import SwiftUI
import AVFoundation
import UIKit
import CoreLocation
import MapKit

// MARK: - Camera Capture View (Instagram Story Style)
struct CameraCaptureView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var camera = CameraService()
    @State private var capturedImage: UIImage?
    @State private var showImagePreview = false
    let tappedCoordinate: CLLocationCoordinate2D?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if !camera.isAuthorized {
                // Permission request view
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)

                    Text("Camera Access Required")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text("Spotted needs camera access to take photos for check-ins")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button(action: {
                        camera.requestPermission()
                    }) {
                        Text("Allow Camera Access")
                            .font(.system(size: 17, weight: .bold))
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
                    .padding(.horizontal, 40)
                    .padding(.top, 20)

                    Button(action: {
                        dismiss()
                    }) {
                        Text("Maybe Later")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            } else if camera.hasError {
                // Error state (e.g., simulator without camera)
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)

                    Text("Camera Not Available")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text("Camera is not available on this device. Please use a physical iPhone to take photos.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
            } else if let image = capturedImage, showImagePreview {
                // Show captured image preview
                CheckInPreviewView(capturedImage: image, tappedCoordinate: tappedCoordinate)
            } else if camera.isReady {
                // Camera preview
                CameraPreview(camera: camera)
                    .ignoresSafeArea()

                // Camera controls overlay
                VStack {
                    // Top bar
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }

                        Spacer()

                        Button(action: {
                            camera.flipCamera()
                        }) {
                            Image(systemName: "camera.rotate.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                    Spacer()

                    // Capture button
                    Button(action: {
                        camera.capturePhoto { image in
                            if let image = image {
                                capturedImage = image
                                withAnimation {
                                    showImagePreview = true
                                }
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 70, height: 70)

                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                        }
                    }
                    .padding(.bottom, 40)
                }
            } else {
                // Loading state
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)

                    Text("Initializing camera...")
                        .foregroundColor(.white)
                        .padding(.top)
                }
            }
        }
        .onAppear {
            camera.restartIfNeeded()
        }
        .onDisappear {
            camera.cleanup()
        }
    }
}

// MARK: - Camera Preview (UIKit Wrapper)
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraService

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        // Add preview layer immediately
        camera.previewLayer.frame = view.bounds
        camera.previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.previewLayer)

        print("CameraPreview: Added preview layer to view")

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update preview layer frame when view size changes
        DispatchQueue.main.async {
            camera.previewLayer.frame = uiView.bounds

            // Ensure preview layer is the first sublayer (behind everything else)
            if let index = uiView.layer.sublayers?.firstIndex(of: camera.previewLayer) {
                if index != 0 {
                    camera.previewLayer.removeFromSuperlayer()
                    uiView.layer.insertSublayer(camera.previewLayer, at: 0)
                }
            } else {
                // Re-add if somehow removed
                uiView.layer.insertSublayer(camera.previewLayer, at: 0)
            }
        }
    }
}

