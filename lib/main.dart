import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'BLE Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Core Body Temp'),
      );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  // final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  // final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "00:20:04:BD:18:5B";
  String _name = "CORE TEMP SENSOR";

  // Timer _discoverableTimeoutTimer;
  // int _discoverableTimeoutSecondsLeft = 0;

  final _writeController = TextEditingController();
  BluetoothDevice _connectedDevice;

  // List<BluetoothService> _services;
  //Queue temps = new Queue.from([1.0, 2.0, 3.0, 4.0, 5.0]);
  Queue temps = new Queue();
  List<BluetoothDevice> devicesList = [];
  int weirdLeadingDigit = 0;
  int maxPlotPoints = 8;
  Future<void> getpaireddevices() async{
    List<BluetoothDevice> devices = [];
    try{
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } on PlatformException{
      print("platform exception");
    }
    setState((){
      devicesList = devices;
      for(int i=0;i<devices.length;i++){
        print(devices[i].address);
      }
    });
  }
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


    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    getpaireddevices();
    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) async {
      // Some simplest connection :F
      try {
        BluetoothConnection connection = await BluetoothConnection.toAddress(
            _address);
        print('Connected to the device');

        connection.input.listen((Uint8List data) {
          //print('Data incoming: ${ascii.decode(data)}');
          if (data.length==1){
            try{
              weirdLeadingDigit = int.parse(ascii.decode(data));
            } on FormatException{
              print('Expected Numerical string, got ${ascii.decode(data)}');
            }
          }
          else if(data.length==5) {
            double thisPoint = double.parse(ascii.decode(data))+10*weirdLeadingDigit;
            var now = DateTime.now();
            print(thisPoint);
            setState((){
              temps.add([thisPoint,now]);
              if (temps.length > 1800) {
                temps.removeFirst();
              }
            });
          }
          else{
            double thisPoint = double.parse(ascii.decode(data));
            var now = DateTime.now();
            print(thisPoint);
            setState((){
              temps.add([thisPoint,now]);
              if (temps.length > 1800) {
                temps.removeFirst();
              }
            });
          }
         // print(ascii.decode(data));
          connection.output.add(data); // Sending data

          if (ascii.decode(data).contains('!')) {
            connection.finish(); // Closing connection
            print('Disconnecting by local host');
          }
        }).onDone(() {
          print('Disconnected by remote request');
        });
      }
      catch (exception) {
        print('Cannot connect, exception occurred');
      }
      // Update the address field
      // FlutterBluetoothSerial.instance.address.then((address) {
      //   setState(() {
      //     _address = address;
      //   });
      // });
    });

    // FlutterBluetoothSerial.instance.name.then((name) {
    //   setState(() {
    //     _name = name;
    //   });
    // });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        // _discoverableTimeoutTimer = null;
        // _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  // ListView _buildListViewOfDevices() {
  //   List<Container> containers = new List<Container>();
  //   for (BluetoothDevice device in widget.devicesList) {
  //     containers.add(
  //       Container(
  //         height: 50,
  //         child: Row(
  //           children: <Widget>[
  //             Expanded(
  //               child: Column(
  //                 children: <Widget>[
  //                   Text(device.name == '' ? '(unknown device)' : device.name),
  //                   Text(device.id.toString()),
  //                 ],
  //               ),
  //             ),
  //             FlatButton(
  //               color: Colors.blue,
  //               child: Text(
  //                 'Connect',
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //               onPressed: () async {
  //                 widget.flutterBlue.stopScan();
  //                 try {
  //                   await device.connect();
  //                 } catch (e) {
  //                   if (e.code != 'already_connected') {
  //                     throw e;
  //                   }
  //                 } finally {
  //                   _services = await device.discoverServices();
  //                 }
  //                 setState(() {
  //                   _connectedDevice = device;
  //                 });
  //               },
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }

  //   return ListView(
  //     padding: const EdgeInsets.all(8),
  //     children: <Widget>[
  //       ...containers,
  //       Text('123',
  //       textAlign: TextAlign.center,
  //       style: TextStyle(
  //       fontSize: 80,
  //       color: Colors.black,
  //       // foreground: Paint()
  //       //   ..style = PaintingStyle.stroke
  //       //   ..strokeWidth = 6
  //       //   ..color = Colors.blue,
  //     ),
  //       ),
  //       TextButton.icon(
  //         label: Text('START TEMP CHECK'),
  //         style: TextButton.styleFrom(
  //           primary: Colors.white,
  //           backgroundColor: Colors.blue,
  //           onSurface: Colors.grey,
  //           textStyle: TextStyle(fontSize: 20),
  //         ),
  //         icon: Icon(Icons.device_thermostat
  //         ),
  //         onPressed: () {
  //           print('no cap');
  //   }
  // )
  //     ],
  //   );
  // }

  // List<ButtonTheme> _buildReadWriteNotifyButton(
  //     BluetoothCharacteristic characteristic) {
  //   List<ButtonTheme> buttons = new List<ButtonTheme>();

  //   if (characteristic.properties.read) {
  //     buttons.add(
  //       ButtonTheme(
  //         minWidth: 10,
  //         height: 20,
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 4),
  //           child: RaisedButton(
  //             color: Colors.blue,
  //             child: Text('READ', style: TextStyle(color: Colors.white)),
  //             onPressed: () async {
  //               var sub = characteristic.value.listen((value) {
  //                 setState(() {
  //                   widget.readValues[characteristic.uuid] = value;
  //                 });
  //               });
  //               await characteristic.read();
  //               sub.cancel();
  //             },
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  //   if (characteristic.properties.write) {
  //     buttons.add(
  //       ButtonTheme(
  //         minWidth: 10,
  //         height: 20,
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 4),
  //           child: RaisedButton(
  //             child: Text('WRITE', style: TextStyle(color: Colors.white)),
  //             onPressed: () async {
  //               await showDialog(
  //                   context: context,
  //                   builder: (BuildContext context) {
  //                     return AlertDialog(
  //                       title: Text("Write"),
  //                       content: Row(
  //                         children: <Widget>[
  //                           Expanded(
  //                             child: TextField(
  //                               controller: _writeController,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       actions: <Widget>[
  //                         FlatButton(
  //                           child: Text("Send"),
  //                           onPressed: () {
  //                             characteristic.write(
  //                                 utf8.encode(_writeController.value.text));
  //                             Navigator.pop(context);
  //                           },
  //                         ),
  //                         FlatButton(
  //                           child: Text("Cancel"),
  //                           onPressed: () {
  //                             Navigator.pop(context);
  //                           },
  //                         ),
  //                       ],
  //                     );
  //                   });
  //             },
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  //   if (characteristic.properties.notify) {
  //     buttons.add(
  //       ButtonTheme(
  //         minWidth: 10,
  //         height: 20,
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 4),
  //           child: RaisedButton(
  //             child: Text('NOTIFY', style: TextStyle(color: Colors.white)),
  //             onPressed: () async {
  //               characteristic.value.listen((value) {
  //                 widget.readValues[characteristic.uuid] = value;
  //               });
  //               await characteristic.setNotifyValue(true);
  //             },
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   return buttons;
  // }

  // void setCharacteristic(){

  // }

  void appendTemp(tempChar) async {
    await tempChar.setNotifyValue(true);
    tempChar.value.listen((value) {
      setState(() {
        var temp = value[0].toDouble() / 100;
        temps.add(temp);
        if (temps.length > 1800) {
          temps.removeFirst();
        }
      });
    }
    );
  }

  ListView _buildConnectDeviceView() {
    List<Container> containers = new List<Container>();

    // for (BluetoothService service in _services) {
    //   List<Widget> characteristicsWidget = new List<Widget>();
    //   for (BluetoothCharacteristic characteristic in service.characteristics) {
    containers.add(
        Container(
            padding: EdgeInsets.all(10.0),
            child: Text(temps.last.toString() + '°C' ,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
              textScaleFactor: 5.0,
            )
        )
    );
    List<FlSpot> tempData = List.generate(temps.length, (index) {
      return FlSpot(index.toDouble(), temps.elementAt(index).elementAt(0));
    });
    containers.add(
        Container(
            padding: EdgeInsets.all(10),
            width: double.infinity,
            child: LineChart(LineChartData(
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                      spots: tempData
                  )
                ]
            ))
        )
    );
    //     characteristicsWidget.add(
    //       Align(
    //         alignment: Alignment.centerLeft,
    //         child: Column(
    //           children: <Widget>[
    //             Row(
    //               children: <Widget>[
    //                 Text(characteristic.uuid.toString(),
    //                     style: TextStyle(fontWeight: FontWeight.bold)),
    //               ],
    //             ),
    //             Row(
    //               children: <Widget>[
    //                 ..._buildReadWriteNotifyButton(characteristic),
    //               ],
    //             ),
    //             Row(
    //               children: <Widget>[
    //                 Text('Value: ' +
    //                     widget.readValues[characteristic.uuid].toString()),
    //               ],
    //             ),
    //             Divider(),
    //           ],
    //         ),
    //       ),
    //     );
    //   }
    //   containers.add(
    //     Container(
    //       child: ExpansionTile(
    //           title: Text(service.uuid.toString()),
    //           children: characteristicsWidget),
    //     ),
    //   );
    // }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  // }
  // NOTE: the if statement and secondary return are only to test UI as if a device were connected
  ListView _buildView() {
    //if (_connectedDevice != null) {
    return _buildConnectDeviceView();
    //  }
    // return _buildListViewOfDevices();
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(
          title: Text("Core Temp"),
        ),
        body: _buildView(),
      );
}