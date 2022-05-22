///////////////////////////////
/*
©2021 RIVVIR Tech LLC
All Rights Reserved.
This code is released for code verification purposes. All rights are retained by RIVVIR Tech LLC and no re-distribution or alteration rights are granted at this time.
*/
///////////////////////////////

import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import MerkleTree "../dRouteUtilities/MerkleTree";
import MetaTree "../metatree/lib";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import PipelinifyTypes "mo:pipelinify/types";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Candy "mo:candy/types";


module {

    public type MerkleTree = MerkleTree.Tree;
    public type MerkleTreeKey = MerkleTree.Key;
    public type MerkleTreeVal = MerkleTree.Value;
    public type MerkleTreeWitness = MerkleTree.Witness;

    public type DRouteEvent = {
        eventType : Text;
        source : Principal;
        dataConfig : PipelinifyTypes.DataConfig;
        dRouteID: Nat;
        userID: Nat;
        //todo
        //certification: {
        //    #signature;
        //    #witness:{
        //        canister: Principal;
        //        witness: Blob;
        //    };
        //    #none;
        //};
    };

    //field 0 : name - text
    //field 1 : source - principal
    //field n-2...data
    public type DRouteEventStable = [Candy.AddressedChunk];

    public type ValidSourceOptions = {
        #whitelist: [Principal];
        #blacklist: [Principal];
        #dynamic: {
            canister: Text;
        };
    };

    //todo: US 35; add valid targets
    public type EventRegistration = {
        eventType: Text;
        var validSources: ValidSourceOptions;
        var publishingCanisters: [Text];
    };

    public type EventRegistrationStable = {
        eventType: Text;
        validSources: ValidSourceOptions;
        publishingCanisters: [Text];
    };

    public type NamespaceRight = {
        namespace: Text;
        controllers: [Principal];
        authorized: [Principal];
    };

    public type DRouteEventDef = {
        eventName: Text;
        validSources: {
            #whitelist: [Principal];
            #blacklist: [Principal];
            #dynamic: {
                canister: Text;
            };
        };
    };

    public type DRouteInitialization = {
        regCanister : ?Principal;
        eventTypes: [DRouteEventDef];
    };


    public type BroadcastLogItem = {
        eventType: Text;
        eventDRouteID: Nat;
        eventUserID: Nat;
        destination: Principal;
        processor: Principal;
        subscriptionUserID: Nat;
        subscriptionDRoutID: Nat;
        dateSent: Int;
        notifyResponse: Bool;
        heapCycleID: Nat;
        index: Nat;

        error: ?PublishError;
    };

    

    public type EventPublishable = {
        eventType: Text;
        userID: Nat;
        dataConfig: PipelinifyTypes.DataConfig;
    };

    public type PublishStatus = {
        #recieved;
        #delivered;
    };

    public type PublishResponse = {
        dRouteID : Nat;
        timeRecieved : Int;
        status: PublishStatus;
        publishCanister : Principal.Principal;
    };

    public type PublishError = {
        code : Nat;
        text : Text;
    };


    public type ConfirmEventRegistrtationResponse = {
        #notFound;
        #found: DRouteEventDef;
    };



    public type SubscriptionFilter = {
        #notImplemented;
    };

    public type SubscriptionThrottle = {
        #notImplemented;
    };

    public type SubscriptionRequest = {

        eventType : Text;
        filter: ?SubscriptionFilter;
        throttle: ?SubscriptionThrottle;
        destinationSet: [Principal];
        userID: Nat; //hash of namespace to keep from duplicates from occuring

    };

    public type Subscription = {

        eventType : Text;
        filter: ?SubscriptionFilter;
        throttle: ?SubscriptionThrottle;
        destinationSet: [Principal];
        userID: Nat; //hash of namespace to keep from duplicates from occuring
        dRouteID: Nat;
        status: {
            #started;
            #stopped;
        };
        controllers: [Principal];
    };

    public type SubscriptionResponse = {
        subscriptionID: Nat;
        userID: Nat;
    };

    public type NotifyResponse = Result.Result<Bool, PublishError>;

    public type ProcessQueueResponse= {
        eventsProcessed: Nat;
        queueLength: Nat;
    };

    public type RegCanisterActor = actor {
        getPublishingCanisters: (Nat) -> async [Text];
        getEventRegistration: (Text) -> async ?EventRegistrationStable;
        subscribe: (SubscriptionRequest) -> async Result.Result<SubscriptionResponse, PublishError>;
    };

    public type PublishingCanisterActor = actor {
        publish: (EventPublishable) -> async Result.Result<PublishResponse,PublishError>;
        processQueue: () -> async Result.Result<ProcessQueueResponse, PublishError>;

        //todo: this probably doesnt go here figure out where metatree should go
        getProcessingLogs: (Text) -> async MetaTree.ReadResponse;
        getProcessingLogsByIndex: (Text, Nat) -> async MetaTree.ReadResponse;
    };

    public type ListenerCanisterActor = actor {
        __dRouteNotify: (DRouteEvent) -> async NotifyResponse;
        __dRouteSubValidate: query (Principal, Nat) -> async (Bool, Blob, MerkleTreeWitness);
    };


    ////////////////////////
    //
    // Errors
    //
    // Subscriptions
    // 1 - No valid destinations in DestinationSet


};
