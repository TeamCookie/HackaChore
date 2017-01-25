import UIKit

class ChoreListTableViewController: UITableViewController {

  let listToUsers = "ListToUsers"
  
  var items: [ChoreItem] = []
  var user: User!
  var userCountBarButtonItem: UIBarButtonItem!
  
  let ref = FIRDatabase.database().reference(withPath: "chore-items")
  let usersRef = FIRDatabase.database().reference(withPath: "online")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.allowsMultipleSelectionDuringEditing = false
    
    userCountBarButtonItem = UIBarButtonItem(title: "1",
                                             style: .plain,
                                             target: self,
                                             action: #selector(userCountButtonDidTouch))
    userCountBarButtonItem.tintColor = UIColor.white
    navigationItem.leftBarButtonItem = userCountBarButtonItem
    
    FIRAuth.auth()!.addStateDidChangeListener { auth, user in
      guard let user = user else { return }
      self.user = User(authData: user)
      // 1
      let currentUserRef = self.usersRef.child(self.user.uid)
      // 2
      currentUserRef.setValue(self.user.email)
      // 3
      currentUserRef.onDisconnectRemoveValue()
    }
    
    ref.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
      var newItems: [ChoreItem] = []
      
      for item in snapshot.children {
        let choreItem = ChoreItem(snapshot: item as! FIRDataSnapshot)
        newItems.append(choreItem)
      }
      
      self.items = newItems
      self.tableView.reloadData()
    })
    
    usersRef.observe(.value, with: { snapshot in
      if snapshot.exists() {
        self.userCountBarButtonItem?.title = snapshot.childrenCount.description
      } else {
        self.userCountBarButtonItem?.title = "0"
      }
    })
    
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
    let choreItem = items[indexPath.row]
    
    cell.textLabel?.text = choreItem.name
    cell.detailTextLabel?.text = choreItem.addedByUser
    
    toggleCellCheckbox(cell, isCompleted: choreItem.completed)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let choreItem = items[indexPath.row]
      choreItem.ref?.removeValue()
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    let choreItem = items[indexPath.row]
    let toggledCompletion = !choreItem.completed
    toggleCellCheckbox(cell, isCompleted: toggledCompletion)
    choreItem.ref?.updateChildValues([
      "completed": toggledCompletion
      ])
  }
  
  func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
    if !isCompleted {
      cell.accessoryType = .none
      cell.textLabel?.textColor = UIColor.black
      cell.detailTextLabel?.textColor = UIColor.black
    } else {
      cell.accessoryType = .checkmark
      cell.textLabel?.textColor = UIColor.gray
      cell.detailTextLabel?.textColor = UIColor.gray
    }
  }
    
  @IBAction func addButtonDidTouch(_ sender: AnyObject) {
    let alert = UIAlertController(title: "Chore Item",
                                  message: "Add a Chore",
                                  preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
          guard let textField = alert.textFields?.first, let text = textField.text else { return }
          let choreItem = ChoreItem(name: text, addedByUser: self.user.email,
                                        completed: false)
          let choreItemRef = self.ref.child(text.lowercased())
          choreItemRef.setValue(choreItem.toAnyObject())
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .default)
    
    alert.addTextField()
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  func userCountButtonDidTouch() {
    performSegue(withIdentifier: listToUsers, sender: nil)
  }
  
}
