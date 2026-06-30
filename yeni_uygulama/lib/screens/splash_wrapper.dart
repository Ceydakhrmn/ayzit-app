import 'dart:async';
import 'package:flutter/material.dart';
import 'splash_screen.dart';

class SplashWrapper extends StatefulWidget {
  final Widget child;

  const SplashWrapper({super.key, required this.child});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // 3 saniye sonra splash screen'i gizle
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showSplash ? const DonguSplash() : widget.child;
  }
}
