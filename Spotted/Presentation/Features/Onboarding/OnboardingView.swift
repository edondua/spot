import SwiftUI
import PhotosUI

// MARK: - Onboarding Coordinator
struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showAuth = false

    var body: some View {
        ZStack {
            if showAuth {
                AuthenticationView()
                    .transition(.move(edge: .trailing))
            } else {
                OnboardingPagesView(currentPage: $currentPage, showAuth: $showAuth)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showAuth)
    }
}

// MARK: - Onboarding Pages
struct OnboardingPagesView: View {
    @Binding var currentPage: Int
    @Binding var showAuth: Bool

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Spot Someone Special",
            subtitle: "Connect with people at the places you love",
            icon: "mappin.and.ellipse",
            gradient: [Color(red: 252/255, green: 108/255, blue: 133/255), Color(red: 255/255, green: 77/255, blue: 109/255)]
        ),
        OnboardingPage(
            title: "Check In & Be Seen",
            subtitle: "Let others know when you're at your favorite spots",
            icon: "checkmark.circle.fill",
            gradient: [Color.purple, Color(red: 200/255, green: 100/255, blue: 255/255)]
        ),
        OnboardingPage(
            title: "Real Connections",
            subtitle: "Match with people who share your hangouts and interests",
            icon: "heart.fill",
            gradient: [Color.pink, Color.orange]
        ),
        OnboardingPage(
            title: "Your Privacy Matters",
            subtitle: "You control when and where you're visible",
            icon: "hand.raised.fill",
            gradient: [Color.blue, Color.cyan]
        )
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: pages[currentPage].gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPage = pages.count - 1
                            }
                        } label: {
                            Text("Skip")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                        }
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal, 20)

                Spacer()

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageContent(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: currentPage)

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: currentPage == index ? 10 : 8, height: currentPage == index ? 10 : 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 30)

                // Action buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        Button {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                showAuth = true
                            }
                        } label: {
                            Text("Get Started")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(pages[currentPage].gradient[0])
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.white)
                                .cornerRadius(30)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        }
                    } else {
                        Button {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text("Continue")
                                    .font(.system(size: 18, weight: .bold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Onboarding Page Content
struct OnboardingPageContent: View {
    let page: OnboardingPage
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 40) {
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 100, weight: .light))
                .foregroundColor(.white)
                .scaleEffect(showContent ? 1 : 0.5)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1), value: showContent)

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)

                Text(page.subtitle)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.3), value: showContent)
            }
        }
        .onAppear {
            showContent = true
        }
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
}

// MARK: - Authentication View
struct AuthenticationView: View {
    @State private var showSignUp = false
    @State private var showContent = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 252/255, green: 108/255, blue: 133/255),
                    Color(red: 255/255, green: 77/255, blue: 109/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo/Brand
                VStack(spacing: 16) {
                    Image("icon-1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 10)
                        .scaleEffect(showContent ? 1 : 0.5)
                        .opacity(showContent ? 1 : 0)

                    Text("Spotted")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    Text("Find love in the places you love")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                }
                .padding(.bottom, 60)
                .animation(.spring(response: 0.8, dampingFraction: 0.7), value: showContent)

                // Auth buttons
                VStack(spacing: 16) {
                    // Sign up with Apple
                    Button {
                        // Handle Apple sign in
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Continue with Apple")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                    // Sign up with phone
                    Button {
                        showSignUp = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Continue with Phone")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(30)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: showContent)

                    // Sign up with email
                    Button {
                        showSignUp = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Continue with Email")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
                }
                .padding(.horizontal, 40)

                Spacer()

                // Terms and privacy
                VStack(spacing: 8) {
                    Text("By continuing, you agree to our")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))

                    HStack(spacing: 4) {
                        Button("Terms of Service") {}
                        Text("and")
                        Button("Privacy Policy") {}
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                }
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.5), value: showContent)
            }
        }
        .sheet(isPresented: $showSignUp) {
            ProfileCreationWizard()
        }
        .onAppear {
            showContent = true
        }
    }
}

