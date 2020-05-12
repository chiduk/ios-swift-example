//
//  TextSelectViewController.swift
//  BuxBox
//
//  Created by SongChiduk on 24/01/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit


class SelectAndCropViewController : UIViewController, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        setupNavBar()
        view.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
        setupView()
    }
    
    deinit {
        print("SelectAndCropViewController denit successful")
    }
    
    weak var delegate : AddphotoDelegate?
    var topView : UIView!
    var backButton : UIButton!
    var nextButton : UIButton!
    func setupNavBar() {
        
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
        
        
        backButton = UIButton()
        backButton.setImage(UIImage(named: "backArrow")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.tintColor = UIColor.white
        backButton.addTarget(self, action: #selector(backView), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: marginBase*2).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: height-marginBase).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: height-marginBase).isActive = true
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        nextButton = UIButton()
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(UIColor.gray, for: .disabled)
        nextButton.setTitleColor(Color.hexStringToUIColor(hex: "#FFBF2E"), for: .normal)
        nextButton.isEnabled = true
        nextButton.addTarget(self, action: #selector(nextView), for: .touchUpInside)
        view.addSubview(nextButton)
        nextButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        nextButton.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -marginBase*2).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: (nextButton.titleLabel?.intrinsicContentSize.width)! + marginBase*2).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: height-marginBase).isActive = true
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    @objc func backView() {
        delegate?.goBack(pageNumber: 0, direction: .reverse)
    }
    
    @objc func nextView() {
        delegate?.goTo(pageNumber: 2, direction: .forward)
    }
    
    
    //
    //    @objc func imageFolderSelectView() {
    //        let vc = ImageFolderSaveViewController()
    //        vc.imageListSet = imageArray
    //        navigationController?.pushViewController(vc, animated: true)
    //    }
    //
    //    let saveAsTextButton : UIButton = {
    //        let s = UIButton()
    //        s.setTitle("Save As Text", for: .normal)
    //        s.setTitleColor(buxboxthemeColor, for: .normal)
    //        s.addTarget(self, action: #selector(saveAsText), for: .touchUpInside)
    //       return s
    //    }()
    
    let testTextForExhibit = UILabel()
    
    //    @objc func saveAsText() {
    //
    //
    //
    //    }
    weak var photoLibarary : PhotoLibraryController?
    lazy var photoCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let p = UICollectionView(frame: .zero, collectionViewLayout: layout)
        p.dataSource = self
        p.delegate = self
        return p
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count ?? 0
    }
    
    var cell : CropImageCollectionViewCell?
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = imageArray[indexPath.item]
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CropImageCollectionViewCell", for: indexPath) as? CropImageCollectionViewCell
        cell?.imageSet = data
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    var imageArray : [UIImage] = []
    
    var scrollView : UIScrollView?
    let buttonHeight : CGFloat = 44
    var buttonView : UIView!
    var garbageCan : UIButton!
    func setupView() {
        let imageSize : CGFloat = view.frame.width
        photoCollectionView.register(CropImageCollectionViewCell.self, forCellWithReuseIdentifier: "CropImageCollectionViewCell")
        photoCollectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
        photoCollectionView.isPagingEnabled = true
        view.addSubview(photoCollectionView)
        photoCollectionView.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        photoCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        photoCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        photoCollectionView.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        photoCollectionView.reloadData()
        
        //        scrollView = UIScrollView()
        //        scrollView?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: imageSize)
        //        scrollView?.contentSize = CGSize(width: imageSize*CGFloat(imageArray.count), height:imageSize)
        //
        //        scrollView?.delegate = self
        //
        //        scrollView?.isPagingEnabled = true
        //        view.addSubview(scrollView!)
        //        scrollView?.topAnchor.constraint(equalTo: topView.bottomAnchor).isActive = true
        //        scrollView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        //        scrollView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        //        scrollView?.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
        //        scrollView?.translatesAutoresizingMaskIntoConstraints = false
        //
        //        setupImageInsideScrollView()
        
        
        pager = UIPageControl()
        pager?.currentPage = 0
        pager?.numberOfPages = imageArray.count
        pager?.currentPageIndicatorTintColor = Color.hexStringToUIColor(hex: "#FFBF2E")
        
        view.addSubview(pager!)
        pager?.topAnchor.constraint(equalTo: (photoCollectionView.bottomAnchor), constant: marginBase).isActive = true
        pager?.centerXAnchor.constraint(equalTo: (photoCollectionView.centerXAnchor)).isActive = true
        pager?.heightAnchor.constraint(equalToConstant: 16).isActive = true
        pager?.translatesAutoresizingMaskIntoConstraints = false
        
        buttonView = UIView()
        buttonView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: buttonHeight + marginBase*4)
        buttonView.backgroundColor = UIColor.black
        view.addSubview(buttonView)
        buttonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -marginBase*2).isActive = true
        buttonView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        buttonView.heightAnchor.constraint(equalToConstant: buttonHeight + marginBase*4).isActive = true
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        
        let cropButton = UIButton()
        cropButton.setImage(UIImage(named: "cropIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        cropButton.tintColor = UIColor.white
        cropButton.addTarget(self, action: #selector(startCrop), for: .touchUpInside)
        
        buttonView.addSubview(cropButton)
        cropButton.centerYAnchor.constraint(equalTo: (buttonView?.centerYAnchor)!).isActive = true
        cropButton.leftAnchor.constraint(equalTo: (buttonView?.leftAnchor)!, constant: marginBase*4).isActive = true
        cropButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        cropButton.widthAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        cropButton.translatesAutoresizingMaskIntoConstraints = false
        
        garbageCan = UIButton()
        garbageCan.setImage(UIImage(named: "garbageCan")?.withRenderingMode(.alwaysTemplate), for: .normal)
        garbageCan.imageView?.contentMode = .scaleAspectFit
        garbageCan.tintColor = UIColor.white
        garbageCan.addTarget(self, action: #selector(deletePhoto), for: .touchUpInside)
        
        buttonView.addSubview(garbageCan)
        garbageCan.centerYAnchor.constraint(equalTo: (buttonView?.centerYAnchor)!).isActive = true
        garbageCan.rightAnchor.constraint(equalTo: (buttonView?.rightAnchor)!, constant: -marginBase*4).isActive = true
        garbageCan.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        garbageCan.widthAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        garbageCan.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func deletePhoto() {
        if imageArray.count == 1 {
            imageArray.removeAll()
            photoCollectionView.reloadData()
            //            reloadView()
            backView()
        } else {
            let visibleRect = CGRect(origin: photoCollectionView.contentOffset, size: photoCollectionView.bounds.size)
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            let index = photoCollectionView.indexPathForItem(at: visiblePoint)
            //            let index = round((photoCollectionView.contentOffset) / (scrollView?.frame.width)!)
            imageArray.remove(at: (index?.item)!)
            photoCollectionView.performBatchUpdates({
                photoCollectionView.deleteItems(at: [index!])
            }) { (bool) in
                if bool == true {
                    self.photoCollectionView.reloadData()
                }
            }
            pager?.numberOfPages = imageArray.count
            //            reloadView()
        }
        
    }
    //MARK : SETUP CROP VIEW
    var leftTopPan : UIPanGestureRecognizer!
    var cropview : CropView?
    @objc func startCrop() {
        buttonView.isHidden = true
        print("start crop")
        let visibleRect = CGRect(origin: photoCollectionView.contentOffset, size: photoCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let index = photoCollectionView.indexPathForItem(at: visiblePoint)
        
        //        let index = round((scrollView?.contentOffset.x)! / (scrollView?.frame.width)!)
        let image = imageArray[(index?.item)!]
        cropview = CropView(frame: photoCollectionView.frame)
        cropview?.imageSelectView = self
        
        //        cropview?.frame = photoCollectionView.bounds
        cropview?.imageSet = image
        view.addSubview(cropview!)
        cropview?.imageView.isUserInteractionEnabled = true
        cropview?.leftTop.isUserInteractionEnabled = true
        cropview?.leftBottom.isUserInteractionEnabled = true
        cropview?.rightTop.isUserInteractionEnabled = true
        cropview?.rightBottom.isUserInteractionEnabled = true
        setupDoneButton()
    }
    
    
    var doneCrop : UIButton?
    var cancel : UIButton?
    var doneWidth : NSLayoutConstraint?
    var cancelWidth : NSLayoutConstraint?
    func setupDoneButton() {
        pager?.isHidden = true
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        doneCrop = UIButton()
        doneCrop?.setTitle("Finish Cropping", for: .normal)
        doneCrop?.tintColor = Color.hexStringToUIColor(hex: "#FFBF2E")
        doneCrop?.addTarget(self, action: #selector(doneCropPressed), for: .touchUpInside)
        doneCrop?.setTitleColor(Color.hexStringToUIColor(hex: "#FFBF2E"), for: .normal)
        
        let buttonHeight = (doneCrop?.titleLabel?.intrinsicContentSize.height)! + marginBase
        view.addSubview(doneCrop!)
        doneCrop?.topAnchor.constraint(equalTo: (cropview?.bottomAnchor)!, constant: marginBase).isActive = true
        doneCrop?.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -marginBase*2).isActive = true
        
        doneWidth = NSLayoutConstraint(item: doneCrop, attribute: .width, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: (doneCrop?.titleLabel?.intrinsicContentSize.width)!)
        doneCrop?.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        doneCrop?.translatesAutoresizingMaskIntoConstraints = false
        doneCrop?.layer.cornerRadius = buttonHeight / 2
        view.addConstraint(doneWidth!)
        
        cancel = UIButton()
        cancel?.setTitle("Cancel", for: .normal)
        cancel?.tintColor = Color.hexStringToUIColor(hex: "#FFBF2E")
        cancel?.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        cancel?.setTitleColor(UIColor.white, for: .normal)
        
        let cancelHeight = (cancel?.titleLabel?.intrinsicContentSize.height)! + marginBase
        view.addSubview(cancel!)
        cancel?.topAnchor.constraint(equalTo: (cropview?.bottomAnchor)!, constant: marginBase).isActive = true
        cancel?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
        
        cancelWidth = NSLayoutConstraint(item: cancel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: (cancel?.titleLabel?.intrinsicContentSize.width)!)
        cancel?.heightAnchor.constraint(equalToConstant: cancelHeight).isActive = true
        cancel?.translatesAutoresizingMaskIntoConstraints = false
        cancel?.layer.cornerRadius = cancelHeight / 2
        view.addConstraint(cancelWidth!)
    }
    
    
    @objc func doneCropPressed() {
        if doneCrop?.titleLabel?.text == "Finish Cropping" {
            
            cropview?.finishCropPressed()
            
        } else {
            imageArray[scrollIndex] = (cropview?.imageView.image)!
            //            scrollView?.setNeedsDisplay()
            photoCollectionView.performBatchUpdates({
                photoCollectionView.reloadItems(at: [IndexPath(item: scrollIndex, section: 0)])
            }) { (bool) in
                if bool == true {
                    self.photoCollectionView.reloadData()
                }
            }
            
            hideCropView()
            //            reloadView()
            //            scrollView?.scrollRectToVisible(CGRect(x: view.frame.width*CGFloat(scrollIndex), y: 0, width: view.frame.width, height: view.frame.width), animated: false)
        }
        buttonView.isHidden = false
    }
    
    
    @objc func cancelPressed() {
        if cancel?.titleLabel?.text == "Cancel" {
            hideCropView()
        } else {
            cropview?.imageView.image = imageArray[scrollIndex]
            cropview?.toggleCropViewView()
            cancel?.setTitle("Cancel", for: .normal)
            cancelWidth?.constant = (cancel?.titleLabel?.intrinsicContentSize.width)!
            
            doneCrop?.setTitle("Finish Cropping", for: .normal)
            doneWidth?.constant = (doneCrop?.titleLabel?.intrinsicContentSize.width)!
            navigationItem.rightBarButtonItem?.isEnabled = false
            
        }
        buttonView.isHidden = false
    }
    
    func hideCropView() {
        cropview?.removeFromSuperview()
        doneCrop?.removeFromSuperview()
        cancel?.removeFromSuperview()
        pager?.isHidden = false
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    
    //    func reloadView() {
    //        for i in (scrollView?.subviews)! {
    //            if i.isKind(of: UIImageView.self) {
    //                i.removeFromSuperview()
    //            }
    //        }
    //        setupImageInsideScrollView()
    //    }
    
    //    func setupImageInsideScrollView() {
    //        let imageSize : CGFloat = view.frame.width
    //        scrollView?.contentSize = CGSize(width: imageSize*CGFloat(imageArray.count), height:imageSize)
    //        for i in 0..<(imageArray.count) {
    //            let data = imageArray[i]
    //            let imageView = UIImageView()
    //            imageView.image = data
    //            imageView.contentMode = .scaleAspectFit
    //            imageView.clipsToBounds = true
    //
    //            scrollView?.addSubview(imageView)
    //            imageView.topAnchor.constraint(equalTo: (scrollView?.topAnchor)!).isActive = true
    //            imageView.leadingAnchor.constraint(equalTo: (scrollView?.leadingAnchor)!, constant: imageSize*CGFloat(i)).isActive = true
    //            imageView.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
    //            imageView.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
    //            imageView.translatesAutoresizingMaskIntoConstraints = false
    //        }
    //        pager?.numberOfPages = imageArray.count
    //    }
    //
    
    var scrollIndex : Int = 0
    var pager : UIPageControl?
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        let index = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        let visibleRect = CGRect(origin: photoCollectionView.contentOffset, size: photoCollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let index = photoCollectionView.indexPathForItem(at: visiblePoint) else {return}
        scrollIndex = (index.item)
        pager?.currentPage = (index.item)
    }
    
    //    var hashTagLabel : UILabel?
    //    let hashTagLabelFont = UIFont(name: "HelveticaNeue-Bold", size: 22)
    //    var addHashTadButton = UIButton()
    //    func setupHashTag() {
    //        hashTagLabel?.removeFromSuperview()
    //        hashTagLabel = UILabel()
    //        let text = "#디자인 #문구"
    //        hashTagLabel?.font = hashTagLabelFont
    //        hashTagLabel?.textColor = UIColor.orange
    //
    //        view.addSubview(hashTagLabel!)
    //        hashTagLabel?.topAnchor.constraint(equalTo: (scrollView?.bottomAnchor)!, constant: marginBase*2).isActive = true
    //        hashTagLabel?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
    //        hashTagLabel?.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -(marginBase*2)).isActive = true
    //        hashTagLabel?.translatesAutoresizingMaskIntoConstraints = false
    //
    ////        addHashTadButton.setImage(UIImage(named: "addIconCircle")?.withRenderingMode(.alwaysTemplate), for: .normal)
    ////        addHashTadButton.tintColor = UIColor.lightGray
    ////        addHashTadButton.imageView?.clipsToBounds = true
    ////        addHashTadButton.imageView?.contentMode = .scaleAspectFit
    ////        view.addSubview(addHashTadButton)
    ////        addHashTadButton.centerYAnchor.constraint(equalTo: (hashTagLabel?.centerYAnchor)!).isActive = true
    ////        addHashTadButton.leftAnchor.constraint(equalTo: (hashTagLabel?.rightAnchor)!, constant: marginBase*2).isActive = true
    ////        addHashTadButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    ////        addHashTadButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
    ////        addHashTadButton.translatesAutoresizingMaskIntoConstraints = false
    //
    //        let attachment = NSTextAttachment()
    //        attachment.image = UIImage(named: "addIconCircle")
    //        attachment.bounds = CGRect(x: 0, y: -5, width: 30, height: 30)
    //        let attachmentStr = NSAttributedString(attachment: attachment)
    //        let myString = NSMutableAttributedString(string: "\(text)  ")
    //        myString.append(attachmentStr)
    ////        let myString1 = NSMutableAttributedString(string: "#디자인 #문구")
    ////        myString.append(myString1)
    //        hashTagLabel?.attributedText = myString
    ////        setupFolderSelect()
    //    }
    //    var folderChoiceButton = UIButton()
    //    var folderLabel : UILabel?
    //    var fieldLabelWidth : CGFloat?
    //
    //    let createNew = UIButton()
    //
    //    let saveButton = UIButton()
    //
    //    let memo = UILabel()
    //    let memoButton = UIButton()
    //
    //    func setupFolderSelect() {
    //        folderLabel = UILabel()
    //        folderLabel?.text = "Folder"
    //        folderLabel?.font = hashTagLabelFont
    //        folderLabel?.textColor = UIColor.darkGray
    //        fieldLabelWidth = Text.textWidthForView(text: (folderLabel?.text)!, font: hashTagLabelFont!, height: (hashTagLabelFont?.pointSize)!)
    //
    //        view.addSubview(folderLabel!)
    //        folderLabel?.topAnchor.constraint(equalTo: (hashTagLabel?.bottomAnchor)!, constant: marginBase*2).isActive = true
    //        folderLabel?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
    //        folderLabel?.translatesAutoresizingMaskIntoConstraints = false
    //
    //        folderChoiceButton.backgroundColor = UIColor.lightGray
    //        folderChoiceButton.layer.borderColor = UIColor.darkGray.cgColor
    //        folderChoiceButton.layer.borderWidth = 3
    //        folderChoiceButton.setTitle("Design    ▼", for: .normal)
    //
    //        let fieldWidth = view.frame.width - (marginBase*5) - fieldLabelWidth!
    //
    //        view.addSubview(folderChoiceButton)
    //        folderChoiceButton.centerYAnchor.constraint(equalTo: (folderLabel?.centerYAnchor)!).isActive = true
    //        folderChoiceButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -marginBase*2).isActive = true
    //        folderChoiceButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    //        folderChoiceButton.widthAnchor.constraint(equalToConstant: fieldWidth).isActive = true
    //        folderChoiceButton.translatesAutoresizingMaskIntoConstraints = false
    //
    //        createNew.setTitle("Create New +", for: .normal)
    //        createNew.backgroundColor = UIColor.darkGray
    ////        createNew.layer.borderColor = UIColor.darkGray.cgColor
    ////        createNew.layer.borderWidth = 3
    //        view.addSubview(createNew)
    //        createNew.topAnchor.constraint(equalTo: folderChoiceButton.bottomAnchor, constant: marginBase).isActive = true
    //        createNew.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -marginBase*2).isActive = true
    //        createNew.heightAnchor.constraint(equalToConstant: 40).isActive = true
    //        createNew.widthAnchor.constraint(equalToConstant: fieldWidth).isActive = true
    //        createNew.translatesAutoresizingMaskIntoConstraints = false
    //
    //        memo.text = "memo"
    //        memo.font = hashTagLabelFont
    //        memo.textColor = UIColor.darkGray
    //
    //        view.addSubview(memo)
    //        memo.topAnchor.constraint(equalTo: (createNew.bottomAnchor), constant: marginBase*2).isActive = true
    //        memo.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
    //        memo.translatesAutoresizingMaskIntoConstraints = false
    //
    //        memoButton.backgroundColor = UIColor.lightGray
    //        memoButton.layer.borderColor = UIColor.darkGray.cgColor
    //        memoButton.layer.borderWidth = 3
    //
    //
    //        view.addSubview(memoButton)
    //        memoButton.centerYAnchor.constraint(equalTo: (memo.centerYAnchor)).isActive = true
    //        memoButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -marginBase*2).isActive = true
    //        memoButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    //        memoButton.widthAnchor.constraint(equalToConstant: fieldWidth).isActive = true
    //        memoButton.translatesAutoresizingMaskIntoConstraints = false
    //
    //
    //        saveButton.setTitle("Save", for: .normal)
    //        saveButton.backgroundColor = Color.hexStringToUIColor(hex: "#394F7D")
    //
    //        view.addSubview(saveButton)
    //        saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    //        saveButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    //        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    //        saveButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    //        saveButton.translatesAutoresizingMaskIntoConstraints = false
    //
    //
    //
    //    }
    
    //    func setupMemoField() {
    //
    //    }
    //
    //    func setupConverTextSwitch() {
    //
    //    }
    
    
}

class CropImageCollectionViewCell : UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var backview : UIView?
    var imageView : UIImageView?
    var imageSet : UIImage? {
        didSet {
            backview?.removeFromSuperview()
            backview = UIView()
            contentView.addSubview(backview!)
            backview?.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            backview?.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            backview?.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            backview?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            backview?.translatesAutoresizingMaskIntoConstraints = false
            
            imageView?.removeFromSuperview()
            imageView = UIImageView()
            imageView?.image = imageSet
            imageView?.contentMode = .scaleAspectFit
            imageView?.clipsToBounds = true
            
            backview?.addSubview(imageView!)
            imageView?.centerXAnchor.constraint(equalTo: (backview?.centerXAnchor)!).isActive = true
            imageView?.centerYAnchor.constraint(equalTo: (backview?.centerYAnchor)!).isActive = true
            imageView?.widthAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
            imageView?.heightAnchor.constraint(equalToConstant: contentView.frame.height).isActive = true
            imageView?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
}
