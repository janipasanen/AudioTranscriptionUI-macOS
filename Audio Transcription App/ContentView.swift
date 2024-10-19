//
//  ContentView.swift
//  Audio Transcription App
//
//  Created by Jani Pasanen on 2024-10-18.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var transcriptionManager = TranscriptionManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("Audio Transcription App")
                .font(.largeTitle)
                .padding(.top)

            // File selection button
            Button(action: transcriptionManager.selectAudioFile) {
                Text("Select M4A File")
            }
            .disabled(transcriptionManager.isProcessing)

            // Status message
            Text(transcriptionManager.statusMessage)
                .foregroundColor(.gray)

            // Scrollable Whisper output text box (continuous output)
            ScrollView {
                Text(transcriptionManager.whisperOutputText)
                    .padding()
                    .frame(minWidth: 650, minHeight: 190, alignment: .leading)
                    .border(Color.gray, width: 1)
            }
            .frame(maxHeight: 250)

            // Scrollable transcription text box (transcription from file)
            ScrollView {
                Text(transcriptionManager.transcriptionText)
                    .padding()
                    .frame(minWidth: 650, minHeight: 190, alignment: .leading)
                    .border(Color.gray, width: 1)
            }
            .frame(maxHeight: 250)

            // Transcribe button
            Button(action: transcriptionManager.transcribeAudio) {
                Text("Transcribe Audio")
            }
            .disabled(transcriptionManager.selectedFileURL == nil || transcriptionManager.isProcessing)

            // Copy to clipboard button
            Button(action: transcriptionManager.copyToClipboard) {
                Text("Copy to Clipboard")
            }
            .disabled(transcriptionManager.isCopyButtonDisabled || transcriptionManager.isProcessing)

            Spacer()
        }
        .padding()
        .frame(width: 700, height: 700)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
