import 'dart:convert';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show Uint8List, rootBundle;
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart' as pc;

// Future<String> _getAccessToken() async {
//   // Load service account
//   final credentials =
//       jsonDecode(await rootBundle.loadString('assets/key.json'));
//   final clientEmail = credentials['client_email'];
//   final privateKeyPem = credentials['private_key'];
//   const scope = 'https://www.googleapis.com/auth/cloud-platform';

//   // Timestamps
//   final iat = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 60;
//   final exp = iat + 3600;

//   // JWT Header & Payload
//   final header = {'alg': 'RS256', 'typ': 'JWT'};
//   final payload = {
//     'iss': clientEmail,
//     'scope': scope,
//     'aud': 'https://oauth2.googleapis.com/token',
//     'iat': iat,
//     'exp': exp,
//   };

//   // Base64 URL encode
//   String base64UrlEncode(Map data) =>
//       base64Url.encode(utf8.encode(jsonEncode(data))).replaceAll('=', '');
//   final encodedHeader = base64UrlEncode(header);
//   final encodedPayload = base64UrlEncode(payload);
//   final signingInput = '$encodedHeader.$encodedPayload';

//   // Parse RSA private key
//   final privateKey = CryptoUtils.rsaPrivateKeyFromPem(privateKeyPem);

//   // Sign using RS256
//   final signer = pc.Signer('SHA-256/RSA');
//   final privParams = pc.PrivateKeyParameter<pc.RSAPrivateKey>(privateKey);
//   signer.init(true, privParams);
//   final signatureBytes =
//       signer.generateSignature(Uint8List.fromList(utf8.encode(signingInput)))
//           as pc.RSASignature;

//   final signature = base64Url.encode(signatureBytes.bytes).replaceAll('=', '');

//   final jwt = '$signingInput.$signature';

//   // Exchange JWT for OAuth token
//   final response = await http.post(
//     Uri.parse('https://oauth2.googleapis.com/token'),
//     headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//     body: {
//       'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
//       'assertion': jwt,
//     },
//   );

//   if (response.statusCode != 200) {
//     throw Exception('Failed to get token: ${response.body}');
//   }

//   final json = jsonDecode(response.body);
//   return json['access_token'];
// }

/// Handles fetching a fresh Google Cloud access token using a service account JSON.
class AuthTokenService {
  static Future<String> getAccessToken() async {
    final credentials =
        jsonDecode(await rootBundle.loadString('assets/key.json'));
    final clientEmail = credentials['client_email'];
    final privateKeyPem = credentials['private_key'];
    const scope = 'https://www.googleapis.com/auth/cloud-platform';

    final iat = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 60;
    final exp = iat + 3600;

    final header = {'alg': 'RS256', 'typ': 'JWT'};
    final payload = {
      'iss': clientEmail,
      'scope': scope,
      'aud': 'https://oauth2.googleapis.com/token',
      'iat': iat,
      'exp': exp,
    };

    String base64UrlEncode(Map data) =>
        base64Url.encode(utf8.encode(jsonEncode(data))).replaceAll('=', '');
    final encodedHeader = base64UrlEncode(header);
    final encodedPayload = base64UrlEncode(payload);
    final signingInput = '$encodedHeader.$encodedPayload';

    final privateKey = CryptoUtils.rsaPrivateKeyFromPem(privateKeyPem);
    final signer = pc.Signer('SHA-256/RSA');
    signer.init(true, pc.PrivateKeyParameter<pc.RSAPrivateKey>(privateKey));

    // final signature = signer
    //     .generateSignature(Uint8List.fromList(utf8.encode(signingInput)))
    //     .bytes;

    final pc.RSASignature signature = signer.generateSignature(
      Uint8List.fromList(utf8.encode(signingInput)),
    ) as pc.RSASignature;

    final signatureBytes = signature.bytes;

    final signedJwt =
        '$signingInput.${base64Url.encode(signatureBytes).replaceAll('=', '')}';

    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': signedJwt,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch token: ${response.body}');
    }

    return jsonDecode(response.body)['access_token'];
  }
}
