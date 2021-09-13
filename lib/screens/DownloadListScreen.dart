import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pikapi/basic/Channels.dart';
import 'package:pikapi/basic/Common.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/Pica.dart';
import 'DownloadImportScreen.dart';
import 'DownloadInfoScreen.dart';
import 'components/ContentLoading.dart';
import 'components/DownloadInfoCard.dart';

// 下载列表
class DownloadListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DownloadListScreenState();
}

class _DownloadListScreenState extends State<DownloadListScreen> {
  DownloadComic? _downloading;
  late bool _downloadRunning = false;
  late StreamSubscription<dynamic> _sub;
  late Future<List<DownloadComic>> _f = pica.allDownloads();

  @override
  void initState() {
    _sub = eventChannel.receiveBroadcastStream(
        {"function": "DOWNLOAD", "id": "DOWNLOAD_LIST"}).listen(
      (event) {
        print("EVENT");
        print(event);
        if (event is String) {
          try {
            setState(() {
              _downloading = DownloadComic.fromJson(json.decode(event));
            });
          } catch (e, s) {
            print(e);
            print(s);
          }
        }
      },
    );
    pica
        .downloadRunning()
        .then((val) => setState(() => _downloadRunning = val));
    super.initState();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('下载列表'),
        actions: [
          ...(Platform.isWindows ||
                  Platform.isMacOS ||
                  Platform.isLinux ||
                  Platform.isAndroid ||
                  Platform.isIOS)
              ? [
                  MaterialButton(
                      minWidth: 0,
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DownloadImportScreen(),
                          ),
                        );
                        setState(() {
                          _f = pica.allDownloads();
                        });
                      },
                      child: Column(
                        children: [
                          Expanded(child: Container()),
                          Icon(
                            Icons.label_important,
                            size: 18,
                            color: Colors.white,
                          ),
                          Text(
                            '导入',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          Expanded(child: Container()),
                        ],
                      )),
                ]
              : [],
          MaterialButton(
              minWidth: 0,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('下载任务'),
                      content: Text(
                        _downloadRunning ? "暂停下载吗?" : "启动下载吗?",
                      ),
                      actions: [
                        MaterialButton(
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          child: Text('取消'),
                        ),
                        MaterialButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            var to = !_downloadRunning;
                            // properties.saveDownloading(to);
                            await pica.setDownloadRunning(to);
                            setState(() {
                              _downloadRunning = to;
                            });
                          },
                          child: Text('确认'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Column(
                children: [
                  Expanded(child: Container()),
                  Icon(
                    _downloadRunning
                        ? Icons.compare_arrows_sharp
                        : Icons.schedule_send,
                    size: 18,
                    color: Colors.white,
                  ),
                  Text(
                    _downloadRunning ? '下载中' : '暂停中',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Expanded(child: Container()),
                ],
              )),
          MaterialButton(
              minWidth: 0,
              onPressed: () async {
                await pica.resetFailed();
                setState(() {
                  _f = pica.allDownloads();
                });
                defaultToast(context, "所有失败的下载已经恢复");
              },
              child: Column(
                children: [
                  Expanded(child: Container()),
                  Icon(
                    Icons.sync_problem,
                    size: 18,
                    color: Colors.white,
                  ),
                  Text(
                    '恢复',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Expanded(child: Container()),
                ],
              )),
        ],
      ),
      body: FutureBuilder(
        future: _f,
        builder: (BuildContext context,
            AsyncSnapshot<List<DownloadComic>> snapshot) {
          if (snapshot.hasError) {
            print("${snapshot.error}");
            print("${snapshot.stackTrace}");
            return Center(child: Text('加载失败'));
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return ContentLoading(label: '加载中');
          }

          var data = snapshot.data!;

          if (_downloading != null) {
            print(_downloading);
            try {
              for (var i = 0; i < data.length; i++) {
                if (_downloading!.id == data[i].id) {
                  data[i].copy(_downloading!);
                }
              }
            } catch (e, s) {
              print(e);
              print(s);
            }
          }

          return ListView(
            children: [
              ...data.map(
                (e) => InkWell(
                  onTap: () {
                    if (e.deleting) {
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DownloadInfoScreen(
                          comicId: e.id,
                          comicTitle: e.title,
                        ),
                      ),
                    );
                  },
                  onLongPress: () async {
                    String? action =
                        await chooseListDialog(context, e.title, ['删除']);
                    if (action == '删除') {
                      await pica.deleteDownloadComic(e.id);
                      setState(() => e.deleting = true);
                    }
                  },
                  child: DownloadInfoCard(
                    task: e,
                    downloading:
                        _downloading != null && _downloading!.id == e.id,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
