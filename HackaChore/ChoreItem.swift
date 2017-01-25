import Foundation

struct ChoreItem {
  
  let key: String
  let name: String
  let addedByUser: String
  let completedByUser: String
  let ref: FIRDatabaseReference?
  var completed: Bool
  
  init(name: String, addedByUser: String, completedByUser: String, completed: Bool, key: String = "") {
    self.key = key
    self.name = name
    self.addedByUser = addedByUser
    self.completedByUser = completedByUser
    self.completed = completed
    self.ref = nil
  }
  
  init(snapshot: FIRDataSnapshot) {
    key = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    name = snapshotValue["name"] as! String
    addedByUser = snapshotValue["addedByUser"] as! String
    completedByUser = snapshotValue["completedByUser"] as! String
    completed = snapshotValue["completed"] as! Bool
    ref = snapshot.ref
  }
  
  func toAnyObject() -> Any {
    return [
      "name": name,
      "addedByUser": addedByUser,
      "completedByUser": completedByUser,
      "completed": completed
    ]
  }
  
}
