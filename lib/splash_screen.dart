import 'package:flutter/material.dart';
import 'package:vibe_chat/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibe_chat/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  @override
void initState() {
  super.initState();

  Future.delayed(const Duration(seconds: 1), () {

    if (FirebaseAuth.instance.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        ),
      );
    }

  });
}
  @override
  Widget build(BuildContext context) {
     return Scaffold(
     backgroundColor: Colors.grey[900],
      body: Padding(
        padding: EdgeInsets.fromLTRB(100,300,100,100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/Final-IMAGE.png',
              width: 250,
              height: 250,
            ),

            SizedBox(
              height: 210,
            ),
            Text(
              'Vibe Chat',
               style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontFamily: 'RedHatDisplay',
                fontWeight: FontWeight.bold,
               ),
            ),
            SizedBox(
              height:4,
            ),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontFamily: 'RedWeightDisplay',
              ),     
            ),
          ],
         ),
      ),
    );
  }
}