import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:okta_login/src/domain/model/okta_configuration.dart';

final class IsTokenActiveUseCaseUseCase {
  const IsTokenActiveUseCaseUseCase();

  Future<bool> call({
    required String token,
    required OktaConfiguration oktaConfiguration,
  }) async {
    try {
      final tokenValidation = await _validateToken(
        token: _extractAccessToken(token: token),
        oktaConfiguration: oktaConfiguration,
      );
      return tokenValidation['active'] as bool;
    } catch (_) {
      return false;
    }
  }

  String _extractAccessToken({required String token}) {
    final json = jsonDecode(token) as Map<String, dynamic>;
    return json['accessToken'] as String;
  }

  Future<Map<String, dynamic>> _validateToken({
    required String token,
    required OktaConfiguration oktaConfiguration,
  }) async {
    final url = Uri.https(
      oktaConfiguration.domain,
      'oauth2/default/v1/introspect',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'client_id': oktaConfiguration.clientId, 'token': token},
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
