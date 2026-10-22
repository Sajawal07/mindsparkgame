import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/constants/app_assets.dart';

/// A small Mindspark-branded loading indicator used on Splash/Home.
class MindSparkLoadingIndicator extends StatelessWidget {
  const MindSparkLoadingIndicator({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        AppAssets.customLoader,
        width: size,
        height: size,
        fit: BoxFit.contain,
        repeat: true,
        animate: true,
      ),
    );
  }
}

