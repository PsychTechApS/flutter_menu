import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_menu/flutter_menu.dart';

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
  String _message = "Choose a MenuItem";

  void _showMessage(String newMessage) {
    setState(() {
      _message = newMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreen(
        appContextMenu: appContextMenu(),
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
        detailWidth: 600,
        detailMinWidth: 400,
        detailMaxWidth: 800,
        onBreakpointChange: () {
          setState(() {
            print('Breakpoint change');
          });
        },
      ),
    );
  }

  Builder detailPane() {
    print('BUILD: detailPane');
    return Builder(
      builder: (BuildContext context) {
        return Container(
          color: Colors.blueGrey[300],
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
                        child: Text('DETAIL', style: TextStyle(fontSize: 20))),
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
              Card(
                elevation: 12,
                child: Container(
                  width: 300,
                  height: 50,
                  child: Center(
                    child: Text(
                        'Pane height: ${context.appScreen.getPaneHeight().toStringAsFixed(1)} width: ${context.appScreen.getDetailPaneWidth().toStringAsFixed(1)}',
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
        );
      },
    );
  }

  Builder masterPane() {
    print('BUILD: masterPane');
    return Builder(
      builder: (BuildContext context) {
        return Container(
          color: Colors.blueAccent,
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
                        child: Text('MASTER', style: TextStyle(fontSize: 20))),
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
              ContextMenu(
                menu: SizedBox(
                  height: 100,
                  width: 100,
                  child:
                      Container(color: Colors.blueGrey, child: Text('Context')),
                ),
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: Container(
                    color: Colors.amber,
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(_message, style: TextStyle(fontSize: 40))),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 12,
                child: Container(
                  width: 400,
                  height: 50,
                  child: Center(
                    child: Text(
                        'Screen height: ${context.appScreen.getScreenHeight().toStringAsFixed(1)} width: ${context.appScreen.getScreenWidth().toStringAsFixed(1)}',
                        style: TextStyle(fontSize: 20)),
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
}
