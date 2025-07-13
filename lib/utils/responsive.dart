// [util 2.1] responsive.dart

import 'package:flutter/material.dart';

class Responsive {
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
}
