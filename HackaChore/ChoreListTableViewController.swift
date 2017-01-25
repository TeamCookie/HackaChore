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
    
    userCountBarButtonItem = UIBarButtonItem(title: "1", style: .plain, target: self, action: #selector(userCountButtonDidTouch))
    userCountBarButtonItem.tintColor = UIColor.white
    navigationItem.leftBarButtonItem = userCountBarButtonItem
    
    FIRAuth.auth()!.addStateDidChangeListener { auth, user in
      guard let user = user else { return }
      self.user = User(authData: user)
      let currentUserRef = self.usersRef.child(self.user.uid)
      currentUserRef.setValue(self.user.email)
      currentUserRef.onDisconnectRemoveValue()
    }
    
    // ATTACH LISTENER TO OBSERVE FOR VALUE CHANGES OF NEW CHOREITEMS THAT ARE BEING CREATED
    // PLUS ORDER BY COMPLETED SO THAT COMPLETED TASKS FALL BELOW
    ref.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
      var newItems: [ChoreItem] = []
      
      for item in snapshot.children {
        let choreItem = ChoreItem(snapshot: item as! FIRDataSnapshot)
        newItems.append(choreItem)
      }
      
      self.items = newItems
      self.tableView.reloadData()
    })
    
    // OBSERVE FOR VALUE CHANGES TO SET ONLINE UER COUNT
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
    cell.detailTextLabel?.text = "Added By: " + choreItem.addedByUser
    
    toggleCellCheckbox(cell, isCompleted: choreItem.completed, chore: choreItem)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
    // CREATING THE UPDATE BUTTON ON SWIPE
    let updateAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Update" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
      let choreItem = self.items[indexPath.row]
      
      let alert = UIAlertController(title: "Chore Item", message: "Edit a Chore", preferredStyle: .alert)
      
      // ALERT SAVE BUTTON CLICKED AND DB OBJECT UPDATED
      let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
        guard let textField = alert.textFields?.first, let text = textField.text else { return }
        choreItem.ref?.updateChildValues([
          "name": text
          ])
      }
      
      // ALERT CANCEL BUTTON CLICKED
      let cancelAction = UIAlertAction(title: "Cancel", style: .default)
      
      let textField = alert.addTextField(){ (textField) in
        textField.text = choreItem.name
      }
      
      alert.addAction(saveAction)
      alert.addAction(cancelAction)
      self.present(alert, animated: true, completion: nil)
    })
    
    // DELETE CELL ROW SLIDER BUTTON
    let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
      let choreItem = self.items[indexPath.row]
      choreItem.ref?.removeValue()
    })
    updateAction.backgroundColor = UIColor.lightGray
    return [deleteAction,updateAction]
  }
  
  // UPDATING CHECKBOX
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    let choreItem = items[indexPath.row]
    let toggledCompletion = !choreItem.completed
    toggleCellCheckbox(cell, isCompleted: toggledCompletion, chore: choreItem)
    choreItem.ref?.updateChildValues([
      "completed": toggledCompletion,
      "completedByUser": self.user.email
      ])
  }
  
  func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool, chore: ChoreItem) {
    // STYLING FOR INCOMPLETE ITEMS
    if !isCompleted {
      cell.accessoryType = .none
      cell.textLabel?.textColor = UIColor.black
      cell.detailTextLabel?.textColor = UIColor.black
      cell.detailTextLabel?.text = "Added By: " + chore.addedByUser
      
    } else {
      // STYLING FOR COMPLETE ITEMS
      cell.accessoryType = .checkmark
      cell.textLabel?.textColor = UIColor.gray
      cell.detailTextLabel?.textColor = UIColor.gray
      cell.detailTextLabel?.text = "Added By: " + chore.addedByUser + " / Completed By:" + chore.completedByUser
    }
  }
    
  @IBAction func addButtonDidTouch(_ sender: AnyObject) {

    let alert = UIAlertController(title: "Chore Item", message: "Add a Chore", preferredStyle: .alert)
    
    // ALERT SAVE BUTTON PRESSED AND SAVED TO DB
    let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
      guard let textField = alert.textFields?.first, let text = textField.text else { return }
      let choreItem = ChoreItem(name: text, addedByUser: self.user.email, completedByUser: "", completed: false)
      let choreItemRef = self.ref.child(text.lowercased())
      choreItemRef.setValue(choreItem.toAnyObject())
    }
    
    // ALERT CANCEL BUTTON PRESSED
    let cancelAction = UIAlertAction(title: "Cancel", style: .default)
    
    alert.addTextField()
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  func userCountButtonDidTouch() {
    performSegue(withIdentifier: listToUsers, sender: nil)
  }
  
}
