// import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//         // This makes the visual density adapt to the platform that you run
//         // the app on. For desktop platforms, the controls will be smaller and
//         // closer together (more dense) than on mobile platforms.
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(title: 'Core Temp Reading'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);
//   FlutterBlue flutterBlue = FlutterBlue.instance;
//   final List<BluetoothDevice> deviceList = new List<BluetoothDevice>();
//   final Map<Guid,List<int>> readValues = new Map<Guid,List<int>>();
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//   _addDevice(final BluetoothDevice device){
//     if(!widget.deviceList.contains(device)){
//       setState((){
//         widget.deviceList.add(device);
//     });
//     }
//   }

//   @override
//   void initState(){
//     super.initState();
//     widget.flutterBlue.connectedDevices.asStream().listen((List<BluetoothDevice> devices){
//       for (BluetoothDevice device in devices){
//         _addDevice(device);
//       }
//     });
//     widget.flutterBlue.scanResults.listen((List<ScanResult>results){
//       for (ScanResult result in results){
//         _addDevice(result.device);
//       }
//     });
//     widget.flutterBlue.startScan();
//   }
//   ListView _buildView(){
//     if(_connectedDevice!=null){
//       return _buildConnectDeviceView();
//     }
//     return _buildDeviceList();
//   }
//   ListView _buildDeviceList(){
//     List<Container> containers = new List<Container>();
//     for (BluetoothDevice device in widget.deviceList){
//       containers.add(
//         Container(
//           height:50,
//           child:Row(
//             children:<Widget>[
//               Expanded(
//                 child: Column(
//                   children: <Widget>[
//                     Text(device.name =="?'(unknown device)':device.name"),
//                     Text(device.id.toString()),
//                   ],
//                 ),
//               ),
//               FlatButton(
//                 color: Colors.blue,
//                 child: Text(
//                 'Connect',
//                 style:TextStyle(color:Colors.white),
//               ),
//               onPressed: (){
//                   setState(() async{
//                     widget.flutterBlue.stopScan();
//                     try{
//                       await device.connect();
//                     }
//                     catch(e){
//                       if(e.code!='already_connected') {
//                         throw e;
//                       }
//                     }
//                     finally{
//                       _services= await device.discoverServices();
//                     }
//                     _connectedDevice = device;
//                   });
//               },
//               )
//             ],
//           ),
//         ),
//       );
//     }
//     return ListView(
//       padding:const EdgeInsets.all(8),
//       children:<Widget>[
//         ...containers,
//       ]
//     );
//   }
//   ListView _buildConnectedView(){

//     return ListView(
//       padding:const EdgeInsets.all(8),
//       children:<Widget>[
//                 Text(
//                  'Current Temp:',
//                  style: Theme.of(context).textTheme.headline5,
//                 ),
//                 Text(
//                    widget.readValues[characteristic.uuid].toString() +'  °C',
//                    style: Theme.of(context).textTheme.headline3),
//               ],
//     );
//   }
//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   // This method is rerun every time setState is called, for instance as done
//   //   // by the _incrementCounter method above.
//   //   //
//   //   // The Flutter framework has been optimized to make rerunning build methods
//   //   // fast, so that you can just rebuild anything that needs updating rather
//   //   // than having to individually change instances of widgets.
//   //   return Scaffold(
//   //     appBar: AppBar(
//   //       // Here we take the value from the MyHomePage object that was created by
//   //       // the App.build method, and use it to set our appbar title.
//   //       title: Text(widget.title),
//   //     ),
//   //     body: Center(
//   //       // Center is a layout widget. It takes a single child and positions it
//   //       // in the middle of the parent.
//   //       child: Column(
//   //         // Column is also a layout widget. It takes a list of children and
//   //         // arranges them vertically. By default, it sizes itself to fit its
//   //         // children horizontally, and tries to be as tall as its parent.
//   //         //
//   //         // Invoke "debug painting" (press "p" in the console, choose the
//   //         // "Toggle Debug Paint" action from the Flutter Inspector in Android
//   //         // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//   //         // to see the wireframe for each widget.
//   //         //
//   //         // Column has various properties to control how it sizes itself and
//   //         // how it positions its children. Here we use mainAxisAlignment to
//   //         // center the children vertically; the main axis here is the vertical
//   //         // axis because Columns are vertical (the cross axis would be
//   //         // horizontal).
//   //         mainAxisAlignment: MainAxisAlignment.center,
//   //         children: <Widget>[
//   //           Text(
//   //             'Current Temp:',
//   //             style: Theme.of(context).textTheme.headline5,
//   //           ),
//   //           Text(
//   //             '$_counter  °C',
//   //             style: Theme.of(context).textTheme.headline3,
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //     floatingActionButton: FloatingActionButton(
//   //       onPressed: _incrementCounter,
//   //       tooltip: 'Increment',
//   //       child: Icon(Icons.add),
//   //     ), // This trailing comma makes auto-formatting nicer for build methods.
//   //   );
//   // }
//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(
//       title:Text(widget.title),
//     ),
//     body:_buildView(),
//   );
// }

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'BLE Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Flutter BLE Demo'),
      );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _writeController = TextEditingController();
  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  ListView _buildListViewOfDevices() {
    List<Container> containers = new List<Container>();
    for (BluetoothDevice device in widget.devicesList) {
      containers.add(
        Container(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(device.name == '' ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              FlatButton(
                color: Colors.blue,
                child: Text(
                  'Connect',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  widget.flutterBlue.stopScan();
                  try {
                    await device.connect();
                  } catch (e) {
                    if (e.code != 'already_connected') {
                      throw e;
                    }
                  } finally {
                    _services = await device.discoverServices();
                  }
                  setState(() {
                    _connectedDevice = device;
                  });
                },
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  List<ButtonTheme> _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic) {
    List<ButtonTheme> buttons = new List<ButtonTheme>();

    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              color: Colors.blue,
              child: Text('READ', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                var sub = characteristic.value.listen((value) {
                  setState(() {
                    widget.readValues[characteristic.uuid] = value;
                  });
                });
                await characteristic.read();
                sub.cancel();
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              child: Text('WRITE', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Write"),
                        content: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _writeController,
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Send"),
                            onPressed: () {
                              characteristic.write(
                                  utf8.encode(_writeController.value.text));
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              child: Text('NOTIFY', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                characteristic.value.listen((value) {
                  widget.readValues[characteristic.uuid] = value;
                });
                await characteristic.setNotifyValue(true);
              },
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  ListView _buildConnectDeviceView() {
    List<Container> containers = new List<Container>();

    for (BluetoothService service in _services) {
      List<Widget> characteristicsWidget = new List<Widget>();

      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(characteristic.uuid.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    ..._buildReadWriteNotifyButton(characteristic),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Value: ' +
                        widget.readValues[characteristic.uuid].toString()),
                  ],
                ),
                Divider(),
              ],
            ),
          ),
        );
      }
      containers.add(
        Container(
          child: ExpansionTile(
              title: Text(service.uuid.toString()),
              children: characteristicsWidget),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    }
    return _buildListViewOfDevices();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: _buildView(),
      );
}