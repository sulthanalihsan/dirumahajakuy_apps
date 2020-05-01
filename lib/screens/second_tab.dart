import 'package:dirumahajakuy/commons/color_palletes.dart';
import 'package:dirumahajakuy/commons/database_helper.dart';
import 'package:dirumahajakuy/models/challenge_response.dart';
import 'package:dirumahajakuy/notifier/data_challenge_notifier.dart';
import 'package:dirumahajakuy/service/service_challenge.dart';
import 'package:dirumahajakuy/widgets/custom_item_challenge/item_challenge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class SecondTab extends StatelessWidget {
  final double _smallFontSize = 12;
  final double _valFontSize = 30;
  final FontWeight _smallFontWeight = FontWeight.w500;
  final FontWeight _valFontWeight = FontWeight.w700;
  final Color _fontColor = Color(0xff5b6990);
  final TextStyle _textStyle =
      TextStyle(fontSize: 14, color: Color(0xff5b6990));
  final double _smallFontSpacing = 1.3;

  final TabController tabController;

  SecondTab(this.tabController);

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      alignment: Alignment.topCenter,
      child: FutureBuilder<ChallengeResponse>(
          future: ServiceChallenge.fetchDataResponse(),
          builder: (context, AsyncSnapshot<ChallengeResponse> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(
                backgroundColor: ColorPalette.fontColor,
              ));
            } else if (snapshot.hasData) {
              ChallengeResponse data = snapshot.data;

              DateTime now = DateTime.now();
              DateTime dummyNow = DateTime.parse('2020-04-13 08:00:00.000000');

              String dateNowFormat = DateFormat('yyyy-MM-dd').format(now);
              DateTime limitTime =
                  DateTime.parse('$dateNowFormat 09:00:00.000000');

              bool isAnyChallenge = false;
              DatabaseHelper.db.getAllChallange(1).then((listChallenge) {
                isAnyChallenge = listChallenge.length > 0 ? true : false;
              });

//              if (!limitTime.difference(now).isNegative) {
              if (!limitTime.difference(dummyNow).isNegative) {
                //dibawah jam 9
                return ListView.builder(
                    itemCount: data.listChallenges.length,
                    itemBuilder: (context, index) {
                      Challenge challenge = data.listChallenges[index];

                      return ItemChallenge(
                        titleDialog: 'Apakah kamu yakin?',
                        descriptionDialog:
                            'Ingin mengambil tantangan ini? \n Hadiah: ${challenge.prizeDescription}\nDari: ${challenge.brandSponsor}',
                        fontColor: _fontColor,
                        titleWidget: challenge.challengeName,
                        subtitleWidget: challenge.prizeTitle,
                        trailingWidget: challenge.prize,
                        leadingWidget: challenge.brandImage,
                        onDialogOkButtonPressed: () async {
                          if (!isAnyChallenge) {
                            var challengeEnded = DateTime.now().add(Duration(
                                hours: challenge.challengeDurationHour));
                            challenge.challengeEnded =
                                challengeEnded.toString();
                            DatabaseHelper.db
                                .insertChallenge(challenge)
                                .then((result) {
                              Toast.show(
                                  "Challenge berhasil ditambahkan", context,
                                  duration: Toast.LENGTH_SHORT,
                                  gravity: Toast.BOTTOM);
                              tabController.animateTo(0);
                            });
                          } else {
                            Toast.show(
                                "Maaf hanya boleh satu challenge",
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                          }
                        },
                      );
                    });
              } else {
                //diatas jam 9
                return Center(
                    child: Text(
                  'Maaf Diatas jam 9 pagi\nTidak bisa mengambil challenge :"( ',
                  style: _textStyle,
                ));
              }
            } else {
              return Center(child: Text('Data tidak ada', style: _textStyle));
            }
          }),
    );
  }
}
