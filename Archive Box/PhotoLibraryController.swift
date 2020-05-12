//
//  PhotoLibraryController.swift
//  BuxBox
//
//  Created by SongChiduk on 18/01/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import Photos

class PhotoLibraryController : UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        fetchPhotos()
        startPhotoImport()
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        let closeButton = UIButton()
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(buxboxthemeColor, for: .normal)
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = closeButton
        navigationItem.leftBarButtonItem = leftBarButton
        
        let nextButton = UIButton()
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(buxboxthemeColor, for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = nextButton
        navigationItem.rightBarButtonItem = rightBarButton
        
        view.backgroundColor = UIColor.clear
        setupCollectionView()
    }
    
    @objc func nextButtonPressed() {
        
        let vc = SelectAndCropViewController()
        vc.photoLibarary = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func reloadData() {
        self.collectionView.reloadData()
    }
    
    let photos = PHPhotoLibrary.authorizationStatus()
    func startPhotoImport() {
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    self.getPhotos() { [unowned self] assets in

                        self.photoAssets.removeAll()
                        for i in assets {
                            let dataModel = SelectPhotoModel()
                            dataModel.photo = i
                            dataModel.photoID = i.localIdentifier

//                            if (self.imageSelectorController?.selectedPhoto.count)! > 0 {
//                                for a in (self.imageSelectorController?.selectedPhoto)! {
//                                    if a.photoID == dataModel.photoID {
//                                        print("found a match")
//                                        dataModel.number = a.number
//                                        dataModel.isSelected = a.isSelected
//                                    }
//                                }
//                            }
                            
                            self.photoData.append(dataModel)
                        }
//                        self.changeSelectNumber()
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                        
                    }
                } else {
                    let alert = UIAlertController(title: "Photo Access Denied", message: "App needs access to photo library", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                        if let settingURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
                        }
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(alertAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else if photos == .authorized {
            getPhotos() { [unowned self] assets in
                self.photoAssets.removeAll()
                for i in assets {
                    let dataModel = SelectPhotoModel()
                    dataModel.photo = i
                    dataModel.photoID = i.localIdentifier

//                    if (self.imageSelectorController?.selectedPhoto.count)! > 0 {
//                        for a in (self.imageSelectorController?.selectedPhoto)! {
//                            if a.photoID == dataModel.photoID {
//                                print("found a match")
//                                dataModel.number = a.number
//                                dataModel.isSelected = a.isSelected
//                            }
//                        }
//                    }

                    self.photoData.append(dataModel)
                }
//                self.changeSelectNumber()
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                
            }
        }
    }

    var photoData = [SelectPhotoModel]()
    
    var photoAssets = [PHAsset]()
    
    func getPhotos(_ completion: @escaping ( _ assets: [PHAsset]) -> Void) {
        
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {return}
        
        DispatchQueue.global(qos: .background).async {
            let fetchResult = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
            
            if fetchResult.count > 0 {
                var assetArray = [PHAsset]()
                fetchResult.enumerateObjects({ object, _, _ in
                    assetArray.insert(object, at: 0)
                })
                
                DispatchQueue.main.async {
                    completion(assetArray)
                }
            }
        }
        
    }
    
//    func getAccessToPhoto() {
//        if photos == .notDetermined {
//            PHPhotoLibrary.requestAuthorization { (status) in
//                if status == .authorized {
//
//                    self.fetchPhotos()
//
//                } else {
//                    let alert = UIAlertController(title: "Photo Access Denied", message: "App needs access to photo library", preferredStyle: .alert)
//                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
//                        if let settingURL = URL(string: UIApplication.openSettingsURLString) {
//                            UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
//                        }
//                    })
//                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
//                        self.dismiss(animated: true, completion: nil)
//                    })
//                    alert.addAction(alertAction)
//                    alert.addAction(cancelAction)
//                    self.present(alert, animated: true, completion: nil)
//                }
//            }
//        } else if photos == .authorized {
//
//            self.fetchPhotos()
//
//        }
//    }
//
//
//    func fetchPhotos() {
//        let imageManager = PHImageManager.default()
//        let requestOptions = PHImageRequestOptions()
//        requestOptions.isSynchronous = true
//        requestOptions.deliveryMode = .fastFormat
//
//        let fetchOptions = PHFetchOptions()
//        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//
//        if let fetchResult : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) {
//            if fetchResult.count > 0 {
//                for i in 0..<fetchResult.count {
//                    imageManager.requestImage(for: fetchResult.object(at: i), targetSize: CGSize(width: 400, height: 400), contentMode: .aspectFill, options: requestOptions) { (image, error) in
//                        let data = SelectPhotoModel()
//                        data.image = image
//                        self.photoData.append(data)
//                    }
//                }
//                collectionView.reloadData()
//            } else {
//                print("You have no phots")
//            }
//        }
//    }
    
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupView() {
        
    }
    
    func setupCollectionView() {
        collectionView.backgroundColor = UIColor.white
        collectionView.register(PhotoLibraryCell.self, forCellWithReuseIdentifier: "PhotoLibraryCell")
    }
    
   
    
    var cell : PhotoLibraryCell?
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = photoData[indexPath.item]
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoLibraryCell", for: indexPath) as! PhotoLibraryCell
        
//        DispatchQueue.main.async {
//            self.cell?.imageSet = self.getAssetThumbnail(assets: data.photo!, type: PhotoType.fast)
//        }
        
      
        self.cell?.imageSet = getAssetThumbnail(assets: data.photo!, type: PhotoType.fast)
//        cell?.imageSet = data.image

        cell?.selectIconSet = data.isSelected
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size =  (view.frame.width / 2) - marginBase
        return CGSize(width: size, height: size)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoData.count
        
    }
    
    var selectedPhoto = [SelectPhotoModel]()
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = photoData[indexPath.item]
        data.isSelected = !data.isSelected
        selectedPhoto.append(data)
        collectionView.reloadItems(at: [indexPath])
    }
    

}

