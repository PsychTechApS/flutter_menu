## [0.2.2] - 2020-11-09

- FEATURE: New ResizeBar() to customize the look of the resizeBar. Touch screens can now use the circular helper to move it around
           use leftColor and RightColor to get at default BoxDecoration or customize with decoration and helperDecoration.
- FEATURE: First version of touch mode. Get a larger menu for easy touch screen use.

## [0.2.1] - 2020-11-09

- BREAKING: Pane sizing has changed: You specifiy flex for Master and Detail and minimum sizes for Master and Detail. desktopBreakpoint has to be equal to or larger than min sizes for Master + Detail.
- FEATURE: Longpress opens a centered and animated contextmenu (right click topleft positioned and no animation)

## [0.1.2] - 2020-11-07

- Animation added to context menu
- Context menu stay inside boundaries of Master or Detail pane
- BREAKING: masterContextMenu and detailContextMenu of new type ContextMenu
- BREAKING: ContextMenu (for custom widget menus) is now ContextMenuContainer.
- BREAKING: ContextMenus has to specify width and height (new feature: contextmenu stays within pane and new center option )

## [0.1.1] - 2020-11-04

- Bug fix: when contextmenu then open left click would remove focus.

## [0.1.0] - 2020-11-03

- First version with contextmenu (master, detail and custom widget)


## [0.0.4] - 2020-10-31

- Example gif updated

## [0.0.3] - 2020-10-31

- News: responsive master/detail pane included with lots of features
- Breaking: Menu() changed to AppScreen()
- new example website: http://www.flutter.psychtech.mitspace.dk/
- new gif in readme

## [0.0.2] - 2020-10-25

- changes to readme - gif example included

## [0.0.1] - 2020-10-24

- initial release