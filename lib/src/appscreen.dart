import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:flutter_menu/flutter_menu.dart';

import 'menu_model.dart';

extension BuildContextMenuFinder on BuildContext {
  AppScreenState get appScreen => AppScreen.of(this);
}

typedef MenuBuilderCallback = Widget Function();

/// Menu shows an menu, enables keyboard shortcuts to MenuItems and give master/detail panes
class AppScreen extends StatefulWidget {
  final List<MenuItem> menuList;
  final Builder masterPane;

  final Builder? detailPane;
  final double masterPaneFlex;
  final double detailPaneFlex;
  final double masterPaneMinWidth;
  final double detailPaneMinWidth;

  final bool masterPaneFixedWidth;
  final double desktopBreakpoint;
  final Function? onBreakpointChange;

  final ResizeBar? resizeBar;

  final AppDrawer drawer;

  final Builder? drawerPane;
  final Widget? leading;
  final Widget? trailing;

  final ContextMenu? masterContextMenu;
  final ContextMenu? detailContextMenu;

  final bool touchMode;
  final double touchMenuBarHeight;
  final double dekstopMenuBarHeight;

  const AppScreen({
    Key? key,

    /// Use this to update ui when desktop vs compact change happens
    required this.menuList,
    required this.masterPane,
    this.detailPane,
    this.masterPaneFlex = 1,
    this.detailPaneFlex = 1,
    this.masterPaneMinWidth = 500,
    this.detailPaneMinWidth = 500,
    this.masterPaneFixedWidth = false,
    this.desktopBreakpoint = 1100,
    this.onBreakpointChange,
    this.resizeBar,
    this.drawer = const AppDrawer(),
    this.drawerPane,
    this.leading,
    this.trailing,
    this.masterContextMenu,
    this.detailContextMenu,
    this.touchMode = false,
    this.touchMenuBarHeight = 40,
    this.dekstopMenuBarHeight = 30,
  })  : assert((masterPaneMinWidth + detailPaneMinWidth) <= desktopBreakpoint,
            "Master + Detail min Width has to be less than desktopbreakpoint !"),
        assert(dekstopMenuBarHeight >= 25, "Too small for UI to look good!"),
        assert(touchMenuBarHeight >= 40, "Too small for UI to look good!"),
        super(key: key);

  static AppScreenState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_AppScreenInherited>()!
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
  bool _touchMode = false;
  bool _showShortcutOverlay = true;
  double _lastScreenWidth = 0;
  double _lastScreenHeight = 0;

  late ResizeBar _resizeBar;

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

  late double _currentMenuHeight;

  Detail _masterPaneDetails = Detail();

  /// info about masterPane
  get masterPaneDetails => _masterPaneDetails;

  Detail _detailPaneDetails = Detail();

  /// info about detailPane
  get detailPaneDetails => _detailPaneDetails;

  Detail _screenDetails = Detail();

  /// info about detailPane
  get screenDetails => _screenDetails;

  late double _masterPaneWidth;

  bool _drawerOpen = false;
  bool _drawerEnabled = false;
  bool _smallDrawer = false;
  double _drawerWidth = 0;

  /// Drawer will be set to large. If shown UI will update
  void setLargeDrawer() {
    if (_drawerEnabled && widget.drawer.largeDrawer != null) {
      _setLargeDrawer();

      if (_drawerOpen) {
        setState(() {});
      }
    }
  }

  void _setLargeDrawer() {
    _smallDrawer = false;
    _drawerWidth = widget.drawer.largeDrawerWidth;
  }

  /// Drawer will be set to small. If shown UI will update
  void setSmallDrawer() {
    if (_drawerEnabled && widget.drawer.smallDrawer != null) {
      _setSmallDrawer();
      if (_drawerOpen) {
        setState(() {});
      }
    }
  }

  void _setSmallDrawer() {
    _smallDrawer = true;
    _drawerWidth = widget.drawer.smallDrawerWidth;
  }

  /// Drawer will be closed
  void closeDrawer() {
    if (_drawerEnabled) {
      if (_drawerOpen) {
        setState(() {
          _drawerOpen = false;
        });
      }
    }
  }

  /// Drawer will be opened
  void openDrawer() {
    if (_drawerEnabled) {
      if (!_drawerOpen) {
        setState(() {
          _drawerOpen = true;
        });
      }
    }
  }

