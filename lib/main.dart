import 'package:flutter/cupertino.dart';
import 'package:lcinstaller/app.dart';
import 'package:provider/provider.dart';
import 'package:lcinstaller/notifiers/apps_notifier.dart';
import 'package:lcinstaller/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppsNotifier()..fetchApps(),
      child: const MyApp(),
    ),
  );
}