import 'dart:async';
import 'dart:html';
import 'dart:js_util';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:okta_login/src/domain/model/okta_configuration.dart';
import 'package:okta_login/src/domain/use_case/authenticate_use_case.dart';

const _oktaWidgetId = 'okta-widget-container';

final class AuthenticateUseCaseWeb extends AuthenticateUseCase {
  AuthenticateUseCaseWeb();

  static void registerWith(Registrar registrar) {
    AuthenticateUseCase.instance = AuthenticateUseCaseWeb();
  }

  @override
  Future<String> call({required OktaConfiguration oktaConfiguration}) {
    final completer = Completer<String>();

    _addLibrary(
      () => _addCss(
        () => _addDiv(
          () => _login(
            oktaConfiguration: oktaConfiguration,
            onAuthenticated: (token) => completer.complete(token),
            onError: () => completer.completeError(
              Exception('Failed to authenticate'),
            ),
          ),
        ),
      ),
    );

    return completer.future;
  }

  void _addLibrary(void Function() onLoad) =>
      querySelector('head')!.children.add(
            ScriptElement()
              ..type = "text/javascript"
              ..charset = "utf-8"
              ..async = true
              ..setAttribute(
                'src',
                'https://global.oktacdn.com/okta-signin-widget/7.12.2/js/okta-sign-in.min.js',
              )
              ..addEventListener('load', (_) => onLoad()),
          );

  void _addCss(void Function() onLoad) => querySelector('head')!.children.add(
        Element.tag('link')
          ..setAttribute('style', 'width:0%; height:0%;')
          ..setAttribute('type', 'text/css')
          ..setAttribute('rel', 'stylesheet')
          ..setAttribute(
            'href',
            'https://global.oktacdn.com/okta-signin-widget/7.12.2/css/okta-sign-in.min.css',
          )
          ..addEventListener('load', (_) => onLoad()),
      );

  void _addDiv(void Function() onLoad) {
    querySelector('body')!.children.add(Element.div()..id = _oktaWidgetId);
    onLoad();
  }

  void _login({
    required OktaConfiguration oktaConfiguration,
    required void Function(String) onAuthenticated,
    required void Function() onError,
  }) {
    if (!hasProperty(window, 'onAuthenticated')) {
      setProperty(window, 'onAuthenticated', allowInterop(onAuthenticated));
    }
    if (!hasProperty(window, 'onError')) {
      setProperty(window, 'onError', allowInterop(onError));
    }

    final login = ScriptElement()
      ..innerHtml = '''
       const signIn = new OktaSignIn({
            baseUrl: 'https://${oktaConfiguration.domain}',
            el: '#$_oktaWidgetId',
            clientId: '${oktaConfiguration.clientId}',
            redirectUri: '${oktaConfiguration.redirectUri}',
            authParams: {
                issuer: 'https://${oktaConfiguration.domain}/oauth2/default'
            }
        });
        var searchParams = new URL(window.location.href).searchParams;
        signIn.otp = searchParams.get('otp');
        signIn.state = searchParams.get('state');

        signIn.showSignInToGetTokens().then(function(tokens) {
            const element = document.getElementById("$_oktaWidgetId");
            element.remove();

            var accessToken = JSON.stringify(tokens['accessToken']);
            onAuthenticated(accessToken);
        }).catch(function(error){
            onError();
        });
      ''';
    querySelector('body')!.children.add(login);
  }
}
