//
//  ImageDetailViewController.swift
//  BuxBox
//
//  Created by SongChiduk on 02/04/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class ImageDetailViewController : UIViewController, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITextFieldDelegate, UITextViewDelegate, FolderSelectDelegate {
    
    
  
    var actionId: String?
    var action = "NOTE_IMAGE"
    var folderId: String?
    var imageId: String?
    var memoId: String?
    var shouldDeleteAction = true
    var detail = [Detail]()
    weak var refreshDelegate : RefreshDelegate?
    var listIndex : Int?
    
    
    var tags = [[String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        setupView()
        setDetail(index: 0)
        setupKeyBoardNotification()
        setupMoreView()
        setupFolderSelectView()
        
        if action == "NOTE_IMAGE" {
            getImageDetail()
        }else{
            getNoteDetail()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if action == "NOTE_IMAGE" {
            saveImageDetail()
        }else {
            saveNoteDetail()
        }
        
        if let index = self.listIndex {
            self.refreshDelegate?.refresh(index: index)
        }
        
        
        endEditing()
    }
    
    weak var delegate : FolderSelectDelegate?
    
    func setupKeyBoardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func saveImageDetail() {
        var data = [[String:Any]]()

        for detail in detail{
            data.append(["imageId": detail.imageId,
                         "hashTags": detail.hashTags,
                         "labels": detail.labels,
                         //"texts": detail.texts,
                         "fullText": detail.fullText,
                         "memo": detail.memo,
                         "url": detail.url])
        }

        let params = [
            "uniqueId" : JoinUserInfo.getInstance.uniqueId,
            "data" : data
        ] as [String:Any]
        
        do{
            let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
            var request = URLRequest(url: URL(string: RestApi.saveImageDetail)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonParams
            
            URLSession(configuration: .default).dataTask(with: request){(data, response, error) in
                
            }.resume()
        }catch{
            print(error)
        }
    }
    
    func saveNoteDetail(){
        var data = [[String:Any]]()
        
        for detail in detail{
            data.append(["memoId": detail.memoId,
                         "hashTags": detail.hashTags,
                         "labels": detail.labels,
                         //"texts": detail.texts,
                         "fullText": detail.fullText,
                         "memo": detail.memo,
                         "url": detail.url])
        }
        
        let params = [
            "uniqueId" : JoinUserInfo.getInstance.uniqueId,
            "data" : data
        ] as [String:Any]
        
        do{
            let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
            var request = URLRequest(url: URL(string: RestApi.saveNoteDetail)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonParams
            
            URLSession(configuration: .default).dataTask(with: request){(data, response, error) in
                
            }.resume()
        }catch{
            print(error)
        }
    }
    
    var emptyViewHeight : CGFloat = 0
    var keyboardHeight : CGFloat = 0
    var keyBoardDuration : Double = 0
    var isKeyboardOn : Bool?
    @objc func keyboardShow(_ notification: Notification) {
        isKeyboardOn = true
        let keyBoardFrame = (notification.userInfo? [UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        keyboardHeight = (keyBoardFrame?.height)!
        keyBoardDuration = (notification.userInfo? [UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        if isFolderOn == true {
            folderHeight = tagViewHeight + keyboardHeight
            folderHeightConstraint?.constant = folderHeight
            UIView.animate(withDuration: keyBoardDuration) {
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    @objc func keyboardHide(_ notification: Notification) {
        isKeyboardOn = false
        keyBoardDuration = (notification.userInfo? [UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        if isFolderOn == true {
            folderHeight = tagViewHeight + folderSelectViewHeight
            folderHeightConstraint?.constant = folderHeight
            UIView.animate(withDuration: keyBoardDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    deinit {
        print("ImageDetailViewController denit successful")
    }
    
    func getNoteDetail() {
        let params = [
            "uniqueId": JoinUserInfo.getInstance.uniqueId,
            "actionId": (memoId == nil) ? actionId : "",
            "memoId" : memoId ?? ""
        ].stringFromHttpParameters()
        
        var request = URLRequest(url: URL(string: RestApi.getNoteDetail + "?" + params)!)
        request.httpMethod = "GET"
        
        URLSession(configuration: .default).dataTask(with: request){[weak self] (data, response ,error) in
            if data == nil {
                return
            }
            
            do{
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String:Any]] else{ return }
                
                let detail = Mapper<Detail>().mapArray(JSONArray: json)
                
                DispatchQueue.main.async {
                    self?.detail = detail
                    
                    guard let details = self?.detail else {return}
                    
                  
                    self?.tags = [[String]]()
                    for index in 0 ..< details.count{
                        
                        if let tags = detail[index].hashTags {
                            var tempArray = [String]()
                            for tagIndex in 0 ..< tags.count {
                                
                                tempArray.append(tags[tagIndex])
                                
                            }
                            
                            self?.tags.append(tempArray)
                        }
                        
                    }
 
                    self?.imageCollectionView.reloadData()
                    
                    
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withFullDate, .withFullDate, .withDashSeparatorInDate, .withColonSeparatorInTime]
                    
                    var dateString = "          "
                    
                    if let dstring = self?.detail.first?.date {
                        dateString = dstring
                    }
                    
                    
                    let date = dateFormatter.date(from: dateString)
                    
                    let locatDateFormatter = DateFormatter()
                    locatDateFormatter.timeZone = .current
                    locatDateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    if let date = date {
                        let localDate = locatDateFormatter.string(from: date)
                        self?.dateLabel.text = localDate
                    }
                    
                    self?.setDetail(index: 0)
                    self?.setupMoreView()
                }
            }catch{
                print(error)
            }
        }.resume()
    }
    
    func getImageDetail() {
        let params = [
            "uniqueId": JoinUserInfo.getInstance.uniqueId,
            "actionId": (imageId == nil) ? actionId : "",
            "imageId": imageId ?? ""
        ].stringFromHttpParameters()
        
        var request = URLRequest(url: URL(string: RestApi.getImageDetail + "?" + params)!)
        request.httpMethod = "GET"
        
        URLSession(configuration: .default).dataTask(with: request){[weak self] (data, response ,error) in
            if data == nil {
                return
            }
            
            do{
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String:Any]] else{ return }
                
                let detail = Mapper<Detail>().mapArray(JSONArray: json)
                
                DispatchQueue.main.async {
                    self?.detail = detail
                    
                    guard let details = self?.detail else {return}
                    
                    var imageNames = [String]()
                    
                    self?.tags = [[String]]()
                    for index in 0 ..< details.count{
                        if let imageName = detail[index].imageName{
                            imageNames.append(imageName)
                        }
                        
                        if let tags = detail[index].hashTags {
                            var tempArray = [String]()
                            for tagIndex in 0 ..< tags.count {
                                
                                tempArray.append(tags[tagIndex])
                                
                            }
                            
                            self?.tags.append(tempArray)
                        }

                    }
                    
                    if imageNames.count > 0 {
                        self?.addPhotobutton?.isHidden = true
                        self?.pager?.numberOfPages = imageNames.count
                        
                        if imageNames.count > 1{
                            self?.pager?.isHidden = false
                        }else{
                            self?.pager?.isHidden = true
                        }
                        
                    }
                    
                    self?.imageStrArray = imageNames
                    self?.imageCollectionView.reloadData()
                    
                    
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withFullDate, .withFullDate, .withDashSeparatorInDate, .withColonSeparatorInTime]
                    
                    var dateString = "          "
                    
                    if let dstring = self?.detail.first?.date {
                        dateString = dstring
                    }
                    
                    
                    let date = dateFormatter.date(from: dateString)
                    
                    let locatDateFormatter = DateFormatter()
                    locatDateFormatter.timeZone = .current
                    locatDateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    if let date = date {
                        let localDate = locatDateFormatter.string(from: date)
                        self?.dateLabel.text = localDate
                    }
                    
                    self?.setDetail(index: 0)
                    self?.setupMoreView()
                }
            }catch{
                print(error)
            }
            
        }.resume()
        
    }
    
    var verticalScrollView : UIScrollView?
    
    //var data = HistoryDataModel()
    var isUrlImages = false
    var createdDate : String = ""
    var imageArray = [UIImage]()
    var imageStrArray = [String]()
    var memoText : String = ""
    var hashTagArray = [String]()
    var extractedText : String = ""
    var url : String = ""
    var verticalScrollHeight : CGFloat = 0
    func setupView() {
        let verticalTapGesture = UITapGestureRecognizer(target: self, action: #selector(verticalTap))
        verticalScrollView = UIScrollView()
        verticalScrollView?.addGestureRecognizer(verticalTapGesture)
        verticalScrollView?.delegate = self
        view.addSubview(verticalScrollView!)
        verticalScrollView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        verticalScrollView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        verticalScrollView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        verticalScrollView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        verticalScrollView?.translatesAutoresizingMaskIntoConstraints = false
        
        setupImageScrollView()
        
    }
    
    @objc func verticalTap() {
        endEditing()
        closeMoreButton()
    }
    
    lazy var imageCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let c = UICollectionView(frame: .zero, collectionViewLayout: layout)
        c.dataSource = self
        c.delegate = self
        return c
    }()
    
    var pager : UIPageControl?
    var dateLabel = UILabel()
    var addPhotobutton : UIButton?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isUrlImages {
            return imageStrArray.count
        }else{
            return imageArray.count
        }
        
        
    }
    
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isUrlImages {
            let data = imageStrArray[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            cell.urlImage = data
            return cell
        }else{
            let data = imageArray[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            cell.imageSet = data
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.width)
    }
    
    var scrollHeight : CGFloat = 0
    var dateHeight : CGFloat = 0
    var moreButton : UIButton?
    var trashCanButton : UIButton?
    func setupImageScrollView() {
        let width = view.frame.width
        
        imageCollectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        imageCollectionView.backgroundColor = Color.hexStringToUIColor(hex: "#2E2E2E")
        imageCollectionView.isPagingEnabled = true
        
        verticalScrollView?.addSubview(imageCollectionView)
        imageCollectionView.topAnchor.constraint(equalTo: (verticalScrollView?.topAnchor)!).isActive = true
        imageCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageCollectionView.heightAnchor.constraint(equalToConstant: width).isActive = true
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        if isUrlImages {
            if imageStrArray.count == 0{
                setupAddImageButton()
            }
        }else{
            if imageArray.count == 0{
                setupAddImageButton()
            }
        }
        
        scrollHeight = width
        
        pager = UIPageControl()
        pager?.currentPage = 0
        
        if isUrlImages {
            pager?.numberOfPages = imageStrArray.count
        }else{
            pager?.numberOfPages = imageArray.count
        }
      
        pager?.currentPageIndicatorTintColor = Color.hexStringToUIColor(hex: "#FFBF2E")
        
        verticalScrollView?.addSubview(pager!)
        pager?.topAnchor.constraint(equalTo: imageCollectionView.bottomAnchor, constant: marginBase).isActive = true
        pager?.centerXAnchor.constraint(equalTo: imageCollectionView.centerXAnchor).isActive = true
        pager?.heightAnchor.constraint(equalToConstant: 16).isActive = true
        pager?.translatesAutoresizingMaskIntoConstraints = false
        
        if isUrlImages {
            if imageStrArray.count < 2 {
                pager?.isHidden = true
            }
        }else{
            if imageArray.count < 2 {
                pager?.isHidden = true
            }
        }
 
        dateLabel.text = "2019-01-01"
        dateLabel.font = UIFont(name: "HelveticaNeue", size: 16)
        dateLabel.textColor = .lightGray
        
        verticalScrollView?.addSubview(dateLabel)
        dateLabel.topAnchor.constraint(equalTo: imageCollectionView.bottomAnchor, constant: marginBase).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: (pager?.leftAnchor)!, constant: -marginBase*2).isActive = true
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateHeight = dateLabel.intrinsicContentSize.height + marginBase
        
        moreButton = UIButton()
        moreButton?.setImage(UIImage(named: "threeDots")?.withRenderingMode(.alwaysTemplate), for: .normal)
        moreButton?.addTarget(self, action: #selector(morePressed), for: .touchUpInside)
        moreButton?.tintColor = .lightGray
        
        verticalScrollView?.addSubview(moreButton!)
        moreButton?.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor).isActive = true
        moreButton?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        moreButton?.widthAnchor.constraint(equalToConstant: CGFloat(44)).isActive = true
        moreButton?.heightAnchor.constraint(equalToConstant: dateLabel.intrinsicContentSize.height).isActive = true
        moreButton?.translatesAutoresizingMaskIntoConstraints = false
        
        
        trashCanButton = UIButton()
        trashCanButton?.setImage(UIImage(named: "trashCan")?.withRenderingMode(.alwaysTemplate), for: .normal)
        trashCanButton?.addTarget(self, action: #selector(trashCanPressed), for: .touchUpInside)
        trashCanButton?.tintColor = Color.hexStringToUIColor(hex: "#FFBF2E")
        trashCanButton?.imageView?.contentMode = .scaleAspectFit
        trashCanButton?.imageView?.clipsToBounds = true
        trashCanButton?.isHidden = true
        
        verticalScrollView?.addSubview(trashCanButton!)
        trashCanButton?.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor).isActive = true
        trashCanButton?.rightAnchor.constraint(equalTo: (moreButton?.rightAnchor)!, constant: -marginBase*5).isActive = true
        trashCanButton?.widthAnchor.constraint(equalToConstant: CGFloat(44)).isActive = true
        trashCanButton?.heightAnchor.constraint(equalToConstant: dateLabel.intrinsicContentSize.height).isActive = true
        trashCanButton?.translatesAutoresizingMaskIntoConstraints = false
        
        
    }
    
    func setupAddImageButton() {
        addPhotobutton = UIButton()
        addPhotobutton?.setImage(UIImage(named: "addIconCircle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        addPhotobutton?.setTitle("이미지 ", for: .normal)
        addPhotobutton?.titleLabel?.font = labelFont
        addPhotobutton?.imageView?.contentMode = .scaleAspectFit
        addPhotobutton?.imageView?.clipsToBounds = true
        
        addPhotobutton?.tintColor = .white
        addPhotobutton?.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        
        addPhotobutton?.addTarget(self, action: #selector(addImagePressed), for: .touchUpInside)
        
        verticalScrollView?.addSubview(addPhotobutton!)
        addPhotobutton?.centerXAnchor.constraint(equalTo: imageCollectionView.centerXAnchor).isActive = true
        addPhotobutton?.centerYAnchor.constraint(equalTo: imageCollectionView.centerYAnchor).isActive = true
        addPhotobutton?.widthAnchor.constraint(equalToConstant: 100 + 40).isActive = true
        addPhotobutton?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addPhotobutton?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func deleteImage(index: Int){
        guard let imageId = detail[index].imageId else {
            return
        }
        
        let params = [
            "uniqueId" : JoinUserInfo.getInstance.uniqueId,
            "imageId": imageId
        ] as [String:Any]
        
        do{
            let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
            var request = URLRequest(url: URL(string: RestApi.deleteImage)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonParams
            
            URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error ) in
                guard let data = data else {return}
                
                do{
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return }
                    let actionId = json["modifiedActionId"] as? String
                    let deleteAction = json["deleteAction"] as? Bool
                    
                    
                    DispatchQueue.main.async {
                        if let actionId = actionId, let deleteAction = deleteAction {
                            self?.refreshDelegate?.refresh(actions: [RefreshAction(actionId: actionId, deleteAction: deleteAction, imageIds: [imageId])])
                        }
                    }
                }catch{
                    print(error)
                }
                
            }.resume()
        }catch{
            print(error)
        }
    }
    
    @objc func trashCanPressed() {
        let visibleRect = CGRect(origin: imageCollectionView.contentOffset, size: imageCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = imageCollectionView.indexPathForItem(at: visiblePoint)
        
        if isUrlImages{
            if let row = visibleIndexPath?.item{
                deleteImage(index: row)

                imageStrArray.remove(at: row)
                detail.remove(at: row)
                imageCollectionView.performBatchUpdates({
                    if let indexPath = visibleIndexPath{
                        imageCollectionView.deleteItems(at: [indexPath])
                    }
                }, completion: {[weak self](finsished) in
                    if finsished {
                        
                        if let contentOffset = self?.imageCollectionView.contentOffset, let size = self?.imageCollectionView.bounds.size {
                            let vRect = CGRect(origin: contentOffset, size: size)
                            let vPoint = CGPoint(x: vRect.midX, y: vRect.midY)
                            let vIndexPath = self?.imageCollectionView.indexPathForItem(at: vPoint)
                            
                            if let row = vIndexPath?.row{
                                
                                if let imageCount = self?.imageStrArray.count {
                                    self?.pager?.numberOfPages = imageCount
                                    self?.pager?.currentPage = row
                                    if imageCount > 1 {
                                        self?.pager?.isHidden = false
                                    }else{
                                        self?.pager?.isHidden = true
                                    }
                                }
                                
                                self?.setDetail(index: row)
                                self?.setupMoreView()
                            }
                            
                        }
                        
                       
                        
                        if self?.imageStrArray.count == 0 {
                            self?.setupAddImageButton()
                            self?.trashCanButton?.isHidden = true
                            self?.setDetail(index: 0)
                            self?.setupMoreView()
                            
                            if let shouldDelete = self?.shouldDeleteAction{
                                if shouldDelete{
                                    self?.deleteAction()
                                }else{
                                    
                                    self?.navigationController?.popViewController(animated: true)
                                }
                            }
                            
                            
                            
                        }
                    }
                })
            }
        }else{
            if let row = visibleIndexPath?.item{
                imageArray.remove(at: row)
                imageCollectionView.performBatchUpdates({
                    
                    if let indexPath = visibleIndexPath{
                        imageCollectionView.deleteItems(at: [indexPath])
                    }
                    
                }) { (bool) in
                    if bool == true {
                        if self.imageArray.count == 0 {
                            self.setupAddImageButton()
                            self.trashCanButton?.isHidden = true
                        }
                    }
                }
            }
    
        }
   
    }
    
    func deleteAction(){
        let params = [
            "uniqueId" : JoinUserInfo.getInstance.uniqueId,
            "actionId" : actionId ?? ""
        ] as [String:Any]
        
        do{
            let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
            
            var request = URLRequest(url: URL(string: RestApi.deleteAction)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonParams
            
            URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse else {return}
                
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
    
                        if let actionId = self?.actionId {
                             let refreshAction = RefreshAction(actionId: actionId, deleteAction: true)
                            self?.refreshDelegate?.refresh(actions: [refreshAction])
                        }
                       
                        
                        self?.navigationController?.popViewController(animated: true)
                    }
                    
                }
                }.resume()
        }catch{
            print(error)
        }
    }
    
    var moreViewMaxWidth : CGFloat?
    var moreViewMaxHeight : CGFloat?
    var moreViewWidthConstraint : NSLayoutConstraint?
    var moreViewHeightConstraint : NSLayoutConstraint?
    var moreView : UIView?
    var moreButtonArray = ["다른 폴더로 보내기", "이미지 선택 삭제", "전체 삭제"]
    var moreButtonHeight : CGFloat = 50
    let moreButtonFont = UIFont(name: "HelveticaNeue", size: 18)
    func setupMoreView() {
        moreView?.removeFromSuperview()
        moreView = UIView()
        moreView?.backgroundColor = .white
        moreView?.layer.cornerRadius = 20
        verticalScrollView?.addSubview(moreView!)
        moreView?.centerYAnchor.constraint(equalTo: (moreButton?.centerYAnchor)!).isActive = true
        moreView?.rightAnchor.constraint(equalTo: (moreButton?.leftAnchor)!).isActive = true
        moreView?.translatesAutoresizingMaskIntoConstraints = false
        moreViewWidthConstraint = NSLayoutConstraint(item: moreView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        moreViewHeightConstraint = NSLayoutConstraint(item: moreView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        verticalScrollView?.addConstraints([moreViewWidthConstraint!, moreViewHeightConstraint!])
        
        var widthArray : [Int] = []
        for i in moreButtonArray {
            let label = UILabel()
            label.font = moreButtonFont
            label.text = i
            let widthVal = label.intrinsicContentSize.width
            widthArray.append(Int(widthVal))
        }
        
        moreViewMaxWidth = CGFloat(widthArray.max()!)
        
        for (index, element) in moreButtonArray.enumerated() {
            let button = UIButton()
            button.setTitle(element, for: .normal)
            button.addTarget(self, action: #selector(buttosInMorePressed), for: .touchUpInside)
            button.tag = index
            button.setTitleColor(.black, for: .normal)
            button.contentHorizontalAlignment = .left
            
            moreView?.addSubview(button)
            button.topAnchor.constraint(equalTo: (moreView?.topAnchor)!, constant: moreButtonHeight*CGFloat(index)).isActive = true
            button.leftAnchor.constraint(equalTo: (moreView?.leftAnchor)!, constant:(marginBase*2)).isActive = true
            button.widthAnchor.constraint(equalToConstant: moreViewMaxWidth!).isActive = true
            button.heightAnchor.constraint(equalToConstant: moreButtonHeight).isActive = true
            button.translatesAutoresizingMaskIntoConstraints = false
        }
        
        moreViewMaxHeight = moreButtonHeight * CGFloat(moreButtonArray.count)
        
        moreView?.subviews.forEach({ (element) in
            element.alpha = 0
        })
    }
    
    var isMoreOpen : Bool = false
    @objc func morePressed() {
        if isMoreOpen == false {
            openMoreView()
        } else {
            closeMoreButton()
        }
        isMoreOpen = !isMoreOpen
    }
    
    @objc func openMoreView() {
        
        moreViewWidthConstraint?.constant = moreViewMaxWidth! + (marginBase*4)
        moreViewHeightConstraint?.constant = moreViewMaxHeight!
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 3, initialSpringVelocity: 3, options: .curveEaseInOut, animations: {
            self.moreView?.subviews.forEach({ (element) in
                element.alpha = 1
            })
            self.view.layoutIfNeeded()
        }) { (bool) in
            if bool == true {
                
            }
        }
        
    }
    
    @objc func closeMoreButton() {
        
        moreViewWidthConstraint?.constant = 0
        moreViewHeightConstraint?.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 3, initialSpringVelocity: 3, options: .curveEaseInOut, animations: {
            self.moreView?.subviews.forEach({ (element) in
                element.alpha = 0
            })
            self.view.layoutIfNeeded()
        }) { (bool) in
            if bool == true {
                
            }
        }
    }
    
    @objc func buttosInMorePressed(sender: UIButton) {
        if sender.tag == 0 {
            sendToOtherFolder()
        } else if  sender.tag == 1 {
            if sender.titleLabel?.text == "이미지 선택 삭제" {
                deleteImageStart()
                sender.setTitle("이미지 삭제 취소", for: .normal)
                trashCanButton?.isHidden = false
            } else {
                sender.setTitle("이미지 선택 삭제", for: .normal)
                trashCanButton?.isHidden = true
                morePressed()
            }
        } else {
            deleteAll()
        }
    }
    
    func sendToOtherFolder() {
        view.endEditing(true)
        closeMoreButton()
        presentFolderSaveTools()
    }
    
    func deleteAll() {
        closeMoreButton()
        
        let alert = UIAlertController(title:"삭제 하시겠습니까?", message: "삭제된 파일은 복원되지 않습니다.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "네", style: .destructive, handler:{[weak self](action: UIAlertAction!) in
            if self?.action == "NOTE_IMAGE"{
                self?.deleteAllImages()
            }else if self?.action == "NOTE"{
                self?.deleteAllNote()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "아니오", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func deleteAllImages(){
        var imageIds = [String]()
        
        for detail in detail{
            if let imageId = detail.imageId{
                imageIds.append(imageId)
            }
        }
        
        let params = [
            "uniqueId" : JoinUserInfo.getInstance.uniqueId,
            "actionId" : actionId ?? "",
            "imageIds" : imageIds
        ] as [String : Any]
        
        do{
            let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
            var request = URLRequest(url: URL(string: RestApi.deleteAllImages)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonParams
            
            URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error ) in
                
                guard let data = data else { return }
                
                do{
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return }
                    let actionId = json["modifiedActionId"] as? String
                    let deleteAction = json["deleteAction"] as? Bool
                    
                    DispatchQueue.main.async {
                        if let actionId = actionId, let deleteAction = deleteAction {
                            self?.refreshDelegate?.refresh(actions: [RefreshAction(actionId: actionId, deleteAction: deleteAction, imageIds: imageIds)])
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                }catch{
                    print(error)
                }
                

            }.resume()
        }catch{
            print(error)
        }
    }
    
    func deleteAllNote(){
        var memoId = ""
        if self.detail.count > 0 {
            
            if let mId = detail[0].memoId{
                memoId = mId
            }
            
            
        }
        
        
        
        let params = [
            "uniqueId" : JoinUserInfo.getInstance.uniqueId,
            "actionId" : actionId ?? "",
            "memoId" : memoId
        ] as [String : Any]
        
        do{
            let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
            var request = URLRequest(url: URL(string: RestApi.deleteAllNotes)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonParams
            
            URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse else {return}
                if httpResponse.statusCode == 200 {
                    
                    DispatchQueue.main.async {
                        
                        
                        if let actionId = self?.actionId{
                            let refreshAction = RefreshAction(actionId: actionId, deleteAction: true, memoId: memoId)
                            
                            self?.refreshDelegate?.refresh(actions: [refreshAction])
                            
                            self?.navigationController?.popViewController(animated: true)
                        }
                        
                        
                        
                    }
                    
                    
                    
                    
                }
            }.resume()
        }catch{
            print(error)
        }
    }
    
    func deleteImageStart() {
        if isUrlImages{
            if imageStrArray.count == 0 {
                trashCanButton?.isHidden = true
            } else {
                trashCanButton?.isHidden = false
            }
        }else{
            if imageArray.count == 0 {
                trashCanButton?.isHidden = true
            } else {
                trashCanButton?.isHidden = false
            }
        }
        
        
        closeMoreButton()
    }
    
    func presentFolderSaveTools() {
        isFolderOn = true
        folder?.tagField?.text = self.hashTagField.text
        folderHeightConstraint?.constant = folderHeight
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    var folder : FolderSelectionViewController?
    var folderBottomConstraint : NSLayoutConstraint?
    var folderHeightConstraint : NSLayoutConstraint?
    var folderHeight : CGFloat = 0
    var tagViewHeight : CGFloat = 0
    var folderSelectViewHeight : CGFloat = 0
    var isFolderOn : Bool = false
    func setupFolderSelectView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        folder = FolderSelectionViewController(collectionViewLayout: layout)
        folder?.delegate = self
        if let folderId = folderId {
            folder?.skipFolderId = folderId
        }
        
        
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
        folderBottomConstraint = NSLayoutConstraint(item: folderView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraints([folderHeightConstraint!, folderBottomConstraint!])
        folder?.cancelbutton?.addTarget(self, action: #selector(endEditing), for: .touchUpInside)
        folder?.tagField?.delegate = self
        
    }
    
    func folderSelected(sender: HistoryDataModel) {
        
        
//        data.imageArrayForTesting = imageArray
//        data.hashTagArray = folder?.tagField?.text?.components(separatedBy: " ")
//        delegate?.folderSelected(sender: data)
        
        if action == "NOTE_IMAGE" {
            moveImage(sender: sender)
        }else {
            moveNote(sender: sender)
        }
        
        endEditing()
    }
    
    func moveNote(sender: HistoryDataModel){
        let newFolderId = sender.folderID
        let newFolderName = sender.folderName
        
        
        if self.detail.count <= 0 { return }
        let memoId = self.detail[0].memoId
        var hts = [String]()
        if let hashTags = folder?.tagField?.text?.components(separatedBy: [" ", "#"]){
            let filteredTags = hashTags.filter{$0 != ""}
            hts = filteredTags
        }
        
        let params = [
            "uniqueId" : JoinUserInfo.getInstance.uniqueId,
            "memoId" : memoId ?? "",
            "newFolderId" : newFolderId ?? "",
            "newFolderName" : newFolderName ?? "",
            "actionId" : actionId ?? "",
            "hashTags" : hts
            ] as [String:Any]
            
        do{
            let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
            var request = URLRequest(url: URL(string: RestApi.moveNote)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonParams
            
            URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
                if data == nil {
                    return
                }
                
                do{
                    guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] else { return }
                    let newActionId = json["actionId"] as? String
                    let folderId = json["folderId"] as? String
                    
                    guard let index = self?.scrollIndex else { return }
                    
                    DispatchQueue.main.async {
                      
                        sender.actionId = self?.actionId
                        sender.deleteData = true
                        sender.memoIdToEdit = self?.memoId
                        
                        self?.delegate?.folderSelected(sender: sender)
                        
                        sender.actionId = newActionId
                        sender.deleteData = false
                        sender.folderID = folderId
                        
                        self?.delegate?.folderSelected(sender: sender)
                        self?.navigationController?.popViewController(animated: true)
                        
                        
                    }
                    
                }catch{
                    print(error)
                }
                
                }.resume()
        }catch{
            print(error)
        }
    }
    
    func moveImage(sender: HistoryDataModel){
        
        let newFolderId = sender.folderID
        let imageId = detail[scrollIndex].imageId
        let newFolderName = sender.folderName
     
        var hts = [String]()
        if let hashTags = folder?.tagField?.text?.components(separatedBy: [" ", "#"]){
            let filteredTags = hashTags.filter{$0 != ""}
            hts = filteredTags
        }
        
        let params = [
            "uniqueId" : JoinUserInfo.getInstance.uniqueId,
            "imageId" : imageId ?? "",
            "newFolderId" : newFolderId ?? "",
            "newFolderName" : newFolderName ?? "",
            "actionId" : actionId ?? "",
            "hashTags" : hts
        ] as [String:Any]
        
        do{
            let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
            var request = URLRequest(url: URL(string: RestApi.moveImage)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonParams
            
            URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
                if data == nil {
                    return
                }
                
                do{
                    guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] else { return }
                    let newActionId = json["actionId"] as? String
                    let folderId = json["folderId"] as? String
                    
                    guard let index = self?.scrollIndex else { return }
                    
                    DispatchQueue.main.async {
                        self?.imageStrArray.remove(at: index)
                        self?.detail.remove(at: index)
                        self?.imageCollectionView.performBatchUpdates({
                            self?.imageCollectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                        }, completion: {[weak self](finsished) in
                            if finsished {
                                
                                if let contentOffset = self?.imageCollectionView.contentOffset, let size = self?.imageCollectionView.bounds.size {
                                    let vRect = CGRect(origin: contentOffset, size: size)
                                    let vPoint = CGPoint(x: vRect.midX, y: vRect.midY)
                                    let vIndexPath = self?.imageCollectionView.indexPathForItem(at: vPoint)
                                    
                                    
                                    
                                    
                                    if let row = vIndexPath?.row{
                                        
                                        if let imageCount = self?.imageStrArray.count {
                                            self?.pager?.numberOfPages = imageCount
                                            self?.pager?.currentPage = row
                                            if imageCount > 1 {
                                                self?.pager?.isHidden = false
                                            }else{
                                                self?.pager?.isHidden = true
                                            }
                                        }
                                        
                                        self?.setDetail(index: row)
                                        self?.setupMoreView()
                                    }
                                    
                                }
                                
                              
                                if self?.imageStrArray.count == 0 {
                                    self?.setupAddImageButton()
                                    self?.trashCanButton?.isHidden = true

                                    sender.actionId = self?.actionId
                                    sender.deleteData = true
                                    sender.imageIdToEdit = self?.imageId
                                    
                                    
                                    self?.delegate?.folderSelected(sender: sender)
                                    
                                    sender.actionId = newActionId
                                    sender.deleteData = false
                                    sender.folderID = folderId
                                    
                                    self?.delegate?.folderSelected(sender: sender)
                                    self?.navigationController?.popViewController(animated: true)
                                }else{
                                    sender.actionId = newActionId
                                    sender.deleteData = false
                                    
                                    self?.delegate?.folderSelected(sender: sender)
                                }
                                
                                
                            }
                        })
                    }
                    
                }catch{
                    print(error)
                }
                
            }.resume()
        }catch{
            print(error)
        }
        
        
    }
    
    @objc func endEditing() {
        
        folderHeightConstraint?.constant = 0
        isFolderOn = false
        view.endEditing(true)
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func addImagePressed() {
        let vw = GalleryViewController()
        vw.modalPresentationStyle = .overFullScreen
        vw.delegate = self
        vw.isForFolder = false
        if self.action == "NOTE" {
            vw.limit = 1
        }
        present(vw, animated: true, completion: nil)
    }
    

    var scrollIndex : Int = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        closeMoreButton()
        if scrollView == imageCollectionView {
            let index = round(scrollView.contentOffset.x / scrollView.frame.size.width)
            scrollIndex = Int(index)
            pager?.currentPage = Int(index)
            
        }
        if dontEndEditing == false {
            endEditing()
            view.endEditing(true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == imageCollectionView{
            let index = round(scrollView.contentOffset.x / scrollView.frame.size.width)
            
            setDetail(index: Int(index))
            setupMoreView()
        }
    }
    
    func setDetail(index: Int){
        
        if detail.count > 0{
            if let hashTags = detail[index].hashTags {
                setupTagView(tags: hashTags)
            }else {
                setupTagView(tags: [""])
                
            }
            
            
            
            if let memos = detail[index].memo {
                if memos.count > 0 {
                    setupMemoView(text: memos[0])
                }else{
                    setupMemoView(text: "")
                }
            } else {
                setupMemoView(text: "")
                
            }
            
            
            
            if let labels = detail[index].labels {
                setupExtractedTextView(text: labels)
            } else {
                
                setupExtractedTextView(text: [""])
            }
            
            
            
            if let fullText = detail[index].fullText {
                setupImageTagTextView(text: [fullText])
            } else {
                setupImageTagTextView(text: [""])
                
            }
            
            
           
            
            
            if let url = detail[index].url {
                if url.count > 0 {
                    setupURL(url: url[0])
                }else{
                    setupURL(url: "")
                }
            } else {
                setupURL(url: "")
                
            }
            
           
            
        }else{
            setupTagView(tags: [""])
            setupMemoView(text: "")
            setupExtractedTextView(text: [""])
            setupImageTagTextView(text: [""])
            setupURL(url: "")
        }
        
        
    }
    
    let labelFont = UIFont(name: "HelveticaNeue-Bold", size: 18)
    let tagLabel = UILabel()
    let hashTagView = UIView()
    let hashTagField = UITextField()
    var hashHeight : CGFloat = 0
    var hashLabelHeight : CGFloat = 0
    func setupTagView(tags: [String]) {
        tagLabel.text = "태그"
        tagLabel.font = labelFont
        tagLabel.textColor = .white
        verticalScrollView?.addSubview(tagLabel)
        tagLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: marginBase*2).isActive = true
        tagLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        
        hashLabelHeight = tagLabel.intrinsicContentSize.height + (marginBase*2)
        
        hashTagView.backgroundColor = Color.hexStringToUIColor(hex: "#2E2E2E")
        verticalScrollView?.addSubview(hashTagView)
        hashTagView.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: marginBase).isActive = true
        hashTagView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        hashTagView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        hashTagView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        hashTagView.translatesAutoresizingMaskIntoConstraints = false
        
        hashHeight = 50 + marginBase
        
        
        var hashString = ""
        for tag in tags {
            let tagged = "#" + tag + " "
            hashString += tagged
        }
        
        //let hashString = tags.joined(separator:["#", " "])
        hashTagField.placeholder = "#"
        hashTagField.text = hashString.trimmingCharacters(in: .whitespaces)
        hashTagField.textColor = .white
        hashTagField.font = fieldFont
        hashTagField.isEnabled = true
        hashTagField.delegate = self
        
        hashTagView.addSubview(hashTagField)
        hashTagField.centerYAnchor.constraint(equalTo: hashTagView.centerYAnchor).isActive = true
        hashTagField.leftAnchor.constraint(equalTo: hashTagView.leftAnchor, constant: marginBase*2).isActive = true
        hashTagField.rightAnchor.constraint(equalTo: hashTagView.rightAnchor, constant: -marginBase*2).isActive = true
        hashTagField.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    let fieldFont = UIFont(name: "HelveticaNeue", size: 18)
    var memoLabel : UILabel?
    var memoView : UIView?
    var memoField : UITextView?
    var memoViewHeight : NSLayoutConstraint?
    var memoHeight : CGFloat = 0
    var memoLabelHeight : CGFloat = 0
    func setupMemoView(text: String) {
        memoLabel = UILabel()
        memoLabel?.text = "메모"
        memoLabel?.font = labelFont
        memoLabel?.textColor = .white
        verticalScrollView?.addSubview(memoLabel!)
        memoLabel?.topAnchor.constraint(equalTo: hashTagView.bottomAnchor, constant: marginBase*2).isActive = true
        memoLabel?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
        memoLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        memoLabelHeight = (memoLabel?.intrinsicContentSize.height)! + (marginBase*2)
        
        var textViewHeight : CGFloat = 0
        if text == "" {
            textViewHeight = 50
        } else {
            textViewHeight = Text.textHeightForView(text: text, font: fieldFont!, width: view.frame.width - (marginBase*4)) + (marginBase*2)
        }
        memoView?.removeFromSuperview()
        memoView = UIView()
        memoView?.backgroundColor = Color.hexStringToUIColor(hex: "#2E2E2E")
        
        verticalScrollView?.addSubview(memoView!)
        memoView?.topAnchor.constraint(equalTo: (memoLabel?.bottomAnchor)!, constant: marginBase).isActive = true
        memoView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        memoView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        memoViewHeight = NSLayoutConstraint(item: memoView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: textViewHeight)
        memoView?.translatesAutoresizingMaskIntoConstraints = false
        verticalScrollView?.addConstraint(memoViewHeight!)
        
        view.layoutIfNeeded()
        
        memoHeight = (memoViewHeight?.constant)! + marginBase
        
        memoField?.removeFromSuperview()
        memoField = UITextView()
        let width = view.frame.width - (marginBase*4)
        memoField?.text = text
        memoField?.font = fieldFont
        memoField?.textColor = .white
        memoField?.backgroundColor = .clear
        memoField?.scrollRangeToVisible(NSRangeFromString(text))
        memoField?.isEditable = true
        memoField?.delegate = self
        memoField?.isScrollEnabled = false
        
        memoView?.addSubview(memoField!)
        memoField?.centerYAnchor.constraint(equalTo: (memoView?.centerYAnchor)!).isActive = true
        memoField?.leftAnchor.constraint(equalTo: (memoView?.leftAnchor)!, constant: marginBase*2).isActive = true
        memoField?.widthAnchor.constraint(equalToConstant: width).isActive = true
        memoField?.sizeToFit()
        memoField?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var extractLabel = UILabel()
    var extractView : UIView?
    var extractField : UITextView?
    var extractHeight : NSLayoutConstraint?
    var extractViewHeight : CGFloat = 0
    var extractLabelHeight : CGFloat = 0
    func setupExtractedTextView(text: [String]) {
        extractLabel.text = "이미지 인식"
        extractLabel.font = labelFont
        extractLabel.textColor = .white
        verticalScrollView?.addSubview(extractLabel)
        extractLabel.topAnchor.constraint(equalTo: (memoView?.bottomAnchor)!, constant: marginBase*2).isActive = true
        extractLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
        extractLabel.translatesAutoresizingMaskIntoConstraints = false
        
        extractLabelHeight = extractLabel.intrinsicContentSize.height + marginBase*2
        
        let labels = text.joined(separator: ", ")
        var textViewHeight : CGFloat = 0
        if labels == "" {
            textViewHeight = 50
        } else {
            let calHeight = Text.textHeightForView(text: labels, font: fieldFont!, width: view.frame.width - (marginBase*5)) + (marginBase*2)
            if calHeight > 50 {
                textViewHeight = calHeight
            } else {
                textViewHeight = 50
            }
        }
        
         print("extractView \(textViewHeight)")
        
        extractView?.removeFromSuperview()
        extractView = UIView()
        extractView?.backgroundColor = Color.hexStringToUIColor(hex: "#2E2E2E")
        
        verticalScrollView?.addSubview(extractView!)
        extractView?.topAnchor.constraint(equalTo: extractLabel.bottomAnchor, constant: marginBase).isActive = true
        extractView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        extractView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        extractView?.translatesAutoresizingMaskIntoConstraints = false
        
        let width = view.frame.width - (marginBase*4)
        extractField?.removeFromSuperview()
        extractField = UITextView()
        extractField?.text = labels
        extractField?.font = fieldFont
        extractField?.textColor = .white
        extractField?.backgroundColor = .clear
        extractField?.scrollRangeToVisible(NSRangeFromString(labels))
        extractField?.isEditable = true
        extractField?.isScrollEnabled = false
        extractField?.delegate = self
        
        extractView?.addSubview(extractField!)
        extractField?.centerYAnchor.constraint(equalTo: (extractView?.centerYAnchor)!).isActive = true
        extractField?.leftAnchor.constraint(equalTo: (extractView?.leftAnchor)!, constant: marginBase*2).isActive = true
        extractField?.widthAnchor.constraint(equalToConstant: width).isActive = true
        extractField?.sizeToFit()
        extractField?.translatesAutoresizingMaskIntoConstraints = false
        
        let size = CGSize(width: width, height: .infinity)
        let estimatedSize = extractField?.sizeThatFits(size)
        
        extractHeight = NSLayoutConstraint(item: extractView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: (estimatedSize?.height)!+(marginBase*2))
        verticalScrollView?.addConstraint(extractHeight!)
        
        extractViewHeight = (extractHeight?.constant)! + marginBase
    }
    
    var imageTagLabel : UILabel?
    var imageTagView : UIView?
    var imageTagField : UITextView?
    var imageTagHeight : NSLayoutConstraint?
    var imageTagViewHeight : CGFloat = 0
    var imageTagLabelHeight : CGFloat = 0
    func setupImageTagTextView(text: [String]) {
        imageTagLabel?.removeFromSuperview()
        imageTagLabel = UILabel()
        imageTagLabel?.text = "이미지 문자 추출"
        imageTagLabel?.font = labelFont
        imageTagLabel?.textColor = .white
        verticalScrollView?.addSubview(imageTagLabel!)
        imageTagLabel?.topAnchor.constraint(equalTo: (extractView?.bottomAnchor)!, constant: marginBase*2).isActive = true
        imageTagLabel?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
        imageTagLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        imageTagLabelHeight = (imageTagLabel?.intrinsicContentSize.height)! + marginBase*2
        
        var labels : String = text.joined(separator: ", ")
        let lastTwo = String(labels.suffix(1))
        if lastTwo == "\n" {
            labels.removeLast(1)
        }
        print("labels \(labels)")
        var textViewHeight : CGFloat = 0
        if labels == "" {
            textViewHeight = 50
        } else {
            let calHeight = Text.textHeightForView(text: labels, font: fieldFont!, width: view.frame.width - (marginBase*6)) + (marginBase*2)
            if calHeight > 50 {
                textViewHeight = calHeight
            } else {
                textViewHeight = 50
            }
        }
        
        print("imageTagView \(textViewHeight)")
        
        imageTagView?.removeFromSuperview()
        imageTagView = UIView()
        imageTagView?.backgroundColor = Color.hexStringToUIColor(hex: "#2E2E2E")
        
        verticalScrollView?.addSubview(imageTagView!)
        imageTagView?.topAnchor.constraint(equalTo: (imageTagLabel?.bottomAnchor)!, constant: marginBase).isActive = true
        imageTagView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageTagView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageTagView?.translatesAutoresizingMaskIntoConstraints = false
        
        
        let width = view.frame.width - (marginBase*4)
        imageTagField?.removeFromSuperview()
        imageTagField = UITextView()
        imageTagField?.text = labels
        imageTagField?.font = fieldFont
        imageTagField?.textColor = .white
        imageTagField?.backgroundColor = .clear
        imageTagField?.scrollRangeToVisible(NSRangeFromString(labels))
        imageTagField?.isEditable = true
        imageTagField?.isScrollEnabled = false
        imageTagField?.delegate = self
        
        imageTagView?.addSubview(imageTagField!)
        imageTagField?.centerYAnchor.constraint(equalTo: (imageTagView?.centerYAnchor)!).isActive = true
        imageTagField?.leftAnchor.constraint(equalTo: (imageTagView?.leftAnchor)!, constant: marginBase*2).isActive = true
        imageTagField?.widthAnchor.constraint(equalToConstant: width).isActive = true
        imageTagField?.sizeToFit()
        imageTagField?.translatesAutoresizingMaskIntoConstraints = false
        
        let size = CGSize(width: width, height: .infinity)
        let estimatedSize = imageTagField?.sizeThatFits(size)
        
        imageTagHeight = NSLayoutConstraint(item: imageTagView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: (estimatedSize?.height)!+(marginBase*2))
        verticalScrollView?.addConstraint(imageTagHeight!)
        
        imageTagViewHeight = (imageTagHeight?.constant)! + marginBase
    }
    
    let urlLabel = UILabel()
    let urlView = UIView()
    let urlField = UITextField()
    var urlHeight : CGFloat = 0
    func setupURL(url: String)  {
        urlLabel.text = "URL"
        urlLabel.font = labelFont
        urlLabel.textColor = .white
        verticalScrollView?.addSubview(urlLabel)
        urlLabel.topAnchor.constraint(equalTo: (imageTagView?.bottomAnchor)!, constant: marginBase*2).isActive = true
        urlLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
        urlLabel.translatesAutoresizingMaskIntoConstraints = false
        
        verticalScrollHeight += urlLabel.intrinsicContentSize.height + marginBase*2
        
        urlView.backgroundColor = Color.hexStringToUIColor(hex: "#2E2E2E")
        verticalScrollView?.addSubview(urlView)
        urlView.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: marginBase).isActive = true
        urlView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        urlView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        urlView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        urlView.translatesAutoresizingMaskIntoConstraints = false
        
        urlHeight = 50 + marginBase + 100
        
        verticalScrollHeight = scrollHeight + dateHeight + hashLabelHeight + hashHeight + memoLabelHeight + memoHeight + extractLabelHeight + extractViewHeight + imageTagLabelHeight + imageTagViewHeight + urlHeight
        
        verticalScrollView?.contentSize = CGSize(width: view.frame.width, height: verticalScrollHeight)
        
        
        urlField.text = url
        urlField.textColor = .white
        urlField.font = fieldFont
        urlField.isEnabled = true
        urlField.delegate = self
        
        urlView.addSubview(urlField)
        urlField.centerYAnchor.constraint(equalTo: urlView.centerYAnchor).isActive = true
        urlField.leftAnchor.constraint(equalTo: urlView.leftAnchor, constant: marginBase*2).isActive = true
        urlField.rightAnchor.constraint(equalTo: urlView.rightAnchor, constant: -marginBase*2).isActive = true
        urlField.translatesAutoresizingMaskIntoConstraints = false
        
    }
    var dontEndEditing : Bool = false
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let when = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: when) {
            let availableView = self.view.frame.height - self.keyboardHeight
            
            if textField == self.hashTagField {
                let hashTagViewY = self.hashTagView.frame.origin.y
                
                if availableView < hashTagViewY {
                    self.dontEndEditing = true
                    UIView.animate(withDuration: self.keyBoardDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                        self.verticalScrollView?.contentOffset.y = (hashTagViewY-availableView) + 50
                    }) { (bool) in
                        if bool == true {
                            self.dontEndEditing = false
                        }
                    }
                    
                }
            } else if textField == self.urlField {
                let urlY = self.urlView.frame.origin.y
                if availableView < urlY {
                    self.dontEndEditing = true
                    UIView.animate(withDuration: self.keyBoardDuration, delay: 0.3, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                        self.verticalScrollView?.contentOffset.y = (urlY-availableView) + 50
                    }) { (bool) in
                        if bool == true {
                            self.dontEndEditing = false
                        }
                    }
                }
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == hashTagField || textField == (folder?.tagField)! {
            if textField.text?.count == 0 {
                textField.text = "#"
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == hashTagField || textField == (folder?.tagField)! {
            
            if textField.text!.count > 2 {
                
                if textField.text?.last == "#" {
                    let text = textField.text
                    let range = text!.index((text!.endIndex), offsetBy: -2)..<(text!.endIndex)
                    textField.text?.removeSubrange(range)
                }
                
            } else if textField.text!.count == 1 {
                textField.text = ""
            }
            view.endEditing(true)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == hashTagField || textField == (folder?.tagField)! {
            if textField.text!.count > 2 {
                
                if textField.text?.last == "#" {
                    let text = textField.text
                    let range = text!.index((text!.endIndex), offsetBy: -2)..<(text!.endIndex)
                    textField.text?.removeSubrange(range)
                }
                
            } else if textField.text!.count == 1 {
                textField.text = ""
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var count : Int = 0
        if textField == hashTagField || textField == (folder?.tagField)! {
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
            
            var hts = [String]()
            if let hashTags = textField.text?.components(separatedBy: [" ", "#"]){
                let filteredTags = hashTags.filter{$0 != ""}
                hts = filteredTags
                
                var imageId = ""
                var memoId = ""
                
                if let iId = self.detail[self.scrollIndex].imageId{
                    imageId = iId
                }
                
                if let mId = self.detail[self.scrollIndex].memoId{
                    memoId = mId
                }
                
                let params = [
                    "uniqueId": JoinUserInfo.getInstance.uniqueId,
                    "imageId" : imageId,
                    "memoId" : memoId,
                    "hashTags" : hts
                ] as[ String:Any]
                
                do{
                    let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
                    var request = URLRequest(url: URL(string: RestApi.saveHashTags)!)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpMethod = "POST"
                    request.httpBody = jsonParams
                    
                    URLSession(configuration: .default).dataTask(with: request){(data, response, error) in
                        
                    }.resume()
                }catch{
                    print(error)
                }
            }
            
            self.detail[scrollIndex].hashTags = hts
        }
        
        if textField == urlField {
            if let url = textField.text{
                self.detail[scrollIndex].url?.removeAll()
                self.detail[scrollIndex].url?.append(url + string)
                
                var imageId = ""
                var memoId = ""
                
                if let iId = self.detail[self.scrollIndex].imageId{
                    imageId = iId
                }
                
                if let mId = self.detail[self.scrollIndex].memoId{
                    memoId = mId
                }
                
                let params = [
                    "uniqueId": JoinUserInfo.getInstance.uniqueId,
                    "imageId" : imageId,
                    "memoId" : memoId,
                    "url" : url + string
                    ] as[ String:Any]
                
                do{
                    let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
                    var request = URLRequest(url: URL(string: RestApi.saveUrl)!)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpMethod = "POST"
                    request.httpBody = jsonParams
                    
                    URLSession(configuration: .default).dataTask(with: request){(data, response, error) in
                        
                        }.resume()
                }catch{
                    print(error)
                }
            }

        }
        
        
        return range.location >= count
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let when = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: when) {
            let availableView = self.view.frame.height - self.keyboardHeight
            
            if textView == self.memoField {
                let caret = textView.caretRect(for: (textView.selectedTextRange?.start)!)
//                let hashTagViewY = (self.memoView?.frame.origin.y)! + (self.memoViewHeight?.constant)!
                let hashTagViewY = (self.memoView?.frame.origin.y)! + caret.maxY + (marginBase*4)

//                if availableView < hashTagViewY {
                let screenCoor = self.self.memoView?.superview?.convert((self.memoView?.frame.origin)!, to: self.view)
                let screenCoorY = (screenCoor?.y)! + caret.maxY + (marginBase*4)
                
                //                if availableView < urlY {
                if screenCoorY > availableView {
                    self.dontEndEditing = true
                    UIView.animate(withDuration: self.keyBoardDuration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                        self.verticalScrollView?.contentOffset.y = (hashTagViewY-availableView)
                    }) { (bool) in
                        if bool == true {
//                            self.dontEndEditing = false
                        }
                    }
                    
                }
                
               
            } else if textView == self.extractField {
                let caret = textView.caretRect(for: (textView.selectedTextRange?.start)!)

                let urlY = (self.extractView?.frame.origin.y)! + caret.maxY + (marginBase*4)
                let screenCoor = self.extractView?.superview?.convert((self.extractView?.frame.origin)!, to: self.view)
                let screenCoorY = (screenCoor?.y)! + caret.maxY + (marginBase*4)
                
                //                if availableView < urlY {
                if screenCoorY > availableView {

                    self.dontEndEditing = true
                    UIView.animate(withDuration: self.keyBoardDuration, delay: 0.3, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                        self.verticalScrollView?.contentOffset.y = (urlY-availableView)
                    }) { (bool) in
                        if bool == true {
//                            self.dontEndEditing = false
                        }
                    }
                }
            } else if textView == self.imageTagField {
//                let urlY = (self.imageTagView?.frame.origin.y)! + (self.imageTagHeight?.constant)!
                
                let caret = textView.caretRect(for: (textView.selectedTextRange?.start)!)
                //                let hashTagViewY = (self.memoView?.frame.origin.y)! + (self.memoViewHeight?.constant)!
                let urlY = (self.imageTagView?.frame.origin.y)! + caret.maxY + (marginBase*4)
                let screenCoor = self.imageTagView?.superview?.convert((self.imageTagView?.frame.origin)!, to: self.view)
                let screenCoorY = (screenCoor?.y)! + caret.maxY + (marginBase*4)

//                if availableView < urlY {
                if screenCoorY > availableView {
                    self.dontEndEditing = true
                    UIView.animate(withDuration: self.keyBoardDuration, delay: 0.3, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                        self.verticalScrollView?.contentOffset.y = (urlY-availableView)
                    }) { (bool) in
                        if bool == true {
//                            self.dontEndEditing = false
                        }
                    }
                }
            }
        }
        
        verticalScrollHeight = scrollHeight + dateHeight + hashLabelHeight + hashHeight + memoLabelHeight + memoHeight + extractLabelHeight + extractViewHeight + imageTagLabelHeight + imageTagViewHeight + urlHeight + keyboardHeight
        verticalScrollView?.contentSize = CGSize(width: view.frame.width, height: verticalScrollHeight)
    }
    
    var previewHeightWithoutTextView : CGFloat?
    func textViewDidChange(_ textView: UITextView) {
        let availableView = self.view.frame.height - self.keyboardHeight
        if textView == memoField {
            self.dontEndEditing = true
            
            let width = view.frame.width - (marginBase*4)
            let size = CGSize(width: width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            
            textView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                    memoViewHeight?.constant = estimatedSize.height + (marginBase*2)
                    
                }
            }
            
            view.layoutIfNeeded()
            let caret = textView.caretRect(for: (textView.selectedTextRange?.start)!)
            let memoY = (memoView?.frame.origin.y)! + caret.maxY + (marginBase*4)
            let screenCoor = self.memoView?.superview?.convert((self.memoView?.frame.origin)!, to: view)
            let screenCoorY = (screenCoor?.y)! + caret.maxY
            if screenCoorY > availableView {
                UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                    self.verticalScrollView?.contentOffset.y = memoY - availableView
                }) { (bool) in
                    if bool == true {
                        //                    self.dontEndEditing = false
                    }
                }
            }
            
            
            if let memo = textView.text{
                self.detail[self.scrollIndex].memo?.removeAll()
                self.detail[self.scrollIndex].memo?.append(memo)
                
                print(memo)
                
                var imageId = ""
                var memoId = ""
                
                if let iId = self.detail[self.scrollIndex].imageId{
                    imageId = iId
                }
                
                if let mId = self.detail[self.scrollIndex].memoId{
                    memoId = mId
                }
                
                let params = [
                    "uniqueId": JoinUserInfo.getInstance.uniqueId,
                    "imageId" : imageId,
                    "memoId" : memoId,
                    "memo" : memo
                    ] as[ String:Any]
                
                do{
                    let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
                    var request = URLRequest(url: URL(string: RestApi.saveMemo)!)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpMethod = "POST"
                    request.httpBody = jsonParams
                    
                    URLSession(configuration: .default).dataTask(with: request){(data, response, error) in
                        
                        }.resume()
                }catch{
                    print(error)
                }
                
            }
            
        }
        
        if textView == extractField {
            self.dontEndEditing = true
            let width = view.frame.width - (marginBase*4)
            let size = CGSize(width: width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            
            textView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                    extractHeight?.constant = estimatedSize.height + (marginBase*2)
                }
            }
            
            view.layoutIfNeeded()
            let caret = textView.caretRect(for: (textView.selectedTextRange?.start)!)
            let extractY = (extractView?.frame.origin.y)! + caret.maxY + (marginBase*4)
            
            let screenCoor = self.extractView?.superview?.convert((self.extractView?.frame.origin)!, to: view)
            let screenCoorY = (screenCoor?.y)! + caret.maxY
            if screenCoorY > availableView {
                UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                    self.verticalScrollView?.contentOffset.y = extractY - availableView
                }) { (bool) in
                    if bool == true {
                        //                    self.dontEndEditing = false
                    }
                }
            }
            
            
            if let labels = (extractField?.text) {
                let separatedLabels = labels.components(separatedBy: ",")
                print(separatedLabels)
                self.detail[scrollIndex].labels = separatedLabels
            }
        }
        
        if textView == imageTagField {
            self.dontEndEditing = true
            let width = view.frame.width - (marginBase*4)
            let size = CGSize(width: width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            
            textView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                    imageTagHeight?.constant = estimatedSize.height + (marginBase*2)
                }
            }
            
            view.layoutIfNeeded()
            
            let caret = textView.caretRect(for: (textView.selectedTextRange?.start)!)
            //                let hashTagViewY = (self.memoView?.frame.origin.y)! + (self.memoViewHeight?.constant)!
            let extractY = (self.imageTagView?.frame.origin.y)! + caret.maxY + (marginBase*4)
            let screenCoor = self.imageTagView?.superview?.convert((self.imageTagView?.frame.origin)!, to: view)
            let screenCoorY = (screenCoor?.y)! + caret.maxY
            
//            let extractY = (imageTagView?.frame.origin.y)! + estimatedSize.height + (marginBase*2)
            if screenCoorY > availableView {
                UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                    self.verticalScrollView?.contentOffset.y = extractY - availableView
                }) { (bool) in
                    if bool == true {
                        //                    self.dontEndEditing = false
                    }
                }
            }
            
            
            if let labels = (imageTagField?.text) {
                let separatedLabels = labels.components(separatedBy: ",")
                print(separatedLabels)
                self.detail[scrollIndex].labels = separatedLabels
                
                var imageId = ""
                var memoId = ""
                
                if let iId = self.detail[self.scrollIndex].imageId{
                    imageId = iId
                }
                
                if let mId = self.detail[self.scrollIndex].memoId{
                    memoId = mId
                }
                
                let params = [
                    "uniqueId": JoinUserInfo.getInstance.uniqueId,
                    "imageId" : imageId,
                    "memoId" : memoId,
                    "labels" : separatedLabels
                ] as[ String:Any]
                
                do{
                    let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
                    var request = URLRequest(url: URL(string: RestApi.saveLabels)!)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpMethod = "POST"
                    request.httpBody = jsonParams
                    
                    URLSession(configuration: .default).dataTask(with: request){(data, response, error) in
                        
                        }.resume()
                }catch{
                    print(error)
                }
            }
        }
        
        verticalScrollHeight = scrollHeight + dateHeight + hashLabelHeight + hashHeight + memoLabelHeight + memoHeight + extractLabelHeight + extractViewHeight + imageTagLabelHeight + imageTagViewHeight + urlHeight + keyboardHeight
        verticalScrollView?.contentSize = CGSize(width: view.frame.width, height: verticalScrollHeight)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == memoField {
            memoHeight = (memoViewHeight?.constant)!
        } else if textView == extractField {
            extractViewHeight = (extractHeight?.constant)!
        } else if textView == imageTagField {
            imageTagViewHeight = (imageTagHeight?.constant)!
        }
        verticalScrollHeight = scrollHeight + dateHeight + hashLabelHeight + hashHeight + memoLabelHeight + memoHeight + extractLabelHeight + extractViewHeight + imageTagLabelHeight + imageTagViewHeight + urlHeight
        verticalScrollView?.contentSize = CGSize(width: view.frame.width, height: verticalScrollHeight)
        self.dontEndEditing = false
    }
    

    
    func deleteContents(data: HistoryDataModel) {
        
    }
    
    
}

class ImageCell : UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    var imageView : UIImageView?
    var imageSet : UIImage? {
        didSet {
            
            imageView?.removeFromSuperview()
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.width))
            
            if let image = imageSet {
                imageView?.image = image
            }
            
            
            imageView?.contentMode = .scaleAspectFit
            imageView?.clipsToBounds = true
            
            contentView.addSubview(imageView!)
            imageView?.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
            imageView?.heightAnchor.constraint(equalToConstant: contentView.frame.height).isActive = true
            imageView?.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            imageView?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            imageView?.translatesAutoresizingMaskIntoConstraints = false
            
        }
    }
    
    var urlImage : String? {
        didSet {
            imageView?.removeFromSuperview()
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.width))
            
            if let image = urlImage {
                imageView?.kf.setImage(with: URL(string: RestApi.noteImage + image))
            }
            
            
            imageView?.contentMode = .scaleAspectFit
            imageView?.clipsToBounds = true
            
            contentView.addSubview(imageView!)
            imageView?.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
            imageView?.heightAnchor.constraint(equalToConstant: contentView.frame.height).isActive = true
            imageView?.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            imageView?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            imageView?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ImageDetailViewController : GalleryPhotoDelegate {
    func saveIntoFolder(sender: HistoryDataModel) {
        
    }
    
    func addPhoto(sender: [UIImage]) {
        guard let actionId = actionId else {
            return
        }
        
        guard let folderId = folderId else {
            return
        }
        
        var memoId = ""
        var hashTags = [String]()
        var url = ""
        
        if self.detail.count > 0 {
            if let mId = self.detail[0].memoId {
                memoId = mId
            }
            
            if let hTags = self.detail[0].hashTags{
                hashTags = hTags
            }
            
            if let urlCount = self.detail[0].url?.count {
                if urlCount > 0 {
                    if let u = self.detail[0].url?[0]{
                        url = u
                    }
                }
            }
        }
        
        self.showSpinner(onView: self.view)
        
        do{
            let params = [
                "uniqueId": JoinUserInfo.getInstance.uniqueId,
                "folderId": folderId ,
                "actionId": actionId,
                "memoId": memoId,
                "hashTags" : hashTags,
                "url": url
            ] as [String:Any]
            
            let request = try createImageUploadRequest(url: RestApi.addNoteImage, parameters: params, images: sender)
            URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
                if data == nil {
                    return
                }
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    guard let images = json["images"] as? [[String:Any]] else { return }
                    
                    let imageData = Mapper<ImageData>().mapArray(JSONArray: images)
                    
                    let aId = json["actionId"] as? String
                    self?.action = "NOTE_IMAGE"
                    DispatchQueue.main.async {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5 , execute: {() in
                            self?.getImageDetail()
                            self?.removeSpinner()
                        })
                        
                        if let actionId = aId{
                            
                            var imageNames = [String]()
                            for image in imageData {
                                if let imageName = image.imageName {
                                    imageNames.append(imageName)
                                }
                            }
                            let refreshAction = RefreshAction(actionId: actionId, deleteAction: false, images: imageData)
                            refreshAction.convertToImage = true
                            refreshAction.memoId = memoId
                            self?.refreshDelegate?.refresh(actions: [refreshAction])
                        }

                    }
                    
                }catch{
                    print(error)
                }
            }.resume()
 
        }catch{
            print(error)
        }
        
        addPhotobutton?.isHidden = true
        pager?.numberOfPages = imageArray.count
        pager?.isHidden = false
    }
    
}

