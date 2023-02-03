import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:meetup/constants/app_strings.dart';
import 'package:meetup/services/auth.service.dart';
import 'package:meetup/views/pages/splash.page.dart';
import 'package:meetup/services/router.service.dart' as router;

import 'constants/app_colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlexSchemeData _myFlexScheme = const FlexSchemeData(
      name: 'Base Theme',
      description: 'Midnight blue theme, custom definition of all colors',
      light: FlexSchemeColor(
        primary: AppColor.primaryColor,
        secondary: AppColor.accentColor,
        primaryContainer: AppColor.primaryColorDark,
        secondaryContainer: AppColor.accentColor,
      ),
      dark: FlexSchemeColor(
        primary: AppColor.primaryColor,
        secondary: AppColor.accentColor,
        primaryContainer: AppColor.primaryColorDark,
        secondaryContainer: AppColor.accentColor,
      ),
    );

    //
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      onGenerateRoute: router.generateRoute,
      // initialRoute: _startRoute,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('es'),
        Locale('de'),
        Locale('ar'),
        Locale('ko'),
      ],
      home: I18n(
        child: const SplashPage(),
        initialLocale: Locale(AuthServices.getLocale()),
      ),
      theme: FlexThemeData.light(
        colors: _myFlexScheme.light,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      // Same setup for the dark theme, but using FlexThemeData.dark().
      darkTheme: FlexThemeData.dark(
        colors: _myFlexScheme.dark,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
    );
  }
}
