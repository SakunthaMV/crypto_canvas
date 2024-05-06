import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:provider/provider.dart';

import 'Screens/home.dart';

void main() {
  runApp(
    StreamProvider<InternetStatus>(
      initialData: InternetStatus.connected,
      create: (context) {
        return InternetConnection().onStatusChange;
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Canvas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xff23231a),
          background: Color(0xfffee5d5),
          primaryContainer: Color(0xffFEC19C),
          secondary: Color(0xffFE5F00),
          secondaryContainer: Color(0xff6A5837),
          tertiary: Color(0xff6A5837),
          error: Colors.red,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Crypto Canvas'),
    );
  }
}
