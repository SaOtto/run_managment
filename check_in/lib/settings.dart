import 'dart:convert';
import 'dart:io';

import 'package:check_in/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final String? note;
  final String currentFolder;
  final String currentRunName;
  final String currentLength;
  final bool asc;
  const SettingsPage(
      {Key? key,
      this.note,
      required this.currentFolder,
      required this.asc,
      required this.currentRunName,
      required this.currentLength})
      : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var controller = TextEditingController();
  var pathLengthController = TextEditingController();
  var runNameController = TextEditingController();
  int val = 1;

  @override
  initState() {
    super.initState();
    controller.text = widget.currentFolder;
    runNameController.text = widget.currentRunName;
    pathLengthController.text = widget.currentLength;
    widget.asc ? val = 2 : val = 1;
  }

  void pickFile() async {
    var selectedDir = await FilePicker.platform.getDirectoryPath();
    selectedDir ??= 'data';
    controller.text = selectedDir;
  }

  void store() async {
    var conf = {
      'count': val == 1 ? 'desc' : 'asc',
      'dataFolder': controller.text != '' ? controller.text : 'data.csv',
      'runName': runNameController.text,
      'pathLength': pathLengthController.text.split(';')
    };
    var file = File('.config');
    await file.writeAsString(jsonEncode(conf));
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyHomePage()));
  }

  Widget buildRadioButtons() {
    return Row(
      children: [
        const Expanded(child: Text('Sortierung der Startnummern:')),
        Expanded(
            child: ListTile(
          title: const Text("Absteigend"),
          leading: Radio(
            value: 1,
            groupValue: val,
            onChanged: (int? value) {
              setState(() {
                if (value != null) {
                  val = value;
                }
              });
            },
          ),
        )),
        Expanded(
            child: ListTile(
          title: const Text("Aufsteigend"),
          leading: Radio(
            value: 2,
            groupValue: val,
            onChanged: (int? value) {
              setState(() {
                if (value != null) {
                  val = value;
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
        child: Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        children: [
          if (widget.note != null) Text(widget.note!),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: Text('Datenordner:')),
              Expanded(
                  child: TextFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Ordner-Pfad'),
                controller: controller,
              )),
              const SizedBox(
                width: 100,
              ),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: pickFile,
                  icon: const Icon(Icons.folder),
                  label: const Text('Ordner wählen'),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          buildRadioButtons(),
          const SizedBox(
            height: 40,
          ),
          TextFormField(
            controller: runNameController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), labelText: 'Veranstaltungsname'),
          ),
          const SizedBox(
            height: 40,
          ),
          TextFormField(
            controller: pathLengthController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText:
                    'Liste der verfügbaren Streckenlängen, getrennt mit Semikolon'),
          )
        ],
      ),
    ));
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
                        currentLength: widget.currentLength,
                        currentRunName: widget.currentRunName,
                        asc: widget.asc,
                        currentFolder: widget.currentFolder,
                      )));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      drawer: buildDrawer(),
      body: SingleChildScrollView(child: buildForm()),
      persistentFooterButtons: [
        TextButton(onPressed: store, child: const Text('Speichern'))
      ],
    );
  }
}
