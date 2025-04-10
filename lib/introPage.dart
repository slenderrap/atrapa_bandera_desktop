import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'layout.dart';
import 'app_data.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo borroso con imagen
          Positioned.fill(
            child: Image.asset(
              'assets/mainMenuImage.png', // Asegúrate de agregar esta imagen en tu carpeta assets
              fit: BoxFit.cover,
            ),
          ),
          // Filtro borroso y oscuro
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
                // Aquí usamos Consumer para escuchar los cambios en AppData
                Consumer<AppData>(
                  builder: (context, appData, child) {
                    print("Countdown actualizado: ${appData.countdown}");
                    return Column(
                      children: [
                        Text(
                          'Countdown: ${appData.countdown}',
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
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            shadowColor: Colors.black45,
                            elevation: 10,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const Layout()),
                            );
                          },
                          child: const Text(
                            'Entrar al juego',
                            style: TextStyle(
                              fontSize: 18,
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
                        ),
                      ],
                    );
                  },
                )

              ],
            ),
          ),
        ],
      ),
    );
  }
}
