import 'package:flutter/material.dart';
import 'package:players_app/data/home_data.dart';
import 'package:players_app/models/home_category.dart';
import 'package:players_app/screens/home/players.dart';
import 'package:players_app/screens/home/teams.dart';
import 'package:players_app/widgets/home/home_grid_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _selectCategory(BuildContext context, HomeCategory category) {
    if (category.id == "c1") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => PlayersScreen()));
    }
    if (category.id == "c2") {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => TeamsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GridView(
          padding: const EdgeInsets.all(24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 7 / 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20),
          children: [
            for (final category in availableCategories)
              HomeGridItem(
                  category: category,
                  onSelectCategory: () {
                    _selectCategory(context, category);
                  })
          ],
        ),
      ),
    );
  }
}
