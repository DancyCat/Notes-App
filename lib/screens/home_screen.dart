import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/note_provider.dart';
import '../widgets/add_note_sheet.dart';
import '../widgets/note_card.dart';
import '../i18n/strings.g.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    // Cache colorScheme tránh gọi lại nhiều lần trong build
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: t.home_screen.search_hint,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: onSurface.withValues(alpha: 0.5),
                  ),
                ),
                style: TextStyle(color: onSurface, fontSize: 18),
                onChanged: (_) {},
              )
            : Text(t.app_name),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchText = '';
                  FocusScope.of(context).unfocus();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      // FIX: Chỉ dùng Consumer — bỏ Provider.of ở ngoài
      // Trước đây dùng cả 2 → screen rebuild 2 lần mỗi khi notes thay đổi
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          if (noteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredNotes = _searchText.isEmpty
              ? noteProvider.notes
              : noteProvider.notes.where((note) {
                  return note.title
                      .toLowerCase()
                      .contains(_searchText.toLowerCase());
                }).toList();

          if (filteredNotes.isEmpty) {
            return Center(
              child: Text(
                _searchText.isEmpty
                    ? t.home_screen.no_notes_empty_state
                    : t.home_screen.no_notes_found_search
                        .replaceAll('{searchText}', _searchText),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredNotes.length,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: NoteCard(note: filteredNotes[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddNoteSheet(context),
        label: Text(t.home_screen.create_note_button),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
