# flutter_menu

This packages is developed for web but should work in flutter desktop as well (is tested on Flutter Windows). 

The package gives you a desktop like experience on web. It gives you the following:

[x] Menu with list items (with icon, title and keyboard shortcuts)
[x] Keyboard shortcuts for menu items
[ ] Context menu (right click) for screen and widgets
[ ] Master, detail views (Left pane, right pane)
[ ] More panes (drawer, 4th pane)
[ ] Extra topbar to be used as toolbar or information bar
[ ] Fullscreen dialogs
 

## How to install

### On web:

The Flutter App has to have control over the right click (contextmenu) a
To take control you have to include the following in your index.html file in the web folder:

<body oncontextmenu="return false;"></body>

### On desktop:

Nothing has to be changed.


## Features

### Keyboard shortcuts

#### Shortcut Overlay

Overlay feature is disabled by default, but can be enabled programmably (se section).

## How to use

Please notice that the browser shortcuts takes presidence over the Flutter App keyboard, so be carefull which shortcut keys to choose.

### Programmably control the menu, context menu, dialog and shortcut overlay

You can access all variables and functions through the buildContext, and for your convenience we have made an extention for easy access: context.menu

Fx.
You would like to enable shortcut overlay and write: context.menu.showShortcutLabel(). Now keyboard shortcuts will activate an 2 sec. text overlay in the buttom of the screen.

All functions accessable through the context.menu:

context.menu.showShortcutOverlay()  - 2 sec. text overlay will be shown
context.menu.hideShortcutOverlay()  - No overlay will be shown


