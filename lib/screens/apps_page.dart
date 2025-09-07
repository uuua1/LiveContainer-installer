import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:lcinstaller/models/source.dart';
import 'package:lcinstaller/utils/refetch.dart';
import 'package:provider/provider.dart';
import 'package:lcinstaller/notifiers/apps_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppsPage extends StatefulWidget {
  final Source? source;
  const AppsPage({super.key, this.source});

  @override
  State<AppsPage> createState() => _AppsPageState();
}

class _AppsPageState extends State<AppsPage> {
  late SharedPreferences prefs;
  String searchQuery = "";
  late String sortType;
  late bool sortAscending;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    fetchPreferences();
  }

  void fetchPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      sortType = prefs.getString('sort_type') ?? "default";
      sortAscending = prefs.getBool('sort_ascending') ?? false;
      isReady = true;
    });
  }

  void setSortPreferences(String sortType, bool sortAscending) async {
    await prefs.setString('sort_type', sortType);
    await prefs.setBool('sort_ascending', sortAscending);
    setState(() {
      this.sortType = sortType;
      this.sortAscending = sortAscending;
    });
  }

  Future<void> _installInLiveContainer(String ipaUrl) async {
    final uri = Uri.parse(
      "livecontainer://install?url=${Uri.encodeComponent(ipaUrl)}",
    );
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return Consumer<AppsNotifier>(
      builder: (context, appsNotifier, child) {
        final apps = appsNotifier.apps;
        final isLoading = appsNotifier.isLoading;
        final filteredApps = searchQuery.isEmpty
            ? apps
            : apps
                .where(
                  (app) =>
                      app.name.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ||
                      app.localizedDescription.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                )
                .toList();

        final sortedApps = filteredApps
          ..sort((a, b) {
            int comparison = 0;
            switch (sortType) {
              case "name":
                comparison = a.name.compareTo(b.name);
                break;
              case "date":
              case "default":
                comparison = a.versionDate.compareTo(b.versionDate);
                break;
              default:
                comparison = 0;
            }
            return sortAscending ? comparison : -comparison;
          });

        return CupertinoPageScaffold(
            child: CustomScrollView(
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    await refetchApps(context, widget.source);
                    await appsNotifier.refreshApps();
                  },
                ),
              CupertinoSliverNavigationBar(
                largeTitle: Text(
                  widget.source == null ? 'All Apps' : widget.source!.name,
                ),
                trailing: IconButton(
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) => CupertinoActionSheet(
                        title: const Text("Filter by"),
                        actions: [
                          _buildSortAction("default"),
                          _buildSortAction("name"),
                          _buildSortAction("date"),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(
                    Ionicons.filter_outline,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
                border: null,
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SearchBarDelegate(
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    "${sortedApps.length} Apps",
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ),
              isLoading
                  ? const SliverFillRemaining(
                      child: Center(child: CupertinoActivityIndicator()),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final app = sortedApps[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: CupertinoListTile(
                            leading: Stack(
                              children: [
                                Image.network(
                                  app.iconURL,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.systemBackground
                                          .withAlpha(200),
                                      borderRadius: BorderRadius.circular(34),
                                    ),
                                    child: Image.network(
                                      app.sourceIconURL,
                                      width: 14,
                                      height: 14,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            title: Text(app.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Version: ${app.version}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                Text(
                                  app.localizedDescription,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => _installInLiveContainer(
                                app.downloadURL,
                              ),
                              child: Icon(
                                Ionicons.download_outline,
                                size: 24,
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                          ),
                        );
                      }, childCount: sortedApps.length),
                    ),
            ],
          ),
        );
      },
    );
  }

  CupertinoContextMenuAction _buildSortAction(String type) {
    return CupertinoContextMenuAction(
      onPressed: () {
        setSortPreferences(type, sortType != type || !sortAscending);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(type[0].toUpperCase() + type.substring(1)),
          if (sortType == type)
            Icon(
              sortAscending
                  ? Ionicons.chevron_up_circle_outline
                  : Ionicons.chevron_down_circle_outline,
              size: 16,
              color: CupertinoColors.systemGrey,
            ),
        ],
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final ValueChanged<String> onChanged;
  _SearchBarDelegate({required this.onChanged});

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: maxExtent,
      color: CupertinoColors.systemBackground.resolveFrom(context),
      padding: const EdgeInsets.all(8.0),
      child: CupertinoSearchTextField(
        placeholder: "Search",
        onChanged: onChanged,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
