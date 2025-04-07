import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum ConnectionStatus { disconnected, disconnecting, connecting, connected }

class WebSocketsHandler {
  late Function _callback;
  String ip = "bandera2.ieti.site";
  String port = "443";
  String? socketId;

  WebSocketChannel? _socketClient;
  ConnectionStatus connectionStatus = ConnectionStatus.disconnected;

  void connectToServer(
    String serverIp,
    int serverPort,
    void Function(String message) callback, {
    void Function(dynamic error)? onError,
    void Function()? onDone,
  }) async {
    _callback = callback;
    ip = serverIp;
    port = serverPort.toString();

    connectionStatus = ConnectionStatus.connecting;

    try {
      // Establecer conexión con el servidor
      _socketClient = WebSocketChannel.connect(Uri.parse("wss://$ip:$port"));

      // Una vez conectado, escuchamos mensajes
      _socketClient!.stream.listen(
        (message) {
          connectionStatus = ConnectionStatus.connected;
          _handleMessage(message);
          _callback(message);
        },
        onError: (error) {
          connectionStatus = ConnectionStatus.disconnected;
          onError?.call(error);
        },
        onDone: () {
          connectionStatus = ConnectionStatus.disconnected;
          onDone?.call();
        },
      );

      // // Enviar el mensaje con el tipo de cliente después de conectar
      // // Asegurarse de que el socket está conectado antes de enviar el mensaje
      // sendMessage(json.encode({"type": "connection", "value": "flutter"}));

    } catch (e) {
      connectionStatus = ConnectionStatus.disconnected;
      onError?.call(e);
    }
  }

  void _handleMessage(String message) {
    try {
      final data = jsonDecode(message);
      if (data is Map<String, dynamic> &&
          data.containsKey("type") &&
          data["type"] == "welcome" &&
          data.containsKey("id")) {
        socketId = data["id"];
        if (kDebugMode) {
          print("Client ID assignat pel servidor: $socketId");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error processant missatge WebSocket: $e");
      }
    }
  }

  void sendMessage(String message) {
    if (connectionStatus == ConnectionStatus.connected) {
      _socketClient!.sink.add(message);
    }
  }

  void disconnectFromServer() {
    connectionStatus = ConnectionStatus.disconnecting;
    _socketClient?.sink.close();
    connectionStatus = ConnectionStatus.disconnected;
  }
}
