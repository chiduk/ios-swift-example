//
//  ImageView.swift
//  BuxBox
//
//  Created by SongChiduk on 10/01/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit

class Triangle : UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupImage() {
        self.image = UIImage(named: "triangle")?.withRenderingMode(.alwaysTemplate)
        self.contentMode = .scaleAspectFit
        self.clipsToBounds = true
        self.tintColor = buxboxthemeColor
    }
    
    var isTapped : Bool? {
        didSet {
            if isTapped == true {
                UIView.animate(withDuration: 0.2) {
                    self.transform = CGAffineTransform(rotationAngle: CGFloat(Double(90) * .pi/180))
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.transform = CGAffineTransform.identity
                }
            }
        }
    }
    
}

func convertImageToBW(image:UIImage) -> UIImage {
    
    let filter = CIFilter(name: "CIPhotoEffectMono")
    
    // convert UIImage to CIImage and set as input
    
    let ciInput = CIImage(image: image)
    filter?.setValue(ciInput, forKey: "inputImage")
    
    // get output CIImage, render as CGImage first to retain proper UIImage scale
    
    let ciOutput = filter?.outputImage
    let ciContext = CIContext()
    let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
    
    return UIImage(cgImage: cgImage!)
}
