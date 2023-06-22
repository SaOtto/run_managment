import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:run/main.dart';

class SettingsPage extends StatefulWidget {
  final String? note;
  final String currentTimeFile;
  final List<String> currentDataFiles;
  const SettingsPage(
      {Key? key,
      this.note,
      required this.currentDataFiles,
      required this.currentTimeFile})
      : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var controller = TextEditingController();
  var dataFileController = TextEditingController();
  var runNameController = TextEditingController();
  var paths = [];

  @override
  initState() {
    super.initState();
    controller.text = widget.currentTimeFile;
    dataFileController.text = widget.currentDataFiles.toString();
    paths = widget.currentDataFiles;
  }

  void pickFiles() async {
    var selectedFiles =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (selectedFiles != null) {
      dataFileController.text = selectedFiles.paths.toString();
      paths = selectedFiles.paths;
    }
  }

  void pickFile() async {
    var selectedFiles = await FilePicker.platform.saveFile(
      dialogTitle: 'Wähle eine Datei zum Speichern',
      fileName: 'times.txt',
    );

    if (selectedFiles != null) {
      controller.text = selectedFiles;
    }
  }

  void store() async {
    var conf = {
      'time': controller.text,
      'data': paths,
      'runName': runNameController.text
    };
    var file = File('.config');
    await file.writeAsString(jsonEncode(conf));
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MyHomePage()));
  }

  Widget buildForm() {
    return Form(
        child: Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        children: [
          if (widget.note != null) Text(widget.note!),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: Text('Daten:')),
              Expanded(
                  child: TextFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Datendateien'),
                controller: dataFileController,
              )),
              const SizedBox(
                width: 100,
              ),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: pickFiles,
                  icon: const Icon(Icons.folder),
                  label: const Text('Dateien wählen'),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: Text('Datei zum Speichern der Zeiten')),
              Expanded(
                  child: TextFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Zeiten'),
                controller: controller,
              )),
              const SizedBox(
                width: 100,
              ),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: pickFile,
                  icon: const Icon(Icons.folder),
                  label: const Text('Datei wählen'),
                ),
              ),
            ],
          ),
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
                        currentDataFiles: widget.currentDataFiles,
                        currentTimeFile: widget.currentTimeFile,
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
