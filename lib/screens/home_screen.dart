import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_scanner/utilities/scan_button.dart';
import 'package:qr_scanner/utilities/side_menu.dart';
import 'package:qr_scanner/utilities/themed_background.dart';

class HomeDestination {
  final SideMenuItem item;
  final Widget screen;
  const HomeDestination({required this.item, required this.screen});
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.title,
    required this.destinations,
    required this.selectedIndex,
    this.onPrimaryAction,
  });

  final String title;
  final List<HomeDestination> destinations;
  final ValueNotifier<int> selectedIndex;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (context, index, _) {
        final current = (index >= 0 && index < destinations.length)
            ? destinations[index]
            : null;
        final cs = Theme.of(context).colorScheme;
        final barBg = cs.primary;
        final barFg = cs.onPrimary;
        final isDarkBar =
            ThemeData.estimateBrightnessForColor(barBg) == Brightness.dark;

        return Stack(
          children: [
            const Positioned.fill(child: ThemedBackground()),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: barBg,
                foregroundColor: barFg,
                elevation: 0,
                systemOverlayStyle: isDarkBar
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
                title: Text(current?.item.label ?? title),
              ),
              drawer: SideMenu(
                items: destinations.map((d) => d.item).toList(),
                selectedIndex: index,
                onSelected: (i) => selectedIndex.value = i,
              ),
              body: IndexedStack(
                index: index,
                children: destinations.map((d) => d.screen).toList(),
              ),
              floatingActionButton: onPrimaryAction != null && index == 0
                  ? ScanButton(onPressed: onPrimaryAction!)
                  : null,
            ),
          ],
        );
      },
    );
  }
}
