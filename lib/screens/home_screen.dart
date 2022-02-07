import 'package:flutter/material.dart';
import 'package:flutter_graph_ui/utils/colors.dart';
import 'package:flutter_graph_ui/widgets/bottom_tab_sel_widget.dart';
import 'package:flutter_graph_ui/widgets/graph_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const BottomTabSelWidget(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _ThisTopHeaderWidget(),
          GraphWidget(),
        ],
      ),
    );
  }
}

class _ThisTopHeaderWidget extends StatelessWidget {
  const _ThisTopHeaderWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: color21DCB6,
      ),
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top).add(
        const EdgeInsets.only(
          top: 36,
          left: 24,
          right: 24,
          bottom: 24,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Portfolio",
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: Colors.white),
                ),
              ),
              const FaIcon(
                FontAwesomeIcons.circleNotch,
                color: Colors.white,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 36),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "\$5370.98",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "+\$530",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    FaIcon(
                      FontAwesomeIcons.arrowUp,
                      size: 14,
                      color: color21DCB6,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "5.89%",
                      style: TextStyle(
                          color: color21DCB6,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
