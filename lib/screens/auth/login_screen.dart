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
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Ubah menjadi format email jika perlu
    String email = username.contains('@') ? username : '$username@sawit.com';

    try {
      // Login menggunakan FirebaseAuth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // UID berhasil diambil
      String uid = userCredential.user?.uid ?? "UID kosong";
      print("Login berhasil dengan UID: $uid");

      // Ambil role user dari Realtime Database
      final dbRef = FirebaseDatabase.instance.ref('User');
      final snapshot = await dbRef.get();

      for (final child in snapshot.children) {
        final user = Map<String, dynamic>.from(child.value as Map);
        if (user['email'] == email) {
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
        message = 'User tidak ditemukan';
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
      body: SafeArea(
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(defaultPadding),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo or App Name
                      const Text(
                        "SAWIT",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: defaultPadding * 2),

                      // Username Field
                      Material(
                        child: TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.person),
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
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
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
    );
  }
}
