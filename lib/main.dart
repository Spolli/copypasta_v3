import 'dart:async';
import 'dart:io';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Copypasta'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title = "Copypasta";

  MyHomePage({Key key, title}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Directory extDir;
  bool externalStoragePermissionOkay = false;

  static List<FileSystemEntity> files;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var a = _checkPermissions();
    _getData();
    print(a);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Null> _getData() async {
    this.extDir = await getExternalStorageDirectory();
    List<FileSystemEntity> filez = extDir.listSync(recursive: true, followLinks: true);
    setState(() {
      /*
      for(int i = 0; i < filez.length; i++){
        files.add(filez[i]);
      }
      */
      files = filez;
    });
  }

  @override
  Widget build(BuildContext context) {
    /*var futureBuilder = new FutureBuilder(
      future: _getData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Center(
                child: new CircularProgressIndicator(),
              ),
            );
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return createListView(context, snapshot);
        }
      },
    );*/

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: createListView(context),
    );
  }

  bool _checkPermissions() {
    if (Platform.isAndroid) {
      SimplePermissions
          .checkPermission(Permission.ReadExternalStorage)
          .then((checkOkay) {
        if (!checkOkay) {
          SimplePermissions
              .requestPermission(Permission.ReadExternalStorage)
              .then((okDone) {
            if (okDone) {
              debugPrint("${okDone}");
              setState(() {
                externalStoragePermissionOkay = okDone;
                return true;
              });
            } else {return false;}
          });
        } else {
          setState(() {
            externalStoragePermissionOkay = checkOkay;
            return true;
          });
        }
      });
    } else {return false;}
    return false;
  }



  Widget createListView(BuildContext context) {
    List<FileSystemEntity> values = files;

    return new ListView.builder(
      itemCount: values.length,
      itemBuilder: (BuildContext contex, int index){
          return new Card(
            child: new ListTile(
              leading: new Text(index.toString()),
              title: new Text(values[index].path),
              trailing: new IconButton(icon: new Icon(Icons.call_made), onPressed: null),
            ),
          );
      },
    );
  }
}
