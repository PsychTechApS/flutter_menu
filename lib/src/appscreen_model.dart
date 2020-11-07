import 'package:flutter/foundation.dart';

import '../flutter_menu.dart';

class Detail {
  double height;
  double width;
  double minDx;
  double minDy;
  double maxDx;
  double maxDy;
  // bool isShown;
  @override
  String toString() =>
      'Detail(height: $height, width: $width, minDx: $minDx), minDy: $minDy, maxDx: $maxDx, minDy: $maxDy)';
}

class ContextMenu {
  final double width;
  final double height;
  final ContextMenuWidget child;

  ContextMenu(
      {@required this.child, @required this.width, @required this.height});
}
