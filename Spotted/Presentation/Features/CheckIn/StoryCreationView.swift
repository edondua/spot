import SwiftUI
import PhotosUI

struct StoryCreationView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss

    let location: Location

    @State private var selectedPhoto: String?
    @State private var showPhotoPicker = false
    @State private var caption = ""
    @State private var showPreview = false

    var body: some View {
        NavigationStack {
            ZStack {
                if let photo = selectedPhoto {
                    // Preview with editing tools
                    storyPreviewView(photo: photo)
                } else {
                    // Photo selection
                    photoSelectionView
                }
            }
            .navigationTitle("Create Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                if selectedPhoto != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Share") {
                            shareStory()
                        }
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                    }
                }
            }
        }
    }

    // MARK: - Photo Selection View
    private var photoSelectionView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            Image(systemName: "photo.stack.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.7))

            // Instructions
            VStack(spacing: 12) {
                Text("Share Your Moment")
                    .font(.system(size: 28, weight: .bold))

                Text("Add a photo to share what you're up to at \(location.name)")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            // Select Photo Button
            Button(action: {
                showPhotoPicker = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 20, weight: .semibold))

                    Text("Choose Photo")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 252/255, green: 108/255, blue: 133/255),
                            Color(red: 234/255, green: 88/255, blue: 120/255)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.3), radius: 12, y: 6)
            }
            .padding(.horizontal, 40)

            Spacer()

            // Tips
            VStack(spacing: 12) {
                TipRow(icon: "camera.fill", text: "Stories disappear after 24 hours", color: .blue)
                TipRow(icon: "eye.fill", text: "Only visible to people at this location", color: .purple)
                TipRow(icon: "sparkles", text: "Add captions to make your story stand out", color: .orange)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .sheet(isPresented: $showPhotoPicker) {
            ImagePickerForStory(selectedPhoto: $selectedPhoto)
        }
    }

    // MARK: - Story Preview View
    private func storyPreviewView(photo: String) -> some View {
        ZStack {
            // Photo background
            PhotoPlaceholderView(photoId: photo, aspectRatio: 9/16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            // Gradient overlays for readability
            LinearGradient(
                colors: [Color.black.opacity(0.5), Color.clear, Color.black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Caption editor
            VStack {
                Spacer()

                // Caption text field
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "text.bubble.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))

                        Text("Add a caption")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))

                        Spacer()
                    }

                    TextField("What's happening?", text: $caption)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                        .textFieldStyle(.plain)
                }
                .padding(20)
                .background(Color.black.opacity(0.3))
                .cornerRadius(16)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }

            // Location badge
            VStack {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 16))

                        Text(location.name)
                            .font(.system(size: 15, weight: .semibold))

                        Text("•")
                            .font(.system(size: 12))
                            .opacity(0.7)

                        Text("Just now")
                            .font(.system(size: 14))
                            .opacity(0.8)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(20)
                    .padding(20)

                    Spacer()
                }

                Spacer()
            }
        }
    }

    // MARK: - Actions
    private func shareStory() {
        guard let photo = selectedPhoto else { return }

        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()

        // Create and post story
        viewModel.postStory(at: location, imageUrl: photo, caption: caption.isEmpty ? nil : caption)

        // Show success toast
        Task { @MainActor in
            ToastManager.shared.showSuccess("Story shared!")
        }

        // Dismiss after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

// MARK: - Image Picker for Stories
struct ImagePickerForStory: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedPhoto: String?

    // Simulated photo library
    let availablePhotos = (1...20).map { "photo\($0)" }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 2) {
                    ForEach(availablePhotos, id: \.self) { photoId in
                        Button {
                            selectedPhoto = photoId
                            dismiss()
                        } label: {
                            PhotoPlaceholderView(photoId: photoId, aspectRatio: 1.0)
                                .frame(height: 120)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Select Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    StoryCreationView(location: Location(
        id: "loc1",
        name: "Central Perk Café",
        type: .cafe,
        address: "123 Manhattan Ave",
        latitude: 40.7580,
        longitude: -73.9855,
        activeUsers: 12
    ))
    .environmentObject(AppViewModel())
}
