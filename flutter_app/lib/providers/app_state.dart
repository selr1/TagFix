import 'package:flutter/material.dart';
import 'package:audiotags/audiotags.dart';
import '../models/audio_file.dart';
import '../services/file_service.dart';
import '../services/tag_service.dart';
import '../services/ffmpeg_service.dart';

class AppState extends ChangeNotifier {
  final FileService _fileService = FileService();
  final TagService _tagService = TagService();
  final FfmpegService _ffmpegService = FfmpegService();

  List<AudioFile> _files = [];
  List<AudioFile> get files => _files;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _currentDirectory;
  String? get currentDirectory => _currentDirectory;

  AudioFile? _selectedFile;
  AudioFile? get selectedFile => _selectedFile;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<AudioFile> get filteredFiles {
    if (_searchQuery.isEmpty) return _files;
    final query = _searchQuery.toLowerCase();
    return _files.where((file) {
      final title = (file.tags?.title ?? file.filename).toLowerCase();
      final artist = (file.tags?.trackArtist ?? '').toLowerCase();
      final album = (file.tags?.album ?? '').toLowerCase();
      return title.contains(query) || artist.contains(query) || album.contains(query);
    }).toList();
  }

  Future<void> scanDirectory(String path) async {
    _isLoading = true;
    _currentDirectory = path;
    notifyListeners();

    _files = await _fileService.scanDirectory(path);
    
    
    _isLoading = false;
    notifyListeners();
    
    _loadTags();
  }

  Future<void> _loadTags() async {
    for (int i = 0; i < _files.length; i++) {
      if (_files[i].tags == null) {
        _files[i] = await _tagService.readTags(_files[i]);
        notifyListeners(); 
      }
    }
  }

  void selectFile(AudioFile? file) {
    _selectedFile = file;
    notifyListeners();
  }

  Future<bool> updateTags(AudioFile file, {
    String? title,
    String? artist,
    String? album,
    String? albumArtist,
    String? year,
    String? genre,
    String? trackNumber,
    String? discNumber,
  }) async {
    if (file.tags == null) return false;

    final newTags = Tag(
      title: title ?? file.tags?.title,
      trackArtist: artist ?? file.tags?.trackArtist,
      album: album ?? file.tags?.album,
      albumArtist: albumArtist ?? file.tags?.albumArtist,
      year: year != null ? int.tryParse(year) : file.tags?.year,
      genre: genre ?? file.tags?.genre,
      trackNumber: trackNumber != null ? int.tryParse(trackNumber) : file.tags?.trackNumber,
      trackTotal: file.tags?.trackTotal,
      discNumber: discNumber != null ? int.tryParse(discNumber) : file.tags?.discNumber,
      discTotal: file.tags?.discTotal,
      lyrics: file.tags?.lyrics,
      pictures: file.tags?.pictures ?? const [],
    );

    final success = await _tagService.writeTags(file, newTags);
    if (success) {
      final index = _files.indexOf(file);
      if (index != -1) {
        _files[index] = file.copyWith(tags: newTags);
        if (_selectedFile == file) {
          _selectedFile = _files[index];
        }
        notifyListeners();
      }
    }
    return success;
  }

  Future<void> renameFile(AudioFile file, String newFilename) async {
    final newPath = await _fileService.renameFile(file, newFilename);
    if (newPath != null) {
      final index = _files.indexOf(file);
      if (index != -1) {
        _files[index] = file.copyWith(
          path: newPath,
          filename: newFilename, 
        );
        if (_selectedFile == file) {
          _selectedFile = _files[index];
        }
        notifyListeners();
      }
    }
  }
  
  Future<void> reloadFile(AudioFile file) async {
    final index = _files.indexOf(file);
    if (index != -1) {
      _files[index] = await _tagService.readTags(_files[index]);
      if (_selectedFile == file) {
        _selectedFile = _files[index];
      }
      notifyListeners();
    }
  }
  
  void setPendingCover(AudioFile file, List<int> coverBytes) {
    final index = _files.indexOf(file);
    if (index != -1) {
      _files[index] = _files[index].copyWith(pendingCover: coverBytes);
      if (_selectedFile == file) {
        _selectedFile = _files[index];
      }
      notifyListeners();
    }
  }
  
  void setPendingLyrics(AudioFile file, String lyrics) {
    final index = _files.indexOf(file);
    if (index != -1) {
      _files[index] = _files[index].copyWith(pendingLyrics: lyrics);
      if (_selectedFile == file) {
        _selectedFile = _files[index];
      }
      notifyListeners();
    }
  }
  
  Future<bool> savePendingChanges(AudioFile file) async {
    bool success = true;
    
    if (file.pendingCover != null) {
      final coverSuccess = await _tagService.setCover(file, file.pendingCover!);
      if (!coverSuccess) success = false;
    }
    
    if (file.pendingLyrics != null) {
      final lyricsSuccess = await _tagService.setLyrics(file, file.pendingLyrics!);
      if (!lyricsSuccess) success = false;
    }
    
    if (success) {
      final index = _files.indexOf(file);
      if (index != -1) {
        _files[index] = _files[index].copyWith(
          clearPendingCover: true,
          clearPendingLyrics: true,
        );
        _files[index] = await _tagService.readTags(_files[index]);
        if (_selectedFile == file) {
          _selectedFile = _files[index];
        }
        notifyListeners();
      }
    }
    
    return success;
  }
  
  void discardPendingChanges(AudioFile file) {
    final index = _files.indexOf(file);
    if (index != -1) {
      _files[index] = _files[index].copyWith(
        clearPendingCover: true,
        clearPendingLyrics: true,
      );
      if (_selectedFile == file) {
        _selectedFile = _files[index];
      }
      notifyListeners();
    }
  }
  
  Future<void> convertSelectedToWav() async {
  }
}