  void _setupDrawer() {
    _drawerOpen = false;
    _drawerEnabled = false;
    _smallDrawer = widget.drawer.defaultSmall;
    _drawerWidth = 0;

    if (widget.drawer.smallDrawer != null && _smallDrawer == true) {
      _setSmallDrawer();
      _drawerEnabled = true;
    } else if (widget.drawer.largeDrawer != null && _smallDrawer == false) {
      _setLargeDrawer();
      _drawerEnabled = true;
    }
    if (_isDesktop && widget.drawer.showOnDesktop) _drawerOpen = true;
  }

  /// returns null if no drawer is to be shown
  Widget? _getActiveDrawer() {
    if (!_drawerOpen) return null;
    if (!_drawerEnabled) return null;

    if (_smallDrawer) return widget.drawer.smallDrawer; // can be null
    return widget.drawer.largeDrawer; // can be null;
  }

  void _calcScreenAndPaneSize(BoxConstraints constraints) {
    // Calc screen sized
    _screenDetails.height = constraints.maxHeight;
    _screenDetails.width = constraints.maxWidth;
    _screenDetails.minDx = 0;
    _screenDetails.maxDx = constraints.maxWidth;
    _screenDetails.minDy = 0;
    _screenDetails.maxDy = constraints.maxHeight;

    // calc the pane height info
    _detailPaneDetails.maxDy = constraints.maxHeight;
    _masterPaneDetails.maxDy = constraints.maxHeight;

    // is menu shown it has to be withdrawen from pane height
    _detailPaneDetails.minDy = _menuIsShown ? _currentMenuHeight : 0;
    _masterPaneDetails.minDy = _menuIsShown ? _currentMenuHeight : 0;

    _detailPaneDetails.height =
        _detailPaneDetails.maxDy - _detailPaneDetails.minDy;
    _masterPaneDetails.height =
        _masterPaneDetails.maxDy - _masterPaneDetails.minDy;

    if (_isDesktop) // we have both on screen
    {
      // we have desktop view with master AND detail
      // remember the slider width if shown
      _masterPaneDetails.minDx = _drawerOpen ? _drawerWidth : 0;
      _masterPaneDetails.maxDx = _masterPaneDetails.minDx + _masterPaneWidth;
      _detailPaneDetails.minDx = _masterPaneDetails.maxDx + _resizeBar.width;
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
      _calcPaneFlexWidth(screenWidth: constraints.maxWidth);
      _showContext = false;
      _lastScreenHeight = constraints.maxHeight;
      _lastScreenWidth = constraints.maxWidth;
    }
  }

  /// will only be called if widget.onBreakPointChange is not null
  Future _onBreakPointChange() async {
    // Move to next tick to prevent call under build
    Future.delayed(Duration.zero, () async {
      widget.onBreakpointChange!();
    });
  }

  late double _maxMasterPaneWidth; // Used to keep resizebar within boundaries

  void _calcPaneFlexWidth({required double screenWidth}) {
    double _availableWidth = screenWidth - (_drawerOpen ? _drawerWidth : 0);
    double screenFlex = widget.masterPaneFlex + widget.detailPaneFlex;
    _masterPaneWidth = _availableWidth / screenFlex * widget.masterPaneFlex;
    // TODO: CHECK THIS CALCULATION IF WIDTH IS CHANGED:
    _maxMasterPaneWidth =
        _availableWidth - widget.detailPaneMinWidth - _resizeBar.width;
    if (_masterPaneWidth < widget.masterPaneMinWidth)
      _masterPaneWidth = widget.masterPaneMinWidth;
    else if (_masterPaneWidth > _maxMasterPaneWidth)
      _masterPaneWidth = _maxMasterPaneWidth;
  }

