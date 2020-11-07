import 'package:flutter/material.dart';
import 'appscreen.dart';

enum ContextPlacementCenter { longPressOnly, never, always }

abstract class ContextMenuType extends StatelessWidget {}

abstract class ContextMenuItemType extends StatelessWidget {}

class ContextMenu extends StatelessWidget {
  final ContextMenuType menu;
  final double menuWidth;
  final double menuHeight;
  final Widget child;
  const ContextMenu(
      {Key key,
      @required this.menu,
      this.menuHeight,
      this.menuWidth,
      this.child})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          if (event.buttons == 2) // right click
          {
            context.appScreen
                .showContextMenu(offset: event.position, menu: menu);
          } else
            context.appScreen.hideContextMenu();
        },
        child: child,
      ),
    );
  }
}
