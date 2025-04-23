import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'app_data.dart';

class CanvasPainter extends CustomPainter {
  final AppData appData;

  Map directions_run = {
    "down": [Offset(0, 0), Offset(64, 0), Offset(128, 0), Offset(192, 0), Offset(256, 0), Offset(320, 0), Offset(384, 0), Offset(448, 0)],
    "up": [Offset(0, 64), Offset(64, 64), Offset(128, 64), Offset(192, 64), Offset(256, 64), Offset(320, 64), Offset(384, 64), Offset(448, 64)],
    "left": [Offset(0, 128), Offset(64, 128), Offset(128, 128), Offset(192, 128), Offset(256, 128), Offset(320, 128), Offset(384, 128), Offset(448, 128)],
    "right": [Offset(0, 192), Offset(64, 192), Offset(128, 192), Offset(192, 192), Offset(256, 192), Offset(320, 192), Offset(384, 192), Offset(448, 192)]
  };

  Map directions_walk = {
    "down": [Offset(0, 0), Offset(64, 0), Offset(128, 0), Offset(192, 0), Offset(256, 0), Offset(320, 0)],
    "up": [Offset(0, 64), Offset(64, 64), Offset(128, 64), Offset(192, 64), Offset(256, 64), Offset(320, 64)],
    "left": [Offset(0, 128), Offset(64, 128), Offset(128, 128), Offset(192, 128), Offset(256, 128), Offset(320, 128)],
    "right": [Offset(0, 192), Offset(64, 192), Offset(128, 192), Offset(192, 192), Offset(256, 192), Offset(320, 192)]
  };
  CanvasPainter(this.appData);

