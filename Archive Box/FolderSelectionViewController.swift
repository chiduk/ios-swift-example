//
//  FolderSelectionViewController.swift
//  BuxBox
//
//  Created by SongChiduk on 11/03/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

protocol FolderSelectDelegate : class {
    func folderSelected(sender: HistoryDataModel)
    func deleteContents(data: HistoryDataModel)
}

class FolderSelectionViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout, SaveIntoFolderDelegate, UITextFieldDelegate {
    
    
    var folderListArray = [HistoryDataModel]()
    var folders = [HistoryDataModel]()
    var loadData = false
    var skipFolderId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.hexStringToUIColor(hex: "#E8E8E8")
//        collectionView.delegate = self
//        collectionView.dataSource = self
        setupView()
        setupCollectionView()
        
        getFolders()
    }
    
    deinit {
        print("FolderSelectionViewController denit successful")
    }
    
    weak var delegate : FolderSelectDelegate?
    
    weak var refreshDelegate: RefreshDelegate?
    
    var tagView : UIView?
    var tagLabel : UILabel?
    var tagFieldView : UIView?
    var tagField : UITextField?
    

    let viewAllButton = UIButton()
    let viewAllButtonSize : CGFloat = 44
    
    let addFolderButton = UIButton()
    
    let selectFolderLabel : UILabel = {
        let label = UILabel()
        label.text = "폴더선택"
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        label.textColor = .black
        return label
    }()
    
    var collectionViewBackGround : UIView?
    func setupView() {
        let tagViewHeight = (marginBase*2) + 18 + marginBase + viewAllButtonSize + (marginBase*2)
        tagView = UIView()
        tagView?.backgroundColor = .white
        view.addSubview(tagView!)
        tagView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tagView?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tagView?.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tagView?.heightAnchor.constraint(equalToConstant: tagViewHeight).isActive = true
        tagView?.translatesAutoresizingMaskIntoConstraints = false
        
        tagLabel = UILabel()
        tagLabel?.text = "태그추가"
        tagLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        tagLabel?.textColor = .black
        
        view.addSubview(tagLabel!)
        tagLabel?.topAnchor.constraint(equalTo: (tagView?.topAnchor)!, constant: marginBase*2).isActive = true
        tagLabel?.leftAnchor.constraint(equalTo: (tagView?.leftAnchor)!, constant: marginBase*2).isActive = true
        tagLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        
        tagFieldView = UIView()
        tagFieldView?.backgroundColor = Color.hexStringToUIColor(hex: "#D5D3D3")
        view.addSubview(tagFieldView!)
        tagFieldView?.topAnchor.constraint(equalTo: (tagLabel?.bottomAnchor)!, constant: marginBase).isActive = true
        tagFieldView?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
        tagFieldView?.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -(marginBase*2)).isActive = true
        tagFieldView?.heightAnchor.constraint(equalToConstant: viewAllButtonSize).isActive = true
        tagFieldView?.translatesAutoresizingMaskIntoConstraints = false
        
        
        tagField = UITextField()
        tagField?.placeholder = "#"
        tagField?.delegate = self
        tagField?.clearButtonMode = .whileEditing
        tagField?.textColor = .black
        tagField?.autocorrectionType = .no
        tagField?.returnKeyType = .continue
        tagField?.font = UIFont(name: "HelveticaNeue", size: 18)
        tagFieldView?.addSubview(tagField!)
        tagField?.centerYAnchor.constraint(equalTo: (tagFieldView?.centerYAnchor)!, constant: 0).isActive = true
        tagField?.leftAnchor.constraint(equalTo: (tagFieldView?.leftAnchor)!, constant: marginBase).isActive = true
        tagField?.rightAnchor.constraint(equalTo: (tagFieldView?.rightAnchor)!, constant: -marginBase).isActive = true
        tagField?.heightAnchor.constraint(equalToConstant: viewAllButtonSize).isActive = true
        tagField?.translatesAutoresizingMaskIntoConstraints = false
        
        
        collectionViewBackGround = UIView()
        collectionViewBackGround?.backgroundColor = Color.hexStringToUIColor(hex: "#E8E8E8")
        view.addSubview(collectionViewBackGround!)
        collectionViewBackGround?.topAnchor.constraint(equalTo: (tagView?.bottomAnchor)!).isActive = true
        collectionViewBackGround?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        collectionViewBackGround?.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        collectionViewBackGround?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        collectionViewBackGround?.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(selectFolderLabel)
        selectFolderLabel.topAnchor.constraint(equalTo: (tagView?.bottomAnchor)!, constant: marginBase*2).isActive = true
        selectFolderLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
        selectFolderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        addFolderButton.setImage(UIImage(named: "folderAddIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        addFolderButton.tintColor = .black
        addFolderButton.addTarget(self, action: #selector(presentAddFolderView), for: .touchUpInside)
        
        view.addSubview(addFolderButton)
        addFolderButton.centerYAnchor.constraint(equalTo: selectFolderLabel.centerYAnchor, constant: 0).isActive = true
        addFolderButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -marginBase*2).isActive = true
        addFolderButton.widthAnchor.constraint(equalToConstant: viewAllButtonSize).isActive = true
        addFolderButton.heightAnchor.constraint(equalToConstant: viewAllButtonSize).isActive = true
        addFolderButton.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.frame.size.width{
            if loadData{
                loadData = false
                getFolders()
            }
        }
    }
    
    func getFolders(){
        let params = [
            "uniqueId" : JoinUserInfo.getInstance.uniqueId,
            "skip" : (self.folderListArray.count == 0) ? 0.description : ( self.folders.count - 1 ).description
        ].stringFromHttpParameters()
        
        let request = URLRequest(url: URL(string: RestApi.getFolders + "?" + params)!)
        URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
            self?.loadData = true
            
            if data == nil {
                return
            }
            
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String:Any]]
                let folders = Mapper<HistoryDataModel>().mapArray(JSONArray: json)
                
                if folders.count == 0 {
                    return
                }
                
                for folder in folders{
                    if let folderId = folder.folderID{
                        if folderId == self?.skipFolderId{
                            print(folderId)
                        }else{
                            self?.folderListArray.append(folder)
                        }
                    }
                }
                
                self?.folders += folders
                
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }catch{
                print(error)
            }
        }.resume()
    }
    
    @objc func presentAddFolderView() {
        let vc = CreateFolderTextViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        let nv = UINavigationController(rootViewController: vc)
        present(nv, animated: true, completion: nil)
    }
    
    var cancelbutton : UIButton?
    func setupCollectionView() {
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Color.hexStringToUIColor(hex: "#E8E8E8")
        collectionView.register(FolderSelectCell.self, forCellWithReuseIdentifier: "FolderSelectCell")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: marginBase*2, bottom: 0, right: marginBase*2)
        
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: selectFolderLabel.bottomAnchor, constant: marginBase*2).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: cellSize).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.reloadData()
        
        viewAllButton.setImage(UIImage(named: "fourSquares"), for: .normal)
        viewAllButton.setTitle("  전체보기", for: .normal)
        viewAllButton.setTitleColor(UIColor.black, for: .normal)
        viewAllButton.tintColor = .black
        viewAllButton.contentHorizontalAlignment = .left
        viewAllButton.addTarget(self, action: #selector(viewAllFolders), for: .touchUpInside)
        
        let width = (viewAllButton.titleLabel?.intrinsicContentSize.width)! + viewAllButtonSize + marginBase*2
        view.addSubview(viewAllButton)
        viewAllButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: marginBase).isActive = true
        viewAllButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
        viewAllButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        viewAllButton.heightAnchor.constraint(equalToConstant: viewAllButtonSize).isActive = true
        viewAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        cancelbutton = UIButton()
        cancelbutton?.setTitle("취소", for: .normal)
        cancelbutton?.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        cancelbutton?.setTitleColor(Color.hexStringToUIColor(hex: "#FFA00A"), for: .normal)
        view.addSubview(cancelbutton!)
        cancelbutton?.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: marginBase).isActive = true
        cancelbutton?.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -marginBase*2).isActive = true
        cancelbutton?.widthAnchor.constraint(equalToConstant: (cancelbutton?.titleLabel?.intrinsicContentSize.width)!+(marginBase*2)).isActive = true
        cancelbutton?.heightAnchor.constraint(equalToConstant: viewAllButtonSize).isActive = true
        cancelbutton?.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folderListArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = folderListArray[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderSelectCell", for: indexPath) as?
FolderSelectCell
        cell!.layer.cornerRadius = 20
        cell?.layer.borderColor = UIColor.black.cgColor
        cell?.layer.borderWidth = 1
        
        cell?.titleSet = data.folderName
        if indexPath.item == 0 {
            cell?.backgroundColor = UIColor.black
            cell?.titleLabel?.textColor = UIColor.white
        } else {
            cell?.backgroundColor = UIColor.white
            cell?.titleLabel?.textColor = UIColor.black
        }
        
        return cell!
    }
    
    var cellSize : CGFloat = 0
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = folderListArray[indexPath.item]
       
        saveIntoAFolder(data: data)

    }
    
    @objc func viewAllFolders(){
        let vc = FolderViewController(collectionViewLayout: UICollectionViewFlowLayout())
        vc.folderSelectedDelegate = self
        vc.isForFolderSelecting = true
        vc.refreshDelegate = self
        let nc = UINavigationController(rootViewController: vc)
        self.present(nc, animated: true, completion: nil)
    }
    
    func saveIntoAFolder(data: HistoryDataModel) {
        if tagField?.text != nil || tagField?.text != "" {
            data.hashTagArray = tagField?.text?.components(separatedBy: [" ", "#"])
            
            if let hashTags = data.hashTagArray{
                let filteredTags = hashTags.filter{$0 != ""}
                data.hashTagArray = filteredTags
            }
        }
        delegate?.folderSelected(sender: data)
    }
    
}

