import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/order_binding.dart';
import 'views/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Global Status - Cafetería',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialBinding: OrderBinding(),
      home: HomePage(),
    );
  }
}
