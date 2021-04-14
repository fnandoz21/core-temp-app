import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';

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
  Queue temps = new Queue.from([[1.0, DateTime.now()]]);
  //Queue temps = new Queue();
  List<BluetoothDevice> devicesList = [];
  int weirdLeadingDigit = 0;
  int maxPlotPoints = 8;
  int tempsQSize = 20; //display over 40 seconds
  Future<void> getpaireddevices() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    } on PlatformException {
      print("platform exception");
    }
    setState(() {
      devicesList = devices;
      for (int i = 0; i < devices.length; i++) {
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
        BluetoothConnection connection =
            await BluetoothConnection.toAddress(_address);
        print('Connected to the device');

        connection.input.listen((Uint8List data) {
          double thisPoint;
          //print('Data incoming: ${ascii.decode(data)}');
          if (data.length == 1) {
            try {
              weirdLeadingDigit = int.parse(ascii.decode(data));
            } on FormatException {
              print('Expected Numerical string, got ${ascii.decode(data)}');
            }
          } else if (data.length == 5) {

            try {
              thisPoint =
                  double.parse(ascii.decode(data)) + 10 * weirdLeadingDigit;
            }catch(exception){
              thisPoint = temps.last.elementAt(0);
            }
            var now = DateTime.now();
            String nowTime = DateFormat.Hms().format(now);
            //print(nowTime);
            print(ascii.decode(data));
            setState(() {
              temps.add([thisPoint, nowTime]);
              if (temps.length > tempsQSize) {
                temps.removeFirst();
              }
            });
          } else {
            try {
              thisPoint = double.parse(ascii.decode(data));
            } catch(exception){
              thisPoint = temps.last.elementAt(0);
            }
            var now = DateTime.now();
            String nowTime = DateFormat.Hms().format(now);

            print(ascii.decode(data));
            setState(() {
              temps.add([thisPoint, nowTime]);
              if (temps.length > tempsQSize) {
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
      } catch (exception) {
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

  void appendTemp(tempChar) async {
    await tempChar.setNotifyValue(true);
    tempChar.value.listen((value) {
      setState(() {
        var temp = value[0].toDouble() / 100;
        temps.add(temp);
        if (temps.length > tempsQSize) {
          temps.removeFirst();
        }
      });
    });
  }

  ListView _buildConnectDeviceView() {
    List<Container> containers = new List<Container>();

    // for (BluetoothService service in _services) {
    //   List<Widget> characteristicsWidget = new List<Widget>();
    //   for (BluetoothCharacteristic characteristic in service.characteristics) {
    containers.add(Container(
        padding: EdgeInsets.all(10.0),
        child: Text(
          temps.last.elementAt(0).toString() + '°C',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
          textScaleFactor: 5.0,
        )));
    List<FlSpot> tempData = List.generate(temps.length, (index) {
      return FlSpot(index.toDouble(), temps.elementAt(index).elementAt(0));
    });
    containers.add(Container(
        padding: EdgeInsets.all(10),
        width: double.infinity,
        child: LineChart(LineChartData(
            borderData: FlBorderData(show: false),
            lineBarsData: [LineChartBarData(spots: tempData)],
            titlesData: FlTitlesData(
              bottomTitles: SideTitles(
                showTitles: true,
                getTitles: (val) {
                  if(temps.length<5){
                    temps.elementAt(val.toInt()).elementAt(1);
                    return temps.elementAt(val.toInt()).elementAt(1);
                  }
                  else if (val.toInt() % (temps.length~/5) == 0) {

                    return temps.elementAt(val.toInt()).elementAt(1);
                  }
                  else {
                    return '';
                  }
                }
              ))),
            )));
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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Core Temp"),
        ),
        body: _buildView(),
      );
}