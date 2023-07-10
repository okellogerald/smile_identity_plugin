//
//  CameraPermissionManager.swift
//  Runner
//
//  Created by MacBookPro on 26/06/2023.
//

import Foundation
import AVFoundation

class CameraManager {
    func checkCameraPermission() async -> Bool {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
         switch cameraAuthorizationStatus {
             case .denied, .restricted: return false
             case .authorized: return true
             case .notDetermined: return await AVCaptureDevice.requestAccess(for: .video)
         @unknown default:
             return false
         }
    }
}
