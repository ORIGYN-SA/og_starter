///////////////////////////////
/*
©2021 RIVVIR Tech LLC
All Rights Reserved.
This code is released for code verification purposes. All rights are retained by RIVVIR Tech LLC and no re-distribution or alteration rights are granted at this time.
*/
///////////////////////////////

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Candy "mo:candy/types";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import ListenerStore "listenerStore";
import Nat "mo:base/Nat";
import Nat16 "mo:base/Nat16";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import RBTree "mo:base/RBTree";
import Result "mo:base/Result";
import Source "mo:ulid/Source";
import Time "mo:base/Time";
import Type "types";
import Types "types";
import XorShift "mo:rand/XorShift";

module {

    public class dRouteListener(initArgs: Types.DRouteListenerInitArgs) = this{

        var self : Principal = Principal.fromText("aaaaa-aa");
        var reg_canister : Principal = Principal.fromText("aaaaa-aa");
        var store : Types.ListenerStore =  ListenerStore.DefaultListenerStore({
            self = Principal.fromText("aaaaa-aa");
            pending_subscriptions = [];
            event_subscriptions = [];
            pending_handlers = [];
            }
        );

        var onEventNotification : ?((Types.EventInstance, Types.ListenerStore) -> async ()) = null;
        var onEventHandlerRequest : ?((Type.EventSubscription, Types.ListenerStore) -> async ()) = null;
        var onEventHandlerResponse : ?((Type.EventSubscription, [Principal], Types.ListenerStore) -> async ()) = null;
        var onEventSubscription: ?((Types.EventSubscription, Types.ListenerStore) -> async ()) = null;
        var onEventSubscriptionRequest : ?((Blob, Types.ListenerStore) -> async ()) = null;
        var onEventSubscriptionConfirmation : ?((Types.EventSubscription, Types.ListenerStore) -> async ()) = null;
        var onInit : ?((Types.DRouteListener) -> ()) = null;
        
        switch(initArgs){
            case(#StartUp(args)){
                self := args.self;
                reg_canister := args.reg_canister;
                store := args.store;
                onEventNotification := args.onEventNotification;
                onEventSubscriptionConfirmation := args.onEventSubscriptionConfirmation;
                onEventHandlerRequest := args.onEventHandlerRequest;
                onEventHandlerResponse := args.onEventHandlerResponse;
                onEventSubscription := args.onEventSubscription;
                onEventSubscriptionRequest := args.onEventSubscriptionRequest;
                onInit := args.onInit;
            };
            case(#Rehydrate(args)){
                self := args.self;
                reg_canister := args.reg_canister;
                store := args.store;
                onEventNotification := args.onEventNotification;
                onEventSubscriptionConfirmation := args.onEventSubscriptionConfirmation;
                onEventHandlerRequest := args.onEventHandlerRequest;
                onEventHandlerResponse := args.onEventHandlerResponse;
                onEventSubscription := args.onEventSubscription;
                onEventSubscriptionRequest := args.onEventSubscriptionRequest;
                onInit := args.onInit;
            };
        };



        let RegCanister : Types.RegCanisterActor = actor(Principal.toText(reg_canister));

        //used to create ulids
        private let rr = XorShift.toReader(XorShift.XorShift64(?Nat64.fromNat(Nat32.toNat(Principal.hash(self)))));
        private let se = Source.Source(rr, 1);

        public func init(): (){
            switch(onInit){
                case(null){};
                case(?val){val({
                    subscribe = this.subscribe})};
            };
        };

        public func subscribe(subscription_request : Types.EventSubscriptionRequest, subscription_id: ?Blob) : async Result.Result<Types.EventSubscriptionResponse, Types.DRouteError> {

            Debug.print("in subscribe");
            //construct the subscription
            let subscription = switch(subscription_id){
                case(null){
                    Debug.print("no subsription yet so lets create it");
                    let sub = {
                        subscription_id = Blob.fromArray(se.new());
                        event_type = subscription_request.event_type;
                        filter =  subscription_request.filter;
                        throttle = subscription_request.throttle;
                        destination_set = switch(subscription_request.destination_set){
                            case(null){[self]}; 
                            case(?v){v};
                        };
                        user_id  = subscription_request.user_id; 
                        status = #stopped;
                        controllers = switch(subscription_request.controllers){
                            case(null){[self]}; 
                            case(?v){v};
                        }; 
                        request = ?subscription_request;
                    };

                    switch(onEventSubscription){
                        case(null){};
                        case(?val){let future = val(sub, store)};
                    };

                    sub;

                };
                case(?subscription_id){
                     Debug.print("already have  sub so look it up");
                    switch(await store.get_event_subscription(subscription_id)){
                        case(#ok(val)){val};
                        case(#err(err)){return #err(Types.errors(err.error, "cannot find subscription - subscribe - rehydrate " # err.flag_point, ?self))};
                    };
                };
            };

            

            let handlers = switch((await store.get_subscription_handler(subscription_request.event_type))){
                case(#ok(val)){val};
                case(#err(err)){
                    //make the request to know the handlers and queue the subscription request
                    Debug.print("calling get_handler_canisters_for_event_droute");
                    RegCanister.get_handler_canisters_for_event_droute(subscription_request.event_type, subscription.subscription_id);
                    switch(onEventHandlerRequest){
                        case(null){};
                        case(?val){let future = val(subscription, store)};
                    };
                    
                    return #ok(#needHandler(subscription.subscription_id));
                };
            };

            let targetCanister = handlers[Nat.rem(Int.abs(Time.now()), handlers.size())];
            //send the message to the pulication canister

            let publishingCanister : Types.PublishingCanisterActor = actor(Principal.toText(targetCanister));

            Debug.print("writing the pending subscription request");
            switch(onEventSubscriptionRequest){
                case(null){};
                case(?val){let future = val(subscription.subscription_id, store)};
            };

            
            Debug.print("calling the subscription");
            let subscribeFuture = publishingCanister.subscribe_event_droute(subscription);

            return(#ok(#pendingResponse(subscription.subscription_id)));
        };

        public func subscription_handler_recieved(items : [Principal], subscription_id: Blob, caller: Principal) : async Result.Result<Bool, Types.DRouteError> {

            switch(onEventHandlerResponse){
                case(?val){
                    switch(await store.get_event_subscription(subscription_id)){
                        case(#err(err)){
                            return #err(Types.errors(err.error, "subscription_handler_recieved could not get sub" # err.flag_point, ?caller));
                        };
                        case(#ok(subscription)){
                            let future = val(subscription, items, store);
                        };
                    };

                    
                };
                case(null){};
            };

            return(#ok(true));
        };

        public func subscription_confirm_recieved(subscription : Types.EventSubscription, caller: Principal) : async Result.Result<Bool, Types.DRouteError>{
            switch(onEventSubscriptionConfirmation){
                case(?val){
                    let future = val(subscription, store);
                };
                case(null){};
            };

            return(#ok(true));
        };

        public func notify_event_recieved(event: Types.EventInstance, caller: Principal) : async Result.Result<Bool, Types.DRouteError>{
            switch(onEventNotification){
                case(?val){
                    let future = val(event, store);
                };
                case(null){};
            };

            return(#ok(true));
        };

        
    };


    



};