  void _setMasterPaneWidthOnPan(
      {required double panDx, required BoxConstraints constraints}) {
    double _newMasterPaneWidth = panDx - (_drawerOpen ? _drawerWidth : 0);
    if (_maxMasterPaneWidth < widget.masterPaneMinWidth)
      _maxMasterPaneWidth = widget.masterPaneMinWidth;
    _calcPaneFlexWidth(screenWidth: constraints.maxWidth);

    if (_masterPaneWidth > widget.masterPaneMinWidth) {
      if (_newMasterPaneWidth < widget.masterPaneMinWidth)
        _masterPaneWidth = widget.masterPaneMinWidth;
      else if (_newMasterPaneWidth > _maxMasterPaneWidth)
        _masterPaneWidth = _maxMasterPaneWidth;
      else
        _masterPaneWidth = _newMasterPaneWidth;
      setState(() {});
    }
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
  void showOnlyDetail({bool showBackButton = true}) {
    if (!_isDesktop) {
      if (!_compactShowDetail) {
        setState(() {
          _compactShowDetail = true;
        });
      }
    }
  }

  bool _showContext = false;
  bool _contextAnimation = false;
  Widget? _currentContextMenu;
  late double _currentContextDx;
  late double _currentContextDy;
  late double _currentContextWidth;
  late double _currentContextHeight;

  /// Setup ContextMenu to be shown on build
  void _setupContextMenu(
      {required Widget menu,
      required double menuWidth,
      required double menuHeight,
      required Offset offset,
      required Detail constraints,
      required bool centerContextMenu}) {
    _contextAnimation = centerContextMenu; // If longpress we animate
    _calcContextMenuPosition(
        positionDx: offset.dx,
        positionDy: offset.dy,
        contextMenuSize: Size(menuWidth, menuHeight),
        currentConstraints: constraints,
        centerContextMenu: centerContextMenu);
    _currentContextWidth = menuWidth;
    _currentContextHeight = menuHeight;

    _currentContextMenu = menu;
    setState(() {
      _showContext = true;
    });
  }

  /// Show ContextMenu
  void showContextMenu(
      {required Offset offset,
      required Widget menu,
      required double width,
      required double height,
      required bool center}) {
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
      menuHeight: height,
      centerContextMenu: center,
    );
  }

