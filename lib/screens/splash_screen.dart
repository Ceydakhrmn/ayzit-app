import 'package:flutter/material.dart';

class DonguSplash extends StatelessWidget {
  const DonguSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5EEF8),
      body: Center(
        child: Image(
          image: AssetImage('assets/logo_new.png'),
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
