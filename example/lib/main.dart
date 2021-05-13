import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_menu/flutter_menu.dart';

const Map kColorMap = {
  'Red': Colors.red,
  'Blue': Colors.blue,
  'Purple': Colors.purple,
  'Black': Colors.black,
  'Pink': Colors.pink,
  'Yellow': Colors.yellow,
  'Orange': Colors.orange,
  'White': Colors.white,
  'BlueGrey': Colors.blueGrey,
};

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(
                Colors.blueGrey[600]), // Set Button hover color
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.black),

            backgroundColor: MaterialStateProperty.all(Colors.white),
            overlayColor: MaterialStateProperty.all(
                Colors.blueGrey[600]), // Set Button hover color
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Screen(),
    );
  }
}

class Screen extends StatefulWidget {
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  final ScrollController scrollController = ScrollController();
  TextEditingController controller = TextEditingController();
  String _message = "Choose a MenuItem.";
  String _drawerTitle = 'Tap a drawerItem';
  IconData _drawerIcon = Icons.menu;

  Color masterBackgroundColor = Colors.white;
  Color detailBackgroundColor = Colors.blueGrey[300] as Color;

  void _showMessage(String newMessage) {
    setState(() {
      _message = newMessage;
    });
  }

  void _masterSetBackgroundColor(String color) {
    setState(() {
      masterBackgroundColor = kColorMap[color];
    });
  }

  void _detailSetBackgroundColor(String color) {
    setState(() {
      detailBackgroundColor = kColorMap[color];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreen(
        masterContextMenu: ContextMenu(
          width: 150,
          height: 250,
          child: ContextMenuSliver(
            title: 'Master',
            children: [
              masterContextMenuItem(color: 'Red'),
              masterContextMenuItem(color: 'Blue'),
              masterContextMenuItem(color: 'Purple'),
              masterContextMenuItem(color: 'Pink'),
              masterContextMenuItem(color: 'White'),
            ],
          ),
        ),
        detailContextMenu: ContextMenu(
          width: 300,
          height: 150,
          child: ContextMenuSliver(
            title: 'Detail',
            children: [
              detailContextMenuItem(color: 'Yellow'),
              detailContextMenuItem(color: 'Orange'),
              detailContextMenuItem(color: 'Pink'),
              detailContextMenuItem(color: 'Red'),
              detailContextMenuItem(color: 'BlueGrey'),
            ],
          ),
        ),
        menuList: [
          MenuItem(title: 'File', menuListItems: [
            MenuListItem(
              icon: Icons.open_in_new,
              title: 'Open',
              onPressed: () {
                _showMessage('File.open');
              },
              shortcut: MenuShortcut(key: LogicalKeyboardKey.keyO, ctrl: true),
            ),
            MenuListItem(
              title: 'Close',
              onPressed: () {
                _showMessage('File.close');
              },
            ),
            MenuListItem(
              title: 'Save',
              onPressed: () {
                _showMessage('File.save');
              },
            ),
            MenuListItem(
              title: 'Delete',
              shortcut: MenuShortcut(key: LogicalKeyboardKey.keyD, alt: true),
              onPressed: () {
                _showMessage('File.delete');
              },
            ),
          ]),
          MenuItem(title: 'View', isActive: true, menuListItems: [
            MenuListItem(title: 'View all'),
            MenuListItem(title: 'close view'),
            MenuListItem(title: 'jump to'),
            MenuListItem(title: 'go to'),
          ]),
          MenuItem(title: 'Help', isActive: true, menuListItems: [
            MenuListItem(title: 'Help'),
            MenuListItem(title: 'About'),
            MenuListItem(title: 'License'),
            MenuListDivider(),
            MenuListItem(title: 'Goodbye'),
          ]),
        ],
        masterPane: masterPane(),
        detailPane: detailPane(),
        drawer: AppDrawer(
          defaultSmall: false,
          largeDrawerWidth: 200,
          largeDrawer: drawer(small: false),
          smallDrawerWidth: 60,
          smallDrawer: drawer(small: true),
        ),
        onBreakpointChange: () {
          setState(() {
            print('Breakpoint change');
          });
        },
        resizeBar: ResizeBar(
            leftColor: masterBackgroundColor,
            rightColor: detailBackgroundColor),
      ),
    );
  }

  Widget drawer({required bool small}) {
    return Container(
        color: Colors.amber,
        child: ListView(
          children: [
            drawerButton(
                title: 'User', icon: Icons.account_circle, small: small),
            drawerButton(title: 'Inbox', icon: Icons.inbox, small: small),
            drawerButton(title: 'Files', icon: Icons.save, small: small),
            drawerButton(
              title: 'Clients',
              icon: Icons.supervised_user_circle,
              small: small,
            ),
            drawerButton(
              title: 'Settings',
              icon: Icons.settings,
              small: small,
            ),
          ],
        ));
  }

  Widget drawerButton(
      {required String title, required IconData icon, required bool small}) {
    return small
        ? drawerSmallButton(icon: icon, title: title)
        : drawerLargeButton(icon: icon, title: title);
  }

  Widget drawerLargeButton({required String title, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          elevation: 8,
          child: ListTile(
            leading: Icon(icon),
            title: Text(title),
            onTap: () {
              setState(() {
                _drawerIcon = icon;
                _drawerTitle = title;
              });
            },
          )),
    );
  }

