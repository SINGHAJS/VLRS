import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var dataFromTelemetry = "";
  var token =
      "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0ZW5hbnRAdGhpbmdzYm9hcmQub3JnIiwidXNlcklkIjoiNDEwYTJkYjAtNDE5Ni0xMWVlLTk2OWQtNWIyNDI0YTlhM2FkIiwic2NvcGVzIjpbIlRFTkFOVF9BRE1JTiJdLCJzZXNzaW9uSWQiOiIwYmNmZDFkMC0wNGVlLTRiZjItOTVjYi1jZGYxZjRiNTAyYWIiLCJpc3MiOiJ0aGluZ3Nib2FyZC5pbyIsImlhdCI6MTY5NjUxOTAzOCwiZXhwIjoxNjk2NTI4MDM4LCJlbmFibGVkIjp0cnVlLCJpc1B1YmxpYyI6ZmFsc2UsInRlbmFudElkIjoiM2ZmYzQwMjAtNDE5Ni0xMWVlLTk2OWQtNWIyNDI0YTlhM2FkIiwiY3VzdG9tZXJJZCI6IjEzODE0MDAwLTFkZDItMTFiMi04MDgwLTgwODA4MDgwODA4MCJ9.QtqI9gMyqASoL9rGbnTPy1QhhpxqcON7dAikWvHpKoj8lOGf6IEM31QAi1hJhYBY2e492IDgde1E90ADBTItzg";
  var entityId = "630a8b30-46be-11ee-8816-b3b2ecd2ae97";
  telemetryDataConfig() async {
    var url = "ws://43.226.218.94:8080/api/ws/plugins/telemetry?token=$token";
    final wsUrl = Uri.parse(url);
    var channel = WebSocketChannel.connect(wsUrl);
    var object = {
      "tsSubCmds": [
        {
          "entityType": "DEVICE",
          "entityId": entityId,
          "scope": "LATEST_TELEMETRY",
          "cmdId": 10
        }
      ],
      "historyCmds": [],
      "attrSubCmds": []
    };
    var data = jsonEncode(object);

      channel.sink.add(data);
    channel.stream.listen((message) {
      print(message);
      setState(() {
        dataFromTelemetry = message.toString();
      });
      channel.sink.close(status.goingAway);
    });
  }

  final WebSocketChannel _channel = WebSocketChannel.connect(Uri.parse(
      "ws://43.226.218.94:8080/api/ws/plugins/telemetry?token=eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0ZW5hbnRAdGhpbmdzYm9hcmQub3JnIiwidXNlcklkIjoiNDEwYTJkYjAtNDE5Ni0xMWVlLTk2OWQtNWIyNDI0YTlhM2FkIiwic2NvcGVzIjpbIlRFTkFOVF9BRE1JTiJdLCJzZXNzaW9uSWQiOiIwYmNmZDFkMC0wNGVlLTRiZjItOTVjYi1jZGYxZjRiNTAyYWIiLCJpc3MiOiJ0aGluZ3Nib2FyZC5pbyIsImlhdCI6MTY5NjUxOTAzOCwiZXhwIjoxNjk2NTI4MDM4LCJlbmFibGVkIjp0cnVlLCJpc1B1YmxpYyI6ZmFsc2UsInRlbmFudElkIjoiM2ZmYzQwMjAtNDE5Ni0xMWVlLTk2OWQtNWIyNDI0YTlhM2FkIiwiY3VzdG9tZXJJZCI6IjEzODE0MDAwLTFkZDItMTFiMi04MDgwLTgwODA4MDgwODA4MCJ9.QtqI9gMyqASoL9rGbnTPy1QhhpxqcON7dAikWvHpKoj8lOGf6IEM31QAi1hJhYBY2e492IDgde1E90ADBTItzg"));

  @override
  void initState() {
    super.initState();
    telemetryDataConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              _channel.sink.add(jsonEncode({
                "tsSubCmds": [
                  {
                    "entityType": "DEVICE",
                    "entityId": entityId,
                    "scope": "LATEST_TELEMETRY",
                    "cmdId": 1
                  }
                ],
                "historyCmds": [],
                "attrSubCmds": []
              }));
            },
          )
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: _channel.stream,
          builder: (context, snapshot) {
            return Text(snapshot.hasData ? '${snapshot.data}' : '');
          },
        ),
      ),
    );
  }
}
