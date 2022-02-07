import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pistes/files_handler/resorts_storage.dart';

class SearchField extends StatefulWidget {
  final StreamController<String> mapController;

  const SearchField({Key? key, required this.mapController}) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {
        showSearch(
          context: context,
          delegate: CustomSearchDelegate(widget.mapController),
        );
      },
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final StreamController<String> mapController;

  CustomSearchDelegate(this.mapController);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    var res = ResortsStorage.allResorts().where((element) => element.contains(query)).toList();

    return Builder(
      builder: (context) {
        if (res.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(child: CircularProgressIndicator()),
            ],
          );
        } else if (res.length == 0) {
          return Column(
            children: <Widget>[
              Text(
                "No Results Found.",
              ),
            ],
          );
        } else {
          var results = res;
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              var result = results[index];
              return ListTile(
                title: Text(result),
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return FutureBuilder<List<DataResort>>(
        future: ResortsStorage.resortsDataList(),
        builder: (context, resortsSnapshot) {
          var res = (resortsSnapshot.data ?? []).where((element) => element.fileName.contains(query)).toList();
          return ListView.builder(
            itemCount: res.length,
            itemBuilder: (context, index) {
              var resortName = res[index].fileName;
              return ListTile(
                leading: const Icon(Icons.favorite),
                title: Text(resortName),
                onTap: () async {
                  if (res[index].isLoaded) {
                    mapController.add('camera ${res[index].point.latitude} ${res[index].point.longitude}');
                  }
                  Navigator.pop(context);
                },
                trailing: ClipOval(
                  child: Container(
                    color: Colors.transparent,
                    width: 20,
                    height: 20,
                    child: Center(
                      child: (!res[index].isLoaded)
                          ? const Icon(Icons.arrow_downward)
                          : ((res[index].isLastVersion) ? const Icon(Icons.wifi_protected_setup) : (Container())),
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}
