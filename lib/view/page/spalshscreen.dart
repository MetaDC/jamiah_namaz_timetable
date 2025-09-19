import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jamiah_namaz_timetable/view/page/homepage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NamazTimePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Material(
      color: Color(0xffFFF2CD),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            SizedBox(
              height: 80,
              width: 400,
              child: Image(
                image: AssetImage("assets/images/spalsh1.png"),
                fit: BoxFit.contain,
              ),
            ),
            // Illustration
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image(
                image: AssetImage("assets/images/spalsh2.png"),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
