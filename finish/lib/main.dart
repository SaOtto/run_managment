import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;

import '../certificate.dart';
import '../settings.dart';

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
  final Map<String, Map<String, List<Runner>>> _ageGroupedList = {};
  late Future<bool> _initF;
  late String _certFileName, _finalInfoName;
  late List<String> _currentDataFiles, _currentTimeFile;
  late String pathSep;

  String runName = '';
  String runPlace = '';

  @override
  initState() {
    super.initState();
    if (Platform.isWindows) {
      pathSep = '\\';
    } else {
      pathSep = '/';
    }
    _initF = init();
  }

  Future<bool> init() async {
    try {
      var configFile = File('.config');
      var configString = await configFile.readAsString();
      var config = jsonDecode(configString);
      _certFileName = config['certfile'] ?? 'urkunden.pdf';
      _finalInfoName = config['evaluation'] ?? 'auswertung.csv';
      _currentDataFiles = config['data'].cast<String>();
      _currentTimeFile = config['time'].cast<String>();

      runName = config['runName'] ?? '';
      runPlace = config['runPlace'] ?? 'Sachsen';

      Map<String, List<String>> timeData = {};
      Map<String, List<String>> timeData2 = {};
      // Convert stream to individual lines.

      for (var timeName in _currentTimeFile) {
        var timeFile = File(timeName);
        Stream<String> lines = timeFile
            .openRead()
            .transform(utf8.decoder) // Decode bytes to UTF-8.
            .transform(const LineSplitter());
        await for (var line in lines) {
          var splited = line.split(';');
          if (splited.length == 3) {
            var key = splited.removeAt(0);
            var km = splited.removeAt(0);
            if (!(timeData.containsKey('${key}_$km'))) {
              timeData['${key}_$km'] = splited;
            } else {
              timeData2['${key}_$km'] = splited;
            }
          }
        }
      }
      for (var filename in _currentDataFiles) {
        var baseDataFile = File(filename);
        Stream<String> lines2 = baseDataFile
            .openRead()
            .transform(utf8.decoder) // Decode bytes to UTF-8.
            .transform(
                const LineSplitter()); // Convert stream to individual lines.

        await for (var line in lines2) {
          var splited = line.split(';');
          var r = Runner(splited[0], splited[4], splited[3], splited[2],
              splited[6], splited[1], splited[5]);
          Map<String, List<Runner>> kmList = _ageGroupedList[r.runLength] ?? {};
          List<Runner> ageList = kmList[r.ageGroup] ?? [];
          if (timeData.containsKey('${r.startNumber}_${r.runLength}')) {
            r.addTime(
                int.parse(timeData['${r.startNumber}_${r.runLength}']!.last));
          }
          ageList.add(r);
          kmList[r.ageGroup] = ageList;
          _ageGroupedList[r.runLength] = kmList;
        }
      }
      return true;
    } catch (e) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const SettingsPage(
                oldRunPlace: '',
                oldRunName: '',
                currentDataFiles: [],
                currentTimeFile: [],
                oldInfo: 'auswertung.csv',
                oldCert: 'urkunden.pdf',
              )));
      return false;
    }
  }

  Widget buildAgeGroupList(String km) {
    List<Widget> children = [];
    _ageGroupedList[km]!.forEach((key, value) {
      var w = ExpansionTile(
        title: Text(key),
        children: buildListContent(value),
      );
      children.add(w);
    });
    return SingleChildScrollView(
      child: Column(
        children: children,
      ),
    );
  }

  List<Widget> buildListContent(List<Runner> runners) {
    List<Widget> widgetList = [];
    runners.sort();
    for (var r in runners) {
      var tile = ListTile(
        leading: Text(r.startNumber),
        title: Text('${r.givenName} ${r.familyName}'),
        subtitle: Text('Zeit: ${r.formattedTime ?? '---'}'),
      );
      widgetList.add(tile);
    }
    return widgetList;
  }

  Future<void> buildCerts() async {
    try {
      final pdf = pw.Document();
      _ageGroupedList.forEach((key, value) {
        value.forEach((key, value) {
          value.sort();

          int p = 1;
          for (var r in value) {
            if (p == 4) break;
            if (r.time != null) {
              pdf.addPage(buildCert(r, p, 'images${pathSep}picLeft.jpg',
                  'images${pathSep}picRight.jpg', runName, runPlace));
            }
            p++;
          }
        });
      });
      final file = File(_certFileName);
      file.createSync();
      await file.writeAsBytes(await pdf.save());
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Urkunden erfolgreich gespeichert')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern der Urkunden: $e')));
    }
  }

  Future<void> buildFinalInfo() async {
    try {
      var f = File(_finalInfoName);
      if (f.existsSync()) await f.delete();
      await f.create();
      _ageGroupedList.forEach((key, value) {
        f.writeAsStringSync('$key\r\n', mode: FileMode.append);
        value.forEach((key, value) {
          f.writeAsStringSync('$key\r\n', mode: FileMode.append);
          value.sort();
          int place = 1;
          for (var r in value) {
            f.writeAsStringSync(
                '$place;${r.startNumber};"${r.familyName}";"${r.givenName}";${r.birthYear};"${r.group}";"${r.formattedTime ?? '---'}";"${r.formattedTimeExcel ?? '---'}"\r\n',
                mode: FileMode.append);
            place++;
          }
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auswertung erfolgreich gespeichert')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern der Auswertung: $e')));
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
            title: const Text('Auswertung'),
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
                        oldRunPlace: runPlace,
                        oldRunName: runName,
                        currentDataFiles: _currentDataFiles,
                        currentTimeFile: _currentTimeFile,
                        oldInfo: _finalInfoName,
                        oldCert: _certFileName,
                      )));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initF,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            var kms = _ageGroupedList.keys.toList();
            return DefaultTabController(
              length: _ageGroupedList.length,
              child: Scaffold(
                drawer: buildDrawer(),
                appBar: AppBar(
                  title: Text('Auswertung $runName'),
                  bottom: TabBar(
                    tabs: List.generate(
                        kms.length,
                        (index) => Tab(
                              text: kms[index],
                            )),
                  ),
                ),
                body: TabBarView(
                  children: List.generate(
                      kms.length, (index) => buildAgeGroupList(kms[index])),
                ),
                persistentFooterButtons: [
                  TextButton(
                      onPressed: buildCerts,
                      child: const Text('Urkunden erstellen')),
                  TextButton(
                      onPressed: buildFinalInfo,
                      child: const Text('Auswertung erstellen'))
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Fehler')),
              body: Center(child: Text(snapshot.error!.toString())),
            );
          } else {
            return Scaffold(
                appBar: AppBar(title: const Text('Laden')),
                body: const Center(child: CircularProgressIndicator()));
          }
        });
  }
}

class Runner implements Comparable {
  String givenName;
  String familyName;
  String ageGroup;
  String birthYear;
  String runLength;
  String group;
  String startNumber;
  int? time;
  String? formattedTime;
  String? formattedTimeExcel;
  int? place;

  Runner(this.startNumber, this.givenName, this.familyName, this.ageGroup,
      this.birthYear, this.runLength, this.group);

  addTime(int time) {
    this.time = time;
    int millis = time % 1000;
    int secs = time ~/ 1000;
    int min = secs ~/ 60;
    secs %= 60;

    formattedTime =
        '${min.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}:${millis.toString().padLeft(3, '0')}';
    formattedTimeExcel =
        '${min.toString().padLeft(2, '0')}min ${secs.toString().padLeft(2, '0')}s ${millis.toString().padLeft(3, '0')}ms';
  }

  @override
  int compareTo(other) {
    if (time == null) return 1;
    if (other.time == null) return -1;
    if (other.time == time) return 0;
    if (other.time > time) {
      return -1;
    } else {
      return 1;
    }
  }
}
