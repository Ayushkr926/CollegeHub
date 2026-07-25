import 'package:college/Provider/Requestprovider.dart';
import 'package:college/Provider/club_provider.dart';
import 'package:college/Screen/Auth/provider/register_provider.dart';
import 'package:college/Screen/Auth/splash_screen.dart';
import 'package:college/onboarding/HomeScreen.dart';
import 'package:college/storage/local_storage.dart';
import 'package:college/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Provider/Create_event_provider.dart';
import 'Screen/Auth/provider/login_provider.dart';
import 'Screen/Auth/select_role_screen.dart';
import 'Screen/Auth/student_registration_screen.dart';
import 'Screen/Clubs/discover_clubs_screen.dart';
import 'Screen/Events/createevent.dart';
import 'Screen/Profile/Profilescreen.dart';
import 'Screen/Profile/studentprofile.dart';
import 'Screen/Request/requestscreen.dart';
import 'onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CreateEventProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ClubProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Requestprovider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RegisterProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LoginProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Premium Onboarding',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}