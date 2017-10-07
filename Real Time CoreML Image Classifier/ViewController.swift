//
//  ViewController.swift
//  Real Time CoreML Image Classifier
//
//  Created by Alan Rabelo Martins on 05/10/2017.
//  Copyright © 2017 alanrabelo. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    let captureSession = AVCaptureSession()
    
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var probabilityLabel: UILabel!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    var model : VNCoreMLModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        do {
            self.model = try VNCoreMLModel(for: Resnet50().model)
        } catch {
            print("Didn't added model")
            return
        }
        
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        
        let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera!)
            captureSession.addInput(input)
            
        } catch {
            print("Can't acess camera")
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(previewLayer)
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.init(label: "sample buffer delegate"))
        captureSession.addOutput(videoOutput)
        
        captureSession.startRunning()
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let coreImage = CIImage(cvPixelBuffer: pixelBuffer!)
        
        DispatchQueue.main.async {
            self.imageView.image = UIImage.init(ciImage: coreImage)

        }

        let request = VNCoreMLRequest(model: self.model, completionHandler: { (request, error) in
            guard let results = request.results as? [VNClassificationObservation]
                else { fatalError("huh") }
            
            if let best = results.first {
                
                DispatchQueue.main.async {
                    self.classLabel.text = best.identifier
                    self.probabilityLabel.text = "\((best as VNObservation).confidence)"
                    
                }
            }
            


        })

        let hander = VNImageRequestHandler(cvPixelBuffer: pixelBuffer!, orientation: .up, options: [:])
        do {
            try hander.perform([request])
        } catch {
            print("Could'nt perform")
        }

        
        
        
        
        
       
    }
    
    
}


