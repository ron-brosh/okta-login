import 'package:flutter/widgets.dart';
import 'package:okta_login/src/domain/model/okta_configuration.dart';
import 'package:okta_login/src/domain/model/okta_state.dart';
import 'package:okta_login/src/domain/use_case/authenticate_use_case.dart';
import 'package:okta_login/src/domain/use_case/is_token_active_use_case.dart';

final class OktaLogin extends StatefulWidget {
  const OktaLogin({
    super.key,
    required this.oktaConfiguration,
    required this.builder,
  });

  final OktaConfiguration oktaConfiguration;
  final Widget Function(BuildContext context, OktaState state) builder;

  @override
  State<OktaLogin> createState() => _OktaLoginState();
}

class _OktaLoginState extends State<OktaLogin> {
  OktaState _oktaState = OktaState.initialising;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _oktaState);

  Future<void> _authenticate() async {
    try {
      final token = await AuthenticateUseCase.instance(
        oktaConfiguration: widget.oktaConfiguration,
      );

      setState(() => _oktaState = OktaState.authenticating);
      final isTokenActive = await const IsTokenActiveUseCaseUseCase()(
        oktaConfiguration: widget.oktaConfiguration,
        token: token,
      );

      setState(() {
        _oktaState = isTokenActive ? OktaState.success : OktaState.error;
      });
    } catch (_) {
      setState(() {
        _oktaState = OktaState.error;
      });
    }
  }
}
