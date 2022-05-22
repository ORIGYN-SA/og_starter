///////////////////////////////
/*
©2021 RIVVIR Tech LLC
All Rights Reserved.
This code is released for code verification purposes. All rights are retained by RIVVIR Tech LLC and no re-distribution or alteration rights are granted at this time.
*/
///////////////////////////////

import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Nat8 "mo:base/Nat8";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Candy "mo:candy/types";
import Principal "mo:base/Principal";
//import RegCanister "../droute/main";
import dRouteTypes "../dRouteTypes";

module {

    //Types

    public type DRouteEventDef = dRouteTypes.DRouteEventDef;
    public type DRouteInitialization = dRouteTypes.DRouteInitialization;
    public type EventPublishable = dRouteTypes.EventPublishable;
    public type PublishStatus = dRouteTypes.PublishStatus;
    public type PublishResponse = dRouteTypes.PublishResponse;
    public type PublishError = dRouteTypes.PublishError;
    public type ConfirmEventRegistrtationResponse = dRouteTypes.ConfirmEventRegistrtationResponse;
    public type RegCanisterActor =  dRouteTypes.RegCanisterActor;
    public type PublishingCanisterActor =  dRouteTypes.PublishingCanisterActor;
    public type SubscriptionRequest =  dRouteTypes.SubscriptionRequest;
    public type SubscriptionResponse =  dRouteTypes.SubscriptionResponse;

    public class dRouteListener(initArgs : {
        regPrincipal: Principal
    }){
        type Result<T,E> = Result.Result<T,E>;

        func selfHash(_self : Hash.Hash) : Hash.Hash {
            _self;
        };

        public var regPrincipal = initArgs.regPrincipal;


        public func subscribe(subscription : SubscriptionRequest) : async Result<SubscriptionResponse, PublishError> {

            //check to see if we have a set of canisters to send messages to
            let RegCanister : RegCanisterActor = actor(Principal.toText(regPrincipal));

            //todo: for now we need to send to the reg canister, but how scalable is that for subscriptions?
            let regCanister : RegCanisterActor = actor(Principal.toText(regPrincipal));
            let subscribeResult = await regCanister.subscribe(subscription);

            switch subscribeResult{
                case(#ok(result)){
                    return #ok(result);
                };
                case(#err(err)){
                    return #err(err);
                };
            };

        };


    };



};
