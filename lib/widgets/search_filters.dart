import 'package:flutter/material.dart' hide TextBox, Slider, BackButton;
import 'package:glossy/glossy.dart';

import '../manager.dart';
import 'buttons/button.dart';
import 'frosted_noise.dart';

class AnimeFilterHeader extends StatefulWidget {
  const AnimeFilterHeader({super.key});

  @override
  State<AnimeFilterHeader> createState() => _AnimeFilterHeaderState();
}

class _AnimeFilterHeaderState extends State<AnimeFilterHeader> {
  // Mock State Variables for dropdowns
  String _selectedGenre = 'Any';
  String _selectedYear = 'Any';
  String _selectedSeason = 'Any';
  String _selectedFormat = 'Any';
  String _selectedStatus = 'Any';

  bool _showAdvFilters = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: LayoutBuilder(builder: (context, constraints) {
        final sizePerFilter = (constraints.maxWidth - (16 * 4) - 24 - 40) / 5;
        Color filterColorBg = _showAdvFilters ? (Manager.currentDominantAccentColor ?? Manager.accentColor) : Colors.transparent;
        final borderRadius = 8.0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 2. Dropdowns
            _buildDropdown("Genres", _selectedGenre, ['Any', 'Action', 'Drama'], (v) => setState(() => _selectedGenre = v!), sizePerFilter),
            const SizedBox(width: 16),
            _buildDropdown("Year", _selectedYear, ['Any', '2024', '2023'], (v) => setState(() => _selectedYear = v!), sizePerFilter),
            const SizedBox(width: 16),
            _buildDropdown("Season", _selectedSeason, ['Any', 'Winter', 'Spring'], (v) => setState(() => _selectedSeason = v!), sizePerFilter),
            const SizedBox(width: 16),
            _buildDropdown("Format", _selectedFormat, ['Any', 'TV Show', 'Movie'], (v) => setState(() => _selectedFormat = v!), sizePerFilter),
            const SizedBox(width: 16),
            _buildDropdown("Airing Status", _selectedStatus, ['Any', 'Airing', 'Finished'], (v) => setState(() => _selectedStatus = v!), sizePerFilter),

            const SizedBox(width: 16),

            // 3. Filter/List View Toggle Button (Far right in image)
            GlossyContainer(
              color: filterColorBg,
              opacity: 0.1,
              strengthX: 20,
              strengthY: 20,
              blendMode: BlendMode.src,
              border: Border.all(
                color: _showAdvFilters ? (Manager.currentDominantAccentColor ?? Manager.accentColor) : Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(borderRadius),
                bottomLeft: Radius.circular(borderRadius),
                topRight: Radius.circular(borderRadius),
                bottomRight: Radius.circular(borderRadius),
              ),
              width: 140,
              height: 40,
              child: FrostedNoise(
                intensity: .5,
                color: filterColorBg,
                child: StandardButton.iconLabel(
                  expandY: true,
                  padding: EdgeInsets.zero,
                  expand: true,
                  label: Transform.translate(
                    offset: const Offset(0, 1),
                    child: Text('Advanced', style: Manager.bodyStyle.copyWith(color: Colors.grey)),
                  ),
                  icon: Icon(Icons.tune, color: _showAdvFilters ? Manager.accentColor : Colors.grey, size: 20),
                  onPressed: () => setState(() => _showAdvFilters = !_showAdvFilters),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Helper to build stylized Dropdowns
  Widget _buildDropdown(String label, String currentValue, List<String> items, ValueChanged<String?> onChanged, double width) {
    return Expanded(
      child: GlossyContainer(
        opacity: 0.1,
        strengthX: 20,
        strengthY: 20,
        blendMode: BlendMode.src,
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
        width: width,
        height: 40,
        child: FrostedNoise(
          intensity: 0.4,
          child: Padding(
            padding: EdgeInsets.only(left: 24.0, right: 12.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentValue,
                hint: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                dropdownColor: const Color(0xFF1B222C),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                isExpanded: true,
                onChanged: onChanged,
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
