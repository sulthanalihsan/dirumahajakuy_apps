import 'package:dirumahajakuy/commons/color_palletes.dart';
import 'package:dirumahajakuy/commons/database_helper.dart';
import 'package:dirumahajakuy/models/challenge_response.dart';
import 'package:dirumahajakuy/notifier/data_challenge_notifier.dart';
import 'package:dirumahajakuy/widgets/clock/clock.dart';
import 'package:dirumahajakuy/widgets/custom_item_challenge/item_challenge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class FirstTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final TextStyle _textStyle =
    TextStyle(fontSize: 14, color: Color(0xff5b6990));
    var dataChallengeNotif = Provider.of<DataChallengeNotifier>(context);
    double spaceHeight = 30.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Clock(),
        ),
        SizedBox(
          height: spaceHeight,
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(30, 0, 30, 10),
          child: Text('YOUR CHALLENGE',
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: Color(0xffff0863),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3)),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: FutureBuilder<List<Challenge>>(
                future: dataChallengeNotif.getAllChallange(1),
                builder: (context, AsyncSnapshot<List<Challenge>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                      backgroundColor: ColorPalette.fontColor,
                    ));
                  } else if (snapshot.hasData) {
                    List<Challenge> data = snapshot.data;
                    if (data.length == 0) {
                      return Center(child: Text('Tidak ada challenge saat ini',style: _textStyle));
                    }
                    return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          Challenge challenge = data[index];

                          return ItemChallenge(
                            titleDialog: 'Apakah kamu yakin?',
                            descriptionDialog:
                                'Ingin membatalkan tantangan ini ? \n Hadiah: ${challenge.prizeDescription}\nDari: ${challenge.brandSponsor}',
                            fontColor: ColorPalette.fontColor,
                            titleWidget: challenge.challengeName,
                            subtitleWidget: challenge.challengeEndedStr,
                            trailingWidget: challenge.prize,
                            leadingWidget: challenge.brandImage,
                            onDialogOkButtonPressed: () async {
                              var result = await dataChallengeNotif
                                  .deleteChallengeById(challenge);
                              Toast.show(
                                  'Berhasil Dibatalkan $result', context);
                              result == 1
                                  ? Toast.show('Berhasil Dibatalkan', context)
                                  : Toast.show('Batal Dibatalkan', context);
                            },
                          );
                        });
                  } else {
                    return Center(child: Text('Data tidak ada',style: _textStyle));
                  }
                }),
          ),
        )
      ],
    );
  }
}
