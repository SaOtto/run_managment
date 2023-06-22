import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class SettingsPage extends StatefulWidget {
  final String? note;
  final List<String> currentTimeFile;
  final List<String> currentDataFiles;
  final String oldCert;
  final String oldInfo;
  final String oldRunPlace;
  final String oldRunName;

  const SettingsPage(
      {Key? key,
      this.note,
      required this.oldRunName,
      required this.oldRunPlace,
      required this.currentDataFiles,
      required this.currentTimeFile,
      required this.oldCert,
      required this.oldInfo})
      : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var controller = TextEditingController();
  var dataFileController = TextEditingController();
  var certController = TextEditingController();
  var infoController = TextEditingController();
  var runNameController = TextEditingController();
  var runPlaceController = TextEditingController();
  var paths = [];
  var pathsTimes = [];

  @override
  initState() {
    super.initState();
    controller.text = widget.currentTimeFile.toString();
    dataFileController.text = widget.currentDataFiles.toString();
    certController.text = widget.oldCert;
    infoController.text = widget.oldInfo;
    runPlaceController.text = widget.oldRunPlace;
    runNameController.text = widget.oldRunName;
    paths = widget.currentDataFiles;
    pathsTimes = widget.currentTimeFile;
  }

  void pickFiles() async {
    var selectedFiles =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (selectedFiles != null) {
      dataFileController.text = selectedFiles.paths.toString();
      paths = selectedFiles.paths;
    }
  }

  void pickFiles2() async {
    var selectedFiles =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (selectedFiles != null) {
      controller.text = selectedFiles.paths.toString();
      pathsTimes = selectedFiles.paths;
    }
  }

  void pickFile() async {
    var selectedFiles = await FilePicker.platform.saveFile(
      dialogTitle: 'Wähle eine Datei zum Speichern',
      fileName: 'urkunden.pdf',
    );

    if (selectedFiles != null) {
      certController.text = selectedFiles;
    }
  }

  void pickInfo() async {
    var selectedFiles = await FilePicker.platform.saveFile(
      dialogTitle: 'Wähle eine Datei zum Speichern',
      fileName: 'auswertung.csv',
    );

    if (selectedFiles != null) {
      infoController.text = selectedFiles;
    }
  }

  void store() async {
    var conf = {
      'runName': runNameController.text,
      'runPlace': runPlaceController.text,
      'time': pathsTimes,
      'data': paths,
      'certfile':
          certController.text == '' ? 'urkunden.pdf' : certController.text,
      'evaluation':
          infoController.text == '' ? 'auswertung.csv' : infoController.text
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
          TextFormField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name der Veranstaltung'),
            controller: runNameController,
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Ort der Veranstaltung'),
            controller: runPlaceController,
          ),
          const SizedBox(
            height: 20,
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
              const Expanded(child: Text('Dateien mit Zeiten')),
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
                  onPressed: pickFiles2,
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
              const Expanded(child: Text('Urkunden:')),
              Expanded(
                  child: TextFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Urkundendatei'),
                controller: certController,
              )),
              const SizedBox(
                width: 100,
              ),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: pickFile,
                  icon: const Icon(Icons.folder),
                  label: const Text('Urkunden'),
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
              const Expanded(child: Text('Auswertung:')),
              Expanded(
                  child: TextFormField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Auswertungsdatei'),
                controller: infoController,
              )),
              const SizedBox(
                width: 100,
              ),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: pickInfo,
                  icon: const Icon(Icons.folder),
                  label: const Text('Auswertung'),
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
                        oldRunName: widget.oldRunName,
                        oldRunPlace: widget.oldRunPlace,
                        currentDataFiles: widget.currentDataFiles,
                        currentTimeFile: widget.currentTimeFile,
                        oldCert: widget.oldCert,
                        oldInfo: widget.oldInfo,
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
