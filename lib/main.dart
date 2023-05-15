import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:band_names/pages/pages.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider( // para que este disponible en cualquier widget que necesite
      providers: [ // inicializar instancias
        ChangeNotifierProvider(
          create: (context) => SocketService(),
        )
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        initialRoute: 'home',
        routes: {
          'home': (_) => const HomePage(),
          'status': (_) => const StatusPage()
        },
      ),
    );
  }
}