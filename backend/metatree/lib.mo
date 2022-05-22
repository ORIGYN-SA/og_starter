///////////////////////////////
/*
©2021 RIVVIR Tech LLC
All Rights Reserved.
This code is released for code verification purposes. All rights are retained by RIVVIR Tech LLC and no re-distribution or alteration rights are granted at this time.
*/
///////////////////////////////

import Text "mo:base/Text";
import Result "mo:base/Result";
import Principal "mo:principal/Principal";
import Hash "mo:base/Hash";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Int "mo:base/Int";
import Prelude "mo:base/Prelude";
import Blob "mo:base/Blob";

import Buffer "mo:base/Buffer";

import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Option "mo:base/Option";

import HashMap "mo:base/HashMap";
import Candy "mo:candy/types";
import Conversion "mo:candy/conversion";
import Workspace "mo:candy/workspace";
import SHA256 "../dRouteUtilities/SHA256";
import MerkleTree "../dRouteUtilities/MerkleTree";
import CertifiedData "mo:base/CertifiedData";

import PipelinifyTypes "mo:pipelinify/types";

module {
    type AddressedChunkArray = Candy.AddressedChunkArray;


    public type Entry = {
        primaryID: Nat;
        marker: Nat;
        data: AddressedChunkArray;
    };

    public type EntryGroup = {
        entries : [Entry];
        firstKey : Nat;
        firstMarker : Nat;
        lastKey: Nat;
        lastMarker : Nat;
        indexCanister: {
            #this; //held here
            #remote: Principal;};
    };

    public type ReadResponse = {
        #notFound;
        #data : {
            data: [Entry];
            lastID: ?Nat;
            lastMarker: ?Nat;
            firstID: ?Nat;
            firstMarker : ?Nat;
        };
        #pointer : {
            canister: Principal;
            namespace : Text;
            minID : ?Nat;
            maxID : ?Nat;
            lastID : Nat;
            lastMarker: Nat;
        };
    };

    public type WitnessResponse = {
        #finalWitness: MerkleTree.Witness;
        #pointer : {
            canister: Principal;
            witness: MerkleTree.Witness;
        }
    };

    public type MetaTreeConfig = {
        #local;
    };

    public type MetaTreeIndex = {
        namespace : Text;
        dataZone: Nat;
        dataChunk: Nat;
        indexType: {
            #Nat;
            #Text;
            #Int;
            #Dyanamic : Principal;
            #Principal;
        };
    };

    public type MetaTreeActor = actor {
        readToData : (namespace : Text, minID : ?Nat, maxID : ?Nat, lastID : Nat, lastMarker: Nat) -> async ReadResponse;
    };


    public class MetaTree(config: MetaTreeConfig){
        //todo: add the container's merkle tree to the config;

        //need to start at 1 instead of 0 becuase we can't do -1 and first item will not be detected
        var nonce : Nat = 1;

        func bigNatToNat32(n : Nat) : Nat32{
            Nat32.fromNat(Nat.rem(n, 4_294_967_295));
        };

        //todo: we really need a sha256 Hashmap
        var namespaceMap : HashMap.HashMap<Nat,[EntryGroup]> = HashMap.HashMap<Nat,[EntryGroup]>(1, Nat.equal, bigNatToNat32);
        var certifiedTree = MerkleTree.empty();
        let natToBytes = Conversion.natToBytes;
        let h = MerkleTree.h;
        let h2 = MerkleTree.h2;
        let h3 = MerkleTree.h3;

        func certify(namespace: Nat, primaryID: Nat, marker: Nat, data: AddressedChunkArray){
            Debug.print("certifying namespace:" # debug_show(namespace) # " primary:" # debug_show(primaryID) # " Marker:" # debug_show(marker));
            let key = h2("\0dmetatree-cert",
                h3(
                    Blob.fromArray(
                        natToBytes(namespace)),
                    Blob.fromArray(
                        natToBytes(primaryID)),
                    Blob.fromArray(
                        natToBytes(marker))));
            Debug.print("writing key " # debug_show(key));
            let value = h(Blob.fromArray(Workspace.flattenAddressedChunkArray(data)));
            certifiedTree := MerkleTree.put(certifiedTree, key, value);
            CertifiedData.set(MerkleTree.treeHash(certifiedTree));
        };

        public func getWitness(namespace: Nat, primaryID: Nat, marker: Nat) : WitnessResponse{
            //todo: what if the witness is on a different canister - combine them
            Debug.print("in get witness namespace" # debug_show(namespace) # " Primary:" # debug_show(primaryID) # " marker:" # debug_show(marker));
            let key = h2("\0dmetatree-cert",
                h3(
                    Blob.fromArray(
                        natToBytes(namespace)),
                    Blob.fromArray(
                        natToBytes(primaryID)),
                    Blob.fromArray(
                        natToBytes(marker))));

            Debug.print("key " # debug_show(key));

            //todo: check to see if the witness i son this canister or not
            let witness = MerkleTree.reveal(certifiedTree, key);
            return #finalWitness(witness);
        };

        public func getWitnessByNamespace(namespace: Text, primaryID: Nat, marker: Nat) :  WitnessResponse {
            getWitness(namespaceToHash(namespace), primaryID, marker);
        };

        func namespaceToHash(namespace: Text) : Nat{
            return Conversion.bytesToNat(SHA256.sha256(Conversion.textToBytes(namespace)))
        };

        public func write(namespace : Text, primaryID : Nat, dataConfig: PipelinifyTypes.DataConfig, bCertify : Bool) : async Nat{
            //todo: write to metatree service
            let marker = nonce;
            nonce += 1;
            let namespaceHash = namespaceToHash(namespace);

            let currentList : ?[EntryGroup] = namespaceMap.get(namespaceHash);
            switch(currentList, dataConfig){
                case(null, #dataIncluded(data)){
                    Debug.print("no list for namespace " # namespace);
                    namespaceMap.put(namespaceHash, [{
                        entries = [{primaryID = primaryID; marker = marker; data = data.data}];
                        firstKey = primaryID;
                        firstMarker = marker;
                        lastKey = primaryID;
                        lastMarker = marker;
                        indexCanister = #this; }]
                    );
                    if(bCertify == true){
                        certify(namespaceHash, primaryID, marker,data.data);
                    };
                };
                case(?currentList, #dataIncluded(data)){
                    Debug.print("found list for namespace " # namespace # " " #  debug_show(currentList.size()));
                    var bIn = false;
                    //todo handle what to do if the list is full(split)
                    let currentListSize = currentList[0].entries.size();
                    //todo: test inserting in the middle of the list.
                    //todo: need to not have a chunk go over 2MB
                    //todo: need to partition
                    var newMinKey = 0;
                    var newMinMarker = 0;
                    var newMaxKey = 0;
                    var newMaxMarker = 0;

                    let newArray = Array.tabulate<Entry>(currentListSize + 1, func(idx){
                        if(idx == 0){
                            newMinKey := currentList[0].firstKey;
                            newMinMarker := currentList[0].firstMarker;
                        };
                        if(idx == currentListSize){
                            newMaxKey := currentList[0].lastKey;
                            newMaxMarker := currentList[0].lastMarker;
                        };
                        if(bIn == false){
                            Debug.print("bIn is false");

                            if(idx < currentListSize and (primaryID > currentList[0].entries[idx].primaryID or (primaryID == currentList[0].entries[idx].primaryID and marker > currentList[0].entries[idx].marker))){
                                //Debug.print("keeping the same" # debug_show(idx));
                                return currentList[0].entries[idx];
                            } else {

                                //Debug.print("found the place to insert and adding an item");
                                bIn := true;

                                if(idx == 0){
                                    newMinKey := primaryID;
                                    newMinMarker := marker;
                                };
                                if(idx == currentListSize){
                                    newMaxKey := primaryID;
                                    newMaxMarker := marker;
                                };
                                return {
                                    primaryID = primaryID;
                                    marker = marker;
                                    data = data.data
                                };
                            };

                        } else {
                            //Debug.print("bIn is true inserting one back");
                            return currentList[0].entries[idx - 1];
                        };
                    });
                    Debug.print("inserting new array" # debug_show(newArray.size()));
                    namespaceMap.put(namespaceHash, [{
                        entries = newArray;
                        firstKey = newMinKey;
                        firstMarker = newMinMarker;
                        lastKey = newMaxKey;
                        lastMarker = newMaxMarker;
                        indexCanister = #this;
                        }
                    ]);
                    if(bCertify == true){
                        //todo: handle certification for splits
                        certify(namespaceHash, primaryID, marker,data.data);
                    };
                };
                case(_,_){
                    return Prelude.nyi();
                }
            };

            return marker;

        };


        public func writeAndIndex(namespace : Text, primaryID : Nat, dataConfig: PipelinifyTypes.DataConfig, bCertify: Bool, index: [MetaTreeIndex]) : async Nat{
            //todo: write to metatree service
            switch(dataConfig){
                case(#dataIncluded(data)){
                    let marker  = await write(namespace, primaryID, dataConfig, bCertify);
                    Debug.print(
                        "wrote initial item to log...now doing index"
                    );

                    for(thisIndex in index.vals()){
                        Debug.print(debug_show(thisIndex));
                        let metaData = Option.unwrap(calcIndexMeta(thisIndex, data.data));//should trap if not configured correctly
                        let newNamespace = thisIndex.namespace # ".__index." # metaData.postFix;
                        //not currently awaiting the markers.
                        //todo: need to change to writing a pointer to original data...or maybe it is an index config
                        //todo: inspect the index to see if it needs to be cerified
                        let aMarker = write(newNamespace, metaData.primaryID, dataConfig, false);
                    };
                    return marker;
                };
                case(_){
                    return Prelude.nyi();
                };
            };

        };




        public func replace(namespace : Text, primaryID : Nat, dataConfig: PipelinifyTypes.DataConfig, bCertify: Bool) : async Nat{
            //todo: write to metatree service
            let marker = 1; //we use 1 with replace because it is always unique
            Debug.print("in replace " # namespace # debug_show(primaryID));
            let namespaceHash = Conversion.bytesToNat(SHA256.sha256(Conversion.textToBytes(namespace)));
            Debug.print("namespaceHash" # debug_show(namespaceHash));

            //var currentList : ?[Entry] = namespaceMap.get(namespaceHash);
            switch(dataConfig){
                case(#dataIncluded(data)){
                    Debug.print(debug_show(data));
                    Debug.print("namespace " # namespace);
                    namespaceMap.put(namespaceHash, [{
                        entries= [{primaryID = primaryID; marker = marker; data = data.data}];
                        firstKey = primaryID;
                        firstMarker = marker;
                        lastKey = primaryID;
                        lastMarker = marker;
                        indexCanister = #this;
                    }]
                    );
                    //todo: need to remove indexes where this item is pointed to
                    if(bCertify == true){
                        certify(namespaceHash, primaryID, marker,data.data);
                    };
                };
                case(_){
                    Debug.print("NYI");
                    return Prelude.nyi();
                };
            };


            return marker;

        };

        public func replaceAndIndex(namespace : Text, primaryID : Nat, dataConfig: PipelinifyTypes.DataConfig, bCertify: Bool, index: [MetaTreeIndex]) : async Nat{
            //todo: write to metatree service
            switch(dataConfig){
                case(#dataIncluded(data)){
                    let marker  = await replace(namespace, primaryID, dataConfig, bCertify);
                    Debug.print(
                        "wrote initial item to log...now doing index"
                    );

                    for(thisIndex in index.vals()){
                        Debug.print(debug_show(thisIndex));
                        let metaData = Option.unwrap(calcIndexMeta(thisIndex, data.data));
                        let newNamespace = thisIndex.namespace # ".__index." # metaData.postFix;
                        //not currently awaiting the markers.
                        //todo: need to erase old index
                        //todo: need to add pointers to original data instead
                        let aMarker = replace(newNamespace, metaData.primaryID, dataConfig, false);
                    };
                    return marker;
                };
                case(_){
                    Prelude.nyi()
                }
            };

        };

        public func __resetTest() : async Bool{
            //todo: restrict to controller
            namespaceMap := HashMap.HashMap<Nat,[EntryGroup]>(1, Nat.equal, bigNatToNat32);
            certifiedTree := MerkleTree.empty();

            return true;

        };



        func calcIndexMeta(index : MetaTreeIndex, data : AddressedChunkArray) : ?{primaryID : Nat; postFix : Text} {
            let val = Workspace.getDataChunkFromAddressedChunkArray(data, index.dataZone, index.dataChunk);
            let meta = switch(index.indexType){
                case(#Nat){
                    let n = switch(val){case(#Nat(val)){val};case(_){return null;}};
                    {postFix = Nat.toText(n);
                     primaryID = n
                    };
                };
                case(#Int){
                    //todo: does not support negative ints. Maybe add a billionty to private id?
                    let n = switch(val){case(#Int(val)){val};case(_){return null;}};

                    {postFix = Int.toText(n);
                    primaryID = Int.abs(n)};
                };
                case(#Text){
                    let n = SHA256.sha256(Conversion.textToBytes(switch(val){case(#Text(val)){val};case(_){return null;}}));
                    {postFix = Conversion.bytesToText(n);
                    primaryID = Conversion.bytesToNat(n)};
                };
                case(#Principal){
                    let n = SHA256.sha256(Conversion.principalToBytes(switch(val){case(#Principal(val)){val};case(_){return null;}}));
                    {postFix = Principal.toText(switch(val){case(#Principal(val)){val};case(_){return null;}});
                    primaryID = Conversion.bytesToNat(n)};
                };
                case(_){
                    {postFix="Not Implemented";
                    primaryID=0};
                };
            };

            return ?meta;
        };


        var maxchunkSize : Nat = 2_000_000;


        public func readToData(response : ReadResponse) : async ReadResponse{
            switch(response){
                case(#data(aData)){
                    return response;
                };
                case(#pointer(aPointer)){
                    let aActor : MetaTreeActor = actor(Principal.toText(aPointer.canister));

                    return await aActor.readToData(aPointer.namespace, aPointer.minID, aPointer.maxID, aPointer.lastID, aPointer.lastMarker);
                };
                case(#notFound){return #notFound};
            };
        };



        public func read(namespace : Text) :  ReadResponse{
            return  readFilterPage(namespace, null, null, 0, 0);
        };

        public func readPage(namespace : Text, lastID : Nat, lastMarker : Nat) :  ReadResponse{
            return  readFilterPage(namespace, null, null, lastID, lastMarker);
        };

        public func readFilter(namespace : Text, minID : ?Nat, maxID : ?Nat) :  ReadResponse{
            return  readFilterPage(namespace, minID, maxID, 0, 0);
        };

        public func readUnique(namespace : Text) :  ReadResponse{
            return  readFilterPage(namespace, null, null, 0, 0);
        };

        public func readFilterPage(namespace : Text, minID : ?Nat, maxID : ?Nat, lastID : Nat, lastMarker: Nat) : ReadResponse {

            let namespaceHash = Conversion.bytesToNat(SHA256.sha256(Conversion.textToBytes(namespace)));
            Debug.print("getting logs for hash " # debug_show(namespaceHash) # " " # namespace);
            //todo: makesure there isn't a pointer to another canister

            let currentList : ?[EntryGroup] = namespaceMap.get(namespaceHash);
            //Debug.print("found a List");
            switch(currentList){
                case(null){
                    Debug.print("no logs");
                    return #notFound;
                };
                case(?currentList){
                    //todo: this wont work for large lists
                    //todo: navigate to proper group
                    let currentEntries = currentList[0].entries;
                    Debug.print("logs exist" # debug_show(currentEntries));
                    var resultSize = 0;
                    let responseBuffer = Buffer.Buffer<Entry>(16);
                    if(currentList.size() == 0){
                        Debug.print("no logs size");
                        return #data({
                        data = [];
                        lastID = null;
                        lastMarker = null;
                        firstID = null;
                        firstMarker = null;
                        });
                    };
                    switch(minID, maxID){
                        case(null, null){
                            //no filter
                            Debug.print("no filter" # debug_show(currentEntries.size()));
                            label buildResponse for(thisEntry in currentEntries.vals()){
                                //Debug.print(debug_show(lastID) # " " # debug_show(lastMarker) # " " # debug_show(thisEntry.primaryID) # " " # debug_show(thisEntry.marker));
                                if(thisEntry.primaryID >= lastID and thisEntry.marker > lastMarker){
                                    //Debug.print("prcing entry " # debug_show(thisEntry));
                                    responseBuffer.add(thisEntry);
                                    resultSize += Workspace.getAddressedChunkArraySize(thisEntry.data);
                                };
                                if(resultSize > maxchunkSize){
                                    //Debug.print("breaking because chunksize" # debug_show(resultSize));
                                    break buildResponse;
                                };
                            };
                        };
                        case(null, ?maxID){
                            Debug.print("no min max");
                            label buildResponse for(thisEntry in currentEntries.vals()){
                                if(thisEntry.primaryID >= maxID){
                                    break buildResponse;
                                };
                                if(thisEntry.primaryID >= lastID and thisEntry.marker > lastMarker){
                                    responseBuffer.add(thisEntry);
                                    resultSize += Workspace.getAddressedChunkArraySize(thisEntry.data);
                                };
                                if(resultSize > maxchunkSize){
                                    break buildResponse;
                                };
                            };
                        };
                        case(?minID, null){
                            Debug.print("min no max");
                            label buildResponse for(thisEntry in currentEntries.vals()){
                                if(thisEntry.primaryID < minID){
                                    continue buildResponse;
                                };
                                if(thisEntry.primaryID >= lastID and thisEntry.marker > lastMarker){
                                    responseBuffer.add(thisEntry);
                                    resultSize += Workspace.getAddressedChunkArraySize(thisEntry.data);
                                };
                                if(resultSize > maxchunkSize){
                                    break buildResponse;
                                };
                            };
                        };
                        case(?minID, ?maxID){
                            Debug.print("min and max");
                            label buildResponse for(thisEntry in currentEntries.vals()){
                                if(thisEntry.primaryID < minID){
                                    continue buildResponse;
                                };
                                if(thisEntry.primaryID >= maxID){
                                    break buildResponse;
                                };
                                if(thisEntry.primaryID >= lastID and thisEntry.marker > lastMarker){
                                    responseBuffer.add(thisEntry);
                                    resultSize += Workspace.getAddressedChunkArraySize(thisEntry.data);
                                };
                                if(resultSize > maxchunkSize){
                                    break buildResponse;
                                };
                            };
                        };

                    };

                    let lastItem = if(responseBuffer.size() > 0)
                            {responseBuffer.get(responseBuffer.size() - 1)}
                        else {{primaryID=0;marker=0;data=[];}};
                    let firstItem = if(responseBuffer.size() > 0)
                            {responseBuffer.get(0)}
                        else {{primaryID=0;marker=0;data=[];}};

                    return #data({
                        data = responseBuffer.toArray();
                        lastID = ?lastItem.primaryID;
                        lastMarker = ?lastItem.marker;
                        firstID = ?firstItem.primaryID;
                        firstMarker = ?firstItem.marker;
                    });

                };
            };
        }

        //todo: US 6; handle upgrades
    };



};