//
//  HomeViewController.swift
//  BuxBox
//
//  Created by SongChiduk on 04/03/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import SafariServices
import ObjectMapper
import SwiftLinkPreview

protocol SaveFolderDelegate : class {
    func createNewFolder(sender :HistoryDataModel)
    func saveIntoFolder(sender:HistoryDataModel)
}

protocol RefreshDelegate: class {
    func refresh(index: Int)
    func refresh(actions: [RefreshAction])
    func refresh(folderId: String)
    func refresh(folderId: String, folderName: String)
}

class HomeViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout, SaveFolderDelegate, UITextViewDelegate, FolderSelectDelegate, UITextFieldDelegate, GalleryPhotoDelegate {
    
    var loadData = true
    var oldOffset : CGFloat = 0
  
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = Color.hexStringToUIColor(hex: "#212121")
        navigationController?.navigationBar.isTranslucent = false
        
//        let rightBarbutton = UIBarButtonItem(image: UIImage(named: "searchTabIcon")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(searchPressed))
//        rightBarbutton.tintColor = UIColor.white
//        self.navigationItem.rightBarButtonItem = rightBarbutton
        
        let rightBarbutton = UIButton(type: .custom)
        rightBarbutton.frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 35)
        rightBarbutton.setImage(UIImage(named:"searchTabIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        rightBarbutton.imageView?.contentMode = .scaleAspectFit
        rightBarbutton.imageView?.clipsToBounds = true
        rightBarbutton.addTarget(self, action: #selector(searchPressed), for: .touchUpInside)
        rightBarbutton.tintColor = .white
        
        let rightBarItem = UIBarButtonItem(customView: rightBarbutton)
        let currWidth = rightBarItem.customView?.widthAnchor.constraint(equalToConstant: 50)
        currWidth?.isActive = true
        let currHeight = rightBarItem.customView?.heightAnchor.constraint(equalToConstant: 25)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        setupKeyBoardNotification()
        
        view.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
        setupBottomButton()
//        setupWelcomeMessageView()
        setupCollectionView()
        setupTextField()
        setupFolderSelectView()
        
        getList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        endEditing()
    }
    
    var isFristLoad : Bool = true
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        //collectionView.scrollToItem(at: IndexPath(item: historyDataArray.count-1, section: 0), at: .top, animated: false)
    }
    
    @objc func searchPressed() {
        print("search view present")
        let vc = SearchViewController()
        vc.homeViewController = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupKeyBoardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func getList(){
        let params = [
            "uniqueId": JoinUserInfo.getInstance.uniqueId,
            "skip" : historyDataArray.count.description
        ].stringFromHttpParameters()
        
        var request = URLRequest(url: URL(string: RestApi.getList + "?" + params)!)
        request.httpMethod = "GET"
        
        URLSession(configuration: .default).dataTask(with: request){(data, response, error) in
            
            self.loadData = true
            
            if data == nil {
                return
            }
            
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String:Any]]
                var result = Mapper<HistoryDataModel>().mapArray(JSONArray: json)
                
                if result.count == 0 {
                    return
                }
                
                var scrollToBottom = false
                if self.historyDataArray.count == 0 {
                    scrollToBottom = true
                }
                
                result.reverse()
                
                DispatchQueue.main.async {
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    self.collectionView.performBatchUpdates({
                        let count = result.count
                        var indexPaths = [IndexPath]()
                        for index in 0 ..< count {
                            
                            let indexPath = IndexPath(row: index, section: 0)
                            indexPaths.append(indexPath)
                            
                        }
                        
                        self.historyDataArray.insert(contentsOf: result, at: 0)
                        
                        if indexPaths.count > 0 {
                            self.collectionView.insertItems(at: indexPaths)
                        }
                    }, completion: { finished in
                        
                        if !scrollToBottom {
                           self.collectionView.contentOffset = CGPoint(x: 0.0, y: self.collectionView.contentSize.height - self.oldOffset)
                        }
                 
                        CATransaction.commit()
                    })
                
                 
                    if scrollToBottom {
                        
                        self.collectionView.scrollToItem(at: IndexPath(item: self.historyDataArray.count-1, section: 0), at: .top, animated: false)
                        
                    }
                }                   
            }catch{
                print(error)
            }
            
        }.resume()
    }
    
    var emptyViewHeight : CGFloat = 0
    var keyboardHeight : CGFloat = 0
    @objc func keyboardShow(_ notification: Notification) {
        
        let keyBoardFrame = (notification.userInfo? [UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        keyboardHeight = (keyBoardFrame?.height)!
        let keyBoardDuration = (notification.userInfo? [UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        textViewBottomConstraint?.constant = -((keyBoardFrame?.height)!)
        emptyViewHeight = view.frame.height - (keyBoardFrame?.height)! - (marginBase*10)
        
        
        if isFolderOn == true {
            let newFolderHeight = tagViewHeight + keyboardHeight
            folderHeightConstraint?.constant = newFolderHeight
            textViewBottomConstraint?.constant = -newFolderHeight
        }
        
        UIView.animate(withDuration: keyBoardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    var keyBoardDuration : Double = 0
    @objc func keyboardHide(_ notification: Notification) {
        
        keyBoardDuration = (notification.userInfo? [UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
//        textViewBottomConstraint?.constant = -(tabViewHeight)
        
        UIView.animate(withDuration: keyBoardDuration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    var textViewContainer : UIView?
    var textViewBottomConstraint : NSLayoutConstraint?
    var textViewContainerHeight : NSLayoutConstraint?
    
    var textViewInnerContainer : UIView?
    var textViewInnerHeight : NSLayoutConstraint?
    
    var textView : UITextView?
    var textViewHeightContraint : NSLayoutConstraint?
    var textViewHeight : CGFloat = 0
    var saveButton : UIButton?
    
    var textViewWidth : CGFloat = 0
    func setupTextField() {
        
        saveButton = UIButton()
        saveButton?.setTitle("저장", for: .normal)
        saveButton?.setTitleColor(Color.hexStringToUIColor(hex: "#FFA00A"), for: .normal)
        saveButton?.setTitleColor(UIColor.lightGray, for: .disabled)
        saveButton?.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        saveButton?.isEnabled = false
        saveButton?.addTarget(self, action: #selector(savePressed), for: .touchUpInside)
        
        textViewWidth = view.frame.width - (marginBase*5) - (saveButton?.titleLabel?.intrinsicContentSize.width)!
        textView = UITextView()
        textView?.delegate = self
        textView?.tintColor = Color.hexStringToUIColor(hex: "#FFA00A")
        textView?.font = UIFont(name: "HelveticaNeue", size: 18)
        textView?.textColor = UIColor.white
        textView?.backgroundColor = UIColor.clear
        let size = CGSize(width: textViewWidth, height: .infinity)
        let estimatedSize = textView?.sizeThatFits(size)
        textViewHeight = (estimatedSize?.height)!
        textViewContainer = UIView()
        textViewContainer?.backgroundColor = Color.hexStringToUIColor(hex: "#2E2E2E")

        view.addSubview(textViewContainer!)
        textViewBottomConstraint = NSLayoutConstraint(item: textViewContainer!, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -tabViewHeight)
        textViewContainer?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textViewContainer?.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        textViewContainerHeight = NSLayoutConstraint(item: textViewContainer!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: textViewHeight + (marginBase*2))
        view.addConstraints([textViewBottomConstraint!, textViewContainerHeight!])
        textViewContainer?.translatesAutoresizingMaskIntoConstraints = false
        
        textViewInnerContainer = UIView()
        textViewInnerContainer?.backgroundColor = Color.hexStringToUIColor(hex: "#363636")
        textViewInnerContainer?.layer.cornerRadius = textViewHeight / 2
        textViewContainer?.addSubview(textViewInnerContainer!)
        textViewInnerContainer?.topAnchor.constraint(equalTo: textViewContainer!.topAnchor, constant: marginBase).isActive = true
        textViewInnerContainer?.centerXAnchor.constraint(equalTo: textViewContainer!.centerXAnchor).isActive = true
        textViewInnerContainer?.widthAnchor.constraint(equalToConstant: view.frame.width - marginBase*2).isActive = true
        textViewInnerHeight = NSLayoutConstraint(item: textViewInnerContainer!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: textViewHeight)
        textViewInnerContainer?.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(textViewInnerHeight!)
        
       
        textViewContainer?.addSubview(saveButton!)
        saveButton?.bottomAnchor.constraint(equalTo: (textViewInnerContainer?.bottomAnchor)!, constant: -8).isActive = true
        saveButton?.rightAnchor.constraint(equalTo: (textViewInnerContainer?.rightAnchor)!, constant: -8).isActive = true
        saveButton?.widthAnchor.constraint(equalToConstant: (saveButton?.titleLabel?.intrinsicContentSize.width)!).isActive = true
        saveButton?.heightAnchor.constraint(equalToConstant: (saveButton?.titleLabel?.intrinsicContentSize.height)!).isActive = true
        saveButton?.translatesAutoresizingMaskIntoConstraints = false
        
        
        textViewContainer?.addSubview(textView!)
        textView?.centerYAnchor.constraint(equalTo: textViewInnerContainer!.centerYAnchor).isActive = true
        textView?.leftAnchor.constraint(equalTo: (textViewInnerContainer?.leftAnchor)!, constant: marginBase).isActive = true
        textView?.rightAnchor.constraint(equalTo: (saveButton?.leftAnchor)!, constant: -marginBase).isActive = true
        textView?.heightAnchor.constraint(equalToConstant: textViewHeight).isActive = true
        textView?.translatesAutoresizingMaskIntoConstraints = false
        
        let gapView = UIView()
        gapView.backgroundColor = Color.hexStringToUIColor(hex: "#2E2E2E")
        view.addSubview(gapView)
        gapView.topAnchor.constraint(equalTo: (textViewContainer?.bottomAnchor)!).isActive = true
        gapView.bottomAnchor.constraint(equalTo: tabView.topAnchor).isActive = true
        gapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        gapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        gapView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("editing")
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            saveButton?.isEnabled = true
        } else {
            saveButton?.isEnabled = false
        }
        let size = CGSize(width: textViewWidth, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                if estimatedSize.height < emptyViewHeight {
                    constraint.constant = estimatedSize.height
                    textViewHeightContraint?.constant = estimatedSize.height
                    textViewContainerHeight?.constant = estimatedSize.height + (marginBase*2)
                    textViewInnerHeight?.constant = estimatedSize.height
                } else {
                    let maxHeight = emptyViewHeight
                    constraint.constant = maxHeight
                    textViewContainerHeight?.constant = maxHeight + (marginBase*2)
                    textViewInnerHeight?.constant = maxHeight
                }
            }
        }
        view.layoutIfNeeded()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            textView?.endEditing(true)
        }
        
        //if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height{
        
        if scrollView.contentOffset.y <= 0 {
            if self.historyDataArray.count <= 0 {
                return
            }
            
            if loadData {
                
                loadData = false
                oldOffset = self.collectionView.contentSize.height - self.collectionView.contentOffset.y
                getList()
                
            }
        }
    }
    
    @objc func savePressed() {
        view.endEditing(true)
        presentFolderSaveTools()
    }
    
    func presentFolderSaveTools() {
        textViewBottomConstraint?.constant = -(folderHeight)
        folderHeightConstraint?.constant = folderHeight
        UIView.animate(withDuration: keyBoardDuration) {
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
    func setupFolderSelectView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        folder = FolderSelectionViewController(collectionViewLayout: layout)
        folder?.delegate = self
        folder?.refreshDelegate = self
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
    
    func folderSelected(sender: HistoryDataModel) {
        
        if sender.deleteData {
            
            let actionId = sender.actionId
            
            if let actionId = actionId{
                self.historyDataArray.removeAll(where: {$0.actionId == actionId})
                self.collectionView.reloadData()
                deleteAction(actionId: actionId)
            }
            
        }else{
            if textView?.text != "" {
                let savingText = textView?.text
                sender.savingcontentsText = savingText
                
                let dataType : NSTextCheckingResult.CheckingType = [.link]
                let detector = try? NSDataDetector(types: dataType.rawValue)
                let range = NSRange(savingText!.startIndex..<savingText!.endIndex, in: savingText!)
                detector?.enumerateMatches(in: savingText!, options: [], range: range) { (result, _, _) in
                     sender.url = "\((result?.url)!)"
                    self.saveIntoFolder(sender: sender)
                }
                
                
                if (sender.url == nil) || (sender.url == "") {
                    self.saveIntoFolder(sender: sender)
                }
                
            }else{
                self.saveIntoFolder(sender: sender)
            }
        }
        
        endEditing()
        
        textView?.text = ""
        textViewContainerHeight?.constant = textViewHeight + (marginBase*2)
        textViewInnerHeight?.constant = textViewHeight
        let size = CGSize(width: textViewWidth, height: textViewHeight)
        textView?.sizeThatFits(size)
        
        saveButton?.isEnabled = false
        
    }
    
    
    func deleteAction(actionId: String){
        let params = [
            "uniqueId" : JoinUserInfo.getInstance.uniqueId,
            "actionId" : actionId
        ] as [String:Any]
        
        do{
            let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
            
            var request = URLRequest(url: URL(string: RestApi.deleteAction)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonParams
            
            URLSession(configuration: .default).dataTask(with: request){(data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse else {return}
                
                if httpResponse.statusCode == 200 {
                    
                }
            }.resume()
            
        }catch{
            print(error)
        }
    }
    
    func deleteContents(data: HistoryDataModel) {
        var indexNum : Int?
        for (index, element) in historyDataArray.enumerated() {
            if element.folderID == data.folderID {
                indexNum = index
            }
        }
        
        if let val = indexNum {
            historyDataArray.remove(at: val)
            collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [IndexPath(item: val, section: 0)])
            }) { (bool) in
                if bool == true {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func checkWebsite(urlString: String, completion: @escaping (Bool) -> Void ) {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: urlString, options: [], range: NSRange(location: 0, length: urlString.utf16.count)) {
            // it is a link, if the match covers the whole string
            completion(match.range.length == urlString.utf16.count)
        } else {
            completion(false)
        }
    }
    
    func getURL(text: String) -> String {
        let input = text
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
        
        var url : String = ""
        for match in matches {
            guard let range = Range(match.range, in: input) else { continue }
            url = String(input[range])
            
        }
        return url
    }
    
    func verifyUrl(string: String?) -> Bool {
        if let urlString = string {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    func popWebView(url : URL) {
        let vc = WebViewController()
        vc.url = url
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @objc func endEditing() {
        textViewBottomConstraint?.constant = -tabViewHeight
//        folderBottomConstraint?.constant = folderHeight
        folderHeightConstraint?.constant = 0
        isFolderOn = false
        view.endEditing(true)
        UIView.animate(withDuration: keyBoardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func endAddingTag() {
        textViewBottomConstraint?.constant = -folderHeight
        folderHeightConstraint?.constant = folderHeight
        view.endEditing(true)
        UIView.animate(withDuration: keyBoardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == folder?.tagField {
            if textField.text!.count > 2 {
                
                if textField.text?.last == "#" {
                    let text = textField.text
                    let range = text!.index((text!.endIndex), offsetBy: -2)..<(text!.endIndex)
                    textField.text?.removeSubrange(range)
                }
                
            } else if textField.text!.count == 1 {
                textField.text = ""
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

    
    func appendHashTag(_ field : UITextField) {
        field.deleteBackward()
    }
    
    func setupCollectionView() {
        let collectionViewTap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        collectionView.addGestureRecognizer(collectionViewTap)
        collectionView.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
//        collectionView.register(HistoryFolderCell.self, forCellWithReuseIdentifier: "HistoryCell")
        collectionView.register(HistoryInputCell.self, forCellWithReuseIdentifier: "HistoryInputCell")
        collectionView.contentInset = UIEdgeInsets(top: marginBase*2, left: 0, bottom: 55+(marginBase*2), right: 0)
//        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize

        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: tabView.topAnchor).isActive = true
//        collectionView.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        collectionView.heightAnchor.constraint(equalToConstant: contentSize.height).isActive = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
    }
    
    func createNewFolder(sender: HistoryDataModel) {
        saveIntoFolder(sender: sender)
    }
    
    func saveIntoFolder(sender: HistoryDataModel) {
        if let actionId = sender.actionId {
            getAction(actionId: actionId)
        }else{
           saveNote(sender: sender)
        }
        
        endEditing()  
        collectionView.scrollToItem(at: IndexPath(item: historyDataArray.count - 1, section: 0), at: .top, animated: true)
    }
    
    func saveNote(sender: HistoryDataModel){
        let params = [
            "uniqueId": JoinUserInfo.getInstance.uniqueId,
            "hashTags": sender.hashTagArray ?? [],
            "url": sender.url?.trimmingCharacters(in: .whitespaces) ?? "",
            "memo": sender.savingcontentsText?.trimmingCharacters(in: .whitespaces) ?? "",
            "folderName" : sender.folderName?.trimmingCharacters(in: .whitespaces) ?? ""
        ] as [String:Any]
        
        do{
            let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
            
            var request = URLRequest(url: URL(string: RestApi.addNote)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonParams
            
            URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
                if data == nil {
                    return
                }
                
                do{
                    guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] else {return}
                    guard let actionId = json["actionId"] as? String else { return }
                    
                    DispatchQueue.main.async {
                        self?.getAction(actionId: actionId)
                    }

                }catch{
                    print(error)
                }
            }.resume()
            
        }catch{
            print(error)
        }
    }
    
    func getAction(actionId: String){
        let params = [
            "uniqueId" : JoinUserInfo.getInstance.uniqueId,
            "actionId" : actionId
        ].stringFromHttpParameters()
        
        var request = URLRequest(url: URL(string: RestApi.getAction + "?" + params)!)
        request.httpMethod = "GET"
        
        URLSession(configuration: .default).dataTask(with: request) {[weak self] (data, response, error) in
            if data == nil {
                return
            }
            
            do{
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String:Any]] else {return}
                let actions = Mapper<HistoryDataModel>().mapArray(JSONArray: json)
                
                DispatchQueue.main.async {
                    if actions.count > 0 {
                        if let actionId = actions[0].actionId{
                            
                            if let contains = self?.historyDataArray.contains(where: {$0.actionId == actionId}){
                                if contains {
                                    if let index = self?.historyDataArray.index(where: {$0.actionId == actionId}) {
//                                        self?.historyDataArray[index] = actions[0]
//                                        self?.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
//                                        self?.collectionView.reloadData()
                                        self?.refresh(index: index)
                                    }
                                }else{
                                    self?.historyDataArray.append(actions[0])
                                    self?.collectionView.reloadData()
                                    
                                    guard let dataCount = self?.historyDataArray.count else { return }
                                    
                                    
                                    self?.collectionView.scrollToItem(at: IndexPath(item: dataCount - 1, section: 0), at: .top, animated: true)
                                }
                            }
                            
                        }
                        
                       
                    }
                }
                
                
            }catch{
                print(error)
            }
        }.resume()
    }
   
    func addPhoto(sender: [UIImage]){}
    

    var buttonArray = ["cameraTabIcon", "galleryTabIcon", "folderTabIcon"]
    var tabView : UIStackView!
    var tabViewHeight : CGFloat = 0
    func setupBottomButton() {
        let tabbar = UITabBarController()
        tabViewHeight = tabbar.tabBar.frame.height + (marginBase*5)
        
        tabView = UIStackView()
        tabView.backgroundColor = Color.hexStringToUIColor(hex: "#212121")
        tabView.axis = .horizontal
        tabView.distribution = .fillEqually
//        tabView.spacing = (view.frame.width - CGFloat(buttonArray.count * 44))/CGFloat(buttonArray.count)
        view.addSubview(tabView)
        tabView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tabView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tabView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tabView.heightAnchor.constraint(equalToConstant: tabViewHeight).isActive = true
        tabView.translatesAutoresizingMaskIntoConstraints = false
        
        for (_, element) in buttonArray.enumerated() {
            let buttonview = UIView()
            buttonview.backgroundColor = Color.hexStringToUIColor(hex: "#212121")
            tabView.addArrangedSubview(buttonview)
            
            let buttonInnerView = UIView()
            buttonInnerView.backgroundColor = UIColor.black
            buttonInnerView.layer.cornerRadius = 12
            buttonInnerView.layer.borderColor = UIColor.gray.cgColor
            buttonInnerView.layer.borderWidth = 1.5
            buttonview.addSubview(buttonInnerView)
            buttonInnerView.topAnchor.constraint(equalTo: buttonview.topAnchor, constant: marginBase).isActive = true
            buttonInnerView.centerXAnchor.constraint(equalTo: buttonview.centerXAnchor).isActive = true
            buttonInnerView.widthAnchor.constraint(equalToConstant: 44+marginBase).isActive = true
            buttonInnerView.heightAnchor.constraint(equalToConstant: 44+marginBase).isActive = true
            buttonInnerView.translatesAutoresizingMaskIntoConstraints = false
            
            let button = UIButton()
            button.setImage(UIImage(named: element), for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapPressed(sender: )))
            tap.name = element
            button.addGestureRecognizer(tap)
            
            buttonInnerView.addSubview(button)
            button.centerYAnchor.constraint(equalTo: buttonInnerView.centerYAnchor).isActive = true
            button.centerXAnchor.constraint(equalTo: buttonInnerView.centerXAnchor).isActive = true
            button.widthAnchor.constraint(equalToConstant: 30).isActive = true
            button.heightAnchor.constraint(equalToConstant: 30).isActive = true
            button.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.font = UIFont(name: "HelveticaNeue", size: 14)
            label.textColor = Color.hexStringToUIColor(hex: "#807F7F")
            buttonview.addSubview(label)
            label.topAnchor.constraint(equalTo: buttonInnerView.bottomAnchor, constant: 5).isActive = true
            label.centerXAnchor.constraint(equalTo: buttonview.centerXAnchor).isActive = true
            label.translatesAutoresizingMaskIntoConstraints = false
            if element == "cameraTabIcon" {
               label.text = "카메라"
            } else if element == "galleryTabIcon" {
               label.text = "사진첩"
            } else if element == "folderTabIcon" {
                label.text = "폴더"
            }
            
            
        }
    }
    
    func createNewFolder(sender: FolderListModel) {
        let historyModel = HistoryDataModel()
        
        saveIntoFolder(sender: historyModel)
    }
    
    
    var messageView : UIView!
    var dateLabel : UILabel?
    let dateFont = UIFont(name: "HelveticaNeue-Bold", size: 18)
    var aiLogo : UIImageView?
    let logoSize : CGFloat = 24
    let welcomeMessage : UILabel = {
        let w = UILabel()
        w.text = "Welcome to Archive Intelligence. \nChoose a task you want."
        return w
    }()
//    func setupWelcomeMessageView() {
//
//        let messageHeight = Text.textHeightForView(text: welcomeMessage.text!, font: dateFont!, width: view.frame.width - (marginBase*3) - logoSize)
//        let dateHeight = Text.textHeightForView(text: "2019-2-4-Monday", font: dateFont!, width: view.frame.width)
//        let viewHeight = dateHeight + messageHeight + (marginBase*4)
//        messageView = UIView()
//        view.addSubview(messageView)
//        messageView.bottomAnchor.constraint(equalTo: tabView.topAnchor).isActive = true
//        messageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        messageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        messageView.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
//        messageView.translatesAutoresizingMaskIntoConstraints = false
//
//        dateLabel = UILabel()
//        dateLabel?.text = getToday()
//        dateLabel?.font = dateFont
//        dateLabel?.textColor = Color.hexStringToUIColor(hex: "#9B9B9B")
//
//        view.addSubview(dateLabel!)
//        dateLabel?.centerXAnchor.constraint(equalTo: messageView.centerXAnchor).isActive = true
//        dateLabel?.topAnchor.constraint(equalTo: messageView.topAnchor).isActive = true
//        dateLabel?.translatesAutoresizingMaskIntoConstraints = false
//
//        let leftLine = UIView()
//        leftLine.backgroundColor = Color.hexStringToUIColor(hex: "#9B9B9B")
//        view.addSubview(leftLine)
//        leftLine.leftAnchor.constraint(equalTo: messageView.leftAnchor).isActive = true
//        leftLine.rightAnchor.constraint(equalTo: (dateLabel?.leftAnchor)!, constant: -marginBase*2).isActive = true
//        leftLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
//        leftLine.centerYAnchor.constraint(equalTo: (dateLabel?.centerYAnchor)!).isActive = true
//        leftLine.translatesAutoresizingMaskIntoConstraints = false
//
//        let rightLine = UIView()
//        rightLine.backgroundColor = Color.hexStringToUIColor(hex: "#9B9B9B")
//        view.addSubview(rightLine)
//        rightLine.leftAnchor.constraint(equalTo: (dateLabel?.rightAnchor)! , constant: marginBase*2).isActive = true
//        rightLine.rightAnchor.constraint(equalTo: messageView.rightAnchor).isActive = true
//        rightLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
//        rightLine.centerYAnchor.constraint(equalTo: (dateLabel?.centerYAnchor)!).isActive = true
//        rightLine.translatesAutoresizingMaskIntoConstraints = false
//
//        aiLogo = UIImageView()
//        aiLogo?.image = UIImage(named: "AILogo")
//        view.addSubview(aiLogo!)
//        aiLogo?.widthAnchor.constraint(equalToConstant: logoSize).isActive = true
//        aiLogo?.heightAnchor.constraint(equalToConstant: logoSize).isActive = true
//        aiLogo?.topAnchor.constraint(equalTo: (dateLabel?.bottomAnchor)!, constant: marginBase*2).isActive = true
//        aiLogo?.leftAnchor.constraint(equalTo: messageView.leftAnchor, constant: marginBase).isActive = true
//        aiLogo?.translatesAutoresizingMaskIntoConstraints = false
//
//        welcomeMessage.font = dateFont
//        welcomeMessage.textColor = Color.hexStringToUIColor(hex: "#9B9B9B")
//        welcomeMessage.numberOfLines = 0
//        welcomeMessage.lineBreakMode = .byWordWrapping
//        view.addSubview(welcomeMessage)
//        welcomeMessage.topAnchor.constraint(equalTo: (dateLabel?.bottomAnchor)!, constant: marginBase*2).isActive = true
//        welcomeMessage.leftAnchor.constraint(equalTo: (aiLogo?.rightAnchor)!, constant: marginBase).isActive = true
//        welcomeMessage.rightAnchor.constraint(equalTo: messageView.rightAnchor, constant: -marginBase).isActive = true
//        welcomeMessage.translatesAutoresizingMaskIntoConstraints = false
//
//    }
    
    @objc func tapPressed(sender: UITapGestureRecognizer) {
        
        if sender.name == "cameraTabIcon" {
            let vw = AddPhotoPageController()
            vw.saveDelegate = self
            vw.modalPresentationStyle = .overFullScreen
            let nv = UINavigationController(rootViewController: vw)
            present(nv, animated: true, completion: nil)
        } else if sender.name == "galleryTabIcon" {
            let vw = GalleryViewController()
            vw.modalPresentationStyle = .overFullScreen
            vw.delegate = self
            present(vw, animated: true, completion: nil)
        } else if sender.name == "textTabIcon" {
//            let vw = TextAddViewController()
//            vw.modalPresentationStyle = .overFullScreen
//            let nv = UINavigationController(rootViewController: vw)
//            present(nv, animated: true, completion: nil)
        } else if sender.name == "folderTabIcon" {
            let vw = FolderViewController(collectionViewLayout: UICollectionViewFlowLayout())
            vw.refreshDelegate = self
            vw.modalPresentationStyle = .overFullScreen
            
            let nv = UINavigationController(rootViewController: vw)
            present(nv, animated: true, completion: nil)
        } else if sender.name == "searchTabIcon" {
            let vw = FolderViewController(collectionViewLayout: UICollectionViewFlowLayout())
            vw.modalPresentationStyle = .overFullScreen
            let nv = UINavigationController(rootViewController: vw)
            present(nv, animated: true, completion: nil)
        }
        
    }
    
    
    var historyDataArray = [HistoryDataModel]()
    
    var sampleArray : [HistoryDataModel] = [
    
    ]
    
    @objc func imageTapped(sender: CustomTapGestureRecognizer) {
        
        guard let index = sender.index else { return}
        
        let data = historyDataArray[index]
        let vc = ImageDetailViewController()
        vc.delegate = self
        vc.refreshDelegate = self
        vc.listIndex = index
        vc.actionId = data.actionId
        vc.folderId = data.folderID
        
        vc.isUrlImages = true
        if let action = data.action {
            vc.action = action
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func webViewPresent(sender: CustomTapGestureRecognizer) {
        if let index = sender.index{
            let data = historyDataArray[index]
            
            if let url = data.url{
                var link = url
                if !url.hasPrefix("http") {
                    link = "http://" + url
                }
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = false
                config.barCollapsingEnabled = true
                if let urlLink = URL(string: link.trimmingCharacters(in: .whitespaces)){
                    let vc = SFSafariViewController(url: urlLink, configuration: config)
                    vc.modalPresentationStyle = .overFullScreen
                    
                    self.present(vc, animated: true, completion: nil)

                }
            }
            
        }
        
        
    }
    
    @objc func webViewPresentFromTextView(sender: IndexPath) {
        let data = historyDataArray[sender.item]
        let vc = MyWebView()
        vc.link = "\(data.url!)"
        let nv = UINavigationController(rootViewController: vc)
        nv.modalPresentationStyle = .overFullScreen
        
        present(nv, animated: true, completion: nil)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return historyDataArray.count
    }
    
    @objc func folderNameTap(sender: CustomTapGestureRecognizer){
        if let index = sender.index {
            let data = historyDataArray[index]
            let vc = FolderDetailViewController()
            vc.folderID = data.folderID
            vc.folderTitle = data.folderName
            vc.refreshDelegate = self
            self.navigationController?.pushViewController(vc, animated: true)
            
            
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = historyDataArray[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryInputCell", for: indexPath) as? HistoryInputCell
        
        cell?.homeView = self
        cell?.index = indexPath
        
        if let imageData = data.savingContentsImage {
            cell?.imageSet = imageData
        }
        
        //MARK: TESTING PURPOSE ONLY
        if let testingImageData = data.imageArrayForTesting {
            cell?.testImageSet = testingImageData
        }
         //END : TESTING PURPOSE ONLY
        
        if let textData = data.memo {
            cell?.textSet = textData
            let textTap = CustomTapGestureRecognizer(target: self, action: #selector(imageTapped))
            textTap.index = indexPath.item
            textTap.historyData = data
            cell?.savingText?.addGestureRecognizer(textTap)
            cell?.savingText?.isUserInteractionEnabled = true
            
            

            
            if let url = data.url {
                if url.count > 0 {
                    cell?.webViewHeight?.constant = self.view.frame.width/2
                    cell?.webView?.isHidden = false
                    collectionView.layoutIfNeeded()
                    if data.urlImage == nil {
                        if url.hasPrefix("https://goo.") {
                            /*
                             need to run google OAuth then getURL
                             */
                            data.urlTitle = "www.google.com"
                            cell?.urlTitleSet = "www.google.com"
                            
                            data.urlImage = "https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png"
                            cell?.urlImageSet = "https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png"
                        } else {
                            
                            
                            self.getURLData(index: indexPath, textData: url, urlDataCompletion: { (image, title) in
                                if let dataReceived = title {
                                    cell?.urlTitleSet = dataReceived
                                }
                                
                                if let dataReceived = image {
                                    cell?.urlImageSet = dataReceived
                                } else {
                                    if data.urlTitle == "Google Maps" {
                                        data.urlImage = "https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png"
                                        cell?.urlImageSet = "https://www.google.com/images/branding/googleg/1x/googleg_standard_color_128dp.png"
                                    } else {
                                        cell?.urlImageSet = "galleryTabIcon"
                                    }
                                    
                                }
                                
                            })
                            
                        }
                    }
                }else{
                    cell?.webViewHeight?.constant = 0
                    cell?.webView?.removeFromSuperview()
                    cell?.webView?.isHidden = true
                    collectionView.layoutIfNeeded()
                }
                
                
            } else {
                cell?.webViewHeight?.constant = 0
                cell?.webView?.removeFromSuperview()
                cell?.webView?.isHidden = true
                collectionView.layoutIfNeeded()
            }
            
            if let urltitle = data.urlTitle {
                cell?.urlTitleSet = urltitle
            }
            
            //MARK: SET URL IMAGE ON BACKGROUND THREAD
            if let imageData = data.urlImage {
                cell?.urlImageSet = imageData
            }
            
            let urlTap = CustomTapGestureRecognizer(target: self, action: #selector(webViewPresent))
            urlTap.index = indexPath.item
            cell?.webView?.addGestureRecognizer(urlTap)
            
        }
        
        
        
        
        cell?.setupFolderView()
        
        cell?.titleSet = data.folderName
        
        
        if let container = cell?.inputContainer {
            for i in (container.subviews) {
                if i is UIImageView {
                    let multiImageTap = CustomTapGestureRecognizer(target: self, action: #selector(imageTapped))
                    multiImageTap.index = indexPath.item
                    multiImageTap.historyData = data
                    
                    i.addGestureRecognizer(multiImageTap)
                    i.isUserInteractionEnabled = true
                }
            }
        }
        
        if let singleImage = cell?.imageView {
            let imageTap = CustomTapGestureRecognizer(target: self, action: #selector(imageTapped))
            imageTap.index = indexPath.item
            imageTap.historyData = data
            singleImage.addGestureRecognizer(imageTap)
            singleImage.isUserInteractionEnabled = true
        }
        
        cell?.folderView.isUserInteractionEnabled = true
        let tap = CustomTapGestureRecognizer(target: self, action: #selector(folderNameTap(sender:)))
        tap.index = indexPath.row
        cell?.folderView.addGestureRecognizer(tap)
        
        return cell!
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cell = HistoryInputCell()
        let data = historyDataArray[indexPath.item]
        var cellHeight : CGFloat = 0
        let imageWidthDivider : CGFloat = 2.5
        var topGap : CGFloat = 4
        
        if let imageData = data.savingContentsImage {
            if imageData.count == 1 {
                let image = UIImage(named: imageData[0])
                let width = (view.frame.width) / imageWidthDivider
                let height =  803 / 571 * (width)
                cellHeight = height + (marginBase * topGap)
            } else if  imageData.count > 1 {
                cellHeight = (view.frame.width / imageWidthDivider) + (marginBase*3) + CGFloat(4*imageData.count) + (marginBase * topGap)
            } else {
                cellHeight = 0
            }
        } else {
            cellHeight = 0
        }
        
        
        //MARK: TESTING PURPOSE ONLY
        if let testingImageArray = data.imageArrayForTesting {
            if testingImageArray.count == 1 {
                let image = testingImageArray[0]
                let width = (view.frame.width) / cell.imageWidthDivider
                let height = ((image.size.height)/(image.size.width))*(width)
                cellHeight = height + (marginBase*cell.topGap)
            } else if  testingImageArray.count > 1 {
                cellHeight = (view.frame.width / cell.imageWidthDivider) + (marginBase*3) + CGFloat(4*testingImageArray.count) + (marginBase*cell.topGap)
            } else {
                cellHeight = 0
            }
        }
        //END : TESTING PURPOSE ONLY
        
        if let textData = data.memo {
            cellHeight = Text.textHeightForView(text: textData, font: cell.textViewFont!, width: view.frame.width/2) + (marginBase*cell.topGap)
            
            if let url = data.url {
                if url.count > 0 {
                    cellHeight += self.view.frame.width/2 + (marginBase*4)
                }
                
            }
            
//            let previewLink = SwiftLinkPreview(session: .shared, workQueue: .main, responseQueue: .main, cache: DisabledCache.instance)
//            previewLink.preview(textData, onSuccess: { (result) in
//                print("\(result)")
//
//                if result.title != nil {
//                    cellHeight += self.view.frame.width/2 + (marginBase*4)
//                }
//
//            }) { (error) in
//                print("\(error)")
//            }
            
        }
        
        let folderHeight = cell.imageHeight
        let saveLabelHeight = cell.savedLabel.intrinsicContentSize.height + marginBase + (marginBase/2)
        
        
        let totalCellHeight = cellHeight + marginBase + folderHeight + saveLabelHeight
        
        return CGSize(width: view.frame.width, height: totalCellHeight)
    }
    
    func getURLData(index: IndexPath, textData: String, urlDataCompletion: @escaping (_ image: String?, _ title: String?)-> Void) {
        
        let previewLink = SwiftLinkPreview(session: .shared, workQueue: .main, responseQueue: .main, cache: DisabledCache.instance)
        
        previewLink.preview(textData, onSuccess: { (result) in
            
                let data = self.historyDataArray[index.item]
                var image : String?
                var title : String?
                if let imageResult = result.image {
                    data.urlImage = imageResult
                    image = imageResult
                } else if let imageResult = result.images?[0] {
                    data.urlImage = imageResult
                    image = imageResult
                }
            
                if let resultTitle = result.title {
                    data.urlTitle = resultTitle
                    title = resultTitle
                }
            
            
            if let setImage = image, let setTitle = title {
                return urlDataCompletion(setImage, setTitle)
            } else {
                return urlDataCompletion(image, title)
            }
            
            
            
            
        }) { (error) in
            print("previewLink \(error)")
        }
    }
    
    func returnURL(text: String,completion: @escaping (String)->Void) {
        let previewLink = SwiftLinkPreview(session: .shared, workQueue: .main, responseQueue: .main, cache: DisabledCache.instance)
        previewLink.preview(text, onSuccess: { (result) in
            
            print(result)
            
            if result.finalUrl != nil {
                completion("\(result.finalUrl!)")
            } else if result.canonicalUrl != nil {
                completion("\(result.canonicalUrl!)")
            } else if result.url != nil {
                completion("\(result.url!)")
            }
        }) { (error) in
            print("\(error)")
        }
    }
    
    
}


class HistoryInputCell : UICollectionViewCell, UITextViewDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var folderView = UIView()
    
    var homeView : HomeViewController?
    var index : IndexPath?
    let imageWidthDivider : CGFloat = 2.5
    var imageView : UIImageView?
    var inputContainer : UIView?
    
    var numberView : UIView?
    var numberLabel : UILabel?
    var topGap : CGFloat = 4
    var imageSet : [String]? {
        didSet {
        
            removeAll()
            if imageSet!.count > 1 {
                let width = contentView.frame.width/3
                let containerHeight = width + (marginBase*3)+CGFloat(4*(imageSet?.count)!)
                inputContainer = UIView()
                contentView.addSubview(inputContainer!)
                inputContainer?.topAnchor.constraint(equalTo: contentView.topAnchor, constant: marginBase*3).isActive = true
                inputContainer?.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
                inputContainer?.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
                inputContainer?.heightAnchor.constraint(equalToConstant: containerHeight).isActive = true
                inputContainer?.translatesAutoresizingMaskIntoConstraints = false
                
                for (index, element) in (imageSet?.enumerated())! {
                    
                    let imageView = UIImageView()
                    imageView.kf.setImage(with: URL(string: RestApi.noteImage + element))
                    imageView.contentMode = .scaleAspectFill
                    imageView.clipsToBounds = true
                    
                    inputContainer?.addSubview(imageView)
                    imageView.topAnchor.constraint(equalTo: (inputContainer?.topAnchor)!, constant: (marginBase*topGap)+CGFloat((4*((imageSet?.count)!-index)))).isActive = true
                    imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -((marginBase*3)+(4*CGFloat(index)))).isActive = true
                    imageView.widthAnchor.constraint(equalToConstant: contentView.frame.width/imageWidthDivider).isActive = true
                    imageView.heightAnchor.constraint(equalToConstant: contentView.frame.width/imageWidthDivider).isActive = true
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    
                    if index != ((imageSet?.count)!-1) {
                        //imageView.image = convertImageToBW(image: UIImage(named: element)!)
                        let processor = BlackWhiteProcessor()
                        imageView.kf.setImage(with: URL(string: RestApi.noteImage + element), options: [.processor(processor)])
                    }
                    
                    if index == ((imageSet?.count)!-1) {
                        numberView?.removeFromSuperview()
                        numberView = UIView()
                        numberView?.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
                        numberView?.alpha = 0.7
                        numberView?.layer.borderColor = UIColor.white.cgColor
                        numberView?.layer.borderWidth = 1
                        numberView?.layer.cornerRadius = 15
                        
                        contentView.addSubview(numberView!)
                        numberView?.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10).isActive = true
                        numberView?.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: -10).isActive = true
                        numberView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
                        numberView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
                        numberView?.translatesAutoresizingMaskIntoConstraints = false
                        
                        numberLabel?.removeFromSuperview()
                        numberLabel = UILabel()
                        numberLabel?.text = "\((imageSet?.count)!)"
                        numberLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                        numberLabel?.textColor = UIColor.white
                        numberView?.addSubview(numberLabel!)
                        numberLabel?.centerXAnchor.constraint(equalTo: (numberView?.centerXAnchor)!).isActive = true
                        numberLabel?.centerYAnchor.constraint(equalTo: (numberView?.centerYAnchor)!).isActive = true
                        numberLabel?.translatesAutoresizingMaskIntoConstraints = false
                    }
                }
                
            } else {
                imageView?.removeFromSuperview()
                imageView = UIImageView()
                imageView?.contentMode = .scaleAspectFit
                imageView?.clipsToBounds = true
                
                
                
                if let images = imageSet {
                    if images.count > 0 {
                        imageView?.kf.setImage(with: URL(string: RestApi.noteImage + images[0]))
                    }
                    
                }
                

                
                
                let width = (contentView.frame.width) / imageWidthDivider
                let height = 803 / 571 * (width)
                
                contentView.addSubview(imageView!)
                imageView?.topAnchor.constraint(equalTo: contentView.topAnchor, constant: (marginBase*topGap)).isActive = true
                imageView?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -(marginBase*3)).isActive = true
                imageView?.widthAnchor.constraint(equalToConstant: width).isActive = true
                imageView?.heightAnchor.constraint(equalToConstant: height).isActive = true
                imageView?.translatesAutoresizingMaskIntoConstraints = false
            }
        }
    }
    
    var testImageSet : [UIImage]? {
        didSet {
            removeAll()
            if testImageSet!.count > 1 {
                let width = contentView.frame.width/3
                let containerHeight = width + (marginBase*3)+CGFloat(4*(testImageSet?.count)!)
                inputContainer = UIView()
                contentView.addSubview(inputContainer!)
                inputContainer?.topAnchor.constraint(equalTo: contentView.topAnchor, constant: marginBase*3).isActive = true
                inputContainer?.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
                inputContainer?.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
                inputContainer?.heightAnchor.constraint(equalToConstant: containerHeight).isActive = true
                inputContainer?.translatesAutoresizingMaskIntoConstraints = false
                
                for (index, element) in (testImageSet?.enumerated())! {
                    
                    let imageView = UIImageView()
                    imageView.image = element
                    imageView.contentMode = .scaleAspectFill
                    imageView.clipsToBounds = true
                    
                    inputContainer?.addSubview(imageView)
                    imageView.topAnchor.constraint(equalTo: (inputContainer?.topAnchor)!, constant: (marginBase*topGap)+CGFloat((4*((testImageSet?.count)!-index)))).isActive = true
                    imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -((marginBase*3)+(4*CGFloat(index)))).isActive = true
                    imageView.widthAnchor.constraint(equalToConstant: contentView.frame.width/imageWidthDivider).isActive = true
                    imageView.heightAnchor.constraint(equalToConstant: contentView.frame.width/imageWidthDivider).isActive = true
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    
                    if index != ((testImageSet?.count)!-1) {
                        imageView.image = convertImageToBW(image: element)
                    }
                
                    if index == ((testImageSet?.count)!-1) {
                        numberView?.removeFromSuperview()
                        numberView = UIView()
                        numberView?.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
                        numberView?.alpha = 0.7
                        numberView?.layer.borderColor = UIColor.white.cgColor
                        numberView?.layer.borderWidth = 1
                        numberView?.layer.cornerRadius = 15
                        
                        contentView.addSubview(numberView!)
                        numberView?.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10).isActive = true
                        numberView?.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: -10).isActive = true
                        numberView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
                        numberView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
                        numberView?.translatesAutoresizingMaskIntoConstraints = false
                        
                        numberLabel?.removeFromSuperview()
                        numberLabel = UILabel()
                        numberLabel?.text = "\((testImageSet?.count)!)"
                        numberLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                        numberLabel?.textColor = UIColor.white
                        numberView?.addSubview(numberLabel!)
                        numberLabel?.centerXAnchor.constraint(equalTo: (numberView?.centerXAnchor)!).isActive = true
                        numberLabel?.centerYAnchor.constraint(equalTo: (numberView?.centerYAnchor)!).isActive = true
                        numberLabel?.translatesAutoresizingMaskIntoConstraints = false
                    }
                }
                
            } else {
                imageView?.removeFromSuperview()
                imageView = UIImageView()
                imageView?.contentMode = .scaleAspectFit
                imageView?.clipsToBounds = true
                
                let image = testImageSet![0]
                imageView?.image = image
                
                let width = (contentView.frame.width) / imageWidthDivider
                let height = ((image.size.height)/(image.size.width))*(width)
                
                contentView.addSubview(imageView!)
                imageView?.topAnchor.constraint(equalTo: contentView.topAnchor, constant: (marginBase*topGap)).isActive = true
                imageView?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -(marginBase*3)).isActive = true
                imageView?.widthAnchor.constraint(equalToConstant: width).isActive = true
                imageView?.heightAnchor.constraint(equalToConstant: height).isActive = true
                imageView?.translatesAutoresizingMaskIntoConstraints = false
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        homeView?.webViewPresentFromTextView(sender: self.index!)
        return true
    }
    
    var webView : UIView?
    var webViewHeight : NSLayoutConstraint?
    var webViewTop : NSLayoutConstraint?
    var savingText : UITextView?
    let textViewFont = UIFont(name: "HelveticaNeue", size: 18)
    var textSet : String? {
        didSet {
            removeAll()
            savingText?.removeFromSuperview()
            savingText = UITextView()
            savingText?.delegate = self
            savingText?.text = textSet
            savingText?.font = UIFont(name: "HelveticaNeue", size: 18)
            savingText?.textColor = UIColor.white
            savingText?.backgroundColor = UIColor.clear
            savingText?.isEditable = false
            savingText?.scrollRangeToVisible(NSRangeFromString(textSet!))
            savingText?.isScrollEnabled = false
//            savingText?.dataDetectorTypes = UIDataDetectorTypes.link
            
            
            let width = contentView.frame.width / 2
            let textWidth = Text.textWidthForView(text: textSet!, font: textViewFont!, height: 20)
            if textWidth < width {
                savingText?.textAlignment = .right
            } else {
                savingText?.textAlignment = .left
            }
            contentView.addSubview(savingText!)
            savingText?.topAnchor.constraint(equalTo: contentView.topAnchor, constant: (marginBase*topGap)).isActive = true
            savingText?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -(marginBase*3)).isActive = true
            savingText?.widthAnchor.constraint(equalToConstant: width).isActive = true
            savingText?.sizeToFit()
            savingText?.translatesAutoresizingMaskIntoConstraints = false
            
            webView?.removeFromSuperview()
            webView = UIView()
            webView?.backgroundColor = .white
            
            contentView.addSubview(webView!)
            webViewTop = NSLayoutConstraint(item: webView as Any, attribute: .top, relatedBy: .equal, toItem: savingText, attribute: .bottom, multiplier: 1, constant: 0)
            webViewHeight = NSLayoutConstraint(item: webView as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
            webView?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -(marginBase*3)).isActive = true
            webView?.widthAnchor.constraint(equalToConstant: contentView.frame.width/2).isActive = true
            webView?.translatesAutoresizingMaskIntoConstraints = false
            contentView.addConstraints([webViewTop!, webViewHeight!])
            
            urlImageView?.removeFromSuperview()
            urlImageView = UIImageView()
            urlImageView?.contentMode = .scaleAspectFill
            urlImageView?.clipsToBounds = true
            urlImageHeight = NSLayoutConstraint(item: urlImageView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
            
            webView?.addSubview(urlImageView!)
            urlImageView?.topAnchor.constraint(equalTo: (webView?.topAnchor)!).isActive = true
            urlImageView?.leftAnchor.constraint(equalTo: (webView?.leftAnchor)!).isActive = true
            urlImageView?.rightAnchor.constraint(equalTo: (webView?.rightAnchor)!).isActive = true
            urlImageView?.translatesAutoresizingMaskIntoConstraints = false
            webView?.addConstraint(urlImageHeight!)
        }
    }
    
    var urlTitleFont = UIFont(name: "HelveticaNeue", size: 18)
    var urlTitleLabel : UILabel?
    var urlTitleHeight : CGFloat?
    var urlTitleSet : String? {
        didSet {
            
            urlTitleLabel?.removeFromSuperview()
            urlTitleLabel = UILabel()
            if let data = urlTitleSet {
               urlTitleLabel?.text = data
            } else {
               urlTitleLabel?.text = ""
            }
            
            urlTitleLabel?.font = urlTitleFont
            urlTitleLabel?.numberOfLines = 2
            urlTitleLabel?.lineBreakMode = .byWordWrapping
            urlTitleLabel?.textColor = .darkGray
            
            webView?.addSubview(urlTitleLabel!)
            urlTitleLabel?.bottomAnchor.constraint(equalTo: (webView?.bottomAnchor)!, constant: -marginBase/2).isActive = true
            urlTitleLabel?.leftAnchor.constraint(equalTo: (webView?.leftAnchor)!, constant: marginBase/2).isActive = true
            urlTitleLabel?.rightAnchor.constraint(equalTo: (webView?.rightAnchor)!, constant: -marginBase/2).isActive = true
            urlTitleLabel?.translatesAutoresizingMaskIntoConstraints = false
            
            urlTitleHeight = Text.textHeightForView(text: (urlTitleLabel?.text)!, font: urlTitleFont!, width: (contentView.frame.width/2) - marginBase)
            
            urlImageHeight?.constant = contentView.frame.width/2 - urlTitleHeight! - 4
        }
    }
    
    var urlImageHeight : NSLayoutConstraint?
    var urlImageView : UIImageView?
    var urlImageSet : String? {
        didSet {
            
//            if let data = urlImageSet {
//                let imageURL = URL(string: urlImageSet!)
//                guard let imageData = try? Data(contentsOf: imageURL!) else { return }
//                let image = UIImage(data: imageData)
//                UIGraphicsBeginImageContext(imageSize)
//                image?.draw(in: rect)
//                let newImage = UIGraphicsGetImageFromCurrentImageContext()
//                UIGraphicsEndImageContext()
//                urlImageView?.image = newImage
//            } else {
//                urlImageView?.image = UIImage(named: "galleryTabIcon")
//            }
//            let imageURL = URL(string: self.urlImageSet!)
//            guard let imageData = try? Data(contentsOf: imageURL!) else { return }
            
            
//             let imageURL = URL(string: self.urlImageSet!)
//
//            let task = URLSession.shared.dataTask(with: imageURL!) { data, response, error in
//                guard let data = data, error == nil else { return }
//
//                DispatchQueue.main.async() {    // execute on main thread
//                    self.urlImageView?.image = UIImage(data: data)
//                }
//            }
//
//            task.resume()
//
//            if self.urlImageView?.image != nil {
//               task.cancel()
//            }
            self.urlImageView?.contentMode = .scaleAspectFit
            self.urlImageView?.clipsToBounds = true
            self.urlImageView?.tintColor = .gray
            if urlImageSet == "galleryTabIcon" {
                
                self.urlImageView?.image = UIImage(named: urlImageSet!)?.withRenderingMode(.alwaysTemplate)
               
            } else {
                
                //            DispatchQueue.global(qos: .background).async {
                //                DispatchQueue.main.async {
                self.urlImageView?.kf.setImage(with: URL(string: self.urlImageSet!))
                //                }
                //            }
                
                
//                KingfisherManager.shared.retrieveImage(with: URL(string: self.urlImageSet!)!, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
//
//                    DispatchQueue.main.async {
//                        self.urlImageView?.image = image
//                    }
//                })
                
            }

            
//            if urlImageView?.image == nil {
//                urlImageView?.image = UIImage(named: "galleryTabIcon")
//            }
            
//            guard let url = URL(string: urlImageSet!) else { return }
//
//            let data = try? Data(contentsOf: url)
//
//            if let data = data, let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                     self.urlImageView?.image = image
//                }
//            }
            
        }
    }
    
    func removeAll() {
        inputContainer?.removeFromSuperview()
        numberView?.removeFromSuperview()
        imageView?.removeFromSuperview()
        savingText?.removeFromSuperview()
        webView?.removeFromSuperview()
        urlImageView?.removeFromSuperview()
        urlTitleLabel?.removeFromSuperview()
    }
    
    let savedLabel : UILabel = {
        let w = UILabel()
        w.text = "저장완료"
        w.font = UIFont(name: "HelveticaNeue", size: 14)
        return w
    }()
    
    
    var savedLableView : UIView?
    var folderImage : UIImageView?
    let imageHeight : CGFloat = 25
    var rightArrowButton : UIButton?
    func setupFolderView() {
        folderImage?.removeFromSuperview()
        folderImage = UIImageView()
        folderImage?.image = UIImage(named: "folderImage")?.withRenderingMode(.alwaysTemplate)
        folderImage?.tintColor = UIColor.lightGray
        folderImage?.contentMode = .scaleAspectFit
        folderImage?.clipsToBounds = true
        
        contentView.addSubview(folderImage!)
        folderImage?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        folderImage?.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: marginBase*3).isActive = true
        folderImage?.widthAnchor.constraint(equalToConstant: imageHeight).isActive = true
        folderImage?.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
        folderImage?.translatesAutoresizingMaskIntoConstraints = false
        
        rightArrowButton?.removeFromSuperview()
        rightArrowButton = UIButton()
        rightArrowButton?.setImage(UIImage(named: "nextArrowIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        rightArrowButton?.tintColor = UIColor.lightGray
        rightArrowButton?.imageView?.contentMode = .scaleAspectFit
        rightArrowButton?.imageView?.clipsToBounds = true
        
        contentView.addSubview(rightArrowButton!)
        rightArrowButton?.centerYAnchor.constraint(equalTo: (folderImage?.centerYAnchor)!).isActive = true
        rightArrowButton?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -marginBase*3).isActive = true
        rightArrowButton?.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
        rightArrowButton?.widthAnchor.constraint(equalToConstant: imageHeight).isActive = true
        rightArrowButton?.translatesAutoresizingMaskIntoConstraints = false
        
        //        savedLabel.font = saveLabelFont
        savedLabel.textColor = UIColor.lightGray
        let viewWidth = savedLabel.intrinsicContentSize.width + marginBase*2
        let viewHeight = savedLabel.intrinsicContentSize.height + marginBase
        
        savedLableView?.removeFromSuperview()
        savedLableView = UIView()
        savedLableView?.layer.cornerRadius = viewHeight/2
        
        savedLableView?.backgroundColor = Color.hexStringToUIColor(hex: "#2E2E2E")
        contentView.addSubview(savedLableView!)
        savedLableView?.bottomAnchor.constraint(equalTo: folderImage!.topAnchor, constant: -(marginBase/2)).isActive = true
        savedLableView?.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: marginBase*2).isActive = true
        savedLableView?.widthAnchor.constraint(equalToConstant: viewWidth).isActive = true
        savedLableView?.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
        savedLableView?.translatesAutoresizingMaskIntoConstraints = false
        
        savedLableView?.addSubview(savedLabel)
        savedLabel.centerXAnchor.constraint(equalTo: savedLableView!.centerXAnchor).isActive = true
        savedLabel.centerYAnchor.constraint(equalTo: savedLableView!.centerYAnchor).isActive = true
        savedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        folderView.removeFromSuperview()
        folderView = UIView()
        contentView.addSubview(folderView)
        folderView.topAnchor.constraint(equalTo: savedLabel.topAnchor).isActive = true
        folderView.leftAnchor.constraint(equalTo: savedLabel.leftAnchor).isActive = true
        folderView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        folderView.translatesAutoresizingMaskIntoConstraints = false
       
    }
    
    let dateFont = UIFont(name: "HelveticaNeue-Bold", size: 18)
    var titleLable : UILabel?
    var titleSet : String? {
        didSet {
            titleLable?.removeFromSuperview()
            titleLable = UILabel()
            titleLable?.text = titleSet
            titleLable?.font = dateFont
            titleLable?.textColor = UIColor.white
            titleLable?.numberOfLines = 0
            titleLable?.lineBreakMode = .byWordWrapping
            contentView.addSubview(titleLable!)
            titleLable?.centerYAnchor.constraint(equalTo: folderImage!.centerYAnchor).isActive = true
            titleLable?.leftAnchor.constraint(equalTo: folderImage!.rightAnchor, constant: marginBase).isActive = true
            titleLable?.rightAnchor.constraint(equalTo: (rightArrowButton?.leftAnchor)!, constant: -marginBase).isActive = true
            titleLable?.translatesAutoresizingMaskIntoConstraints = false
            
            if let bottomAnchor = titleLable?.bottomAnchor {
                folderView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            }
        }
    }
    
}

extension HomeViewController : RefreshDelegate {
    func refresh(folderId: String){
        self.historyDataArray.removeAll(where: {$0.folderID == folderId})
        self.collectionView.reloadData()
    }
    
    func refresh(folderId: String, folderName: String) {
        for data in self.historyDataArray{
            if data.folderID == folderId{
                data.folderName = folderName
            }
        }
        
        self.collectionView.reloadData()
    }
    
    func refresh(actions: [RefreshAction]) {
        
        for action in actions{
            if let delAction = action.deleteAction {
                if delAction {
                    guard let actionId = action.actionId else { return }
                    self.deleteAction(actionId: actionId)
                    self.historyDataArray.removeAll(where: {$0.actionId == actionId})
                    self.collectionView.reloadData()
                }else{
                    guard let actionId = action.actionId else {return}

                    self.getAction(actionId: actionId)
 
                }
            }
        }

    }
    
    func refresh(index: Int) {
        
        
        if self.historyDataArray.count <= index {
            return
        }
        
        
        guard let actionId = self.historyDataArray[index].actionId else {return}
        
        let params = [
            "uniqueId" : JoinUserInfo.getInstance.uniqueId,
            "actionId" : actionId
        ].stringFromHttpParameters()
        
        var request = URLRequest(url: URL(string: RestApi.getAction + "?" + params)!)
        request.httpMethod = "GET"
        
        URLSession(configuration: .default).dataTask(with: request) {[weak self](data, response, error) in
            if data == nil {
                return
            }
            
            do{
                guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String:Any]] else {return}
                let folders = Mapper<HistoryDataModel>().mapArray(JSONArray: json)
                
                DispatchQueue.main.async {
                    if folders.count > 0 {
                        let folder = folders[0]
                        
                        let index = self?.historyDataArray.index(where: {$0.actionId == actionId})
                        if let index = index {
                             self?.historyDataArray[index] = folder
                            self?.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
                        }
                       
                        
                    }else if folders.count == 0 {
                        self?.historyDataArray.removeAll(where: {$0.actionId == actionId})
                        self?.collectionView.reloadData()
                    }
                }
                
            }catch{
                print(error)
            }
        }.resume()
    }
}
