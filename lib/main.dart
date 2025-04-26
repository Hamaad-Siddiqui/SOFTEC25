import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:softec25/bloc/main_bloc.dart';
import 'package:softec25/firebase_options.dart';
import 'package:softec25/screens/login.dart';

late Box box;

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MainBloc mb;

  bool _init = false;

  Future<void> initialize() async {
    if (_init) return;
    _init = true;

    mb.box = box;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      splitScreenMode: true,
      child: ChangeNotifierProvider(
        create: (context) => MainBloc(),

        builder: (context, child) {
          mb = context.read<MainBloc>();

          initialize();

          return child!;
        },

        child: MaterialApp(
          title: 'Personal AI Life Assistant',

          routes: {Login.routeName: (context) => const Login()},
          initialRoute: Login.routeName,
        ),
      ),
      builder: (context, child) {
        return child!;
      },
    );
  }
}
