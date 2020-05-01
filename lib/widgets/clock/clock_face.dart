import 'package:dirumahajakuy/widgets/clock/clock_text.dart';
import 'package:flutter/material.dart';

class ClockFace extends StatelessWidget {
  final DateTime dateTime;
  final ClockText clockText;

  ClockFace({this.clockText = ClockText.arabic, this.dateTime});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: AspectRatio(
          aspectRatio: 0.75,
          child: LayoutBuilder(
            builder: (context, contraint) => Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF4F9FD),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(8.0, 0.0),
                            blurRadius: 13.0,
                            spreadRadius: 1.0,
                            color: Color(0xffd3e0f0))
                      ]),
                ),
//                Positioned(
////                  left: contraint.biggest.width/2,
//                  top: 0 + 40.0,
////                  right: contraint.biggest.width/2- 10,
////                  bottom: contraint.biggest.width+40,
//                  left: contraint.maxWidth / 2 - 5,
//                  child: CircleAvatar(
//                    radius: 10.0,
//                    backgroundImage: NetworkImage(
//                        'https://zonakuota.com/images/produk/paket_internet/indosat-voucher-data-1015-qzhn.png'),
//                  ),
//                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
