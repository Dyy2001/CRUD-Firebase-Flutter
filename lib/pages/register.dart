import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:d_view/d_view.dart';
import 'package:d_input/d_input.dart';
import 'package:d_info/d_info.dart';
import 'package:task_crudfirebase/pages/login.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void register(BuildContext context) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim());

      if (userCredential.user != null) {
        DInfo.toastSuccess('Success register');
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      } else {
        DInfo.toastError('Failed Register');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        DInfo.toastError('Password is too weak');
      } else if (e.code == 'email-already-in-use') {
        DInfo.toastError('Email is already in use');
      } else if (e.code == 'invalid-email') {
        DInfo.toastError('Invalid email format');
      } else {
        DInfo.toastError('Failed Register');
      }
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
              "Register Page",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 24),
            ),
            DView.spaceHeight(),
            DInput(
              controller: emailController,
              hint: 'Email',
            ),
            DView.spaceHeight(),
            DInputPassword(
              controller: passwordController,
              hint: 'Password',
              obsecureCharacter: '*',
            ),
            DView.spaceHeight(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => register(context),
                child: Text("Register"),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black)),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Login",
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
