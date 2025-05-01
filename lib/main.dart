import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gestor_gastos/widgets/login_screen.dart';
import 'package:gestor_gastos/widgets/signup_screen.dart';
import 'package:provider/provider.dart';
import 'package:gestor_gastos/providers/gastos_provider.dart';
import 'package:gestor_gastos/pages/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gestor_gastos/models/gasto_model.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    // Inicializar Hive
    print('Inicializando Hive...');
    await Hive.initFlutter();
    Hive.registerAdapter(GastoAdapter());
    Hive.registerAdapter(SubGastoAdapter());
    final gastosBox = await Hive.openBox<Gasto>('gastosBox');
    final syncQueueBox = await Hive.openBox('syncQueue');
    print('Hive inicializado correctamente. GastosBox isOpen: ${gastosBox.isOpen}, SyncQueueBox isOpen: ${syncQueueBox.isOpen}');

    // Limpieza al inicio para pruebas
    print('Limpiando cajas de Hive...');
    await gastosBox.clear();
    await syncQueueBox.clear();
    print('Cajas de Hive limpiadas. GastosBox length: ${gastosBox.length}, SyncQueueBox length: ${syncQueueBox.length}');

    // Inicializar Supabase
    print('Inicializando Supabase...');
    await Supabase.initialize(
      url: 'https://kqkgkutjrbwifvpyzvrt.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtxa2drdXRqcmJ3aWZ2cHl6dnJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIyNjU1MTQsImV4cCI6MjA1Nzg0MTUxNH0._iluaVC3D3jyFgRAz0Zo8zyZUoHeju9r1vlT6E15Lf4',
    );
    print('Supabase inicializado correctamente.');

    // Inicializar formato de fechas en español
    print('Inicializando formato de fechas...');
    await initializeDateFormatting('es', null);
    print('Formato de fechas inicializado.');

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) {
              print('Creando GastosProvider...');
              return GastosProvider();
            },
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('Error durante la inicialización: $e');
    print('Stack trace: $stackTrace');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Gastos',
      initialRoute: Supabase.instance.client.auth.currentUser == null ? '/login' : '/home',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es')],
      locale: const Locale('es'),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(), // Añade la ruta para la pantalla de registro
        '/home': (context) => const  HomePage(title: 'Gestor de Gastos'), // Tu pantalla principal
      },

    );
  }
}