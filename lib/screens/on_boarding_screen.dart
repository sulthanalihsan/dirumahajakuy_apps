import 'package:dirumahajakuy/main.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AppClock()),
    );
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset(
        'assets/$assetName.png',
        width: 200.0,
      ),
      alignment: Alignment.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "#DirumahAjaKuy Apps",
          body: "Aplikasi yang bikin kamu senang hati #DirumahAja",
          image: _buildImage('logo'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Ambil Tantangan",
          body: "Kamu akan diberikan tantangan yang menarik saat #DirumahAja",
          image: _buildImage('award'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Dapatkan Hadiahnya",
          body:
              "Setiap tantangan yang kamu selesaikan, akan mendapatkan hadiah menarik",
          image: _buildImage('gift'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}
