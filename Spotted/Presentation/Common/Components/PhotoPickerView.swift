import SwiftUI
import PhotosUI

// MARK: - Enhanced Photo Picker
struct EnhancedPhotoPickerView: View {
    @Binding var selectedPhotos: [String]
    let maxPhotos: Int
    @State private var showImagePicker = false
    @State private var draggedPhoto: String?

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add Photos")
                        .font(.system(size: 24, weight: .bold))

                    Text("\(selectedPhotos.count) of \(maxPhotos) photos")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()

                if !selectedPhotos.isEmpty {
                    Button("Clear All") {
                        withAnimation(.easeOut(duration: 0.3)) {
                            selectedPhotos.removeAll()
                        }
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                }
            }
            .padding(.horizontal, 20)

            // Photo Grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<maxPhotos, id: \.self) { index in
                    if index < selectedPhotos.count {
                        // Existing photo
                        PhotoThumbnail(
                            photoId: selectedPhotos[index],
                            index: index,
                            isMain: index == 0
                        ) {
                            // Remove photo
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                let _ = selectedPhotos.remove(at: index)
                            }
                        }
                    } else {
                        // Empty slot
                        AddPhotoButton(index: index) {
                            showImagePicker = true
                        }
                    }
                }
            }
            .padding(.horizontal, 20)

            // Tips
            VStack(alignment: .leading, spacing: 12) {
                TipRow(icon: "sparkles", text: "First photo is your profile picture", color: .pink)
                TipRow(icon: "photo.stack", text: "Add at least 2 photos for best results", color: .blue)
                TipRow(icon: "face.smiling", text: "Photos with your face get 4x more matches", color: .orange)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerPlaceholder(selectedPhotos: $selectedPhotos, maxPhotos: maxPhotos)
        }
    }
}

// MARK: - Photo Thumbnail
struct PhotoThumbnail: View {
    let photoId: String
    let index: Int
    let isMain: Bool
    let onRemove: () -> Void

    @State private var showContent = false

    var body: some View {
        ZStack {
            PhotoPlaceholderView(photoId: photoId, aspectRatio: 0.75)
                .frame(height: 160)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isMain ? Color(red: 252/255, green: 108/255, blue: 133/255) : Color.clear, lineWidth: 3)
                )

            // Main badge
            if isMain {
                VStack {
                    HStack {
                        Text("MAIN")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(red: 252/255, green: 108/255, blue: 133/255))
                            .cornerRadius(4)
                            .padding(8)

                        Spacer()
                    }
                    Spacer()
                }
            }

            // Remove button
            VStack {
                HStack {
                    Spacer()

                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.3), radius: 2)
                            .padding(8)
                    }
                }
                Spacer()
            }

            // Index number
            VStack {
                Spacer()
                HStack {
                    Text("\(index + 1)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .padding(8)

                    Spacer()
                }
            }
        }
        .scaleEffect(showContent ? 1 : 0.8)
        .opacity(showContent ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showContent = true
            }
        }
    }
}

// MARK: - Add Photo Button
struct AddPhotoButton: View {
    let index: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.7))

                Text(index == 0 ? "Add Main Photo" : "Add Photo")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundColor(Color.gray.opacity(0.3))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tip Row
struct TipRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

// MARK: - Image Picker Placeholder
struct ImagePickerPlaceholder: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedPhotos: [String]
    let maxPhotos: Int

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
                            if selectedPhotos.count < maxPhotos && !selectedPhotos.contains(photoId) {
                                selectedPhotos.append(photoId)
                            }
                        } label: {
                            ZStack {
                                PhotoPlaceholderView(photoId: photoId, aspectRatio: 1.0)
                                    .frame(height: 120)

                                if selectedPhotos.contains(photoId) {
                                    Color.black.opacity(0.5)

                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .navigationTitle("Select Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                }
            }
        }
    }
}

#Preview {
    EnhancedPhotoPickerView(selectedPhotos: .constant(["photo1", "photo2"]), maxPhotos: 6)
}
