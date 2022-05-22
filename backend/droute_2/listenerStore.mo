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
import Text "mo:base/Text";
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

    public class DefaultListenerStore(initArgs: Types.DRouteListenerStoreInitArgs){

        let pending_subscriptions : RBTree.RBTree<Blob, Nat> = RBTree.RBTree<Blob,Nat>(Blob.compare); //why RB Tree - already in order, self balancing
        let event_subscriptions : RBTree.RBTree<Blob, Types.EventSubscription> = RBTree.RBTree<Blob,Types.EventSubscription>(Blob.compare); //why RB Tree - already in order, self balancing
        let subscription_handlers : RBTree.RBTree<Text, [Principal]> = RBTree.RBTree<Text,[Principal]>(Text.compare); //why RB Tree - already in order, self balancing
        let pending_handlers : RBTree.RBTree<Blob, Types.EventSubscription> = RBTree.RBTree<Blob,Types.EventSubscription>(Blob.compare); //why RB Tree - already in order, self balancing
        let self = initArgs.self;
        
        for(thisItem in initArgs.pending_subscriptions.vals()){
            pending_subscriptions.put(thisItem.0,thisItem.1);
        };

        for(thisItem in initArgs.event_subscriptions.vals()){
            event_subscriptions.put(thisItem.0,thisItem.1);
        };
                
        //used to create ulids
        //private let rr = XorShift.toReader(XorShift.XorShift64(?Nat64.fromNat(Nat32.toNat(Principal.hash(self)))));
        //private let se = Source.Source(rr, 1);

        public func get_event_subscription(subscription_id: Blob) : async Result.Result<Types.EventSubscription, Types.DRouteError>{
            switch(event_subscriptions.get(subscription_id)){
                case(null){#err(Types.errors(#cannot_find_event_subscription,"get_event_subscription cannot find event subscription " # ulid.toText(Blob.toArray(subscription_id)), ?self))};
                case(?val){return #ok(val)};
            };
        };

        public func set_event_subscription(subscription_id: Blob, event_subscription: ?Types.EventSubscription) : async Result.Result<?Types.EventSubscription, Types.DRouteError>{
            switch(event_subscription){
                case(null){
                    event_subscriptions.delete(subscription_id);
                };
                case(?val){
                    event_subscriptions.put(subscription_id, val);
                };
            };
            return #ok(event_subscription);
        };

        public func get_pending_subscription(subscription_id: Blob) : async Result.Result<Nat, Types.DRouteError>{
            Debug.print("in get_pending_subscription ");
            switch(pending_subscriptions.get(subscription_id)){
                case(null){#err(Types.errors(#cannot_find_event_subscription,"get_pending_subscription cannot find event subscription " # ulid.toText(Blob.toArray(subscription_id)), ?self))};
                case(?val){return #ok(val)};
            };
        };

        public func set_pending_subscription(subscription_id: Blob, attempts: ?Nat) : async Result.Result<?Nat, Types.DRouteError>{
            switch(attempts){
                case(null){
                    Debug.print("Should be delteing the pending");
                    pending_subscriptions.delete(subscription_id);
                };
                case(?val){
                    pending_subscriptions.put(subscription_id, val);
                };
            };
            return #ok(attempts);
        };


        public func get_subscription_handler(event_type: Text) : async Result.Result<[Principal], Types.DRouteError>{
            switch(subscription_handlers.get(event_type)){
                case(null){#err(Types.errors(#cannot_find_event_type,"get_subscription_handler cannot find event type " # event_type, ?self))};
                case(?val){return #ok(val)};
            };
        };

        public func set_subscription_handler(event_type: Text, items: ?[Principal]) : async Result.Result<?[Principal], Types.DRouteError>{
            switch(items){
                case(null){
                    Debug.print("Should be delteing the pending");
                    subscription_handlers.delete(event_type);
                };
                case(?val){
                    subscription_handlers.put(event_type, val);
                };
            };
            return #ok(items);
        };


        public func get_pending_handler(subscription_id: Blob) : async Result.Result<Types.EventSubscription, Types.DRouteError>{
            switch(pending_handlers.get(subscription_id)){
                case(null){#err(Types.errors(#cannot_find_event_subscription,"get_pending_handler cannot find event subscription " # ulid.toText(Blob.toArray(subscription_id)), ?self))};
                case(?val){return #ok(val)};
            };
        };

        public func set_pending_handler(subscription_id: Blob, subscription: ?Types.EventSubscription) : async Result.Result<?Types.EventSubscription, Types.DRouteError>{
            Debug.print("setting peding handler");
            switch(subscription){
                case(null){
                    Debug.print("Should be delteing the pending");
                    pending_handlers.delete(subscription_id);
                };
                case(?val){
                    Debug.print("we have a new one");
                    pending_handlers.put(subscription_id, val);
                };
            };
            return #ok(subscription);
        };


        public func stabalize(items: ?[Text]): Types.ListenerStoreStable{
            //todo implement picklist
            return {
                pending_subscriptions = ?Iter.toArray(pending_subscriptions.entries());
                event_subscriptions = ?Iter.toArray(event_subscriptions.entries());
                subscription_handlers = ?Iter.toArray(subscription_handlers.entries());
            };
        };

    };



};
