import 'package:okta_login/src/data/okta_login_method_channel.dart';
import 'package:okta_login/src/domain/model/okta_configuration.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class AuthenticateUseCase extends PlatformInterface {
  AuthenticateUseCase() : super(token: _token);

  static final Object _token = Object();
  static AuthenticateUseCase _instance = MethodChannelOktaLogin();

  static AuthenticateUseCase get instance => _instance;

  static set instance(AuthenticateUseCase instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> call({required OktaConfiguration oktaConfiguration}) =>
      throw UnimplementedError('call() has not been implemented.');
}
