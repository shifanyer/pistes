import 'dart:async';

import 'package:flutter/material.dart';

import '../osm_map/default_map.dart';

class SideBar extends StatelessWidget {
  final StreamController<String> currentResortController;

  const SideBar({Key? key, required this.currentResortController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
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
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {
              currentResortController.add('Sheregesh');
              Navigator.pop(context);
            },
            trailing: ClipOval(
              child: Container(
                color: Colors.red,
                width: 20,
                height: 20,
                child: const Center(
                  child: Text(
                    '8',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