extension FolderSelectionViewController: FolderSelectDelegate {
    func folderSelected(sender: HistoryDataModel) {
        self.saveIntoAFolder(data: sender)
    }
    
    func deleteContents(data: HistoryDataModel) {
        
    }
    
    
}

extension FolderSelectionViewController: RefreshDelegate {
    func refresh(index: Int) {
        
    }
    
    func refresh(actions: [RefreshAction]) {
        
    }
    
    func refresh(folderId: String) {
        self.refreshDelegate?.refresh(folderId: folderId)
    }
    
    func refresh(folderId: String, folderName: String) {
        
    }
    
    
}


class FolderSelectCell : UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    var titleLabel : UILabel?
    var titleSet : String? {
        didSet{
            titleLabel?.removeFromSuperview()
            titleLabel = UILabel()
            titleLabel?.text = titleSet
            titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
            titleLabel?.numberOfLines = 3
            titleLabel?.lineBreakMode = .byWordWrapping
            
            contentView.addSubview(titleLabel!)
            titleLabel?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            titleLabel?.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: marginBase).isActive = true
            titleLabel?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -marginBase).isActive = true
            titleLabel?.translatesAutoresizingMaskIntoConstraints = false
            
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

struct InputType: OptionSet {
    let rawValue: Int
    
    static let image = InputType(rawValue: 1 << 0)
    static let text = InputType(rawValue: 1 << 1)
   
}

    //MARK: SEARCH TEXT COLOR CHANGE
    var searchText : [String]?
    
