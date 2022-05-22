import Buffer "mo:base/Buffer";
import NIspTypes "../nispTypes";
import DRouteTypes "../DRouteTypes";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import MetaTree "../metatree";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Candy "mo:candy/types";
import Conversion "mo:candy/conversion";
import Workspace "mo:candy/workspace";


actor class NIsp() = this {

    type NIspAppRecord = {
            app: Text;
            cycles: Nat;
            blocked: Bool;
        };

    type NIspAccount = {
        principal: Principal.Principal;
        cycles: Nat;
        apps: [NIspAppRecord];
    };

    func serializeNIspAccount(account: NIspAccount) : Candy.Workspace{
        let ws = Workspace.emptyWorkspace();
        let chunks = Buffer.Buffer<Candy.AddressedChunk>(account.apps.size() + 3);
        chunks.add((0,0,#Nat(1))); //version 1
        chunks.add((1,0, #Principal(account.principal)));
        chunks.add((2,0, #Nat(account.cycles)));
        //todo: this won't scale past 2MB of apps
        var appTracker = 0;
        //todo how do we put null items into a datazone?
        if(account.apps.size() > 0){
            for(thisApp in account.apps.vals()){
                chunks.add((3,appTracker, #Text(thisApp.app)));
                chunks.add((4,appTracker, #Nat(thisApp.cycles)));
                chunks.add((5,appTracker, #Bool(thisApp.blocked)));
                appTracker += 1;
            };
        } else {
            chunks.add((3,0, #Empty));
            chunks.add((4,0, #Empty));
            chunks.add((5,0, #Empty));
        };


        Workspace.fileAddressedChunks(ws,chunks.toArray());
        return ws;
    };

    func deSerializeNIspAccountChunks(chunks: Candy.AddressedChunkArray) : ?NIspAccount{
        let ws = Workspace.emptyWorkspace();
        Workspace.fileAddressedChunks(ws,chunks);
        deSerializeNIspAccountWorkspace(ws);
    };

    func deSerializeNIspAccountWorkspace(ws: Candy.Workspace) : ?NIspAccount{
        let version = Conversion.valueUnstableToNat(ws.get(0).get(0));
        if(version == 1){
            let apps = Buffer.Buffer<NIspAppRecord>(ws.get(3).size());
            if(ws.size() > 3){
                //if the apps arent there we don't need to loop
                //todo: how do we pull zones out...
                for(thisApp in Iter.range(0, ws.get(3).size()-1)){
                    let exists = switch(ws.get(3).get(thisApp)){
                            case(#Empty){false;};
                            case(_){true;}
                        };
                    if(exists == true ){
                        apps.add({
                            app = Conversion.valueUnstableToText(ws.get(3).get(thisApp));
                            cycles = Conversion.valueUnstableToNat(ws.get(4).get(thisApp));
                            blocked = Conversion.valueUnstableToBool(ws.get(5).get(thisApp));
                        });
                    };
                };
            };
            return ?{
                principal = Conversion.valueUnstableToPrincipal(ws.get(1).get(0));
                cycles = Conversion.valueUnstableToNat(ws.get(2).get(0));
                apps = apps.toArray();
            }
        };
        return null;
    };

    ///////////////////////////////////
    // todo: this may need to be in the reg canister and a comprable structure in each publishing canister
    ///////////////////////////////////
        stable var upgradeEventRegistration: [DRouteTypes.EventRegistrationStable] = [];

        var registrationStore = HashMap.HashMap<Text, DRouteTypes.EventRegistration>(
            1,
            Text.equal,
            Text.hash
        );
    ///////////////////////////////////
    // /end shared structure
    ///////////////////////////////////




    //todo: make metatree stable
    var metatree = MetaTree.MetaTree(#local);


    //var broadcastLogItemIndex : [MetaTree.MetaTreeIndex] = [
    //    {namespace = "com.nisp.cycleWitness.__eventDRouteID"; dataZone=3; dataChunk=0; indexType = #Nat;},
    //
    //];

    func pricipalAsNat(principal : Principal) : Nat{
        Conversion.bytesToNat(Conversion.principalToBytes(principal));
    };

    func getBalanceWitness(principal : Principal, apps : ?[Text]) : NIspTypes.BalanceWitness {

        //todo: make sure the caller isnt anonymous
        let principalText = Principal.toText(principal);
        //todo: highly inefficent becaue it converst to text
        Debug.print("in get balance witness " # debug_show(principal));
        let thisPrincipal = pricipalAsNat(principal);
        let witness = metatree.getWitnessByNamespace("com.nisp.account." # principalText, thisPrincipal, 0);
        Debug.print("found Witness" # debug_show(witness));
        let balanceRecord = metatree.readUnique("com.nisp.account." # principalText);
        Debug.print("found balance" # debug_show(balanceRecord));
        switch(witness, balanceRecord){
            case(#finalWitness(witness), #data(balanceRecord)){
                Debug.print("handling balance and witness ");

                //todo: probably shouldnt do an unwrap



                if(balanceRecord.data.size() == 0){
                    return #notFound(witness);
                } else {

                    let nispAccount = Option.unwrap(deSerializeNIspAccountChunks(balanceRecord.data[0].data));
                    Debug.print("nisp account " # debug_show(nispAccount));
                    let appBuffer = Buffer.Buffer<(NIspAppRecord)>(switch(apps){case(null){1};case(?app){app.size()}});
                    switch(apps){
                        case(null){};
                        case(?apps){

                            for(thisApp in apps.vals()){
                                label availableApps for(anApp in nispAccount.apps.vals()){
                                    if(thisApp == anApp.app){
                                        appBuffer.add(anApp);
                                        break availableApps;
                                    };
                                };


                            };
                        };
                    };
                    return #found({
                            balance = nispAccount.cycles;
                            witness = witness;
                            apps = appBuffer.toArray();
                        });
                };
            };
            case(#pointer(aPointer),#pointer(bPointer)){
                //todo: document how a witness principal must be on the same canister as the response
                Debug.print("in pointer");
                assert(aPointer.canister == bPointer.canister);
                return #pointer({
                        canister = aPointer.canister;
                        witness = aPointer.witness;
                    });
            };
            case(_,_){
                Debug.print("Shouldnt be here");
                return #err({code=404; text="not implemented subscribe"});
            };
        };
        //return #ok();

        return #err({code=404; text="not implemented subscribe"})
    };


    public  shared query(msg)  func getStatus(apps : ?[Text]) : async Result.Result<NIspTypes.GetStatusResponse, DRouteTypes.PublishError>{

        Debug.print("getting status");
        var currentWitness =  getBalanceWitness(msg.caller, apps);
        Debug.print("have witess " # debug_show(currentWitness));
        switch(currentWitness){
            case(#notFound(result)){
                return #ok(#notFound(result));
            };
            case(#found(result)){
                return #ok(#cycleBalance((result.balance, result.witness)));
            };
            case(#pointer(result)){
                return #ok(#pointer((result.canister, result.witness)));
            };
            case(#err(err)){
                return #err(err);
            };

        };
        Debug.print("returning no record");
        //return #ok(#not);

        return #err({code=404; text="not implemented subscribe"})
    };

    public shared(msg) func updateCycles(principal : Principal, cycles : Nat) : async Bool{
        //todo: only allow for controler
        //todo: never set for anonymous
        Debug.print("adding cylces to principal" # debug_show(pricipalAsNat(principal)));
        let principalText = Principal.toText(principal);
        let principalNat = pricipalAsNat(principal);
        //todo: implement a metatree.readToEnd(readResponse) that makes sure we get the record for an update call
        let balanceRecord = await metatree.readToData(metatree.readUnique("com.nisp.account." # principalText));
        switch(balanceRecord){
            case(#data(balanceResult)){
                if(balanceResult.data.size() > 0 ){
                    let nispAccount = Option.unwrap(deSerializeNIspAccountChunks(balanceResult.data[0].data));
                    let newNispAccount = {
                        principal = nispAccount.principal;
                        cycles = cycles;
                        apps = nispAccount.apps;
                    };
                    let marker = await metatree.replace("com.nisp.account." # principalText,
                        principalNat,
                        //todo: this needs to be a better interface for metatree that takes workspaces and serialization into account. use orthoginal percistance
                        #dataIncluded({data = Workspace.workspaceToAddressedChunkArray(serializeNIspAccount(newNispAccount))}),
                        true);
                    //marker should be 0
                    Debug.print(debug_show(marker));
                    return true;
                } else {
                    let newNispAccount = {
                        principal = principal;
                        cycles = cycles;
                        apps = [];
                    };
                    let marker = await metatree.replace("com.nisp.account." # principalText,
                        principalNat,
                        //todo: this needs to be a better interface for metatree that takes workspaces and serialization into account. use orthoginal percistance
                        #dataIncluded({data = Workspace.workspaceToAddressedChunkArray(serializeNIspAccount(newNispAccount))}),
                        true);
                    //marker should be 0
                    Debug.print(debug_show(marker));
                    return true;
                };
            };
            case(_){return false;}
        };

    };

    public shared(msg) func __resetTest() : async Bool{
        //todo: only allow for controler
        //todo: never set for anonymous

        let marker = await metatree.__resetTest();
        //marker should be 0
        Debug.print("reseting metatree");
        return true;
    };



    system func preupgrade() {


    };

    system func postupgrade() {


    };


};