  @override
  void paint(Canvas canvas, Size painterSize) {
    // Draw white background
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, painterSize.width, painterSize.height),
      paint,
    );

    // Draw game state
    var gameState = appData.gameState;
    var gameData = appData.gameData;
    var countdown = appData.countdown;
    var gameStart = appData.gameStart;
    var restart = appData.restart;

    if (gameState.isNotEmpty && gameData.isNotEmpty) {

      // 
      // 
      // 
      // 

      // Get level data
      if (gameState["level"] != null) {
        final String levelName = gameState["level"];
        final List<dynamic> levels = appData.gameData["levels"];
        final level = levels.firstWhere(
          (lvl) => lvl["name"] == levelName,
          orElse: () => null,
        );
        
        // // Update camera position based on player data
        // if (appData.playerData != null) {
        //   appData.camera.x = appData.playerData["x"].toDouble();
        //   appData.camera.y = appData.playerData["y"].toDouble();
        // }
        
        // Draw the level
        if (level != null) {
          drawLevel(canvas, painterSize, level);
          drawKeys(canvas, painterSize);
        }
      }

      // Draw the flag
      drawFlag(canvas, painterSize);
      
      // Draw players
      if (gameState["players"] != null) {
        for (var player in gameState["players"]) {
          if(player["id"][0] == "C"){
            
            drawPlayer(canvas, painterSize, player);
          }
        }
      }

      // Draw connection status indicator
      paint.color = appData.isConnected ? Colors.green : Colors.red;
      canvas.drawCircle(Offset(painterSize.width - 10, 10), 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  // Helper method to get camera and scale
  Map<String, dynamic> _getCameraAndScale(Size painterSize) {
    final cam = appData.camera;
    final double scale = painterSize.width / cam.focal;
    return {'cam': cam, 'scale': scale};
  }

  // Helper method to convert world coordinates to screen coordinates
  Offset worldToScreen(double worldX, double worldY, Size painterSize, {double depth = 0}) {
    final camData = _getCameraAndScale(painterSize);
    final cam = camData['cam'];
    final scale = camData['scale'];
    
    final double parallax = depth >= 0 ? 1.0 : 1.0 / (1.0 - depth);
    final double camX = cam.x * parallax;
    final double camY = cam.y * parallax;
    
    return Offset(
      (worldX - camX) * scale + painterSize.width / 2,
      (worldY - camY) * scale + painterSize.height / 2,
    );
  }

  // Helper method to draw any image from spritesheet
  void drawSpriteFromSheet(
    Canvas canvas, 
    ui.Image spriteSheet, 
    Rect srcRect, 
    Offset destPos, 
    Size destSize,
  ) {
    canvas.drawImageRect(
      spriteSheet,
      srcRect,
      Rect.fromLTWH(
        destPos.dx,
        destPos.dy,
        destSize.width,
        destSize.height,
      ),
      Paint(),
    );
  }

  Offset _getDirectionTile(String direction, bool hasFlag, int tickCounter) {
    if (direction.contains("up")) {
      direction = "up";
    } else if (direction.contains("down")) {
      direction = "down";
    }

    List<Offset> tileList;

    switch (direction) {
      case "left":
      case "up":
      case "right":
      case "down":
        tileList = hasFlag ? directions_walk[direction]! : directions_run[direction]!;
        break;
      default:
        tileList = hasFlag ? directions_walk["down"]! : directions_run["down"]!;
        break;
    }

    // Cada grupo de 3 ticks corresponde a una posición
    int index = (tickCounter ~/ 3) % tileList.length;
    return tileList[index];
  }


  // Convert color string to Flutter Color
  static Color _getColorFromString(String color) {
    switch (color.toLowerCase()) {
      case "orc":
        return Colors.grey;
      case "human":
        return const ui.Color.fromARGB(255, 0, 121, 4);
      case "slime":
        return Colors.blue;
      case "vampire":
        return Colors.orange;
      default:
        return Colors.black;
    }
  }
  
  static String _getImageFromRace(String race, bool hasFlag) {
    switch (race.toLowerCase()) {
      case "orc":
        if(hasFlag){
          return "Orc_Walk_full.png";
        } else{
          return "Orc_Run_full.png";
        }
      case "human":
        if(hasFlag){
          return "Sword_Walk_full.png";
        } else{
          return "Sword_Run_full.png";
        }
      case "slime":
        if(hasFlag){
          return "Slime_Walk_full.png";
        } else{
          return "Slime_Run_full.png";
        }
      case "vampire":
        if(hasFlag){
          return "Vampires_Walk_full.png";
        } else{
          return "Vampires_Run_full.png";
        }
      default:
        if(hasFlag){
          return "Sword_Walk_full.png";
        } else{
          return "Sword_Run_full.png";
        }
    }
  }

  void drawLevel(Canvas canvas, Size painterSize, Map<String, dynamic> level) {
    final layers = level["layers"] as List<dynamic>;
    final camData = _getCameraAndScale(painterSize);
    final cam = camData['cam'];
    final scale = camData['scale'];

    for (final layer in layers) {
      if (layer["visible"] != true) continue;

      final double depth = (layer["depth"] ?? 0).toDouble();
      final double parallax = depth >= 0 ? 1.0 : 1.0 / (1.0 - depth);
      final double camX = cam.x * parallax;
      final double camY = cam.y * parallax;
      final double layerX = (layer["x"] as num?)?.toDouble() ?? 0;
      final double layerY = (layer["y"] as num?)?.toDouble() ?? 0;

      final tileMap = layer["tileMap"] as List<dynamic>;
      final tileW = (layer["tilesWidth"] as num).toDouble();
      final tileH = (layer["tilesHeight"] as num).toDouble();
      final tileSheetPath = "${layer["tilesSheetFile"]}";

      if (!appData.imagesCache.containsKey(tileSheetPath)) continue;
      final ui.Image tileSheet = appData.imagesCache[tileSheetPath]!;
      final int tileSheetCols = (tileSheet.width / tileW).floor();

      for (int row = 0; row < tileMap.length; row++) {
        final rowTiles = tileMap[row] as List<dynamic>;
        for (int col = 0; col < rowTiles.length; col++) {
          final int tileIndex = (rowTiles[col] as num).toInt();
          if (tileIndex < 0) continue;

          final double worldX = layerX + col * tileW;
          final double worldY = layerY + row * tileH;
          final double screenX = (worldX - camX) * scale + painterSize.width / 2;
          final double screenY = (worldY - camY) * scale + painterSize.height / 2;
          final double destWidth = tileW * scale;
          final double destHeight = tileH * scale;
          final int srcCol = tileIndex % tileSheetCols;
          final int srcRow = tileIndex ~/ tileSheetCols;
          final double srcX = srcCol * tileW;
          final double srcY = srcRow * tileH;

          canvas.drawImageRect(
            tileSheet,
            Rect.fromLTWH(srcX, srcY, tileW, tileH),
            Rect.fromLTWH(screenX - 1, screenY - 1, destWidth + 1, destHeight + 1),
            Paint(),
          );
        }
      }
    }
  }



  void drawKeys(Canvas canvas, Size painterSize) {
  final level = appData.gameData["levels"].firstWhere(
    (lvl) => lvl["name"] == appData.gameState["level"],
    orElse: () => null,
  );
  if (level == null) return;

  final sprites = level["sprites"] as List<dynamic>;
  final keySprite = sprites.firstWhere(
    (sprite) => sprite["type"] == "key",
    orElse: () => null,
  );
  if (keySprite == null) return;

  final String spritePath = "${keySprite["imageFile"]}";
  if (!appData.imagesCache.containsKey(spritePath)) return;

  final ui.Image spriteImg = appData.imagesCache[spritePath]!;
  final camData = _getCameraAndScale(painterSize);
  final scale = camData['scale'];
  final tickCounter = appData.gameState["tickCounter"] ?? 0;

  final keys = appData.gameState["keys"];
  if (keys == null) return;

  const frameWidth = 16.0;
  const frameHeight = 32.0;
  const totalFrames = 6;

  for (var key in keys) {
    if (key["pickedUp"] == true) continue;

    final Offset screenPos = worldToScreen(
      key["x"].toDouble(),
      key["y"].toDouble(),
      painterSize,
    );

    final destWidth = key["width"] * scale;
    final destHeight = key["height"] * scale;

    // Animación: calcular frame actual
    final int currentFrame = tickCounter % totalFrames;
    final Offset spriteOffset = Offset(currentFrame * frameWidth, 0);

    drawSpriteFromSheet(
      canvas,
      spriteImg,
      Rect.fromLTWH(spriteOffset.dx, spriteOffset.dy, frameWidth, frameHeight),
      screenPos,
      Size(destWidth, destHeight),
    );
  }
}


  void drawFlag(Canvas canvas, Size painterSize) {
    final level = appData.gameData["levels"].firstWhere(
      (lvl) => lvl["name"] == appData.gameState["level"],
      orElse: () => null,
    );
    if (level == null) return;

    final sprites = level["sprites"] as List<dynamic>;
    final flagSprite = sprites.firstWhere(
      (sprite) => sprite["type"] == "flag",
      orElse: () => null,
    );
    if (flagSprite == null) return;

    final flagOwnerId = appData.gameState["flagOwnerId"];
    final flagHasOwner = flagOwnerId != null && flagOwnerId.isNotEmpty;

    if (!flagHasOwner) {
      // Draw flag at its position if it doesn't have an owner
      final String spritePath = "assets/${flagSprite["imageFile"]}";
      if (!appData.imagesCache.containsKey(spritePath)) return;
      
      final ui.Image spriteImg = appData.imagesCache[spritePath]!;
      final int frameCount = (spriteImg.width / flagSprite["width"]).floor();
      final int tickCounter = appData.gameState["tickCounter"] ?? 0;
      final double frameIndex = (tickCounter % frameCount).toDouble();
      final double srcX = frameIndex * flagSprite["width"];
      
      final Offset screenPos = worldToScreen(
        flagSprite["x"].toDouble(),
        flagSprite["y"].toDouble(),
        painterSize,
      );
      
      final camData = _getCameraAndScale(painterSize);
      final scale = camData['scale'];
      final destWidth = flagSprite["width"] * scale;
      final destHeight = flagSprite["height"] * scale;
      
      canvas.drawImageRect(
        spriteImg,
        Rect.fromLTWH(srcX, 0, flagSprite["width"].toDouble(), flagSprite["height"].toDouble()),
        Rect.fromLTWH(
          screenPos.dx - destWidth / 2,
          screenPos.dy - destHeight / 2,
          destWidth,
          destHeight,
        ),
        Paint(),
      );
    } else {
      // Flag owner text
      final flagOwner = appData.getPlayerData(flagOwnerId);
      if (flagOwner != null) {
        final textSpan = TextSpan(
          text: "Player '${flagOwner["color"]}' has the flag",
          style: TextStyle(color: Colors.black, fontSize: 20),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(50, 50));
      }
    }
  }

  void drawPlayer(Canvas canvas, Size painterSize, Map<String, dynamic> player) {
  

  final camData = _getCameraAndScale(painterSize);
  final scale = camData['scale'];
  



        final double playerWidth = (player["width"] as num).toDouble();
        

        final double playerHeight = (player["height"] as num).toDouble(); // <-- ¿Quizás debería ser 'height'?
        

        final String color = player["race"];
        

        final String direction = player["direction"];
        

        // final bool hasFlag = player["pickedUp"];
        // 
        
        final bool hasFlag = true;

        final int tickCounter = appData.gameState["tickCounter"] ?? 0;

  

  // Get player position
  final Offset screenPos = worldToScreen(
    player["x"].toDouble(),
    player["y"].toDouble(),
    painterSize,
  );

  
  

  // Draw player rectangle
  final Paint paint = Paint()..color = _getColorFromString(color);
  final rect = Rect.fromLTWH(screenPos.dx, screenPos.dy, playerWidth * scale, playerHeight * scale);
  // canvas.drawRect(rect, paint);

  

  // Draw direction arrow
  final String arrowPath = _getImageFromRace(color, hasFlag);
  

  if (appData.imagesCache.containsKey(arrowPath)) {
    final ui.Image arrowsImage = appData.imagesCache[arrowPath]!;
    final Offset tilePos = _getDirectionTile(direction, hasFlag, tickCounter);

    

    const Size tileSize = Size(64, 64); // Arrow tiles are 64x64
    final Size scaledSize = Size((rect.width * 3), (rect.height * 3));

    

    drawSpriteFromSheet(
      canvas,
      arrowsImage,
      Rect.fromLTWH(tilePos.dx, tilePos.dy, tileSize.width, tileSize.height),
      screenPos,
      scaledSize,
    );

    
  } else {
    
  }

    // Draw flag on top of player if they own it
    final flagOwnerId = appData.gameState["flagOwnerId"];
    if (flagOwnerId == player["id"]) {
      // Find flag sprite
      final level = appData.gameData["levels"].firstWhere(
        (lvl) => lvl["name"] == appData.gameState["level"],
        orElse: () => null,
      );
      if (level == null) return;

      final sprites = level["sprites"] as List<dynamic>;
      final flagSprite = sprites.firstWhere(
        (sprite) => sprite["type"] == "flag",
        orElse: () => null,
      );
      if (flagSprite == null) return;

      final String spritePath = "assets/${flagSprite["imageFile"]}";
      if (!appData.imagesCache.containsKey(spritePath)) return;
      
      final ui.Image spriteImg = appData.imagesCache[spritePath]!;
      final int frameCount = (spriteImg.width / flagSprite["width"]).floor();
      final double frameIndex = (tickCounter % frameCount).toDouble();
      final double srcX = frameIndex * flagSprite["width"];
      
      // Draw small flag on top of player
      final double flagScale = 0.5; // Make flag smaller than player
      final double flagWidth = flagSprite["width"] * scale * flagScale;
      final double flagHeight = flagSprite["height"] * scale * flagScale;
      
      // Position flag above player
      final Offset flagPos = Offset(
        screenPos.dx,
        screenPos.dy,
      );
      
      canvas.drawImageRect(
        spriteImg,
        Rect.fromLTWH(srcX, 0, flagSprite["width"].toDouble(), flagSprite["height"].toDouble()),
        Rect.fromLTWH(
          flagPos.dx + playerWidth / 2,
          flagPos.dy - flagHeight,
          flagWidth,
          flagHeight,
        ),
        Paint(),
      );
    }
  }
}