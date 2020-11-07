import 'package:flutter/material.dart';
import 'appscreen.dart';

enum ContextPlacementCenter { longPressOnly, never, always }

abstract class ContextMenuWidget extends StatelessWidget {}

abstract class ContextMenuItemType extends StatelessWidget {}

class ContextMenuContainer extends StatelessWidget {
  final ContextMenuWidget menu;
  final double width;
  final double height;
  final Widget child;
  const ContextMenuContainer(
      {Key key,
      @required this.menu,
      @required this.height,
      @required this.width,
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
            context.appScreen.showContextMenu(
                offset: event.position,
                menu: menu,
                width: width,
                height: height);
          } else
            context.appScreen.hideContextMenu();
        },
        child: child,
      ),
    );
  }
}
