//
//  TranscriptionManager.swift
//  Audio Transcription App
//
//  Created by Jani Pasanen on 2024-10-20.
//

import Foundation
import AppKit

class TranscriptionManager: ObservableObject {
    @Published var whisperOutputText: String = ""
    @Published var transcriptionText: String = ""
    @Published var statusMessage: String = "Select an M4A file to transcribe"
    @Published var isProcessing: Bool = false
    @Published var isCopyButtonDisabled: Bool = true
    var selectedFileURL: URL? = nil

    // Function to open a file picker
    func selectAudioFile() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["m4a"]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false

        if panel.runModal() == .OK {
            selectedFileURL = panel.url
            statusMessage = "File selected: \(panel.url?.lastPathComponent ?? "")"
        }
    }

    // Function to handle audio transcription with continuous output
    func transcribeAudio() {
        guard let audioURL = selectedFileURL else { return }
        isProcessing = true
        isCopyButtonDisabled = true
        statusMessage = "Transcribing audio..."

        // Reset output fields
        whisperOutputText = ""
        transcriptionText = ""

        // Set a path for the transcription output file
        let outputDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let audioFileName = audioURL.deletingPathExtension().lastPathComponent
        let outputFilePath = outputDirectory.appendingPathComponent("\(audioFileName).txt")

        // Run the shell command to transcribe
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")

        // Set the PATH environment variable to ensure ffmpeg can be found
        task.environment = ProcessInfo.processInfo.environment
        task.environment?["PATH"] = "/usr/local/bin:/opt/anaconda3/bin:/usr/bin:/bin:/usr/sbin:/sbin"

        let script = """
        /opt/anaconda3/bin/whisper '\(audioURL.path)' --language sv --output_format txt --output_dir '\(outputDirectory.path)'
        """

        task.arguments = ["-c", script]

        // Capture output and errors from Whisper
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        task.terminationHandler = { [weak self] _ in
            guard let self = self else { return }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""

            DispatchQueue.main.async {
                // Display Whisper output continuously
                self.whisperOutputText = output

                // Check if transcription file exists
                if FileManager.default.fileExists(atPath: outputFilePath.path) {
                    self.isCopyButtonDisabled = false
                    do {
                        let transcription = try String(contentsOf: outputFilePath, encoding: .utf8)
                        self.transcriptionText = transcription
                        self.statusMessage = "Transcription complete."
                    } catch {
                        self.statusMessage = "Failed to read transcription file."
                    }
                } else {
                    self.isCopyButtonDisabled = true
                    self.statusMessage = "Transcription file not found at \(outputFilePath.path)"
                }
                self.isProcessing = false
            }
        }

        do {
            try task.run()
        } catch {
            statusMessage = "Error running Whisper: \(error.localizedDescription)"
            isProcessing = false
        }
    }

    // Copy transcription text to clipboard
    func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(transcriptionText, forType: .string)
    }
}
