import 'package:cached_network_image/cached_network_image.dart';
import 'package:defer_pointer/defer_pointer.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:miruryoiki/enums.dart';
import 'package:miruryoiki/utils/logging.dart';
import 'package:miruryoiki/widgets/tooltip_wrapper.dart';
import 'package:provider/provider.dart';

import '../../manager.dart';
import '../../models/anilist/anime.dart';
import '../../models/anilist/user_data.dart';
import '../../models/anilist/user_list.dart';
import '../../services/anilist/provider/anilist_provider.dart';
import '../../services/anilist/queries/anilist_service.dart';
import '../../services/navigation/dialog_functions.dart';
import '../../services/navigation/dialog_framework.dart';
import '../../services/navigation/navigation.dart';
import '../../services/navigation/show_info.dart';
import '../../utils/time.dart';
import '../buttons/animated_icon_label_button.dart';
import '../buttons/button.dart';
import '../buttons/wrapper.dart';
import '../fluent_selectable_text.dart';
import '../score_widget.dart';
import '../smooth_scroll.dart';
import 'show_dialog.dart';

/// Show the AniList entry editor dialog for a given media
///
/// - [mediaId] is the AniList media ID
/// - [title] is the display title for the dialog header
/// - [totalEpisodes] is the total episode count (null if unknown)
/// - [bannerImage] optional banner image URL for the header background
/// - [coverImage] optional cover/poster image URL
/// - [isFavourite] current favourite state (display only for now)
/// - [entry] is the existing list entry (null if adding for the first time)
void showEntryEditorDialog(
  BuildContext context, {
  required int mediaId,
  required String title,
  int? totalEpisodes,
  String? bannerImage,
  String? coverImage,
  bool isFavourite = false,
  AnilistMediaListEntry? entry,
}) {
  showPaddedDialog(
    context,
    navigationItem: DialogNavigationItem(
      id: 'anilist:entry-editor:$mediaId',
      title: 'Edit Entry',
    ),
    barrierOptions: PaddedBarrierOptions(
      barrierColor: Manager.currentDominantColor?.withOpacity(0.5),
      userDismissable: true,
    ),
    builder: (ctx, item, options) {
      return PaddedDialog.custom(
        navigationItem: item,
        barrierOptions: options,
        constraints: const BoxConstraints(maxWidth: 880, maxHeight: 860, minWidth: 560),
        contentBuilder: (context, constraints) {
          return _EntryEditorShell(
            mediaId: mediaId,
            title: title,
            totalEpisodes: totalEpisodes,
            bannerImage: bannerImage,
            coverImage: coverImage,
            isFavourite: isFavourite,
            entry: entry,
          );
        },
      );
    },
  );
}

const _editableStatuses = [
  AnilistListApiStatus.CURRENT,
  AnilistListApiStatus.PLANNING,
  AnilistListApiStatus.COMPLETED,
  AnilistListApiStatus.DROPPED,
  AnilistListApiStatus.PAUSED,
  AnilistListApiStatus.REPEATING,
  //AnilistListApiStatus.CUSTOM is not allowed for this status field, only for custom lists
];

class _EntryEditorShell extends StatefulWidget {
  final int mediaId;
  final String title;
  final int? totalEpisodes;
  final String? bannerImage;
  final String? coverImage;
  final bool isFavourite;
  final AnilistMediaListEntry? entry;

  const _EntryEditorShell({
    required this.mediaId,
    required this.title,
    this.totalEpisodes,
    this.bannerImage,
    this.coverImage,
    this.isFavourite = false,
    this.entry,
  });

  @override
  State<_EntryEditorShell> createState() => _EntryEditorShellState();
}

class _EntryEditorShellState extends State<_EntryEditorShell> {
  late AnilistListApiStatus _status;
  late int _score;
  late int _progress;
  late int _repeat;
  late bool _private;
  late bool _hiddenFromStatusLists;
  late bool _isFavourite;
  late String _notes;
  late DateValue? _startedAt;
  late DateValue? _completedAt;
  late Set<String> _selectedCustomLists; // display names

