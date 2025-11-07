import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss

    // Editable fields
    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var job: String = ""
    @State private var hometown: String = ""
    @State private var sexuality: String = ""
    @State private var lookingFor: String = ""
    @State private var drinking: String = ""
    @State private var smoking: String = ""
    @State private var kids: String = ""
    @State private var selectedInterests: Set<String> = []

    // Photo management
    @State private var photos: [String] = []
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    // UI State
    @State private var showingInterestPicker = false
    @State private var hasChanges = false

    // Initialize on appear to use the actual environment object
    @State private var isInitialized = false
    @State private var allowChangeTracking = false

    private func initializeFields(from user: User) {
        guard !isInitialized else { return }
        name = user.name
        bio = user.bio
        age = String(user.age)
        height = user.height ?? ""
        job = user.job ?? ""
        hometown = user.hometown ?? ""
        sexuality = user.sexuality ?? ""
        lookingFor = user.lookingFor ?? ""
        drinking = user.drinking ?? ""
        smoking = user.smoking ?? ""
        kids = user.kids ?? ""
        selectedInterests = Set(user.interests)
        photos = user.photos
        isInitialized = true
        hasChanges = false
        DispatchQueue.main.async {
            allowChangeTracking = true
        }
    }

    private var formSnapshot: ProfileFormSnapshot {
        ProfileFormSnapshot(
            name: name,
            bio: bio,
            age: age,
            height: height,
            job: job,
            hometown: hometown,
            sexuality: sexuality,
            lookingFor: lookingFor,
            drinking: drinking,
            smoking: smoking,
            kids: kids,
            interests: selectedInterests,
            photos: photos
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Photo Section
                    profilePhotoSection

                    Divider()

                    // Basic Info
                    basicInfoSection

                    Divider()

                    // Interests
                    interestsSection

                    Divider()

                    // Stats
                    statsSection

                    Divider()

                    // Lifestyle
                    lifestyleSection
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .fontWeight(.bold)
                    .disabled(!hasChanges)
                }
            }
            .onChange(of: formSnapshot) { _, _ in
                guard allowChangeTracking else { return }
                hasChanges = true
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                if let newItem = newItem {
                    loadPhoto(from: newItem)
                }
            }
            .onAppear {
                initializeFields(from: viewModel.currentUser)
            }
        }
    }

    private func loadPhoto(from item: PhotosPickerItem) {
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                // Save image to temporary storage and add photo ID
                await MainActor.run {
                    let photoId = savePhotoToTemp(image: uiImage)
                    photos.append(photoId)
                    selectedPhotoItem = nil // Reset for next selection

                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
            }
        }
    }

    private func savePhotoToTemp(image: UIImage) -> String {
        // Save image to temporary directory
        let tempDir = FileManager.default.temporaryDirectory
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = tempDir.appendingPathComponent(filename)

        if let imageData = image.jpegData(compressionQuality: 0.85) {
            do {
                try imageData.write(to: fileURL, options: .atomic)
                return fileURL.path
            } catch {
                print("Failed to save photo: \(error.localizedDescription)")
            }
        }

        // Fallback to identifier if writing failed
        return filename
    }

    // MARK: - Profile Photo Section
    private var profilePhotoSection: some View {
        VStack(spacing: 16) {
            Text("Photos")
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<6) { index in
                        if index < photos.count {
                            // Existing photo
                            ZStack(alignment: .topTrailing) {
                                PhotoPlaceholderView(
                                    photoId: photos[index],
                                    aspectRatio: 4/5
                                )
                                .frame(width: 120, height: 160)
                                .cornerRadius(12)

                                // Delete button
                                Button(action: {
                                    deletePhoto(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .background(
                                            Circle()
                                                .fill(Color.black.opacity(0.6))
                                                .frame(width: 28, height: 28)
                                        )
                                }
                                .padding(8)
                            }
                        } else {
                            // Add photo placeholder with PhotosPicker
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                VStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))

                                    Text("Add Photo")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 120, height: 160)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
            }

            Text("Add at least 2 photos to get more matches")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(spacing: 16) {
            Text("Basic Info")
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                EditField(label: "Name", text: $name, placeholder: "Your name")

                EditField(
                    label: "Bio",
                    text: $bio,
                    placeholder: "Tell us about yourself...",
                    isMultiline: true
                )
            }
        }
    }

    // MARK: - Interests Section
    private var interestsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Interests")
                    .font(.system(size: 20, weight: .bold))

                Spacer()

                Button(action: {
                    showingInterestPicker = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                }
            }

            if selectedInterests.isEmpty {
                Text("No interests selected. Tap 'Add' to choose your interests.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 100), spacing: 8)
                ], spacing: 8) {
                    ForEach(Array(selectedInterests), id: \.self) { interest in
                        if let category = DiscoveryCategory.allCases.first(where: { $0.rawValue == interest }) {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 12, weight: .bold))
                                Text(category.rawValue)
                                    .font(.system(size: 14, weight: .semibold))

                                Button(action: {
                                    selectedInterests.remove(interest)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(category.color)
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingInterestPicker) {
            InterestPickerView(selectedInterests: $selectedInterests)
        }
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        VStack(spacing: 16) {
            Text("About You")
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                EditField(label: "Age", text: $age, placeholder: "25", keyboardType: .numberPad)
                EditField(label: "Height", text: $height, placeholder: "5'10\"")
                EditField(label: "Job", text: $job, placeholder: "Your profession")
                EditField(label: "Hometown", text: $hometown, placeholder: "City, Country")
                EditField(label: "Sexuality", text: $sexuality, placeholder: "Straight, Gay, Bisexual, etc.")
                EditField(label: "Looking For", text: $lookingFor, placeholder: "Relationship, Friends, etc.")
            }
        }
    }

    // MARK: - Lifestyle Section
    private var lifestyleSection: some View {
        VStack(spacing: 16) {
            Text("Lifestyle")
                .font(.system(size: 20, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                EditField(label: "Drinking", text: $drinking, placeholder: "Never, Socially, Often")
                EditField(label: "Smoking", text: $smoking, placeholder: "Never, Sometimes, Often")
                EditField(label: "Kids", text: $kids, placeholder: "No, Yes, Want someday")
            }
        }
    }

    // MARK: - Actions
    private func saveProfile() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        // Validate age is in reasonable range
        let validatedAge = Int(age) ?? viewModel.currentUser.age
        let finalAge = max(18, min(99, validatedAge))

        // Update user in view model
        viewModel.updateCurrentUser(
            name: name,
            bio: bio,
            age: finalAge,
            height: height.isEmpty ? nil : height,
            job: job.isEmpty ? nil : job,
            hometown: hometown.isEmpty ? nil : hometown,
            sexuality: sexuality.isEmpty ? nil : sexuality,
            lookingFor: lookingFor.isEmpty ? nil : lookingFor,
            drinking: drinking.isEmpty ? nil : drinking,
            smoking: smoking.isEmpty ? nil : smoking,
            kids: kids.isEmpty ? nil : kids,
            interests: Array(selectedInterests)
        )

        // Update photos
        viewModel.updateUserPhotos(photos)

        dismiss()
    }

    private func deletePhoto(at index: Int) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        guard index < photos.count else { return }

        // Remove photo from array
        photos.remove(at: index)
    }
}

