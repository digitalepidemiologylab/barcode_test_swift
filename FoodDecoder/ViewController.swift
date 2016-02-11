//
//  ViewController.swift
//  FoodDecoder
//
//  Created by Boris Conforty on 08/02/16.
//  Copyright © 2016 Boris Conforty. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var infoLabelBackground: UIView?
    @IBOutlet weak var statusBarBackground: UIView?
    @IBOutlet weak var infoLabel:      UILabel?
    @IBOutlet weak var activeZoneView: UIView?
    
    var _captureObjects: CaptureSessionObjects?
    var _prevLayer: AVCaptureVideoPreviewLayer?
    var _highlightViews : [UIView] = []
    var _session_queue: dispatch_queue_t?
    var _detailCode: String?
    

    // Prepare capture session
    func prepareSession() {
        _captureObjects = CaptureSessionHelper.prepareSession()
        if (_captureObjects?.errorDescription != nil) {
            infoLabel?.text = _captureObjects?.errorDescription;
        }
        _captureObjects!.output?.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
    }
    
    // Prepare preview of camera output
    func preparePreview() {
        _prevLayer = AVCaptureVideoPreviewLayer(session: _captureObjects!.session)
        if _prevLayer == nil {
            infoLabel?.text = "Could not initialize capture video preview layer"
            return
        }
        _prevLayer?.frame = self.view.bounds;
        _prevLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.insertSublayer(_prevLayer!, atIndex: 0)
    }

    // Configure auto focus, point of interest, and zoom
    func configureDevice() {
        do {
            try _captureObjects!.device!.lockForConfiguration()
            if _captureObjects!.device!.autoFocusRangeRestrictionSupported {
                _captureObjects!.device?.autoFocusRangeRestriction = .Near
            }
            
            if _captureObjects!.device!.focusPointOfInterestSupported {
                let center = _prevLayer?.captureDevicePointOfInterestForPoint(self.view.center)
                _captureObjects!.device?.focusPointOfInterest = center!
            }
            
            _captureObjects!.device?.videoZoomFactor = 1.5;//(_device?.activeFormat.videoZoomFactorUpscaleThreshold)!;
            
            _captureObjects!.device?.unlockForConfiguration()
        } catch {
            
        }
    }

    // Get objects detected by the capture and filter for code bars
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Keep only objects of class AVMetadataMachineReadableCodeObject
        let objects: [AVMetadataMachineReadableCodeObject] = metadataObjects.filter { (object: AnyObject) -> Bool in
            return object.isKindOfClass(AVMetadataMachineReadableCodeObject)
            } as! [AVMetadataMachineReadableCodeObject]
        
        showObjects(objects)
    }
    
    
    // Prepare
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if _session_queue == nil {
            _session_queue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
            
            dispatch_async(_session_queue!) {
                self.prepareSession()
                dispatch_async(dispatch_get_main_queue(), {
                    self.preparePreview()
                    
                    self.activeZoneView?.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.5).CGColor
                    self.activeZoneView?.layer.borderWidth = 2;
                    self.activeZoneView?.backgroundColor = UIColor.clearColor()
                    
                    dispatch_async(self._session_queue!) {
                        self._captureObjects!.session?.startRunning()
                        self.configureDevice()
                    }
                })
            }
        }
    }
    
    // Highlight found barcodes and show text description
    func showObjects(objects: [AVMetadataMachineReadableCodeObject]) {
        var texts: [String] = []
        var highlights: [CGRect] = []
        var isFirst = true
        for object in objects {
            texts += ["\(object.type): \(object.stringValue)"]
            highlights += [_prevLayer!.transformedMetadataObjectForMetadataObject(object).bounds]
            if isFirst {
                showDetailsForCode(object.stringValue)
                isFirst = false
            }
        }
        showHighlights(highlights)
        if texts.count > 0 {
            infoLabel?.text = texts.joinWithSeparator("\n")
        }
    }
    
    func showHighlights(highlights: [CGRect]) {
        var count = 0
        for rect in highlights {
            count += 1
            var view: UIView
            if count > _highlightViews.count {
                view = UIView()
                view.layer.borderColor = UIColor.greenColor().CGColor
                view.layer.borderWidth = 2
                view.backgroundColor = UIColor.clearColor()
                self.view.addSubview(view)
                _highlightViews += [view]
            } else {
                view = _highlightViews[count - 1]
            }
            view.frame = rect
        }
        
        while count < _highlightViews.count {
            _highlightViews.last?.removeFromSuperview()
            _highlightViews.removeLast()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        restartSession()
    }
    
    @IBAction func restartSession() {
        showHighlights([])
        
        if _captureObjects?.session != nil {
            //dispatch_async(self._session_queue!) {
            self._captureObjects!.session?.startRunning()
            self.configureDevice()
            //}
        }
    }
    
    func showDetailsForCode(code: String) {
        _captureObjects!.session?.stopRunning()
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        _detailCode = code
        self.performSegueWithIdentifier("DetailFoodViewSegue", sender: self)
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc: FoodDetailViewController = segue.destinationViewController as! FoodDetailViewController
        vc.prepareURLForDetails(_detailCode!)
    }
}