// MARK: - Camera Service
class CameraService: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var isReady = false
    @Published var hasError = false

    private var captureSession: AVCaptureSession?
    private(set) var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput?
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var currentCamera: AVCaptureDevice.Position = .back
    private var photoCaptureCompletion: ((UIImage?) -> Void)?

    private let sessionQueue = DispatchQueue(label: "com.spotted.camera.session")

    override init() {
        super.init()
        print("CameraService: Initializing")

        // Create capture session
        let session = AVCaptureSession()
        captureSession = session

        // Create and configure preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill

        print("CameraService: Session and preview layer created")
        print("CameraService: Preview layer session: \(previewLayer.session != nil ? "connected" : "not connected")")

        checkPermission()
    }

    func checkPermission() {
        print("CameraService: Checking permission")
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        print("CameraService: Authorization status: \(status.rawValue)")

        switch status {
        case .authorized:
            print("CameraService: Already authorized, setting up camera")
            DispatchQueue.main.async {
                self.isAuthorized = true
            }
            setupCamera()
        case .notDetermined:
            print("CameraService: Permission not determined")
            isAuthorized = false
        case .denied, .restricted:
            print("CameraService: Permission denied or restricted")
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
        @unknown default:
            print("CameraService: Unknown authorization status")
            isAuthorized = false
        }
    }

    func requestPermission() {
        print("CameraService: Requesting camera permission")
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            print("CameraService: Permission request result: \(granted)")

            DispatchQueue.main.async {
                self?.isAuthorized = granted
                print("CameraService: Updated isAuthorized to \(granted)")
            }

            if granted {
                print("CameraService: Permission granted, setting up camera")
                self?.setupCamera()
            } else {
                print("CameraService: Permission denied")
            }
        }
    }

    private func setupCamera() {
        print("CameraService: setupCamera() called")

        sessionQueue.async { [weak self] in
            print("CameraService: On session queue")

            guard let self = self else {
                print("CameraService: self is nil")
                return
            }

            guard let session = self.captureSession else {
                print("CameraService: captureSession is nil")
                return
            }

            print("CameraService: Beginning configuration")
            session.beginConfiguration()

            // Set session preset
            if session.canSetSessionPreset(.photo) {
                session.sessionPreset = .photo
                print("CameraService: Set session preset to .photo")
            }

            // Remove existing inputs
            print("CameraService: Removing \(session.inputs.count) existing inputs")
            session.inputs.forEach { session.removeInput($0) }

            // Add video input
            print("CameraService: Getting camera device for position: \(self.currentCamera.rawValue)")
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: self.currentCamera) else {
                print("CameraService: Failed to get camera device - likely running on simulator")
                DispatchQueue.main.async {
                    self.hasError = true
                    self.isReady = false
                }
                session.commitConfiguration()
                return
            }

            print("CameraService: Got camera device, creating input")
            do {
                let input = try AVCaptureDeviceInput(device: camera)
                if session.canAddInput(input) {
                    session.addInput(input)
                    self.videoDeviceInput = input
                    print("CameraService: Successfully added video input")
                } else {
                    print("CameraService: Cannot add input to session")
                    throw NSError(domain: "CameraError", code: -1, userInfo: nil)
                }
            } catch {
                print("CameraService: Error setting up camera input: \(error)")
                DispatchQueue.main.async {
                    self.hasError = true
                    self.isReady = false
                }
                session.commitConfiguration()
                return
            }

            // Remove existing outputs
            print("CameraService: Removing \(session.outputs.count) existing outputs")
            session.outputs.forEach { session.removeOutput($0) }

            // Add photo output
            print("CameraService: Creating photo output")
            let output = AVCapturePhotoOutput()
            if session.canAddOutput(output) {
                session.addOutput(output)
                self.photoOutput = output
                print("CameraService: Successfully added photo output")
            } else {
                print("CameraService: Could not add photo output")
                DispatchQueue.main.async {
                    self.hasError = true
                    self.isReady = false
                }
                session.commitConfiguration()
                return
            }

            print("CameraService: Committing configuration")
            session.commitConfiguration()

            // Start session
            if !session.isRunning {
                print("CameraService: Starting capture session")
                session.startRunning()
                print("CameraService: Capture session started")
            } else {
                print("CameraService: Session already running")
            }

            DispatchQueue.main.async {
                print("CameraService: Camera is ready!")
                self.isReady = true
                self.hasError = false

                // Ensure preview layer connection is active
                if self.previewLayer.connection != nil {
                    print("CameraService: Preview layer connection is active")
                }

                // Force preview layer update
                self.objectWillChange.send()
            }
        }
    }

    func flipCamera() {
        print("CameraService: Flipping camera")

        DispatchQueue.main.async {
            self.isReady = false
        }

        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.currentCamera = self.currentCamera == .back ? .front : .back
            self.setupCamera()
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self = self,
                  let photoOutput = self.photoOutput else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            self.photoCaptureCompletion = completion

            let settings = AVCapturePhotoSettings()

            photoOutput.capturePhoto(with: settings, delegate: self)

            // Haptic feedback
            DispatchQueue.main.async {
                let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                impactHeavy.impactOccurred()
            }
        }
    }

    func restartIfNeeded() {
        print("CameraService: restartIfNeeded() called")

        sessionQueue.async { [weak self] in
            guard let self = self,
                  let session = self.captureSession else {
                print("CameraService: No session to restart")
                return
            }

            // Check if session is not running
            if !session.isRunning {
                print("CameraService: Session stopped, restarting...")

                // If we're authorized but session stopped, restart it
                if self.isAuthorized {
                    session.startRunning()
                    print("CameraService: Session restarted")

                    DispatchQueue.main.async {
                        self.isReady = true
                        self.hasError = false
                        self.objectWillChange.send()
                    }
                } else {
                    print("CameraService: Not authorized, cannot restart")
                }
            } else {
                print("CameraService: Session already running")
            }
        }
    }

    func cleanup() {
        print("CameraService: cleanup() called")
        sessionQueue.async { [weak self] in
            guard let session = self?.captureSession else { return }
            if session.isRunning {
                print("CameraService: Stopping session")
                session.stopRunning()
            }
        }
    }

    deinit {
        print("CameraService: deinit called")
        captureSession?.stopRunning()
        captureSession = nil
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            DispatchQueue.main.async {
                self.photoCaptureCompletion?(nil)
            }
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            DispatchQueue.main.async {
                self.photoCaptureCompletion?(nil)
            }
            return
        }

        DispatchQueue.main.async {
            self.photoCaptureCompletion?(image)
        }
    }
}