  // Tracking original state to prevent empty mutations
  late AnilistListApiStatus _initialStatus;
  late int _initialScore;
  late int _initialProgress;
  late int _initialRepeat;
  late bool _initialPrivate;
  late bool _initialHiddenFromStatusLists;
  late String _initialNotes;
  DateValue? _initialStartedAt;
  DateValue? _initialCompletedAt;
  Set<String>? _initialCustomLists;

  late TextEditingController _notesController;

  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isFetchingLatest = false;

  /// Tracks whether we've received a fresh entry from the API
  ///
  /// Used to decide if "Delete" should be available (the passed-in entry may be null for brand-new items, but the API may return an existing one)
  AnilistMediaListEntry? _latestEntry;

  bool get _isNewEntry => _latestEntry == null && widget.entry == null;
  int? get _totalEpisodes => widget.totalEpisodes;

  @override
  void initState() {
    super.initState();
    _applyEntry(widget.entry);
    _notesController = TextEditingController(text: _notes);
    _isFavourite = widget.isFavourite;
    _populateCustomListsFromProvider();

    // Kick off a background fetch for the latest entry data from AniList.
    _fetchLatestEntry();
  }

  /// Populate form fields from an entry (or defaults when null)
  void _applyEntry(AnilistMediaListEntry? e) {
    _status = e?.status ?? AnilistListApiStatus.PLANNING; // Default to PLANNING for new entries
    _score = e?.score ?? 0;
    _progress = e?.progress ?? 0;
    _repeat = e?.repeat ?? 0;
    _private = e?.private ?? false;
    _hiddenFromStatusLists = e?.hiddenFromStatusLists ?? false;
    _notes = e?.notes ?? '';
    _startedAt = e?.startedAt;
    _completedAt = e?.completedAt;

    _initialStatus = _status;
    _initialScore = _score;
    _initialProgress = _progress;
    _initialRepeat = _repeat;
    _initialPrivate = _private;
    _initialHiddenFromStatusLists = _hiddenFromStatusLists;
    _initialNotes = _notes;
    _initialStartedAt = _startedAt;
    _initialCompletedAt = _completedAt;
  }

  /// Scan the provider to figure out which custom lists contain this entry
  void _populateCustomListsFromProvider() {
    _selectedCustomLists = <String>{};
    try {
      final anilist = Provider.of<AnilistProvider>(context, listen: false);
      for (final entryMap in anilist.userLists.entries) {
        final key = entryMap.key;
        if (!key.startsWith(AnilistService.statusListPrefixCustom)) continue;
        final contains = entryMap.value.entries.any((x) => x.mediaId == widget.mediaId);
        if (contains) {
          _selectedCustomLists.add(_stripCustomPrefix(key));
        }
      }
    } catch (_) {
      // Provider not available
      logWarn('Failed to read custom lists from provider in entry editor');
    }
    _initialCustomLists = Set.from(_selectedCustomLists);
  }

