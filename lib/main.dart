// import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';

import 'models/library.dart';
import 'screens/home.dart';
import 'screens/settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('MiruRyoiki');
    setWindowMinSize(const Size(800, 600));
    setWindowMaxSize(Size.infinite);
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => Library(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'MiruRyoiki',
      theme: FluentThemeData(
        accentColor: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: FluentThemeData(
        accentColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const AppRoot(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        title: const Text('MiruRyoiki'),
        automaticallyImplyLeading: false,
      ),
      pane: NavigationPane(
        selected: _selectedIndex,
        onChanged: (index) => setState(() => _selectedIndex = index),
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.video),
            title: const Text('Library'),
            body: const HomeScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('Settings'),
            body: const SettingsScreen(),
          ),
        ],
      ),
    );
  }
}