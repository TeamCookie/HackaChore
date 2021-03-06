import UIKit

class LoginViewController: UIViewController {

  let loginToList = "LoginToList"
  
  @IBOutlet weak var textFieldLoginEmail: UITextField!
  @IBOutlet weak var textFieldLoginPassword: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // SETTING BACKGROUND IMAGE FOR LOGIN PAGE
    var bgImage = UIImage(named: "background")
    var imageView = UIImageView(frame: self.view.bounds)
    imageView.image = bgImage
    self.view.addSubview(imageView)
    self.view.sendSubview(toBack: imageView)
    
    FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
      if user != nil {
        self.performSegue(withIdentifier: self.loginToList, sender: nil)
      }
    }
  }
  
  @IBAction func loginDidTouch(_ sender: AnyObject) {
      FIRAuth.auth()!.signIn(withEmail: textFieldLoginEmail.text!, password: textFieldLoginPassword.text!)
  }
  
  @IBAction func signUpDidTouch(_ sender: AnyObject) {
    let alert = UIAlertController(title: "Register", message: "Register", preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { action in
      
      let emailField = alert.textFields![0]
      let passwordField = alert.textFields![1]
      
      FIRAuth.auth()!.createUser(withEmail: emailField.text!,
                                 password: passwordField.text!) { user, error in
                                  if error == nil {

                                    FIRAuth.auth()!.signIn(withEmail: self.textFieldLoginEmail.text!,
                                                           password: self.textFieldLoginPassword.text!)
                                  }
      }
                                    
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .default)
    
    alert.addTextField { textEmail in
      textEmail.placeholder = "Enter your email"
    }
    
    alert.addTextField { textPassword in
      textPassword.isSecureTextEntry = true
      textPassword.placeholder = "Enter your password"
    }
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
  
}

extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == textFieldLoginEmail {
      textFieldLoginPassword.becomeFirstResponder()
    }
    if textField == textFieldLoginPassword {
      textField.resignFirstResponder()
    }
    return true
  }
  
}
