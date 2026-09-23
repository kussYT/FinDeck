import 'package:findeck/app/provisional_section_page.dart';
import 'package:flutter/material.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProvisionalSectionPage(
      title: 'Marché',
      message:
          'Cet écran est provisoire. Le catalogue, la recherche et les cours '
          'ne sont pas encore développés. Aucune donnée de marché n\'est affichée.',
    );
  }
}
