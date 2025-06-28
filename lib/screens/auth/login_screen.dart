import 'package:flutter/services.dart';
// import 'package:admin/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../dashboard/dashboard_screen.dart';
// import '../../constants.dart';
import 'forgot_password_screen.dart';
import '../../controllers/menu_app_controller.dart';
import '../../screens/dashboard/dashboard_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final inputUsername = _usernameController.text.trim();
      final inputPassword = _passwordController.text;

      try {
        final dbRef = FirebaseDatabase.instance.ref('User');
        final snapshot = await dbRef.get();

        String? matchedEmail;

        for (final child in snapshot.children) {
          final user = Map<String, dynamic>.from(child.value as Map);
          if (user['name'] == inputUsername) {
            matchedEmail = user['email'];
            break;
          }
        }

        if (matchedEmail == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username tidak ditemukan')),
          );
          setState(() => _isLoading = false);
          return;
        }

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: matchedEmail, password: inputPassword);

        String uid = userCredential.user?.uid ?? "UID kosong";

        for (final child in snapshot.children) {
          final user = Map<String, dynamic>.from(child.value as Map);
          if (user['email'] == matchedEmail) {
            int role = int.tryParse(user['role'].toString()) ?? 0;
            Widget destination;

            if (role == 1) {
              destination = MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (context) => MenuAppController()),
                ],
                child: DashboardScreen(),
              );
            } else if (role == 2) {
              destination = MultiProvider(
                providers: [
                  ChangeNotifierProvider(create: (context) => MenuAppController()),
                ],
                child: DashboardUser(),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Role tidak dikenali')),
              );
              setState(() => _isLoading = false);
              return;
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
            setState(() => _isLoading = false);
            return;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User tidak ditemukan di database')),
        );
      } on FirebaseAuthException catch (e) {
        String message = 'Login gagal';
        if (e.code == 'user-not-found') {
          message = 'Email tidak ditemukan';
        } else if (e.code == 'wrong-password') {
          message = 'Password salah';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showUserDataForm(User user) async {
    final _nameController = TextEditingController(text: user.displayName ?? '');
    final _emailController = TextEditingController(text: user.email ?? '');
    final _alamatController = TextEditingController();
    final _teleponController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Lengkapi Data Anda'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  controller: _emailController,
                  enabled: false,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _alamatController,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                ),
                TextField(
                  controller: _teleponController,
                  decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Lanjutkan'),
              onPressed: () async {
                final uid = user.uid;
                final dbRef = FirebaseDatabase.instance.ref('User/$uid');

                await dbRef.set({
                  "name": _nameController.text,
                  "email": _emailController.text,
                  "alamat": _alamatController.text,
                  "nomor_telepon": _teleponController.text,
                  "password": "-", // Placeholder
                  "role": 2,
                });

                Navigator.of(context).pop();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider(create: (context) => MenuAppController()),
                      ],
                      child: DashboardUser(),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn();

      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login gagal')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final uid = user.uid;
      final dbRef = FirebaseDatabase.instance.ref('User/$uid');
      final snapshot = await dbRef.get();

      if (!snapshot.exists) {
        await _showUserDataForm(user); // tampilkan form & simpan
        setState(() => _isLoading = false);
        return;
      }

      final userData = Map<String, dynamic>.from(snapshot.value as Map);
      int role = int.tryParse(userData['role'].toString()) ?? 0;

      Widget destination;
      if (role == 1) {
        destination = MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => MenuAppController()),
          ],
          child: DashboardScreen(),
        );
      } else if (role == 2) {
        destination = MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => MenuAppController()),
          ],
          child: DashboardUser(),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role tidak dikenali')),
        );
        setState(() => _isLoading = false);
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    } catch (e, stacktrace) {
      print("Login Google error: $e");
      print("Stacktrace: $stacktrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF9E79F),
              Color(0xFFFAD7A0),
              Color(0xFFA9DFBF),
              Color(0xFF3A7D44),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 0,
                vertical: isMobile ? 16 : 0,
              ),
              child: Card(
                color: const Color(0xFF264D32),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                margin: EdgeInsets.all(isMobile ? 8 : 32),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 18 : 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 340),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo1sawit.png',
                            height: isMobile ? 120 : 180,
                          ),
                          const SizedBox(height: 18),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFFF9D923),
                                Color(0xFFF27329),
                                Color(0xFF3A7D44),
                              ],
                            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                            child: const Text(
                              "I-SAWIT",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Material(
                            color: Colors.transparent,
                            child: TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Username',
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                prefixIcon: const Icon(Icons.person, color: Colors.black),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan username';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          Material(
                            color: Colors.transparent,
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                prefixIcon: const Icon(Icons.lock, color: Colors.black),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan password';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF27329),
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text('Login'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              icon: Image.asset('assets/images/google_icon.png', height: 22),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(color: Color(0xFFF27329), width: 1.2),
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              label: const Text('Login dengan Google'),
                              onPressed: _isLoading ? null : _loginWithGoogle,
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Lupa Password?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
