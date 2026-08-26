import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/timer_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/stopwatch_provider.dart';
import 'screens/timers_screen.dart';
import 'screens/groups_screen.dart';
import 'screens/tabata_screen.dart';
import 'screens/stopwatch_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (_) => TimerProvider()..init()),
        ChangeNotifierProvider(create: (_) => StopwatchProvider()..init()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Multi Timer App',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    TimersScreen(),
    GroupsScreen(),
    TabataScreen(),
    StopwatchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _BuildNavBar(
          currentIndex: _currentIndex,
          onTabChanged: (i) => setState(() => _currentIndex = i)),
    );
  }
}

class _BuildNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabChanged;

  const _BuildNavBar({required this.currentIndex, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    final totalRunning = _getRunningCount(context);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTabChanged,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.timer_outlined),
          selectedIcon: Icon(Icons.timer),
          label: 'Timers',
        ),
        const NavigationDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: 'Groups',
        ),
        const NavigationDestination(
          icon: Icon(Icons.fitness_center_outlined),
          selectedIcon: Icon(Icons.fitness_center),
          label: 'Tabata',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: totalRunning > 0,
            label: Text('$totalRunning'),
            child: const Icon(Icons.av_timer_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: totalRunning > 0,
            label: Text('$totalRunning'),
            child: const Icon(Icons.av_timer),
          ),
          label: 'Stopwatch',
        ),
        const NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  int _getRunningCount(BuildContext context) {
    return context.watch<StopwatchProvider>().runningCount;
  }
}
