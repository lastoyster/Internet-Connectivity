import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigoAccent,
          textTheme: const TextTheme(
            bodyText2: TextStyle(fontSize: 30),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 32),
              minimumSize: const Size(250, 56),
            ),
          ),
        ),
        home: const MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late StreamSubscription subscription;
  late StreamSubscription internetSubscription;
  bool hasInternet = false;

  @override
  void initState() {
    super.initState();

    subscription =
        Connectivity().onConnectivityChanged.listen(_showConnectivitySnackBar);

    internetSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;

      setState(() => this.hasInternet = hasInternet);
    });
  }

  @override
  void dispose() {
    super.dispose();

    subscription.cancel();
    internetSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connectivity plus'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildInternetStatus(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final result = await Connectivity().checkConnectivity();
                _showConnectivitySnackBar(result);
              },
              child: const Text('Check connectivity'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInternetStatus() => Column(
        children: [
          const Text(
            'Connection status',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasInternet ? Icons.done : Icons.error,
                color: hasInternet ? Colors.green : Colors.red,
                size: 40,
              ),
              const SizedBox(width: 20),
              Text(hasInternet ? 'Internet available' : 'No Internet'),
            ],
          ),
        ],
      );

  void _showConnectivitySnackBar(ConnectivityResult result) {
    final hasInternet = result != ConnectivityResult.none;
    final message = hasInternet
        ? result == ConnectivityResult.mobile
            ? 'You are connected to Mobile Network'
            : 'You are connected to Wifi Network'
        : 'You have no internet';
    final color = hasInternet ? Colors.green : Colors.red;

    _showSnackBar(message, color);
  }

  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 20),
      ),
      backgroundColor: color,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
