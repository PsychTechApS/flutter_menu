import 'package:flutter/material.dart';

import 'package:flutter_menu/flutter_menu.dart';

class ContextMenuSliver extends ContextMenuWidget {
  final String title;
  final double height;
  final double width;
  final Color titleBackgroundColor;
  final TextStyle? titleStyle;
  final Color widgetBackgroundColor;

  final List<Widget> children;

  ContextMenuSliver({
    Key? key,
    this.title = 'Menu',
    this.height = 200,
    this.width = 150,
    this.titleBackgroundColor = Colors.green,
    this.titleStyle,
    this.widgetBackgroundColor = Colors.amber,
    this.children = const [Center(child: Text('Empty'))],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Card(
        elevation: 5,
        child: Container(
          color: widgetBackgroundColor,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                title: Text(title, style: titleStyle),
                backgroundColor: titleBackgroundColor,
                expandedHeight: 60.0,
                // flexibleSpace: FlexibleSpaceBar(
                //   background: Image.asset('assets/forest.jpg', fit: BoxFit.cover),
                // ),
              ),
              SliverFixedExtentList(
                itemExtent: 50.0,
                delegate: SliverChildListDelegate(List.from(children)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContextMenuItem extends ContextMenuItemType {
  final Function? onTap;

  final Widget? child;

  ContextMenuItem({
    Key? key,
    this.onTap,
    this.child,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap as void Function()?, child: child);
  }
}
