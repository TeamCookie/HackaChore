import UIKit

class LoginViewController: UIViewController {
  
  // MARK: Constants
  let loginToList = "LoginToList"
  
  // MARK: Outlets
  @IBOutlet weak var textFieldLoginEmail: UITextField!
  @IBOutlet weak var textFieldLoginPassword: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 1
    FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
      // 2
      if user != nil {
        // 3
        self.performSegue(withIdentifier: self.loginToList, sender: nil)
      }
    }
  }
  
  // MARK: Actions
  @IBAction func loginDidTouch(_ sender: AnyObject) {
//    performSegue(withIdentifier: loginToList, sender: nil)
      FIRAuth.auth()!.signIn(withEmail: textFieldLoginEmail.text!,
                             password: textFieldLoginPassword.text!)
  }
  
  @IBAction func signUpDidTouch(_ sender: AnyObject) {
    let alert = UIAlertController(title: "Register", message: "Register", preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { action in
      
      // 1
      let emailField = alert.textFields![0]
      let passwordField = alert.textFields![1]
      
      // 2
      FIRAuth.auth()!.createUser(withEmail: emailField.text!,
                                 password: passwordField.text!) { user, error in
                                  if error == nil {
                                    // 3
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
