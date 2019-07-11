import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> _localPath() async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> _localFile() async {
  final path = await _localPath();
  try {
    print("======Getting file");
    return File('$path/firstlaunch.data');
  } catch (e) {
    return null;
  }
}

Future<bool> firstLaunchFile() async {
  File firstLaunch = await _localFile();

  if (firstLaunch != null) {
    try {
      String content = await firstLaunch.readAsString();
      if (content.contains("Already Launched")) {
        return false;
      } else {
        await firstLaunch.writeAsString("Already Launched");
        return true;
      }
    } catch (e) {
      await firstLaunch.writeAsString("Already Launched");
      return true;
    }
  } else {
    return true;
  }
}
