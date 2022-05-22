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
import RBTree "mo:base/RBTree";
import Blob "mo:base/Blob";
import Result "mo:base/Result";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import Time "mo:base/Time";
import Option "mo:base/Option";
import Int "mo:base/Int";
import Candy "mo:candy/types";
import Principal "mo:base/Principal";
import XorShift "mo:rand/XorShift";
import Source "mo:ulid/Source";
//import RegCanister "../droute/main";
import Types "types";
import PublisherStore "publisherStore";

module {

    public class dRoutePublisher(initArgs: Types.DRoutePublisherInitArgs){

        var self : Principal = Principal.fromText("aaaaa-aa");
        var reg_canister : Principal = Principal.fromText("aaaaa-aa");
        var store : Types.PublisherStore =  PublisherStore.DefaultPublisherStore({
            self = Principal.fromText("aaaaa-aa");
            pending_publish = [];
            event_instances = [];
            delivery_confirmation = [];
            broadcast_confirmation = []
            }
        );
        var publishingCanisters : [Principal] = [];
        var onEventPublish : ?((Types.EventInstance, Types.PublisherStore) -> async ()) = null;
        var onEventRecieved : ?((Blob, Types.PublisherStore) -> async ()) = null;
        var onEventBroadcastConfirmation : ?((Types.EventDeliveryConfirmation, Types.PublisherStore) -> async ()) = null;
        var onEventDeliveryConfirmation : ?((Types.EventDeliveryConfirmation, Types.PublisherStore) -> async ()) = null;
        var onEventDeliveryComplete : ?((Blob, Types.PublisherStore) -> async ()) = null;
        
        switch(initArgs){
            case(#StartUp(args)){
                self := args.self;
                reg_canister := args.reg_canister;
                store := args.store;
                onEventPublish := args.onEventPublish;
                onEventRecieved := args.onEventRecieved;
                onEventBroadcastConfirmation := args.onEventBroadcastConfirmation;
                onEventDeliveryConfirmation := args.onEventDeliveryConfirmation;
                onEventDeliveryComplete := args.onEventDeliveryComplete;
            };
            case(#Rehydrate(args)){
                self := args.self;
                reg_canister := args.reg_canister;
                store := args.store;
                onEventPublish := args.onEventPublish;
                onEventRecieved := args.onEventRecieved;
                onEventBroadcastConfirmation := args.onEventBroadcastConfirmation;
                onEventDeliveryConfirmation := args.onEventDeliveryConfirmation;
                onEventDeliveryComplete := args.onEventDeliveryComplete;
            };
        };

        let RegCanister : Types.RegCanisterActor = actor(Principal.toText(reg_canister));

        //used to create ulids
        private let rr = XorShift.toReader(XorShift.XorShift64(?Nat64.fromNat(Nat32.toNat(Principal.hash(self)))));
        private let se = Source.Source(rr, 1);

        public var b_registration_updated : Bool = false;

        public func get_publishing_canisters() : [Principal]{
            return publishingCanisters;
        };

        public func updateRegistration() {
            //pass in a complicated structure and call different functions on the reg canister to update the registration
            //keep in sync with local cache
        };

        public func syncRegistration() : async Result.Result<Bool, Types.DRouteError> {
            //pull configs from the reg canister and sync them with the local cache.
            
            //todo: may want to allow for private or public See UserStories 27. 28.
            Debug.print("callling sync");
            let canisterRequestFuture = RegCanister.get_publishing_canisters_request_droute(16);
            return #ok(true);
        };


        public func sync_registration_confirm(items: [Principal], caller: Principal) : Result.Result<Bool, Types.DRouteError> {
            //pull configs from the reg canister and sync them with the local cache.
            Debug.print("in sync Reg Cofirm" # debug_show(items));
            
            publishingCanisters := items;
            b_registration_updated := true;
            return #ok(true);
        };

        public func publish(event : Types.EventPublishable) : async Result.Result<Types.EventInstance, Types.DRouteError> {

            if(publishingCanisters.size() == 0){
                Debug.print("syncing");
                let sync = await syncRegistration();
                Debug.print("done syncing");
            };

            let targetCanister = publishingCanisters[Nat.rem(Int.abs(Time.now()), publishingCanisters.size())];
            //send the message to the pulication canister

            let publishingCanister : Types.PublishingCanisterActor = actor(Principal.toText(targetCanister));

            let event_instance : Types.EventInstance = {
                event_id = Blob.fromArray(se.new());
                timestamp = Time.now();
                target = targetCanister;
                event = event;
            };

            switch(onEventPublish){
                case(null){};
                case(?val){let future = val(event_instance, store)};
            };

            //add the instance to the pending queue
            //pending_publish.put(event_instance.event_id, event_instance);

            let publishFuture = publishingCanister.publish_event_droute(event_instance);

            return(#ok(event_instance));
        };

        public func publish_recieved(event_id : Blob, caller: Principal) : async Result.Result<Bool, Types.DRouteError> {

            switch(onEventRecieved){
                case(?val){let future = val(event_id, store)};
                case(null){};
            };

            return(#ok(true));
        };


        public func publish_broadcast(notification: Types.EventDeliveryConfirmation) : async Result.Result<Bool, Types.DRouteError> {
            Debug.print("handling publish_broadcast in publisher");
            switch(onEventBroadcastConfirmation){
                case(?val){let future = val(notification, store)};
                case(null){};
            };

            return(#ok(true));
        };


        public func publish_delivered(notification: Types.EventDeliveryConfirmation) : async Result.Result<Bool, Types.DRouteError> {

            switch(onEventDeliveryConfirmation){
                case(?val){let future = val(notification, store)};
                case(null){};
            };

            return(#ok(true));
        };

    };



};
