import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/url_entry.dart';
import 'page_status_row.dart';

class HomeUserPages extends StatelessWidget {
  final List<UrlEntry> userPages;
  final Future<void> Function(String pageId, String newUrl, String? newUrlName) onEditUrl;
  final Future<void> Function(String pageId) onDeleteUrl;
  final String timezone;

  const HomeUserPages({
    super.key,
    required this.userPages,
    required this.onEditUrl,
    required this.onDeleteUrl,
    required this.timezone,
  });

Future<void> _showEditDialog(BuildContext context, UrlEntry entry) async {
  final TextEditingController editUrlController = TextEditingController(text: entry.url);
  final TextEditingController editUrlNameController = TextEditingController(text: entry.urlName);

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.white.withOpacity(0.28),
          width: 2.0,
        ),
      ),
      elevation: 14,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      titlePadding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 6),
      title: Text(
        'Edit page',
        style: GoogleFonts.epilogue(fontWeight: FontWeight.w700, fontSize: 24),
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.only(left: 28, right: 28, bottom: 8, top: 2),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Text(
            "Update the page URL or name.",
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          TextField(
            controller: editUrlNameController,
            decoration: InputDecoration(
              labelText: 'Page Name (optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            ),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: editUrlController,
            decoration: InputDecoration(
              labelText: 'Page URL',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (editUrlController.text.trim().isEmpty) return;
                  await onEditUrl(
                    entry.id,
                    editUrlController.text.trim(),
                    editUrlNameController.text.trim().isEmpty ? null : editUrlNameController.text.trim(),
                  );
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Page updated.')),
                  );
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> _showDeleteConfirmDialog(BuildContext context, String pageId) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.white.withOpacity(0.28),
          width: 2.0,
        ),
      ),
      elevation: 14,
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      titlePadding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 6),
      title: Text(
        "Delete page?",
        style: GoogleFonts.epilogue(fontWeight: FontWeight.w700, fontSize: 24),
        textAlign: TextAlign.center,
      ),
      contentPadding: const EdgeInsets.only(left: 28, right: 28, bottom: 16, top: 2),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Text(
            "Are you sure you want to delete this page? All logs and records for this page will also be deleted.",
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: GoogleFonts.epilogue(fontSize: 16, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await onDeleteUrl(pageId);
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Page deleted.')),
                  );
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Delete'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: Column(
          children: [
            const SizedBox(height: 38),
            Text(
              "My Pages",
              style: GoogleFonts.epilogue(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (userPages.isEmpty)
              Text(
                'You have not added any pages yet.',
                style: GoogleFonts.inter(fontSize: 15, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ...userPages.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: Colors.grey.withOpacity(0.22),
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                    child: Column(
                      children: [
                        PageStatusRowWidget(page: entry, timezone: timezone),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: "Edit",
                              onPressed: () => _showEditDialog(context, entry),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: "Delete",
                              onPressed: () => _showDeleteConfirmDialog(context, entry.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Divider(height: 44, thickness: 1, color: Colors.grey.withOpacity(0.14)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
