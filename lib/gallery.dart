import 'package:flutter/material.dart';
import 'package:galleryimage/galleryimage.dart';
import 'utils.dart';
import 'form.dart';
import 'dart:async';
import 'dart:io';
import 'models.dart';

class RouteOne extends StatefulWidget {
  const RouteOne({Key? key, required this.collection}) : super(key: key);
  final String collection;
  @override
  State<RouteOne> createState() => RouteOneState();
}

class RouteOneState extends State<RouteOne> {
  late Future<List<PhotoItem>> currentFiles;

  @override
  void initState() {
    super.initState();
    currentFiles = getFiles(widget.collection);
  }

  refresh() {
    setState(() {
      currentFiles = getFiles(widget.collection);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery: ${widget.collection}'),
      ),
      body: FutureBuilder(
          future: currentFiles,
          builder: (context, snapshot) {
            if ((snapshot.connectionState == ConnectionState.done) &&
                (snapshot.hasData)) {
              final data = snapshot.data as List<PhotoItem>;
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  crossAxisCount: 3,
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RouteTwo(
                                path: data[index].path,
                                date: data[index].date,
                                notifyParent: refresh),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(
                              (File(data[index].path)),
                            ),
                          ),
                        ),
                      ));
                },
              );
            } else {
              return const CircularProgressIndicator();
            }
            ;
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await pickImage(widget.collection);
          setState(() {
            currentFiles = getFiles(widget.collection);
          });
        },
        tooltip: 'Add Picture',
        child: const Icon(Icons.camera),
      ),
    );
  }
}

class RouteTwo extends StatelessWidget {
  final String path;
  final String date;
  final Function notifyParent;

  const RouteTwo(
      {Key? key,
      required this.path,
      required this.date,
      required this.notifyParent})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(date)),
      body: Column(
        children: [
          Image.file(
            File(path),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm"),
                    content: const Text("Delete?"),
                    actions: <Widget>[
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            deleteFile(path);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Deleted!')),
                            );
                            notifyParent();
                            Navigator.of(context).pop();
                          },
                          child: const Text("DELETE")),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("CANCEL"),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}
