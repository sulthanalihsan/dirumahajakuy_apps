import 'package:dirumahajakuy/commons/database_helper.dart';
import 'package:dirumahajakuy/models/challenge_response.dart';
import 'package:flutter/foundation.dart';

class DataChallengeNotifier with ChangeNotifier {
  List<Challenge> _listChallenge = [];

  List<Challenge> get listChallenge => _listChallenge;

  Future<List<Challenge>> getAllChallange(int status) async {
    _listChallenge =
        await DatabaseHelper.db.getAllChallange(status).then((listChallenges) {
      listChallenges.forEach((challenge) {
        var estimateChallengeEndedHour = DateTime.now()
            .difference(DateTime.parse(challenge.challengeEnded))
            .inHours
            .remainder(60)
            .abs();
        var estimateChallengeEndedMinute = DateTime.now()
            .difference(DateTime.parse(challenge.challengeEnded))
            .inMinutes
            .remainder(60)
            .abs();

        var estimateChallengeEndedStr = '$estimateChallengeEndedHour Jam, '
            '$estimateChallengeEndedMinute Menit Lagi';
        challenge.challengeEndedStr = estimateChallengeEndedStr;
      });
      return listChallenges;
    });
    return _listChallenge;
  }

  Future<int> deleteChallengeById(Challenge challenge) {
    _listChallenge.remove(challenge);
    notifyListeners();
    return DatabaseHelper.db.deleteChallengeById(challenge.id);
  }

}
