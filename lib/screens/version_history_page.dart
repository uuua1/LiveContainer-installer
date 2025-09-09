import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lcinstaller/models/app.dart';
import 'package:lcinstaller/utils/formatters.dart';
import 'package:lcinstaller/utils/utils.dart';
import 'package:lcinstaller/widgets/show_more_text.dart';

class VersionHistoryPage extends StatelessWidget {
  final AppWithSource app;
  const VersionHistoryPage({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(app.name)),
      child: ListView.builder(
        itemCount: app.versions.length,
        itemBuilder: (context, index) {
          final version = app.versions[index];
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Card(
              color: CupertinoColors.secondarySystemBackground.resolveFrom(
                context,
              ),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Version ${version.version}',
                          style: TextStyle(
                            color: CupertinoColors.systemIndigo.resolveFrom(
                              context,
                            ),
                          ),
                        ),
                        if (version.size > 0)
                          Row(
                            children: [
                              Icon(Ionicons.archive_outline, size: 16),
                              SizedBox(width: 4),
                              Text(
                                formatFileSize(version.size),
                                style: TextStyle(
                                  color: CupertinoColors.label.resolveFrom(
                                    context,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (version.date.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          timeAgo(version.date),
                          style: TextStyle(
                            color: CupertinoColors.secondaryLabel.resolveFrom(
                              context,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (version.localizedDescription.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ShowMoreText(
                          version.localizedDescription,
                          style: TextStyle(
                            color: CupertinoColors.secondaryLabel.resolveFrom(
                              context,
                            ),
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ElevatedButton(
                      onPressed: () =>
                          installInLiveContainer(version.downloadURL),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Ionicons.cloud_download_outline, size: 16),
                          SizedBox(width: 8),
                          Text("Get"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
