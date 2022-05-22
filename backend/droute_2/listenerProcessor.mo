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

    public class DefaultListenerProcessor(initArgs: Types.DRouteListenerProcessorInitArgs){

        let self = initArgs.self;
        var listener = {
            subscribe = func(subscription_request : Types.EventSubscriptionRequest, subscription_id: ?Blob): async Result.Result<Types.EventSubscriptionResponse, Types.DRouteError>{
                #err(Types.errors(#listener_not_initilized, "subscribe listener processor", ?self));
            }
        };

        public func handleInit(remote_listener: Types.DRouteListener) : () {
            Debug.print("in handleEventSubscription");
            listener := remote_listener;
        };
        
        public func handleEventSubscription(subscription: Types.EventSubscription, store: Types.ListenerStore) : async () {
            Debug.print("in handleEventSubscription");
            let setFuture = store.set_event_subscription(subscription.subscription_id, ?subscription);
        };

        public func handleEventHandlerRequest(subscription: Types.EventSubscription, store: Types.ListenerStore) : async () {
            Debug.print("in handleEventHandlerRequest");
            let setPendingFuture = store.set_pending_handler(subscription.subscription_id, ?subscription);
        };

        public func handleEventHandlerResponse(subscription: Types.EventSubscription, items: [Principal], store: Types.ListenerStore) : async () {
            Debug.print("in handleEventHandlerResponse");
            let setPendingFuture = store.set_pending_handler(subscription.subscription_id, null);
            Debug.print("in handleEventHandlerResponse" # debug_show(subscription.event_type) # debug_show(items));
            let setHandlerFuture = await store.set_subscription_handler(subscription.event_type, ?items);
            //this is where we should try to retry any subscription requests
            //let subscription = await store.get_event_subscription(subscription.subscription_id);
            switch(subscription.request){
                case(null){Debug.print("this shouldnt be null");};
                case(?sub){
                    Debug.print("calling subscribe again");
                    let subFuture = listener.subscribe(sub, ?subscription.subscription_id);
                    //Debug.print(debug_show(subFuture));
                };
            };

            return;
            
        };

        public func handleEventSubscriptionRequest(subscription_id: Blob, store: Types.ListenerStore) : async () {
            Debug.print("in handleEventSubscriptionRequest");
            let setRequestFuture = store.set_pending_subscription(subscription_id, ?1);
        };


        public func handleEventSubscriptionConfirmation(subscription: Types.EventSubscription, store: Types.ListenerStore) : async () {
            Debug.print("in handleEventSubscriptionConfirmation");
            let setFuture = store.set_pending_subscription(subscription.subscription_id, null);
            let setSubFuture = store.set_event_subscription(subscription.subscription_id, ?subscription);
        };

        public func handleEventNotification(event_instance: Types.EventInstance, store: Types.ListenerStore) : async (){
            Debug.print("in handleEventNotification");
            //let setEventFuture = store.set_event_instance(event_instance.event_id, ?event_instance);
            //let setPendingFuture = store.set_pending_publish(event_instance.event_id, ?1);
        };


        
    };



};
