import 'dart:convert';

import 'package:dirumahajakuy/models/challenge_response.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ServiceChallenge {
//  static final String _baseUrl = 'http://192.168.100.232/dirumahajakuy';
  static final String _baseUrl = 'https://raw.githubusercontent.com/sulthanalihsan/dirumahajakuy/master';

  //end-point
  static String _challenge = "/challenge.json";

  static Future<ChallengeResponse> fetchDataResponse() async {
    final response = await http.get(_baseUrl + _challenge);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      ChallengeResponse data = ChallengeResponse.fromJson(json);
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
