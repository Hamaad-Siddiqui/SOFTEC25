import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  static const String routeName = '/login';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
