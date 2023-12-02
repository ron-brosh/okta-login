final class OktaConfiguration {
  const OktaConfiguration({
    required this.domain,
    required this.clientId,
    required this.redirectUri,
  });

  final String domain;
  final String clientId;
  final String redirectUri;
}
