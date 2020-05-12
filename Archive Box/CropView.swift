//
//  CropView.swift
//  BuxBox
//
//  Created by SongChiduk on 06/03/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit

class CropView : UIView {
    
    var imageSelectView : SelectAndCropViewController?
    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    
    var imageView : UIImageView!
    var imageSet : UIImage? {
        didSet {
            if let data = imageSet {
                
                imageView = UIImageView()
                imageView.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
                imageView.image = data
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true
                
                self.addSubview(imageView)
                imageView.frame = self.bounds
                setupCropTool()
            }
        }
    }
    
    var cropView : UIView!
    var cropViewWidth : CGFloat = 0
    var cropViewHeight : CGFloat = 0
    var leftTop : UIImageView!
    var leftTopPan : UIPanGestureRecognizer!

    var leftBottom : UIImageView!
    var leftBottomPan : UIPanGestureRecognizer!
    
    var rightTop : UIImageView!
    var rightTopPan : UIPanGestureRecognizer!

    var rightBottom : UIImageView!
    var rightBottomPan : UIPanGestureRecognizer!

    func setupCropTool() {
        cropViewWidth = imageView.frame.width - 10
        cropViewHeight = imageView.frame.height - 10
        cropView = UIView()

        cropView.backgroundColor = UIColor.clear
        cropView.layer.borderColor = UIColor.blue.cgColor
        cropView.layer.borderWidth = 3
        self.addSubview(cropView)
        
        leftTop = UIImageView()
        leftTop.image = UIImage(named: "leftTop")?.withRenderingMode(.alwaysTemplate)
        leftTop.tintColor = UIColor.blue
        
        self.addSubview(leftTop)
        leftTop.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        leftTopPan = UIPanGestureRecognizer(target: self, action: #selector(moveCropBox(sender: )))
        leftTop.addGestureRecognizer(leftTopPan)
        leftTop.backgroundColor = UIColor.clear
        
        
        leftBottom = UIImageView()
        leftBottom.image = UIImage(named: "leftBottom")?.withRenderingMode(.alwaysTemplate)
        leftBottom.tintColor = UIColor.blue
        self.addSubview(leftBottom)
        leftBottom.frame = CGRect(x: imageView.frame.minX, y: imageView.frame.height-50, width: 50, height: 50)
        leftBottom.backgroundColor = UIColor.clear
        leftBottomPan = UIPanGestureRecognizer(target: self, action: #selector(moveCropBox(sender: )))
        leftBottom.addGestureRecognizer(leftBottomPan)

        
        rightTop = UIImageView()
        rightTop.image = UIImage(named: "rightTop")?.withRenderingMode(.alwaysTemplate)
        rightTop.tintColor = UIColor.blue
        self.addSubview(rightTop)
        rightTop.frame = CGRect(x: imageView.frame.width - 50, y: imageView.frame.minY, width: 50, height: 50)
        rightTopPan = UIPanGestureRecognizer(target: self, action: #selector(moveCropBox(sender: )))
        rightTop.addGestureRecognizer(rightTopPan)

        
        rightBottom = UIImageView()
        rightBottom.image = UIImage(named: "rightBottom")?.withRenderingMode(.alwaysTemplate)
        rightBottom.tintColor = UIColor.blue
        self.addSubview(rightBottom)
        rightBottom.frame = CGRect(x: imageView.frame.width - 50, y: imageView.frame.height-50, width: 50, height: 50)
        rightBottomPan = UIPanGestureRecognizer(target: self, action: #selector(moveCropBox(sender: )))
        rightBottom.addGestureRecognizer(rightBottomPan)
        
        cropView.frame = CGRect(x: leftTop.frame.minX, y: leftTop.frame.minY, width: rightTop.frame.maxX - leftTop.frame.minX, height: rightBottom.frame.maxY-rightTop.frame.minY)

    }
    
    @objc func targerTest() {
        print("corner pressed")
    }
    
    var initialPoint = CGPoint(x: 0, y: 0)
    @objc func moveCropBox(sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: self.imageView)
        
        let initialLeftTopX = leftTop.frame.minX
        let initialleftTopY = leftTop.frame.minY
        
        let initialLeftBottomX = leftBottom.frame.minX
        let initialLeftBottomY = leftBottom.frame.minY
        
        let initialRightTopX = rightTop.frame.minX
        let initialRightTopY = rightTop.frame.minY
        
        let initialRightBottomX = rightBottom.frame.minX
        let initialRightBottomY = rightBottom.frame.minY
        
        switch sender.state {
        case .began :
            initialPoint = touchPoint

        case .changed :
            let xPoint = touchPoint.x-25
            let yPoint = touchPoint.y-25
            if sender == leftTopPan {
                
                if xPoint > initialRightTopX || yPoint > initialLeftBottomY {
                    return
                } else {
                    leftTop.frame = CGRect(x: xPoint, y: yPoint, width: 50, height: 50)
                    leftBottom.frame = CGRect(x: xPoint, y: initialLeftBottomY, width: 50, height: 50)
                    rightTop.frame = CGRect(x: initialRightTopX, y: yPoint, width: 50, height: 50)
                    updateCropViewFrame(sender: leftTopPan)
                }
                
                
            } else if sender == leftBottomPan {
                
                if xPoint > initialRightTopX || yPoint < initialleftTopY {
                    return
                } else {
                    leftBottom.frame = CGRect(x: xPoint, y: yPoint, width: 50, height: 50)
                    leftTop.frame = CGRect(x: xPoint, y: initialleftTopY, width: 50, height: 50)
                    rightBottom.frame = CGRect(x: initialRightBottomX, y: yPoint, width: 50, height: 50)
                    updateCropViewFrame(sender: leftBottomPan)
                }
                
            } else if sender == rightTopPan {
                
                if xPoint < initialLeftTopX || yPoint > initialRightBottomY {
                    return
                } else {
                    rightTop.frame = CGRect(x: xPoint, y: yPoint, width: 50, height: 50)
                    leftTop.frame = CGRect(x: initialLeftTopX, y: yPoint, width: 50, height: 50)
                    rightBottom.frame = CGRect(x: xPoint, y: initialRightBottomY, width: 50, height: 50)
                    updateCropViewFrame(sender: rightTopPan)
                }
                
            } else {
                
                if xPoint < initialLeftBottomX || yPoint < initialRightTopY {
                    return
                } else {
                    rightBottom.frame = CGRect(x: xPoint, y: yPoint, width: 50, height: 50)
                    leftBottom.frame = CGRect(x: initialLeftBottomX, y: yPoint, width: 50, height: 50)
                    rightTop.frame = CGRect(x: xPoint, y: initialRightTopY, width: 50, height: 50)
                    updateCropViewFrame(sender: rightBottomPan)
                }
            
            }
            
        case .ended :
            print("ended")
        default:
            break
        }
    }
    
    func updateCropViewFrame(sender: UIPanGestureRecognizer) {
        if sender == leftTopPan || sender == leftBottomPan {
            
                cropView.frame = CGRect(x: leftTop.frame.minX, y: leftTop.frame.minY, width: rightTop.frame.maxX - leftTop.frame.minX, height: leftBottom.frame.maxY-leftTop.frame.minY)
            
        } else {
            cropView.frame = CGRect(x: leftTop.frame.minX, y: leftTop.frame.minY, width: rightTop.frame.maxX - leftTop.frame.minX, height: rightBottom.frame.maxY-rightTop.frame.minY)
        }
    }
    
    func finishCropPressed() {
        
        let sendingImage = imageView.image

        imageView.image = cropImage(sendingImage!, toRect: cropView.frame, viewWidth: self.frame.width, viewHeight: self.frame.width)
        imageSelectView?.doneCrop?.setTitle("Save", for: .normal)

        imageSelectView?.doneWidth?.constant = (imageSelectView?.doneCrop?.titleLabel?.intrinsicContentSize.width)!
        
        imageSelectView?.cancel?.setTitle("Cancel Crop", for: .normal)
        imageSelectView?.cancelWidth?.constant = (imageSelectView?.cancel?.titleLabel?.intrinsicContentSize.width)!


        toggleCropViewView()
    }
    
    func toggleCropViewView() {
        cropView.isHidden = !cropView.isHidden
        leftTop.isHidden = !leftTop.isHidden
        leftBottom.isHidden = !leftBottom.isHidden
        rightTop.isHidden = !rightTop.isHidden
        rightBottom.isHidden = !rightBottom.isHidden
    }
    
    
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
        let imageViewScale = max((inputImage.size.width*inputImage.scale) / viewWidth,
                                 (inputImage.size.height*inputImage.scale) / viewHeight)
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)

        
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
            else {
                return nil
        }

        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
