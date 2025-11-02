import 'package:flutter/material.dart';

class SideMenuItem {
  final String label;
  final IconData icon;
  const SideMenuItem(this.label, this.icon);
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
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: cs.primary,
      child: SafeArea(
        child: ListTileTheme(
          textColor: cs.onPrimary,
          iconColor: cs.onPrimary,
          selectedColor: cs.onPrimary,
          selectedTileColor: cs.onPrimary.withValues(alpha: .12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
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
      ),
    );
  }
}
