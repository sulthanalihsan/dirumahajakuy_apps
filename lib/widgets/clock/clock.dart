import 'dart:async';

import 'package:dirumahajakuy/notifier/data_challenge_notifier.dart';
import 'package:dirumahajakuy/widgets/clock/clock_dial_painter.dart';
import 'package:dirumahajakuy/widgets/clock/clock_face.dart';
import 'package:dirumahajakuy/widgets/clock/clock_hands.dart';
import 'package:dirumahajakuy/widgets/clock/clock_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

typedef TimeProducer = DateTime Function();

class Clock extends StatefulWidget {
  final Color circleColor;
  final Color shadowColor;

  final ClockText clockText;

  final TimeProducer getCurrentTime;
  final Duration updateDuration;

  Clock(
      {this.circleColor = const Color(0xfffe1ecf7),
      this.clockText = ClockText.arabic,
      this.shadowColor = const Color(0xffd9e2ed),
      this.getCurrentTime = getSystemTime,
      this.updateDuration = const Duration(seconds: 1)});

  static DateTime getSystemTime() {
    return new DateTime.now();
  }

  @override
  State<StatefulWidget> createState() {
    return _Clock();
  }
}

class _Clock extends State<Clock> {
  Timer _timer;
  DateTime dateTime;

  @override
  void initState() {
    super.initState();
    dateTime = DateTime.now();
    this._timer = Timer.periodic(widget.updateDuration, setTime);
  }

  void setTime(Timer timer) {
    setState(() {
      dateTime = new DateTime.now();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dataChallengeNotif = Provider.of<DataChallengeNotifier>(context);

    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: Column(children: <Widget>[
        AspectRatio(aspectRatio: 1.0, child: buildClockCircle(context)),
        Padding(
          padding: EdgeInsets.only(top: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'CURRENT TIME',
                    style: TextStyle(
                        color: Color(0xffff0863),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    DateFormat.jm().format(dateTime),
                    style: TextStyle(
                      color: Color(0xff2d386b),
                      fontSize: 30.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "CHALLENGE ENDED",
                    style: TextStyle(
                        color: Color(0xffff0863),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    dataChallengeNotif.listChallenge.length == 0
                        ? '-'
                        : DateFormat.jm().format(DateTime.parse(
                            dataChallengeNotif
                                .listChallenge[0]?.challengeEnded)),
                    style: TextStyle(
                      color: Color(0xff2d386b),
                      fontSize: 30.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ]),
    );
  }

  Container buildClockCircle(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            offset: Offset(0.0, 5.0),
            blurRadius: 0.0,
            color: widget.shadowColor,
          ),
          BoxShadow(
              offset: Offset(0.0, 5.0),
              color: widget.circleColor,
              blurRadius: 10.0,
              spreadRadius: -8.0)
        ],
      ),
      child: Stack(
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ClockFace(
                clockText: widget.clockText,
                dateTime: dateTime,
              ),
//              Positioned(
//                top: 10,
//                right: 10,
//                child: CircleAvatar(
//                  radius: 10.0,
//                  backgroundImage: NetworkImage(
//                      'https://zonakuota.com/images/produk/paket_internet/indosat-voucher-data-1015-qzhn.png'),
//                ),
//              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(25),
            width: double.infinity,
            child: CustomPaint(
              painter: ClockDialPainter(clockText: widget.clockText),
            ),
          ),
          ClockHands(dateTime: dateTime),
        ],
      ),
    );
  }
}
