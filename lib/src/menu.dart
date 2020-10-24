import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'menu_model.dart';

extension BuildContextMenuFinder on BuildContext {
  MenuState get menu => Menu.of(this);
}

typedef MenuBuilderCallback = Widget Function();

class Menu extends StatefulWidget {
  final Builder builder;
  final MenuBuilderCallback menuBuilder;
  final List<MenuItem> menuList;
  final Widget leading;
  final Widget trailing;

  const Menu({
    Key key,
    @required this.builder,
    @required this.menuBuilder,
    this.menuList,
    this.leading,
    this.trailing,
  })  : assert(menuBuilder != null, "menuBuilder is missing!"),
        super(key: key);

  static MenuState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MenuInherited>().data;
  }

  @override
  State<StatefulWidget> createState() {
    return MenuState();
  }
}

class MenuState extends State<Menu> {
  bool _menuIsOpen = false;
  bool _isActive = true;
  bool _menuIsShown = true;
  bool _showShortcutOverlay = true;

  bool get isShown => _menuIsShown;
  bool get isOpen => _menuIsOpen;
  bool get isActive => _isActive;

  void showShortcutOverlay() => _showShortcutOverlay = true;
  void hideShortcutOverlay() => _showShortcutOverlay = false;

  int _activeIndex = 0;

  void hideMenu() {
    if (_menuIsShown) {
      setState(() {
        _menuIsShown = false;
      });
    }
  }

  void showMenu() {
    if (!_menuIsShown) {
      setState(() {
        _menuIsShown = true;
      });
    }
  }

  void openMenu() {
    if (!_menuIsOpen) {
      setState(() {
        _menuIsOpen = true;
      });
    }
  }

  void closeMenu() {
    if (_menuIsOpen) {
      setState(() {
        _menuIsOpen = false;
      });
    }
  }

