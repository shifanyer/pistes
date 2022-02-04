import 'dart:async';

import 'package:flutter/material.dart';

import '../osm_map/default_map.dart';
import 'resorts_storage.dart';

class SideBar extends StatelessWidget {
  final StreamController<String> currentResortController;

  const SideBar({Key? key, required this.currentResortController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<List<DataResort>>(
          future: ResortsStorage.resortsData(),
          builder: (context, snapshot) {
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
                      if (resortInfo.isLoaded) {
                        currentResortController.add(resortInfo.fileName);
                      }
                      Navigator.pop(context);
                    },
                    trailing: ClipOval(
                      child: Container(
                        color: Colors.transparent,
                        width: 20,
                        height: 20,
                        child: Center(
                          child: (!resortInfo.isLoaded)
                              ? const Icon(Icons.arrow_downward)
                              : ((!resortInfo.isLastVersion) ? const Icon(Icons.wifi_protected_setup) : (Container())),
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
