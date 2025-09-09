import 'package:url_launcher/url_launcher.dart';

Future<void> installInLiveContainer(String ipaUrl) async {
  final uri = Uri.parse(
    "livecontainer://install?url=${Uri.encodeComponent(ipaUrl)}",
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
