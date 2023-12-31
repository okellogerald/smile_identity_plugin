#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import FlutterMacOS
import AppKit
#endif
import Smile_Identity_SDK
import os
import Foundation

let METHOD_CHANNEL_NAME = "smile_identity_plugin";

public class SmileIdentityPluginImpl: NSObject, FlutterPlugin {
    var channel: FlutterMethodChannel!;
    var manager: SmileIdentityManager!;
    
    init(_ _channel: FlutterMethodChannel) {
        super.init()
        channel = _channel
        manager = SmileIdentityManager(channel: channel)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(
        name: METHOD_CHANNEL_NAME,
        binaryMessenger: registrar.messenger())

      let instance = SmileIdentityPluginImpl(channel)
      registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "battery_level":
            result(10);
        case "capture":
            manager.handleCapture(call)
        case "submit":
            manager.handleSubmit(call)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
