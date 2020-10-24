import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuItem {
  final double width;
  final double height;

  final String title;
  final bool isActive;
  final List<MenuListItemType> menuListItems;

  const MenuItem({
    this.width = 170,
    this.height = 200,
    this.title,
    this.isActive = true,
    this.menuListItems,
  });

  @override
  String toString() => 'MenuItem(title: $title, isActive: $isActive, menuItemList: $menuListItems)';
}

abstract class MenuListItemType {}

class MenuListDivider extends MenuListItemType {}

class MenuListItem extends MenuListItemType {
  final String title;
  final IconData icon;
  final bool isActive;
  final MenuShortcut shortcut;
  final Function onPressed;
  MenuListItem({
    this.title,
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

class MenuShortcut {
  final LogicalKeyboardKey key;
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
