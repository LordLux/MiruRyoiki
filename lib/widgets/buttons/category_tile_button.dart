import 'package:fluent_ui/fluent_ui.dart';
import 'package:miruryoiki/widgets/buttons/button.dart';

import '../../manager.dart';
import '../../utils/color.dart';
import '../cutout.dart';

class CategoryTileButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onPressed;
  final double bottomPadding;

  const CategoryTileButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onPressed,
    this.bottomPadding = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    // When unselected, the icon is neutral white. When selected, it takes the category color.
    final Icon activeIcon = Icon(icon, color: isSelected ? color : Colors.white.withOpacity(0.75), size: 22);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: StandardButton(
        isFilled: isSelected,
        backgroundColor: isSelected ? color.withOpacity(.15) : null,
        hoverColor: color.withOpacity(.2),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 1.5),
            isSelected
                ? Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.25),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(child: activeIcon),
                  )
                : SquircleCutoutWidget(
                    borderRadius: 8.0,
                    size: const Size(35, 35),
                    color: Colors.white.withOpacity(0.15),
                    child: Center(child: activeIcon),
                  ),
            const SizedBox(width: 10),
            Text(
              title,
              style: isSelected ? Manager.bodyStrongStyle.copyWith(color: lighten(color, 0.4)) : Manager.bodyStyle.copyWith(color: Colors.white.withOpacity(.75)),
            ),
          ],
        ),
        onPressed: onPressed,
        expand: true,
        isWide: true,
        padding: const EdgeInsets.all(6),
        isSmall: false,
      ),
    );
  }
}