class PhotoLibraryCell : UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var imageView : UIImageView?
    var imageSet : UIImage? {
        didSet {
            imageView?.removeFromSuperview()
            imageView = UIImageView()
            imageView?.frame = contentView.frame
            imageView?.image = imageSet
            imageView?.contentMode = .scaleAspectFit
            imageView?.clipsToBounds = true
            
            contentView.addSubview(imageView!)
            
        }
    }
    
    var image: String? {
        didSet {
            imageView?.removeFromSuperview()
            imageView = UIImageView()
            imageView?.frame = contentView.frame
            if let image = image {
                imageView?.kf.setImage(with: URL(string: RestApi.noteImage + image))
            }else{
                
            }
            imageView?.contentMode = .scaleAspectFit
            imageView?.clipsToBounds = true
            
            contentView.addSubview(imageView!)
        }
    }
    
    var selectButton : UIButton?
    var selectIconSet : Bool? {
        didSet {
            let size : CGFloat = 20
            selectButton?.removeFromSuperview()
            selectButton = UIButton()
            selectButton?.backgroundColor = UIColor.clear
            selectButton?.layer.cornerRadius = size/2
            selectButton?.layer.borderColor = buxboxthemeColor.cgColor
            selectButton?.layer.borderWidth = 5
            
            if selectIconSet == true {
                selectButton?.backgroundColor = buxboxthemeColor
            } else {
                selectButton?.backgroundColor = UIColor.clear
            }
            
            contentView.addSubview(selectButton!)
            selectButton?.topAnchor.constraint(equalTo: contentView.topAnchor, constant: marginBase).isActive = true
            selectButton?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -marginBase).isActive = true
            selectButton?.widthAnchor.constraint(equalToConstant: size).isActive = true
            selectButton?.heightAnchor.constraint(equalToConstant: size).isActive = true
            selectButton?.translatesAutoresizingMaskIntoConstraints = false
            
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class SelectPhotoModel : NSObject {
    var image : UIImage?
    var photo : PHAsset?
    var photoID : String?
    var isSelected : Bool = false
    var selectedNumber : Int?
}

enum PhotoType {
    case fast
    case max
}


func getAssetThumbnail(assets: PHAsset, type: PhotoType) -> UIImage {
    
    let manager = PHImageManager.default()
    let option = PHImageRequestOptions()
    var image = UIImage()
    option.isSynchronous = true
    
    if type == PhotoType.fast {
        
        option.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
        manager.requestImage(for: assets, targetSize: CGSize(width: 800, height: 800), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            image = result!
        })
        
    } else {
        
        option.resizeMode = .exact
        manager.requestImage(for: assets, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
            image = result!
        })
        
    }
    
    return image
}
