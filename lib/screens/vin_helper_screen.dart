import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class VinHelperScreen extends StatefulWidget {
  const VinHelperScreen({super.key});

  @override
  State<VinHelperScreen> createState() => _VinHelperScreenState();
}

class _VinHelperScreenState extends State<VinHelperScreen> {
  int _expandedIndex = -1;

  static const List<_VinLocation> _locations = [
    _VinLocation(
      title: 'Targhetta sul cruscotto',
      description:
          "Visibile dall'esterno attraverso il parabrezza, lato passeggero. "
          "\u00c8 il metodo pi\u00f9 semplice per auto dal 1981 in poi.",
      icon: Icons.dashboard_outlined,
    ),
    _VinLocation(
      title: 'Montante portiera',
      description:
          'Aprendo la portiera lato guida, sul montante verticale trovi '
          "un'etichetta con il VIN e altre informazioni.",
      icon: Icons.sensor_door_outlined,
    ),
    _VinLocation(
      title: 'Vano motore',
      description:
          'Targhetta rivettata nel vano motore, spesso sulla parete '
          'parafiamma o sul passaruota. Comune in auto italiane pre-1981.',
      icon: Icons.miscellaneous_services_outlined,
    ),
    _VinLocation(
      title: 'Libretto di circolazione',
      description:
          'Il numero di telaio \u00e8 riportato alla voce (E) del libretto '
          "di circolazione. Puoi fotografare il libretto e l'app legger\u00e0 "
          'il VIN automaticamente.',
      icon: Icons.description_outlined,
    ),
    _VinLocation(
      title: 'Bagagliaio',
      description:
          'Sotto il tappetino del bagagliaio o sul passaruota posteriore. '
          'Tipico di Fiat 500, 600, 850.',
      icon: Icons.luggage_outlined,
    ),
    _VinLocation(
      title: 'Certificato ASI',
      description:
          "Se l'auto \u00e8 iscritta all'ASI, il numero di telaio \u00e8 riportato "
          'sul certificato di rilevanza storica.',
      icon: Icons.verified_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        foregroundColor: context.colors.textPrimary,
        title: Text(
          'Dove trovo il telaio?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // Header
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.colors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.border, width: 1),
              ),
              child: Icon(
                Icons.search,
                color: context.colors.textPrimary,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Dove trovo il numero di telaio?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Il VIN (Vehicle Identification Number) pu\u00f2 trovarsi '
            'in diverse posizioni a seconda del modello e dell\'anno.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Expandable cards
          ...List.generate(_locations.length, (index) {
            final location = _locations[index];
            final isExpanded = _expandedIndex == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isExpanded ? context.colors.textPrimary : context.colors.border,
                    width: isExpanded ? 1.5 : 1,
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    key: ValueKey('vin_location_$index'),
                    initiallyExpanded: isExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _expandedIndex = expanded ? index : -1;
                      });
                    },
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    childrenPadding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: context.colors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        location.icon,
                        color: context.colors.textPrimary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      location.title,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color:
                            isExpanded ? context.colors.textPrimary : context.colors.textSecondary,
                      ),
                    ),
                    children: [
                      Text(
                        location.description,
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Info note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: context.colors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Per auto dal 1981 in poi, il VIN ha sempre 17 caratteri. '
                    'Per auto precedenti, il formato varia per marca.',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // CTA button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.textPrimary,
                foregroundColor: context.colors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Ho capito',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VinLocation {
  final String title;
  final String description;
  final IconData icon;

  const _VinLocation({
    required this.title,
    required this.description,
    required this.icon,
  });
}
