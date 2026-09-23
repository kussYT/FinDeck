import 'package:findeck/app/provisional_section_page.dart';
import 'package:flutter/material.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProvisionalSectionPage(
      title: 'Collection',
      message: 'Cet écran est provisoire. Les cartes, les packs et les gemmes '
          'ne sont pas encore développés.',
    );
  }
}
