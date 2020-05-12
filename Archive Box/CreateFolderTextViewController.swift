//
//  CreateFolderTextViewController.swift
//  BuxBox
//
//  Created by SongChiduk on 11/03/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

protocol SaveIntoFolderDelegate {
    func saveIntoAFolder(data: HistoryDataModel)
}

class CreateFolderTextViewController : UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
        setupNavBar()
        setupTextBox()
    }
    
    deinit {
        print("CreateFolderTextViewController denit successfull.")
    }
    
    var delegate : SaveIntoFolderDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        textField.becomeFirstResponder()
    }
    
    func setupNavBar() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = Color.hexStringToUIColor(hex: "#212121")
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.isHidden = false
        
        let leftButton = UIBarButtonItem(image: UIImage(named: "closeXIcon"), style: .done, target: self, action: #selector(dismissView))
        leftButton.tintColor = .white
        navigationItem.leftBarButtonItem = leftButton
        
        let rightButton = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createFolder))
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    let folderLabel = UILabel()
    let labelFont = UIFont(name: "HelveticaNeue-Bold", size: 18)
    
    var textFieldView : UIView!
    var textField : UITextField!
    var saveButton : UIButton!
    func setupTextBox() {
        
        folderLabel.text = "폴더명"
        folderLabel.font = labelFont
        folderLabel.textColor = .white
        
        view.addSubview(folderLabel)
        folderLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: marginBase*2).isActive = true
        folderLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase).isActive = true
        folderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textFieldView = UIView()
        textFieldView.backgroundColor = Color.hexStringToUIColor(hex: "#5C5C5C")
     
        
        view.addSubview(textFieldView)
        textFieldView.topAnchor.constraint(equalTo: folderLabel.bottomAnchor, constant: marginBase*2).isActive = true
        textFieldView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase).isActive = true
        textFieldView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -marginBase).isActive = true
        textFieldView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textFieldView.translatesAutoresizingMaskIntoConstraints = false
        
        textField = UITextField()
        textField.delegate = self
        textField.textColor = .white
        textField.placeholder = "Write a folder name"
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)

        view.addSubview(textField)
        textField.centerYAnchor.constraint(equalTo: textFieldView.centerYAnchor).isActive = true
        textField.leftAnchor.constraint(equalTo: textFieldView.leftAnchor, constant: marginBase).isActive = true
        textField.rightAnchor.constraint(equalTo: textFieldView.rightAnchor, constant: -marginBase).isActive = true
//        textField.heightAnchor.constraint(equalToConstant: 55).isActive = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton = UIButton()
        saveButton.setTitle("확인", for: .normal)
        saveButton.setTitleColor(.black, for: .normal)
        saveButton.setTitleColor(.gray, for: .disabled)
        saveButton.backgroundColor = Color.hexStringToUIColor(hex: "#000000")
        let buttonHeight = (saveButton.titleLabel?.intrinsicContentSize.height)! + marginBase*4
        saveButton.addTarget(self, action: #selector(createFolder), for: .touchUpInside)
        view.addSubview(saveButton)
        saveButton.topAnchor.constraint(equalTo: textFieldView.bottomAnchor, constant: marginBase*2).isActive = true
        saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: view.frame.width - marginBase*4).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.isEnabled = false
        
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if (textField.text?.count)! > 0 {
            navigationItem.rightBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.tintColor = Color.hexStringToUIColor(hex: "#FFBF2E")
            saveButton.isEnabled = true
            saveButton.backgroundColor = Color.hexStringToUIColor(hex: "#FFBF2E")
        }
    }
    
    
    
    @objc func createFolder() {
        guard let folderName = self.textField.text?.trimmingCharacters(in: .whitespaces) else {return}
        
        let params = [
            "uniqueId": JoinUserInfo.getInstance.uniqueId,
            "folderName" : folderName
        ].stringFromHttpParameters()
        
        var request = URLRequest(url: URL(string: RestApi.checkFolderName + "?" + params)!)
        request.httpMethod = "GET"
        
        URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
            guard let data = data else {return}
            
            do{
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {return}
                guard let exists = json["exists"] as? Bool else {return}
                
                DispatchQueue.main.async {
                    if exists {
                        let alert = UIAlertController(title: nil, message: "같은 이름의 폴더가 이미 존재합니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                        
                        self?.present(alert, animated: true, completion: nil)
                    }else{
                        self?.dismiss(animated: true) {
                            
                            
                            let sampleFolder = HistoryDataModel()
                            sampleFolder.folderName = folderName
                            self?.delegate?.saveIntoAFolder(data: sampleFolder)
                        }
                        
                    }
                }
                
            }catch{
                print(error)
            }
        }.resume()
        
        
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
