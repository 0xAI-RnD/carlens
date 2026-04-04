import 'package:flutter/material.dart';

class VinHelperScreen extends StatefulWidget {
  const VinHelperScreen({super.key});

  @override
  State<VinHelperScreen> createState() => _VinHelperScreenState();
}

class _VinHelperScreenState extends State<VinHelperScreen> {
  static const _bgColor = Color(0xFFFAFAF8);
  static const _textPrimary = Color(0xFF1A1A1A);
  static const _textSecondary = Color(0xFF8C8C8C);
  static const _textTertiary = Color(0xFFB0B0B0);
  static const _borderColor = Color(0xFFE8E8E6);
  static const _surfaceLight = Color(0xFFF0F0EE);

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
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        foregroundColor: _textPrimary,
        title: const Text(
          'Dove trovo il telaio?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: _textPrimary,
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
                color: _surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(color: _borderColor, width: 1),
              ),
              child: const Icon(
                Icons.search,
                color: _textPrimary,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Dove trovo il numero di telaio?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Il VIN (Vehicle Identification Number) pu\u00f2 trovarsi '
            'in diverse posizioni a seconda del modello e dell\'anno.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textSecondary,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isExpanded ? _textPrimary : _borderColor,
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
                        color: _surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        location.icon,
                        color: _textPrimary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      location.title,
                      style: const TextStyle(
                        color: _textPrimary,
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
                            isExpanded ? _textPrimary : _textSecondary,
                      ),
                    ),
                    children: [
                      Text(
                        location.description,
                        style: const TextStyle(
                          color: _textSecondary,
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
              color: _surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: _textSecondary,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Per auto dal 1981 in poi, il VIN ha sempre 17 caratteri. '
                    'Per auto precedenti, il formato varia per marca.',
                    style: TextStyle(
                      color: _textSecondary,
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
                backgroundColor: _textPrimary,
                foregroundColor: _bgColor,
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
