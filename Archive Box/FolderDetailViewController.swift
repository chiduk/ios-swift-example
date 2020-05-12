//
//  FolderDetailViewController.swift
//  BuxBox
//
//  Created by SongChiduk on 09/04/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
class FolderDetailViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, SaveIntoFolderDelegate {
    
    weak var folderViewController: FolderViewController?
    weak var refreshDelegate: RefreshDelegate?
    
    var contentData = [HistoryDataModel]()
    var listIndex = 0;
    var loadData = true
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = Color.hexStringToUIColor(hex: "#212121")
        navigationController?.navigationBar.isTranslucent = false
        tableView.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
        setupLeftSideButton()
        setupTableview()
        setupMoreView()
        
    
        self.tableView.alwaysBounceVertical = true
        
        getFolderContents()
    }
    
    lazy var tableView : UITableView = {
        let t = UITableView()
        return t
    }()
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= scrollView.contentSize.width - scrollView.frame.size.width{
            if loadData{
                loadData = false
                getFolderContents()
            }
        }
    }
    
    func setupTableview() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FolderDetailViewCell.self, forCellReuseIdentifier: "FolderDetailViewCell")
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.tableFooterView = UIView()
        //        tableView.separatorInset = UIEdgeInsets(top: 0, left: marginBase, bottom: 0, right: marginBase)
        tableView.separatorStyle = .none
        //tableView.allowsSelection = false
    }
    
    func getFolderContents(){
        
        if self.contentData.count == 0 {
            self.showSpinner(onView: self.view)
        }
        
        let params = [
            "uniqueId" : JoinUserInfo.getInstance.uniqueId,
            "folderId" : folderID ?? "",
            "skip" : contentData.count.description
        ].stringFromHttpParameters()
        
        var request = URLRequest(url: URL(string: RestApi.getFolderContent + "?" + params)!)
        request.httpMethod = "GET"
        
        URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
            self?.loadData = true
            guard let data = data else { return }
            
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]]
                guard let result = json else { return }
                
                if result.count <= 0 {
                    self?.removeSpinner()
                    return
                }
                let content = Mapper<HistoryDataModel>().mapArray(JSONArray: result)
                self?.contentData += content
                
                DispatchQueue.main.async {
                    self?.removeSpinner()
                    self?.tableView.reloadData()
                }
            }catch{
                print(error)
            }
        }.resume()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = contentData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderDetailViewCell", for: indexPath) as? FolderDetailViewCell
        cell?.selectionStyle = .none
        if let images = data.savingContentsImage{
            if images.count > 0 {
                cell?.noteImage = images[0]
            }else{
                cell?.noteImage = ""
            }
        }else{
            cell?.noteImage = ""
        }
        
        if let dataSet = data.hashTagArray {
            cell?.hashTagsSet = dataSet
        }
        
        if let dataSet = data.memo {
            cell?.memoSet = dataSet
        }else{
            cell?.memoSet = ""
        }
        
        if let dataSet = data.folderLastUpdate {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate, .withFullDate, .withDashSeparatorInDate, .withColonSeparatorInTime]

            let date = dateFormatter.date(from: dataSet)
            
            let locatDateFormatter = DateFormatter()
            locatDateFormatter.timeZone = .current
            locatDateFormatter.dateFormat = "yyyy-MM-dd"
            
            if let date = date {
                let localDate = locatDateFormatter.string(from: date)
                
                cell?.dateLastUpdated = localDate
            }

        }
       
        return cell!
    }
    
    @objc func pushToDetail(sender: CustomTapGestureRecognizer) {
        let vc = ImageDetailViewController()
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height : CGFloat = 105
        return height
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = contentData[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: false)
        let vc = ImageDetailViewController()
        vc.delegate = self
        vc.refreshDelegate = self
        vc.listIndex = indexPath.row
        vc.actionId = data.actionId
        vc.folderId = folderID
        vc.isUrlImages = true
        vc.shouldDeleteAction = false
        
        if let contentData = data.contentData{
            if contentData.count > 0{
                
                if let imageId = contentData[0].imageId{
                    
                    vc.imageId = imageId
                    vc.action = "NOTE_IMAGE"
                }
                
                if let memoId = contentData[0].memoId{
                    
                    vc.memoId = memoId
                    vc.action = "NOTE"
                }
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteCell(indexPath: indexPath)
        }
    }
    
    func deleteCell(indexPath:IndexPath) {
        let data = contentData[indexPath.row]
        let alert = UIAlertController(title:"삭제 하시겠습니까?", message: "삭제된 파일은 복원되지 않습니다.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "네", style: .destructive, handler:{(action: UIAlertAction!) in
            
            if let contentData = data.contentData{
                if contentData.count > 0 {
                    let imageId = contentData[0].imageId
                    let memoId = contentData[0].memoId
                    
                    var params = [
                        "uniqueId" : JoinUserInfo.getInstance.uniqueId,
                        "imageId" : "",
                        "memoId" : ""
                    ]
                    
                    var action = ""
                    
                    if let imageId = imageId {
                        params["imageId"] = imageId
                        action = "NOTE_IMAGE"
                    }
                    
                    if let memoId = memoId{
                        params["memoId"] = memoId
                        action = "NOTE"
                    }
                    
                    if action == "NOTE_IMAGE" {
                        do{
                            let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
                            var request = URLRequest(url: URL(string: RestApi.deleteImage)!)
                            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                            request.httpMethod = "POST"
                            request.httpBody = jsonParams
                            
                            URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
                                if data == nil {
                                    return
                                }
                                
                                do {
                                    guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] else { return}
                                    let result = json["modifiedActionId"] as? String
                                    let deleteAction = json["deleteAction"] as? Bool
                                    
                                    if let modifiedActionId = result, let deleteAction = deleteAction {
                                        
                                        let refreshAction = RefreshAction(actionId: modifiedActionId, deleteAction: deleteAction)
                                        
                                        if let folderVC = self?.folderViewController {
                                            folderVC.refreshActions.append(refreshAction)
                                        }
                                       
                                        DispatchQueue.main.async {
                                            if let refreshDelegate = self?.refreshDelegate {
                                                refreshDelegate.refresh(actions: [refreshAction])
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
                    }else{
                        do{
                            let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
                            var request = URLRequest(url: URL(string: RestApi.deleteNote)!)
                            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                            request.httpMethod = "POST"
                            request.httpBody = jsonParams
                            
                            URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
                                if data == nil {
                                    return
                                }
                                
                                do {
                                    guard let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] else { return}
                                    let result = json["deletedActionId"] as? String
                                    
                                    if let deletedActionId = result {
                                        
                                        let refreshAction = RefreshAction(actionId: deletedActionId, deleteAction: true)
                                        if let folderVC = self?.folderViewController {
                                            folderVC.refreshActions.append(refreshAction)
                                        }
                                        
                                        DispatchQueue.main.async {
                                            if let refreshDelegate = self?.refreshDelegate {
                                                refreshDelegate.refresh(actions: [refreshAction])
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
            }
            
            
            self.contentData.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .left)
            
        }))
        
        alert.addAction(UIAlertAction(title: "아니요", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    var folderTitle : String?
    var folderID : String?
    func setupLeftSideButton() {
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        menuBtn.setImage(UIImage(named:"threeDots")?.withRenderingMode(.alwaysTemplate), for: .normal)
        menuBtn.addTarget(self, action: #selector(morePressed), for: .touchUpInside)
        menuBtn.tintColor = .white
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 20)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 20)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
        
        navigationItem.title = folderTitle
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    
    
    var moreViewMaxWidth : CGFloat?
    var moreViewMaxHeight : CGFloat?
    var moreViewWidthConstraint : NSLayoutConstraint?
    var moreViewHeightConstraint : NSLayoutConstraint?
    var moreView : UIView?
    var moreButtonArray = ["편집", "폴더 설정"]
    var moreButtonHeight : CGFloat = 50
    let moreButtonFont = UIFont(name: "HelveticaNeue", size: 18)
    func setupMoreView() {
        moreView?.removeFromSuperview()
        moreView = UIView()
        moreView?.backgroundColor = .white
        moreView?.layer.cornerRadius = 20
        view.addSubview(moreView!)
        moreView?.topAnchor.constraint(equalTo: view.topAnchor, constant: marginBase*2).isActive = true
        moreView?.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -marginBase*2).isActive = true
        moreView?.translatesAutoresizingMaskIntoConstraints = false
        moreViewWidthConstraint = NSLayoutConstraint(item: moreView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        moreViewHeightConstraint = NSLayoutConstraint(item: moreView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        view.addConstraints([moreViewWidthConstraint!, moreViewHeightConstraint!])
        
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
            editFolderStart()
        } else if  sender.tag == 1 {
            folderSettingStart()
        }
    }
    
    func editFolderStart() {
        tableView.isEditing = !tableView.isEditing
        if tableView.isEditing == true {
            moreButtonArray[0] = "편집 완료"
        } else {
            moreButtonArray[0] = "편집"
        }
        setupMoreView()
        closeMoreButton()
    }
    
    func folderSettingStart() {
        closeMoreButton()
        presentFolderSettingController()
    }
    
    func presentFolderSettingController() {
        
        if let comparison = folderTitle?.caseInsensitiveCompare("default"){
            switch comparison {
            case .orderedSame :
                let alert = UIAlertController(title: nil, message: "Default 폴더는 이름을 변경 할 수 없습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "네", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                break
                
            default:
                let vc = CreateFolderTextViewController()
                vc.delegate = self
                let nv = UINavigationController(rootViewController: vc)
                nv.modalPresentationStyle = .overFullScreen
                present(nv, animated: true) {
                    vc.textField.text = self.folderTitle
                }
                break
            }
        }
       
        
    }
    
    func saveIntoAFolder(data: HistoryDataModel) {
        folderTitle = data.folderName
        navigationItem.title = folderTitle
        
        guard let folderId = self.folderID else { return }
        
        let params = [
            "uniqueId": JoinUserInfo.getInstance.uniqueId,
            "folderId": folderId,
            "folderName": folderTitle ?? ""
        ] as [String:Any]
        
        do{
            let jsonParams = try JSONSerialization.data(withJSONObject: params, options: [])
            var request = URLRequest(url: URL(string: RestApi.renameFolder)!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonParams
            
            URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse else { return }
                
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        
                        if let folderVC = self?.folderViewController {
                            guard let defautDataIndex = folderVC.defaultData.index(where: {$0.folderID == folderId}) else {return}
                            folderVC.defaultData[defautDataIndex].folderName = self?.folderTitle
                            guard let folderDataIndex = folderVC.folderData.index(where: {$0.folderID == folderId}) else {return}
                            folderVC.folderData[folderDataIndex].folderName = self?.folderTitle
                            
                            folderVC.collectionView.reloadData()
                        }
                        
                        if let refreshDelegate = self?.refreshDelegate{
                            if let folderName = self?.folderTitle{
                                refreshDelegate.refresh(folderId: folderId, folderName: folderName)
                            }
                            
                        }
                    }
                }
            }.resume()
            
        }catch{
            print(error)
        }
    }
    
}

extension FolderDetailViewController: FolderSelectDelegate {
    func folderSelected(sender: HistoryDataModel) {
       
        
        if sender.deleteData {
            if let imageId = sender.imageIdToEdit {
                guard let dataIndex = self.contentData.index(where: {$0.contentData?[0].imageId == imageId}) else { return }
                if let actionId = self.contentData[dataIndex].actionId {
                    
                    let refreshAction = RefreshAction(actionId: actionId, deleteAction: true)
                    self.folderViewController?.refreshActions.append(refreshAction)
                }
                self.contentData.remove(at: dataIndex)
                self.tableView.reloadData()
            }else if let memoId = sender.memoIdToEdit {
                guard let dataIndex = self.contentData.index(where: {$0.contentData?[0].memoId == memoId}) else { return }
                if let actionId = self.contentData[dataIndex].actionId {
                    let refreshAction = RefreshAction(actionId: actionId, deleteAction: true)
                    self.folderViewController?.refreshActions.append(refreshAction)
                }
                self.contentData.remove(at: dataIndex)
                self.tableView.reloadData()
            }
        }else{
            guard let newActionId = sender.actionId else {return}
            let refreshAction = RefreshAction(actionId: newActionId, deleteAction: false)
            self.folderViewController?.refreshActions.append(refreshAction)
        }
    }
    
    func deleteContents(data: HistoryDataModel) {
        print(data)
    }
}

extension FolderDetailViewController: RefreshDelegate {
    func refresh(folderId: String) {
        
    }
    
    func refresh(folderId: String, folderName: String) {
        
    }
    
    func refresh(actions: [RefreshAction]) {
       
        
        for action in actions {
            
             self.folderViewController?.refreshActions.append(action)
            
            if action.convertToImage {
                if let index = self.contentData.index(where: {$0.contentData?[0].memoId == action.memoId}) {
                    
                    var imageNames = [String]()
                    
                    if let imageData = action.images{
                        for data in imageData {
                            self.contentData[index].contentData?[0].imageId = data.imageId
                            self.contentData[index].contentData?[0].imageName = data.imageName
                            
                            if let imageName = data.imageName{
                                imageNames.append(imageName)
                            }
                            
                        }
                        
                        self.contentData[index].contentData?[0].memoId = nil
                    }
                    
                    self.contentData[index].savingContentsImage = imageNames
                    self.contentData[index].action = "NOTE_IMAGE"
                    self.tableView.reloadRows(at: [IndexPath(row:index, section: 0)], with: .none)
                }
            }else{
                if let imageIds = action.imageIds {
                    for imageId in imageIds {
                        self.contentData.removeAll(where: {$0.contentData?[0].imageId == imageId})
                    }
                }
                
                if let memoId = action.memoId {
                    self.contentData.removeAll(where: {$0.contentData?[0].memoId == memoId})
                }
                
                self.tableView.reloadData()
            }
            
        }
        
        self.refreshDelegate?.refresh(actions: actions)
    }
    
    func refresh(index: Int) {
        print(index)
        
        if self.contentData.count > index {

            var params = ""
            if let imageId = contentData[index].contentData?[0].imageId {
                params = [
                    "uniqueId" : JoinUserInfo.getInstance.uniqueId,
                    "imageId" : imageId,
                    "folderId" : folderID ?? ""
                ].stringFromHttpParameters()
            }
            
            if let memoId = contentData[index].contentData?[0].memoId {
                params = [
                    "uniqueId" : JoinUserInfo.getInstance.uniqueId,
                    "memoId" : memoId,
                    "folderId" : folderID ?? ""
                ].stringFromHttpParameters()
            }
            
            var request = URLRequest(url: URL(string: RestApi.getContent + "?" + params)!)
            request.httpMethod = "GET"
            
            URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
                guard let data = data else {return}
                do{
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {return}
                    guard let content = Mapper<HistoryDataModel>().map(JSON: json) else { return }
                    
                    DispatchQueue.main.async {
                        self?.contentData[index] = content
                        self?.tableView.reloadData()
                    }
                    
                }catch{
                    print(error)
                }
            }.resume()
        }
        
    }
    
    
}

class FolderDetailViewCell : UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Color.hexStringToUIColor(hex: "#333333")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("FolderDetailViewCell denit successful")
    }
    var searchText : [String] = []
    var folderImage : UIImageView?
    var imageSet : UIImage? {
        didSet {
            folderImage?.removeFromSuperview()
            folderImage = UIImageView()
            folderImage?.image = imageSet
            folderImage?.contentMode = .scaleAspectFill
            folderImage?.clipsToBounds = true
            let size = contentView.frame.height - (marginBase*2)
            contentView.addSubview(folderImage!)
            folderImage?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            folderImage?.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: marginBase).isActive = true
            folderImage?.heightAnchor.constraint(equalToConstant: size).isActive = true
            folderImage?.widthAnchor.constraint(equalToConstant: size).isActive = true
            folderImage?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    var noteImage : String? {
        didSet{
            folderImage?.removeFromSuperview()
            folderImage = UIImageView()
            
            if let image = noteImage {
                if image.count > 0 {
                    folderImage?.kf.setImage(with: URL(string: RestApi.noteImage + image), placeholder: UIImage(named: "addIconCircle"))
                }else{
                    folderImage?.image = UIImage(named: "addIconCircle")
                }
                
            }else{
                folderImage?.image = UIImage(named: "addIconCircle")?.withRenderingMode(.alwaysTemplate)
            }
            
            folderImage?.contentMode = .scaleAspectFill
            folderImage?.clipsToBounds = true
            let size = contentView.frame.height - (marginBase*2)
            contentView.addSubview(folderImage!)
            folderImage?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            folderImage?.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: marginBase).isActive = true
            folderImage?.heightAnchor.constraint(equalToConstant: size).isActive = true
            folderImage?.widthAnchor.constraint(equalToConstant: size).isActive = true
            folderImage?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    
    let hashFont = UIFont(name: "HelveticaNeue-Bold", size: 17)
    var hashString : UILabel?
    var hashTagsSet : [String]? {
        didSet {
            hashString?.removeFromSuperview()
            hashString = UILabel()
            var hashTags = hashTagsSet?.joined(separator: " #")
            
            if let tags = hashTags {
                hashTags = "#" + tags
            }
            
            hashString?.text = hashTags
            hashString?.font = hashFont
            hashString?.textColor = .white
            
            let attributedString = NSMutableAttributedString(string: (hashString?.text)!)

            for i in 0..<searchText.count {
                if let range : NSRange = (((hashString?.text)! as? NSString)?.range(of: searchText[i], options: .caseInsensitive))! {
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Color.hexStringToUIColor(hex: "#FFA00A"), range: range)
                }
            }
            
            hashString?.attributedText = attributedString
            
            contentView.addSubview(hashString!)
            hashString?.topAnchor.constraint(equalTo: (folderImage?.topAnchor)!).isActive = true
            hashString?.leftAnchor.constraint(equalTo: (folderImage?.rightAnchor)!, constant: marginBase*2).isActive = true
            hashString?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -marginBase*2).isActive = true
            hashString?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    let memoFont = UIFont(name: "HelveticaNeue", size: 15)
    var memoLabel : UILabel?
    var memoSet : String? {
        didSet {
            
            memoLabel?.removeFromSuperview()
            memoLabel = UILabel()
            memoLabel?.text = memoSet!
            memoLabel?.font = memoFont
            memoLabel?.textColor = .lightGray
            memoLabel?.numberOfLines = 2
            memoLabel?.lineBreakMode = .byWordWrapping
            
            let attributedString = NSMutableAttributedString(string: (memoLabel?.text)!)

            for i in 0..<searchText.count {
                if let range : NSRange = (((memoLabel?.text)! as? NSString)?.range(of: searchText[i], options: .caseInsensitive))! {
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Color.hexStringToUIColor(hex: "#FFA00A"), range: range)
                }
            }
            memoLabel?.attributedText = attributedString
            
            contentView.addSubview(memoLabel!)
            memoLabel?.topAnchor.constraint(equalTo: (hashString?.bottomAnchor)!, constant: marginBase).isActive = true
            memoLabel?.leftAnchor.constraint(equalTo: (folderImage?.rightAnchor)!, constant: marginBase*2).isActive = true
            memoLabel?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -marginBase*2).isActive = true
            memoLabel?.translatesAutoresizingMaskIntoConstraints = false
            
        }
    }
    
    let dateFont = UIFont(name: "HelveticaNeue", size: 15)
    var dateLabel : UILabel?
    var dateLastUpdated : String? {
        didSet {
            
            dateLabel?.removeFromSuperview()
            dateLabel = UILabel()
            dateLabel?.text = dateLastUpdated!
            dateLabel?.font = memoFont
            dateLabel?.textColor = .gray
            
            contentView.addSubview(dateLabel!)
            dateLabel?.bottomAnchor.constraint(equalTo: (folderImage?.bottomAnchor)!).isActive = true
            dateLabel?.leftAnchor.constraint(equalTo: (folderImage?.rightAnchor)!, constant: marginBase*2).isActive = true
            dateLabel?.translatesAutoresizingMaskIntoConstraints = false
            
        }
    }
    
}
