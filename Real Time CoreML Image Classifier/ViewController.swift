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
    
    
    
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var probabilityLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var model : VNCoreMLModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let videoManager = VideoSessionManager(withDelegate: self)
        
        do {
            self.model = try VNCoreMLModel(for: Resnet50().model)
        } catch {
            print("Didn't added model")
            return
        }
        
    }
    
    var count = 0
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let coreImage = CIImage(cvPixelBuffer: pixelBuffer!)
        
        DispatchQueue.main.async {
            self.imageView.image = UIImage.init(ciImage: coreImage)
        }

        if count < 20 {
            count += 1
            return
        }
        count = 0
        
        let request = VNCoreMLRequest(model: self.model, completionHandler: { (request, error) in
            guard let results = request.results as? [VNClassificationObservation]
                else { fatalError("huh") }
            
            if let best = results.first {
                
                DispatchQueue.main.async {
                    self.classLabel.text = best.identifier
                    self.probabilityLabel.text = "\((best as VNObservation).confidence)"
                    
                }
            } else {
                DispatchQueue.main.async {
                    self.classLabel.text = "Nothing found"
                    self.probabilityLabel.text = ""
                    
                }
            }
        })

        let hander = VNImageRequestHandler(cvPixelBuffer: pixelBuffer!, orientation: .up, options: [:])
        do {
            try hander.perform([request])
        } catch {
            print("Couldn't perform")
        }

    }

    
}


