# Audio Transcription App

A macOS application that allows users to transcribe audio files (in `.m4a` format) using Whisper, an open-source speech recognition model. The app provides a simple user interface where you can select an audio file, transcribe it, and view both the transcription progress and the final result. Additionally, the app supports copying the final transcription to the clipboard.

## Features

- Supports `.m4a` audio files.
- Uses Whisper for speech-to-text transcription.
- Displays transcription progress and results in real-time.
- Allows copying the final transcription to the clipboard.
- Works with multiple languages, with the default set to Swedish (`sv`).
- Output stored in `.txt` format with the same name as the audio file.

## Requirements

- macOS
- Swift 5.3 or later
- Xcode 12.1 or later
- Whisper installed via Anaconda
- FFmpeg installed for audio processing

## Installation

### 1. Clone the repository

```
git clone https://github.com/janipasanen/AudioTranscriptionUI-macOS.git
cd AudioTranscriptionUI-macOS
```

2. Install Whisper

Ensure that Whisper is installed via Anaconda.

```
conda install -c conda-forge whisper
```

Make sure whisper and ffmpeg are accessible in your system’s PATH.


3. Install FFmpeg and coreutils

You can install FFmpeg and coreutils via Homebrew:

```
brew install ffmpeg coreutils

```

4. Build the project

Open the project in Xcode:

```
open AudioTranscriptionApp.xcodeproj
```

Build and run the app using Xcode.


Usage

    Launch the application.
    Click on the "Select M4A File" button to choose an audio file.
    Click "Transcribe Audio" to start the transcription process.
    View transcription progress in the upper text box and the final result in the lower text box.
    Use the "Copy to Clipboard" button to copy the transcription.


Troubleshooting
FFmpeg Not Found

If you receive errors related to FFmpeg not being found, ensure that FFmpeg is installed and added to your system’s PATH. You can verify by running:

```
which ffmpeg
```

If it is not found, reinstall FFmpeg via Homebrew as mentioned above.
Whisper Not Found

If the Whisper executable is not found, ensure that Anaconda's environment variables are correctly set up, and that Whisper is installed.

You can check if Whisper is installed by running:

```
which whisper
```

If you still encounter issues, ensure that you modify the PATH in the project’s environment setup.
