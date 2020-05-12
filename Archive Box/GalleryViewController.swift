//
//  GalleryViewController.swift
//  BuxBox
//
//  Created by SongChiduk on 28/02/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import Photos
import ObjectMapper

protocol GalleryPhotoDelegate : class {
    func saveIntoFolder(sender: HistoryDataModel)
    func addPhoto(sender: [UIImage])
}

class GalleryViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, FolderSelectDelegate {
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.hexStringToUIColor(hex: "#3E3E3E")
        getPhotoData()
        setupView()
        setupCollectionView()
       
        setupFolderView()
        setupKeyBoardNotification()
    }
    
    weak var delegate : GalleryPhotoDelegate?
    var isForFolder : Bool = true
    var limit = 5
    func setupKeyBoardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    var emptyViewHeight : CGFloat = 0
    var keyboardHeight : CGFloat = 0
    @objc func keyboardShow(_ notification: Notification) {
        
        let keyBoardFrame = (notification.userInfo? [UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        keyboardHeight = (keyBoardFrame?.height)!
        let keyBoardDuration = (notification.userInfo? [UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        emptyViewHeight = view.frame.height - (keyBoardFrame?.height)! - (marginBase*10)
        
        
        if isFolderOn == true {
            let newFolderHeight = tagViewHeight + keyboardHeight
            folderHeightConstraint?.constant = newFolderHeight
        }
        
        UIView.animate(withDuration: keyBoardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    var keyBoardDuration : Double = 0
    @objc func keyboardHide(_ notification: Notification) {
        
        keyBoardDuration = (notification.userInfo? [UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        
        
        UIView.animate(withDuration: keyBoardDuration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    let photos = PHPhotoLibrary.authorizationStatus()
    func getPhotoData() {
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    self.getPhotos() { [unowned self] assets in
                        
                        self.listImageArray.removeAll()
                        for i in assets {
                            let dataModel = PhotoDataModel()
                            dataModel.phImage = i
                            dataModel.id = i.localIdentifier
                            
                            self.listImageArray.append(dataModel)
                        }
                        
                        DispatchQueue.main.async {
                            self.listCollectionView.reloadData()
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
                self.listImageArray.removeAll()
                for i in assets {
                    let dataModel = PhotoDataModel()
                    dataModel.phImage = i
                    dataModel.id = i.localIdentifier
                    
                    self.listImageArray.append(dataModel)
                }
                
                DispatchQueue.main.async {
                    self.listCollectionView.reloadData()
                }
            }
        }
    }
    
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
    
    enum PhotoQuality {
        case fast
        case high
    }
    
    func convertPHAssetToUIImage(asset : PHAsset, quality: PhotoQuality, imageSize: CGFloat) -> UIImage {
        
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        if quality == .fast {
            option.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
            manager.requestImage(for: asset, targetSize: CGSize(width: imageSize, height: imageSize), contentMode: .aspectFit, options: option) { (result, info)->Void in
                image = result!
            }
        } else {
            option.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            manager.requestImage(for: asset, targetSize: CGSize(width: 1080, height: 1080), contentMode: .aspectFit, options: option) { (result, info)->Void in
                image = result!
            }
        }
        
        return image
    }
    
    
    deinit {
        print("GalleryViewController denit successful")
    }
    
    func setupView() {
        setupTopBar()
    }
    var barView : UIView!
    var closeButton : UIButton!
    var rightSideButton : UIButton!
    func setupTopBar() {
        let barHeight : CGFloat = 50
        barView = UIView()
        barView.backgroundColor = .black
        view.addSubview(barView)
        barView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        barView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        barView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        barView.heightAnchor.constraint(equalToConstant: barHeight).isActive = true
        barView.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonHeight = barHeight - marginBase
        
        let leftSideButton = UIButton()
        leftSideButton.setImage(UIImage(named: "closeXIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        leftSideButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        leftSideButton.imageView?.contentMode = .scaleAspectFit
        leftSideButton.imageView?.clipsToBounds = true
        leftSideButton.tintColor = .white
        
        view.addSubview(leftSideButton)
        leftSideButton.centerYAnchor.constraint(equalTo: barView.centerYAnchor).isActive = true
        leftSideButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase).isActive = true
        leftSideButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        leftSideButton.widthAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        leftSideButton.translatesAutoresizingMaskIntoConstraints = false
        
        rightSideButton = UIButton()
        rightSideButton.isEnabled = false
        rightSideButton.setTitle("저장", for: .normal)
        rightSideButton.setTitleColor(.white, for: .disabled)
        rightSideButton.setTitleColor(.black, for: .normal)
        rightSideButton.addTarget(self, action: #selector(saveIntoFolder), for: .touchUpInside)
        let rightButtonWidth = (rightSideButton.titleLabel?.intrinsicContentSize.width)! + (marginBase*2)
        let rightButtonHeight = (rightSideButton.titleLabel?.intrinsicContentSize.height)! + (marginBase*1.5)
        rightSideButton.layer.cornerRadius = rightButtonHeight/2
        rightSideButton.backgroundColor = Color.hexStringToUIColor(hex: "#B5B5B5")
        
        view.addSubview(rightSideButton)
        rightSideButton.centerYAnchor.constraint(equalTo: barView.centerYAnchor).isActive = true
        rightSideButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -marginBase).isActive = true
        rightSideButton.heightAnchor.constraint(equalToConstant: rightButtonHeight).isActive = true
        rightSideButton.widthAnchor.constraint(equalToConstant: rightButtonWidth).isActive = true
        rightSideButton.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    @objc func closeView() {
        self.dismiss(animated: true) {
            print("dismiss pressed")
        }
    }
    
    lazy var selectedCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    lazy var listCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
   
    
    func setupCollectionView() {
        setupSelectedView()
        setupPhotoListView()
    }
    var selectedViewHeight : CGFloat = 0
    var selectedCollectionViewHeight : NSLayoutConstraint?
    func setupSelectedView() {
        selectedViewHeight = view.frame.width / 3.5
        selectedCollectionView.register(SelectedPhotoCell.self, forCellWithReuseIdentifier: "SelectedPhotoCell")
        selectedCollectionView.backgroundColor = Color.hexStringToUIColor(hex: "#AAAAAA")
        selectedCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        view.addSubview(selectedCollectionView)
        selectedCollectionView.topAnchor.constraint(equalTo: barView.bottomAnchor).isActive = true
        selectedCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        selectedCollectionView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        selectedCollectionViewHeight = NSLayoutConstraint(item: selectedCollectionView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        selectedCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(selectedCollectionViewHeight!)
    }
    
    var listCollectionTop : NSLayoutConstraint?
    func setupPhotoListView() {
        listCollectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: "ListCollectionViewCell")
        listCollectionView.backgroundColor = .white
        listCollectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
        view.addSubview(listCollectionView)
        listCollectionTop = NSLayoutConstraint(item: listCollectionView, attribute: .top, relatedBy: .equal, toItem: barView, attribute: .bottom, multiplier: 1, constant: 0)
//        listCollectionView.topAnchor.constraint(equalTo: selectedCollectionView.bottomAnchor).isActive = true
        listCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        listCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        listCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        listCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(listCollectionTop!)
    }
    
    var selectedImageArray = [PhotoDataModel]()
    
    var listImageArray = [PhotoDataModel]()

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == selectedCollectionView {
            return selectedImageArray.count
        } else {
            return listImageArray.count
        }
    }
    var selectedPhotoCell : SelectedPhotoCell?
    var listCell : ListCollectionViewCell?
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == selectedCollectionView {
            selectedPhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectedPhotoCell", for: indexPath) as? SelectedPhotoCell
            
            let data = selectedImageArray[indexPath.row]
            
            if let imageData = data.phImage {
                selectedPhotoCell?.imageSet = convertPHAssetToUIImage(asset: imageData, quality: .fast, imageSize: view.frame.width/3)
            }
            
            selectedPhotoCell?.closeButton?.id = data.id
            selectedPhotoCell?.closeButton?.addTarget(self, action: #selector(deleteButtonPressed), for: .touchUpInside)
            

            return selectedPhotoCell!
        } else {
            
            listCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell", for: indexPath) as? ListCollectionViewCell
            let data = listImageArray[indexPath.row]
            data.indexValFromListCollectionView = indexPath.item
            
            if let imageData = data.phImage {
                listCell?.imageSet = convertPHAssetToUIImage(asset: imageData, quality: .fast, imageSize: view.frame.width/3)
            }
            
            let imageTap = CustomTapGestureRecognizer(target: self, action: #selector(imageTapped))
            imageTap.data = data
            imageTap.index = indexPath.item
            listCell?.imageView?.addGestureRecognizer(imageTap)
            listCell?.imageView?.isUserInteractionEnabled = true
            if let numberData = data.number {
                listCell?.selectedNumberCountSet = numberData
            }
            
            return listCell!
        }
    }
    
    @objc func imageTapped(sender: CustomTapGestureRecognizer) {
        if listImageArray[sender.index!].isSelected == false {
            
            if selectedImageArray.count > self.limit - 1{
                let action = UIAlertController(title: nil, message: String(format: "이미지를 한번에 %d장까지 업로드 할 수 있습니다.", self.limit), preferredStyle: .alert)
                action.addAction(UIAlertAction(title: "확인", style: .cancel, handler: {(action) in
                    return
                }))
                
                self.present(action, animated: true, completion: {() in
                    return
                })
            }else{
                let index = selectedImageArray.count
                selectedImageArray.append(sender.data!)
                selectedCollectionView.reloadData()
                selectedCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .right, animated: true)
                
                if selectedImageArray.count > 0 {
                    rightSideButton.isEnabled = true
                    rightSideButton.backgroundColor = Color.hexStringToUIColor(hex: "#FFBC52")
                    
                    if selectedCollectionViewHeight?.constant == 0 {
                        selectedCollectionViewHeight?.constant = selectedViewHeight
                        listCollectionTop?.constant = selectedViewHeight
                        UIView.animate(withDuration: 0.5) {
                            self.view.layoutIfNeeded()
                        }
                    }
                }
                listImageArray[sender.index!].isSelected = true
                
            }
            
            
            
        } else {
            for (index, element) in selectedImageArray.enumerated() {
                
                if element.indexValFromListCollectionView == sender.index {
                    selectedImageArray.remove(at: index)
                    selectedCollectionView.performBatchUpdates({
                        selectedCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                    }, completion: nil)
                }
                
            }
            listImageArray[sender.index!].isSelected = false
            listImageArray[sender.index!].number = 0
        }
        
        
        if selectedImageArray.count == 0 {
            selectedImageArray.removeAll()
            selectedCollectionView.reloadData()
            selectedCollectionViewHeight?.constant = 0
            listCollectionTop?.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            rightSideButton.isEnabled = false
            rightSideButton.backgroundColor = Color.hexStringToUIColor(hex: "#B5B5B5")
        }
        
        updateSelectedNumber()
    }
    
    @objc func deleteButtonPressed(sender: CloseButton) {
        selectedCollectionView.performBatchUpdates({
            let id = sender.id
            
            for (index, element) in selectedImageArray.enumerated() {
                if element.id == id {
                    selectedImageArray.remove(at: index)
                    selectedCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                    listImageArray[element.indexValFromListCollectionView!].number = 0
                    listImageArray[element.indexValFromListCollectionView!].isSelected = false
                }
            }
            
        }) { (bool) in
            if bool == true {
                
            } else {
                
            }
        }
        
        if selectedImageArray.count == 1 {

        } else {

        }
        
        if selectedImageArray.count == 0 {
            selectedImageArray.removeAll()
            selectedCollectionView.reloadData()
            selectedCollectionViewHeight?.constant = 0
            listCollectionTop?.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            rightSideButton.isEnabled = false
            rightSideButton.backgroundColor = Color.hexStringToUIColor(hex: "#B5B5B5")
        }
        updateSelectedNumber()
    }
    
    func updateSelectedNumber() {
        for (index, element) in selectedImageArray.enumerated() {
            listImageArray[element.indexValFromListCollectionView!].number = index + 1
        }
        listCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == selectedCollectionView {
            return CGSize(width: selectedViewHeight, height: selectedViewHeight)
        } else {
            let size = (view.frame.width/3)-(4*2)
            return CGSize(width: size, height: size)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == selectedCollectionView {
            return CGFloat(4)
        } else {
            return CGFloat(10)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == listCollectionView {
            endEditing()
        }
    }
    
    func presentFolderView() {
        folderHeightConstraint?.constant = folderHeight
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
        isFolderOn = true
    }
    
    var folder : FolderSelectionViewController?
    var folderBottomConstraint : NSLayoutConstraint?
    var folderHeightConstraint : NSLayoutConstraint?
    var folderHeight : CGFloat = 0
    var tagViewHeight : CGFloat = 0
    var folderSelectViewHeight : CGFloat = 0
    var isFolderOn : Bool = false
    func setupFolderView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        folder = FolderSelectionViewController(collectionViewLayout: layout)
        folder?.delegate = self
        let cellWidth = view.frame.width / 3.5
        
        folder?.cellSize = cellWidth
        tagViewHeight = (marginBase*2) + 18 + marginBase + (folder?.viewAllButtonSize)! + (marginBase*2)
        folderSelectViewHeight = (marginBase*2) + 18 + (marginBase*2) + cellWidth + (marginBase) + (folder?.viewAllButtonSize)! + (marginBase*2)
        folderHeight = tagViewHeight + folderSelectViewHeight
        let folderView = (folder?.view)!
        let path = UIBezierPath(roundedRect:folderView.bounds, byRoundingCorners:[.topLeft, .topRight], cornerRadii: CGSize(width: 20, height:  20))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        
        folderView.layer.mask = maskLayer
        self.addChild(folder!)
        view.addSubview(folderView)
        folderView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        folderView.translatesAutoresizingMaskIntoConstraints = false
        folderHeightConstraint = NSLayoutConstraint(item: folderView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        folderBottomConstraint = NSLayoutConstraint(item: folderView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraints([folderHeightConstraint!, folderBottomConstraint!])
        folder?.cancelbutton?.addTarget(self, action: #selector(endEditing), for: .touchUpInside)
        folder?.tagField?.delegate = self
        
    }
    
    @objc func endEditing() {
        folderHeightConstraint?.constant = 0
        isFolderOn = false
        view.endEditing(true)
        UIView.animate(withDuration: keyBoardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func saveIntoFolder() {
        if isForFolder == true {
            presentFolderView()
        } else {
            convertPHAssetArray(asset: selectedImageArray) { (array, bool) in
                if bool == true {
                    self.delegate?.addPhoto(sender: array)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func folderSelected(sender: HistoryDataModel) {
        
        convertPHAssetArray(asset: selectedImageArray) { (array, bool) in
            if bool  {
                sender.imageArrayForTesting = array
                self.showSpinner(onView: self.view)
                do{
                    let params = [
                        "uniqueId": JoinUserInfo.getInstance.uniqueId,
                        "folderName": (sender.folderName?.trimmingCharacters(in: .whitespaces)) ?? "",
                        "hashTags" : sender.hashTagArray ?? ""
                        ] as [String:Any]
                    
                    let request = try createImageUploadRequest(url: RestApi.addNoteImage, parameters: params, images: array)
                    URLSession(configuration: .default).dataTask(with: request){(data, response, error) in
                        if data == nil {
                            return
                        }
                        
                        do{
                            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                            guard let images = json["images"] as? [[String:Any]] else {return}
                            let actionId = json["actionId"] as? String
                            let imageData = Mapper<ImageData>().mapArray(JSONArray: images)
                            var imageNames = [String]()
                            for image in imageData {
                                if let imageName = image.imageName {
                                    imageNames.append(imageName)
                                }
                            }
                            sender.savingContentsImage = imageNames
                            sender.actionId = actionId
                            
                            DispatchQueue.main.async {
                                self.removeSpinner()
                                self.delegate?.saveIntoFolder(sender: sender)
                                self.dismiss(animated: true, completion: nil)
                                
                                
                            }
                            
                        }catch{
                            print(error)
                        }
                    }.resume()
                    
                    
                    
                }catch{
                    print(error)
                }
                
                
                
            }
        }
        
        
    }
    
    func deleteContents(data: HistoryDataModel){}
    
    func convertPHAssetArray(asset: [PhotoDataModel], completion: @escaping ([UIImage], Bool)->Void) {
        var array = [UIImage]()
        for i in asset {
            array.append(convertPHAssetToUIImage(asset: i.phImage!, quality: .high, imageSize: view.frame.width))
        }
        
        if array.count == asset.count {
            completion(array, true)
            
        } else {
            completion(array, false)
        }
        
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == folder?.tagField {
            if textField.text?.last == "#" {
                let text = textField.text
                let range = text!.index((text!.endIndex), offsetBy: -2)..<(text!.endIndex)
                textField.text?.removeSubrange(range)
            }
            endAddingTag()
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == folder?.tagField {
            if textField.text?.count == 0 {
                folder?.tagField?.text = "#"
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var count : Int = 0
        if textField == folder?.tagField {
            if textField.text!.count == 0 {
                textField.text = "#"
                count = 1
            }
            
            if string == " " {
                let lastCharacter = textField.text?.last
                if lastCharacter == "#" {
                    return false
                } else {
                    let text = "\((textField.text)!) #"
                    count = text.count
                    textField.text = text
                }
            }
        }
        return range.location >= count
    }
    
    func endAddingTag() {
        folderHeightConstraint?.constant = folderHeight
        view.endEditing(true)
        UIView.animate(withDuration: keyBoardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
   
}

class SelectedPhotoCell : UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    deinit {
        print("selected cell denit successful")
    }
    
    var buttonView : UIView?
    var imageView : UIImageView?
    var closeButton : CloseButton?
    let closeButtonHeight : CGFloat = 30
    var imageSet : UIImage? {
        didSet {
            let width = contentView.frame.width - (marginBase*3)
            imageView?.removeFromSuperview()
            imageView = UIImageView()
            imageView?.image = imageSet!
            imageView?.contentMode = .scaleAspectFill
            imageView?.clipsToBounds = true
            
            contentView.addSubview(imageView!)
            imageView?.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            imageView?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            imageView?.widthAnchor.constraint(equalToConstant: width).isActive = true
            imageView?.heightAnchor.constraint(equalToConstant: width).isActive = true
            imageView?.translatesAutoresizingMaskIntoConstraints = false
            
//            buttonView = UIView()
//            buttonView?.backgroundColor = Color.hexStringToUIColor(hex: "#3B3939")
//            buttonView?.layer.cornerRadius = closeButtonHeight/2
            
//            contentView.addSubview(buttonView!)
//            buttonView?.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
//            buttonView?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4).isActive = true
//            buttonView?.heightAnchor.constraint(equalToConstant: closeButtonHeight).isActive = true
//            buttonView?.widthAnchor.constraint(equalToConstant: closeButtonHeight).isActive = true
//            buttonView?.translatesAutoresizingMaskIntoConstraints = false
            
            closeButton?.removeFromSuperview()
            closeButton = CloseButton()
            closeButton?.setImage(UIImage(named: "closeXIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
            closeButton?.backgroundColor = Color.hexStringToUIColor(hex: "#3B3939")
            closeButton?.imageView?.contentMode = .scaleAspectFit
            closeButton?.imageView?.clipsToBounds = true
            closeButton?.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
            closeButton?.tintColor = .white
            closeButton?.layer.cornerRadius = closeButtonHeight/2

            
            contentView.addSubview(closeButton!)
            closeButton?.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
            closeButton?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4).isActive = true
            closeButton?.heightAnchor.constraint(equalToConstant: closeButtonHeight).isActive = true
            closeButton?.widthAnchor.constraint(equalToConstant: closeButtonHeight).isActive = true
            closeButton?.translatesAutoresizingMaskIntoConstraints = false
            
        }
    }
    
    
    
//    func setupCloseButton() {
//        closeButton?.removeFromSuperview()
//        closeButton = UIButton()
//        closeButton?.setImage(UIImage(named: "closeXIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
//        closeButton?.imageView?.contentMode = .scaleAspectFit
//        closeButton?.imageView?.clipsToBounds = true
//        closeButton?.backgroundColor = Color.hexStringToUIColor(hex: "#3B3939")
//        closeButton?.layer.cornerRadius = closeButtonHeight/2
//        closeButton?.tintColor = .white
//
//        contentView.addSubview(closeButton!)
//        closeButton?.topAnchor.constraint(equalTo: contentView.topAnchor, constant: marginBase/2).isActive = true
//        closeButton?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -(marginBase/2)).isActive = true
//        closeButton?.heightAnchor.constraint(equalToConstant: closeButtonHeight).isActive = true
//        closeButton?.widthAnchor.constraint(equalToConstant: closeButtonHeight).isActive = true
//        closeButton?.translatesAutoresizingMaskIntoConstraints = false
//    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ListCollectionViewCell : UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    var imageView : UIImageView?
    var imageSet : UIImage? {
        didSet {
            imageView?.removeFromSuperview()
            imageView = UIImageView()
            imageView?.image = imageSet!
            imageView?.contentMode = .scaleAspectFill
            imageView?.clipsToBounds = true
            
            contentView.addSubview(imageView!)
            imageView?.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            imageView?.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            imageView?.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            imageView?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            imageView?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    var backView : UIView?
    var number : UILabel?
    let viewHeight : CGFloat = 20
    var numberFont = UIFont(name: "HelveticaNeue", size: 12)
    var selectedNumberCountSet : Int? {
        didSet {
            backView?.removeFromSuperview()
            backView = UIView()
            backView?.backgroundColor = Color.hexStringToUIColor(hex: "#FFBC52")
            backView?.layer.cornerRadius = viewHeight / 2
            
            contentView.addSubview(backView!)
            backView?.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4).isActive = true
            backView?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4).isActive = true
            backView?.widthAnchor.constraint(equalToConstant: viewHeight).isActive = true
            backView?.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
            backView?.translatesAutoresizingMaskIntoConstraints = false
            
            number?.removeFromSuperview()
            number = UILabel()
            number?.text = "\(selectedNumberCountSet!)"
            number?.font = numberFont
            number?.textColor = .black
            
            backView?.addSubview(number!)
            number?.centerXAnchor.constraint(equalTo: (backView?.centerXAnchor)!).isActive = true
            number?.centerYAnchor.constraint(equalTo: (backView?.centerYAnchor)!).isActive = true
            number?.translatesAutoresizingMaskIntoConstraints = false
            
            if selectedNumberCountSet == 0 {
                backView?.isHidden = true
                number?.isHidden = true
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

class PhotoDataModel : NSObject {
    
    var phImage : PHAsset?
    var image : String?
    var id : String?
    var number : Int?
    var isSelected: Bool = false
    var indexValFromListCollectionView : Int?
    
//    init(image: String? = nil , id: String) {
//        self.image = image
//        self.id = id
//    }
    
}
