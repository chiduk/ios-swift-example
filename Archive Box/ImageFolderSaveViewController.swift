//
//  ImageFolderSaveViewController.swift
//  BuxBox
//
//  Created by SongChiduk on 11/03/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class ImageFolderSaveViewController : UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
        setupNavBar()
        setupFolderView()
        setupKeyBoardNotification()
        folderHeightConstraint?.constant = folderHeight
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
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
        
            let newFolderHeight = tagViewHeight + keyboardHeight
            folderHeightConstraint?.constant = newFolderHeight
        
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
    
    deinit {
        folder = nil
        print("ImageFolderSaveViewController denit successful")
    }
    
    weak var delegate : AddphotoDelegate?
    var closeButton : UIButton!
    var topView : UIView!
    func setupNavBar() {
      
        let nav = UINavigationController()
        let height = nav.navigationBar.frame.height
        topView = UIView()
        topView.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
        view.addSubview(topView)
        topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        topView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: height).isActive = true
        topView.translatesAutoresizingMaskIntoConstraints = false
        
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
        
    }
    
    @objc func dismissView() {
        delegate?.dismissView()
    }
    
    
    var imageListSet : [UIImage]? {
        didSet {
            
            for (index, element) in (imageListSet?.enumerated())! {
                
                let imageView = UIImageView()
                imageView.image = element
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                
                view.addSubview(imageView)
                if index == 0 {
                    imageView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: (marginBase*3)+CGFloat((4*(imageListSet?.count)!))).isActive = true
                    imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -marginBase*3).isActive = true
                } else {
                    imageView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: (marginBase*3)+CGFloat((4*((imageListSet?.count)!-index)))).isActive = true
                    imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -((marginBase*3)+(4*CGFloat(index)))).isActive = true
                }
                
                
                imageView.widthAnchor.constraint(equalToConstant: view.frame.width/4).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: view.frame.width/4).isActive = true
                imageView.translatesAutoresizingMaskIntoConstraints = false
                
                if index != ((imageListSet?.count)!-1) {
                    imageView.image = convertImageToBW(image: element)
                }
                
                if index == ((imageListSet?.count)!-1) {
                    let numberView = UIView()
                    numberView.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
                    numberView.alpha = 0.7
                    numberView.layer.borderColor = UIColor.white.cgColor
                    numberView.layer.borderWidth = 1
                    numberView.layer.cornerRadius = 15
                    
                    view.addSubview(numberView)
                    numberView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10).isActive = true
                    numberView.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: -10).isActive = true
                    numberView.widthAnchor.constraint(equalToConstant: 30).isActive = true
                    numberView.heightAnchor.constraint(equalToConstant: 30).isActive = true
                    numberView.translatesAutoresizingMaskIntoConstraints = false
                    
                    let numberLabel = UILabel()
                    numberLabel.text = "\((imageListSet?.count)!)"
                    numberLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
                    numberLabel.textColor = UIColor.white
                    view.addSubview(numberLabel)
                    numberLabel.centerXAnchor.constraint(equalTo: numberView.centerXAnchor).isActive = true
                    numberLabel.centerYAnchor.constraint(equalTo: numberView.centerYAnchor).isActive = true
                    numberLabel.translatesAutoresizingMaskIntoConstraints = false
                }
                
            }
            
        }
    }
    
    var folder : FolderSelectionViewController?
    var folderHeightConstraint : NSLayoutConstraint?
    var folderBottomConstraint : NSLayoutConstraint?

    var folderHeight : CGFloat = 0
    var tagViewHeight : CGFloat = 0
    var folderSelectViewHeight : CGFloat = 0
    var isFolderOn : Bool = false

    func setupFolderView() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
//        view.addGestureRecognizer(tap)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        folder = FolderSelectionViewController(collectionViewLayout: layout)
        folder?.delegate = self
        let cellWidth = view.frame.width / 3.5
        
        folder?.cellSize = cellWidth
        
        tagViewHeight = (marginBase*2) + 18 + marginBase + (folder?.viewAllButtonSize)! + (marginBase*2)
        folderSelectViewHeight = (marginBase*2) + 18 + (marginBase*2) + cellWidth + (marginBase) + (folder?.viewAllButtonSize)! + (marginBase*2)
        folderHeight = tagViewHeight + folderSelectViewHeight
//        folder?.view.frame = CGRect(x: 0, y: view.frame.height - folderHeight, width: view.frame.width, height: folderHeight)
        let folderView = (folder?.view)!
        let path = UIBezierPath(roundedRect:folderView.bounds, byRoundingCorners:[.topLeft, .topRight], cornerRadii: CGSize(width: 20, height:  20))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath

        folderView.layer.mask = maskLayer
        
        self.addChild(folder!)
        view.addSubview(folderView)
        folderView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        folderBottomConstraint = NSLayoutConstraint(item: folderView, attribute: .bottom, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        folderHeightConstraint = NSLayoutConstraint(item: folderView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: folderHeight)
        folderView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([folderHeightConstraint!, folderBottomConstraint!])

        folder?.cancelbutton?.addTarget(self, action: #selector(endEditing), for: .touchUpInside)
        folder?.tagField?.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == folder?.tagField {
            if textField.text?.last == "#" {
                let text = textField.text
                
                if let text = text {
                    if text.count > 2{
                        let range = text.index((text.endIndex), offsetBy: -2)..<(text.endIndex)
                        textField.text?.removeSubrange(range)

                    }
                }
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
    
    @objc func endEditing() {
        folderHeightConstraint?.constant = folderHeight
        isFolderOn = false
        view.endEditing(true)
        UIView.animate(withDuration: keyBoardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
}

extension ImageFolderSaveViewController : FolderSelectDelegate {
    
    func folderSelected(sender: HistoryDataModel) {
       
        do{
            let params = [
                "uniqueId": JoinUserInfo.getInstance.uniqueId,
                "folderName": (sender.folderName?.trimmingCharacters(in: .whitespaces)) ?? "",
                "hashTags" : sender.hashTagArray ?? ""
            ] as [String:Any]
            
            if let imageList = self.imageListSet{
                let request = try createImageUploadRequest(url: RestApi.addNoteImage, parameters: params, images: imageList)
                URLSession(configuration: .default).dataTask(with: request){(data, response, error) in
                    if data == nil {
                        return
                    }
                    
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                        guard let images = json["images"] as? [[String:Any]] else { return }
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
                            self.delegate?.saveIntoFolder(sender: sender)
                            self.delegate?.dismissView()
                            
                        }
                        
                    }catch{
                        print(error)
                    }
                    }.resume()
            }
            
            
            
        }catch{
            print(error)
        }
        
        
    }
    
    func deleteContents(data: HistoryDataModel){}
    
}
