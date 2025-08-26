import '../../utils/path_utils.dart';

String get iconsfolder => "$assets/icons";

String get watch => PathString("$iconsfolder/watch.ico").path;
String get watch_all => PathString("$iconsfolder/watch_all.ico").path;
String get unwatch => PathString("$iconsfolder/unwatch.ico").path;
String get copy => PathString("$iconsfolder/copy.ico").path;
String get openFolder => PathString("$iconsfolder/open_folder.ico").path;
String get play => PathString("$iconsfolder/play.ico").path;
String get folderInfo => PathString("$iconsfolder/folder_info.ico").path;
String get anilist => PathString("$iconsfolder/anilist.png").path;
String get series => PathString("$iconsfolder/series.png").path;
String get list => PathString("$iconsfolder/list.png").path;
String get hide => PathString("$iconsfolder/hide.ico").path;
String get unhide => watch; // Reusing watch icon for unhide
