import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
    await Hive.openBox<Gasto>('gastosBox');
    await Hive.openBox('syncQueue');
    await Hive.box('syncQueue').clear();
    print('Hive inicializado correctamente.');

    // Limpieza temporal para pruebas (opcional, descomentar solo si quieres reiniciar datos)
    // await Hive.box<Gasto>('gastosBox').clear();
    // await Hive.box('syncQueue').clear();

    // Inicializar Supabase
    print('Inicializando Supabase...');
    await Supabase.initialize(
      url: 'https://kqkgkutjrbwifvpyzvrt.supabase.co', // Reemplaza con tu URL de Supabase
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtxa2drdXRqcmJ3aWZ2cHl6dnJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIyNjU1MTQsImV4cCI6MjA1Nzg0MTUxNH0._iluaVC3D3jyFgRAz0Zo8zyZUoHeju9r1vlT6E15Lf4', // Reemplaza con tu clave anónima
    );
    print('Supabase inicializado correctamente.');

    // Inicializar formato de fechas en español
    print('Inicializando formato de fechas...');
    await initializeDateFormatting('es', null);
    print('Formato de fechas inicializado.');

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GastosProvider()),
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
      home: const HomePage(title: 'Gestor de Gastos'),
    );
  }
}