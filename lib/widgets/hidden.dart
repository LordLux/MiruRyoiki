import 'package:fluent_ui/fluent_ui.dart';

class LocalHidden extends StatelessWidget {
  const LocalHidden({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Tooltip(
        message: 'Hidden inside this app',
        child: Icon(
          FluentIcons.hide2, // or use FluentIcons.hide2 or FluentIcons.eye_hide
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

class AnilistHidden extends StatelessWidget {
  const AnilistHidden({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Tooltip(
        message: 'Hidden from Anilist status lists',
        child: Icon(
          FluentIcons.hide, // or use FluentIcons.hide2 or FluentIcons.eye_hide
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
