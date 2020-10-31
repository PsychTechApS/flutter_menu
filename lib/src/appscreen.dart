import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'menu_model.dart';

/// extension for quick access to menu actions and informations
extension BuildContextMenuFinder on BuildContext {
  AppScreenState get appScreen => AppScreen.of(this);
}

typedef MenuBuilderCallback = Widget Function();

/// Menu shows an menu, enables keyboard shortcuts to MenuItems and give master/detail panes
class AppScreen extends StatefulWidget {
  final List<MenuItem> menuList;
  final Builder masterPane;

  final Builder detailPane;
  final double detailMinWidth;
  final double detailMaxWidth;
  final double detailWidth;
  final bool detailFixedWidth;
  final double desktopBreakpoint;
  final Function onBreakpointChange;

  final Builder drawerPane;
  final Widget leading;
  final Widget trailing;

  const AppScreen({
    Key key,
    this.menuList,
    this.masterPane,
    this.detailPane,
    this.detailMinWidth = 500,
    this.detailMaxWidth = 300,
    this.detailWidth = 400,
    this.detailFixedWidth = false,
    this.desktopBreakpoint = 800,

    /// Use this to update ui when desktop vs compact change happens
    this.onBreakpointChange,
    this.drawerPane,
    this.leading,
    this.trailing,
  })  : assert(menuList != null, "menuList is missing!"),
        assert(masterPane != null, "masterPane is missing!"),
        assert(detailMinWidth < detailMaxWidth, "Min width > max width!"),
        super(key: key);

  static AppScreenState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppScreenInherited>()
        .data;
  }

  @override
  State<StatefulWidget> createState() {
    return AppScreenState();
  }
}

class AppScreenState extends State<AppScreen> {
  bool _menuIsOpen = false;
  bool _menuIsShown = true;
  bool _showShortcutOverlay = true;

  /// True = Menu is Shown
  bool get isShown => _menuIsShown;

  /// True = MenuList is open (the active MenuItem has it MenuList shown)
  bool get isOpen => _menuIsOpen;

  void showShortcutOverlay() => _showShortcutOverlay = true;
  void hideShortcutOverlay() => _showShortcutOverlay = false;

  int _activeIndex = 0;

  /// Menu will be hidden from screen
  void hideMenu() {
    if (_menuIsShown) {
      setState(() {
        _menuIsShown = false;
      });
    }
  }

  /// Menu will be on screen
  void showMenu() {
    if (!_menuIsShown) {
      setState(() {
        _menuIsShown = true;
      });
    }
  }

  /// Active MenuItem will get is menulist shown
  void openMenu() {
    if (!_menuIsOpen) {
      setState(() {
        _menuIsOpen = true;
      });
    }
  }

  /// MenuList will be closed
  void closeMenu() {
    if (_menuIsOpen) {
      setState(() {
        _menuIsOpen = false;
      });
    }
  }

  final double kMenuHeight = 30;

  double _paneHeight;
  double _detailPaneWidth;
  double detailPaneWidth() => _detailPaneWidth;
  double paneHeight() => _paneHeight;

  void _calcPaneHeight(double screenHeight) {
    if (_menuIsShown)
      _paneHeight = screenHeight - kMenuHeight;
    else
      _paneHeight = screenHeight;
  }

  void _handleBreakpoint(BoxConstraints constraints) {
    if (constraints.maxWidth >= widget.desktopBreakpoint) {
      if (!_isDesktop) {
        _isDesktop = true;
        if (widget.onBreakpointChange != null) _onBreakPointChange();
      }
    } else if (_isDesktop) {
      _isDesktop = false;
      if (widget.onBreakpointChange != null) _onBreakPointChange();
    }
  }

  Future _onBreakPointChange() async {
    // Move to next tick to prevent call under build
    Future.delayed(Duration.zero, () async {
      widget.onBreakpointChange();
    });
  }

  void setDetailPaneWidth({@required double width}) {
    if (width < widget.detailMinWidth)
      _detailPaneWidth = widget.detailMinWidth;
    else if (width > widget.detailMaxWidth)
      _detailPaneWidth = widget.detailMaxWidth;
    else
      _detailPaneWidth = width;
    setState(() {});
  }

  bool _isDesktop = true;
  bool _compactShowDetail = false;

  /// Get current status of detailPane
  /// TODO: implement
  bool detailIsShown() {
    if (_isDesktop) {
      // We are on desktop view
      return true;
    }
    // we are in compact mode
    if (_compactShowDetail) return true;
    return false;
  }

  /// Returns current view (true == desktop view)
  bool isDesktop() => _isDesktop;

  /// Returns current view (true == compact view)

  bool isCompact() => !_isDesktop;

  /// Master pane is shown.
  void showOnlyMaster() {
    // TODO: programmaly choose pane
    if (!_isDesktop) {
      if (_compactShowDetail) {
        setState(() {
          _compactShowDetail = false;
        });
      }
    }
  }

