import 'path.dart';

/// file:///M:/Projects/MiruRyoiki/miruryoiki/assets/system/

String get anilistPath => "$assets/icons/anilist"; // using assetbundle
String get contextMenuPath => "$assets/system/context"; // using file path
String get videoPlayersPath => "$assets/system/players"; // using assetbundle

// Anilist icons
String get anilist_logo => PathString("$anilistPath/logo.si").asset!;
String get anilist_logo_offline => PathString("$anilistPath/offline_logo.si").asset!;
String get icon_offline => PathString("$anilistPath/offline.si").asset!;

// Context menu icons
String get anilist => PathString("$contextMenuPath/anilist.png").path;
String get check => PathString("$contextMenuPath/check.png").path;
String get check_all => PathString("$contextMenuPath/check_all.png").path;
String get checkPrevious => PathString("$contextMenuPath/check_previous.png").path;
String get copy => PathString("$contextMenuPath/copy.ico").path;
String get folder_info => PathString("$contextMenuPath/folder_info.ico").path;
String get folder_open => PathString("$contextMenuPath/folder_open.ico").path;
String get hide => PathString("$contextMenuPath/hide.ico").path;
String get list => PathString("$contextMenuPath/list.png").path;
String get play => PathString("$contextMenuPath/play.png").path;
String get remove_link => PathString("$contextMenuPath/remove_link.png").path;
String get series => PathString("$contextMenuPath/series.ico").path;
String get unhide => PathString("$contextMenuPath/unhide.ico").path;
String get unwatch => PathString("$contextMenuPath/unwatch.ico").path;
String get video_info => PathString("$contextMenuPath/video_info.ico").path;
@Deprecated('Use check')
String get watch2 => PathString("$contextMenuPath/watch.png").path;
@Deprecated('Use check_all')
String get watch_all2 => PathString("$contextMenuPath/watch_all.ico").path;

// Video Players
String get vlc => PathString("$videoPlayersPath/vlc.si").asset!;
String get mpcHc => PathString("$videoPlayersPath/mpchc.si").asset!;