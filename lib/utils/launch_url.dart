import 'package:url_launcher/url_launcher.dart';

launchURLBrowser(String url) async {
  await launch(url);
}
launchMailto(String url) async {
  await launch("mailto:$url");
}