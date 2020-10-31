import 'package:flutter/material.dart';
import 'appscreen.dart';

class ContextMenu extends StatelessWidget {
  final Widget child;
  final Widget menu;

  const ContextMenu({Key key, @required this.menu, this.child})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) {
          if (event.buttons == 2) // højre klik
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
