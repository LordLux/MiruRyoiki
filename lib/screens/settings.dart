// import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../models/library.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          readOnly: true,
                          controller: TextEditingController(
                              text: library.libraryPath ?? ''),
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
            ),
          ),
          
          const SizedBox(height: 24),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About MiruRyoiki',
                    style: FluentTheme.of(context).typography.subtitle,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'MiruRyoiki is a video tracking application that integrates with '
                    'Media Player Classic: Home Cinema to track your watched videos.',
                  ),
                  const SizedBox(height: 24),
                  const InfoBar(
                    title: Text('MPC-HC Integration'),
                    content: Text(
                      'This app reads data from the Windows Registry to detect videos played in MPC-HC. '
                      'Please ensure MPC-HC is installed and configured properly.',
                    ),
                    severity: InfoBarSeverity.info,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}