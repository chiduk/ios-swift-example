//
//  LogIn.swift
//  BuxBox
//
//  Created by SongChiduk on 12/29/18.
//  Copyright © 2018 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import ObjectMapper

protocol LogInDelegate: class {
    func logIn() 
}

class LogIn: UIViewController, UITextFieldDelegate {
    
    
    var dict : [String : AnyObject]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
        setupKeyBoardNotification()
        setupView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEdit))
        view.addGestureRecognizer(tap)
    }
    
    @objc func endEdit() {
        view.endEditing(true)
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
        UIView.animate(withDuration: self.keyBoardDuration, animations: {
            self.scrollView.contentOffset.y = 0
        })
    }
    
    deinit {
        print("LogIn denit successful")
    }
    
    func setupKeyBoardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    var isKeyboardOn : Bool = false
    var keyboardHeight : CGFloat = 0
    var keyBoardDuration : Double = 0
    @objc func keyboardShow(_ notification: Notification) {
        isKeyboardOn = true
        let keyBoardFrame = (notification.userInfo? [UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        keyboardHeight = (keyBoardFrame?.height)!
        keyBoardDuration = (notification.userInfo? [UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
    }
    
    @objc func keyboardHide(_ notification: Notification) {
        isKeyboardOn = false
        keyBoardDuration = (notification.userInfo? [UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
    }
    
    let scrollView = UIScrollView()
    
    let logo : UIImageView = {
        let l = UIImageView()
        l.image = UIImage(named: "aiIconLarge")
        return l
    }()
    
    let facebooButtonView = UIView()
    
    let loginButton = UIButton()
    
    let emailView = UIView()
    let emailAddressTextField = UITextField()
    
    let passWorkView = UIView()
    let passworkTextField = UITextField()
    
    let signupbutton = UIButton()
    let loginEmailButton = UIButton()
    
    let fieldHeight : CGFloat = 60
    
    func setupView() {
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
        
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        
        logo.contentMode = .scaleAspectFit
        logo.clipsToBounds = true
        
        scrollView.addSubview(logo)
        logo.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 100).isActive = true
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.widthAnchor.constraint(equalToConstant: CGFloat(100)).isActive = true
        logo.heightAnchor.constraint(equalToConstant: CGFloat(100)).isActive = true
        logo.translatesAutoresizingMaskIntoConstraints = false
        
        let width = view.frame.width - (marginBase*8)
        
        facebooButtonView.backgroundColor = Color.hexStringToUIColor(hex: "#3A559F")
        facebooButtonView.layer.cornerRadius = fieldHeight / 2
        
        scrollView.addSubview(facebooButtonView)
        facebooButtonView.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: marginBase*2).isActive = true
        facebooButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        facebooButtonView.widthAnchor.constraint(equalToConstant: width).isActive = true
        facebooButtonView.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        facebooButtonView.translatesAutoresizingMaskIntoConstraints = false
        
        facebooButtonView.addSubview(loginButton)
        loginButton.centerYAnchor.constraint(equalTo: facebooButtonView.centerYAnchor).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: facebooButtonView.centerXAnchor).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: width - (marginBase*4)).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.setTitle(" 페이스북 로그인", for: .normal)
        loginButton.setImage(UIImage(named: "facebookIcon"), for: .normal)
        loginButton.addTarget(self, action: #selector(facebookLogin), for: .touchUpInside)
        loginButton.imageView?.contentMode = .scaleAspectFit
        loginButton.imageView?.clipsToBounds = true
        loginButton.contentHorizontalAlignment = .left
        loginButton.layer.cornerRadius = fieldHeight/2
        loginButton.clipsToBounds = true
        loginButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        
        scrollView.addSubview(emailView)
        emailView.topAnchor.constraint(equalTo: facebooButtonView.bottomAnchor, constant: marginBase*2).isActive = true
        emailView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailView.widthAnchor.constraint(equalToConstant: width).isActive = true
        emailView.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        emailView.translatesAutoresizingMaskIntoConstraints = false
        
        emailView.backgroundColor = .white
        emailView.layer.cornerRadius = fieldHeight / 2
        
        emailView.addSubview(emailAddressTextField)
        emailAddressTextField.centerYAnchor.constraint(equalTo: emailView.centerYAnchor).isActive = true
        emailAddressTextField.centerXAnchor.constraint(equalTo: emailView.centerXAnchor).isActive = true
        emailAddressTextField.widthAnchor.constraint(equalToConstant: width - marginBase*4).isActive = true
        emailAddressTextField.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        emailAddressTextField.translatesAutoresizingMaskIntoConstraints = false
        emailAddressTextField.delegate = self
        emailAddressTextField.keyboardType = .emailAddress
        emailAddressTextField.placeholder = " 이메일 로그인"
        emailAddressTextField.textColor = .black
        
        passWorkView.backgroundColor = .white
        passWorkView.layer.cornerRadius = fieldHeight / 2
        
        scrollView.addSubview(passWorkView)
        passWorkView.topAnchor.constraint(equalTo: emailView.bottomAnchor, constant: marginBase*2).isActive = true
        passWorkView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passWorkView.widthAnchor.constraint(equalToConstant: width).isActive = true
        passWorkView.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        passWorkView.translatesAutoresizingMaskIntoConstraints = false
        
        passWorkView.addSubview(passworkTextField)
        passworkTextField.centerYAnchor.constraint(equalTo: passWorkView.centerYAnchor).isActive = true
        passworkTextField.centerXAnchor.constraint(equalTo: passWorkView.centerXAnchor).isActive = true
        passworkTextField.widthAnchor.constraint(equalToConstant: width - marginBase*4).isActive = true
        passworkTextField.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        passworkTextField.translatesAutoresizingMaskIntoConstraints = false
        passworkTextField.delegate = self
        passworkTextField.keyboardType = .default
        passworkTextField.placeholder = "암호"
        passworkTextField.isSecureTextEntry = true
        passworkTextField.textColor = .black

        signupbutton.layer.cornerRadius = fieldHeight / 2
        signupbutton.backgroundColor = .white
        signupbutton.setTitle("가입", for: .normal)
        signupbutton.setTitleColor(.black, for: .normal)
        signupbutton.addTarget(self, action: #selector(signupPressed), for: .touchUpInside)
        
        scrollView.addSubview(signupbutton)
        signupbutton.topAnchor.constraint(equalTo: passWorkView.bottomAnchor, constant: marginBase*2).isActive = true
        signupbutton.leftAnchor.constraint(equalTo: passWorkView.leftAnchor, constant: 0).isActive = true
        signupbutton.widthAnchor.constraint(equalToConstant: (width/2) - marginBase).isActive = true
        signupbutton.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        signupbutton.translatesAutoresizingMaskIntoConstraints = false
        
        loginEmailButton.layer.cornerRadius = fieldHeight / 2
        loginEmailButton.backgroundColor = .white
        loginEmailButton.setTitle("로그인", for: .normal)
        loginEmailButton.setTitleColor(.black, for: .normal)
        loginEmailButton.addTarget(self, action: #selector(emailLoginPressed), for: .touchUpInside)
        scrollView.addSubview(loginEmailButton)
        loginEmailButton.topAnchor.constraint(equalTo: passWorkView.bottomAnchor, constant: marginBase*2).isActive = true
        loginEmailButton.rightAnchor.constraint(equalTo: passWorkView.rightAnchor, constant: 0).isActive = true
        loginEmailButton.widthAnchor.constraint(equalToConstant: (width/2) - marginBase).isActive = true
        loginEmailButton.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        loginEmailButton.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let when = DispatchTime.now() + 0.3
        DispatchQueue.main.asyncAfter(deadline: when) {
            
            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+self.keyboardHeight)

            let availableView = self.view.frame.height - self.keyboardHeight
            
            if textField == self.emailAddressTextField {
                let origin = self.emailView.frame.origin.y + self.fieldHeight + (marginBase*4)
                let coordinate =  self.emailAddressTextField.superview?.convert(self.emailAddressTextField.frame.origin, to: self.view)
                let ycoordinate = (coordinate?.y)! + self.fieldHeight
                
                if ycoordinate > availableView {
                    
                    UIView.animate(withDuration: self.keyBoardDuration, animations: {
                        self.scrollView.contentOffset.y = origin - availableView
                    })
                    
                }
            } else if textField == self.passworkTextField {
                let origin = self.passWorkView.frame.origin.y + self.fieldHeight + (marginBase*4)
                let coordinate =  self.passworkTextField.superview?.convert(self.passworkTextField.frame.origin, to: self.view)
                
                let ycoordinate = (coordinate?.y)! + self.fieldHeight
                
                if ycoordinate > availableView {
                    
                    UIView.animate(withDuration: self.keyBoardDuration, animations: {
                        self.scrollView.contentOffset.y = origin - availableView
                    })
                    
                }
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailAddressTextField {
            passworkTextField.becomeFirstResponder()
        } else if textField == passworkTextField {
            emailLoginPressed()
            endEdit()
        }
        return true
    }
    
    @objc func facebookLogin() {
        
        let alert = UIAlertController(title:"Terms and Policy", message: "By logging in, you acknowledge that you have read the terms and conditions and agree with them.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{(action: UIAlertAction!) in
            
            let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
            fbLoginManager.logIn(withReadPermissions: ["public_profile","email", "user_friends"], from: self) { (result, error) in
                
                if (error == nil){
                    let fbloginresult : FBSDKLoginManagerLoginResult = result!
                    if fbloginresult.grantedPermissions != nil {
                        
                        self.getFBUserData()
                        
                    }
                }else{
                    
                    let alert = UIAlertController(title: nil, message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title:"No", style: .cancel, handler:nil))
        
        alert.addAction(UIAlertAction(title: "Read the policy", style: .default, handler:{(action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
            let vc = MyWebView()
            vc.link = "http://www.dogeartravel.com/eula.html"
            let navController = UINavigationController(rootViewController: vc)
            self.present(navController, animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email, age_range"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! [String : AnyObject]
                    
                    
                    let name = self.dict["name"]
                    let firstName = self.dict["first_name"]
                    let lastName = self.dict["last_name"]
                    let facebookId = self.dict["id"]
                    let params = [
                        "name": (name?.description)!,
                        //"email" : self.dict["email"]!.description,
                        "firstName": (firstName?.description)!,
                        "lastName": (lastName?.description)!,
                        "password": "unknown",
                        "receiveEmail" : false.description,
                        "gender":"unknown",
                        "phoneNumber":"unknown",
                        "facebookAccount": true.description,
                        "facebookId": (facebookId?.description)!
                        
                    ]
                    
                    
                    
                    let strParams = params.stringFromHttpParameters()
                    
                    var request = URLRequest(url: URL(string: RestApi.facebookLogin + "?" + strParams)!)
                    request.httpMethod = "GET"
                    
                    URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
                        if data == nil{
                            return
                        }
                        
                        do{
                            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                            let result = Mapper<User>().map(JSON: json)
                            
                            
                            let uniqueId = result?.uniqueId
                            
                            let phoneNumber = " "
                            
                            let dbHelper: DBHelper = DBHelper()
                            dbHelper.insertUser(userName: (result?.name)!, userUniqueId: uniqueId!, userPhone: phoneNumber)
                            
                            if dbHelper.retrieveUserInfo() {
                                
                                
                                DispatchQueue.main.async {
                                    self?.logIn()
                                }
                            }
                            
                            
                            
                        }catch{
                            print(error)
                        }
                        }.resume()
                }
            })
        }
    }
    
    @objc func emailLoginPressed() {
        
        if emailAddressTextField.text == "" {
            let alert = UIAlertController(title:"Please Enter Email Address", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: {
                    self.emailAddressTextField.becomeFirstResponder()
                })
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if passworkTextField.text == "" || passworkTextField.text == nil {
            let alert = UIAlertController(title:"Please Enter Password", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: {
                    self.passworkTextField.becomeFirstResponder()
                })
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        guard let email = emailAddressTextField.text else { return }
        guard let password = passworkTextField.text else { return }
        
        
        let params = [
            "email": email.trimmingCharacters(in: .whitespaces),
            "password": password.trimmingCharacters(in: .whitespaces)
        ].stringFromHttpParameters()
        
        var request = URLRequest(url: URL(string: RestApi.login + "?" + params)!)
        request.httpMethod = "GET"
        
        URLSession(configuration: .default).dataTask(with: request){[weak self](data, response, error) in
            guard let data = data else {return}
            
            do{
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else { return }
                guard let user = Mapper<User>().map(JSON: json) else {return}
                
                DispatchQueue.main.async {
                    if user.status == 200 {
                        let dbHelper = DBHelper()
                        guard let uniqueId = user.uniqueId else { return }
                        dbHelper.insertUser(userUniqueId: uniqueId)
                        if dbHelper.retrieveUserInfo() {
                            self?.logIn()
                        }
                    }else if user.status == 401 { //email not exists
                        let alert = UIAlertController(title: nil, message: "존재하지 않는 이메일 주소 입니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                    }else if user.status == 402 { //incorrect password
                        let alert = UIAlertController(title: nil, message: "비밀번호가 틀렸습니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
                
                
            }catch{
                print(error)
            }
            
        }.resume()
    }
    
    @objc func signupPressed() {
        let vc = SignUpController()
        vc.loginPage = self
        vc.logInDelegate = self
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)

    }
    
    
}

extension LogIn: LogInDelegate{
    func logIn() {
        self.navigationController?.popViewController(animated: true)
        let vc = HomeViewController(collectionViewLayout : UICollectionViewFlowLayout())
        let nc = UINavigationController(rootViewController: vc)
        self.present(nc, animated: true, completion: nil)
    }
    
    
}
