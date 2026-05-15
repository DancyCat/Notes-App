import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../i18n/strings.g.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    // Cache textTheme tránh gọi lại nhiều lần
    final textTheme = Theme.of(context).textTheme;

    return Card(
      // FIX: Clip.hardEdge thay vì Clip.antiAlias
      // hardEdge nhẹ hơn antiAlias khi kết hợp với elevation shadow
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => context.push('/note/${note.id}', extra: note),
        child: ListTile(
          title: Text(note.title, style: textTheme.titleMedium),
          subtitle: Text(
            t.note_card.created_at.replaceAll(
              '{date}',
              DateFormat.yMd().add_jm().format(note.createdAt),
            ),
            style: textTheme.bodySmall,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(t.note_card.delete_confirm_title),
                  content: Text(t.note_card.delete_confirm_content),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(t.note_card.cancel_button),
                    ),
                    FilledButton.tonal(
                      onPressed: () {
                        Provider.of<NoteProvider>(context, listen: false)
                            .deleteNote(note.id);
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t.note_card.note_deleted_snackbar),
                          ),
                        );
                      },
                      child: Text(t.note_card.delete_button),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
