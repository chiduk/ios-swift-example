//
//  SearchViewController .swift
//  BuxBox
//
//  Created by SongChiduk on 12/03/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class SearchViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let dbHelper = DBHelper()
    weak var homeViewController : HomeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTableView()
        
        getSearchTerms()
    }
    
    var searchBar : UISearchBar?
    func setupNavBar() {
        searchBar = UISearchBar(frame: .zero)
        
        searchBar?.placeholder = " 검색"
        searchBar?.backgroundImage = UIImage()
        searchBar?.barTintColor = Color.hexStringToUIColor(hex: "#212121")
        if let txfSearchField = searchBar?.value(forKey: "_searchField") as? UITextField {
            txfSearchField.borderStyle = .none
            txfSearchField.backgroundColor = .clear
            txfSearchField.textColor = .white
            txfSearchField.leftViewMode = .unlessEditing
            txfSearchField.autocorrectionType = .yes
        }
        
        let searchBarContainer = SearchBarContainerView(customSearchBar: searchBar!)
        searchBarContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        navigationItem.titleView = searchBarContainer
        searchBar?.delegate = self
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = Color.hexStringToUIColor(hex: "#212121")
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
        
    }
    
    func getSearchTerms() {
        let terms = dbHelper.getSearchTerms()
        self.historyData.removeAll()
        for term in terms {
            self.historyData.append(SearchHistoryModel(text: term))
        }
        
        searchHistoryTable.reloadData()
    }
    
    func saveSearchTerm(term: String){
        
        dbHelper.deleteSearchTerm(searchTerm: term.trimmingCharacters(in: .whitespaces))
        dbHelper.insertSearchTerm(searchTerm: term.trimmingCharacters(in: .whitespaces))
        
        getSearchTerms()
    }
    
    lazy var searchHistoryTable : UITableView = {
        let s = UITableView()
        s.delegate = self
        s.dataSource = self
        return s
    }()
    
    lazy var searchResultTable : UITableView = {
        let s = UITableView()
        s.delegate = self
        s.dataSource = self
        return s
    }()
    
    func setupTableView() {
        searchHistoryTable.frame = view.bounds
        searchHistoryTable.isHidden = false
        searchHistoryTable.tableFooterView = UIView()
        searchHistoryTable.separatorStyle = .none
        searchHistoryTable.allowsSelection = false
        searchHistoryTable.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
        view.addSubview(searchHistoryTable)
        searchHistoryTable.register(SearchHistoryCell.self, forCellReuseIdentifier: "SearchHistoryCell")
        searchHistoryTable.sectionHeaderHeight = 70
        
        
        searchResultTable.frame = view.bounds
        searchResultTable.isHidden = true
        searchResultTable.tableFooterView = UIView()
        searchResultTable.separatorStyle = .none
        searchResultTable.allowsSelection = false
        searchResultTable.sectionHeaderHeight = 0
        searchResultTable.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
        view.addSubview(searchResultTable)
        searchResultTable.register(FolderDetailViewCell.self, forCellReuseIdentifier: "FolderDetailViewCell")
        
    }
    
    //    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    //        if (searchBar.text?.count)! > 0 {
    //            searchHistoryTable.isHidden = true
    //            searchResultTable.isHidden = false
    //            getSearchResult()
    //        }
    //    }
    //
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        view.endEditing(true)
        searchBar?.endEditing(true)
    }

    //    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    //        searchHistoryTable.isHidden = false
    //        searchResultTable.isHidden = true
    //    }
    
    func getSearchResult(keyword: String) {
        
        let params = [
            "uniqueId": JoinUserInfo.getInstance.uniqueId,
            "keyword": keyword.trimmingCharacters(in: .whitespaces)
        ].stringFromHttpParameters()
        
        var request = URLRequest(url: URL(string: RestApi.searchKeyword + "?" + params)!)
        request.httpMethod = "GET"
        
        URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
            guard let data = data else {return}
            
            do{
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]] else {return}
                let results = Mapper<HistoryDataModel>().mapArray(JSONArray: json)
                
                DispatchQueue.main.async {
                    
                    self?.searchResults.removeAll()
                    self?.searchResults += results
                    self?.searchResultTable.reloadData()
                    
                }
                
                
            }catch{
                print(error)
            }
        }.resume()
        
       
    }
    var historyData = [SearchHistoryModel]()
    
    var searchResults = [HistoryDataModel]()
    

    @objc func deleteAll() {
        let alert = UIAlertController(title: "", message: "모두 삭제 하시겠습니까?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "네", style: .destructive, handler:{(action: UIAlertAction!) in
            
            self.deleteAllHistory()
            
        }))
        
        alert.addAction(UIAlertAction(title: "아니요", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    @objc func deleteAllHistory() {
//        let count = historyData.count
//
//        for i in 0..<count {
//            historyData.remove(at: (count-1)-i)
//            searchHistoryTable.performBatchUpdates({
//
//                searchHistoryTable.deleteRows(at: [IndexPath(row: (count-1)-i, section: 0)], with: .left)
//
//            }, completion: nil)
//        }
        
        self.historyData.removeAll()
        
        if dbHelper.deleteAllSearchTerm() {
            self.searchHistoryTable.reloadData()
        }
        
        
    }
    
    let deleteAllButton = UIButton()
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView(frame: .zero)
        if tableView == searchHistoryTable {
            
            let recentLabel = UILabel()
            recentLabel.text = "최근 검색"
            recentLabel.textColor = .gray
            vw.addSubview(recentLabel)
            recentLabel.leftAnchor.constraint(equalTo: vw.leftAnchor, constant: marginBase*2).isActive = true
            recentLabel.centerYAnchor.constraint(equalTo: vw.centerYAnchor).isActive = true
            recentLabel.translatesAutoresizingMaskIntoConstraints = false
            
            deleteAllButton.setTitle("전체삭제", for: .normal)
            deleteAllButton.setTitleColor(.lightGray, for: .normal)
            deleteAllButton.addTarget(self, action: #selector(deleteAll), for: .touchUpInside)
            vw.addSubview(deleteAllButton)
            deleteAllButton.rightAnchor.constraint(equalTo: vw.rightAnchor, constant: -marginBase*2).isActive = true
            deleteAllButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            deleteAllButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
            deleteAllButton.centerYAnchor.constraint(equalTo: vw.centerYAnchor).isActive = true
            deleteAllButton.translatesAutoresizingMaskIntoConstraints = false
            
        }
        return vw
    }
    
    @objc func searchCellTapped(sender: CustomTapGestureRecognizer) {
        guard let index = sender.index else { return }
        let data = historyData[index]
        guard let term = data.text else { return }
        
        searchHistoryTable.isHidden = true
        searchResultTable.isHidden = false
        
        getSearchResult(keyword: term)
        searchBar?.text = term.trimmingCharacters(in: .whitespaces)
        
        saveSearchTerm(term: term.trimmingCharacters(in: .whitespaces))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchHistoryTable {
            return historyData.count
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == searchHistoryTable {
            
            let data = historyData[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchHistoryCell", for: indexPath) as? SearchHistoryCell
            cell?.textSet = data.text
            cell?.deleteButton?.addTarget(self, action: #selector(deleteHistorySingle), for: .touchUpInside)
            let tap = CustomTapGestureRecognizer(target: self, action: #selector(searchCellTapped))
            tap.index = indexPath.row
            
            cell?.addGestureRecognizer(tap)
            
            return cell!
            
        } else {
            
            let data = searchResults[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "FolderDetailViewCell", for: indexPath) as? FolderDetailViewCell
            
            if let dataSet = data.savingContentsImage{
                if dataSet.count > 0 {
                    let image = dataSet[0]
                    cell?.noteImage = image
                }else{
                    cell?.imageSet = UIImage(named: "addIconCircle")
                }
            }else{
                cell?.imageSet = UIImage(named: "addIconCircle")
            }
            
            
            if let data = data.searchText {
                cell?.searchText = data
            }
            
            if let dataSet = data.hashTagArray {
                cell?.hashTagsSet = dataSet
            }else{
                cell?.hashTagsSet = [""]
            }
            
            if let dataSet = data.memo {
                cell?.memoSet = dataSet
            }else{
                cell?.memoSet = ""
            }
            
            
            if let dateSet = data.folderLastUpdate{
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withFullDate, .withFullDate, .withDashSeparatorInDate, .withColonSeparatorInTime]
                
                let date = dateFormatter.date(from: dateSet)
                
                let locatDateFormatter = DateFormatter()
                locatDateFormatter.timeZone = .current
                locatDateFormatter.dateFormat = "yyyy-MM-dd"
                
                if let date = date {
                    let localDate = locatDateFormatter.string(from: date)
                    
                    cell?.dateLastUpdated = localDate
                }else{
                    cell?.dateLastUpdated = "       "
                }

            }else{
                cell?.dateLastUpdated = "       "
            }
            
          
            let tap = CustomTapGestureRecognizer(target: self, action: #selector(pushToDetail))
            tap.index = indexPath.row
            cell?.addGestureRecognizer(tap)
            return cell!
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == searchHistoryTable  {
            let height : CGFloat = 55
            return height
        } else {
            let height : CGFloat = 105
            return height
        }
    }
    
    @objc func deleteHistorySingle(sender: UIButton) {
        
        if let cell = sender.superview?.superview as? SearchHistoryCell {
            guard let indexPath = self.searchHistoryTable.indexPath(for: cell) else {return}
            guard let term = self.historyData[indexPath.row].text else {return }
            dbHelper.deleteSearchTerm(searchTerm: term.trimmingCharacters(in: .whitespaces))
            historyData.removeAll(where: {$0.text == term})
            searchHistoryTable.performBatchUpdates({
                searchHistoryTable.deleteRows(at: [indexPath], with: .left)
            }) { (bool) in
                if bool == true {
                    self.searchHistoryTable.reloadData()
                }
            }
        }
        
    }
    
    @objc func pushToDetail(sender: CustomTapGestureRecognizer) {
        guard let index = sender.index else {
            return
        }
        let data = self.searchResults[index]
        let vc = ImageDetailViewController()
        vc.delegate = self
        vc.refreshDelegate = self
        vc.listIndex = index
        vc.actionId = data.actionId
        vc.folderId = data.folderID
        vc.isUrlImages = true
        vc.shouldDeleteAction = true

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
        
        if let searchTerm = searchBar?.text{
            saveSearchTerm(term: searchTerm.trimmingCharacters(in: .whitespaces))
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 0 {
            searchHistoryTable.isHidden = true
            searchResultTable.isHidden = false
            
            if searchText.count > 1 {
                getSearchResult(keyword: searchText)
            }

            //searchBar.text = searchText.trimmingCharacters(in: .whitespaces)
            
            
            for i in searchResults {
                i.searchText = searchText.components(separatedBy: " ")
            }
        } else {
            searchHistoryTable.isHidden = false
            searchResultTable.isHidden = true
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
        
        if let term = searchBar.text {
            saveSearchTerm(term: term)
        }
    }
    
}

extension SearchViewController: FolderSelectDelegate {
    func folderSelected(sender: HistoryDataModel) {
        if sender.deleteData {
            if let imageId = sender.imageIdToEdit {
                guard let dataIndex = self.searchResults.index(where: {$0.contentData?[0].imageId == imageId}) else { return }
                if let actionId = self.searchResults[dataIndex].actionId {
                    
                    let refreshAction = RefreshAction(actionId: actionId, deleteAction: true)
                    self.homeViewController?.refresh(actions: [refreshAction])
                }
//                self.searchResults.remove(at: dataIndex)
//                self.searchResultTable.reloadData()
            }else if let memoId = sender.memoIdToEdit {
                guard let dataIndex = self.searchResults.index(where: {$0.contentData?[0].memoId == memoId}) else { return }
                if let actionId = self.searchResults[dataIndex].actionId {
                    let refreshAction = RefreshAction(actionId: actionId, deleteAction: true)
                    self.homeViewController?.refresh(actions: [refreshAction])
                }
//                self.searchResults.remove(at: dataIndex)
//                self.searchResultTable.reloadData()
            }
        }else{
            guard let newActionId = sender.actionId else {return}
            guard let newFolderId = sender.folderID else {return}
            
            if let imageId = sender.imageIdToEdit {
                guard let index = self.searchResults.index(where: {$0.contentData?[0].imageId == imageId}) else { return }
                self.searchResults[index].actionId = newActionId
                self.searchResults[index].folderID = newFolderId
            }
            
            let refreshAction = RefreshAction(actionId: newActionId, deleteAction: false)
            self.homeViewController?.refresh(actions: [refreshAction])
        }
    }
    
    func deleteContents(data: HistoryDataModel) {
        
    }

}

extension SearchViewController: RefreshDelegate{
    func refresh(index: Int) {
        
    }
    
    func refresh(actions: [RefreshAction]) {
        for action in actions {
            
            //self.folderViewController?.refreshActions.append(action)
            
            if action.convertToImage {
                if let index = self.searchResults.index(where: {$0.contentData?[0].memoId == action.memoId}) {
                    
                    var imageNames = [String]()
                    
                    if let imageData = action.images{
                        for data in imageData {
                            self.searchResults[index].contentData?[0].imageId = data.imageId
                            self.searchResults[index].contentData?[0].imageName = data.imageName
                            
                            if let imageName = data.imageName{
                                imageNames.append(imageName)
                            }
                            
                        }
                        
                        self.searchResults[index].contentData?[0].memoId = nil
                    }
                    
                    self.searchResults[index].savingContentsImage = imageNames
                    self.searchResults[index].action = "NOTE_IMAGE"
                    self.searchResultTable.reloadRows(at: [IndexPath(row:index, section: 0)], with: .none)
                }
            }else{
                if let imageIds = action.imageIds {
                    for imageId in imageIds {
                        self.searchResults.removeAll(where: {$0.contentData?[0].imageId == imageId})
                    }
                }
                
                if let memoId = action.memoId {
                    self.searchResults.removeAll(where: {$0.contentData?[0].memoId == memoId})
                }
                
                self.searchResultTable.reloadData()
            }
            
        }
        
        self.homeViewController?.refresh(actions: actions)
    }
    
    func refresh(folderId: String) {
        
    }
    
    func refresh(folderId: String, folderName: String) {
        
    }
    
    
}

class SearchHistoryModel : NSObject {
    var text : String?
    
    init(text : String) {
        self.text = text
    }
}

class SearchHistoryCell : UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let searchIcon : UIImageView = {
        let s = UIImageView()
        s.image = UIImage(named: "searchTabIcon")?.withRenderingMode(.alwaysTemplate)
        s.contentMode = .scaleAspectFit
        s.clipsToBounds = true
        return s
    }()
    
    var deleteButton : UIButton?
    let historyFont = UIFont(name: "HelveticaNeue", size: 18)
    var historyLabel : UILabel?
    var textSet : String? {
        didSet {
            searchIcon.tintColor = .gray
            contentView.addSubview(searchIcon)
            searchIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            searchIcon.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: marginBase*2).isActive = true
            searchIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
            searchIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true
            searchIcon.translatesAutoresizingMaskIntoConstraints = false
            
            deleteButton?.removeFromSuperview()
            deleteButton = UIButton()
            deleteButton?.setImage(UIImage(named: "closeIconSmall")?.withRenderingMode(.alwaysTemplate), for: .normal)
            deleteButton?.tintColor = .gray
            
            contentView.addSubview(deleteButton!)
            deleteButton?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            deleteButton?.widthAnchor.constraint(equalToConstant: 30).isActive = true
            deleteButton?.heightAnchor.constraint(equalToConstant: 30).isActive = true
            deleteButton?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -marginBase*2).isActive = true
            deleteButton?.translatesAutoresizingMaskIntoConstraints = false
            
            historyLabel?.removeFromSuperview()
            historyLabel = UILabel()
            historyLabel?.text = textSet!
            historyLabel?.font = historyFont
            historyLabel?.textColor = .white
            
            contentView.addSubview(historyLabel!)
            historyLabel?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
            historyLabel?.leftAnchor.constraint(equalTo: searchIcon.rightAnchor, constant: marginBase*2).isActive = true
            historyLabel?.rightAnchor.constraint(equalTo: (deleteButton?.leftAnchor)!, constant: -marginBase*2).isActive = true
            historyLabel?.translatesAutoresizingMaskIntoConstraints = false
            
            
        }
    }
    
}
