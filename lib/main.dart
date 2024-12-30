import 'package:flutter/material.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';
import 'package:here_sdk/mapview.dart';

import 'data/models/Routing.dart';

void main() {
  // Usually, you need to initialize the HERE SDK only once during the lifetime of an application.
  _initializeHERESDK();

  // Ensure that all widgets, including MyApp, have a MaterialLocalizations object available.
  runApp(MaterialApp(home: MyApp()));
}

void _initializeHERESDK() async {
  // Needs to be called before accessing SDKOptions to load necessary libraries.
  SdkContext.init(IsolateOrigin.main);

    String accessKeyId = "nqLgpsRwElcuFRG7Lj95lg";
  String accessKeySecret = "TNEVUFlfWp99q2ie0Y4yq84w2WuvAZzntCZA0ck-NzMvuWlFm8RQ8Wmn9c2Vhpey5D-XcC0zRauQfg5Q1Zndag";
  AuthenticationMode authenticationMode =
      AuthenticationMode.withKeySecret(accessKeyId, accessKeySecret);
  SDKOptions sdkOptions = SDKOptions.withAuthenticationMode(authenticationMode);

  try {
    await SDKNativeEngine.makeSharedInstance(sdkOptions);
  } on InstantiationException {
    throw Exception("Failed to initialize the HERE SDK.");
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  RoutingHERE? _routingHERE;
  HereMapController? _hereMapController;
  final List<bool> _selectedTrafficOptimization = <bool>[true];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HERE SDK - Routing'),
      ),
      body: Stack(
        children: [
          HereMap(onMapCreated: _onMapCreated),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  button('Add Route', _addRouteButtonClicked),
                  button('Clear Map', _clearMapButtonClicked),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ToggleButtons(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Text(
                            _selectedTrafficOptimization[0]
                                ? 'Traffic Optimization-On'
                                : 'Traffic Optimization-OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ],
                      onPressed: (int index) {
                        _toggleTrafficOptimization();
                        setState(() {
                          _selectedTrafficOptimization[index] =
                          !_selectedTrafficOptimization[index];
                        });
                      },
                      isSelected: _selectedTrafficOptimization),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onMapCreated(HereMapController hereMapController) {
    _hereMapController = hereMapController;
    _hereMapController?.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
            (MapError? error) {
          if (error == null) {
            _hereMapController?.mapScene.enableFeatures(
                {MapFeatures.lowSpeedZones: MapFeatureModes.lowSpeedZonesAll});
            _routingHERE = RoutingHERE(_showDialog, hereMapController);
          } else {
            print("Map scene not loaded. MapError: " + error.toString());
          }
        });
  }

  void _toggleTrafficOptimization() {
    _routingHERE?.toggleTrafficOptimization();
  }

  void _addRouteButtonClicked() {
    _routingHERE?.addRoute();
  }

  void _clearMapButtonClicked() {
    _routingHERE?.clearMap();
  }

  @override
  void dispose() {
    // Free HERE SDK resources before the application shuts down.
    SDKNativeEngine.sharedInstance?.dispose();
    SdkContext.release();
    super.dispose();
  }

  // A helper method to add a button on top of the HERE map.
  Align button(String buttonLabel, Function callbackFunction) {
    return Align(
      alignment: Alignment.topCenter,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.lightBlueAccent,
        ),
        onPressed: () => callbackFunction(),
        child: Text(buttonLabel, style: TextStyle(fontSize: 20)),
      ),
    );
  }

  // A helper method to show a dialog.
  Future<void> _showDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}