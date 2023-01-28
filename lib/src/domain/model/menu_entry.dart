import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class MenuEntry {
  const MenuEntry({
    required this.label,
    this.shortcut,
    this.onPressed,
    this.menuChildren,
  }) : assert(menuChildren == null || onPressed == null,
            'onPressed is ignored if menuChildren are provided');
  final String label;

  final MenuSerializableShortcut? shortcut;
  final VoidCallback? onPressed;
  final List<MenuEntry>? menuChildren;

  MenuEntry rename(String value) {
    return MenuEntry(
      label: value,
      shortcut: shortcut,
      menuChildren: menuChildren,
      onPressed: onPressed,
    );
  }

  MenuEntry merge(List<MenuEntry> children) {
    final children = <MenuEntry>[];
    final current = menuChildren ?? [];
    for (final child in current) {
      final existing = children.firstWhereOrNull(
        (c) => c.label == child.label,
      );
      if (existing != null) {
        children.remove(existing);
        children.add(existing.merge(child.menuChildren ?? []));
      } else {
        children.add(child);
      }
    }
    return MenuEntry(
      label: label,
      shortcut: shortcut,
      menuChildren: children,
    );
  }

  static List<Widget> build(List<MenuEntry> selections) {
    Widget buildSelection(MenuEntry selection) {
      if (selection.menuChildren != null) {
        return SubmenuButton(
          menuChildren: MenuEntry.build(selection.menuChildren!),
          child: Text(selection.label),
        );
      } else {
        return MenuItemButton(
          shortcut: selection.shortcut,
          onPressed: selection.onPressed,
          child: Text(selection.label),
        );
      }
    }

    return selections.map<Widget>(buildSelection).toList();
  }

  static Map<MenuSerializableShortcut, Intent> shortcuts(
    List<MenuEntry> selections,
  ) {
    final result = <MenuSerializableShortcut, Intent>{};
    for (final selection in selections) {
      if (selection.menuChildren != null) {
        result.addAll(MenuEntry.shortcuts(selection.menuChildren!));
      } else {
        if (selection.shortcut != null && selection.onPressed != null) {
          result[selection.shortcut!] = VoidCallbackIntent(
            selection.onPressed!,
          );
        }
      }
    }
    return result;
  }
}
