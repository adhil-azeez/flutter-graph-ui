import 'package:flutter/material.dart';
import 'package:flutter_graph_ui/utils/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class BottomTabSelWidget extends StatelessWidget {
  const BottomTabSelWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => _ThisFabSelProvider(),
          )
        ],
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: colorE6F0FB,
                  spreadRadius: 6,
                  blurRadius: 20,
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIconButton(
                  iconData: FontAwesomeIcons.home,
                  index: 0,
                ),
                const SizedBox(width: 24),
                _buildIconButton(
                  iconData: FontAwesomeIcons.exchangeAlt,
                  index: 1,
                ),
                const SizedBox(width: 36),
                _buildIconButton(
                  iconData: FontAwesomeIcons.chartLine,
                  index: 2,
                ),
              ],
            ),
          );
        });
  }

  Widget _buildIconButton({required IconData iconData, required int index}) {
    return Consumer<_ThisFabSelProvider>(builder: (context, provider, _) {
      Color color = const Color(0xFFC6D5E8);

      if (provider.index == index) {
        color = color21DCB6;
      }

      return IconButton(
        splashColor: Colors.transparent,
        onPressed: () => provider.index = index,
        icon: Center(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: FittedBox(
              child: FaIcon(iconData),
            ),
          ),
        ),
        color: color,
        iconSize: 32,
      );
    });
  }
}

class _ThisFabSelProvider extends ChangeNotifier {
  int _index = 2;

  int get index => _index;

  set index(int val) {
    _index = val;
    notifyListeners();
  }
}
