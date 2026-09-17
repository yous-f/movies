import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InactiveNavBarIcon extends StatelessWidget {
  final String iconName;

  const InactiveNavBarIcon({super.key, required this.iconName});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$iconName.svg',
      width: 24,
      height: 24,
      fit: BoxFit.scaleDown,
    );
  }
}
