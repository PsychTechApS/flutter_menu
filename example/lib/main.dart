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

  Color masterBackgroundColor = Colors.white;
  Color detailBackgroundColor = Colors.blueGrey[300];

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
        // masterPaneWidth: 600,
        // masterPaneMinWidth: 400,
        // masterPaneMaxWidth: 800,
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
                    RaisedButton(
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
                    RaisedButton(
                      onPressed: () {
                        context.appScreen.hideMenu();
                      },
                      child: Text('Hide Menu'),
                    ),
                    RaisedButton(
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
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(_message, style: TextStyle(fontSize: 40))),
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
                  RaisedButton(
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
                  width: 400,
                  height: 30,
                  child: TextField(
                    decoration: InputDecoration(
                        // border: InputBorder.,
                        hintText: 'Try me...'),
                  ),
                ),
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
                      child: Align(
                          alignment: Alignment.center,
                          child: Text('Right click Me',
                              style: TextStyle(fontSize: 30))),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (context.appScreen.isCompact())
                  RaisedButton(
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

  Widget masterContextMenuItem({String color}) {
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

  Widget detailContextMenuItem({String color}) {
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
