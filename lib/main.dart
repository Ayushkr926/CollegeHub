import 'package:college/Provider/Requestprovider.dart';
import 'package:college/Provider/club_provider.dart';
import 'package:college/Provider/events_provider.dart';
import 'package:college/Screen/Auth/provider/register_provider.dart';
import 'package:college/Screen/Auth/splash_screen.dart';
import 'package:college/onboarding/HomeScreen.dart';
import 'package:college/storage/local_storage.dart';
import 'package:college/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:college/Notices/homescreen/provider/home_provider.dart';
import 'notice/providers/notice_provider.dart';
import 'notice/repositories/notice_repository.dart';
import 'notice/services/notice_api_service.dart';
import 'Provider/Create_event_provider.dart';
import 'Provider/profile_provider_student.dart';
import 'Screen/Auth/provider/club_registration.dart';
import 'Screen/Auth/provider/login_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final noticeApiService = NoticeApiService(
    );
    final noticeRepository = NoticeRepository(
      apiService: noticeApiService,
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CreateEventProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ClubProvider(),
        ),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(
          create: (_) => Requestprovider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RegisterProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LoginProvider(),
        ),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ClubRegistrationProvider()),
        ChangeNotifierProvider(create: (_) => HomeFeedProvider()),
        ChangeNotifierProvider(create: (_) => NoticeProvider(repository: noticeRepository)),
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