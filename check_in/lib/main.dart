import 'dart:convert';
import 'dart:io';

import 'package:check_in/settings.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anmeldung',
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
  late Future<bool> initF;
  final _formKey = GlobalKey<FormState>();
  final familyNameController = TextEditingController();
  final givenNameController = TextEditingController();
  final birthYearController = TextEditingController();
  final groupController = TextEditingController();
  final ageGroupController = TextEditingController();
  final startNumberController = TextEditingController();
  int val = 1;

  late String dataFolder;
  bool asc = false;

  String runName = '';
  dynamic lengthList = [];

  final FocusNode _focus = FocusNode();
  final FocusNode _firstLine = FocusNode();
  bool oldFocus = false;

  String pathSep = '/';

  List<DropdownMenuItem<String>> menuItems = [];
  String selectedLength = '2,5km';

  int startNumber = 0;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
    startNumberController.text = startNumber.toString();
    initF = init();
  }

  Future<bool> init() async {
    var configFile = File('.config');

    if (configFile.existsSync()) {
      var configString = await configFile.readAsString();
      var config = jsonDecode(configString);
      dataFolder = config['dataFolder'] ?? 'data';
      var count = config['count'];
      if (count == 'asc') asc = true;
      runName = config['runName'] ?? '';
      lengthList = config['pathLength'] ?? [];
    } else {
      dataFolder = 'data';
      lengthList = [];
    }

    if (lengthList is! List || lengthList.isEmpty) {
      lengthList = ['2,5km', '5km', '10km'];
    }

    print(lengthList);
    print(lengthList.runtimeType);
    menuItems = [];
    for (var l in lengthList) {
      menuItems.add(DropdownMenuItem<String>(
        child: Text(l),
        value: l,
      ));
    }

    selectedLength = lengthList.first;
    print(selectedLength);

    var dataFolderFile = Directory(dataFolder);
    print(dataFolderFile.path);
    print(dataFolderFile.existsSync());
    if (!dataFolderFile.existsSync()) {
      await dataFolderFile.create();
    }

    if (Platform.isWindows) {
      pathSep = '\\';
    }

    return true;
  }

  void _onFocusChange() {
    if (_focus.hasFocus && !oldFocus) {
      oldFocus = true;
    } else if (!_focus.hasFocus && oldFocus) {
      ageGroupController.text = calculateAge();
    }
  }

  String calculateAge() {
    var year = birthYearController.text;
    if (year.isNotEmpty && year.length == 4) {
      try {
        var birthYear = int.parse(year);
        var age = DateTime.now().year - birthYear;

        String maleFemale = 'M';
        if (val == 2) maleFemale = 'W';

        if (age < 10) {
          return "${maleFemale.toLowerCase()}U10";
        } else if (age < 12) {
          return "${maleFemale.toLowerCase()}U12";
        } else if (age < 14) {
          return "${maleFemale.toLowerCase()}U14";
        } else if (age < 16) {
          return "${maleFemale.toLowerCase()}U16";
        } else if (age < 18) {
          return "${maleFemale.toLowerCase()}U18";
        } else if (age < 20) {
          return "${maleFemale.toLowerCase()}U20";
        } else if (age < 30) {
          return "${maleFemale}20";
        } else if (age < 35) {
          return "${maleFemale}30";
        } else if (age < 40) {
          return "${maleFemale}35";
        } else if (age < 45) {
          return "${maleFemale}40";
        } else if (age < 50) {
          return "${maleFemale}45";
        } else if (age < 55) {
          return "${maleFemale}50";
        } else if (age < 60) {
          return "${maleFemale}55";
        } else if (age < 65) {
          return "${maleFemale}60";
        } else if (age < 70) {
          return "${maleFemale}65";
        } else if (age < 75) {
          return "${maleFemale}70";
        } else if (age < 80) {
          return "${maleFemale}75";
        } else {
          return "${maleFemale}80+";
        }
      } catch (e) {}
    }
    return '';
  }

  Widget buildRadioButtons() {
    return Row(
      children: [
        Expanded(
            child: ListTile(
          title: const Text("Männlich"),
          leading: Radio(
            value: 1,
            groupValue: val,
            onChanged: (int? value) {
              setState(() {
                if (value != null) {
                  val = value;
                  ageGroupController.text = calculateAge();
                }
              });
            },
          ),
        )),
        Expanded(
            child: ListTile(
          title: const Text("Weiblich"),
          leading: Radio(
            value: 2,
            groupValue: val,
            onChanged: (int? value) {
              setState(() {
                if (value != null) {
                  val = value;
                  ageGroupController.text = calculateAge();
                }
              });
            },
          ),
        )),
      ],
    );
  }

  Widget buildForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: <Widget>[
            DropdownButtonFormField(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              value: selectedLength,
              items: menuItems,
              onChanged: (String? newValue) {
                setState(() {
                  selectedLength = newValue!;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              focusNode: _firstLine,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Vorname eintragen'),
              controller: givenNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vorname eintragen';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nachname eintragen'),
              controller: familyNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nachname eintragen';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            buildRadioButtons(),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Geburtsjahr eintragen'),
              controller: birthYearController,
              focusNode: _focus,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Geburtsjahr eintragen';
                }
                if (value.length != 4) return 'Keine gültige Jahreszahl';
                try {
                  int.parse(value);
                } catch (e) {
                  return 'Keine gültige Jahreszahl';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Altersklasse eintragen'),
              controller: ageGroupController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Altersklasse eintragen';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Laufgruppe eintragen'),
              controller: groupController,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Startnummer eintragen'),
              controller: startNumberController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Geburtsjahr eintragen';
                }
                try {
                  int.parse(value);
                } catch (e) {
                  return 'Keine gültige Startnummer';
                }
                return null;
              },
            )
          ],
        ),
      ),
    );
  }

  void save() async {
    if (_formKey.currentState!.validate()) {
      var file = File('$dataFolder$pathSep$selectedLength.txt');

      await file.writeAsString(
          '${startNumberController.text};$selectedLength;${ageGroupController.text};${familyNameController.text};${givenNameController.text};${groupController.text};${birthYearController.text}\r\n',
          mode: FileMode.append);
      if (asc) {
        startNumber = int.parse(startNumberController.text) + 1;
      } else {
        startNumber = int.parse(startNumberController.text) - 1;
      }
      delete();
    }
  }

  void delete() {
    familyNameController.text = '';
    givenNameController.text = '';
    ageGroupController.text = '';
    birthYearController.text = '';
    groupController.text = '';
    startNumberController.text = startNumber.toString();
    val = 1;
    _firstLine.requestFocus();
    setState(() {});
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
            title: const Text('Anmeldung'),
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
                        currentRunName: runName,
                        currentLength: lengthList.join(';'),
                        asc: asc,
                        currentFolder: dataFolder,
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
        future: initF,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Anmeldung $runName ${DateTime.now().year}'),
              ),
              drawer: buildDrawer(),
              body: SingleChildScrollView(child: buildForm()),
              persistentFooterButtons: [
                TextButton(
                  onPressed: save,
                  child:
                      const Text('Speichern', style: TextStyle(fontSize: 25)),
                ),
                TextButton(
                    onPressed: delete,
                    child:
                        const Text('Löschen', style: TextStyle(fontSize: 25))),
              ], // This trailing comma makes auto-formatting nicer for build methods.
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Laden'),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}