// MARK: - Check-In Preview (After Photo Capture)
struct CheckInPreviewView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AppViewModel
    let capturedImage: UIImage
    let tappedCoordinate: CLLocationCoordinate2D?

    @State private var selectedLocation: Location?
    @State private var caption: String = ""
    @State private var showingSuccess = false
    @State private var isEditingText = false
    @State private var textPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width / 2, y: 200)
    @State private var textColor: Color = .white
    @State private var showLocationPicker = false
    @State private var customLocationName: String = ""
    @StateObject private var locationManager = LocationManager.shared
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Photo with text overlay (Instagram/Snapchat style)
            ZStack {
                // Photo preview - full screen
                Image(uiImage: capturedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Tap on background - dismiss keyboard if editing, otherwise start editing
                        if isEditingText || isTextFieldFocused {
                            // Dismiss keyboard
                            isEditingText = false
                            isTextFieldFocused = false
                        } else if caption.isEmpty {
                            // Start editing if no caption yet
                            isEditingText = true
                            isTextFieldFocused = true
                        }
                    }

                // Text overlay on image
                if !caption.isEmpty || isEditingText {
                    VStack {
                        Spacer()

                        TextField("Tap to add text...", text: $caption, axis: .vertical)
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(textColor)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                // Text background (semi-transparent)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.3))
                                    .blur(radius: 20)
                            )
                            .focused($isTextFieldFocused)
                            .onSubmit {
                                isEditingText = false
                                isTextFieldFocused = false
                            }
                            .onTapGesture {
                                // Tap on text field - keep editing
                                if !isEditingText {
                                    isEditingText = true
                                    isTextFieldFocused = true
                                }
                            }

                        Spacer()
                    }
                }
            }

            // Top bar - Text color picker
            VStack {
                HStack(spacing: 12) {
                    // Close button
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }

                    Spacer()

                    // Text color options
                    if isEditingText || !caption.isEmpty {
                        HStack(spacing: 8) {
                            ForEach([Color.white, Color.black, Color(red: 252/255, green: 108/255, blue: 133/255), .blue, .yellow, .green], id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: textColor == color ? 3 : 0)
                                    )
                                    .onTapGesture {
                                        textColor = color
                                    }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)
                    }

                    // Add text button
                    Button(action: {
                        isEditingText = true
                        isTextFieldFocused = true
                    }) {
                        Image(systemName: "textformat")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()
            }

            // Bottom bar - Location and Share
            VStack {
                Spacer()

                VStack(spacing: 16) {
                    // Location selector (tappable)
                    Button(action: {
                        showLocationPicker = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)

                            if let location = selectedLocation {
                                Text(location.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)

                                Text("• \(location.activeUsers) here")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            } else {
                                Text("Add location")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }

                    // Share button
                    Button(action: {
                        performCheckIn()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                            Text("Share to Spotted")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
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
                        .cornerRadius(16)
                        .shadow(color: Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.5), radius: 20, y: 10)
                    }
                    .disabled(selectedLocation == nil)
                    .opacity(selectedLocation == nil ? 0.5 : 1.0)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            if let coordinate = tappedCoordinate {
                createLocationFromCoordinate(coordinate)
            } else {
                autoSelectLocation()
            }
        }
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerSheet(
                currentLocation: locationManager.userLocation?.coordinate,
                selectedLocation: $selectedLocation,
                customLocationName: $customLocationName
            )
        }
    }

    private func createLocationFromCoordinate(_ coordinate: CLLocationCoordinate2D) {
        // Create a custom location from the exact tapped coordinate
        selectedLocation = Location(
            name: "Custom Location",
            type: .other,
            address: String(format: "%.4f, %.4f", coordinate.latitude, coordinate.longitude),
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            activeUsers: 1
        )
        print("CheckIn: Created custom location at \(coordinate.latitude), \(coordinate.longitude)")
    }

    private func autoSelectLocation() {
        // Use actual GPS location if available
        if let userCoordinate = locationManager.userLocation?.coordinate {
            // Create location from actual GPS
            selectedLocation = Location(
                name: customLocationName.isEmpty ? "My Location" : customLocationName,
                type: .other,
                address: String(format: "%.4f, %.4f", userCoordinate.latitude, userCoordinate.longitude),
                latitude: userCoordinate.latitude,
                longitude: userCoordinate.longitude,
                activeUsers: 1
            )
            print("CheckIn: Using actual GPS location at \(userCoordinate.latitude), \(userCoordinate.longitude)")
        } else {
            // Fallback: show location picker to manually select
            print("CheckIn: No GPS location available")
        }
    }

    private func performCheckIn() {
        guard let location = selectedLocation else { return }

        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()

        // Dismiss immediately to prevent blocking UI
        dismiss()

        // Create check-in after dismissing (on background thread)
        DispatchQueue.global(qos: .userInitiated).async {
            let captionText = self.caption.isEmpty ? nil : self.caption

            // Save image to temporary location
            var savedImageUrl: String?
            if let imageData = self.capturedImage.jpegData(compressionQuality: 0.8) {
                let tempDir = FileManager.default.temporaryDirectory
                let fileName = "\(UUID().uuidString).jpg"
                let fileURL = tempDir.appendingPathComponent(fileName)

                do {
                    try imageData.write(to: fileURL)
                    savedImageUrl = fileURL.path
                    print("CheckIn: Saved image to \(fileURL.path)")
                } catch {
                    print("CheckIn: Failed to save image - \(error)")
                }
            }

            DispatchQueue.main.async {
                self.viewModel.checkIn(at: location, caption: captionText, imageUrl: savedImageUrl)
                print("CheckIn: Created check-in at \(location.name) with caption: \(captionText ?? "none")")
            }
        }
    }
}

