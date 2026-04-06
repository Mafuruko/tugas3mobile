import 'dart:io';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'note.dart';

class NoteDatabase extends ChangeNotifier {
  static late Isar isar;

  // initialize database
  static Future<void> initialize() async {
    final dir = Platform.isAndroid
        ? await getApplicationDocumentsDirectory()
        : await getTemporaryDirectory();

    isar = await Isar.open(
      [NoteSchema],
      directory: dir.path,
    );
  }

  // current notes in app
  final List<Note> currentNotes = [];

  // create
  Future<void> addNote(String textFromUser) async {
    final newNote = Note()..text = textFromUser;

    await isar.writeTxn(() async {
      await isar.notes.put(newNote);
    });

    await fetchNotes();
  }

  // read
  Future<void> fetchNotes() async {
    final fetchedNotes = await isar.notes.where().findAll();

    currentNotes.clear();
    currentNotes.addAll(fetchedNotes);

    notifyListeners();
  }

  // update
  Future<void> updateNote(int id, String newText) async {
    final existingNote = await isar.notes.get(id);

    if (existingNote != null) {
      existingNote.text = newText;

      await isar.writeTxn(() async {
        await isar.notes.put(existingNote);
      });

      await fetchNotes();
    }
  }

  // delete
  Future<void> deleteNote(int id) async {
    await isar.writeTxn(() async {
      await isar.notes.delete(id);
    });

    await fetchNotes();
  }
}