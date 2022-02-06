import 'dart:async';

import 'package:flutter/material.dart';

import '../files_handler/resorts_storage.dart';

class SideBar extends StatefulWidget {
  final StreamController<String> currentResortController;

  const SideBar({Key? key, required this.currentResortController}) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  var resortsInfo = [];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<List<DataResort>>(
          future: ResortsStorage.resortsData(),
          builder: (context, snapshot) {
            print('snapshot: ${snapshot.data}');
            print('resortsInfo: ${resortsInfo}');
            if (resortsInfo.isEmpty) {
              resortsInfo = snapshot.data ?? [];
            }
            return ListView(
              children: [
                DrawerHeader(
                  child: Container(
                    width: 90,
                    height: 90,
                    color: Colors.transparent,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    image: DecorationImage(fit: BoxFit.fill, image: NetworkImage('https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')),
                  ),
                ),
                for (var i = 0; i < resortsInfo.length; i++)
                  ListTile(
                    leading: const Icon(Icons.favorite),
                    title: Text(resortsInfo[i].fileName),
                    onTap: () {
                      if (resortsInfo[i].isLoaded) {
                        Navigator.pop(context);
                        widget.currentResortController.add(resortsInfo[i].fileName);
                      } else {
                        if (!resortsInfo[i].isLoading) {
                          resortsInfo[i].isLoading = true;
                          ResortsStorage.downloadResort('resorts_' + resortsInfo[i].fileName);
                          setState(() {});
                        }
                      }
                    },
                    trailing: ClipOval(
                      child: Container(
                        color: Colors.transparent,
                        width: 20,
                        height: 20,
                        child: Center(
                          child: resortsInfo[i].isLoading
                              ? const SizedBox(width: 30, height: 30, child: CircularProgressIndicator())
                              : (!resortsInfo[i].isLoaded)
                                  ? const Icon(Icons.arrow_downward)
                                  : (((resortsInfo[i].isLastVersion) ? const Icon(Icons.wifi_protected_setup) : (Container()))),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
    );
  }
}
