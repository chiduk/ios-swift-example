//
//  FolderViewController.swift
//  BuxBox
//
//  Created by SongChiduk on 07/02/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class FolderViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    var loadData = false
    var refreshActions = [RefreshAction]()
    weak var refreshDelegate : RefreshDelegate?
    weak var folderSelectedDelegate: FolderSelectDelegate?
    var isForFolderSelecting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = Color.hexStringToUIColor(hex: "#212121")
        navigationController?.navigationBar.isTranslucent = false
        collectionView.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
        setupLeftSideButton()
        getFolders()
        setupCollectionView()
        
        self.collectionView.alwaysBounceVertical = true
    }
    
    deinit {
        print("FolderViewController deinit successful")
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height{
            
            if loadData {
                loadData = false
                getFolders()
            }
        }
    }
    
    
    func setupLeftSideButton() {
        
  
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 44)
        menuBtn.setImage(UIImage(named:"closeXIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        menuBtn.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        menuBtn.tintColor = .white
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 50)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
        
        
        navigationItem.title = "폴더"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    @objc func dismissView() {
        
        refreshDelegate?.refresh(actions: refreshActions)
        self.dismiss(animated: true) {
            
        }
    }
    
    var folderData = [FolderModel]()
    
    var defaultData : [FolderModel] = [
        FolderModel(id: "addFolder", imageName: "folderAdd", name: "새폴더", numberOfShared: 0, locked: false, addFolder : true)
        
    ]
    
    func getFolders(){
        let params = [
            "uniqueId" : JoinUserInfo.getInstance.uniqueId,
            "skip" : (self.folderData.count == 0) ? 0.description : (self.folderData.count - 1).description
            ].stringFromHttpParameters()
        
        let request = URLRequest(url: URL(string: RestApi.getFolders + "?" + params)!)
        URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
            self?.loadData = true
            
            if data == nil {
                return
            }
            
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [[String:Any]]
                let folders = Mapper<FolderModel>().mapArray(JSONArray: json)
                
                if folders.count == 0 {
                    return
                }
                
                self?.folderData += folders
                self?.defaultData += folders
                
                DispatchQueue.main.async {
                    
                    if let deleteModOn = self?.isOnDeleteMode {
                        if deleteModOn {
                            if let folderData = self?.folderData{
                                for folder in folderData{
                                    
                                    if let isDefaultFolder = folder.folderName?.localizedCaseInsensitiveContains("default"){
                                        if !isDefaultFolder{
                                            folder.isOnDeleteMode = false
                                        }
                                    }
                                    
                                    
                                }
                            }
                            
                        }
                    }
                    
                    
                    
                    self?.collectionView.reloadData()
                }
            }catch{
                print(error)
            }
            }.resume()
    }
    
    var lpgr : UILongPressGestureRecognizer?
    var tapGesture : UITapGestureRecognizer?
    func setupCollectionView() {
        collectionView.register(FolderCell.self, forCellWithReuseIdentifier: "FolderCell")
        lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        lpgr?.minimumPressDuration = 1
        lpgr?.delaysTouchesBegan = false
        lpgr?.delegate = self
        self.collectionView.addGestureRecognizer(lpgr!)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteModeEnd))
        tapGesture?.isEnabled = false
        self.collectionView.addGestureRecognizer(tapGesture!)
        
    }
    @objc func deleteModeEnd() {
        tapGesture?.isEnabled = false
        lpgr?.isEnabled = true
        startDeleteMode()
        isOnDeleteMode = false
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        
        switch gestureReconizer.state {
        case .changed:
            isOnDeleteMode = true
            tapGesture?.isEnabled = true
            startDeleteMode()
            gestureReconizer.isEnabled = false
            
            break
        default:
            break
        }
    }
    
    func startDeleteMode() {
        if isOnDeleteMode  {
            for i in folderData {
                if i.folderName != "새폴더" && i.folderName != "default" {
                    i.isOnDeleteMode = !i.isOnDeleteMode
                }
            }
            collectionView.reloadData()
        }
    }
    
    @objc func deleteCell(sender: CloseButton) {
        let alert = UIAlertController(title:"삭제 하시겠습니까?", message: "삭제된 파일은 복원되지 않습니다.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "네", style: .destructive, handler:{[weak self](action: UIAlertAction!) in
          
            
            guard let folderId = sender.id else { return }
            
           
            
            let params = [
                "uniqueId" : JoinUserInfo.getInstance.uniqueId,
                "folderId": folderId
            ] as [String:Any]
            
            do{
                let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
                var request = URLRequest(url: URL(string: RestApi.deleteFolder)!)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                request.httpBody = jsonParams
                
                URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
                    guard let httpResponse = response as? HTTPURLResponse else {return}
                    
                    if httpResponse.statusCode == 200 {
                        DispatchQueue.main.async {
                            let index = self?.defaultData.index(where: {$0.folderID == folderId})
                            self?.defaultData.removeAll(where: {$0.folderID == folderId})
                            self?.folderData.removeAll(where: {$0.folderID == folderId})
                            self?.collectionView.performBatchUpdates({
                                guard let index = index else { return}
                                self?.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                            }) { (bool) in
                                if bool == true {
                                    self?.refreshDelegate?.refresh(folderId: folderId)
                                    self?.collectionView.reloadData()
                                }
                            }
                        }
                        
                    }
                }.resume()
            }catch{
                print(error)
            }
            
            
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "아니요", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return defaultData.count
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = defaultData[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCell", for: indexPath) as! FolderCell
        
        if let folderImage = data.folderImage{
            cell.folderImageSet = folderImage
        }else{
              cell.folderImageSet = "folderIcon"
        }
        
      
        cell.folderNameSet = data.folderName
        cell.deleteButtonSet = data.isOnDeleteMode
        cell.deleteButton?.addTarget(self, action: #selector(deleteCell), for: .touchUpInside)
        cell.deleteButton?.id = data.folderID
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = FolderCell()
        let width = (view.frame.width / 3)-marginBase
        let imageWidth = width - (marginBase*4)
        let imageHeight = imageWidth * 0.7
        let textHeight = (cell.folderNameFont?.pointSize)! + marginBase*2
        let totalHeight = imageHeight + textHeight
        return CGSize(width: width, height: totalHeight)
    }
    
    var isOnDeleteMode : Bool = false
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isForFolderSelecting{
            
            if indexPath.item == 0 {
                let vc = CreateFolderTextViewController()
                vc.delegate = self
                vc.modalPresentationStyle = .fullScreen
                let nv = UINavigationController(rootViewController: vc)
                present(nv, animated: true, completion: nil)
            } else {
                let data = defaultData[indexPath.item]
                let model = HistoryDataModel()
                model.folderID = data.folderID
                model.folderName = data.folderName
                
                folderSelectedDelegate?.folderSelected(sender: model)
                self.dismissView()
            }

        }else{
            if indexPath.item == 0 {
                let vc = CreateFolderTextViewController()
                vc.delegate = self
                vc.modalPresentationStyle = .fullScreen
                let nv = UINavigationController(rootViewController: vc)
                present(nv, animated: true, completion: nil)
            } else {
                let data = defaultData[indexPath.item]
                
                if isOnDeleteMode == false {
                    pushToDetailView(data: data)
                }
            }
        }
        
       
    }
    
    func pushToDetailView(data : FolderModel) {
      
        let vc = FolderDetailViewController()
        vc.folderTitle = data.folderName
        vc.folderID = data.folderID
        vc.folderViewController = self
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
//    func saveIntoAFolder(data: HistoryDataModel) {
//        let savingData = FolderModel(id: data.folderID, imageName: "folderIcon", name: data.folderName)
//        defaultData.append(savingData)
//        collectionView.reloadData()
//    }
    
}

extension FolderViewController: SaveIntoFolderDelegate {
    func saveIntoAFolder(data: HistoryDataModel) {
        print(data)
        
        guard let folderName = data.folderName else {
            return
        }
        let params = [
            "uniqueId": JoinUserInfo.getInstance.uniqueId,
            "folderName" : folderName
        ]
        
        do{
            let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
            var request = URLRequest(url: URL(string: RestApi.createFolder)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonParams
            
            URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
                guard let data = data else { return }
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]
                    guard let result = json else { return }
                    
                    let folder = Mapper<FolderModel>().map(JSON: result)
                    guard let newFolder = folder else { return }
                    DispatchQueue.main.async {
                        self?.defaultData.insert(newFolder, at: 2)
                        self?.folderData.insert(newFolder, at: 1)
                        
                        self?.collectionView.reloadData()
                        
                        if let isForFolderSelecting = self?.isForFolderSelecting{
                            if isForFolderSelecting {
                                let model = HistoryDataModel()
                                model.folderID = newFolder.folderID
                                model.folderName = newFolder.folderName
                                self?.folderSelectedDelegate?.folderSelected(sender: model)
                                self?.dismissView()
                            }
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
    
   
    
    
}

class FolderCell : UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var imageView : UIImageView?
    var folderImageSet : String? {
        didSet {
            
            imageView?.removeFromSuperview()
            imageView = UIImageView()
            
            if let image = folderImageSet{
                imageView?.image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate)
            }
            
            
            imageView?.tintColor = .white
            imageView?.contentMode = .scaleAspectFit
            imageView?.clipsToBounds = true
            
            let width : CGFloat = contentView.frame.width-(marginBase*7)
            
            contentView.addSubview(imageView!)
            imageView?.topAnchor.constraint(equalTo: contentView.topAnchor, constant: marginBase*2).isActive = true
            imageView?.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            imageView?.widthAnchor.constraint(equalToConstant: width).isActive = true
            imageView?.heightAnchor.constraint(equalToConstant: width).isActive = true
            imageView?.translatesAutoresizingMaskIntoConstraints = false
            
        }
    }
    
    let folderNameFont = UIFont(name: "HelveticaNeue", size: 16)
    var folderName : UILabel?
    var folderNameSet : String? {
        didSet {
            folderName?.removeFromSuperview()
            folderName = UILabel()
            folderName?.textAlignment = .center
            folderName?.font = folderNameFont
            folderName?.numberOfLines = 2
            if let data = folderNameSet {
                folderName?.text = data
            } else {
                folderName?.text = ""
            }
            folderName?.textColor = .white
            
            contentView.addSubview(folderName!)
            folderName?.topAnchor.constraint(equalTo: (imageView?.bottomAnchor)!, constant: marginBase).isActive = true
            folderName?.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
            folderName?.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
            folderName?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    var deleteButton : CloseButton?
    var deleteButtonSet : Bool? {
        didSet {
            deleteButton?.removeFromSuperview()
            deleteButton = CloseButton()
            deleteButton?.setImage(UIImage(named: "deleteXIcon"), for: .normal)
            deleteButton?.imageView?.contentMode = .scaleAspectFill
            deleteButton?.imageView?.clipsToBounds = true
            deleteButton?.isHidden = deleteButtonSet!
            
            contentView.addSubview(deleteButton!)
            deleteButton?.topAnchor.constraint(equalTo: (imageView?.topAnchor)!).isActive = true
            deleteButton?.centerXAnchor.constraint(equalTo: (imageView?.leftAnchor)!).isActive = true
            deleteButton?.widthAnchor.constraint(equalToConstant: 30).isActive = true
            deleteButton?.heightAnchor.constraint(equalToConstant: 30).isActive = true
            deleteButton?.translatesAutoresizingMaskIntoConstraints = false
            
        }
    }
    
    
}

