//
//  SignUpController.swift
//  Archive Box
//
//  Created by SongChiduk on 23/04/2019.
//  Copyright © 2019 BuxBox. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class SignUpController : UIViewController, UITextFieldDelegate {
    weak var logInDelegate: LogInDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Color.hexStringToUIColor(hex: "#333333")
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEdit))
        view.addGestureRecognizer(tap)
        setupKeyBoardNotification()
        setupview()
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
    
    @objc func endEdit() {
        view.endEditing(true)
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
        UIView.animate(withDuration: self.keyBoardDuration, animations: {
            self.scrollView.contentOffset.y = 0
        })
    }
    
    deinit {
        print("SignUpController denit successful")
    }
    
    var closeButton : UIButton!
    
    let closeButtonHeight : CGFloat = 40
    
    var loginPage : LogIn?
    
    var scrollView : UIScrollView!
    
    let fieldHeight : CGFloat = 50
    
    
    let firstNameLabel : UILabel = {
        let f = UILabel()
        f.text = "이름"
        f.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        f.textColor = .white
        return f
    }()
    
    var firstNameView : UIView!
    var firstNameField : UITextField!
    
    let lastNameLabel : UILabel = {
        let f = UILabel()
        f.text = "성"
        f.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        f.textColor = .white
        return f
    }()
    
    var lastNameView : UIView!
    var lastNameField : UITextField!
    
    
    let emailLabel : UILabel = {
        let f = UILabel()
        f.text = "이메일 주소"
        f.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        f.textColor = .white
        return f
    }()
    
    var emailView : UIView!
    var emailField : UITextField!
    
    let passWordLabel : UILabel = {
        let f = UILabel()
        f.text = "암호"
        f.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        f.textColor = .white
        return f
    }()
    
    let confirmPasswordLabel : UILabel = {
        let f = UILabel()
        f.text = "암호 재입력"
        f.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        f.textColor = .white
        return f
    }()
    
    var passWordView : UIView!
    var passWordField : UITextField!
    let confirmPasswordField = UITextField()
    let confirmPasswordView = UIView()
    
    var signUpButton : UIButton!
    
    func setupview() {
        closeButton = UIButton()
        closeButton.setImage(UIImage(named: "closeXIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        
        view.addSubview(closeButton)
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: marginBase*2).isActive = true
        closeButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: closeButtonHeight).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: closeButtonHeight).isActive = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        scrollView = UIScrollView()
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
        
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: closeButton.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        
        scrollView.addSubview(firstNameLabel)
        firstNameLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: marginBase*2).isActive = true
        firstNameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*4).isActive = true
        firstNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        firstNameView = UIView()
        firstNameView.backgroundColor = .white
        scrollView.addSubview(firstNameView)
        firstNameView.topAnchor.constraint(equalTo: firstNameLabel.bottomAnchor, constant: marginBase).isActive = true
        firstNameView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
        firstNameView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -marginBase*2).isActive = true
        firstNameView.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        firstNameView.translatesAutoresizingMaskIntoConstraints = false
        firstNameView.layer.cornerRadius = 15
        
        firstNameField = UITextField()
        firstNameField.delegate = self
        firstNameField.placeholder = "이름 입력"
        firstNameView.addSubview(firstNameField)
        firstNameField.centerYAnchor.constraint(equalTo: firstNameView.centerYAnchor).isActive = true
        firstNameField.leftAnchor.constraint(equalTo: firstNameView.leftAnchor, constant: marginBase*2).isActive = true
        firstNameField.rightAnchor.constraint(equalTo: firstNameView.rightAnchor, constant: -marginBase*2).isActive = true
        firstNameField.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        firstNameField.translatesAutoresizingMaskIntoConstraints = false
        
        
        scrollView.addSubview(lastNameLabel)
        lastNameLabel.topAnchor.constraint(equalTo: firstNameView.bottomAnchor, constant: marginBase*2).isActive = true
        lastNameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*4).isActive = true
        lastNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        lastNameView = UIView()
        scrollView.addSubview(lastNameView)
        lastNameView.topAnchor.constraint(equalTo: lastNameLabel.bottomAnchor, constant: marginBase).isActive = true
        lastNameView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
        lastNameView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -marginBase*2).isActive = true
        lastNameView.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        lastNameView.translatesAutoresizingMaskIntoConstraints = false
        lastNameView.layer.cornerRadius = 15
        lastNameView.backgroundColor = .white
        
        lastNameField = UITextField()
        lastNameField.delegate = self
        lastNameField.placeholder = "성 입력"
        lastNameView.addSubview(lastNameField)
        lastNameField.centerYAnchor.constraint(equalTo: lastNameView.centerYAnchor).isActive = true
        lastNameField.leftAnchor.constraint(equalTo: lastNameView.leftAnchor, constant: marginBase*2).isActive = true
        lastNameField.rightAnchor.constraint(equalTo: lastNameView.rightAnchor, constant: -marginBase*2).isActive = true
        lastNameField.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        lastNameField.translatesAutoresizingMaskIntoConstraints = false
        
        
        scrollView.addSubview(emailLabel)
        emailLabel.topAnchor.constraint(equalTo: lastNameView.bottomAnchor, constant: marginBase*2).isActive = true
        emailLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*4).isActive = true
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        emailView = UIView()
        scrollView.addSubview(emailView)
        emailView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: marginBase).isActive = true
        emailView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
        emailView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -marginBase*2).isActive = true
        emailView.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        emailView.translatesAutoresizingMaskIntoConstraints = false
        emailView.layer.cornerRadius = 15
        emailView.backgroundColor = .white
        
        emailField = UITextField()
        emailField.delegate = self
        emailField.placeholder = "이메일 주소 입력"
        emailField.keyboardType = .emailAddress
        
        emailView.addSubview(emailField)
        emailField.centerYAnchor.constraint(equalTo: emailView.centerYAnchor).isActive = true
        emailField.leftAnchor.constraint(equalTo: emailView.leftAnchor, constant: marginBase*2).isActive = true
        emailField.rightAnchor.constraint(equalTo: emailView.rightAnchor, constant: -marginBase*2).isActive = true
        emailField.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        emailField.translatesAutoresizingMaskIntoConstraints = false
        
        
        scrollView.addSubview(passWordLabel)
        passWordLabel.topAnchor.constraint(equalTo: emailView.bottomAnchor, constant: marginBase*2).isActive = true
        passWordLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*4).isActive = true
        passWordLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        passWordView = UIView()
        scrollView.addSubview(passWordView)
        passWordView.topAnchor.constraint(equalTo: passWordLabel.bottomAnchor, constant: marginBase).isActive = true
        passWordView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase*2).isActive = true
        passWordView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -marginBase*2).isActive = true
        passWordView.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        passWordView.translatesAutoresizingMaskIntoConstraints = false
        passWordView.layer.cornerRadius = 15
        passWordView.backgroundColor = .white
        
        passWordField = UITextField()
        passWordField.delegate = self
        passWordField.placeholder = "암호 입력"
        passWordField.isSecureTextEntry = true
        
        passWordView.addSubview(passWordField)
        passWordField.centerYAnchor.constraint(equalTo: passWordView.centerYAnchor).isActive = true
        passWordField.leftAnchor.constraint(equalTo: passWordView.leftAnchor, constant: marginBase*2).isActive = true
        passWordField.rightAnchor.constraint(equalTo: passWordView.rightAnchor, constant: -marginBase*2).isActive = true
        passWordField.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        passWordField.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(confirmPasswordLabel)
        confirmPasswordLabel.topAnchor.constraint(equalTo: passWordView.bottomAnchor, constant: marginBase * 2).isActive = true
        confirmPasswordLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase * 4).isActive = true
        confirmPasswordLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(confirmPasswordView)
        confirmPasswordView.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: marginBase).isActive = true
        confirmPasswordView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: marginBase * 2).isActive = true
        confirmPasswordView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -marginBase * 2).isActive = true
        confirmPasswordView.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        confirmPasswordView.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordView.layer.cornerRadius = 15
        confirmPasswordView.backgroundColor = .white
        
        confirmPasswordField.delegate = self
        confirmPasswordField.placeholder = "암호 재입력"
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordView.addSubview(confirmPasswordField)
        confirmPasswordField.centerYAnchor.constraint(equalTo: confirmPasswordView.centerYAnchor).isActive = true
        confirmPasswordField.leftAnchor.constraint(equalTo: confirmPasswordView.leftAnchor, constant: marginBase * 2).isActive = true
        confirmPasswordField.rightAnchor.constraint(equalTo: confirmPasswordView.rightAnchor, constant: -marginBase * 2).isActive = true
        confirmPasswordField.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        confirmPasswordField.translatesAutoresizingMaskIntoConstraints = false
        
        signUpButton = UIButton()
        signUpButton.setTitle("가입", for: .normal)
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.backgroundColor = Color.hexStringToUIColor(hex: "#FFA00A")
        signUpButton.layer.cornerRadius = 15
        signUpButton.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        scrollView.addSubview(signUpButton)
        signUpButton.topAnchor.constraint(equalTo: confirmPasswordView.bottomAnchor, constant: marginBase*3).isActive = true
        signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signUpButton.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        signUpButton.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+self.keyboardHeight)
            let closeHeight = self.closeButtonHeight + (marginBase*2)
            let availableView = self.view.frame.height - self.keyboardHeight
            
            if textField == self.firstNameField {
                
                let origin = self.firstNameView.frame.origin.y + self.fieldHeight + (marginBase*4) + closeHeight
                let coordinate =  self.firstNameField.superview?.convert(self.firstNameField.frame.origin, to: self.view)
                let ycoordinate = (coordinate?.y)! + self.fieldHeight
                
                if ycoordinate > availableView {
                    
                    UIView.animate(withDuration: self.keyBoardDuration, animations: {
                        self.scrollView.contentOffset.y = origin - availableView
                    })
                    
                }
            } else if textField == self.lastNameField {
                let origin = self.lastNameView.frame.origin.y + self.fieldHeight + (marginBase*4) + closeHeight
                let coordinate =  self.lastNameField.superview?.convert(self.lastNameField.frame.origin, to: self.view)
                
                let ycoordinate = (coordinate?.y)! + self.fieldHeight
                
                if ycoordinate > availableView {
                    
                    UIView.animate(withDuration: self.keyBoardDuration, animations: {
                        self.scrollView.contentOffset.y = origin - availableView
                    })
                    
                }
            } else if textField == self.emailField {
                let origin = self.emailView.frame.origin.y + self.fieldHeight + (marginBase*4) + closeHeight
                let coordinate =  self.emailField.superview?.convert(self.emailField.frame.origin, to: self.view)
                
                let ycoordinate = (coordinate?.y)! + self.fieldHeight
                
                if ycoordinate > availableView {
                    
                    UIView.animate(withDuration: self.keyBoardDuration, animations: {
                        self.scrollView.contentOffset.y = origin - availableView
                    })
                    
                }
            } else if textField == self.passWordField {
                let origin = self.passWordView.frame.origin.y + self.fieldHeight + (marginBase*4) + closeHeight
                let coordinate =  self.passWordField.superview?.convert(self.passWordField.frame.origin, to: self.view)
                
                let ycoordinate = (coordinate?.y)! + self.fieldHeight
                
                if ycoordinate > availableView {
                    
                    UIView.animate(withDuration: self.keyBoardDuration, animations: {
                        self.scrollView.contentOffset.y = origin - availableView
                    })
                    
                }
            }else if textField == self.confirmPasswordField {
                let origin = self.confirmPasswordView.frame.origin.y + self.fieldHeight + (marginBase*4) + closeHeight + self.fieldHeight + (marginBase * 7)
                let coordinate =  self.confirmPasswordField.superview?.convert(self.confirmPasswordField.frame.origin, to: self.view)
                
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
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passWordField.becomeFirstResponder()
        } else if textField == passWordField {
            endEdit()
        } else if textField == confirmPasswordField {
            endEdit()
        }
        return true
    }
    
    
    @objc func signUpPressed() {
        if firstNameField.text == "" {
            let alert = UIAlertController(title:"이름을 입력 하여 주세요", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: {
                    self.firstNameField.becomeFirstResponder()
                })
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if lastNameField.text == "" {
            let alert = UIAlertController(title:"성을 입력 하여 주세요", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: {
                    self.lastNameField.becomeFirstResponder()
                })
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if emailField.text == "" {
            let alert = UIAlertController(title:"이메일 주소를 입력 하여 주세요", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: {
                    self.emailField.becomeFirstResponder()
                })
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if passWordField.text == "" {
            let alert = UIAlertController(title:"암호를 입력 하여 주세요", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: {
                    self.passWordField.becomeFirstResponder()
                })
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if confirmPasswordField.text == "" {
            let alert = UIAlertController(title:"암호를 재입력 하여 주세요", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: {
                    self.confirmPasswordField.becomeFirstResponder()
                })
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let firstName = firstNameField.text else {return}
        guard let lastName = lastNameField.text else {return}
        guard let email = emailField.text else {return}
        guard let password = passWordField.text else {return}
        guard let confirmPassword = confirmPasswordField.text else {return}
        
        if password.contains(" ") {
            let alert = UIAlertController(title:"암호는 공백없이 4글자 이상이어야 합니다.", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: {
                    self.confirmPasswordField.becomeFirstResponder()
                })
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if password.count < 4 {
            let alert = UIAlertController(title:"암호는 공백없이 4글자 이상이어야 합니다.", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: {
                    self.confirmPasswordField.becomeFirstResponder()
                })
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if password != confirmPassword {
            let alert = UIAlertController(title:"입력하신 암호가 일치 하지 않습니다.", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{(action: UIAlertAction!) in
                alert.dismiss(animated: true, completion: {
                    self.confirmPasswordField.becomeFirstResponder()
                })
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let params = [
            "firstName": firstName.trimmingCharacters(in: .whitespaces),
            "lastName": lastName.trimmingCharacters(in: .whitespaces),
            "email": email.trimmingCharacters(in: .whitespaces),
            "password": password.trimmingCharacters(in: .whitespaces)
        ].stringFromHttpParameters()
        
        var request = URLRequest(url: URL(string: RestApi.register + "?" + params)!)
        request.httpMethod = "GET"
        self.showSpinner(onView: self.view)
        URLSession(configuration: .default).dataTask(with: request){[weak self](data, response ,error) in
            self?.removeSpinner()
            guard let data = data else {return }
            
            do{
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {return}
                guard let user = Mapper<User>().map(JSON: json) else {return}
                
                DispatchQueue.main.async {
                    let dbHelper = DBHelper()
                    
                    if user.status == 200 {
                        guard let uniqueId = user.uniqueId else {return}
                        dbHelper.insertUser(userUniqueId: uniqueId)
                        if dbHelper.retrieveUserInfo() {
                            self?.dismissView()
                            self?.logInDelegate?.logIn()
                        }else{
                            let alert = UIAlertController(title: nil, message: "가입 중 오류가 발생 하였습니다. 앱을 재실행 해주세요.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: {(action) in
                                
                            }))
                            
                            self?.present(alert, animated: true, completion: nil)
                        }
                    }else if user.status == 403 {
                        let alert = UIAlertController(title: nil, message: "이미 사용중인 이메일 주소 입니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: {(action) in
            
                        }))
                        
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
               
                
            }catch{
                print(error)
                
            }
        }.resume()
        
       
    }
    
    
    @objc func dismissView() {
        self.dismiss(animated: true) {
            print("closed")
        }
    }
    
}
