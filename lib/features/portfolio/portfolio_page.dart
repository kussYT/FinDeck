import 'package:findeck/app/provisional_section_page.dart';
import 'package:flutter/material.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProvisionalSectionPage(
      title: 'Portefeuille',
      message: 'Cet écran est provisoire. La saisie des opérations fictives '
          'n\'est pas encore disponible. Les calculs du domaine ne sont pas '
          'affichés ici. Aucun résultat financier n\'est affiché.',
    );
  }
}
