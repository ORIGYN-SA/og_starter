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

    public class dRoutePublisher(initArgs: {regPrincipal : Principal}){
        type Result<T,E> = Result.Result<T,E>;

        func selfHash(_self : Hash.Hash) : Hash.Hash {
            _self;
        };

        var publishingCanisters : [Text] = [];

        //todo: create strategy for updating this as soon to instantiation as possible
        public var regPrincipal = initArgs.regPrincipal;

        public func updateRegistration() {
            //pass in a complicated structure and call different functions on the reg canister to update the registration
            //keep in sync with local cache

        };

        public func syncRegistration() : async Bool {
            //pull configs from the reg canister and sync them with the local cache.
            Debug.print("in sync Reg" # debug_show(regPrincipal));
            let RegCanister : RegCanisterActor = actor(Principal.toText(regPrincipal));
            Debug.print("have reg canisters");
            //todo: may want to allow for private or public See UserStories 27. 28.
            publishingCanisters := await RegCanister.getPublishingCanisters(16);

            
            Debug.print(debug_show(publishingCanisters));

            return true;
        };

        public func publish(event : EventPublishable) : async Result<PublishResponse, PublishError> {

            //check to see if we have a set of canisters to send messages to
            let RegCanister : RegCanisterActor = actor(Principal.toText(regPrincipal));

            Debug.print(debug_show(publishingCanisters.size()));
            if(publishingCanisters.size() == 0){
                Debug.print("syncing");
                let sync = await syncRegistration();
                Debug.print("done syncing");
            };
            Debug.print(debug_show(Int.abs(Time.now())));
            Debug.print(debug_show(publishingCanisters));
            let targetCanister = publishingCanisters[Nat.rem(Int.abs(Time.now()), publishingCanisters.size())];
            //send the message to the pulication canister

            let publishingCanister : PublishingCanisterActor = actor(targetCanister);

            let publishResult = await publishingCanister.publish(event);

            switch publishResult{
                case(#ok(result)){
                    return publishResult;
                };
                case(#err(err)){
                    return #err(err);
                };
            };

            return #err({code=404;text="Not Implemented"});
        };


    };



};
