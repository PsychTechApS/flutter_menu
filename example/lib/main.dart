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
      home: ExampleApp(),
    );
  }
}

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Menu(
          // leading: Text('Leading'),
          trailing: Text('Trailing'),
          menuList: [
            MenuItem(title: 'File', menuListItems: [
              MenuListItem(
                icon: Icons.open_in_new,
                title: 'Open',
                onPressed: () {
                  print('Open');
                },
                shortcut: MenuShortcut(key: LogicalKeyboardKey.keyO, shift: true),
              ),
              MenuListItem(title: 'Close'),
              MenuListItem(title: 'Save'),
              MenuListItem(
                title: 'Delete',
                shortcut: MenuShortcut(key: LogicalKeyboardKey.keyD, alt: true),
                onPressed: () {
                  print('Delete');
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
          menuBuilder: () {
            return Text('Nr 1');
          },
          builder: Builder(
            builder: (BuildContext context) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 400,
                      height: 30,
                      child: TextField(
                        decoration: InputDecoration(
                            // border: InputBorder.,
                            hintText: 'Try me...'),
                      )),
                  Row(
                    children: [
                      RaisedButton(
                        onPressed: () {
                          context.menu.closeMenu();
                        },
                        child: Text('Close Menu'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      RaisedButton(
                        onPressed: () {
                          context.menu.hideMenu();
                        },
                        child: Text('Hide Menu'),
                      ),
                      RaisedButton(
                        onPressed: () {
                          context.menu.showMenu();
                        },
                        child: Text('Show Menu'),
                      ),
                    ],
                  ),
                ],
              );
            },
          )
          //  NewWidget(),
          ),
    );
  }
}
