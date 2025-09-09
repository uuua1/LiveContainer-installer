import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lcinstaller/screens/add_source_page.dart';
import 'package:lcinstaller/models/source.dart';
import 'package:lcinstaller/database_helper.dart';
import 'package:lcinstaller/screens/apps_page.dart';
import 'package:provider/provider.dart';
import 'package:lcinstaller/notifiers/apps_notifier.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SourcesPage extends StatefulWidget {
  const SourcesPage({super.key});

  @override
  State<SourcesPage> createState() => _SourcesPageState();
}

class _SourcesPageState extends State<SourcesPage> {
  List<Source> sources = [];
  bool isLoading = true;
  bool isAddingSource = false;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchSources();
  }

  Future<void> fetchSources() async {
    final dbSources = await DatabaseHelper().getSources();
    setState(() {
      sources = dbSources.map((e) => Source.fromMap(e)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredSources = searchQuery.isEmpty
        ? sources
        : sources
              .where(
                (source) =>
                    source.name.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    source.sourceURL.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text("Sources"),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                List<String>? urls = await Navigator.push(
                  context,
                  CupertinoSheetRoute(
                    builder: (context) => const AddSourcePage(),
                  ),
                );
                if (urls == null || urls.isEmpty) return;
                for (final url in urls) {
                  if (url.isEmpty) continue;
                  final alreadyExists = sources.any((s) => s.sourceURL == url);
                  if (alreadyExists) {
                    if (context.mounted) {
                      showCupertinoDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: const Text('Duplicate Source'),
                          content: const Text('This source already exists.'),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    }
                    return;
                  }
                  setState(() {
                    isLoading = true;
                    isAddingSource = true;
                  });
                  try {
                    final response = await http.get(Uri.parse(url));
                    if (response.statusCode == 200) {
                      final data = json.decode(response.body);

                      if (data['sourceURL'] == null) {
                        data['sourceURL'] = url;
                      }

                      if (data['name'] == null) {
                        throw Exception("Missing required source field: name");
                      }

                      final newSource = Source(
                        name: data['name'],
                        identifier: data['identifier'] ?? data['sourceURL'],
                        subtitle: data['subtitle'] ?? '',
                        sourceURL: url,
                        iconURL:
                            data['iconURL'] ??
                            data['apps']?[0]?['iconURL'] ??
                            '',
                        website: data['website'] ?? '',
                      );

                      await DatabaseHelper().insertSource(newSource.toMap());

                      // Note: Apps are no longer stored in database
                      // They will be fetched fresh from sources when needed

                      if (context.mounted) {
                        try {
                          final provider = Provider.of<AppsNotifier>(
                            context,
                            listen: false,
                          );
                          await provider.refreshApps();
                        } catch (_) {}
                      }
                    } else {
                      if (context.mounted) {
                        showCupertinoDialog(
                          context: context,
                          builder: (_) => CupertinoAlertDialog(
                            title: const Text('Error'),
                            content: Text(
                              'Failed to fetch source data (status ${response.statusCode})',
                            ),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('OK'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      showCupertinoDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          title: const Text('Error'),
                          content: Text(
                            'Failed to fetch or parse source data.\n$e',
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    }
                  } finally {
                    await fetchSources();
                    setState(() {
                      isAddingSource = false;
                    });
                  }
                }
              },
              child: isAddingSource
                  ? const CupertinoActivityIndicator()
                  : const Icon(
                      CupertinoIcons.add,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Repositories',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    filteredSources.length.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CupertinoActivityIndicator()),
                )
              : SliverPadding(
                  padding: const EdgeInsets.only(
                    bottom: kBottomNavigationBarHeight + 20.0,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final source = filteredSources[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: GestureDetector(
                          onLongPress: () {
                            showCupertinoModalPopup(
                              context: context,
                              builder: (context) => CupertinoActionSheet(
                                title: Text(source.name),
                                message: Text('Choose an action'),
                                actions: [
                                  CupertinoActionSheetAction(
                                    isDestructiveAction: true,
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await DatabaseHelper()
                                          .deleteSourceAndApps(source.id!);
                                      if (context.mounted) {
                                        final provider =
                                            Provider.of<AppsNotifier>(
                                              context,
                                              listen: false,
                                            );
                                        await provider.refreshApps();
                                        await fetchSources();
                                      }
                                    },
                                    child: const Text('Delete'),
                                  ),
                                  CupertinoActionSheetAction(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Clipboard.setData(
                                        ClipboardData(text: source.sourceURL),
                                      );
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (dialogContext) =>
                                            CupertinoAlertDialog(
                                              title: const Text('Copied'),
                                              content: const Text(
                                                'Source URL copied to clipboard.',
                                              ),
                                              actions: [
                                                CupertinoDialogAction(
                                                  child: const Text('OK'),
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        dialogContext,
                                                      ),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                    child: const Text('Copy URL'),
                                  ),
                                ],
                                cancelButton: CupertinoActionSheetAction(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                              ),
                            );
                          },
                          child: CupertinoListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                source.iconURL,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(source.name),
                            subtitle: Text(
                              source.sourceURL,
                              style: const TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                            trailing: const Icon(
                              CupertinoIcons.chevron_forward,
                              color: CupertinoColors.systemGrey,
                            ),
                            onTap: () => Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => AppsPage(source: source),
                              ),
                            ),
                          ),
                        ),
                      );
                    }, childCount: filteredSources.length),
                  ),
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