// MARK: - Profile Creation Wizard
struct ProfileCreationWizard: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AppViewModel

    @State private var currentStep = 0
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var selectedPhotos: [String] = []
    @State private var bio = ""
    @State private var selectedInterests: Set<String> = []
    @State private var showMainApp = false

    let allInterests = ["Short-term Fun", "Long-term Partner", "Gamers", "Creatives", "Foodies", "Travel Buddies", "Binge Watchers", "Sports", "Music Lovers", "Spiritual"]

    var canProceed: Bool {
        switch currentStep {
        case 0: return !name.isEmpty && name.count >= 2
        case 1: return age >= 18
        case 2: return selectedPhotos.count >= 1
        case 3: return true // Bio is optional
        case 4: return selectedInterests.count >= 3
        default: return true
        }
    }

    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 4)

                            Rectangle()
                                .fill(Color(red: 252/255, green: 108/255, blue: 133/255))
                                .frame(width: geometry.size.width * CGFloat(currentStep + 1) / 6, height: 4)
                                .animation(.easeInOut(duration: 0.3), value: currentStep)
                        }
                    }
                    .frame(height: 4)

                    // Content
                    TabView(selection: $currentStep) {
                        // Step 1: Name
                        ProfileCreationStep1(name: $name)
                            .tag(0)

                        // Step 2: Birthday
                        ProfileCreationStep2(birthDate: $birthDate, age: age)
                            .tag(1)

                        // Step 3: Photos
                        ProfileCreationStep3(selectedPhotos: $selectedPhotos)
                            .tag(2)

                        // Step 4: Bio
                        ProfileCreationStep4(bio: $bio)
                            .tag(3)

                        // Step 5: Interests
                        ProfileCreationStep5(selectedInterests: $selectedInterests, allInterests: allInterests)
                            .tag(4)

                        // Step 6: Location Permission
                        ProfileCreationStep6()
                            .tag(5)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    // Allow interactions inside each step (text fields, pickers, etc.)
                    // Swiping between steps is controllable via the buttons below

                    // Navigation buttons
                    HStack(spacing: 16) {
                        if currentStep > 0 {
                            Button {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    currentStep -= 1
                                }
                            } label: {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                                    .frame(width: 50, height: 50)
                                    .background(Color(UIColor.systemGray6))
                                    .clipShape(Circle())
                            }
                        }

                        Spacer()

                        Button {
                            if currentStep < 5 {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    currentStep += 1
                                }
                            } else {
                                // Complete onboarding
                                completeOnboarding()
                            }
                        } label: {
                            Text(currentStep == 5 ? "Let's Go!" : "Continue")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    canProceed || currentStep == 5
                                        ? Color(red: 252/255, green: 108/255, blue: 133/255)
                                        : Color.gray.opacity(0.3)
                                )
                                .cornerRadius(25)
                        }
                        .disabled(!canProceed && currentStep != 5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Step \(currentStep + 1) of 6")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                }
            }
        }
        .fullScreenCover(isPresented: $showMainApp) {
            ContentView()
                .environmentObject(viewModel)
        }
    }

    private func completeOnboarding() {
        // Update user profile with collected info
        viewModel.updateCurrentUser(
            name: name.isEmpty ? viewModel.currentUser.name : name,
            bio: bio.isEmpty ? viewModel.currentUser.bio : bio,
            age: age >= 18 ? age : viewModel.currentUser.age,
            height: viewModel.currentUser.height,
            job: viewModel.currentUser.job,
            hometown: viewModel.currentUser.hometown,
            sexuality: viewModel.currentUser.sexuality,
            lookingFor: viewModel.currentUser.lookingFor,
            drinking: viewModel.currentUser.drinking,
            smoking: viewModel.currentUser.smoking,
            kids: viewModel.currentUser.kids,
            interests: Array(selectedInterests.isEmpty ? Set(viewModel.currentUser.interests) : selectedInterests)
        )

        if !selectedPhotos.isEmpty {
            viewModel.updateUserPhotos(selectedPhotos)
        }

        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        showMainApp = true
    }
}

// MARK: - Profile Creation Steps
struct ProfileCreationStep1: View {
    @Binding var name: String
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Text("What's your first name?")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                Text("This is how you'll appear to others")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
            }
            .padding(.horizontal, 40)
            .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

            TextField("Enter your name", text: $name)
                .font(.system(size: 24, weight: .semibold))
                .multilineTextAlignment(.center)
                .padding(.vertical, 20)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal, 40)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

            Spacer()
            Spacer()
        }
        .onAppear {
            showContent = true
        }
    }
}

