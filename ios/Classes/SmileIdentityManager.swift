//
//  SmileIdentityManager.swift
//  smile_identity_plugin
//
//  Created by Mac on 25/07/2023.
//

import Foundation
import Smile_Identity_SDK

struct SmileData {
    let userId: String;
    let firstName: String?;
    let lastName: String?;
    let country: String;

    let idType: String?;
    let idNumber: String?;
    
    let jobId: String;
    let jobType: Int;
    let jobTag: String;
    
    let callbackUrl: String?;
    let environment: SIDNetData.Environment;

    let additionalValues: [String:Any]?;
}

class SmileIdentityManager : NSObject, SIDCaptureManagerDelegate {
    var cameraManager = CameraManager()
    var channel: FlutterMethodChannel!;
    
    init(cameraManager: CameraManager = CameraManager(), channel: FlutterMethodChannel!) {
        self.cameraManager = cameraManager
        self.channel = channel
    }
    
     func handleCapture(_ call: FlutterMethodCall) {
        let args = call.arguments as! [String: Any]
        let tag = (args["tag"] as? String) ?? ""
        let type = (args["captureType"] as? String) ?? ""
        let handlePermissions = (args["handlePermissions"] as? Bool) ?? true
        let captureType = getType(type: type);
        
        Task {
            await self.capture(
                tag: tag,
                captureType: captureType,
                handlePermissions: handlePermissions
            )
        }
    }
    
     func handleSubmit(_ call: FlutterMethodCall) {
        let data = self.getSmileData(args: call.arguments as! [String:Any])
        Task {
            await self.submitJob(smileData: data)
        }
    }
    
    private func getType(type: String) -> CaptureType {
        switch type {
        case "SELFIE":
            return CaptureType.SELFIE
        case "ID_CAPTURE":
            return CaptureType.ID_CAPTURE
        case "SELFIE_AND_ID_CAPTURE":
            return CaptureType.SELFIE_AND_ID_CAPTURE
        case "ID_CAPTURE_AND_SELFIE":
            return CaptureType.ID_CAPTURE_AND_SELFIE
        default:
            return CaptureType.SELFIE
        }
        
    }

    private func getSmileData(args: [String:Any]) -> SmileData {
         let env = (args["environment"] as? String) ?? "TEST"
           var environment = SIDNetData.Environment.TEST
           if (env == "PROD") {
             environment = SIDNetData.Environment.PROD
           }
         
        return SmileData(
            userId: (args["userId"] as? String) ?? "",
            firstName: args["firstName"] as? String,
            lastName: args["lastName"] as? String,
            country: args["country"] as? String ?? "",
            idType: args["idType"] as? String,
            idNumber: args["idNumber"] as? String,
            jobId: (args["jobId"] as? String) ?? "",
            jobType: (args["jobType"] as? Int) ?? 1,
            jobTag:  (args["jobTag"] as? String) ?? "",
            callbackUrl: args["callbackUrl"] as? String,
            environment: environment,
            additionalValues: (args["additionalValues"] as? [String:Any]) ?? [:]
        );
    }

    private func capture(tag: String, captureType: CaptureType, handlePermissions: Bool) async {
        let granted = await cameraManager.checkCameraPermission(requestPermissionIfNotGranted: handlePermissions)
        if(!granted) {
            var args : [String:Any] = [:]
            args["success"] = false
            args["error"] = CAMERA_PERMISSION_ERROR_DESC
            channel.invokeMethod("capture_state", arguments: args)
            return
        }
                
         DispatchQueue.main.async {
            var builder = SIDCaptureManager.Builder(delegate:self, captureType: captureType)
            
            if  !tag.isEmpty {
                builder = builder.setTag(tag: tag)
            }
            
            if (captureType == CaptureType.SELFIE_AND_ID_CAPTURE || captureType == CaptureType.ID_CAPTURE) {
                let sidIdCaptureConfig = SIDIDCaptureConfig.Builder().setIdCaptureType(idCaptureType: IDCaptureType.Front_And_Back
                ).build()
                builder = builder.setSidIdCaptureConfig(sidIdCaptureConfig: sidIdCaptureConfig!)
            }
            
            let selfieConfig = (SIDSelfieCaptureConfig.Builder()).build()
            let idCaptureConfig = (SIDIDCaptureConfig.Builder()).build()
            
            builder = builder.setSidSelfieConfig(sidSelfieConfig: selfieConfig)
            builder = builder.setSidIdCaptureConfig(sidIdCaptureConfig: idCaptureConfig!)
            builder.build().start()
        }
    }
    
