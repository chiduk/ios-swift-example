//
//  AddNoteController.swift
//  BuxBox
//
//  Created by SongChiduk on 12/29/18.
//  Copyright © 2018 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import AVFoundation

class TakePhotoController: UIViewController, AVCapturePhotoCaptureDelegate {
    override func viewDidLoad() {
        setupNavBar()
        view.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
        
//        setupCloseButton()
//        setupInputSourceButton()
        setupNavBar()
        setupView()
    }
    
    deinit {
        print("TakePhotoController denit successful")
    }
    
    weak var delegate : AddphotoDelegate?
    var ratioButton : UIButton!
    var closeButton : UIButton!
    var nextButton : UIButton!
    var topView : UIView!
    var limit = 5
    func setupNavBar() {
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.barTintColor = Color.hexStringToUIColor(hex: "#333333")
//        navigationController?.navigationBar.tintColor = .white
//
//        let backButton = UIBarButtonItem(image: UIImage(named: "backArrow"), style: .plain, target: self, action: #selector(removeImage))
//        navigationItem.leftBarButtonItem = backButton
//
        
        
        
        let nav = UINavigationController()
        let height = nav.navigationBar.frame.height
        topView = UIView()
        topView.backgroundColor = UIColor.black
        view.addSubview(topView)
        topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        topView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: height).isActive = true
        topView.translatesAutoresizingMaskIntoConstraints = false
        
        ratioButton = UIButton()
        ratioButton.setTitle("1:1", for: .normal)
        ratioButton.tintColor = .white
        ratioButton.layer.borderWidth = 1
        ratioButton.layer.borderColor = UIColor.white.cgColor
        ratioButton.addTarget(self, action: #selector(ratioButtonPressed), for: .touchUpInside)
        view.addSubview(ratioButton)
        ratioButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        ratioButton.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        ratioButton.widthAnchor.constraint(equalToConstant: (ratioButton.titleLabel?.intrinsicContentSize.width)! + marginBase*2).isActive = true
        ratioButton.heightAnchor.constraint(equalToConstant: height-marginBase).isActive = true
        ratioButton.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton = UIButton()
        closeButton.setImage(UIImage(named: "closeXIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = UIColor.white
        closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        closeButton.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: marginBase*2).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: height-marginBase).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: height-marginBase).isActive = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        nextButton = UIButton()
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(UIColor.gray, for: .disabled)
        nextButton.setTitleColor(Color.hexStringToUIColor(hex: "#FFBF2E"), for: .normal)
        nextButton.isEnabled = false
        nextButton.addTarget(self, action: #selector(nextView), for: .touchUpInside)
        view.addSubview(nextButton)
        nextButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        nextButton.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -marginBase*2).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: (nextButton.titleLabel?.intrinsicContentSize.width)! + marginBase*2).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: height-marginBase).isActive = true
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    @objc func dismissView() {
        delegate?.dismissView()
    }
    
    @objc func nextView() {
        delegate?.goTo(pageNumber: 1, direction: .forward)
    }
    
    var numberOfButtonPressed : Int = 0
    @objc func ratioButtonPressed() {
        
        if numberOfButtonPressed == 0 {
            numberOfButtonPressed += 1
            ratioButton.setTitle("1:1.3", for: .normal)
            
        } else if numberOfButtonPressed == 1 {
            numberOfButtonPressed = 0
            ratioButton.setTitle("1:1", for: .normal)
        }
        navigationItem.titleView?.frame = CGRect(x: 0, y: 0, width: (ratioButton.titleLabel?.intrinsicContentSize.width)!+(marginBase*2), height: (navigationController?.navigationBar.frame.height)!-marginBase)
    }
    
    
    
//    func setupCloseButton() {
//        let closeButton = UIBarButtonItem(image: UIImage(named: "closeXIcon"), style: .plain, target: self, action: #selector(close))
//        navigationItem.leftBarButtonItem = closeButton
//    }
    
//    var tabController : MainTabBarController?
    
