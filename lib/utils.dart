import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'dart:io';
import 'dart:async';
import 'models.dart';

Future<List<PhotoItem>> getFiles(String collection) async {
  //asyn function to get list of files
  final appDir = await syspaths.getApplicationDocumentsDirectory();
  //List<String> listOfUrls = ['file:/${appDir.path}/test.jpg'];
  List<FileSystemEntity> listOfUrls =
      Directory("${appDir.path}/$collection").listSync();
  List<PhotoItem> finalList = [];

  for (int i = 0; i < listOfUrls.length; i++) {
    if (listOfUrls[i].path.split(".").last == "jpg") {
      String path = listOfUrls[i].path.toString();
      FileStat stat = FileStat.statSync(path);
      PhotoItem photo = PhotoItem(listOfUrls[i].path.toString(),
          stat.changed.toString().substring(0, 10));

      finalList.add(photo);
    }
  }
  return finalList;
}

Future<PhotoItem> pickImage(String collection) async {
  File? image;
  final ImagePicker picker = ImagePicker();
  // Pick an image
  XFile? pickedImage = await picker.pickImage(source: ImageSource.camera);
  if (pickedImage != null) {
    image = File(pickedImage.path);
  }

  // getting a directory path for saving
  final appDir = await syspaths.getApplicationDocumentsDirectory();

  // copy the file to a new path
  await image?.copy('${appDir.path}/$collection/${path.basename(image.path)}');
  String date = (await pickedImage!.lastModified()).toString().substring(0, 10);

  PhotoItem result = PhotoItem(image!.path, date);
  return result;
}

Future<PhotoItem> copyImage(File file, String collection) async {
  final appDir = await syspaths.getApplicationDocumentsDirectory();

  // copy the file to a new path
  await file.copy('${appDir.path}/$collection/${file.path.split("/").last}');
  String date = (await file.lastModified()).toString().substring(0, 10);

  PhotoItem result = PhotoItem(file.path, date);
  return result;
}

Future<Directory> createDirectory(String name) async {
  final appDir = await syspaths.getApplicationDocumentsDirectory();
  return Directory('${appDir.path}/$name').create();
}

Future<List<String>> getCollections() async {
  //asyn function to get list of files
  final appDir = await syspaths.getApplicationDocumentsDirectory();
  //List<String> listOfUrls = ['file:/${appDir.path}/test.jpg'];
  List<FileSystemEntity> listOfUrls = Directory("${appDir.path}").listSync();
  List<String> finalList = [];
  for (int i = 0; i < listOfUrls.length; i++) {
    bool isDir = listOfUrls[i] is Directory;
    String folderName = listOfUrls[i].path.toString().split("/").last;
    bool notAssetsDir = folderName != "flutter_assets";
    if (isDir && notAssetsDir) {
      finalList.add(folderName);
    }
  }
  return finalList;
}

Future<void> removeCollection(String name) async {
  final appDir = await syspaths.getApplicationDocumentsDirectory();
  Directory toDelete = Directory("${appDir.path}/$name");
  toDelete.deleteSync(recursive: true);
}

Future<void> deleteFile(String path) async {
  File toDelete = File(path);
  toDelete.deleteSync();
}
