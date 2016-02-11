//
//  CaptureSessionHelper.swift
//  FoodDecoder
//
//  Created by Boris Conforty on 11/02/16.
//  Copyright © 2016 Boris Conforty. All rights reserved.
//

import UIKit
import AVFoundation

struct CaptureSessionObjects {
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureMetadataOutput?
    var errorDescription: String?
}

class CaptureSessionHelper: NSObject {

    class func prepareSession() -> CaptureSessionObjects {
        var result = CaptureSessionObjects()
        
        result.session = AVCaptureSession()
        if result.session == nil {
            result.errorDescription = "Could not initialize capture session"
            return result
        }
        
        result.session?.sessionPreset = AVCaptureSessionPresetHigh;
        
        result.device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
        
        if result.device == nil {
            result.errorDescription = "Could not initialize capture device"
            return result
        }
        
        do {
            try result.input = AVCaptureDeviceInput(device: result.device)
        } catch {
            result.errorDescription = "Could not initialize capture device input (error thrown)"
            return result
        }
        if result.input == nil {
            result.errorDescription = "Could not initialize capture device input"
            return result
        }
        
        if result.session!.canAddInput(result.input) {
            result.session?.addInput(result.input)
        } else {
            result.errorDescription = "Could not add input to session"
            return result
        }
        
        result.output = AVCaptureMetadataOutput()
        if result.output == nil {
            result.errorDescription = "Could not initialize capture metadata output"
            return result
        }
        
        if result.session!.canAddOutput(result.output) {
            result.session?.addOutput(result.output)
        } else {
            result.errorDescription = "Could not add output to session"
            return result
        }
        result.output?.metadataObjectTypes = result.output!.availableMetadataObjectTypes
            
        return result
    }
}
