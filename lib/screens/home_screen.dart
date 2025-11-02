import 'package:flutter/material.dart';

class SideMenuItem {
  final String label;
  final IconData icon;
  const SideMenuItem(this.label, this.icon);
}

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
    this.fabIcon = Icons.add,
  });

  final String title;
  final List<HomeDestination> destinations;
  final ValueNotifier<int> selectedIndex;
  final VoidCallback? onPrimaryAction;
  final IconData fabIcon;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (context, index, _) {
        final current = (index >= 0 && index < destinations.length)
            ? destinations[index]
            : null;
        return Scaffold(
          appBar: AppBar(title: Text(current?.item.label ?? title)),
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
              ? FancyMiniButton(icon: fabIcon, onPressed: onPrimaryAction!)
              : null,
        );
      },
    );
  }
}

class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<SideMenuItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            final selected = i == selectedIndex;
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              selected: selected,
              onTap: () {
                Navigator.of(context).pop();
                onSelected(i);
              },
            );
          },
        ),
      ),
    );
  }
}

class FancyMiniButton extends StatelessWidget {
  const FancyMiniButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
  });

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: 48,
      child: Material(
        shape: const CircleBorder(),
        elevation: 8,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Ink(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF60A5FA), Color(0xFF7C3AED)],
              ),
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
