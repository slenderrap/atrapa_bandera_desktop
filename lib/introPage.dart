import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'layout.dart';
import 'app_data.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}class _IntroPageState extends State<IntroPage> {
  bool hasNavigated = false;
  String? restartMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appData = Provider.of<AppData>(context);

    if (!hasNavigated) {
      print(appData.restart);
      if (appData.gameStart.isNotEmpty) {
        hasNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Layout()),
          );
        });
      } else if (appData.restart.isNotEmpty && appData.countdown == 0 && appData.gameStart.isEmpty) {
        setState(() {
          restartMessage = "No hay suficientes jugadores para empezar la partida!";
        });
        print(appData.restart);
        appData.restart = {};
      } else if (appData.countdown > 0){
        setState(() {
          restartMessage = "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset(
              'assets/mainMenuImage.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(),
              ),
            ),
          ),
          // Contenido principal
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '¡Bienvenido!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black45,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Consumer<AppData>(
                  builder: (context, appData, child) {
                    return Column(
                      children: [
                        Text(
                          'La partida comenzara en: ${appData.countdown ?? "-"}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 5,
                                color: Colors.black38,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (restartMessage != null)
                          Text(
                            restartMessage!,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 5,
                                  color: Colors.black38,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
