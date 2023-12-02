import 'package:flutter/material.dart';
import 'package:okta_login/okta_login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: OktaLogin(
          oktaConfiguration: const OktaConfiguration(
            domain: String.fromEnvironment('DOMAIN'),
            clientId: String.fromEnvironment('CLIENT_ID'),
            redirectUri: String.fromEnvironment('REDIRECT_URI'),
          ),
          builder: (_, state) {
            return Center(
              child: switch (state) {
                OktaState.initialising => const SizedBox(),
                OktaState.authenticating => const CircularProgressIndicator(),
                OktaState.error => const Text('Failed to authenticate'),
                OktaState.success => const Text('Authentication successful'),
              },
            );
          },
        ),
      ),
    );
  }
}
