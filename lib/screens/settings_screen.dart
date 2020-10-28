import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mensa_jt21/online/online_service.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = "/settings";

  @override
  createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  OnlineMode _selectedOnlineMode;

  @override
  void initState() {
    super.initState();
    GetIt.instance.get<OnlineService>().registerModeListener((mode) {
      if (mounted)
        setState(() {
          _selectedOnlineMode = mode;
        });
      else
        _selectedOnlineMode = mode;
    });
    // TODO remove listener
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Einstellungen"),
      ),
      body: Column(
        children: [
          Row(children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Online Modus:"),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 16, 16),
              child: DropdownButton<OnlineMode>(
                value: _selectedOnlineMode,
                items: [
                  DropdownMenuItem<OnlineMode>(
                    value: OnlineMode.OFFLINE,
                    child: Text("Offline"),
                  ),
                  DropdownMenuItem<OnlineMode>(
                    value: OnlineMode.MANUAL,
                    child: Text("Manuell"),
                  ),
                  DropdownMenuItem<OnlineMode>(
                    value: OnlineMode.ON_DEMAND,
                    child: Text("Manuell / Automatisch"),
                  ),
                  DropdownMenuItem<OnlineMode>(
                    value: OnlineMode.AUTOMATIC,
                    child: Text("Automatisch / Manuell"),
                  ),
                  DropdownMenuItem<OnlineMode>(
                    value: OnlineMode.ONLINE,
                    child: Text("Automatisch"),
                  ),
                ],
                onChanged: (mode) {
                  GetIt.instance.get<OnlineService>().setOnlineMode(mode);
                },
              ),
            ),
          ]),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text(
              GetIt.instance.get<OnlineService>().getDescription(_selectedOnlineMode),
              softWrap: true,
              maxLines: 10,
            ),
          ),
        ],
      ),
    );
  }
}
