import 'package:path/path.dart' as p;

import '../utils/path.dart';
import 'anilist/mapping.dart';
import 'episode.dart';
import 'season.dart';
import 'series.dart';

/// A node in a [Series]' folder tree: one directory, derived purely from the
/// flat `series.collections` paths (no model/schema change — the scanner already
/// emits one collection per directory at every depth, each with its full path).
///
/// The series root is itself a node: its loose root files come from the synthetic
/// `__uncategorized__` [Folder] (whose path == the series path), and its
/// seasons/folders are its child nodes. So "series screen" and "folder screen"
/// are the same thing — rendering one [FolderNode].
class FolderNode {
  /// Absolute, normalized path of this directory.
  final PathString path;

  /// Display name: the series name for the root; otherwise the collection's
  /// pretty name, or the leaf folder name for synthesized intermediate dirs.
  final String displayName;

  /// The scanned collection located exactly at [path], if any. Null for
  /// synthesized intermediate directories that contain only sub-folders
  /// (e.g. `Extras/` whose only content is `Extras/BD/ep.mkv`).
  final EpisodeCollection? collection;

  /// AniList mapping whose `localPath == path`, if this folder is linked.
  final AnilistMapping? mapping;

  /// Child folder nodes (sub-directories), pre-sorted for display.
  final List<FolderNode> children;

  /// Episodes located directly in this directory (not in sub-folders).
  final List<Episode> directEpisodes;

  /// All episodes at or below this node, recursively (cached at build time).
  final List<Episode> subtreeEpisodes;

  /// Whether this node is the series root.
  final bool isRoot;

  FolderNode({
    required this.path,
    required this.displayName,
    required this.collection,
    required this.mapping,
    required this.children,
    required this.directEpisodes,
    required this.subtreeEpisodes,
    required this.isRoot,
  });

  bool get isLinked => mapping != null;
  bool get hasChildren => children.isNotEmpty;
  bool get hasDirectEpisodes => directEpisodes.isNotEmpty;

  /// Whether this node corresponds to a numbered [Season].
  bool get isSeason => collection is Season;
  int? get seasonNumber => collection is Season ? (collection as Season).seasonNumber : null;

  // Recursive progress (decision: a folder represents everything inside it).
  int get watchedCount => subtreeEpisodes.where((e) => e.watched).length;
  int get totalCount => subtreeEpisodes.length;
  double get watchedPercentage => totalCount > 0 ? watchedCount / totalCount : 0.0;
}

/// Build the full folder tree for [series], rooted at the series directory.
FolderNode buildFolderTree(Series series) {
  final rootStr = series.path.path;

  // Index collections + folder-level mappings by normalized path.
  final collectionByPath = <String, EpisodeCollection>{};
  for (final c in series.collections) //
    collectionByPath[c.path.path] = c;

  final mappingByPath = <String, AnilistMapping>{};
  for (final m in series.anilistMappings) {
    final lp = m.localPath.pathMaybe;
    if (lp != null) mappingByPath[lp] = m;
  }

  // Map keys must stay byte-consistent with collectionByPath keys (which come
  // from PathString.path, i.e. PathUtils.normalizePath). p.dirname does NOT run
  // through that normalization (it skips the long-path `\\?\` prefix and `..`
  // collapsing), so normalize every dirname result before using it as a key,
  // otherwise a real collection could fail the exact-match lookup and be treated
  // as an empty synthetic node.
  String norm(String s) => PathUtils.normalizePath(s) ?? s;

  // Gather every directory node path: the root, plus each collection (except the
  // uncategorized-at-root) and all of its ancestor directories up to the root.
  // Climbing ancestors synthesizes intermediate container dirs that have no
  // collection of their own, so the tree stays navigable.
  final nodePaths = <String>{rootStr};
  for (final c in series.collections) {
    final cp = c.path.path;
    if (p.equals(cp, rootStr)) continue; // uncategorized lives at the root
    String cur = cp;
    while (!p.equals(cur, rootStr) && p.isWithin(rootStr, cur)) {
      nodePaths.add(cur);
      cur = norm(p.dirname(cur));
    }
  }

  // parent path -> child paths
  final childrenByParent = <String, List<String>>{};
  for (final np in nodePaths) {
    if (p.equals(np, rootStr)) continue;
    (childrenByParent[norm(p.dirname(np))] ??= []).add(np);
  }

  FolderNode buildNode(String nodeStr, bool isRoot) {
    final collection = collectionByPath[nodeStr];
    final mapping = mappingByPath[nodeStr];

    final childNodes = [for (final cp in (childrenByParent[nodeStr] ?? const <String>[])) buildNode(cp, false)];
    _sortChildren(childNodes);

    final directEpisodes = collection?.episodes ?? const <Episode>[];
    final subtree = <Episode>[
      ...directEpisodes,
      for (final c in childNodes) ...c.subtreeEpisodes,
    ];

    return FolderNode(
      path: PathString(nodeStr),
      displayName: isRoot ? series.name : (collection?.prettyName ?? p.basename(nodeStr)),
      collection: collection,
      mapping: mapping,
      children: childNodes,
      directEpisodes: directEpisodes,
      subtreeEpisodes: subtree,
      isRoot: isRoot,
    );
  }

  return buildNode(rootStr, true);
}

/// Find the node at [nodePath] within an already-built [tree], or null.
FolderNode? findNodeInTree(FolderNode tree, PathString nodePath) {
  final target = nodePath.path;
  FolderNode? found;

  void walk(FolderNode n) {
    if (found != null) return;
    if (p.equals(n.path.path, target)) {
      found = n;
      return;
    }
    for (final c in n.children) walk(c);
  }

  walk(tree);
  return found;
}

/// Resolve the [FolderNode] at [nodePath] within [series], or null if not found.
/// Builds the whole tree each call — prefer [buildFolderTree] + [findNodeInTree]
/// against a cached tree in hot paths (e.g. widget build).
FolderNode? resolveNode(Series series, PathString nodePath) => findNodeInTree(buildFolderTree(series), nodePath);

/// Default child ordering: seasons first (ascending by number), then folders
/// alphabetically, with the synthetic `Uncategorized` folder last. Matches
/// `AnilistProgressManager`'s season-first intent.
void _sortChildren(List<FolderNode> nodes) {
  nodes.sort((a, b) {
    final sa = a.seasonNumber;
    final sb = b.seasonNumber;
    if (sa != null && sb != null) return sa.compareTo(sb);
    if (sa != null) return -1; // seasons before folders
    if (sb != null) return 1;

    final ua = a.collection is Folder && (a.collection as Folder).isUncategorized;
    final ub = b.collection is Folder && (b.collection as Folder).isUncategorized;
    if (ua && !ub) return 1; // uncategorized last
    if (ub && !ua) return -1;

    return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
  });
}