struct ProfileCreationStep2: View {
    @Binding var birthDate: Date
    let age: Int
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Text("When's your birthday?")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                Text("You must be at least 18 to use Spotted")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
            }
            .padding(.horizontal, 40)
            .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

            VStack(spacing: 16) {
                DatePicker("", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                if age >= 18 {
                    Text("Age: \(age)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                } else if age > 0 {
                    Text("You must be 18 or older")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
        .onAppear {
            showContent = true
        }
    }
}

struct ProfileCreationStep3: View {
    @Binding var selectedPhotos: [String]
    @State private var showContent = false
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showCamera = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("Add your photos")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    Text("Add at least 1 photo to continue")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    Text("\(selectedImages.count) / 6 photos")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedImages.count >= 1 ? Color(red: 252/255, green: 108/255, blue: 133/255) : .secondary)
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)
                .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(0..<6) { index in
                        if index < selectedImages.count {
                            // Show selected photo
                            RealPhotoCell(
                                image: selectedImages[index],
                                index: index
                            ) {
                                // Remove photo
                                selectedImages.remove(at: index)
                                updateSelectedPhotos()
                            }
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.1 + Double(index) * 0.05), value: showContent)
                        } else {
                            // Show add photo button
                            AddPhotoCell(index: index) {
                                // Picker is triggered inline
                            }
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.1 + Double(index) * 0.05), value: showContent)
                        }
                    }
                }
                .padding(.horizontal, 24)

                // Action buttons
                HStack(spacing: 16) {
                    // Photo library picker
                    PhotosPicker(
                        selection: $photoItems,
                        maxSelectionCount: 6 - selectedImages.count,
                        matching: .images
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Photo Library")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 252/255, green: 108/255, blue: 133/255))
                        .cornerRadius(16)
                    }
                    .disabled(selectedImages.count >= 6)

                    // Camera button
                    Button {
                        showCamera = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Camera")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.1))
                        .cornerRadius(16)
                    }
                    .disabled(selectedImages.count >= 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onChange(of: photoItems) { _, newItems in
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImages.append(image)
                    }
                }
                updateSelectedPhotos()
                photoItems = []
            }
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(selectedImage: Binding(
                get: { nil },
                set: { newImage in
                    if let image = newImage {
                        selectedImages.append(image)
                        updateSelectedPhotos()
                    }
                }
            ))
        }
        .onAppear {
            showContent = true
        }
    }

    private func updateSelectedPhotos() {
        // Save images to temp directory and store paths
        selectedPhotos = selectedImages.enumerated().compactMap { index, image in
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "onboarding_photo_\(UUID().uuidString).jpg"
            let fileURL = tempDir.appendingPathComponent(fileName)

            if let data = image.jpegData(compressionQuality: 0.8) {
                try? data.write(to: fileURL)
                return fileURL.path
            }
            return nil
        }
    }
}

// MARK: - Real Photo Cell (shows selected photo)
struct RealPhotoCell: View {
    let image: UIImage
    let index: Int
    let onRemove: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .clipped()
                .cornerRadius(16)

            // Remove button
            Button(action: onRemove) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)

                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                }
            }
            .padding(8)
        }
    }
}

// MARK: - Add Photo Cell (empty slot)
struct AddPhotoCell: View {
    let index: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "plus")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.gray)

                Text("Add Photo")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Image Picker (Camera)
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct ProfileCreationStep4: View {
    @Binding var bio: String
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Text("Write your bio")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                Text("Tell people about yourself (optional)")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
            }
            .padding(.horizontal, 40)
            .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

            VStack(spacing: 8) {
                TextEditor(text: $bio)
                    .font(.system(size: 16))
                    .frame(height: 150)
                    .padding(16)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                HStack {
                    Spacer()
                    Text("\(bio.count) / 500")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
        .onAppear {
            showContent = true
        }
    }
}

struct ProfileCreationStep5: View {
    @Binding var selectedInterests: Set<String>
    let allInterests: [String]
    @State private var showContent = false

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("Choose your interests")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    Text("Select at least 3 to help us find your matches")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    if selectedInterests.count >= 3 {
                        Text("\(selectedInterests.count) selected ✓")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                            .opacity(showContent ? 1 : 0)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)
                .animation(.easeOut(duration: 0.5).delay(0.1), value: showContent)

                FlowLayout(spacing: 12) {
                    ForEach(Array(allInterests.enumerated()), id: \.element) { index, interest in
                        InterestChip(
                            text: interest,
                            isSelected: selectedInterests.contains(interest)
                        ) {
                            if selectedInterests.contains(interest) {
                                selectedInterests.remove(interest)
                            } else {
                                selectedInterests.insert(interest)
                            }
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.4).delay(0.1 + Double(index) * 0.05), value: showContent)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            showContent = true
        }
    }
}

struct ProfileCreationStep6: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var showContent = false
    @State private var hasRequestedPermission = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "location.fill")
                    .font(.system(size: 70, weight: .light))
                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showContent)

                VStack(spacing: 16) {
                    Text("Enable Location")
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    Text("We use your location to show you people at nearby places")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                }
                .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)

                VStack(spacing: 16) {
                    PermissionFeature(icon: "eye.slash.fill", text: "Only visible when checked in")
                    PermissionFeature(icon: "hand.raised.fill", text: "You control your visibility")
                    PermissionFeature(icon: "lock.fill", text: "Your exact location is never shared")
                }
                .padding(.horizontal, 40)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)

                if locationManager.authorizationStatus == .authorizedWhenInUse ||
                   locationManager.authorizationStatus == .authorizedAlways {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Location enabled!")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    .padding(.top, 16)
                } else if hasRequestedPermission {
                    Button {
                        locationManager.requestLocationPermission()
                    } label: {
                        Text("Request Permission")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.1))
                            .cornerRadius(20)
                    }
                    .padding(.top, 16)
                }
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            showContent = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                hasRequestedPermission = true
                if locationManager.authorizationStatus == .notDetermined {
                    locationManager.requestLocationPermission()
                }
            }
        }
    }
}

struct PermissionFeature: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                .frame(width: 30)

            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppViewModel())
}
