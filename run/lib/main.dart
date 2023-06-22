import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:run/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? _start;
  late Future<bool> _initF;
  Map<String, Duration> times = {};
  Map<String, String> length = {};
  late String _timeDataPath;
  late List<String> _dataPaths;

  String runName = '';

  @override
  initState() {
    super.initState();
    _initF = init();
  }

  Future<bool> init() async {
    try {
      var configFile = File('.config');
      var configString = await configFile.readAsString();
      var config = jsonDecode(configString);
      _dataPaths = config['data'].cast<String>();
      _timeDataPath = config['time'];

      runName = config['runName'] ?? '';

      var timeFile = File(_timeDataPath);
      if (timeFile.existsSync() && timeFile.lengthSync() > 0) {
        bool readTime = true;
        Stream<String> linesT = timeFile
            .openRead()
            .transform(utf8.decoder) // Decode bytes to UTF-8.
            .transform(const LineSplitter());

        await for (var line in linesT) {
          if (readTime) {
            _start = DateTime.fromMillisecondsSinceEpoch(int.parse(line));
            print(_start);
            readTime = false;
            print(_start!.toIso8601String());
          } else {
            var splitted = line.split(';');
            times[splitted.first] =
                Duration(milliseconds: int.parse(splitted.last));
          }
        }
      }
      for (var path in _dataPaths) {
        var dataFile = File(path);
        Stream<String> lines = dataFile
            .openRead()
            .transform(utf8.decoder) // Decode bytes to UTF-8.
            .transform(
                const LineSplitter()); // Convert stream to individual lines.

        await for (var line in lines) {
          var splited = line.split(';');
          length[splited[0]] = splited[1];
        }
      }
      return true;
    } catch (e) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const SettingsPage(
                currentDataFiles: [],
                currentTimeFile: '',
              )));
      return false;
    }
  }

  Future<void> _store() async {
    try {
      var f = File(_timeDataPath);
      if (f.existsSync()) f.delete();
      await f.create();
      f.writeAsStringSync('${_start!.millisecondsSinceEpoch}\r\n');
      times.forEach((key, value) {
        f.writeAsStringSync('$key;${length[key]};${value.inMilliseconds}\r\n',
            mode: FileMode.append);
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Erfolgreich gespeichert'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Fehler beim Speichern: $e'),
      ));
    }
  }

  Drawer buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.orange,
            ),
            child: Text('Menü'),
          ),
          ListTile(
            title: const Text('Lauf'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MyHomePage()));
            },
          ),
          ListTile(
            title: const Text('Einstellungen'),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => SettingsPage(
                        currentDataFiles: _dataPaths,
                        currentTimeFile: _timeDataPath,
                      )));
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onWindowClose() async {
    await _store();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(runName),
      ),
      drawer: buildDrawer(),
      body: Center(
        child: FutureBuilder(
          future: _initF,
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              if (_start == null) {
                return ElevatedButton(
                    onPressed: () {
                      _start = DateTime.now();
                      setState(() {});
                    },
                    child: const Text('Start'));
              } else {
                var startNumbers = length.keys.toList();
                return Wrap(
                  children: List.generate(
                      startNumbers.length,
                      (index) => MyButton(
                          number: startNumbers[index],
                          times: times,
                          start: _start!)),
                );
              }
            } else if (snapshot.hasError) {
              return Text('Irgendwas ging schief:\n${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
      persistentFooterButtons: [
        TextButton(onPressed: _store, child: const Text('Speichern'))
      ],
    );
  }
}

class MyButton extends StatefulWidget {
  final String number;
  final Map<String, Duration> times;
  final DateTime start;

  const MyButton(
      {Key? key,
      required this.number,
      required this.times,
      required this.start})
      : super(key: key);

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool _showNumber = true;

  @override
  Widget build(BuildContext context) {
    if (widget.times.containsKey(widget.number)) _showNumber = false;
    return InkWell(
      onTap: () {
        if (_showNumber) {
          _showNumber = false;
          var runTime = DateTime.now().difference(widget.start);
          widget.times[widget.number] = runTime;
          setState(() {});
        }
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(
            minWidth: 100, minHeight: 50, maxHeight: 50, maxWidth: 100),
        child: Card(
          color: Colors.orangeAccent,
          child: Center(
              child: Text(
            _showNumber ? widget.number : '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          )),
        ),
      ),
    );
  }
}
