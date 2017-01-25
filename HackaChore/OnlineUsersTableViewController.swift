import UIKit

class OnlineUsersTableViewController: UITableViewController {
  
  let userCell = "UserCell"
  
  var currentUsers: [String] = []
  let usersRef = FIRDatabase.database().reference(withPath: "online")
  var user: User!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    usersRef.observe(.childAdded, with: { snap in
      guard let email = snap.value as? String else { return }
      self.currentUsers.append(email)
      let row = self.currentUsers.count - 1
      let indexPath = IndexPath(row: row, section: 0)
      self.tableView.insertRows(at: [indexPath], with: .top)
    })
    
    usersRef.observe(.childRemoved, with: { snap in
      guard let emailToFind = snap.value as? String else { return }
      for (index, email) in self.currentUsers.enumerated() {
        if email == emailToFind {
          let indexPath = IndexPath(row: index, section: 0)
          self.currentUsers.remove(at: index)
          self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
      }
    })
    
    FIRAuth.auth()!.addStateDidChangeListener { auth, user in
      if let _user = user {
        self.user = User(authData: _user)
      } else {
        let userRef = self.usersRef.child(self.user.uid)
        userRef.removeValue()
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentUsers.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath)
    let onlineUserEmail = currentUsers[indexPath.row]
    cell.textLabel?.text = onlineUserEmail
    return cell
  }
    
  @IBAction func signoutButtonPressed(_ sender: AnyObject) {
    do {
      try FIRAuth.auth()?.signOut()
      dismiss(animated: true, completion: nil)
    } catch let error as NSError {
      print(error.localizedDescription)
    }
    dismiss(animated: true, completion: nil)
  }
  
}
