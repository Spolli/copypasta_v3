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
    super.initState();
    var a = _checkPermissions(Permission.ReadExternalStorage) && _checkPermissions(Permission.WriteExternalStorage);
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
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: createListView(context),
    );
  }

  bool _checkPermissions(permission) {
    if (Platform.isAndroid) {
      SimplePermissions
          .checkPermission(permission)
          .then((checkOkay) {
        if (!checkOkay) {
          SimplePermissions
              .requestPermission(permission)
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

  void _showDialog(file) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(file.toString()),
          content: new Image.file(new File(file.path)),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Delete"),
              onPressed: () {
                Scaffold.of(context).showSnackBar(new SnackBar(
                    content: new Text('Foto Eliminata!')
                ));
                file.deleteSync();
              },
            ),
          ],
        );
      },
    );
  }



  Widget createListView(BuildContext context) {

    try{
      List<FileSystemEntity> values = files;

      return new ListView.builder(
        itemCount: values.length,
        itemBuilder: (BuildContext contex, int index){
          return new Card(
            child: new ListTile(
              leading: new Text(index.toString()),
              title: new Text(values[index].path),
              trailing: new IconButton(icon: new Icon(Icons.call_made), onPressed: (){
                _showDialog(values[index]);
              }),
            ),
          );
        },
      );
    } catch(e){
      return new Center(
        child: new CircularProgressIndicator(),
      );
    }

  }
}
