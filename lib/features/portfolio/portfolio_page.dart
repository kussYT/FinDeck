import 'package:findeck/app/provisional_section_page.dart';
import 'package:flutter/material.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProvisionalSectionPage(
      title: 'Portefeuille',
      message:
          'Cet écran est provisoire. Les opérations fictives et les calculs '
          'ne sont pas encore développés. Aucun résultat financier n\'est affiché.',
    );
  }
}
