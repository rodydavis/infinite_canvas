import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'actions.dart';
import 'controller.dart';

/// A widget that displays a menu for the [InfiniteCanvas].
class InfiniteCanvasMenu extends StatefulWidget {
  const InfiniteCanvasMenu({
    super.key,
    required this.child,
    required this.controller,
    this.visible = true,
  });

  final Widget child;
  final bool visible;
  final InfiniteCanvasController controller;

  @override
  State<InfiniteCanvasMenu> createState() => _InfiniteCanvasMenuState();
}

class _InfiniteCanvasMenuState extends State<InfiniteCanvasMenu> {
  ShortcutRegistryEntry? _shortcutsEntry;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(onUpdate);
  }

  void onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _shortcutsEntry?.dispose();
    widget.controller.removeListener(onUpdate);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant InfiniteCanvasMenu oldWidget) {
    if (oldWidget.visible != widget.visible) {
      if (mounted) setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (widget.visible)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: MenuBar(
                  children: MenuEntry.build(buildMenus(context)),
                ),
              ),
            ],
          ),
        Expanded(child: widget.child),
      ],
    );
  }

  List<MenuEntry> buildMenus(BuildContext context) {
    final result = <MenuEntry>[
      MenuEntry(
        label: 'View',
        menuChildren: [
          MenuEntry(
            label: 'Zoom In',
            onPressed: widget.controller.zoomIn,
            shortcut: const SingleActivator(
              LogicalKeyboardKey.equal,
            ),
          ),
          MenuEntry(
            label: 'Zoom Out',
            onPressed: widget.controller.zoomOut,
            shortcut: const SingleActivator(
              LogicalKeyboardKey.minus,
            ),
          ),
          MenuEntry(
            label: 'Move Up',
            onPressed: widget.controller.panUp,
            shortcut: const SingleActivator(
              LogicalKeyboardKey.arrowUp,
            ),
          ),
          MenuEntry(
            label: 'Move Down',
            onPressed: widget.controller.panDown,
            shortcut: const SingleActivator(
              LogicalKeyboardKey.arrowDown,
            ),
          ),
          MenuEntry(
            label: 'Move Left',
            onPressed: widget.controller.panLeft,
            shortcut: const SingleActivator(
              LogicalKeyboardKey.arrowLeft,
            ),
          ),
          MenuEntry(
            label: 'Move Right',
            onPressed: widget.controller.panRight,
            shortcut: const SingleActivator(
              LogicalKeyboardKey.arrowRight,
            ),
          ),
          MenuEntry(
            label: 'Reset',
            onPressed: widget.controller.zoomReset,
          ),
        ],
      ),
      MenuEntry(
        label: 'Object',
        menuChildren: [
          MenuEntry(
            label: 'Select All',
            onPressed: widget.controller.selection.length ==
                    widget.controller.nodes.length
                ? null
                : widget.controller.selectAll,
            shortcut: const SingleActivator(
              LogicalKeyboardKey.keyA,
              meta: true,
            ),
          ),
          MenuEntry(
            label: 'Deselect All',
            onPressed: widget.controller.selection.isEmpty
                ? null
                : widget.controller.deselectAll,
            shortcut: const SingleActivator(
              LogicalKeyboardKey.keyA,
              meta: true,
              shift: true,
            ),
          ),
          MenuEntry(
            label: 'Send to back',
            onPressed: widget.controller.sendToBack,
            shortcut: const SingleActivator(
              LogicalKeyboardKey.bracketLeft,
            ),
          ),
          MenuEntry(
            label: 'Send backward',
            onPressed: widget.controller.selection.length == 1
                ? widget.controller.sendBackward
                : null,
            shortcut: const SingleActivator(
              LogicalKeyboardKey.bracketLeft,
              meta: true,
            ),
          ),
          MenuEntry(
            label: 'Bring forward',
            onPressed: widget.controller.selection.length == 1
                ? widget.controller.sendForward
                : null,
            shortcut: const SingleActivator(
              LogicalKeyboardKey.bracketRight,
              meta: true,
            ),
          ),
          MenuEntry(
            label: 'Bring to front',
            onPressed: widget.controller.bringToFront,
            shortcut: const SingleActivator(
              LogicalKeyboardKey.bracketRight,
            ),
          ),
          MenuEntry(
            label: 'Rename',
            onPressed: widget.controller.selection.length == 1
                ? () {
                    final item = widget.controller.selection.first;
                    widget.controller.focusNode.unfocus();
                    prompt(
                      context,
                      title: 'Rename child',
                      value: item.label,
                    ).then((value) {
                      widget.controller.focusNode.requestFocus();
                      if (value == null) return;
                      final newItem = item.copyWith(label: value);
                      widget.controller.edit(newItem);
                    });
                  }
                : null,
            shortcut: const SingleActivator(
              LogicalKeyboardKey.keyR,
              meta: true,
            ),
          ),
          MenuEntry(
            label: 'Delete',
            onPressed: () {
              confirm(
                context,
                title: 'Delete Selection',
                content: 'Do you want to delete the current selection?',
              ).then(
                (value) {
                  if (!value) return;
                  widget.controller.deleteSelection();
                },
              );
            },
            shortcut: const SingleActivator(
              LogicalKeyboardKey.keyD,
              meta: true,
            ),
          ),
        ],
      ),
      // MenuEntry(
      //   label: 'Help',
      //   menuChildren: [
      //     MenuEntry(
      //       label: 'View License',
      //       onPressed: () {
      //         showLicensePage(context: context);
      //       },
      //     ),
      //   ],
      // ),
    ];
    _shortcutsEntry?.dispose();
    final registry = ShortcutRegistry.of(context);
    final items = MenuEntry.shortcuts(result);
    if (items.isNotEmpty) {
      _shortcutsEntry = registry.addAll(items);
    } else {
      _shortcutsEntry = null;
    }
    return result;
  }
}

class MenuEntry {
  const MenuEntry(
      {required this.label, this.shortcut, this.onPressed, this.menuChildren})
      : assert(menuChildren == null || onPressed == null,
            'onPressed is ignored if menuChildren are provided');
  final String label;

  final MenuSerializableShortcut? shortcut;
  final VoidCallback? onPressed;
  final List<MenuEntry>? menuChildren;

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
