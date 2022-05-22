import Debug "mo:base/Debug";
import I "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import RBT "mo:base/RBTree";


actor {
  
  let sorted =
  [
    (1, "reformer"),
    (2, "helper"),
    (3, "achiever"),
    (4, "individualist"),
    (5, "investigator"),
    (6, "loyalist"),
    (7, "enthusiast"),
    (8, "challenger"),
    (9, "peacemaker"),
  ];

  let unsort =
  [
    (6, "loyalist"),
    (3, "achiever"),
    (9, "peacemaker"),
    (1, "reformer"),
    (4, "individualist"),
    (2, "helper"),
    (8, "challenger"),
    (5, "investigator"),
    (7, "enthusiast"),
  ];

  var t = RBT.RBTree<Nat, Text>(Nat.compare);

  public query func RBTSize() : async Nat {

    return RBT.size(t.share());
  };
  public func addOneRBT(n : Nat, item : Text) : async (Text){
    t.put(n, item);

    return ("Added : " # Nat.toText(n) # " " # item);
  }; 

  public func addRBTData () : async () {
    
    for((num, lab) in unsort.vals()){
      t.put(num, lab);
    };
    return ();
  };

  public query func showRBT() : async Text {

    var str : Text = "Entries :" ;
    for((num, lab) in t.entries()){
    //  Debug.print(debug_show(lab));
     str #= " (" # Nat.toText(num) # " " # lab # " ),";
    };

    return str;
  };

  public func deleteItem (n : Nat) : async Text {

    t.delete(n);
    return "Deleted item : (" # Nat.toText(n) # ")";
  };

}