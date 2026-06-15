import 'package:flutter/material.dart';

/// Layout sizing shared across screens so the app reads well on phones,
/// tablets, desktop and the web instead of stretching a phone UI.
const double kContentMaxWidth = 720;
const double kWideLayoutBreakpoint = 800;

bool isWideLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= kWideLayoutBreakpoint;

/// Centers a screen's scrollable content and caps its width on large screens
/// while keeping the surrounding [Scaffold]/[AppBar] full-bleed.
class ContentBody extends StatelessWidget {
  const ContentBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
        child: child,
      ),
    );
  }
}