  /// Show ContextMenu for MasterPane or DetailPane
  void _showMasterOrDetailPaneContextMenu(
      {required Offset offset, required bool center}) {
    if (_isDesktop) {
      // desktop mode
      if (offset.dx >= detailPaneDetails.minDx &&
          widget.detailContextMenu != null) {
        _setupContextMenu(
          menu: widget.detailContextMenu!.child,
          menuWidth: widget.detailContextMenu!.width,
          menuHeight: widget.detailContextMenu!.height,
          offset: offset,
          constraints: detailPaneDetails,
          centerContextMenu: center,
        );
      } else if (widget.masterContextMenu != null) {
        _setupContextMenu(
          menu: widget.masterContextMenu!.child,
          menuWidth: widget.masterContextMenu!.width,
          menuHeight: widget.masterContextMenu!.height,
          offset: offset,
          constraints: masterPaneDetails,
          centerContextMenu: center,
        );
      }
    } else {
      // Compact mode
      if (_compactShowDetail && widget.detailContextMenu != null) {
        _setupContextMenu(
          menu: widget.detailContextMenu!.child,
          menuWidth: widget.detailContextMenu!.width,
          menuHeight: widget.detailContextMenu!.height,
          offset: offset,
          constraints: detailPaneDetails,
          centerContextMenu: center,
        );
      } else if (widget.masterContextMenu != null) {
        _setupContextMenu(
          menu: widget.masterContextMenu!.child,
          menuWidth: widget.masterContextMenu!.width,
          menuHeight: widget.masterContextMenu!.height,
          offset: offset,
          constraints: masterPaneDetails,
          centerContextMenu: center,
        );
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
      {required double positionDx,
      required double positionDy,
      required Detail currentConstraints,
      Size contextMenuSize = const Size(150, 200),
      bool centerContextMenu = true}) {
    _currentContextDx = positionDx;
    _currentContextDy = positionDy;

    if (centerContextMenu) {
      // adjust position to center
      _currentContextDx = positionDx - (contextMenuSize.width / 2);
      _currentContextDy = positionDy - (contextMenuSize.height / 2);
    }

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
  String? _shortcutLabel;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Show ShortCut overlay with 2 seconds timer
  void showShortCutOverlay({required String message}) {
    Timer(Duration(seconds: 2), () {
      // remove the label after 2 seconds
      setState(() {
        _shortcutLabel = '';
      });
    });
    setState(() {
      _shortcutLabel = message;
    });
  }

  void _handleKeyEvent(RawKeyEvent event) {
    // only check on key down and only tjek if real key is involved to reduce payload
    if (event.runtimeType == RawKeyDownEvent &&
        event.logicalKey.keyLabel != '') {
      widget.menuList.forEach((menuList) {
        menuList.menuListItems.forEach((listItem) {
          if (listItem is MenuListItem) {
            if (listItem.shortcut != null &&
                event.isControlPressed == listItem.shortcut!.ctrl &&
                event.isAltPressed == listItem.shortcut!.alt &&
                event.isShiftPressed == listItem.shortcut!.shift &&
                event.logicalKey == listItem.shortcut!.key) {
              if (_showShortcutOverlay) {
                showShortCutOverlay(message: _shortcutText(listItem.shortcut!));
              }
              if (listItem.onPressed != null) {
                closeMenu();
                listItem.onPressed!();
              }
            }
          }
        });
      });
    }
  }

  void _setResizeBarColor() {
    _resizeBar.decoration = BoxDecoration(
      gradient: LinearGradient(
          colors: [_resizeBar.leftColor!, _resizeBar.rightColor!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight),
    );
    _resizeBar.helperDecoration = BoxDecoration(
      gradient: LinearGradient(
          colors: [_resizeBar.rightColor!, _resizeBar.leftColor!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight),
    );
  }

  void _setupResizeBar() {
    _resizeBar = widget.resizeBar ?? kDefaultResizeBar;
    if (_resizeBar.leftColor != null && _resizeBar.rightColor != null) {
      _setResizeBarColor();
    }
  }

  /// Returns true if touch mode is active
  bool isTouchMode() {
    return _touchMode;
  }

  /// Returns true if desktop mode is active
  bool isDesktopMode() {
    return !_touchMode;
  }

  void _setTouchMode() {
    _touchMode = true;
    _currentMenuHeight = widget.touchMenuBarHeight;
  }

  /// activate touch mode
  void setTouchMode() {
    setState(() {
      _setTouchMode();
    });
  }

  void _setDesktopMode() {
    _touchMode = false;
    _currentMenuHeight = widget.dekstopMenuBarHeight;
  }

  /// activate desktop mode
  void setDesktopMode() {
    setState(() {
      _setDesktopMode();
    });
  }

  void _setupMenu() {
    if (widget.touchMode) {
      _setTouchMode();
    } else {
      _setDesktopMode();
    }
  }

  @override
  void initState() {
    _setupResizeBar();
    _setupDrawer();
    _setupMenu();
    if (widget.masterContextMenu != null)
      _currentContextMenu = widget.masterContextMenu!.child;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _AppScreenInherited(
      data: this,
      child: LayoutBuilder(
        builder: (context, constraints) {
          //  _setupResizeBar(); // TODO: Why called two times (also on initState)
          _handleConstraintChange(constraints);

          // This function handles change in _isDesktop, and has to be called before _calcScreenAndPaneSize
          _handleBreakpoint(constraints);

          _calcScreenAndPaneSize(constraints);

          return GestureDetector(
            onLongPressStart: (details) {
              _showMasterOrDetailPaneContextMenu(
                  offset: details.globalPosition, center: true);
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
            if (_menuIsShown && !_touchMode) _desktopMenuBar(),
            if (_menuIsShown && _touchMode) _menuTouchBar(),
            Row(
              children: [
                if (_drawerOpen && _drawerEnabled) _buildDrawer(),
                _masterPane(),
                if (widget.detailPane != null)
                  Row(
                    children: [
                      _buildResizeBar(constraints),
                      _detailPane(),
                    ],
                  ),
              ],
            ),
          ],
        ),
        if (widget.detailPane != null && _touchMode == true)
          _resizeBarIcon(constraints),
        _listenForAppClick(),
        if (_menuIsShown && _menuIsOpen) _buildMenuOpen(),
        if (_drawerEnabled &&
            !_drawerOpen &&
            widget.drawer.edgeDragOpenWidth > 0)
          _edgeDragOpen(),
        if (_showContext && _currentContextMenu != null) _showContextMenu(),
        if (_showShortcutOverlay && _shortcutLabel != null) _shortcutOverlay(),
      ],
    );
  }

  Stack _compactView(BoxConstraints constraints) {
    return Stack(
      children: [
        Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_menuIsShown && !_touchMode) _desktopMenuBar(),
            if (_menuIsShown && _touchMode) _menuTouchBar(),
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
        if (_menuIsShown && _menuIsOpen) _buildMenuOpen(),
        if (_showContext && _currentContextMenu != null) _showContextMenu(),
        if (_showShortcutOverlay && _shortcutLabel != null) _shortcutOverlay(),
        if (_drawerOpen && _drawerEnabled) _buildOverlayDrawer(),
      ],
    );
  }

  Widget _edgeDragOpen() {
    return Positioned(
      top: _masterPaneDetails.minDy,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          _onDrawerDrag(delta: details.delta.dx);
        },
        onHorizontalDragEnd: (_) {
          _onDrawerDragEnd();
        },
        child: SizedBox(
            width: widget.drawer.edgeDragOpenWidth,
            height: _masterPaneDetails.height,
            child: Container(color: Colors.transparent)),
      ),
    );
  }

  double? _drawerDragDelta;

  _onDrawerDrag({required double delta}) {
    _drawerDragDelta = delta;
  }

  _onDrawerDragEnd() {
    if (_drawerDragDelta != null && _drawerOpen) {
      if (_smallDrawer) {
        if (_drawerDragDelta! < 0)
          closeDrawer();
        else
          setLargeDrawer();
      } else {
        if (_drawerDragDelta! > 0) //
        {
          // Do nothing - drawer cannot be bigger
        } else
          setSmallDrawer();
      }
    } else {
      openDrawer();
    }
    _drawerDragDelta = null;
  }

  Widget _buildOverlayDrawer() {
    return Positioned(
      top: _masterPaneDetails.minDy,
      child: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return GestureDetector(
      onLongPressStart: (details) {
        // Do nothing if user accidentially longpresses (do not open contextmenu)
      },
      onHorizontalDragUpdate: (details) {
        _onDrawerDrag(delta: details.delta.dx);
      },
      onHorizontalDragEnd: (_) {
        _onDrawerDragEnd();
      },
      child: Container(
        width: _drawerWidth,
        height: _masterPaneDetails.height,
        child: _getActiveDrawer(),
      ),
    );
  }

  Positioned _resizeBarIcon(BoxConstraints constraints) {
    return Positioned(
        left: _detailPaneDetails.minDx -
            _resizeBar.helperSize / 2 -
            _resizeBar.width / 2,
        top: _detailPaneDetails.maxDy - _resizeBar.helperPos,
        child: GestureDetector(
          onLongPressStart: (details) {
            // Do nothing if user accidentially longpresses (do not open contextmenu)
          },
          onPanUpdate: (details) {
            if (!widget.masterPaneFixedWidth)
              _setMasterPaneWidthOnPan(
                  panDx: details.globalPosition.dx, constraints: constraints);
          },
          child: SizedBox(
            width: _resizeBar.helperSize,
            height: _resizeBar.helperSize,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_resizeBar.helperSize),
              child: Container(decoration: _resizeBar.helperDecoration),
            ),
          ),
        )
        // Icon(_resizeBar.icon,
        //     size: _resizeBar.iconSize, color: _resizeBar.iconColor)),
        );
  }

  Listener _listenForAppClick() {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        if (event.buttons == 2) {
          // right click
          _showMasterOrDetailPaneContextMenu(
              offset: event.position, center: false);
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
        builder: (BuildContext context, dynamic value, Widget? child) {
          return Transform.scale(
            scale: value,
            alignment: Alignment.center,
            child: child,
          );
        },
        tween: Tween(begin: _contextAnimation ? 0.0 : 1.0, end: 1.0),
        child: GestureDetector(
          onLongPressStart: (details) {
            // Do not open contextmenu inside contextmenu
          },
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
      ),
    );
  }

  Widget _desktopMenuBar() {
    return GestureDetector(
      onLongPress: () {
        // Do nothing if user accidentially presses longpress in the menu
      },
      child: SizedBox(
        height: _currentMenuHeight,
        width: double.infinity,
        child: Container(
            color: Colors.blueGrey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_drawerEnabled) _drawerButton(),
                if (widget.leading != null)
                  Row(
                    children: [
                      widget.leading!,
                      Padding(
                        padding: const EdgeInsets.only(left: 4, right: 4),
                        child: SizedBox(
                            width: 2,
                            child: Container(color: Colors.blueGrey[100])),
                      ),
                    ],
                  ),
                Row(
                  children: _buildMenuList(),
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: _touchButton())),
              ],
            )),
      ),
    );
  }

  Widget _menuTouchBar() {
    return GestureDetector(
      onLongPress: () {
        // Do nothing if user accidentially presses longpress in the menu
      },
      child: SizedBox(
        height: _currentMenuHeight,
        width: double.infinity,
        child: Container(
            color: Colors.blueGrey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_drawerEnabled) _drawerButton(),
                if (widget.leading != null)
                  Row(
                    children: [
                      widget.leading!,
                      Padding(
                        padding: const EdgeInsets.only(left: 4, right: 4),
                        child: SizedBox(
                            width: 2,
                            child: Container(color: Colors.blueGrey[100])),
                      ),
                    ],
                  ),
                Row(
                  children: _buildMenuList(),
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: _touchButton())),
              ],
            )),
      ),
    );
  }

  Widget _touchButton() {
    return TextButton(
      onPressed: () {
        if (_touchMode)
          setDesktopMode();
        else
          setTouchMode();
      },
      child: SizedBox(
        width: 25,
        child: Center(
          child: Icon(Icons.devices, color: Colors.white70),
        ),
      ),
    );
  }

  double _getDrawerMenuBarSize() {
    return widget.drawer.largeDrawerWidth < 80
        ? widget.drawer.largeDrawerWidth
        : 80;
  }

  Widget _drawerButton() {
    return SizedBox(
      width: _getDrawerMenuBarSize(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 70,
            child: TextButton(
              onPressed: () {
                if (!_drawerOpen) {
                  setSmallDrawer();
                  openDrawer();
                } else {
                  if (_smallDrawer)
                    setLargeDrawer();
                  else {
                    closeDrawer();
                  }
                }
              },
              child: Center(
                child: Icon(Icons.menu,
                    color: Colors.white70, size: _drawerWidth < 40 ? 16 : 18),
              ),
            ),
          ),
          SizedBox(width: 2, child: Container(color: Colors.white70))
        ],
      ),
    );
  }

  Positioned _buildMenuOpen() {
    return Positioned(
      left: _getDrawerMenuBarSize() + (116 * _activeIndex).toDouble(),
      top: _currentMenuHeight,
      child: GestureDetector(
        onLongPress: () {
          // Do nothing if user accidentially presses longpress in the menu
        },
        child: SizedBox(
            height: (_currentMenuHeight *
                    widget.menuList[_activeIndex].menuListItems.length)
                .toDouble(),
            width: widget.menuList[_activeIndex].width,
            child: Container(
              color: Colors.blueGrey[700],
              child: ListView(
                itemExtent: _currentMenuHeight,
                children: _buildItemList(),
              ),
            )),
      ),
    );
  }

  Align _shortcutOverlay() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Text(
        _shortcutLabel!,
        style: TextStyle(color: Colors.blue, fontSize: 50),
      ),
    );
  }

  Widget _masterPane() {
    return SizedBox(
        height: _masterPaneDetails.height,
        width: _masterPaneDetails.width,
        child: widget.masterPane);
  }

  Widget _detailPane() {
    return SizedBox(
      width: _detailPaneDetails.width,
      height: _detailPaneDetails.height,
      child: widget.detailPane,
    );
  }

  MouseRegion _buildResizeBar(BoxConstraints constraints) {
    return MouseRegion(
      cursor: !widget.masterPaneFixedWidth
          ? SystemMouseCursors.resizeColumn
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onLongPressStart: (details) {
          // Do nothing if user accidentially longpresses (do not open contextmenu)
        },
        onPanUpdate: (details) {
          if (!widget.masterPaneFixedWidth)
            _setMasterPaneWidthOnPan(
                panDx: details.globalPosition.dx, constraints: constraints);
        },
        child: SizedBox(
          width: _resizeBar.width,
          height: _masterPaneDetails.height,
          child: Container(
            // color: Colors.amber,
            decoration: _resizeBar.decoration,
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
            TextButton(
              onPressed: listItem.onPressed != null
                  ? () {
                      closeMenu();
                      listItem.onPressed!();
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
                                size: _touchMode ? 16 : 12,
                                color: Colors.white))),
                  if (listItem.icon == null) SizedBox(width: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(listItem.title,
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: _touchMode ? 16 : 12)),
                  ),
                  if (listItem.shortcut != null)
                    Expanded(
                      // child:
                      // Align(
                      // alignment: Alignment.centerRight,
                      child: Text(
                        _shortcutText(listItem.shortcut!),
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
          child: TextButton(
            onPressed: () {
              _activeIndex = i;
              openMenu(); // Calls setState
            },
            child: SizedBox(
                width: 100,
                child: Center(
                    child: Text(widget.menuList[i].title,
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: _touchMode ? 16 : 12)))),
          ),
        ));
    }
    return buildList;
  }
}

class _AppScreenInherited extends InheritedWidget {
  final AppScreenState data;

  _AppScreenInherited({
    Key? key,
    required Widget child,
    required this.data,
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
  if (shortcut.key == null) return "";
  return (shortcut.ctrl ? _labelCtrl : '') +
      (shortcut.alt ? _labelAlt : '') +
      (shortcut.shift ? _labelShift : '') +
      shortcut.key!.keyLabel;
}