//    @objc func close() {
//        self.dismiss(animated: true) {
//            self.tabController?.createAddPhotoButton()
//        }
//    }
    
    var takenImageViewWidth : CGFloat?
    var imagePreviewArray : [UIImage] = []
    var imagePreviewContainer : UIView?
    func setupPreviewImage() {
        takenImageViewWidth = view.frame.width / 4
        let viewHeightRatio = view.frame.height / view.frame.width
        let height = takenImageViewWidth! * viewHeightRatio
        nextButton.isEnabled = true
        
        if let images = imagePreviewContainer?.subviews {
            for i in images {
                if i.isKind(of: UIImageView.self) {
                    i.removeFromSuperview()
                }
            }
        }
        
        
        imagePreviewContainer?.removeFromSuperview()
        imagePreviewContainer = UIView()
        view.addSubview(imagePreviewContainer!)
        imagePreviewContainer?.topAnchor.constraint(equalTo: previewView.bottomAnchor, constant: marginBase*2).isActive = true
        imagePreviewContainer?.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        imagePreviewContainer?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imagePreviewContainer?.rightAnchor.constraint(equalTo: captureButton.leftAnchor).isActive = true
        imagePreviewContainer?.translatesAutoresizingMaskIntoConstraints = false

       
        
        for (index, element) in imagePreviewArray.enumerated() {
            
            if index == 0 {
                
                let imageView = UIImageView()
                imageView.image = element
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true
                
                imagePreviewContainer?.addSubview(imageView)
                imageView.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor).isActive = true
                imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: takenImageViewWidth!).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
                imageView.translatesAutoresizingMaskIntoConstraints = false
                
            } else {
                
                let imageView = UIImageView()
                imageView.image = element
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true
                
                imagePreviewContainer?.addSubview(imageView)
                imageView.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor, constant: CGFloat(5*(index))).isActive = true
                imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2 + CGFloat(5*(index))).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: takenImageViewWidth!).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: height).isActive = true
                imageView.translatesAutoresizingMaskIntoConstraints = false
                
            }
        }
    }
    
    var previewView = UIView()

    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var captureButton : UIButton!
    func setupView() {
        view.addSubview(previewView)
        previewView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        previewView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        previewView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        previewView.heightAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
        
        let buttonSize : CGFloat = 70
        captureButton = UIButton()
        view.addSubview(captureButton)
        captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -marginBase*8).isActive = true
        captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        captureButton.heightAnchor.constraint(equalToConstant: buttonSize).isActive = true
        captureButton.widthAnchor.constraint(equalToConstant: buttonSize).isActive = true
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.layer.cornerRadius = buttonSize / 2
        captureButton.backgroundColor = Color.hexStringToUIColor(hex: "#CFCFCF")
        captureButton.layer.borderColor = UIColor.lightGray.cgColor
        captureButton.layer.borderWidth = 3
        captureButton.addTarget(self, action: #selector(didTapOnTakePhotoButton), for: .touchUpInside)
        captureButton.setImage(UIImage(named: "camerButton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        captureButton.tintColor = UIColor.black
        captureButton.imageView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        captureButton.imageView?.clipsToBounds = true
        captureButton.imageView?.contentMode = .scaleAspectFit
        
        cameraManager.shouldEnableTapToFocus = true
        cameraManager.shouldEnableExposure = true
        cameraManager.cameraOutputMode = .stillImage
        cameraManager.cameraOutputQuality = .high
        cameraManager.focusMode = .autoFocus
        cameraManager.exposureMode = .autoExpose
        cameraManager.imageAlbumName = "BuxBox"
        cameraManager.animateShutter = true
        cameraManager.addPreviewLayerToView(self.previewView)
    }
    
    @objc func photoLibraryView() {
        let vc = PhotoLibraryController(collectionViewLayout: UICollectionViewFlowLayout())
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .overFullScreen
        present(navController, animated: true, completion: nil)
    }
    
    let cameraManager = CameraManager()

    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
    }
    
//    let viewHeight : CGFloat = 55
//    var buttonView : UIView?
//    var cameraButton : UIButton?
//    var galleryButton : UIButton?
//    func setupInputSourceButton() {
//        buttonView = UIView()
//        view.addSubview(buttonView!)
//        buttonView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        buttonView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        buttonView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        buttonView?.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
//        buttonView?.translatesAutoresizingMaskIntoConstraints = false
//
//        cameraButton = UIButton()
//        cameraButton?.setImage(UIImage(named: "camera")?.withRenderingMode(.alwaysTemplate), for: .normal)
//        cameraButton?.imageView?.clipsToBounds = true
//        cameraButton?.tintColor = buxboxthemeColor
//        cameraButton?.imageView?.contentMode = .scaleAspectFit
//        cameraButton?.setTitle("Camera", for: .normal)
//        cameraButton?.setTitleColor(cameraButton?.tintColor, for: .normal)
//
//        buttonView?.addSubview(cameraButton!)
//        cameraButton?.centerYAnchor.constraint(equalTo: (buttonView?.centerYAnchor)!).isActive = true
//        cameraButton?.leftAnchor.constraint(equalTo: (buttonView?.leftAnchor)!).isActive = true
//        cameraButton?.heightAnchor.constraint(equalToConstant: viewHeight-(marginBase*2)).isActive = true
//        cameraButton?.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
//        cameraButton?.translatesAutoresizingMaskIntoConstraints = false
//
//        galleryButton = UIButton()
//        galleryButton?.setImage(UIImage(named: "gallery")?.withRenderingMode(.alwaysTemplate), for: .normal)
//        galleryButton?.tintColor = UIColor.lightGray
//        galleryButton?.imageView?.clipsToBounds = true
//        galleryButton?.imageView?.contentMode = .scaleAspectFit
//        galleryButton?.setTitle("Gallery", for: .normal)
//        galleryButton?.setTitleColor(galleryButton?.tintColor, for: .normal)
//        galleryButton?.addTarget(self, action: #selector(photoLibraryView), for: .touchUpInside)
//
//        buttonView?.addSubview(galleryButton!)
//        galleryButton?.centerYAnchor.constraint(equalTo: (buttonView?.centerYAnchor)!).isActive = true
//        galleryButton?.rightAnchor.constraint(equalTo: (buttonView?.rightAnchor)!).isActive = true
//        galleryButton?.heightAnchor.constraint(equalToConstant: viewHeight-(marginBase*2)).isActive = true
//        galleryButton?.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
//        galleryButton?.translatesAutoresizingMaskIntoConstraints = false
//
//
//    }
    
    
    @objc func didTapOnTakePhotoButton(_ sender: UIButton) {
        if imagePreviewArray.count < limit {
            
            cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
                let scaleTransform: CGAffineTransform!
                let origin: CGPoint
                
                if(image!.size.width > image!.size.height) {
                    let scaleRatio: CGFloat = self.previewView.frame.height / image!.size.height
                    scaleTransform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
                    
                    origin = CGPoint(x: -(image!.size.width - image!.size.height) / 2.0, y: 0)
                }else {
                    let scaleRatio: CGFloat = self.previewView.frame.width / image!.size.width
                    scaleTransform = CGAffineTransform(scaleX: scaleRatio, y: scaleRatio)
                    
                    origin = CGPoint(x: 0, y:  -(image!.size.height - image!.size.width) / 2.0)
                }
                
                let size: CGSize = CGSize(width: self.previewView.frame.width, height: self.previewView.frame.height)
                
                
                if (UIScreen.main.scale >= 2.0 && UIScreen.main.responds(to: #selector(NSDecimalNumberBehaviors.scale))) {
                    UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
                }else {
                    UIGraphicsBeginImageContext(size)
                }
                
                let context = UIGraphicsGetCurrentContext()
                context!.concatenate(scaleTransform)
                
                image!.draw(at: origin)
                
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                self.showTakenPhoto(image: newImage!)
            })
            
        } else {
            
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
//        captureImageView.image = image
        showTakenPhoto(image: image!)
    }
    
    var captureImageView : UIImageView?
    func showTakenPhoto(image : UIImage) {
//        captureImageView?.removeFromSuperview()
//        captureImageView = UIImageView()
//        captureImageView?.image = image
//        captureImageView?.contentMode = .scaleAspectFill
//        captureImageView?.clipsToBounds = true
//
//        view.addSubview(captureImageView!)
//        captureImageView?.topAnchor.constraint(equalTo: previewView.topAnchor).isActive = true
//        captureImageView?.leftAnchor.constraint(equalTo: previewView.leftAnchor).isActive = true
//        captureImageView?.rightAnchor.constraint(equalTo: previewView.rightAnchor).isActive = true
//        captureImageView?.bottomAnchor.constraint(equalTo: previewView.bottomAnchor).isActive = true
//        captureImageView?.translatesAutoresizingMaskIntoConstraints = false
        
        imagePreviewArray.append(image)
        setupPreviewImage()
        
//        let nextButton = SelectImageNextRightBar(title: "Next", style: .plain, target: self, action: #selector(nextPressed))
//
//        navigationItem.rightBarButtonItem = nextButton
        
    }
    
    
    @objc func nextPressed() {
//        let vc = SelectAndCropViewController()
//        vc.imageArray = imagePreviewArray
//        navigationController?.pushViewController(vc, animated: true)
        delegate?.goTo(pageNumber: 2, direction: .forward)
    }
    
    
    
    @objc func removeImage() {
        
        captureImageView?.removeFromSuperview()
        
//        setupCloseButton()
    }
    
    var cameraDevice : AVCaptureDevice!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first as! UITouch
        let screenSize = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width)
        let focusPoint = CGPoint(x: touchPoint.location(in: previewView).x, y: touchPoint.location(in: previewView).y)
        
//        if let device = cameraDevice {
//            if device.lockForConfiguration() {
//                device.focusPointOfInterest = focusPoint
//                device.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
//                device.exposurePointOfInterest = focusPoint
//                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
//                device.unlockForConfiguration()
//            }
//        }
        
        if let device = cameraDevice {
            do {
                try device.lockForConfiguration()
                device.focusPointOfInterest = focusPoint
                device.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
}