  /// Detail pane is shown. showBackButton (=true) gives backbutton in menu.
  /// If you have your own back functionality use showOnlyMaster() to get back to Master pane.
  void showOnlyDetail({bool showBackButton}) {
    // TODO: backbutton to show
    if (!_isDesktop) {
      if (!_compactShowDetail) {
        setState(() {
          _compactShowDetail = true;
        });
      }
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
    if (event.runtimeType == RawKeyDownEvent &&
        event.logicalKey.keyLabel != '') {
      widget.menuList.forEach((menuList) {
        menuList.menuListItems.forEach((listItem) {
          if (listItem is MenuListItem) {
            if (listItem.shortcut != null &&
                event.isControlPressed == listItem.shortcut.ctrl &&
                event.isAltPressed == listItem.shortcut.alt &&
                event.isShiftPressed == listItem.shortcut.shift &&
                event.logicalKey == listItem.shortcut.key) {
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
  void initState() {
    _detailPaneWidth = widget.detailWidth;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScreenInherited(
      data: this,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // widget.controller.hideContextMenu();
          _calcPaneHeight(constraints.maxHeight);
          _handleBreakpoint(constraints);

          return RawKeyboardListener(
            focusNode: _focusNode,
            onKey: _handleKeyEvent,
            autofocus: true,
            child: _isDesktop
                ? desktopView(constraints)
                : compactView(constraints),
          );
        },
      ),
    );
  }

  Stack desktopView(BoxConstraints constraints) {
    return Stack(
      children: [
        Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_menuIsShown) menuBar(),
            Row(
              children: [
                masterPane(),
                if (widget.detailPane != null)
                  Row(
                    children: [
                      resizeBar(constraints),
                      detailPane(),
                    ],
                  ),
              ],
            ),
          ],
        ),
        Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            if (event.buttons == 2) {} // højre klik
            closeMenu();
          },
        ),
        if (_menuIsShown && _menuIsOpen) showMenuOpen(),

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
        if (_showShortcutOverlay && shortcutLabel != null) shortcutOverlay(),
      ],
    );
  }

  Stack compactView(BoxConstraints constraints) {
    return Stack(
      children: [
        Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_menuIsShown) menuBar(),
            Row(
              children: [
                if (!_compactShowDetail) masterPane(),
                if (_compactShowDetail && widget.detailPane != null)
                  SizedBox(
                      height: _paneHeight,
                      width: constraints.maxWidth,
                      child: detailPane()),
              ],
            ),
          ],
        ),
        Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            if (event.buttons == 2) {} // højre klik
            closeMenu();
          },
        ),
        if (_menuIsShown && _menuIsOpen) showMenuOpen(),

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
        if (_showShortcutOverlay && shortcutLabel != null) shortcutOverlay(),
      ],
    );
  }

  SizedBox menuBar() {
    return SizedBox(
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
                      child: SizedBox(
                          width: 2,
                          child: Container(color: Colors.blueGrey[100])),
                    ),
                  ],
                ),
              if (widget.menuList != null)
                Row(
                  children: buildMenuList(),
                ),
              if (widget.trailing != null)
                Expanded(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: widget.trailing)),
            ],
          )),
    );
  }

  Positioned showMenuOpen() {
    return Positioned(
      left: (116 * _activeIndex).toDouble(),
      top: 30,
      child: SizedBox(
          height: (30 * widget.menuList[_activeIndex].menuListItems.length)
              .toDouble(),
          width: widget.menuList[_activeIndex].width,
          child: Container(
            color: Colors.blueGrey[700],
            child: ListView(
              itemExtent: 30,
              children: buildItemList(),
            ),
          )),
    );
  }

  Align shortcutOverlay() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Text(
        shortcutLabel,
        style: TextStyle(color: Colors.blue, fontSize: 50),
      ),
    );
  }

  Expanded masterPane() {
    return Expanded(
        child: SizedBox(height: _paneHeight, child: widget.masterPane));
  }

  SizedBox detailPane() {
    return SizedBox(
      width: detailPaneWidth(),
      height: _paneHeight,
      child: widget.detailPane,
    );
  }

  MouseRegion resizeBar(BoxConstraints constraints) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onPanUpdate: (details) {
          setDetailPaneWidth(
              width: constraints.maxWidth - details.globalPosition.dx);
        },
        child: SizedBox(
          width: 5,
          height: _paneHeight,
          child: Container(
            // color: Colors.amber,
            decoration: BoxDecoration(
              // color: Colors.teal,
              gradient: LinearGradient(
                  colors: [Colors.teal, Colors.teal[200]],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildItemList() {
    List<Widget> buildItemList = [];

    for (int i = 0;
        i < widget.menuList[_activeIndex].menuListItems.length;
        i++) {
      var listItem = widget.menuList[_activeIndex].menuListItems[i];

      if (listItem is MenuListItem) {
        if (listItem.isActive) {
          buildItemList.add(
            FlatButton(
              hoverColor: Colors.black26,
              onPressed: listItem.onPressed != null
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
                        child: SizedBox(
                            width: 20,
                            child: Icon(listItem.icon,
                                size: 12, color: Colors.white))),
                  if (listItem.icon == null) SizedBox(width: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(listItem.title,
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
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
              _activeIndex = i;
              openMenu(); // Calls setState
            },
            child: SizedBox(
                width: 100,
                child: Center(
                    child: Text(widget.menuList[i].title,
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12)))),
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

class AppScreenInherited extends InheritedWidget {
  final AppScreenState data;

  AppScreenInherited({
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
