# TagFix

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![FOSS](https://img.shields.io/badge/FOSS-100%25-success)](https://github.com/k44yn3/tagfixandroid)
[![Platform](https://img.shields.io/badge/Platform-Android-green)](https://github.com/k44yn3/tagfixandroid)

A powerful audio metadata editor for Android supporting FLAC, MP3, M4A, OGG, OPUS, WMA, and WAV formats.

## Features

- **Metadata**: Edit Title, Artist, Album, Year, Genre, Track/Disc
- **Cover Art**: Update album artwork (Local/Online)
- **Lyrics**: Search and embed synchronized lyrics (LRCLIB)
- **MusicBrainz**: Automatic metadata lookup
- **Scanning**: Recursive directory processing
- **Material You**: Modern dynamic theming with dark mode

## Screenshots
![ss](1.png)

## Requirements

**Minimum Android Version:** Android 7.0 (API 24)

**Permissions:**
- Storage/Media Access
- Internet

## Building

**Prerequisites**
- Flutter SDK (3.24.0+)
- Android SDK with API 24+
- Java 17

```bash
git clone https://github.com/k44yn3/tagfixandroid.git
cd tagfixandroid/flutter_app
flutter pub get
flutter build apk --release
```
## To-do

- [ ] Implement batch editing mode
- [ ] Implement lyrics romanization
- [ ] Better file managing
- [ ] Audio format conversion

## Credits

- [Flutter](https://flutter.dev/)
- [FFmpeg](https://www.ffmpeg.org/)
- [MusicBrainz](https://musicbrainz.org/)
- [Lrclib](https://lrclib.net/)
- [LRCGET](https://github.com/tranxuanthang/lrcget)
