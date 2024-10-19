//
//  ContentView.swift
//  Audio Transcription App
//
//  Created by Jani Pasanen on 2024-10-18.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var selectedFileURL: URL? = nil
    @State private var whisperOutputText: String = ""
    @State private var transcriptionText: String = ""
    @State private var statusMessage: String = "Select an M4A file to transcribe"
    @State private var isProcessing: Bool = false
    @State private var isCopyButtonDisabled: Bool = true

    var body: some View {
        VStack(spacing: 20) {
            Text("Audio Transcription App")
                .font(.largeTitle)
                .padding(.top)

            // File selection button
            Button(action: selectAudioFile) {
                Text("Select M4A File")
            }
            .disabled(isProcessing)

            // Status message
            Text(statusMessage)
                .foregroundColor(.gray)

            // Scrollable Whisper output text box (continuous output)
            ScrollView {
                Text(whisperOutputText)
                    .padding()
                    .frame(minWidth: 650, minHeight: 190, alignment: .leading)
                    .border(Color.gray, width: 1)
            }
            .frame(maxHeight: 250)

            // Scrollable transcription text box (transcription from file)
            ScrollView {
                Text(transcriptionText)
                    .padding()
                    .frame(minWidth: 650, minHeight: 190, alignment: .leading)
                    .border(Color.gray, width: 1)
            }
            .frame(maxHeight: 250)

            // Transcribe button
            Button(action: transcribeAudio) {
                Text("Transcribe Audio")
            }
            .disabled(selectedFileURL == nil || isProcessing)

            // Copy to clipboard button
            Button(action: copyToClipboard) {
                Text("Copy to Clipboard")
            }
            .disabled(isCopyButtonDisabled || isProcessing)

            Spacer()
        }
        .padding()
        .frame(width: 700, height: 700)
    }

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
        // Reset text in output fields
        self.whisperOutputText = ""
        self.transcriptionText = ""
        
        guard let audioURL = selectedFileURL else { return }
        isProcessing = true
        isCopyButtonDisabled = true
        statusMessage = "Transcribing audio..."

        // Set a path for the transcription output file (use same name as the audio file)
        let outputDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let audioFileName = audioURL.deletingPathExtension().lastPathComponent
        let outputFilePath = outputDirectory.appendingPathComponent("\(audioFileName).txt")

        // Run the shell command to transcribe
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")

        // Set the PATH environment variable to ensure ffmpeg can be found
        task.environment = ProcessInfo.processInfo.environment
        task.environment?["PATH"] = "/usr/local/bin:/opt/anaconda3/bin:/usr/bin:/bin:/usr/sbin:/sbin"

        // Update the Whisper script to specify the output directory and format
        let script = """
        /opt/homebrew/opt/coreutils/libexec/gnubin/stdbuf -oL /opt/anaconda3/bin/whisper '\(audioURL.path)' --language sv --output_format txt --output_dir '\(outputDirectory.path)'
        """

        task.arguments = ["-c", script]

        // Capture both stdout and stderr outputs from Whisper
        let stdoutPipe = Pipe()
        //let stderrPipe = Pipe()
        task.standardOutput = stdoutPipe
        //task.standardError = stderrPipe
        task.standardError = stdoutPipe  // Redirect stderr to the same pipe

        // Function to read pipe data continuously
        func readPipe(pipe: Pipe, appendTo outputField: @escaping (String) -> Void) {
            let fileHandle = pipe.fileHandleForReading
            let outputSource = DispatchSource.makeReadSource(fileDescriptor: fileHandle.fileDescriptor, queue: DispatchQueue.global())

            outputSource.setEventHandler {
                let outputData = fileHandle.availableData
                if !outputData.isEmpty {
                    if let output = String(data: outputData, encoding: .utf8) {
                        DispatchQueue.main.async {
                            outputField(output)
                        }
                    }
                } else {
                    outputSource.cancel()
                }
            }

            outputSource.setCancelHandler {
                fileHandle.closeFile()
            }

            outputSource.resume()
        }

        // Continuously read stdout and append to whisperOutputText
        readPipe(pipe: stdoutPipe) { output in
            self.whisperOutputText += output
        }

        // Continuously read stderr and append to whisperOutputText
       /*
        readPipe(pipe: stderrPipe) { output in
            self.whisperOutputText += output
        }
         */

        task.terminationHandler = { _ in
            DispatchQueue.main.async {
                // Check if transcription file exists
                if FileManager.default.fileExists(atPath: outputFilePath.path) {
                    isCopyButtonDisabled = false
                    
                    do {
                        let transcription = try String(contentsOf: outputFilePath, encoding: .utf8)
                        self.transcriptionText = transcription
                        self.statusMessage = "Transcription complete."
                    } catch {
                        self.statusMessage = "Failed to read transcription file."
                    }
                } else {
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
            isCopyButtonDisabled = true
        }
    }

    // Copy transcription text to clipboard
    func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(transcriptionText, forType: .string)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
