import 'package:flutter/services.dart';
import 'package:okta_login/src/domain/use_case/authenticate_use_case.dart';

class MethodChannelOktaLogin extends AuthenticateUseCase {
  final methodChannel = const MethodChannel('okta_login');
}
