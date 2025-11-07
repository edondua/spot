import Foundation

struct ProfilePrompt: Identifiable, Codable, Hashable {
    let id: String
    let question: String
    let answer: String
    var hasVoiceRecording: Bool = false // NEW: Voice prompt support
    var voiceDuration: Int? // Duration in seconds

    init(id: String = UUID().uuidString,
         question: String,
         answer: String,
         hasVoiceRecording: Bool = false,
         voiceDuration: Int? = nil) {
        self.id = id
        self.question = question
        self.answer = answer
        self.hasVoiceRecording = hasVoiceRecording
        self.voiceDuration = voiceDuration
    }

    var durationDisplay: String? {
        guard let duration = voiceDuration else { return nil }
        let minutes = duration / 60
        let seconds = duration % 60
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "0:%02d", seconds)
        }
    }
}
