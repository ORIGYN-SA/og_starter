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
import ulid "mo:ulid/ulid";
//import RegCanister "../droute/main";
import Types "types";

module {

    public class DefaultPublisherProcessor(initArgs: Types.DRoutePublisherProcessorInitArgs){

        let self = initArgs.self;
        
    
        public func handleEventPublish(event_instance: Types.EventInstance, store: Types.PublisherStore) : async (){
            Debug.print("in handleEventPublish");
            let setEventFuture = store.set_event_instance(event_instance.event_id, ?event_instance);
            let setPendingFuture = store.set_pending_publish(event_instance.event_id, ?1);
        };

        public func handleEventRecieved(event_id: Blob, store: Types.PublisherStore) : async () {
            Debug.print("in handleEventRecieved");
            let setPendingFuture = store.set_pending_publish(event_id, null);
        };

        public func handleEventBroadcastConfirmation(event_confirmation: Types.EventDeliveryConfirmation, store: Types.PublisherStore) : async (){
            Debug.print("in handleEventBroadcastConfirmation");
            let setBroadcastFuture = store.set_event_broadcast_confirmation(event_confirmation.event_id, event_confirmation.subscription_id, ?Time.now());
        };

        public func handleEventDeliveryConfirmation(event_confirmation: Types.EventDeliveryConfirmation, store: Types.PublisherStore) : async (){
            Debug.print("in handleEventDeliveryConfirmation");
        };


        public func handleEventDeliveryComplete(event_id: Blob, store: Types.PublisherStore) : (){};

    };



};
