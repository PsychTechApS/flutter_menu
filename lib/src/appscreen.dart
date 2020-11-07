import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_menu/flutter_menu.dart';

import 'menu_model.dart';

// Upcomming:
// ContextPlacementCenter (enum: longPressOnly, never, always)
// ContextPlacementKeepInPane (bool)
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

  final ContextMenu masterContextMenu;
  final ContextMenu detailContextMenu;

  const AppScreen({
    Key key,
    this.menuList,
    this.masterPane,
    this.detailPane,
    this.masterContextMenu,
    this.detailContextMenu,
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
        .dependOnInheritedWidgetOfExactType<_AppScreenInherited>()
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
  double _lastScreenWidth = 0;
  double _lastScreenHeight = 0;

  /// True = Menu is Shown
  bool get isMenuShown => _menuIsShown;

  /// True = MenuList is open (the active MenuItem has it MenuList shown)
  bool get isMenuOpen => _menuIsOpen;

  /// Turn on shortcut overlay (activated shortcut is shown on screen)
  void showShortcutOverlay() => _showShortcutOverlay = true;

  /// Turn off shortcut overlay (activated shortcut is shown on screen)
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

  Detail _masterPaneDetails = Detail();

  /// info about masterPane
  get masterPaneDetails => _masterPaneDetails;

  Detail _detailPaneDetails = Detail();

  /// info about detailPane
  get detailPaneDetails => _detailPaneDetails;

  Detail _screenDetails = Detail();

  /// info about detailPane
  get screenDetails => _screenDetails;

  double _detailPaneWidth;

  bool _drawerIsShown = false; // TODO: implement drawer
  double _drawerWidth = 0; // TODO: implement drawer
  double kResizeBarWidth = 5; // TODO: global or parameter

  void _calcScreenAndPaneSize(BoxConstraints constraints) {
    // Calc screen sized
    _screenDetails.height = constraints.maxHeight;
    _screenDetails.width = constraints.maxWidth;
    _screenDetails.minDx = 0;
    _screenDetails.maxDx = constraints.maxWidth;
    _screenDetails.minDy = 0;
    _screenDetails.minDx = constraints.minWidth;

    // calc the pane height info
    _detailPaneDetails.maxDy = constraints.maxHeight;
    _masterPaneDetails.maxDy = constraints.maxHeight;

    // is menu shown it has to be withdrawen from pane height
    _detailPaneDetails.minDy = _menuIsShown ? kMenuHeight : 0;
    _masterPaneDetails.minDy = _menuIsShown ? kMenuHeight : 0;

    _detailPaneDetails.height =
        _detailPaneDetails.maxDy - _detailPaneDetails.minDy;
    _masterPaneDetails.height =
        _masterPaneDetails.maxDy - _masterPaneDetails.minDy;

    if (_isDesktop) // we have both on screen
    {
      // we have desktop view with master AND detail
      // remember the slider width if shown
      _masterPaneDetails.minDx = _drawerIsShown ? _drawerWidth : 0;
      _masterPaneDetails.maxDx =
          constraints.maxWidth - _detailPaneWidth - kResizeBarWidth;
      _detailPaneDetails.minDx = _masterPaneDetails.maxDx + kResizeBarWidth;
      _detailPaneDetails.maxDx = constraints.maxWidth;
    } else {
      // we are in compact mode (only master or detail)
      _detailPaneDetails.minDx = 0;
      _detailPaneDetails.maxDx = constraints.maxWidth;
      _masterPaneDetails.minDx = 0;
      _masterPaneDetails.maxDx = constraints.maxWidth;
    }
    // can be calculated from current information
    _detailPaneDetails.width =
        _detailPaneDetails.maxDx - _detailPaneDetails.minDx;
    _masterPaneDetails.width =
        _masterPaneDetails.maxDx - _masterPaneDetails.minDx;
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

  void _handleConstraintChange(BoxConstraints constraints) {
    if (constraints.maxHeight != _lastScreenHeight ||
        constraints.maxWidth != _lastScreenWidth) {
      _showContext = false;
      _lastScreenHeight = constraints.maxHeight;
      _lastScreenWidth = constraints.maxWidth;
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
    if (!_isDesktop) {
      if (!_compactShowDetail) {
        setState(() {
          _compactShowDetail = true;
        });
      }
    }
  }

  bool _showContext = false;
  Widget _currentContextMenu;
  double _currentContextDx;
  double _currentContextDy;
  double _currentContextWidth;
  double _currentContextHeight;

  /// Setup ContextMenu to be shown on build
  void _setupContextMenu(
      {@required Widget menu,
      @required double menuWidth,
      @required double menuHeight,
      @required Offset offset,
      @required Detail constraints}) {
    if (menu != null) {
      _calcContextMenuPosition(
          positionDx: offset.dx,
          positionDy: offset.dy,
          contextMenuSize: Size(menuWidth, menuHeight),
          currentConstraints: constraints);
      _currentContextWidth = menuWidth;
      _currentContextHeight = menuHeight;

      _currentContextMenu = menu;
      setState(() {
        _showContext = true;
      });
    } else
      setState(() {
        _showContext = false;
      });
  }

  void showContextMenu(
      {@required Offset offset,
      @required Widget menu,
      @required double width,
      @required double height}) {
    Detail currentConstraints;
    if (_isDesktop) {
      // desktop mode
      if (offset.dx >= detailPaneDetails.minDx)
        currentConstraints = detailPaneDetails;
      else
        currentConstraints = masterPaneDetails;
    } else {
      // Compact mode
      if (_compactShowDetail)
        currentConstraints = detailPaneDetails;
      else
        currentConstraints = masterPaneDetails;
    }
    _setupContextMenu(
        menu: menu,
        offset: offset,
        constraints: currentConstraints,
        menuWidth: width,
        menuHeight: height);
  }

  /// Show ContextMenu for MasterPane or DetailPane
  void _showMasterOrDetailPaneContextMenu({@required Offset offset}) {
    if (_isDesktop) {
      // desktop mode
      if (offset.dx >= detailPaneDetails.minDx) {
        _setupContextMenu(
            menu: widget.detailContextMenu.child,
            menuWidth: widget.detailContextMenu.width,
            menuHeight: widget.detailContextMenu.height,
            offset: offset,
            constraints: detailPaneDetails);
      } else {
        _setupContextMenu(
            menu: widget.masterContextMenu.child,
            menuWidth: widget.masterContextMenu.width,
            menuHeight: widget.masterContextMenu.height,
            offset: offset,
            constraints: masterPaneDetails);
      }
    } else {
      // Compact mode
      if (_compactShowDetail) {
        _setupContextMenu(
            menu: widget.detailContextMenu.child,
            menuWidth: widget.detailContextMenu.width,
            menuHeight: widget.detailContextMenu.height,
            offset: offset,
            constraints: detailPaneDetails);
      } else {
        _setupContextMenu(
            menu: widget.masterContextMenu.child,
            menuWidth: widget.masterContextMenu.width,
            menuHeight: widget.masterContextMenu.height,
            offset: offset,
            constraints: masterPaneDetails);
      }
    }
  }

  /// Hide ContextMenu
  void hideContextMenu() {
    setState(() {
      _showContext = false;
    });
  }

  /// dx,dy = rightclick or longpress position
  /// currentConstraints
  void _calcContextMenuPosition(
      {@required double positionDx,
      @required double positionDy,
      Detail currentConstraints,
      Size contextMenuSize = const Size(150, 200),
      bool centerContextMenu = true}) {
    currentConstraints = currentConstraints ?? _detailPaneDetails;
    // prerequists
    // print('Currentconstraints: $currentConstraints');

    _currentContextDx = positionDx;
    _currentContextDy = positionDy;
    // print('START DX: $_dxContext, DY: $_dyContext');

    if (centerContextMenu) {
      // adjust position to center
      _currentContextDx = positionDx - (contextMenuSize.width / 2);
      _currentContextDy = positionDy - (contextMenuSize.height / 2);
    }
    // print('Center DX: $_dxContext, DY: $_dyContext');
    // check if inside boundaries
    // I need current boundaries...

    // get MaxOffset for the contextmenu to bee inside Pane
    double contextMenuMaxDx =
        currentConstraints.maxDx - contextMenuSize.width - 10;
    double contextMenuMaxDy =
        currentConstraints.maxDy - contextMenuSize.height - 10;
    // print('Max DX: $contextMenuMaxDx, DY: $contextMenuMaxDy');

    // Choose the safe offset for contextmenu to be shown
    if (contextMenuMaxDx < _currentContextDx)
      _currentContextDx = contextMenuMaxDx;
    if (contextMenuMaxDy < _currentContextDy)
      _currentContextDy = contextMenuMaxDy;
    if (currentConstraints.minDx > _currentContextDx)
      _currentContextDx = currentConstraints.minDx;
    if (currentConstraints.minDy > _currentContextDy)
      _currentContextDy = currentConstraints.minDy;
    // what if ContextMenu bigger than current boundaries?
    if (contextMenuMaxDx < 0) _showContext = false;
    if (contextMenuMaxDy < 0) _showContext = false;
    // print('Chosen DX: $_dxContext, DY: $_dyContext, Show: $_showContext');
  }

  final FocusNode _focusNode = FocusNode();
  String shortcutLabel;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    // only check on key down and only tjek if real key is involved to reduce payload
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
                  shortcutLabel = _shortcutText(listItem.shortcut);
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
    if (widget.masterContextMenu != null)
      _currentContextMenu = widget.masterContextMenu.child;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _AppScreenInherited(
      data: this,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _handleConstraintChange(constraints);
          _calcScreenAndPaneSize(constraints);

          _handleBreakpoint(constraints);

          return GestureDetector(
            onLongPressStart: (details) {
              print('Longpres Start: ${details.globalPosition}');
            },
            child: RawKeyboardListener(
              focusNode: _focusNode,
              onKey: _handleKeyEvent,
              autofocus: true,
              child: _isDesktop
                  ? desktopView(constraints)
                  : _compactView(constraints),
            ),
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
            if (_menuIsShown) _menuBar(),
            Row(
              children: [
                _masterPane(),
                if (widget.detailPane != null)
                  Row(
                    children: [
                      _resizeBar(constraints),
                      _detailPane(),
                    ],
                  ),
              ],
            ),
          ],
        ),
        _listenForAppClick(),
        if (_menuIsShown && _menuIsOpen) _showMenuOpen(),
        if (_showContext && _currentContextMenu != null) _showContextMenu(),
        if (_showShortcutOverlay && shortcutLabel != null) _shortcutOverlay(),
      ],
    );
  }

  Listener _listenForAppClick() {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        if (event.buttons == 2) {
          // right click
          _showMasterOrDetailPaneContextMenu(offset: event.position);
        }
        if (event.buttons == 1) {
          // left click
          hideContextMenu();
          closeMenu();
        }
      },
    );
  }

  Positioned _showContextMenu() {
    return Positioned(
      left: _currentContextDx,
      top: _currentContextDy,
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 200),
        builder: (BuildContext context, value, Widget child) {
          return Transform.scale(
            scale: value,
            alignment: Alignment.center,
            child: child,
          );
        },
        tween: Tween(begin: 0.0, end: 1.0),
        child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerSignal: (event) {},
            onPointerDown: (event) {
              if (event.buttons == 2) // højre klik
              {
                hideContextMenu();
              }
            },
            child: SizedBox(
                height: _currentContextHeight,
                width: _currentContextWidth,
                child: _currentContextMenu)),
      ),
    );
  }

  Stack _compactView(BoxConstraints constraints) {
    return Stack(
      children: [
        Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_menuIsShown) _menuBar(),
            Row(
              children: [
                if (!_compactShowDetail) _masterPane(),
                if (_compactShowDetail && widget.detailPane != null)
                  SizedBox(
                      height: _detailPaneDetails.height,
                      width: constraints.maxWidth,
                      child: _detailPane()),
              ],
            ),
          ],
        ),
        _listenForAppClick(),
        if (_menuIsShown && _menuIsOpen) _showMenuOpen(),
        if (_showContext && _currentContextMenu != null) _showContextMenu(),
        if (_showShortcutOverlay && shortcutLabel != null) _shortcutOverlay(),
      ],
    );
  }

  SizedBox _menuBar() {
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
                  children: _buildMenuList(),
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

  Positioned _showMenuOpen() {
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
              children: _buildItemList(),
            ),
          )),
    );
  }

  Align _shortcutOverlay() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Text(
        shortcutLabel,
        style: TextStyle(color: Colors.blue, fontSize: 50),
      ),
    );
  }

  Widget _masterPane() {
    return Expanded(
        child: SizedBox(
            height: _masterPaneDetails.height, child: widget.masterPane));
  }

  Widget _detailPane() {
    return SizedBox(
      width: _detailPaneDetails.width,
      height: _detailPaneDetails.height,
      child: widget.detailPane,
    );
  }

  MouseRegion _resizeBar(BoxConstraints constraints) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onPanUpdate: (details) {
          setDetailPaneWidth(
              width: constraints.maxWidth - details.globalPosition.dx);
        },
        child: SizedBox(
          width: kResizeBarWidth,
          height: _masterPaneDetails.height,
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

  List<Widget> _buildItemList() {
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
                        _shortcutText(listItem.shortcut),
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

  List<Widget> _buildMenuList() {
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
    return buildList;
  }
}

class _AppScreenInherited extends InheritedWidget {
  final AppScreenState data;

  _AppScreenInherited({
    Key key,
    @required Widget child,
    @required this.data,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

const String _labelCtrl = 'Ctrl+';
const String _labelAlt = ' Alt+';
const String _labelShift = 'Shift+';

String _shortcutText(MenuShortcut shortcut) {
  // String text = '';
  return (shortcut.ctrl ? _labelCtrl : '') +
      (shortcut.alt ? _labelAlt : '') +
      (shortcut.shift ? _labelShift : '') +
      shortcut.key.keyLabel;
}
