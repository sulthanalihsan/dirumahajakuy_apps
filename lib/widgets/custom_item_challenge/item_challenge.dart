import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:toast/toast.dart';

class ItemChallenge extends StatelessWidget {
  const ItemChallenge({
    Key key,
    @required Color fontColor,
    this.titleWidget,
    this.subtitleWidget,
    this.trailingWidget,
    this.leadingWidget,
    this.onDialogOkButtonPressed,
    @required this.titleDialog,
    @required this.descriptionDialog,
  })  : _fontColor = fontColor,
        super(key: key);

  final Color _fontColor;
  final Function onDialogOkButtonPressed;
  final String titleWidget,
      subtitleWidget,
      trailingWidget,
      leadingWidget,
      titleDialog,
      descriptionDialog;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (_) => NetworkGiffyDialog(
                  image: Image.asset(
                    "assets/besepeda.gif",
                    fit: BoxFit.cover,
                  ),
                  title: Text(titleDialog,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w600)),
                  description: Text(descriptionDialog,
                    textAlign: TextAlign.center,
                  ),
                  entryAnimation: EntryAnimation.TOP,
                  buttonOkColor: Color(0xffff5e92),
                  buttonCancelColor: Colors.black12,
                  onOkButtonPressed: () {
                    Navigator.pop(context);
                    onDialogOkButtonPressed();
                  },
                ));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            border: Border(
          top: BorderSide(
            color: Color(0xffdde9f7),
            width: 1.5,
          ),
        )),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 25.0,
              backgroundImage: NetworkImage(leadingWidget),
              backgroundColor: _fontColor,
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titleWidget,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _fontColor),
                ),
                Text(
                  subtitleWidget,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey),
                )
              ],
            ),
            Spacer(),
            Row(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(trailingWidget,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _fontColor)),
                    Text('Voucher',
                        style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey))
                  ],
                ),
                Icon(
                  Icons.arrow_right,
                  color: _fontColor,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
