import 'package:admin/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../dashboard/dashboard_screen.dart';
import '../../constants.dart';
import 'forgot_password_screen.dart';
import '../../controllers/menu_app_controller.dart';
import 'package:firebase_database/firebase_database.dart';
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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
UserModel? currentUser;
 Future<void> _login() async {
  if (_formKey.currentState!.validate()) {
    final inputUsername = _usernameController.text.trim();
    final inputPassword = _passwordController.text;

    try {
      // Ambil user dari Realtime Database berdasarkan username
      final dbRef = FirebaseDatabase.instance.ref('User');
      final snapshot = await dbRef.get();

      String? matchedEmail;

      for (final child in snapshot.children) {
        final user = Map<String, dynamic>.from(child.value as Map);

        // Cocokkan username
        if (user['name'] == inputUsername) {
          matchedEmail = user['email'];
          break;
        }
      }

      if (matchedEmail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username tidak ditemukan')),
        );
        return;
      }

      // Gunakan email dari Realtime DB untuk login di FirebaseAuth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: matchedEmail, password: inputPassword);

      // Jika berhasil login, ambil UID dan role
      String uid = userCredential.user?.uid ?? "UID kosong";
      print("Login berhasil dengan UID: $uid");

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
            return;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
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
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF9E79F), // pastel kuning
              Color(0xFFFAD7A0), // pastel oranye
              Color(0xFFA9DFBF), // pastel hijau
              Color(0xFF3A7D44), // hijau daun sawit (lebih gelap)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Card(
              color: Color(0xFF264D32), // hijau gelap elegan
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              margin: const EdgeInsets.all(defaultPadding),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(defaultPadding * 2),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320), // Ubah dari 400 ke 320
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo di atas
                        Image.asset(
                          'assets/images/logo1sawit.png',
                          height: 180, // Ubah dari 80 ke 110 agar logo lebih besar
                        ),
                        const SizedBox(height: defaultPadding),

                        // App Name dengan gradient text
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
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: defaultPadding * 2),

                        // Username Field
                        Material(
                          color: Colors.transparent,
                          child: TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.black), // Teks jadi hitam
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle: TextStyle(color: Colors.grey[700]), // abu-abu
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              prefixIcon: const Icon(Icons.person, color: Colors.black),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: defaultPadding),

                        // Password Field
                        Material(
                          color: Colors.transparent,
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: const TextStyle(color: Colors.black), // Teks jadi hitam
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.grey[700]), // abu-abu
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
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: defaultPadding * 2),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF27329), // oranye
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _login,
                            child: const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: defaultPadding),

                        // Forgot Password Link
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text('Forgot Password?'),
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
    );
  }
}
