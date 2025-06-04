//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <app_links/app_links_plugin_c_api.h>
#include <bitsdojo_window_windows/bitsdojo_window_plugin.h>
#include <flutter_acrylic/flutter_acrylic_plugin.h>
#include <flutter_custom_cursor/flutter_custom_cursor_plugin.h>
#include <flutter_desktop_context_menu/flutter_desktop_context_menu_plugin.h>
#include <flutter_media_metadata/flutter_media_metadata_plugin.h>
#include <flutter_secure_storage_windows/flutter_secure_storage_windows_plugin.h>
#include <screen_retriever_windows/screen_retriever_windows_plugin_c_api.h>
#include <system_theme/system_theme_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>
#include <video_thumbnail_exporter/video_thumbnail_exporter_plugin_c_api.h>
#include <window_manager/window_manager_plugin.h>
#include <window_size/window_size_plugin.h>
#include <windows_single_instance/windows_single_instance_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AppLinksPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AppLinksPluginCApi"));
  BitsdojoWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("BitsdojoWindowPlugin"));
  FlutterAcrylicPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterAcrylicPlugin"));
  FlutterCustomCursorPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterCustomCursorPlugin"));
  FlutterDesktopContextMenuPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterDesktopContextMenuPlugin"));
  FlutterMediaMetadataPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterMediaMetadataPlugin"));
  FlutterSecureStorageWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterSecureStorageWindowsPlugin"));
  ScreenRetrieverWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenRetrieverWindowsPluginCApi"));
  SystemThemePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SystemThemePlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  VideoThumbnailExporterPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("VideoThumbnailExporterPluginCApi"));
  WindowManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowManagerPlugin"));
  WindowSizePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowSizePlugin"));
  WindowsSingleInstancePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowsSingleInstancePlugin"));
}
