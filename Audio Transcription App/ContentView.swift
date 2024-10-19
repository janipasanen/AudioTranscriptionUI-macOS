//
//  ContentView.swift
//  Audio Transcription App
//
//  Created by Jani Pasanen on 2024-10-18.
//

import SwiftUI
import Speech
import AVFoundation

struct ContentView: View {
    @State private var selectedFileURL: URL? = nil
    @State private var transcriptionText: String = ""
    @State private var statusMessage: String = "Select an M4A file to transcribe"
    @State private var isProcessing: Bool = false

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

            // Transcription text box
            ScrollView {
                Text(transcriptionText)
                    .padding()
                    .frame(minHeight: 200)
                    .frame(minWidth: 350)
                    .border(Color.gray, width: 1)
            }
            .frame(maxHeight: 200)
            
            // Transcribe button
            Button(action: transcribeAudio) {
                Text("Transcribe Audio")
            }
            .disabled(selectedFileURL == nil || isProcessing)

            Spacer()
        }
        .padding()
        .frame(width: 400, height: 400)
        /*
        .onAppear {
            requestSpeechRecognitionAuthorization()
        }
         */
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

    // Function to handle audio transcription
    func transcribeAudio() {
        guard let audioURL = selectedFileURL else { return }
        isProcessing = true
        statusMessage = "Transcribing audio..."

        // Set a path for the transcription output file
        let outputDirectory = FileManager.default.temporaryDirectory
        let outputFilePath = outputDirectory.appendingPathComponent("transcription.txt")
        
        // Run the shell command to transcribe
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")

        // Update the Whisper script to output to the known file path
        let script = """
        whisper '\(audioURL.path)' --language sv --output_format txt --output_dir '\(outputDirectory.path)'
        """

        task.arguments = ["-c", script]

        // Capture errors from Whisper, if any
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        task.terminationHandler = { _ in
            // Read the transcription output file
            DispatchQueue.main.async {
                do {
                    let transcriptionOutput = try String(contentsOf: outputFilePath, encoding: .utf8)
                    self.transcriptionText = transcriptionOutput
                    self.statusMessage = "Transcription complete."
                } catch {
                    self.statusMessage = "Error reading transcription output: \(error.localizedDescription)"
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
    
    /*
    // Request authorization for speech recognition
    func requestSpeechRecognitionAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    print("Speech recognition denied by the user")
                case .restricted:
                    print("Speech recognition restricted on this device")
                case .notDetermined:
                    print("Speech recognition not determined yet")
                @unknown default:
                    fatalError()
                }
            }
        }
    }
     */
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
