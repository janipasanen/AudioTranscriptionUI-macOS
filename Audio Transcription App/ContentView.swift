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
        .onAppear {
            requestSpeechRecognitionAuthorization()
        }
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
        requestSpeechRecognitionAuthorization()
        guard let audioURL = selectedFileURL else { return }
        isProcessing = true
        statusMessage = "Processing transcription..."

        // Directly transcribe the M4A file without conversion
        transcribeAudioFile(at: audioURL) { result, error in
            DispatchQueue.main.async {
                isProcessing = false

                if let error = error {
                    statusMessage = "Error: \(error.localizedDescription)"
                } else if let result = result {
                    transcriptionText = result
                    statusMessage = "Transcription complete."
                }
            }
        }
    }

    // Function to perform transcription
    func transcribeAudioFile(at url: URL, completion: @escaping (String?, Error?) -> Void) {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "sv-SE"))!
        let request = SFSpeechURLRecognitionRequest(url: url)

        recognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                completion(result.bestTranscription.formattedString, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
