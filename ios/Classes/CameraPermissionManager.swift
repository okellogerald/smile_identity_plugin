//
//  CameraPermissionManager.swift
//  Runner
//
//  Created by MacBookPro on 26/06/2023.
//

import Foundation
import AVFoundation

class CameraManager {
    func checkCameraPermission(requestPermissionIfNotGranted: Bool) async -> Bool {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
         switch cameraAuthorizationStatus {
             case .denied, .restricted: return false
             case .authorized: return true
             case .notDetermined:
             
             if requestPermissionIfNotGranted {
                 return await AVCaptureDevice.requestAccess(for: .video)
             } else {
                 return false
             }
             
         @unknown default:
             return false
         }
    }
}
