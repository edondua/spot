import SwiftUI

// MARK: - Quick Check-In Floating Button with Long Press Options
struct QuickCheckInButton: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showOptions = false
    @State private var showCheckInSheet = false
    @State private var showCameraView = false
    @State private var checkInType: CheckInType = .simple
    @State private var isPressed = false
    @State private var isLongPressing = false

    enum CheckInType {
        case simple
        case withPhoto
        case withNote
    }

    var body: some View {
        ZStack {
            // Backdrop when options shown
            if showOptions {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showOptions = false
                        }
                    }
                    .transition(.opacity)
            }

            VStack {
                Spacer()

                HStack {
                    Spacer()

                    VStack(spacing: 16) {
                        // Options (appear above button)
                        if showOptions {
                            VStack(spacing: 12) {
                                // Check-in with photo
                                OptionButton(
                                    icon: "camera.fill",
                                    label: "With Photo",
                                    color: .blue
                                ) {
                                    showCameraView = true
                                    withAnimation {
                                        showOptions = false
                                    }
                                }
                                .transition(.scale.combined(with: .opacity))

                                // Check-in with note
                                OptionButton(
                                    icon: "note.text",
                                    label: "With Note",
                                    color: .green
                                ) {
                                    checkInType = .withNote
                                    showCheckInSheet = true
                                    withAnimation {
                                        showOptions = false
                                    }
                                }
                                .transition(.scale.combined(with: .opacity))

                                // Simple check-in
                                OptionButton(
                                    icon: "checkmark.circle.fill",
                                    label: "Quick Check-in",
                                    color: Color(red: 252/255, green: 108/255, blue: 133/255)
                                ) {
                                    checkInType = .simple
                                    showCheckInSheet = true
                                    withAnimation {
                                        showOptions = false
                                    }
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }

                        // Main button
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 252/255, green: 108/255, blue: 133/255),
                                            Color(red: 255/255, green: 149/255, blue: 0/255)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 64, height: 64)
                                .shadow(color: Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.4), radius: 12, x: 0, y: 6)

                            Image(systemName: showOptions ? "xmark" : "mappin.and.ellipse")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(showOptions ? 90 : 0))
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showOptions)
                        }
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    isPressed = true
                                }
                                .onEnded { _ in
                                    isPressed = false
                                }
                        )
                        .onLongPressGesture(minimumDuration: 0.5, pressing: { pressing in
                            isLongPressing = pressing
                        }, perform: {
                            // Long press completed = show options
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()

                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                showOptions.toggle()
                            }
                        })
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 90) // Above tab bar
                }
            }
        }
        .sheet(isPresented: $showCheckInSheet) {
            CheckInSheetView(checkInType: checkInType)
        }
        .fullScreenCover(isPresented: $showCameraView) {
            CameraCaptureView(tappedCoordinate: nil)
        }
    }
}

// MARK: - Option Button
struct OptionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())

                Text(label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            )
            .frame(width: 220)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - Check-In Sheet
struct CheckInSheetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AppViewModel
    let checkInType: QuickCheckInButton.CheckInType

    @State private var selectedLocation: Location?
    @State private var caption: String = ""
    @State private var showImagePicker = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Check In")
                            .font(.system(size: 28, weight: .bold))

                        Text(headerSubtitle)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)

                // Location picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Where are you?")
                        .font(.system(size: 18, weight: .bold))
                        .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(MockDataService.shared.zurichLocations.filter { location in
                                // Exclude water bodies (sea, lake)
                                let name = location.name.lowercased()
                                return !name.contains("see") &&
                                       !name.contains("lake") &&
                                       !name.contains("zürichsee") &&
                                       !name.contains("promenade")
                            }) { location in
                                LocationSelectionRow(
                                    location: location,
                                    isSelected: selectedLocation?.id == location.id
                                ) {
                                    selectedLocation = location
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // Caption field (if with note or photo)
                if checkInType == .withNote || checkInType == .withPhoto {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add a caption")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(.horizontal)

                        TextField("What's happening?", text: $caption, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .lineLimit(3...6)
                    }
                }

                // Photo button (if with photo)
                if checkInType == .withPhoto {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18, weight: .semibold))

                            Text("Add Photo")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }

                Spacer()

                // Check-in button
                Button(action: {
                    performCheckIn()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                        Text("Check In")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 252/255, green: 108/255, blue: 133/255),
                                Color(red: 255/255, green: 149/255, blue: 0/255)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                }
                .disabled(selectedLocation == nil)
                .opacity(selectedLocation == nil ? 0.5 : 1.0)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var headerSubtitle: String {
        switch checkInType {
        case .simple:
            return "Quick check-in"
        case .withPhoto:
            return "With photo"
        case .withNote:
            return "With note"
        }
    }

    private func performCheckIn() {
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()
        guard let location = selectedLocation else { return }

        // Build optional caption depending on type
        let note = (checkInType == .withNote || checkInType == .withPhoto) ? (caption.isEmpty ? nil : caption) : nil

        // Create/extend the check-in using the shared view model logic
        viewModel.checkIn(at: location, caption: note)

        // Close the sheet
        dismiss()
    }
}

// MARK: - Location Selection Row
struct LocationSelectionRow: View {
    let location: Location
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: location.type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : Color(red: 252/255, green: 108/255, blue: 133/255))
                    .frame(width: 44, height: 44)
                    .background(
                        isSelected ?
                        Color(red: 252/255, green: 108/255, blue: 133/255) :
                        Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.1)
                    )
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    HStack(spacing: 6) {
                        Text(location.type.rawValue)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)

                        Text("•")
                            .foregroundColor(.secondary)

                        Text("\(location.activeUsers) here")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.05) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color(red: 252/255, green: 108/255, blue: 133/255) : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()

        QuickCheckInButton()
            .environmentObject(AppViewModel())
    }
}
