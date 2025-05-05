// import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as mat;
import 'package:flutter_acrylic/window_effect.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:recase/recase.dart';
import 'package:toggle_switch/toggle_switch.dart' as toggle;
import 'dart:io';

import '../enums.dart';
import '../main.dart';
import '../manager.dart';
import '../models/library.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// ignore: non_constant_identifier_names
List<WindowEffect> _WindowsWindowEffects = [
  WindowEffect.solid,
  WindowEffect.transparent,
  WindowEffect.aero,
  WindowEffect.acrylic,
  if (Platform.operatingSystemVersion.startsWith('11')) WindowEffect.mica,
];

// ignore: non_constant_identifier_names
List<WindowEffect> get _PlatformWindowEffects => switch (defaultTargetPlatform) {
      TargetPlatform.windows => _WindowsWindowEffects,
      TargetPlatform.macOS => [WindowEffect.disabled, WindowEffect.solid],
      TargetPlatform.linux => [WindowEffect.disabled],
      _ => [WindowEffect.disabled],
    };

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final library = Provider.of<Library>(context);

    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Settings'),
      ),
      content: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Library location section
          SettingsCard(
            children: [
              Text(
                'Library Location',
                style: FluentTheme.of(context).typography.subtitle,
              ),
              const SizedBox(height: 12),
              Text(
                'Select the folder that contains your media library. '
                'The app will scan this folder for video files.',
                style: FluentTheme.of(context).typography.body,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextBox(
                      placeholder: 'No folder selected',
                      controller: TextEditingController(text: library.libraryPath ?? ''),
                      readOnly: true,
                      enabled: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    child: const Text('Browse'),
                    onPressed: () async {
                      final result = await FilePicker.platform.getDirectoryPath(
                        dialogTitle: 'Select Library Folder',
                      );

                      if (result != null) {
                        library.setLibraryPath(result);
                      }
                    },
                  ),
                ],
              ),
              if (library.libraryPath != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Button(
                      child: const Text('Scan Library'),
                      onPressed: () {
                        library.scanLibrary();
                      },
                    ),
                    const SizedBox(width: 8),
                    if (library.isLoading)
                      SizedBox.square(
                        dimension: 20,
                        child: const ProgressRing(
                          strokeWidth: 2,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          // Appearance section
          Builder(builder: (context) {
            final appTheme = context.watch<AppTheme>();

            return SettingsCard(
              children: [
                Text(
                  'Appearance',
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                const SizedBox(height: 12),
                // Theme and font effect settings
                ...[
                  Text('Choose your preferred theme and effect.', style: FluentTheme.of(context).typography.body),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      // Theme
                      const Text('Theme:'),
                      const SizedBox(width: 12),
                      ComboBox<ThemeMode>(
                        value: appTheme.mode,
                        items: <ThemeMode>[ThemeMode.system, ThemeMode.light, ThemeMode.dark].map((ThemeMode value) {
                          return ComboBoxItem<ThemeMode>(
                            value: value,
                            child: Text(value.name.titleCase),
                          );
                        }).toList(),
                        onChanged: (ThemeMode? newValue) async {
                          appTheme.mode = newValue!;
                          appTheme.setEffect(appTheme.windowEffect, context);
                          SettingsManager.saveSettings({'themeMode': newValue.name});

                          await Future.delayed(const Duration(milliseconds: 300));
                          appTheme.setEffect(appTheme.windowEffect, context);
                        },
                      ),
                      // Effect
                      const Text('Effect:'),
                      const SizedBox(width: 12),
                      ComboBox<WindowEffect>(
                        value: appTheme.windowEffect,
                        items: _PlatformWindowEffects.map((WindowEffect value) {
                          return ComboBoxItem<WindowEffect>(
                            value: value,
                            child: Text(value.name.titleCase),
                          );
                        }).toList(),
                        onChanged: (WindowEffect? newValue) {
                          appTheme.windowEffect = newValue!;
                          appTheme.setEffect(newValue, context);
                          SettingsManager.saveSettings({'windowEffect': newValue.name});
                        },
                      ),
                    ],
                  ),
                ],
                // Font Size
                ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Font Size:'),
                      const SizedBox(width: 12),
                      ComboBox<double>(
                        value: appTheme.fontSize,
                        items: <double>[10, 12, 14, 16, 18, 20].map((double value) {
                          return ComboBoxItem<double>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        onChanged: (double? newValue) {
                          appTheme.fontSize = newValue!;
                          SettingsManager.saveSettings({'fontSize': newValue});
                        },
                      ),
                    ],
                  ),
                ],
                // Extra dim for acrylic and mica
                if (appTheme.windowEffect == WindowEffect.aero || appTheme.windowEffect == WindowEffect.acrylic || appTheme.windowEffect == WindowEffect.mica) //
                  ...[
                  const SizedBox(height: 12),
                  Text(
                    context.watch<AppTheme>().windowEffect.toString(),
                    style: FluentTheme.of(context).typography.body,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Dim'),
                      const SizedBox(width: 12),
                      toggle.ToggleSwitch(
                        animate: true,
                        animationDuration: dimDuration.inMilliseconds,
                        initialLabelIndex: context.watch<AppTheme>().dim.index,
                        totalSwitches: Dim.values.length,
                        activeFgColor: Colors.white,
                        activeBgColors: [
                          [FluentTheme.of(context).accentColor.dark],
                          [FluentTheme.of(context).accentColor.normal],
                          [FluentTheme.of(context).accentColor.light],
                        ],
                        minWidth: 130.0,
                        labels: [
                          'Dimmed',
                          'Normal',
                          'Brightened',
                        ],
                        onToggle: (int? value) {
                          final appTheme = context.read<AppTheme>();
                          appTheme.dim = Dim.values[value!];
                        },
                      ),
                    ],
                  ),
                ]
              ],
            );
          }),
          const SizedBox(height: 24),
          // About section
          SettingsCard(
            children: [
              Text(
                'About ${Manager.appTitle}',
                style: FluentTheme.of(context).typography.subtitle,
              ),
              const SizedBox(height: 12),
              const Text(
                '${Manager.appTitle} is a video tracking application that integrates with '
                'Media Player Classic: Home Cinema to track your watched videos.',
              ),
              const SizedBox(height: 24),
              const InfoBar(
                title: Text('MPC-HC Integration'),
                content: Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Text(
                    'This app reads data from the Windows Registry to detect videos played in MPC-HC. '
                    'Please ensure MPC-HC is installed and configured properly.',
                  ),
                ),
                severity: InfoBarSeverity.info,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card with vertically distributed children
Widget SettingsCard({required List<Widget> children}) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );
}
