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
  FlyoutController controller = FlyoutController();
  Color tempColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = Provider.of<SettingsManager>(context, listen: false);
      tempColor = settings.accentColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final library = Provider.of<Library>(context);
    final settings = Provider.of<SettingsManager>(context);

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
                  Row(children: [
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
                        settings.set('themeMode', newValue.name_);

                        await Future.delayed(const Duration(milliseconds: 300));
                        appTheme.setEffect(appTheme.windowEffect, context);
                      },
                    ),
                  ]),
                ],
                const SizedBox(height: 12),
                // Effect
                ...[
                  Row(
                    children: [
                      const Text('Effect:'),
                      const SizedBox(width: 12),
                      ComboBox<WindowEffect>(
                        value: appTheme.windowEffect,
                        items: _PlatformWindowEffects.map((WindowEffect value) {
                          return ComboBoxItem<WindowEffect>(
                            value: value,
                            child: Text(value.name_),
                          );
                        }).toList(),
                        onChanged: (WindowEffect? newValue) {
                          appTheme.windowEffect = newValue!;
                          appTheme.setEffect(newValue, context);
                          settings.set('windowEffect', newValue.name);
                        },
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                // Accent Color
                ...[
                  Row(
                    children: [
                      const Text('Accent Color:'),
                      const SizedBox(width: 12),
                      FlyoutTarget(
                        controller: controller,
                        child: GestureDetector(
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: settings.accentColor,
                              border: Border.all(
                                color: settings.accentColor.lerpWith(Colors.black, .25),
                                width: 1.25,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onTapDown: (_) {
                            // ignore: avoid_single_cascade_in_expression_statements
                            controller.showFlyout(
                              autoModeConfiguration: FlyoutAutoConfiguration(
                                preferredMode: FlyoutPlacementMode.right,
                                horizontal: true,
                              ),
                              barrierDismissible: true,
                              dismissOnPointerMoveAway: true,
                              dismissWithEsc: true,
                              navigatorKey: rootNavigatorKey.currentState,
                              builder: (context) {
                                return FlyoutContent(
                                  child: ColorPicker(
                                    color: settings.accentColor,
                                    onChanged: (color) {
                                      tempColor = color;
                                    },
                                    minValue: 100,
                                    isAlphaSliderVisible: true,
                                    colorSpectrumShape: ColorSpectrumShape.box,
                                    isMoreButtonVisible: false,
                                    isColorSliderVisible: false,
                                    isColorChannelTextInputVisible: false,
                                    isHexInputVisible: false,
                                    isAlphaEnabled: false,
                                  ),
                                );
                              },
                            )..then((_) {
                                settings.accentColor = tempColor;
                                appTheme.color = settings.accentColor.toAccentColor();
                                settings.set('accentColor', settings.accentColor.toHex(leadingHashSign: true));
                              });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                // Extra dim for acrylic and mica
                if (appTheme.windowEffect == WindowEffect.aero || appTheme.windowEffect == WindowEffect.acrylic || appTheme.windowEffect == WindowEffect.mica) //
                  ...[
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
                          [FluentTheme.of(context).accentColor.light],
                          [FluentTheme.of(context).accentColor.lighter],
                          [FluentTheme.of(context).accentColor.lightest],
                        ],
                        minWidth: 130.0,
                        labels: [
                          Dim.values[0].name_,
                          Dim.values[1].name_,
                          Dim.values[2].name_,
                        ],
                        onToggle: (int? value) {
                          final appTheme = context.read<AppTheme>();
                          appTheme.dim = Dim.values[value!];
                          settings.set('dim', Dim.values[value].name_.toLowerCase());
                        },
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                // Font Size
                ...[
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
                          settings.set('fontSize', newValue);
                        },
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                // Library colors
                ...[
                  Row(
                    children: [
                      const Text('Library Dominant Colors:'),
                      const SizedBox(width: 12),
                      ComboBox<LibraryColorView>(
                        value: settings.libColView,
                        items: <LibraryColorView>[
                          LibraryColorView.all,
                          LibraryColorView.onlyHover,
                          LibraryColorView.onlyBackground,
                          LibraryColorView.none,
                        ].map((LibraryColorView value) {
                          return ComboBoxItem<LibraryColorView>(
                            value: value,
                            child: Text(value.name_),
                          );
                        }).toList(),
                        onChanged: (LibraryColorView? newValue) {
                          settings.libColView = newValue!;
                          settings.set('libColView', newValue.name_);
                          print('Library color view: ${newValue.name_}');
                        },
                      ),
                    ],
                  ),
                ],
              ],
            );
          }),
          const SizedBox(height: 24),
          // Behavior section
          SettingsCard(
            children: [
              Text(
                'Behavior',
                style: FluentTheme.of(context).typography.subtitle,
              ),
              const SizedBox(height: 12),
              Text(
                'Automatically load Anilist posters for series without local posters.',
                style: FluentTheme.of(context).typography.body,
              ),
              const SizedBox(height: 24),
              ToggleSwitch(
                checked: settings.autoLoadAnilistPosters,
                content: const Text('Automatically load Anilist posters for series without images'),
                onChanged: (value) {
                  settings.autoLoadAnilistPosters = value;
                  settings.set('autoLoadAnilistPosters', value);
                },
              ),
            ],
          ),
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
