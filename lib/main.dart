import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:softec25/bloc/main_bloc.dart';
import 'package:softec25/env/env.dart';
import 'package:softec25/firebase_options.dart';
import 'package:softec25/screens/auth/forgot_password.dart';
import 'package:softec25/screens/auth/login.dart';
import 'package:softec25/screens/auth/register.dart';
import 'package:softec25/screens/home/ai.dart';
import 'package:softec25/screens/home/dashboard.dart';
import 'package:softec25/screens/home/home.dart';
import 'package:softec25/screens/home/mood_tracking.dart';
import 'package:softec25/screens/home/settings.dart';

late Box box;

void main() async {
  final widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(
    widgetsBinding: widgetsBinding,
  );

  await Hive.initFlutter();
  box = await Hive.openBox('data');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  OpenAI.apiKey = Env.apiKey;

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

          routes: {
            Login.routeName: (context) => const Login(),
            Register.routeName:
                (context) => const Register(),
            ForgotPassword.routeName:
                (context) => const ForgotPassword(),
            Dashboard.routeName:
                (context) => const Dashboard(),
            HomeScreen.routeName:
                (context) => const HomeScreen(),
            SettingScreen.routeName:
                (context) => const SettingScreen(),
            AIScreen.routeName:
                (context) => const AIScreen(),
            MoodTrackingScreen.routeName:
                (context) => const MoodTrackingScreen(),
          },
          initialRoute: Login.routeName,
        ),
      ),
      builder: (context, child) {
        return child!;
      },
    );
  }
}
