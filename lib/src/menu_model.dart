import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// MenuList
class MenuItem {
  final double width;
  final double height;

  final String title;
  final bool isActive;
  final List<MenuListItemType> menuListItems;

  const MenuItem({
    this.width = 170,
    this.height = 200,
    this.title = "Empty",
    this.isActive = true,
    required this.menuListItems,
  });

  @override
  String toString() =>
      'MenuItem(title: $title, isActive: $isActive, menuItemList: $menuListItems)';
}

/// Abstract class
abstract class MenuListItemType {}

/// Use to have a dividerline in your menulist
class MenuListDivider extends MenuListItemType {}

/// Menu Items for your menuList
class MenuListItem extends MenuListItemType {
  final String title;
  final IconData? icon;
  final bool isActive;
  final MenuShortcut? shortcut;
  final Function? onPressed;
  MenuListItem({
    required this.title,
    this.icon,
    this.isActive = true,
    this.shortcut,
    this.onPressed,
  });

  @override
  String toString() {
    return 'MenuListItem(title: $title, icon: $icon, isActive: $isActive, shortcut: $shortcut, onPressed: $onPressed)';
  }
}

/// Setup a keyboard shortcut for MenuItems, notice that shift should only be used in combination with other system keys and take care
/// that the browser takes presidence over the app for keyboard shortcuts so choose with care
class MenuShortcut {
  final LogicalKeyboardKey? key;
  final bool shift;
  final bool alt;
  final bool ctrl;

  MenuShortcut({
    this.key,
    this.shift = false,
    this.alt = false,
    this.ctrl = false,
  });

  @override
  String toString() {
    return 'MenuShortcut(logicalKey: $key, shift: $shift, alt: $alt, ctrl: $ctrl)';
  }
}

// /// DetailPane info:
// class DetailPane {
//   final double defaultWidth;
//   final double minWidth;
//   final double maxWidth;
//   final bool fixedWidth;

//   Pane(this.defaultWidth, this.minWidth, this.maxWidth);
// }
