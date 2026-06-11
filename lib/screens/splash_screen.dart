import 'package:flutter/material.dart';

class DonguSplash extends StatelessWidget {
  const DonguSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/logo_new.png',
          width: 160,
          height: 160,
        ),
      ),
    );
  }
}
