import 'package:flutter/material.dart';


import 'package:shared_preferences/shared_preferences.dart';
import 'package:suprimidospt/constants/locations.dart';

class Favorites extends StatefulWidget {
  @override
  _FavoritesState createState() => new _FavoritesState();
}

class _FavoritesState extends State<Favorites> {

  List<Widget> checkboxes = [];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Map favorites = {};

  @override
  void initState() {
    super.initState();
    for (Map location in locations) {
      favorites[location['favorite_key']] = _prefs.then((SharedPreferences prefs) {
        return (prefs.getBool(location['favorite_key']) ?? true);
      });
    }
    favorites['favorite_all'] = _prefs.then((SharedPreferences prefs) {
      return (prefs.getBool('favorite_all') ?? true);
    });
  }

  List<Widget> _buildCheckboxes() {
    List<Widget> checkboxes = [];
    checkboxes.add(
      FutureBuilder(
        future: favorites['favorite_all'],
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          switch (snapshot.connectionState) {
            default:
              return CheckboxListTile(
                title: Text(
                  'Todas',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                value: snapshot.data ?? false,
                onChanged: (bool value) {
                  _handleChange('favorite_all', value);
                },
              );
          }
        },
      ),
    );

    checkboxes.add(Divider());
    for (Map location in locations) {
      checkboxes.add(
        FutureBuilder(
          future: favorites[location['key']],
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            switch (snapshot.connectionState) {
              default:
                return CheckboxListTile(
                  title: Text(location['value']),
                  value: snapshot.data ?? false,
                  onChanged: (bool value) {
                    _handleChange(location['key'], value);
                  },
                );
            }
          },
        ),
      );
    }

    return checkboxes;
  }


  _handleChange(key, bool value) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setBool(key, value);
    favorites[key] = _prefs.then((SharedPreferences prefs) {
      return (prefs.getBool(key) ?? value);
    });

    if (key == 'favorite_all') {
      for (Map location in locations) {
        prefs.setBool(location['key'], value);
        favorites[location['key']] = _prefs.then((SharedPreferences prefs) {
          return value;
        });
      }
    } else {
      if (value == false) {
        prefs.setBool('favorite_all', value);
        favorites['favorite_all'] = _prefs.then((SharedPreferences prefs) {
          return value;
        });
      } else {
        bool _allChecked = true;
        for (Map location in locations) {
          if (!prefs.getBool(location['key'])) {
            if (_allChecked) {
              _allChecked = false;
            }
          }
        }
        favorites['favorite_all'] = _prefs.then((SharedPreferences prefs) {
          return _allChecked;
        });
        prefs.setBool('favorite_all', _allChecked);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text(
          'Favoritos',
          style: TextStyle(color: Color(0xFFe9ecef)),
        ),
        backgroundColor: Color(0xFF343a40),
      ),
      body: Container(
        child: ListView(
          children: _buildCheckboxes(),
        ),
      ),
    );
  
  }

}
