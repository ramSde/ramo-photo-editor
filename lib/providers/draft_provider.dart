import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/draft_model.dart';

class DraftProvider with ChangeNotifier {
  List<Draft> _drafts = [];
  Draft? _currentDraft;

  List<Draft> get drafts => _drafts;

  Draft? get currentDraft => _currentDraft;

  // Load drafts from file storage
  Future<void> loadDrafts() async {
    final directory = await _getLocalDirectory();
    final draftDir = Directory('${directory.path}/drafts');

    if (!await draftDir.exists()) {
      await draftDir.create();
    }

    _drafts.clear(); // Clear the existing drafts list

    final draftFiles = draftDir.listSync();
    for (var file in draftFiles) {
      if (file is File && file.path.endsWith('.json')) {
        final draftData = await file.readAsString();
        final Map<String, dynamic> map = jsonDecode(draftData);

        // Read the image file as bytes
        final imageFile = File('${draftDir.path}/${map['id']}.png');
        Uint8List imageData = await imageFile.readAsBytes();

        // Read the original image file as bytes
        final originalImageFile = File('${draftDir.path}/${map['id']}_original.png');
        Uint8List originalImageData = await originalImageFile.readAsBytes();

        // Create the Draft object
        _drafts.add(Draft.fromMap(map, imageData, originalImageData));
      }
    }
    notifyListeners();
  }

  // Save a new or updated draft to file storage
  Future<void> saveDraft(Draft draft) async {
    final directory = await _getLocalDirectory();
    final draftDir = Directory('${directory.path}/drafts');

    if (!await draftDir.exists()) {
      await draftDir.create();
    }

    // Save the draft metadata (JSON)
    String draftData = jsonEncode(draft.toMap());
    File draftFile = File('${draftDir.path}/${draft.id}.json');
    await draftFile.writeAsString(draftData);

    // Save the image data (image file)
    File imageFile = File('${draftDir.path}/${draft.id}.png');
    await imageFile.writeAsBytes(draft.imageData);

    // Save the original image data (image file)
    File originalImageFile = File('${draftDir.path}/${draft.id}_original.png');
    await originalImageFile.writeAsBytes(draft.originalImageData);

    // Check if the draft already exists in the list
    int index = _drafts.indexWhere((d) => d.id == draft.id);
    if (index != -1) {
      _drafts[index] = draft; // Update the existing draft
    } else {
      _drafts.add(draft); // Add as a new draft
    }
    notifyListeners();
  }

  // Delete a draft from file storage
  Future<void> deleteDraft(String draftId) async {
    final directory = await _getLocalDirectory();
    final draftDir = Directory('${directory.path}/drafts');

    // Remove the draft metadata and image files
    File draftFile = File('${draftDir.path}/$draftId.json');
    if (await draftFile.exists()) {
      await draftFile.delete();
    }

    File imageFile = File('${draftDir.path}/$draftId.png');
    if (await imageFile.exists()) {
      await imageFile.delete();
    }

    File originalImageFile = File('${draftDir.path}/$draftId}_original.png');
    if (await originalImageFile.exists()) {
      await originalImageFile.delete();
    }

    // Remove the draft from the local list and notify listeners
    _drafts.removeWhere((draft) => draft.id == draftId);
    notifyListeners();
  }

  // Set the current draft for editing
  void setCurrentDraft(Draft? draft) {
    _currentDraft = draft;
    notifyListeners();
  }

  // Create a new draft
  void createNewDraft() {
    _currentDraft = Draft(
      id: _generateId(),
      imagePath: '',
      timestamp: DateTime.now(),
      edits: {},
      title: '',
      imageData: Uint8List(0),
      originalImagePath: '',
      originalImageData: Uint8List(0), // Empty original image data
    );
    notifyListeners();
  }

  // Update the title of the current draft
  void updateCurrentDraftTitle(String title) {
    if (_currentDraft != null) {
      _currentDraft!.title = title;
      _addEditToCurrentDraft('title', title);
      notifyListeners();
    }
  }

  // Update the image data of the current draft
  void updateCurrentDraftImage(Uint8List imageData, String? imagePath) {
    if (_currentDraft != null) {
      _currentDraft!.imageData = imageData;
      _currentDraft!.imagePath = imagePath ?? '';

      if (_currentDraft?.originalImagePath == null || _currentDraft!.originalImagePath.isEmpty) {
        _currentDraft!.originalImagePath = imagePath ?? '';
        _currentDraft!.originalImageData = imageData;
      }

      _addEditToCurrentDraft('image', base64Encode(imageData));
      notifyListeners();
    }
  }

  // Save the current draft (only if it's new or updated)
  Future<void> saveCurrentDraft() async {
    if (_currentDraft != null) {
      await saveDraft(_currentDraft!);
      _currentDraft = null; // Reset current draft after saving
      notifyListeners();
    }
  }

  // Private helper to add edits to the current draft's edits map
  void _addEditToCurrentDraft(String field, String value) {
    if (_currentDraft != null) {
      _currentDraft!.edits[field] = value;
    }
  }

  // Helper method to get the app's local directory
  Future<Directory> _getLocalDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  // Utility method to generate a unique ID for a new draft
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