  /// Fetch the latest entry data from AniList and update the form if the user hasn't started editing yet (i.e. no dirty fields)
  Future<void> _fetchLatestEntry() async {
    final anilist = Provider.of<AnilistProvider>(context, listen: false);
    if (!anilist.allUserAnilistIds.contains(widget.mediaId)) return;
    
    setState(() => _isFetchingLatest = true);
    try {
      final fresh = await anilist.fetchMediaListEntry(widget.mediaId);
      if (!mounted) return;
      if (fresh != null) {
        _latestEntry = fresh;
        setState(() {
          _applyEntry(fresh);
          _notesController.text = _notes;
          _isFavourite = fresh.media.isFavourite ?? _isFavourite;
          _populateCustomListsFromProvider();
        });
      }
    } catch (_) {
      // Fetch failed — keep showing cached data
    } finally {
      if (mounted) setState(() => _isFetchingLatest = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Helpers

  String _stripCustomPrefix(String key) {
    if (key.startsWith(AnilistService.statusListPrefixCustom)) {
      return key.substring(AnilistService.statusListPrefixCustom.length);
    }
    return key;
  }

  String _statusLabel(AnilistListApiStatus s) => StatusStatistic.statusNameToPretty(s.name_);

  List<String> _availableCustomLists(AnilistProvider anilist) {
    return anilist.userLists.keys //
        .where((k) => k.startsWith(AnilistService.statusListPrefixCustom))
        .map(_stripCustomPrefix)
        .toList()
      ..sort();
  }

  bool get _hasChanges {
    if (_isNewEntry) return true;

    if (_status != _initialStatus) return true;
    if (_score != _initialScore) return true;
    if (_progress != _initialProgress) return true;
    if (_repeat != _initialRepeat) return true;
    if (_private != _initialPrivate) return true;
    if (_hiddenFromStatusLists != _initialHiddenFromStatusLists) return true;
    if (_notes != _initialNotes) return true;

    final initStart = _initialStartedAt?.isEmpty == true ? null : _initialStartedAt?.toDateTime();
    final currStart = _startedAt?.isEmpty == true ? null : _startedAt?.toDateTime();
    if (initStart != currStart) return true;

    final initEnd = _initialCompletedAt?.isEmpty == true ? null : _initialCompletedAt?.toDateTime();
    final currEnd = _completedAt?.isEmpty == true ? null : _completedAt?.toDateTime();
    if (initEnd != currEnd) return true;

    if (_initialCustomLists != null) {
      if (_selectedCustomLists.length != _initialCustomLists!.length) return true;
      if (!_selectedCustomLists.containsAll(_initialCustomLists!)) return true;
    }

    return false;
  }

  Future<void> _save() async {
    // If there are no changes just close the dialog
    if (!_hasChanges) {
      closeDialog();
      return;
    }

    setState(() => _isSaving = true);

    try {
      final anilist = Provider.of<AnilistProvider>(context, listen: false);
      final success = await anilist.saveEntry(
        mediaId: widget.mediaId,
        status: _status,
        score: _score,
        progress: _progress,
        repeat: _repeat,
        private: _private,
        hiddenFromStatusLists: _hiddenFromStatusLists,
        notes: _notes,
        startedAt: _startedAt ?? DateValue(),
        completedAt: _completedAt ?? DateValue(),
        customLists: _selectedCustomLists.toList(),
      );

      if (success) {
        snackBar(
          _isNewEntry ? 'Added to ${_statusLabel(_status)}' : 'Entry updated',
          severity: InfoBarSeverity.success,
        );
        closeDialog();
      } else {
        snackBar('Failed to save entry', severity: InfoBarSeverity.error);
      }
    } catch (e) {
      snackBar('Error: $e', severity: InfoBarSeverity.error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _toggleFavourite() async {
    final oldState = _isFavourite;
    setState(() => _isFavourite = !oldState);

    try {
      final anilist = Provider.of<AnilistProvider>(context, listen: false);
      final success = await anilist.toggleFavourite(widget.mediaId);
      if (!success && mounted) {
        // Revert on failure
        setState(() => _isFavourite = oldState);
        snackBar('Failed to update favourite', severity: InfoBarSeverity.error);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFavourite = oldState);
        snackBar('Error: $e', severity: InfoBarSeverity.error);
      }
    }
  }

  Future<void> _delete() async {
    final entryId = (_latestEntry ?? widget.entry)?.id;
    if (entryId == null) return;

    setState(() => _isDeleting = true);

    try {
      final anilist = Provider.of<AnilistProvider>(context, listen: false);
      final success = await anilist.deleteEntry(
        mediaId: widget.mediaId,
        entryId: entryId,
      );

      if (success) {
        snackBar('Entry removed from list', severity: InfoBarSeverity.success);
        closeDialog();
      } else {
        snackBar('Failed to delete entry', severity: InfoBarSeverity.error);
      }
    } catch (e) {
      snackBar('Error: $e', severity: InfoBarSeverity.error);
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  // Build

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final accentColor = Manager.currentDominantAccentColor ?? Manager.accentColor;

    return DeferredPointerHandler(
      child: FluentTheme(
        data: FluentTheme.of(context).copyWith(
          brightness: theme.brightness,
          accentColor: accentColor,
          typography: theme.typography,
          activeColor: accentColor,
          selectionColor: accentColor.withOpacity(0.5),
        ),
        child: mat.Theme(
          data: mat.Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: accentColor.withOpacity(0.5),
              selectionHandleColor: accentColor,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: theme.micaBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.resources.cardStrokeColorDefault),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(theme, accentColor),
                  const SizedBox(height: 12),
                  Flexible(
                    child: SmoothScroll(
                      enableSmoothScroll: Manager.animationsEnabled,
                      builder: (context, controller, physics) {
                        return SingleChildScrollView(
                          controller: controller,
                          physics: physics,
                          padding: const EdgeInsets.fromLTRB(36, 26, 33, 16),
                          child: _buildBody(theme, accentColor),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(36, 0, 33, 23),
                    child: _buildFooter(theme, accentColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(FluentThemeData theme, Color accentColor) {
    const bannerRatio = 19 / 4; // 1900x400
    const bannerHeight = 200.0;
    const bannerWidth = bannerHeight * bannerRatio;
    const posterHeight = 158.0;

    return SizedBox(
      height: bannerHeight,
      child: Transform.scale(
        scale: 1.0075, // Slightly scale up to hide any edges from border radius
        child: Stack(
          children: [
            // Banner background
            Positioned.fill(
              child: widget.bannerImage != null
                  ? CachedNetworkImage(
                      height: bannerHeight,
                      width: bannerWidth,
                      imageUrl: widget.bannerImage!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(color: accentColor.withOpacity(0.35)),
                    )
                  : Container(color: accentColor.withOpacity(0.5)),
            ),
            // Dark overlay for readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(widget.bannerImage != null ? 0.15 : 0),
                      Colors.black.withOpacity(widget.bannerImage != null ? 0.75 : 0.6),
                    ],
                  ),
                ),
              ),
            ),

            // Poster + title row
            Positioned(
              left: 36,
              right: 33,
              bottom: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Poster
                  DeferPointer(
                    child: Transform.translate(
                      offset: const Offset(0, 25),
                      child: Container(
                        height: posterHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: widget.coverImage != null
                            ? CachedNetworkImage(
                                imageUrl: widget.coverImage!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(color: Colors.black.withOpacity(0.25)),
                              )
                            : Container(color: Colors.black.withOpacity(0.25), child: Icon(FluentIcons.picture, color: Colors.white.withOpacity(0.6))),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Title
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: FluentSelectableText(
                        widget.title,
                        style: theme.typography.subtitle?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Favourite heart
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: SizedBox(
                      width: 102,
                      child: Builder(builder: (context) {
                        final tooltip = _isFavourite ? 'Remove from favourites' : 'Add to favourites';
                        final text = _isFavourite ? 'Unfavourite' : 'Favourite';
                        return AnimatedIconLabelButton(
                          tooltip: tooltip,
                          label: text,
                          height: 34,
                          icon: (isHovered) => Icon(
                            _isFavourite ? FluentIcons.heart_fill : FluentIcons.heart,
                            size: 18,
                            color: _isFavourite ? accentColor : Colors.white,
                          ),
                          onPressed: _toggleFavourite,
                          tooltipWaitDuration: longDuration,
                        );
                      }),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Save button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: StandardButton(
                      onPressed: (_isSaving || _isFetchingLatest) ? null : _save,
                      backgroundColor: accentColor,
                      hoverColor: accentColor.lighten(0.05),
                      isFilled: true,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      label: (_isSaving || _isFetchingLatest)
                          ? const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                          : Text(
                              _isNewEntry ? 'Add' : 'Update',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(FluentThemeData theme, Color accentColor) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main fields (left column)
          Expanded(child: _buildMainFields(theme, accentColor)),
          const SizedBox(width: 20),
          // Custom lists (right column)
          SizedBox(
            width: 180,
            child: _buildCustomListsColumn(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFields(FluentThemeData theme, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: Status | Score | Episode Progress
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _field(
                'Status',
                ComboBox<AnilistListApiStatus>(
                  isExpanded: true,
                  value: _status,
                  items: _editableStatuses.map((s) => ComboBoxItem(value: s, child: Text(_statusLabel(s)))).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _status = v;
                      if (v == AnilistListApiStatus.COMPLETED && _totalEpisodes != null && _progress < _totalEpisodes!) {
                        _progress = _totalEpisodes!;
                      }
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                'Score',
                Align(
                  alignment: Alignment.centerLeft,
                  child: ScoreWidget(
                    score: _score,
                    format: Provider.of<AnilistProvider>(context, listen: false).scoreFormat,
                    editable: true,
                    iconSize: 20,
                    onChanged: (v) => setState(() => _score = v),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                'Episode Progress',
                NumberBox<int>(
                  value: _progress,
                  min: 0,
                  max: _totalEpisodes ?? 9999,
                  onChanged: (v) {
                    if (v != null) setState(() => _progress = v);
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Row 2: Start Date | Finish Date | Total Rewatches
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _dateField('Start Date', _startedAt, (d) => setState(() => _startedAt = d)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _dateField('Finish Date', _completedAt, (d) => setState(() => _completedAt = d)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                'Total Rewatches',
                NumberBox<int>(
                  value: _repeat,
                  min: 0,
                  max: 9999,
                  onChanged: (v) {
                    if (v != null) setState(() => _repeat = v);
                  },
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Notes
        _field(
          'Notes',
          TextBox(
            controller: _notesController,
            placeholder: '',
            maxLines: 3,
            minLines: 3,
            onChanged: (v) => _notes = v,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomListsColumn(FluentThemeData theme) {
    final anilist = Provider.of<AnilistProvider>(context, listen: false);
    final available = _availableCustomLists(anilist);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Custom Lists', style: theme.typography.caption),
        const SizedBox(height: 6),
        if (available.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'No custom lists',
              style: theme.typography.caption?.copyWith(color: theme.inactiveColor.withOpacity(0.6)),
            ),
          )
        else
          // Custom lists checkboxes list
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: available
                      .map(
                        (name) => _checkbox(
                          label: name,
                          checked: _selectedCustomLists.contains(name),
                          onChanged: (v) {
                            setState(() {
                              if (v == true) {
                                _selectedCustomLists.add(name);
                              } else {
                                _selectedCustomLists.remove(name);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                // System lists options
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9.0),
                        child: Container(
                          height: 1,
                          color: Colors.white.withOpacity(.25),
                        )),
                    _checkbox(
                      label: 'Hide from status lists',
                      checked: _hiddenFromStatusLists,
                      onChanged: (v) => setState(() => _hiddenFromStatusLists = v ?? false),
                    ),
                    _checkbox(
                      label: 'Private',
                      checked: _private,
                      onChanged: (v) => setState(() => _private = v ?? false),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFooter(FluentThemeData theme, Color accentColor) {
    return Row(
      children: [
        MouseButtonWrapper(
          tooltip: 'Exit without saving',
          child: (_) => StandardButton(
            onPressed: closeDialog,
            label: _isDeleting
                ? const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                : const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text('Cancel'),
                  ),
          ),
        ),
        const Spacer(),
        if (!_isNewEntry)
          MouseButtonWrapper(
            tooltip: 'Remove from Anilist',
            child: (isHovering) => StandardButton(
              onPressed: _isDeleting ? null : _confirmDelete,
              hoverColor: Colors.red,
              backgroundColor: Colors.red.lightest,
              isFilled: true,
              label: _isDeleting
                  ? const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: Text('Remove', style: TextStyle(color: isHovering ? Colors.white : Colors.black)),
                    ),
            ),
          ),
      ],
    );
  }

  void _confirmDelete() {
    showSimpleManagedDialog(
      context,
      id: 'anilist:entry-editor:confirm-delete',
      title: 'Remove Entry',
      body: 'Remove this entry from your AniList? This cannot be undone.',
      positiveButtonText: 'Remove',
      negativeButtonText: 'Cancel',
      isPositiveButtonPrimary: true,
      onPositive: _delete,
    );
  }

  // Field builders

  Widget _field(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: FluentTheme.of(context).typography.caption),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  Widget _dateField(String label, DateValue? value, ValueChanged<DateValue?> onChanged) {
    // if (Manager.settings.datePickerType == DatePickerType.spinner) {
    return _field(
      label,
      SizedBox(
        height: 32,
        child: Row(
          children: [
            Expanded(
              child: DatePicker(
                selected: value?.toDateTime(),
                onChanged: (DateTime picked) {
                  onChanged(DateValue.fromDateTime(picked));
                },
              ),
            ),
            if (value != null && !value.isEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  icon: const Icon(FluentIcons.clear, size: 10),
                  onPressed: () => onChanged(null),
                ),
              ),
          ],
        ),
      ),
    );
    // }

    // TODO when upgrading to fluent_ui 4.15+:
    // final theme = FluentTheme.of(context);
    // final hasValue = value != null && !value.isEmpty;
    // final displayText = hasValue ? value.toString() : '';

    // return _field(
    //   label,
    //   MouseButtonWrapper(
    //     child: (_) => SizedBox(
    //       height: 32,
    //       child: Button(
    //         onPressed: () async {
    //           final initial = value?.toDateTime();
    //           await showDatePickerDialog(context, initial: initial, onDateSelected: (date) => onChanged(DateValue.fromDateTime(date)));
    //         },
    //         style: ButtonStyle(padding: const WidgetStatePropertyAll(EdgeInsets.only(bottom: 4.3, top: 4.3, left: 11.5, right: 7))),
    //         child: Row(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             FluentAnimatedIcon.image(
    //               staticIcon: FluentAnimationStaticIcon.png('assets/icons/spiral_calendar_3d.png'),
    //               animatedIcon: FluentAnimationAnimatedIcon.gif('assets/icons/spiral_calendar_animated.gif'),
    //               playMode: FluentAnimationPlayMode.once,
    //               size: 20,
    //             ),
    //             const SizedBox(width: 6),
    //             Expanded(
    //               child: Text(
    //                 displayText,
    //                 style: theme.typography.body?.copyWith(
    //                   color: hasValue ? null : theme.typography.caption?.color,
    //                 ),
    //                 overflow: TextOverflow.ellipsis,
    //               ),
    //             ),
    //             if (hasValue)
    //               GestureDetector(
    //                 onTap: () => onChanged(null),
    //                 child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(FluentIcons.clear, size: 10, color: theme.typography.caption?.color)),
    //               ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget _checkbox({required String label, required bool checked, required ValueChanged<bool?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: TooltipWrapper(
        tooltip: label,
        child: (l) => Checkbox(
          checked: checked,
          onChanged: onChanged,
          content: Expanded(
            child: Text(
              l,
              style: FluentTheme.of(context).typography.body,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

// TODO when upgrading to fluent_ui 4.15+:
/// Show a simple date picker dialog and return the selected date
///
/// Uses Flutter's native date picker (via showDatePicker) to avoid flyout issues when nested inside a managed dialog
// Future<void> showDatePickerDialog(BuildContext context, {DateTime? initial, required void Function(DateTime)? onDateSelected}) async {
//   DateTime selectedDate = initial ?? now;

//   await showPaddedDialog(
//     context,
//     navigationItem: DialogNavigationItem(id: 'date-picker', title: 'Select Date'),
//     builder: (context, item, options) {
//       return PaddedDialog.simple(
//         navigationItem: item,
//         barrierOptions: options,
//         title: Text('Select Date', style: Manager.titleStyle),
//         constraints: BoxConstraints(
//           maxWidth: 400,
//           minWidth: 300,
//           maxHeight: 450,
//           minHeight: 350,
//         ),
//         content: StatefulBuilder(builder: (context, setState) {
//           return CalendarView(
//             initialStart: selectedDate,
//             selectionMode: CalendarViewSelectionMode.single,
//             isOutOfScopeEnabled: false,
//             isGroupLabelVisible: false,
//             onSelectionChanged: (value) {
//               if (value.selectedDates.isNotEmpty) onDateSelected?.call(value.selectedDates.first);
//             },
//           );
//         }),
//         actions: [
//           StandardButton.label(
//             onPressed: closeDialog,
//             label: 'Cancel',
//           ),
//           StandardButton.label(
//             onPressed: () {
//               onDateSelected?.call(selectedDate);
//               closeDialog();
//             },
//             label: 'Save',
//             isFilled: true,
//           ),
//         ],
//       );
//     },
//   );
// }
