import 'package:flutter/material.dart';

class CardTierSection extends StatefulWidget {
  final String tierName;
  final Color tierColor;
  final int visitsCount;

  const CardTierSection({
    super.key,
    required this.tierName,
    required this.tierColor,
    required this.visitsCount,
  });

  @override
  State<CardTierSection> createState() => _CardTierSectionState();
}

class _CardTierSectionState extends State<CardTierSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.star, color: widget.tierColor),
            title: Text(
              widget.tierName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: widget.tierColor,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Visits: ${widget.visitsCount}', style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visit History:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  // Placeholder for visit history list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3, // Example count
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('- Restaurant ${index + 1}: Date/Time'),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
