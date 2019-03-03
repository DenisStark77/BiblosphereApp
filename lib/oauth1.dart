import 'dart:io';
import 'package:oauth1/oauth1.dart';
// ignore_for_file: implementation_imports
import 'package:oauth1/src/authorization_header_builder.dart';
import 'package:http/http.dart' as http;

class GoodreadsAuthorization extends Authorization {
  final ClientCredentials _clientCredentials;
  final Platform _platform;
  final http.BaseClient _httpClient;

  GoodreadsAuthorization(this._clientCredentials, this._platform,
      this._httpClient) : super(_clientCredentials, _platform, _httpClient);

  //Overrise this method as Goodreads does not return oauth_callback_confirmed
  @override
  Future<AuthorizationResponse> requestTemporaryCredentials(
      [String callbackURI]) async {
    callbackURI ??= 'oob';
    final Map<String, String> additionalParams = <String, String>{
      'oauth_callback': callbackURI
    };
    final AuthorizationHeaderBuilder ahb = AuthorizationHeaderBuilder();
    ahb.signatureMethod = _platform.signatureMethod;
    ahb.clientCredentials = _clientCredentials;
    ahb.method = 'POST';
    ahb.url = _platform.temporaryCredentialsRequestURI;
    ahb.additionalParameters = additionalParams;

    final http.Response res = await _httpClient.post(
        _platform.temporaryCredentialsRequestURI,
        headers: <String, String>{'Authorization': ahb.build().toString()});

    if (res.statusCode != 200) {
      throw StateError(res.body);
    }

    final Map<String, String> params = Uri.splitQueryString(res.body);

    return AuthorizationResponse.fromMap(params);
  }
}
