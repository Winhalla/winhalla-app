import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<InitializationStatus> _initGoogleMobileAds() {
  return MobileAds.instance.initialize();
}
class AdButton extends StatefulWidget {
  final Widget child;
  const AdButton({Key? key, required this.child}) : super(key: key);

  @override
  _AdButtonState createState() => _AdButtonState();
}

class _AdButtonState extends State<AdButton> {
  late Future<InitializationStatus> initStatus;
  @override
  void initState() {
    initStatus = _initGoogleMobileAds();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: widget.child,
      onTap: (){
        print(initStatus);
      },
    );
  }
}
