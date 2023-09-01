import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temp10/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<ServiceNotificationEvent> events = [];
  StreamSubscription<ServiceNotificationEvent>? _subscription;

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }

  Column example() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  final res =
                      await NotificationListenerService.requestPermission();
                  log("Is enabled: $res");
                },
                child: const Text("Request Permission"),
              ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () async {
                  final bool res =
                      await NotificationListenerService.isPermissionGranted();
                  log("Is enabled: $res");
                },
                child: const Text("Check Permission"),
              ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  _subscription = NotificationListenerService
                      .notificationsStream
                      .listen((event) {
                    log("$event");
                    setState(() {
                      events.add(event);
                    });
                  });
                },
                child: const Text("Start Stream"),
              ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  _subscription?.cancel();
                },
                child: const Text("Stop Stream"),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: events.length,
            itemBuilder: (_, index) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                onTap: () async {
                  try {
                    await events[index].sendReply("This is an auto response");
                  } catch (e) {
                    log(e.toString());
                  }
                },
                trailing: events[index].hasRemoved!
                    ? const Text(
                        "Removed",
                        style: TextStyle(color: Colors.red),
                      )
                    : const SizedBox.shrink(),
                leading: events[index].appIcon == null
                    ? const SizedBox.shrink()
                    : Image.memory(
                        events[index].appIcon!,
                        width: 35.0,
                        height: 35.0,
                      ),
                title: Text(events[index].title ?? "No title"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      events[index].content ?? "no content",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    events[index].canReply!
                        ? const Text(
                            "Replied with: This is an auto reply",
                            style: TextStyle(color: Colors.purple),
                          )
                        : const SizedBox.shrink(),
                    events[index].largeIcon != null
                        ? Image.memory(
                            events[index].largeIcon!,
                          )
                        : const SizedBox.shrink(),
                    Text(events[index].packageName ?? "pakageName"),
                    Text(
                        "--information--\nid: ${events[index].id ?? "id"}\ncanReply: ${events[index].canReply ?? "canReply"}\nhaveExtraPicture: ${events[index].haveExtraPicture ?? "haveExtraPicture"}\nhasRemoved: ${events[index].hasRemoved ?? "hasRemoved"}\npackageName: ${events[index].packageName ?? "packageName"}\ntitle: ${events[index].title ?? "title"}\ncontent: ${events[index].content ?? "content"}")
                  ],
                ),
                isThreeLine: true,
              ),
            ),
          ),
        )
      ],
    );
  }
}