// MARK: - Location Picker Sheet (Visual Map-based)
struct LocationPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    let currentLocation: CLLocationCoordinate2D?
    @Binding var selectedLocation: Location?
    @Binding var customLocationName: String

    @State private var locationName: String = ""
    @State private var region: MKCoordinateRegion
    @State private var showNameInput = false

    init(currentLocation: CLLocationCoordinate2D?, selectedLocation: Binding<Location?>, customLocationName: Binding<String>) {
        self.currentLocation = currentLocation
        self._selectedLocation = selectedLocation
        self._customLocationName = customLocationName

        // Initialize region with current location or default
        let coordinate = currentLocation ?? CLLocationCoordinate2D(latitude: 47.3769, longitude: 8.5417) // Zurich default
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        ZStack {
            // Interactive Map
            Map(coordinateRegion: $region)
                .edgesIgnoringSafeArea(.all)

            // Center pin (fixed in center, map moves underneath)
            VStack {
                Spacer()

                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)

                Spacer()
            }

            // Top info bar
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tap and drag to position")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        Text(String(format: "%.4f, %.4f", region.center.latitude, region.center.longitude))
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()

                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.7), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(.top, 50)

                Spacer()

                // Bottom buttons
                VStack(spacing: 12) {
                    // Current location button
                    if currentLocation != nil {
                        Button(action: {
                            withAnimation {
                                region.center = currentLocation!
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 14))
                                Text("Use Current Location")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                    }

                    // Confirm button
                    Button(action: {
                        showNameInput = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                            Text("Confirm Location")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
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
                        .cornerRadius(30)
                        .shadow(color: Color(red: 252/255, green: 108/255, blue: 133/255).opacity(0.5), radius: 15, y: 8)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showNameInput) {
            LocationNameInputSheet(
                coordinate: region.center,
                locationName: $locationName,
                onConfirm: {
                    saveLocation()
                }
            )
            .presentationDetents([.height(300)])
        }
    }

    private func saveLocation() {
        selectedLocation = Location(
            name: locationName.isEmpty ? "My Location" : locationName,
            type: .other,
            address: String(format: "%.4f, %.4f", region.center.latitude, region.center.longitude),
            latitude: region.center.latitude,
            longitude: region.center.longitude,
            activeUsers: 1
        )

        customLocationName = locationName
        dismiss()
    }
}

// MARK: - Location Name Input Sheet
struct LocationNameInputSheet: View {
    @Environment(\.dismiss) var dismiss
    let coordinate: CLLocationCoordinate2D
    @Binding var locationName: String
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Color(red: 252/255, green: 108/255, blue: 133/255))

                    Text("Name this location")
                        .font(.system(size: 20, weight: .bold))

                    Text(String(format: "%.4f, %.4f", coordinate.latitude, coordinate.longitude))
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.secondary)
                }

                TextField("e.g., Coffee Shop, Park, Home", text: $locationName)
                    .font(.system(size: 16))
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                Button(action: {
                    onConfirm()
                    dismiss()
                }) {
                    Text("Confirm")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 252/255, green: 108/255, blue: 133/255))
                        .cornerRadius(14)
                }
                .disabled(locationName.isEmpty)
                .opacity(locationName.isEmpty ? 0.5 : 1.0)
                .padding(.horizontal)
            }

            Spacer()
        }
    }
}

// Helper extension for corner radius on specific corners (Already defined in View+Extensions.swift)
// extension View {
//     func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//         clipShape(RoundedCorner(radius: radius, corners: corners))
//     }
// }
//
// struct RoundedCorner: Shape {
//     var radius: CGFloat = .infinity
//     var corners: UIRectCorner = .allCorners
//
//     func path(in rect: CGRect) -> Path {
//         let path = UIBezierPath(
//             roundedRect: rect,
//             byRoundingCorners: corners,
//             cornerRadii: CGSize(width: radius, height: radius)
//         )
//         return Path(path.cgPath)
//     }
// }

#Preview {
    CameraCaptureView(tappedCoordinate: nil)
        .environmentObject(AppViewModel())
}
