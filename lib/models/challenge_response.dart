// To parse this JSON data, do
//
//     final challengeResponse = challengeResponseFromJson(jsonString);

import 'dart:convert';

ChallengeResponse challengeResponseFromJson(String str) => ChallengeResponse.fromJson(json.decode(str));

String challengeResponseToJson(ChallengeResponse data) => json.encode(data.toJson());

class ChallengeResponse {
  List<Challenge> listChallenges;

  ChallengeResponse({
    this.listChallenges,
  });

  factory ChallengeResponse.fromJson(Map<String, dynamic> json) => ChallengeResponse(
    listChallenges: List<Challenge>.from(json["challenges"].map((x) => Challenge.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "challenges": List<dynamic>.from(listChallenges.map((x) => x.toJson())),
  };
}

class Challenge {
  int id;
  String brandSponsor;
  String brandImage;
  String challengeName;
  int challengeDurationHour;
  String prizeTitle;
  String prize;
  String prizeDescription;
  int status;
  String challengeEnded;
  String challengeEndedStr;

  Challenge({
    this.id,
    this.brandSponsor,
    this.brandImage,
    this.challengeName,
    this.challengeDurationHour,
    this.prizeTitle,
    this.prize,
    this.prizeDescription,
    this.status,
    this.challengeEnded,
    this.challengeEndedStr,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
    id: json["id"],
    brandSponsor: json["brand_sponsor"],
    brandImage: json["brand_image"],
    challengeName: json["challenge_name"],
    challengeDurationHour: json["challenge_duration_hour"],
    prizeTitle: json["prize_title"],
    prize: json["prize"],
    prizeDescription: json["prize_description"],
    status: json["status"],
    challengeEnded: json["challenge_ended"],
    challengeEndedStr: json["challenge_ended_str"] ?? '-',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "brand_sponsor": brandSponsor,
    "brand_image": brandImage,
    "challenge_name": challengeName,
    "challenge_duration_hour": challengeDurationHour,
    "prize_title": prizeTitle,
    "prize": prize,
    "prize_description": prizeDescription,
    "status": status,
    "challenge_ended": challengeEnded,
    "challenge_ended_str": challengeEndedStr ?? '-',
  };
}
