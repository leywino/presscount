import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:presscount/bloc/bloc/whistle_bloc.dart';
import 'package:presscount/core/debouncer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:presscount/main.dart'; // Import the main.dart file for notifications plugin

class LogicPage extends StatefulWidget {
  const LogicPage({super.key});

  @override
  State<LogicPage> createState() => _LogicPageState();
}

class _LogicPageState extends State<LogicPage> {
  bool _isRecording = false;
  NoiseReading? _latestReading;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? noiseMeter;
  Debouncer debouncer = Debouncer(milliseconds: 3000);

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  /// Check if microphone permission is granted.
  Future<bool> checkPermission() async => await Permission.microphone.isGranted;

  /// Request the microphone permission.
  Future<void> requestPermission() async =>
      await Permission.microphone.request();

  void _startListening() async {
    if (!_isRecording) {
      if (!(await checkPermission())) await requestPermission();
      try {
        noiseMeter ??= NoiseMeter();
        noiseMeter!.noise.listen(
          (NoiseReading noiseReading) {
            if (noiseReading.meanDecibel > 80) {
              debouncer.run(() {
                BlocProvider.of<WhistleBloc>(context).add(WhistleDetected());
              });
            }
          },
          onError: (Object error) {
            print(error);
          },
          cancelOnError: true,
        );
        _isRecording = true;
        if (!mounted) return;
        BlocProvider.of<WhistleBloc>(context).add(StartListening());
      } catch (err) {
        print(err);
        _isRecording = false;
      }
    }
  }

  void _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Whistle Maximum Reached',
      'Turn cooker off',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  void onError(Object e) {
    print(e);
    _isRecording = false;
  }

  void _stopListening() {
    _noiseSubscription?.cancel();
    _isRecording = false;
    BlocProvider.of<WhistleBloc>(context).add(StopListening());
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listening for Whistles')),
      body: BlocBuilder<WhistleBloc, WhistleState>(
        builder: (context, state) {
          if (state is WhistleCountUpdated &&
              state.count >=
                  BlocProvider.of<WhistleBloc>(context).maxWhistleCount) {
            _showNotification();
          }
          if (state is Listening || state is WhistleCountUpdated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Whistle Count: ${state is WhistleCountUpdated ? state.count : 0}',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Stopped Listening'));
          }
        },
      ),
    );
  }
}
