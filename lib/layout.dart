import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'introPage.dart';
import 'canvas_painter.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  // final Set<String> _pressedKeys = {};

  @override
  void initState() {
    super.initState();
    final appData = Provider.of<AppData>(context, listen: false);

    // Preload image
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await appData.getImage("key.png");
    });

    // Escuchar cambios en gameOver
    appData.addListener(() {
      if (appData.gameOver.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const IntroPage()),
        );
        appData.gameStart = {};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Container(
          color: CupertinoColors.systemGrey5,
          child: Focus(
            autofocus: true,
            child: CustomPaint(
              painter: CanvasPainter(appData),
              child: Container(),
            ),
          )
        ),
      ),
    );
  }
}
