import 'dart:typed_data';

class Draft {
  final String id;
  String originalImagePath; // Store the original file path
  String imagePath; // Store the cropped file path
  final DateTime timestamp;
  final Map<String, dynamic> edits;
  String title; // Title of the draft project (optional)
  Uint8List imageData; // Store the image data as bytes
  Uint8List originalImageData; // Store the original image data as bytes

  Draft(
      {required this.id,
      required this.originalImagePath,
      required this.imagePath,
      required this.timestamp,
      required this.edits,
      required this.title,
      required this.imageData,
      required this.originalImageData});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalImagePath': originalImagePath,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'edits': edits,
      'title': title,
    };
  }

  factory Draft.fromMap(Map<String, dynamic> map, Uint8List imageData,
      Uint8List originalImageData) {
    return Draft(
        id: map['id'],
        originalImagePath: map['originalImagePath'],
        imagePath: map['imagePath'],
        timestamp: DateTime.parse(map['timestamp']),
        edits: Map<String, dynamic>.from(map['edits']),
        title: map['title'],
        imageData: imageData,
        originalImageData: originalImageData);
  }
}