    private func submitJob(smileData: SmileData) async {
        let sidNetworkRequest = SIDNetworkRequest()
        let delegate = SubmitJobListener(
            onCompleted: {message in
                var args : [String:Any] = [:]
                args["success"] = true
                args["message"] = message
                self.channel.invokeMethod("submit_state", arguments: args)
            },
            onError: { error in
                var args : [String:Any] = [:]
                args["success"] = false
                args["error"] = error
                self.channel.invokeMethod("submit_state", arguments: args)
             }
        )
        sidNetworkRequest.setDelegate(delegate: delegate)
        sidNetworkRequest.initialize()
        
        let sidNetData = SIDNetData(environment: smileData.environment);
        if let callbackUrl = smileData.callbackUrl {
            sidNetData.setCallBackUrl(callbackUrl: callbackUrl)
        }

        let sidConfig = SIDConfig()
        sidConfig.setSidNetworkRequest( sidNetworkRequest : sidNetworkRequest )
        sidConfig.setSidNetData( sidNetData : sidNetData )
        sidConfig.setRetryOnFailurePolicy( retryOnFailurePolicy: getRetryOnFailurePolicy() )
   
        let sidIdInfo = SIDUserIdInfo()
        sidIdInfo.setCountry(country: smileData.country )
        
        if let idType = smileData.idType {
            sidIdInfo.setIdType(idType: idType )
        }
        if let idNumber = smileData.idNumber {
            sidIdInfo.setIdNumber(idNumber: idNumber )
        }
        if let firstName = smileData.firstName {
            sidIdInfo.setFirstName(firstName: firstName )
        }
        if let lastName = smileData.lastName {
            sidIdInfo.setLastName(lastName: lastName )
        }
        
        sidConfig.setUserIdInfo(userIdInfo: sidIdInfo)
       
        let sidPartnerParams = PartnerParams()
        sidPartnerParams.setJobId(jobId: smileData.jobId )
        sidPartnerParams.setUserId(userId:  smileData.userId )
        sidPartnerParams.setJobType(jobType: smileData.jobType )
        if (smileData.additionalValues != nil) {
            for e in smileData.additionalValues! {
                sidPartnerParams.setAdditionalValue(key: e.key, val: e.value)
            }
        }
        
        sidConfig.setPartnerParams( partnerParams : sidPartnerParams )
        sidConfig.setIsEnrollMode(isEnrollMode: true)
        let hasIdCard = SIDInfosManager.hasIdCard(userTag: smileData.jobTag)
        sidConfig.setUseIdCard(useIdCard: hasIdCard)
       
        sidConfig.build(userTag: smileData.jobTag)
        do {
            try sidConfig.getSidNetworkRequest().submit(sidConfig: sidConfig)
        } catch {
            var args : [String:Any] = [:]
            args["success"] = false
            args["error"] = error.localizedDescription
            self.channel.invokeMethod("submit_state", arguments: args)
        }
    }
    
    private func getRetryOnFailurePolicy() -> RetryOnFailurePolicy {
        let options = RetryOnFailurePolicy();
        options.setMaxRetryTimeoutSec(maxRetryTimeoutSec:15 )
        options.setMaxRetryCount(maxRetryCount: 5)
        return options;
    }
    
    public func onSuccess(tag: String, selfiePreview: UIImage?, idFrontPreview: UIImage?, idBackPreview: UIImage?) {
       channel.invokeMethod("capture_state", arguments: ["success": true])
    }
    
    public func onError(tag: String, sidError: Smile_Identity_SDK.SIDError) {
       // showMessage("Error: \(sidError.message)")
        var args : [String:Any] = [:]
        args["success"] = false
        args["error"] = sidError.message
       channel.invokeMethod("capture_state", arguments: args)
    }
}

class SubmitJobListener: SIDNetworkRequestDelegate {
   let onCompleted: (String)->()
   let onError: (String)->()
    
    init(onCompleted: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        self.onCompleted = onCompleted
        self.onError = onError
    }
    
    func onDocumentVerified(sidResponse: SIDResponse) {
        // showMessage("Document is verified")
    }
    
    func onStartJobStatus() {
       // showMessage("Submitting Job...")
    }
    
    func onEndJobStatus() {
    }
    
    func onUpdateJobProgress(progress: Int) {
    }
    
    func onUpdateJobStatus(msg: String) {
    }
    
    func onAuthenticated(sidResponse: SIDResponse) {
        self.onCompleted("You're authenticated")
        // showMessage("Authenticated")
    }
    
    func onEnrolled(sidResponse: SIDResponse) {
        self.onCompleted("You're enrolled")
        // showMessage("Enrolled")
    }
    
    func onComplete() {
        // showMessage("Completed!")
    }
    
    func onError(sidError: SIDError) {
        self.onError(sidError.message)
        // showMessage("Error: \(sidError.message)")
    }
    
    func onIdValidated(idValidationResponse: IDValidationResponse) {
       // showMessage("ID Validated")
    }
}

let CAMERA_PERMISSION_ERROR_DESC = "We need the camera permission to capture your selfie and the verification document. Please enable it in the Settings app"
