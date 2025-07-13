import SwiftUI
import AVFoundation
import UIKit

struct CameraView: View {
    @EnvironmentObject var foodTracker: FoodTracker
    @StateObject private var camera = CameraManager()
    @State private var showingImagePicker = false
    @State private var showingFoodDetail = false
    @State private var capturedImage: UIImage?
    @State private var recognizedFood: FoodItem?
    @State private var isAnalyzing = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // 权限检查
            if !camera.isPermissionGranted {
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("需要相机权限")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("请允许访问相机以拍摄食物")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Button("重新请求权限") {
                        camera.requestPermission()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            } else {
                // 相机预览
                CameraPreview(camera: camera)
                    .ignoresSafeArea()
            }
            
            VStack {
                // 顶部控制栏
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("拍摄食物")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        camera.toggleFlash()
                    }) {
                        Image(systemName: camera.isFlashOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.title2)
                            .foregroundColor(camera.isFlashOn ? .yellow : .white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .disabled(!camera.isPermissionGranted)
                }
                .padding()
                
                Spacer()
                
                // AI识别提示
                if isAnalyzing {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        
                        Text("AI正在识别食物...")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        Text("请保持图像稳定")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.subheadline)
                    }
                    .padding(20)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // 底部控制按钮
                if camera.isPermissionGranted {
                    HStack(spacing: 40) {
                        // 相册按钮
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Image(systemName: "photo.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                        
                        // 拍照按钮
                        Button(action: takePhoto) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 6)
                                    .frame(width: 100, height: 100)
                                
                                if isAnalyzing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                }
                            }
                        }
                        .disabled(isAnalyzing)
                        .scaleEffect(isAnalyzing ? 0.9 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isAnalyzing)
                        
                        // 切换相机按钮
                        Button(action: {
                            camera.switchCamera()
                        }) {
                            Image(systemName: "camera.rotate.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $capturedImage, isPresented: $showingImagePicker)
        }
        .sheet(isPresented: $showingFoodDetail) {
            if let food = recognizedFood {
                FoodDetailView(foodItem: food)
                    .environmentObject(foodTracker)
            }
        }
        .onChange(of: capturedImage) { _, newImage in
            if let image = newImage {
                analyzeFood(from: image)
            }
        }
        .onChange(of: camera.isPermissionGranted) { _, granted in
            if granted {
                camera.startSession()
            }
        }
        .onAppear {
            camera.requestPermission()
        }
        .onDisappear {
            camera.stopSession()
        }
    }
    
    private func takePhoto() {
        guard camera.isPermissionGranted else {
            print("相机权限未授权")
            return
        }
        
        guard !isAnalyzing else {
            print("正在分析中，请稍候")
            return
        }
        
        camera.capturePhoto { image in
            DispatchQueue.main.async {
                if let image = image {
                    self.capturedImage = image
                    self.analyzeFood(from: image)
                } else {
                    print("拍照失败")
                    // 这里可以添加用户提示
                }
            }
        }
    }
    
    private func analyzeFood(from image: UIImage) {
        isAnalyzing = true
        
        // 模拟AI分析延迟
        Task {
            do {
                let aiService = AIFoodRecognitionService()
                let foodItems = try await aiService.recognizeFood(from: image)
                
                await MainActor.run {
                    isAnalyzing = false
                    if let firstFood = foodItems.first {
                        recognizedFood = firstFood
                        showingFoodDetail = true
                    }
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    print("识别失败: \(error)")
                }
            }
        }
    }
}

// MARK: - 相机预览组件

// 相机预览
struct CameraPreview: UIViewRepresentable {
    let camera: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        camera.preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        // 使用 CameraManager 的 startSession 方法
        if camera.isPermissionGranted {
            camera.startSession()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 更新预览层的 frame
        camera.preview.frame = uiView.frame
    }
}

// 图片选择器
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
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
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

#Preview {
    CameraView()
        .environmentObject(FoodTracker())
} 