import 'package:flutter/cupertino.dart';
import 'package:lcinstaller/database_helper.dart';
import 'package:lcinstaller/models/app.dart';
import 'package:lcinstaller/models/installed_app.dart';
import 'package:lcinstaller/notifiers/installed_apps_notifier.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> installInLiveContainer(
  BuildContext context,
  AppWithSource app, {
  Versions? version,
}) async {
  final uri = Uri.parse(
    "livecontainer://install?url=${Uri.encodeComponent(version?.downloadURL ?? app.latestVersion.downloadURL)}",
  );
  await DatabaseHelper().insertInstalledApp(
    InstalledApp(
      sourceId: app.sourceId,
      name: app.name,
      bundleIdentifier: app.bundleIdentifier,
      iconURL: app.iconURL,
      version: version?.version ?? app.latestVersion.version,
      versionDate: version?.date ?? app.latestVersion.date,
    ).toMap(),
  );
  if (context.mounted) {
    final installedAppsNotifier = Provider.of<InstalledAppsNotifier>(
      context,
      listen: false,
    );
    await installedAppsNotifier.refreshInstalledApps();
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