  Widget drawerSmallButton({required String title, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3, 8, 3, 8),
      child: Card(
          elevation: 8,
          child: SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _drawerIcon = icon;
                  _drawerTitle = title;
                });
              },
              child: Center(child: Icon(icon, size: 30, color: Colors.black54)),
            ),
          )),
    );
  }

  Builder detailPane() {
    print('BUILD: detailPane');
    return Builder(
      builder: (BuildContext context) {
        return Container(
          color: detailBackgroundColor,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Card(
                  elevation: 12,
                  child: Container(
                    width: 300,
                    height: 50,
                    child: Container(
                      color: Colors.amber,
                      child: Center(
                          child:
                              Text('DETAIL', style: TextStyle(fontSize: 20))),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.appScreen.closeMenu();
                      },
                      child: Text('Close Menu'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.appScreen.hideMenu();
                      },
                      child: Text('Hide Menu'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.appScreen.showMenu();
                      },
                      child: Text('Show Menu'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Container(
                    color: Colors.blueGrey,
                    child: Center(
                        child: Text(_message,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 40))),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 12,
                  child: Container(
                    width: 300,
                    height: 50,
                    child: Center(
                      child: Text(
                          'Pane height: ${context.appScreen.detailPaneDetails.height.toStringAsFixed(1)} width: ${context.appScreen.detailPaneDetails.width.toStringAsFixed(1)}',
                          style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (context.appScreen.isCompact())
                  ElevatedButton(
                    onPressed: () {
                      context.appScreen.showOnlyMaster();
                    },
                    child: Text('Show master'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Builder masterPane() {
    print('BUILD: masterPane');
    return Builder(
      builder: (BuildContext context) {
        return Container(
          color: masterBackgroundColor,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Card(
                  elevation: 12,
                  child: Container(
                    width: 300,
                    height: 50,
                    child: Container(
                      color: Colors.amber,
                      child: Center(
                          child:
                              Text('MASTER', style: TextStyle(fontSize: 20))),
                    ),
                  ),
                ),
                SizedBox(height: 80),
                SizedBox(
                    width: 140,
                    height: 110,
                    child: Card(
                        elevation: 8,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_drawerIcon, size: 50, color: Colors.black54),
                            Text(_drawerTitle,
                                style: TextStyle(color: Colors.black54)),
                          ],
                        ))),
                SizedBox(height: 80),
                ContextMenuContainer(
                  width: 300,
                  height: 200,
                  menu: ContextMenuSliver(
                    title: 'Widget',
                  ),
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Container(
                      color: Colors.blueGrey,
                      child: Center(
                        child: Text('Right click or longpress me',
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: TextStyle(fontSize: 30)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (context.appScreen.isCompact())
                  ElevatedButton(
                    onPressed: () {
                      context.appScreen.showOnlyDetail();
                    },
                    child: Text('Show detail'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Builder appContextMenu() {
    print('BUILD: appContextMenu');
    return Builder(
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          width: 400,
          child: Container(
            color: Colors.yellow,
            child: Text('AppContextMenu'),
          ),
        );
      },
    );
  }

  Widget masterContextMenuItem({required String color}) {
    return ContextMenuItem(
      onTap: () {
        _masterSetBackgroundColor(color);
      },
      child: Container(
        color: kColorMap[color],
        child: Center(child: Text(color)),
      ),
    );
  }

  Widget detailContextMenuItem({required String color}) {
    return ContextMenuItem(
      onTap: () {
        _detailSetBackgroundColor(color);
      },
      child: Container(
        color: kColorMap[color],
        child: Center(child: Text(color)),
      ),
    );
  }
}
