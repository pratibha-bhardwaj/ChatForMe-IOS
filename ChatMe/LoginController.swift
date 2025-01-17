//
//  LoginController.swift
//  ChatMe
//
//  Created by Sultan on 30/03/18.
//  Copyright © 2018 Sultan. All rights reserved.
//

import UIKit
import FirebaseAuth
import MapKit
import CoreLocation

class LoginController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var weatherTextLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var userLocations = CLLocationCoordinate2D()
    var locationValue = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        locationManagerSetup()
        NotificationCenter.default.addObserver(self, selector: #selector(updateWeatherLabel) , name: Notification.Name.ValueChanged, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
        if let _ = Auth.auth().currentUser{
            performSegue(withIdentifier: "mainActivity", sender: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @objc func updateWeatherLabel(){
        let networkingInstance = Networking()
        locationValue = networkingInstance.getValues()
        DispatchQueue.main.async {
            self.weatherTextLabel.text = "Today It's \(self.locationValue[0]) over \(self.locationValue[1])"
        }
    }
    
    fileprivate func initialView() {
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.white.cgColor
        emailTextField.layer.cornerRadius = 20
        emailTextField.clipsToBounds = true
        emailTextField.delegate = self
        
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.white.cgColor
        passwordTextField.layer.cornerRadius = 20
        passwordTextField.clipsToBounds = true
        passwordTextField.delegate = self
        
        loginBtn.layer.cornerRadius = 20
        loginBtn.clipsToBounds = true
        
        registerBtn.layer.cornerRadius = 10
        registerBtn.clipsToBounds = true
    }
    
    fileprivate func locationManagerSetup() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    //MARK: IBACTIONS
    @IBAction func registerActivity(_ sender: Any) {
        performSegue(withIdentifier: "registerSegue", sender: sender)
    }
    
    @IBAction func loginActivity(_ sender: Any) {
        if (emailTextField.text != "" && passwordTextField.text != ""){
            activityIndicator.startAnimating()
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if user != nil { //User Signed In Successfully
                    self.activityIndicator.stopAnimating()
                    self.performSegue(withIdentifier: "mainActivity", sender: sender)
                } else { //Failed Authentication
                    self.showAlertView(alertMessage: (error?.localizedDescription)!)
                    self.activityIndicator.stopAnimating()
                }
            })
        }
    }
    
}
//MARK: TEXTFIELD DELEGATES
extension UIViewController:UITextFieldDelegate{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: UI CHANGE FOR KEYBOARD
extension LoginController{
    func subscribeToKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(returnKeyboardBack), name: .UIKeyboardWillHide, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func keyboardWillShow(_ notification:Notification) {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation){
            if (passwordTextField.isFirstResponder || emailTextField.isFirstResponder) {
                view.frame.origin.y = (-getKeyboardHeight(notification)+50)
            }
        } else {
            if (passwordTextField.isFirstResponder) {
                view.frame.origin.y = (-getKeyboardHeight(notification)+100)
            }
        }
    }
    @objc func returnKeyboardBack(){
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation){
            if (passwordTextField.isFirstResponder || emailTextField.isFirstResponder) {
                view.frame.origin.y=0
            }
        } else {
            if (passwordTextField.isFirstResponder) {
                view.frame.origin.y=0
            }
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
}

extension LoginController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocations = (manager.location?.coordinate)!
        let networkInstance = Networking()
        locationValue = networkInstance.networkSession(userCoordinate: userLocations)
        locationManager.stopUpdatingLocation()
    }
}





