import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_scanner/providers/qr_history_provider.dart';
import 'package:qr_scanner/providers/qr_scanner_provider.dart';
import 'package:qr_scanner/screens/about_screen.dart';
import 'package:qr_scanner/screens/home_screen.dart';
import 'package:qr_scanner/screens/qr_history_screen.dart';
import 'package:qr_scanner/screens/qr_scan_screen.dart';
import 'package:qr_scanner/utilities/side_menu.dart';

final selectedIndex = ValueNotifier<int>(0);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final destinations = <HomeDestination>[
      HomeDestination(
        item: const SideMenuItem('History', Icons.home_outlined),
        screen: const QrHistoryScreen(),
      ),
      HomeDestination(
        item: const SideMenuItem('About', Icons.collections_bookmark_outlined),
        screen: const AboutScreen(),
      ),
    ];

    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => QrHistoryProvider())],
      child: MaterialApp(
        title: 'QR Scanner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Builder(
          builder: (innerContext) => HomePage(
            title: 'Home',
            destinations: destinations,
            selectedIndex: selectedIndex,
            onPrimaryAction: () async {
              await Navigator.of(innerContext).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (_) => QrScannerProvider(),
                    child: const QrScanScreen(),
                  ),
                ),
              );
              if (selectedIndex.value == 0) {
                await innerContext.read<QrHistoryProvider>().refresh();
              }
            },
          ),
        ),
      ),
    );
  }
}
