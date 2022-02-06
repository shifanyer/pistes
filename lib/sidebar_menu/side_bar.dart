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
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<List<DataResort>>(
          future: ResortsStorage.resortsData(),
          builder: (context, snapshot) {
            print('snapshot: ${snapshot.data}');
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

                for (DataResort resortInfo in snapshot.data ?? [])
                  ListTile(
                    leading: const Icon(Icons.favorite),
                    title: Text(resortInfo.fileName),
                    onTap: () {
                      Navigator.pop(context);
                      widget.currentResortController.add(resortInfo.fileName);
                      // if (resortInfo.isLoaded) {
                      //   widget.currentResortController.add(resortInfo.fileName);
                      // }
                    },
                    trailing: ClipOval(
                      child: Container(
                        color: Colors.transparent,
                        width: 20,
                        height: 20,
                        child: Center(
                          child: (!resortInfo.isLoaded)
                              ? const Icon(Icons.arrow_downward)
                              : ((resortInfo.isLastVersion) ? const Icon(Icons.wifi_protected_setup) : (Container())),
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
