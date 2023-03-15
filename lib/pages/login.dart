import 'package:d_input/d_input.dart';
import 'package:d_view/d_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:task_crudfirebase/pages/homepage.dart';
import 'package:task_crudfirebase/pages/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _checkLogin());
  }

  void _checkLogin() async {
    final user = _auth.currentUser;
    if (user != null) {
      // User telah login, navigasi ke halaman selanjutnya.
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  void _login() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Validasi input email dan password
      if (email.isEmpty || password.isEmpty) {
        Fluttertoast.showToast(msg: "Mohon isi email dan password");
        return;
      }

      // Login dengan Firebase Authentication
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Navigasi ke halaman selanjutnya setelah login berhasil.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Tampilkan pesan kesalahan jika login gagal.
      Fluttertoast.showToast(msg: "Terjadi kesalahan saat login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Login Page",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 24),
            ),
            DView.spaceHeight(),
            DInput(
              controller: _emailController,
              hint: 'Email',
            ),
            DView.spaceHeight(),
            DInputPassword(
              controller: _passwordController,
              hint: 'Password',
              obsecureCharacter: '*',
            ),
            DView.spaceHeight(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                child: Text("Login"),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black)),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => RegisterPage()));
                },
                child: Text(
                  "Register",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
