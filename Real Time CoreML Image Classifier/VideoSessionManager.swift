//
//  VideoSessionManager.swift
//  Real Time CoreML Image Classifier
//
//  Created by Alan Rabelo Martins on 09/10/2017.
//  Copyright © 2017 alanrabelo. All rights reserved.
//

import UIKit
import AVFoundation

class VideoSessionManager: NSObject {
    
    let captureSession = AVCaptureSession()

    var delegate : AVCaptureVideoDataOutputSampleBufferDelegate?
    
    init(withDelegate delegate : AVCaptureVideoDataOutputSampleBufferDelegate) {
        self.delegate = delegate
        
        super.init()
        
        if let delegateController = (self.delegate as? UIViewController), let previewLayer = self.configureSession(inDelegate : self.delegate) {
            delegateController.view.layer.addSublayer(previewLayer)
        }
        
    }
    
    func configureSession(inDelegate delegate  : AVCaptureVideoDataOutputSampleBufferDelegate?) -> AVCaptureVideoPreviewLayer? {
        
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            captureSession.addInput(input)
            
        } catch {
            print("Can't acess camera")
            return nil
        }
        
        
        
        if let delegate = delegate {
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            
            let videoOutput = AVCaptureVideoDataOutput()
            
            videoOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue.init(label: "sample buffer delegate"))
            captureSession.addOutput(videoOutput)
            captureSession.startRunning()
            
            return previewLayer
        }
        
        return nil
        
    }
    

}
