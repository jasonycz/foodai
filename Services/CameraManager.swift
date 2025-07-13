import Foundation
import AVFoundation
import UIKit

class CameraManager: NSObject, ObservableObject {
    @Published var isFlashOn = false
    @Published var isPermissionGranted = false
    @Published var currentCameraPosition: AVCaptureDevice.Position = .back
    
    let session = AVCaptureSession()
    var preview: AVCaptureVideoPreviewLayer!
    private let output = AVCapturePhotoOutput()
    private var capturedImage: UIImage?
    private var completion: ((UIImage?) -> Void)?
    private var currentDevice: AVCaptureDevice?
    private var currentInput: AVCaptureDeviceInput?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("无法获取相机设备")
            return
        }
        
        currentDevice = device
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            currentInput = input
            session.sessionPreset = .photo
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
        } catch {
            print("相机设置失败: \(error.localizedDescription)")
        }
    }
    
    func requestPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isPermissionGranted = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isPermissionGranted = granted
                }
            }
        default:
            isPermissionGranted = false
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        
        let settings = AVCapturePhotoSettings()
        
        // 设置闪光灯
        if isFlashOn {
            settings.flashMode = .on
        } else {
            settings.flashMode = .off
        }
        
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
    }
    
    func switchCamera() {
        let newPosition: AVCaptureDevice.Position = currentCameraPosition == .back ? .front : .back
        
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
            print("无法获取\(newPosition == .back ? "后置" : "前置")摄像头")
            return
        }
        
        do {
            let newInput = try AVCaptureDeviceInput(device: newDevice)
            
            session.beginConfiguration()
            
            if let currentInput = currentInput {
                session.removeInput(currentInput)
            }
            
            if session.canAddInput(newInput) {
                session.addInput(newInput)
                currentInput = newInput
                currentDevice = newDevice
                currentCameraPosition = newPosition
            }
            
            session.commitConfiguration()
            
        } catch {
            print("切换摄像头失败: \(error.localizedDescription)")
        }
    }
    
    func setFocus(at point: CGPoint) {
        guard let device = currentDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
            }
            
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                device.exposureMode = .autoExpose
            }
            
            device.unlockForConfiguration()
            
        } catch {
            print("设置聚焦失败: \(error.localizedDescription)")
        }
    }
    
    func setZoom(_ zoomFactor: CGFloat) {
        guard let device = currentDevice else { return }
        
        do {
            try device.lockForConfiguration()
            let maxZoom = min(zoomFactor, device.activeFormat.videoMaxZoomFactor)
            device.videoZoomFactor = maxZoom
            device.unlockForConfiguration()
        } catch {
            print("设置缩放失败: \(error.localizedDescription)")
        }
    }
    
    func startSession() {
        if !session.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        if session.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.session.stopRunning()
            }
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("拍照失败: \(error.localizedDescription)")
            completion?(nil)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("无法处理拍摄的照片")
            completion?(nil)
            return
        }
        
        completion?(image)
    }
} 