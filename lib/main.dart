import 'package:flutter/material.dart';
import 'package:galleryimage/galleryimage.dart';
import 'utils.dart';
import 'form.dart';
import 'dart:async';
import 'models.dart';
import 'gallery.dart';
import 'package:camera/camera.dart';

late final List<CameraDescription> cameras;
Future<void> getCameras() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of the available cameras on the device.
  cameras = await availableCameras();
  // Get a specific camera from the list of available cameras.
}

void main() {
  getCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<String>> collections;

  @override
  void initState() {
    super.initState();
    collections = getCollections();
  }

  refresh() {
    setState(() {});
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: FutureBuilder(
            future: getCollections(),
            builder: (context, snapshot) {
              if ((snapshot.connectionState == ConnectionState.done) &&
                  (snapshot.hasData)) {
                final data = snapshot.data as List<String>;
                return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Dismissible(
                        key: ValueKey(data[index]),
                        background: Card(
                            shadowColor: Colors.red,
                            //padding: const EdgeInsets.only(right: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: const <Widget>[
                                Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                )
                              ],
                            )),
                        child: ListTile(
                          title: Center(child: Text(data[index])),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RouteOne(collection: data[index]),
                              ),
                            );
                          },
                        ),
                        onDismissed: (direction) {
                          removeCollection(data[index]);
                          setState(() {
                            collections = getCollections();
                          });
                        },
                        confirmDismiss: (DismissDirection direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm"),
                                content: const Text("Delete?"),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text("DELETE")),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("CANCEL"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    });
              } else {
                return const CircularProgressIndicator();
              }
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NewCollectionForm(notifyParent: refresh)),
            );
            setState(() {
              collections = getCollections();
            });
          },
          tooltip: 'New Collection',
          child: const Icon(Icons.add),
        ));
  }
}

class CollectionView extends StatefulWidget {
  const CollectionView({Key? key, required this.collection}) : super(key: key);

  final String collection;

  @override
  State<CollectionView> createState() => _CollectionViewState();
}

class _CollectionViewState extends State<CollectionView> {
  late Future<List<PhotoItem>> currentFiles = getFiles(widget.collection);

  @override
  void initState() {
    super.initState();
    currentFiles = getFiles(widget.collection);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection),
      ),
      body: Center(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Tap to show image"),
                FutureBuilder(
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return const Text(
                          'Error',
                          style: TextStyle(fontSize: 18),
                        );
                      } else if (snapshot.hasData) {
                        final data = snapshot.data as List<PhotoItem>;
                        List<String> files = [];
                        for (var item in data) {
                          files.add(item.path);
                        }
                        return GalleryImage(
                            numOfShowImages: data.length, imageUrls: files);
                      }
                    }
                    return const CircularProgressIndicator();
                  },
                  future: currentFiles,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          pickImage(widget.collection);
        },
        tooltip: 'Add Picture',
        child: const Icon(Icons.camera),
      ),
    );
  }
}
