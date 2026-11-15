
import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Transisi masuk/keluar item list: size + fade + slide tipis.
/// Dipakai pada AnimatedList (insert & remove).
class AnimatedItem extends StatelessWidget {
  const AnimatedItem({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = animation.drive(CurveTween(curve: AppMotion.curve));

    return SizeTransition(
      sizeFactor: curved,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: curved.drive(
            Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
