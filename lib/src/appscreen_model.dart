import 'package:flutter/material.dart';

import '../flutter_menu.dart';

class Detail {
  double height;
  double width;
  double minDx;
  double minDy;
  double maxDx;
  double maxDy;
  // bool isShown;
  @override
  String toString() =>
      'Detail(height: $height, width: $width, minDx: $minDx), minDy: $minDy, maxDx: $maxDx, minDy: $maxDy)';
}

/// ContextMenu
class ContextMenu {
  final double width;
  final double height;
  final ContextMenuWidget child;

  ContextMenu(
      {@required this.child, @required this.width, @required this.height});
}

/// Custom resizeBar: either use leftColor & rightcolor or decorations. Not both of them
class ResizeBar {
  final double width;
  Color leftColor;
  Color rightColor;
  Decoration decoration;
  final double helperSize;
  Decoration helperDecoration;

  final double helperPos;

  ResizeBar({
    this.width = 5,
    this.decoration,
    this.helperSize = 20,
    this.helperDecoration,
    this.leftColor,
    this.rightColor,
    this.helperPos = 30,
  });
}

ResizeBar kDefaultResizeBar = ResizeBar(
  width: 5,
  helperSize: 20,
  helperPos: 30,
  leftColor: Colors.white,
  rightColor: Colors.blueGrey,
);

class AppDrawer {
  final double smallDrawerWidth;
  final Widget smallDrawer;
  final double largeDrawerWidth;
  final Widget largeDrawer;
  final bool showOnDesktop;
  final bool defaultSmall;
  final bool autoSizing;
  const AppDrawer({
    this.smallDrawerWidth = 70,
    this.smallDrawer,
    this.largeDrawerWidth = 100,
    this.largeDrawer,
    this.showOnDesktop = true,

    /// Start with small (true) or large drawer (false)
    this.defaultSmall = true,

    /// autosizing not yet implemented
    this.autoSizing = true,
  })  : assert(smallDrawerWidth >= 30,
            "Has to be at least 30 for UI to render nicely!"),
        assert(largeDrawerWidth >= 30,
            "Has to be at least 30 for UI to render nicely!");
}
