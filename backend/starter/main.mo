import Welcome  "canister:welcome";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";

actor {
    stable var currentValue: Nat = 0;

    public func increment(): async () {
        currentValue += 1;
    };

    public query func getValue(): async Nat {
        currentValue;
    };

    // Get query for hello world
    public query func hello() : async Text {
        return "Hello world from Internet Computer!";
    };
    // Get message for greeting
    public func greet(msg : Text) : async Text {
        return msg;
    };

    public func sayHiFromAnotherCanister() : async Text {
        let hi : Text = await Welcome.greetBack();
        return hi;
    };
    //Whitelist

    // Remove items from an array
    // Pass an array [Text] and remove items from array a
    let a : [Text] = ["a", "b", "c"];
    public func removeFromArray (y : [Text]) : async [Text] {
         
         let res = Buffer.Buffer<Text>(0);
       
         for( thisItem in a.vals()){
            var add = true;
            label search for(thatItem in y.vals()){
                if(thisItem == thatItem){
                    add := false;
                    break search;
                }; 
            };
            if(add == true){
                res.add(thisItem);
            };
        };
        
        return res.toArray();
    };

    // Add array items to array b without duplication
    // Pass an array [Text] and add items to array a
    let b : [Text] = ["a", "b", "c"];
    public func addArrayItemsToArray (y : [Text]) : async [Text] {
          
         let res = Buffer.Buffer<Text>(0);
         for(i in b.vals()){
            res.add(i);
         };
         for( thisItem in y.vals()){
            var add = true;
            label search for(thatItem in b.vals()){
                if(thisItem == thatItem){
                    add := false;
                    break search;
                }; 
            };
            if(add == true){
                res.add(thisItem);
            };
        };
        
        return res.toArray();
    };
    
    // Filter array
    // Pass an array [Text] to filter from array c
    let c : [Text] = ["a", "b", "c"];
    // Predicate function from filter function
    let f = func (t : Text) : Bool {
         var r = false;
        for(item in c.vals()){
            if(item == t){
                r := true;
            }
        };
        return r;
    };

    public query func filter(y : [Text]) : async [Text] {
        let m = Array.filter<Text>(y , f );
        return m;
    };
};
