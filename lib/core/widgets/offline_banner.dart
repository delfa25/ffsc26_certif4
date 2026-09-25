import 'package:flutter/material.dart';

/// Bannière visuelle informant l'utilisateur que l'application est en mode hors-ligne
/// et que les données proviennent du cache local Hive.
class OfflineBanner extends StatelessWidget {
  final String featureName;

  const OfflineBanner({
    super.key,
    this.featureName = 'Données',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.amber.shade900,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mode hors-ligne : $featureName affichés depuis le cache local Hive',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