// MARK: - Edit Field Component
struct EditField: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    var isMultiline: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            if isMultiline {
                TextEditor(text: $text)
                    .frame(minHeight: 100)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        Group {
                            if text.isEmpty {
                                Text(placeholder)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 20)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    .allowsHitTesting(false)
                            }
                        }
                    )
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .font(.system(size: 16))
                    .padding(14)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
        }
    }
}

// MARK: - Interest Picker
struct InterestPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedInterests: Set<String>
    @State private var tempSelection: Set<String>

    init(selectedInterests: Binding<Set<String>>) {
        self._selectedInterests = selectedInterests
        self._tempSelection = State(initialValue: selectedInterests.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(DiscoveryCategory.allCases) { category in
                        Button(action: {
                            toggleInterest(category.rawValue)
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(tempSelection.contains(category.rawValue) ? .white : category.color)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        tempSelection.contains(category.rawValue) ?
                                        category.color : category.color.opacity(0.15)
                                    )
                                    .cornerRadius(12)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(category.rawValue)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)

                                    Text(category.description)
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if tempSelection.contains(category.rawValue) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(category.color)
                                }
                            }
                            .padding(12)
                            .background(Color(.systemGray6).opacity(tempSelection.contains(category.rawValue) ? 0.5 : 1))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Select Interests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        selectedInterests = tempSelection
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }

    private func toggleInterest(_ interest: String) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        if tempSelection.contains(interest) {
            tempSelection.remove(interest)
        } else {
            tempSelection.insert(interest)
        }
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AppViewModel())
}

// MARK: - Snapshot used for change tracking
private struct ProfileFormSnapshot: Equatable {
    var name: String
    var bio: String
    var age: String
    var height: String
    var job: String
    var hometown: String
    var sexuality: String
    var lookingFor: String
    var drinking: String
    var smoking: String
    var kids: String
    var interests: Set<String>
    var photos: [String]
}
