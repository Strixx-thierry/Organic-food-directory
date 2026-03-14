import 'package:flutter/material.dart';

class ExternalLinkPage extends StatelessWidget {
  const ExternalLinkPage({super.key});

  // Placeholder links — will be loaded from Firestore
  static const List<Map<String, dynamic>> _links = [
    {
      'title': 'USDA Organic Certification',
      'description': 'Official organic standards and certification info',
      'url': 'https://www.ams.usda.gov/organic',
      'category': 'Government',
      'icon': Icons.verified_outlined,
      'color': Color(0xFF1B5E20),
    },
    {
      'title': 'Organic Trade Association',
      'description': 'Latest organic industry news and research',
      'url': 'https://www.ota.com',
      'category': 'Industry',
      'icon': Icons.business_outlined,
      'color': Color(0xFF2E7D32),
    },
    {
      'title': 'EWG Dirty Dozen List',
      'description': 'Yearly guide to most pesticide-heavy produce',
      'url': 'https://www.ewg.org/foodnews/dirty-dozen.php',
      'category': 'Research',
      'icon': Icons.science_outlined,
      'color': Colors.teal,
    },
    {
      'title': 'Rodale Institute',
      'description': 'Regenerative organic agriculture research',
      'url': 'https://rodaleinstitute.org',
      'category': 'Research',
      'icon': Icons.eco_outlined,
      'color': Colors.green,
    },
    {
      'title': 'Local Harvest',
      'description': 'Find local organic farms and farmers markets',
      'url': 'https://www.localharvest.org',
      'category': 'Directory',
      'icon': Icons.location_on_outlined,
      'color': Colors.orange,
    },
    {
      'title': 'Non-GMO Project',
      'description': 'Verified non-GMO products and standards',
      'url': 'https://www.nongmoproject.org',
      'category': 'Certification',
      'icon': Icons.check_circle_outline,
      'color': Colors.blue,
    },
  ];

  static const List<String> _categories = [
    'All',
    'Government',
    'Industry',
    'Research',
    'Directory',
    'Certification',
  ];

  @override
  Widget build(BuildContext context) {
    return _ExternalLinkContent(links: _links, categories: _categories);
  }
}

class _ExternalLinkContent extends StatefulWidget {
  final List<Map<String, dynamic>> links;
  final List<String> categories;
  const _ExternalLinkContent(
      {required this.links, required this.categories});

  @override
  State<_ExternalLinkContent> createState() => _ExternalLinkContentState();
}

class _ExternalLinkContentState extends State<_ExternalLinkContent> {
  String _selectedCategory = 'All';

  List<Map<String, dynamic>> get _filtered => _selectedCategory == 'All'
      ? widget.links
      : widget.links
          .where((l) => l['category'] == _selectedCategory)
          .toList();

  void _openLink(BuildContext context, String url, String title) {
    // In production, use url_launcher package: launchUrl(Uri.parse(url))
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Open Link',
            style: TextStyle(
                color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
        content: Text(
          'Open "$title" in your browser?\n\n$url',
          style: TextStyle(color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Open',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF1B5E20)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'External Links',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Text(
              'Trusted organic food resources',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Category Filter Chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.categories.length,
                itemBuilder: (ctx, i) {
                  final cat = widget.categories[i];
                  final selected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF2E7D32)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Links List
            Expanded(
              child: ListView.builder(
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) => _linkCard(_filtered[i], context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkCard(Map<String, dynamic> link, BuildContext context) {
    final color = link['color'] as Color;
    return GestureDetector(
      onTap: () => _openLink(context, link['url'], link['title']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(link['icon'] as IconData, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          link['title'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          link['category'],
                          style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    link['description'],
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.link, size: 13, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          link['url'],
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.open_in_new, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}