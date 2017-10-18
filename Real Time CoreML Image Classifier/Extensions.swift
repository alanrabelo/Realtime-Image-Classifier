//
//  Extensions.swift
//  Real Time CoreML Image Classifier
//
//  Created by Alan Rabelo Martins on 09/10/2017.
//  Copyright © 2017 alanrabelo. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension CMSampleBuffer {
    
    var ciimage : CIImage? {
        
        guard let buffer = CMSampleBufferGetImageBuffer(self) else {
            return nil
        }
        return CIImage(cvPixelBuffer: buffer)
        
    }
}
