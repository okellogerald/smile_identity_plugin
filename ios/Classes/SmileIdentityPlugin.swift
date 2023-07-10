import UIKit
import Flutter
import MaterialComponents
import Smile_Identity_SDK
import os
import Foundation

struct SmileData {
    let userId: String;
    let jobId: String;
    let country: String;
    let idType: String;
    let idNumber: String;
    let firstName: String;
    let lastName: String;
    let tag: String;
}

class SmileIdentityPlugin: NSObject, SIDCaptureManagerDelegate {
     var METHOD_CHANNEL_NAME = "smile_identity_plugin";
     var channel: FlutterMethodChannel!;

    var cameraManager = CameraManager()
    
      init(binaryMessenger: FlutterBinaryMessenger) {
         super.init()
         self.channel = FlutterMethodChannel(name: METHOD_CHANNEL_NAME, binaryMessenger: binaryMessenger)
         setUpListeners()
     }

     func setUpListeners() {
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "battery_level":
                result(10);
            case "capture":
                let data = self.getSmileData(args: call.arguments as! [String:Any])
                Task {
                    await self.capture(smileData: data)
                }
            case "submit":
                let data = self.getSmileData(args: call.arguments as! [String:Any])
                Task {
                    await self.submitJob(smileData: data)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
    
    private func getSmileData(args: [String:Any]) -> SmileData {
        return SmileData(
            userId: (args["userId"] as? String) ?? "",
            jobId: (args["jobId"] as? String) ?? "",
            country: (args["country"] as? String) ?? "",
            idType: (args["idType"] as? String) ?? "",
            idNumber: (args["idNumber"] as? String) ?? "",
            firstName: (args["firstName"] as? String) ?? "",
            lastName: (args["lastName"] as? String) ?? "",
            tag: (args["tag"] as? String) ?? ""
        );
    }

    private func capture(smileData: SmileData) async {
        let granted = await cameraManager.checkCameraPermission()
        if(!granted) {
            MDCSnackbarManager.default.show(MDCSnackbarMessage(text: "We need the camera permission to capture your selfie and the verification document. Please enable it in the Settings app"))
            return
        }
                
        let captureType = CaptureType.SELFIE_AND_ID_CAPTURE
         DispatchQueue.main.async {
            var builder = SIDCaptureManager.Builder(delegate:self, captureType: captureType)
            
            if  !smileData.tag.isEmpty {
                builder = builder.setTag(tag: smileData.tag)
            }
            
            if (captureType == CaptureType.SELFIE_AND_ID_CAPTURE || captureType == CaptureType.ID_CAPTURE) {
                let sidIdCaptureConfig = SIDIDCaptureConfig.Builder().setIdCaptureType(idCaptureType: IDCaptureType.Front).build()
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
        sidNetworkRequest.setDelegate(delegate: SubmitJobListener())
        sidNetworkRequest.initialize()
        
        let sidNetData = SIDNetData(environment: SIDNetData.Environment.PROD);
        sidNetData.setCallBackUrl(callbackUrl: "https://webapi.temboplus.com/webhook/smile-identity/confirm-kyc")

        let sidConfig = SIDConfig()
        sidConfig.setSidNetworkRequest( sidNetworkRequest : sidNetworkRequest )
        sidConfig.setSidNetData( sidNetData : sidNetData )
        sidConfig.setRetryOnFailurePolicy( retryOnFailurePolicy: getRetryOnFailurePolicy() )
   
        let sidIdInfo = SIDUserIdInfo()
        sidIdInfo.setCountry(country: smileData.country )
        //sidIdInfo.setIdType(idType: smileData.idType )
        //sidIdInfo.setIdNumber(idNumber: smileData.idNumber )
        //sidIdInfo.setFirstName(firstName: smileData.firstName )
        //sidIdInfo.setLastName(lastName: smileData.lastName )
        sidConfig.setUserIdInfo(userIdInfo: sidIdInfo)
       
        let sidPartnerParams = PartnerParams()
        sidPartnerParams.setJobId(jobId: smileData.jobId )
        sidPartnerParams.setUserId(userId:  smileData.userId )
        sidPartnerParams.setJobType(jobType: 1 )
        sidPartnerParams.setAdditionalValue(key: "profile_id", val: smileData.userId)
        sidConfig.setPartnerParams( partnerParams : sidPartnerParams )
    
        sidConfig.setIsEnrollMode(isEnrollMode: true)
        let hasIdCard = SIDInfosManager.hasIdCard(userTag: smileData.tag)
        sidConfig.setUseIdCard(useIdCard: hasIdCard)
       
        sidConfig.build(userTag: smileData.tag)
        do {
            try sidConfig.getSidNetworkRequest().submit(sidConfig: sidConfig)
            channel.invokeMethod("submit_state", arguments: ["success": true])
        } catch {
            MDCSnackbarManager.default.show(MDCSnackbarMessage(text: "Submission Error: \(error.localizedDescription)"))
            channel.invokeMethod("submit_state", arguments: ["success": false])
        }
    }
    
    func getRetryOnFailurePolicy() -> RetryOnFailurePolicy {
        let options = RetryOnFailurePolicy();
        options.setMaxRetryTimeoutSec(maxRetryTimeoutSec:15 )
        options.setMaxRetryCount(maxRetryCount: 5)
        return options;
    }
    
    func onSuccess(tag: String, selfiePreview: UIImage?, idFrontPreview: UIImage?, idBackPreview: UIImage?) {
       print("Success √√√√√√√√√√")
       MDCSnackbarManager.default.show(MDCSnackbarMessage(text: "Success"))
       channel.invokeMethod("capture_state", arguments: ["success": true])
    }
    
    func onError(tag: String, sidError: Smile_Identity_SDK.SIDError) {
       print("Error \(sidError.localizedDescription)")
       MDCSnackbarManager.default.show(MDCSnackbarMessage(text: "Error: \(sidError.message)"))
       channel.invokeMethod("capture_state", arguments: ["success": false])
    }
}

class SubmitJobListener: SIDNetworkRequestDelegate {
    func onDocumentVerified(sidResponse: SIDResponse) {
        MDCSnackbarManager.default.show(MDCSnackbarMessage(text: "Document is verified"))
    }
    
    func onStartJobStatus() {
        MDCSnackbarManager.default.show(MDCSnackbarMessage(text: "Document is verified"))
    }
    
    func onEndJobStatus() {
    }
    
    func onUpdateJobProgress(progress: Int) {
    }
    
    func onUpdateJobStatus(msg: String) {
    }
    
    func onAuthenticated(sidResponse: SIDResponse) {
       MDCSnackbarManager.default.show(MDCSnackbarMessage(text: "Authenticated"))
        
    }
    
    func onEnrolled(sidResponse: SIDResponse) {
        MDCSnackbarManager.default.show(MDCSnackbarMessage(text: "Enrolled"))
    }
    
    func onComplete() {
        print("Completed")
        MDCSnackbarManager.default.show(MDCSnackbarMessage(text: "Completed"))
    }
    
    func onError(sidError: SIDError) {
        MDCSnackbarManager.default.show(MDCSnackbarMessage(text: "Error: \(sidError.message)"))
    }
    
    func onIdValidated(idValidationResponse: IDValidationResponse) {
       MDCSnackbarManager.default.show(MDCSnackbarMessage(text: "Validated"))
    }
}