  final FocusNode _focusNode = FocusNode();
  String shortcutLabel;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    // only check on key down and only tjek if real key is involved
    if (event.runtimeType == RawKeyDownEvent && event.logicalKey.keyLabel != '') {
      print('checking');
      print('logical key ${event.logicalKey}');
      widget.menuList.forEach((menuList) {
        menuList.menuListItems.forEach((listItem) {
          if (listItem is MenuListItem) {
            if (listItem.shortcut != null &&
                event.isControlPressed == listItem.shortcut.ctrl &&
                event.isAltPressed == listItem.shortcut.alt &&
                event.isShiftPressed == listItem.shortcut.shift &&
                event.logicalKey == listItem.shortcut.key) {
              print(listItem.shortcut);
              if (_showShortcutOverlay) {
                Timer(Duration(seconds: 2), () {
                  // remove the label after 2 seconds
                  setState(() {
                    shortcutLabel = '';
                  });
                });
                setState(() {
                  shortcutLabel = shortcutText(listItem.shortcut);
                });
              }
              if (listItem.onPressed != null) {
                closeMenu();
                listItem.onPressed();
              }
            }
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MenuInherited(
      data: this,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // widget.controller.hideContextMenu();

          // if (constraints.maxWidth != currentWidth)
          return RawKeyboardListener(
            focusNode: _focusNode,
            onKey: _handleKeyEvent,
            autofocus: true,
            child: Stack(
              children: [
                Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_menuIsShown)
                      SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: Container(
                            color: Colors.blueGrey,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (widget.leading != null)
                                  Row(
                                    children: [
                                      widget.leading,
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4, right: 4),
                                        child: SizedBox(width: 2, child: Container(color: Colors.blueGrey[100])),
                                      ),
                                    ],
                                  ),
                                if (widget.menuList != null)
                                  Row(
                                    children: buildMenuList(),
                                  ),
                                if (widget.menuBuilder != null) widget.menuBuilder(),
                                if (widget.trailing != null)
                                  Expanded(child: Align(alignment: Alignment.centerRight, child: widget.trailing)),
                              ],
                            )),
                      ),
                    if (widget.builder != null) Expanded(child: widget.builder),
                  ],
                ),

                if (_menuIsShown && _menuIsOpen)
                  Positioned(
                    left: (116 * _activeIndex).toDouble(),
                    top: 30,
                    child: SizedBox(
                        height: (30 * widget.menuList[_activeIndex].menuListItems.length).toDouble(),
                        width: widget.menuList[_activeIndex].width,
                        child: Container(
                          color: Colors.blueGrey[700],
                          child: ListView(
                            itemExtent: 30,
                            children: buildItemList(),
                          ),
                        )),
                  ),
                Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (event) {
                    if (event.buttons == 2) {
                      print('Højre tast i hele vinduet');
                    } // højre klik
                    closeMenu();
                  },
                ),

                // ValueListenableBuilder(
                //   valueListenable: widget.controller,
                //   builder: (context, value, child) {
                //     if (value.contextShow && value.contextMenu != null)
                //       return Positioned(
                //         left: value.contextOffset.dx,
                //         top: value.contextOffset.dy,
                //         child: Listener(
                //           behavior: HitTestBehavior.opaque,
                //           onPointerSignal: (event) {
                //             print('${event.toString()}');
                //           },
                //           onPointerDown: (event) {
                //             // if (event.buttons == 2) // højre klik
                //             // {
                //             //   widget.controller.hideContextMenu();
                //             // }
                //           },
                //           child: value.contextMenu,
                //         ),
                //       );
                //     return Container();
                //   },
                // ),
                if (_showShortcutOverlay && shortcutLabel != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      shortcutLabel,
                      style: TextStyle(color: Colors.blue, fontSize: 50),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> buildItemList() {
    List<Widget> buildItemList = [];
    int _nextIndex = 0;

    for (int i = 0; i < widget.menuList[_activeIndex].menuListItems.length; i++) {
      var listItem = widget.menuList[_activeIndex].menuListItems[i];

      if (listItem is MenuListItem) {
        if (listItem.isActive) {
          buildItemList.add(
            FlatButton(
              hoverColor: Colors.black26,
              onPressed: listItem.isActive && listItem.onPressed != null
                  ? () {
                      closeMenu();
                      listItem.onPressed();
                    }
                  : null,
              child: Row(
                children: [
                  if (listItem.icon != null)
                    Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(width: 20, child: Icon(listItem.icon, size: 12, color: Colors.white))),
                  if (listItem.icon == null) SizedBox(width: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(listItem.title, style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
                  if (listItem.shortcut != null)
                    Expanded(
                      // child:
                      // Align(
                      // alignment: Alignment.centerRight,
                      child: Text(
                        shortcutText(listItem.shortcut),
                        textAlign: TextAlign.end,
                        style: TextStyle(color: Colors.white70, fontSize: 8),
                      ),
                      // ),
                    ),
                ],
              ),
            ),
          );
          _nextIndex++;
        }
      }
      if (listItem is MenuListDivider) {
        // insert divider
        buildItemList.add(
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Divider(height: 2, thickness: 2, color: Colors.white24),
          ),
        );
      }
    }
    return buildItemList;
  }

  List<Widget> buildMenuList() {
    List<Widget> buildList = [];
    // int index = 0;
    for (int i = 0; i < widget.menuList.length; i++) {
      if (widget.menuList[i].isActive)
        buildList.add(MouseRegion(
          onHover: (item) {
            setState(() {
              _activeIndex = i;
            });
          },
          child: FlatButton(
            hoverColor: Colors.black38,
            onPressed: () {
              print('We got a hit at $i');
              _activeIndex = i;
              openMenu(); // Calls setState
            },
            child: SizedBox(
                width: 100,
                child: Center(
                    child: Text(widget.menuList[i].title, style: TextStyle(color: Colors.white70, fontSize: 12)))),
          ),
        ));
    }
    // widget.menuList.forEach((menuItem) {
    //   if (menuItem.isActive)
    //     buildList.add(FlatButton(
    //       onPressed: () {
    //         print('We got a hit at $index');
    //         setState(() {
    //           _activeIndex = index;
    //         });
    //       },
    //       child: Text(menuItem.title, style: TextStyle(color: Colors.white70, fontSize: 12)),
    //     )
    //         // Row(
    //         //   children: [
    //         //     Padding(
    //         //       padding: const EdgeInsets.only(left: 15.0, right: 15),
    //         //       child: Row(
    //         //         children: [
    //         //           Text(menuItem.title, style: TextStyle(color: Colors.white70, fontSize: 12)),
    //         //         ],
    //         //       ),
    //         //     ),
    //         //     SizedBox(width: 2, child: Container(color: Colors.black26))
    //         //   ],
    //         // ),
    //         );
    //   index = index + 1;
    // });

    // print(widget.menuList.toString());
    return buildList;
  }
}

class MenuInherited extends InheritedWidget {
  final MenuState data;

  MenuInherited({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

const String labelCtrl = 'Ctrl+';
const String labelAlt = ' Alt+';
const String labelShift = 'Shift+';

String shortcutText(MenuShortcut shortcut) {
  // String text = '';
  return (shortcut.ctrl ? labelCtrl : '') +
      (shortcut.alt ? labelAlt : '') +
      (shortcut.shift ? labelShift : '') +
      shortcut.key.keyLabel;
}
