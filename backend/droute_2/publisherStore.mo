///////////////////////////////
/*
©2021 RIVVIR Tech LLC
All Rights Reserved.
This code is released for code verification purposes. All rights are retained by RIVVIR Tech LLC and no re-distribution or alteration rights are granted at this time.
*/
///////////////////////////////

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Bloob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Candy "mo:candy/types";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
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
import Types "types";
import XorShift "mo:rand/XorShift";
import ulid "mo:ulid/ulid";

module {

    public class DefaultPublisherStore(initArgs: Types.DRoutePublisherStoreInitArgs){

        let pending_publish : RBTree.RBTree<Blob, Nat> = RBTree.RBTree<Blob,Nat>(Blob.compare); //why RB Tree - already in order, self balancing
        let event_instances : RBTree.RBTree<Blob, Types.EventInstance> = RBTree.RBTree<Blob,Types.EventInstance>(Blob.compare); //why RB Tree - already in order, self balancing
        let delivery_confirmation : RBTree.RBTree<Blob, RBTree.RBTree<Blob,Int>> = RBTree.RBTree<Blob, RBTree.RBTree<Blob,Int>> (Blob.compare); //why RB Tree - already in order, self balancing (EventID, SubscriptionID, Timestamp)
        let broadcast_confirmation : RBTree.RBTree<Blob, RBTree.RBTree<Blob,Int>> = RBTree.RBTree<Blob, RBTree.RBTree<Blob,Int>> (Blob.compare); //why RB Tree - already in order, self balancing (EventID, SubscriptionID, Timestamp)
        let self = initArgs.self;
        
        for(thisItem in initArgs.pending_publish.vals()){
            pending_publish.put(thisItem.0,thisItem.1);
        };

        for(thisItem in initArgs.event_instances.vals()){
            event_instances.put(thisItem.0,thisItem.1);
        };
                
        //used to create ulids
        //private let rr = XorShift.toReader(XorShift.XorShift64(?Nat64.fromNat(Nat32.toNat(Principal.hash(self)))));
        //private let se = Source.Source(rr, 1);

        public func get_event_instance(event_id: Blob) : async Result.Result<Types.EventInstance, Types.DRouteError>{
            switch(event_instances.get(event_id)){
                case(null){#err(Types.errors(#cannot_find_event_instance,"get_event_instance cannot find event instance " # ulid.toText(Blob.toArray(event_id)), ?self))};
                case(?val){return #ok(val)};
            };
        };

        public func set_event_instance(event_id: Blob, event_instance: ?Types.EventInstance) : async Result.Result<?Types.EventInstance, Types.DRouteError>{
            switch(event_instance){
                case(null){
                    event_instances.delete(event_id);
                };
                case(?val){
                    event_instances.put(event_id, val);
                };
            };
            return #ok(event_instance);
        };

        public func get_pending_publish(event_id: Blob) : async Result.Result<Nat, Types.DRouteError>{
            switch(pending_publish.get(event_id)){
                case(null){#err(Types.errors(#cannot_find_event_instance,"get_pending_publish cannot find event instance " # ulid.toText(Blob.toArray(event_id)), ?self))};
                case(?val){return #ok(val)};
            };
        };

        public func set_pending_publish(event_id: Blob, attempts: ?Nat) : async Result.Result<?Nat, Types.DRouteError>{
            switch(attempts){
                case(null){
                    Debug.print("Should be delteing the pending");
                    pending_publish.delete(event_id);
                };
                case(?val){
                    pending_publish.put(event_id, val);
                };
            };
            return #ok(attempts);
        };

        public func get_event_delivery_confirmations(event_id: Blob) :  Result.Result<RBTree.RBTree<Blob, Int>, Types.DRouteError>{
            switch(delivery_confirmation.get(event_id)){
                case(null){#err(Types.errors(#cannot_find_event_instance,"get_event_delivery_confirmations cannot find event instance " # ulid.toText(Blob.toArray(event_id)), ?self))};
                case(?val){return #ok(val)};
            };
        };

        public func get_event_delivery_confirmation(event_id: Blob, subscription_id: Blob) : async Result.Result<Int, Types.DRouteError>{
            switch(delivery_confirmation.get(event_id)){
                case(null){#err(Types.errors(#cannot_find_event_instance,"get_event_delivery_confirmation cannot find event instance " # ulid.toText(Blob.toArray(event_id)), ?self))};
                case(?val){
                    switch(val.get(subscription_id)){
                        case(null){#err(Types.errors(#cannot_find_event_subscription,"get_event_delivery_confirmation cannot find subscription instance " # ulid.toText(Blob.toArray(subscription_id)), ?self))};
                        case(?sub){return #ok(sub)};
                    };
                };
            };
        };

        public func set_event_delivery_confirmation(event_id: Blob, subscription_id: Blob, time_stamp: ?Int) : async Result.Result<?Int, Types.DRouteError>{
            switch(delivery_confirmation.get(event_id)){
                case(null){
                    switch(time_stamp){
                        case(null){//nulling a null - do nothing
                        };
                        case(?timestamp){
                            let subTree = RBTree.RBTree<Blob, Int>(Blob.compare);
                            subTree.put(subscription_id, timestamp);
                            delivery_confirmation.put(event_id, subTree);
                        }
                    }
                };
                case(?subTree){
                    switch(time_stamp){
                        case(null){
                            subTree.delete(subscription_id);

                            /* //need a data structure that will let us know when we have 0 entries
                            if(subTree.size() == 0){
                                delivery_confirmation.delete(event_id);
                            }; */
                        };
                        case(?timestamp){
                            subTree.put(subscription_id, timestamp);
                        }
                    }
                };
            };
            
            return #ok(time_stamp);
        };


        public func get_event_broadcast_confirmations(event_id: Blob) :  Result.Result<RBTree.RBTree<Blob, Int>, Types.DRouteError>{
            switch(broadcast_confirmation.get(event_id)){
                case(null){#err(Types.errors(#cannot_find_event_instance,"get_event_broadcast_confirmations cannot find event instance " # ulid.toText(Blob.toArray(event_id)), ?self))};
                case(?val){return #ok(val)};
            };
        };

        public func get_event_broadcast_confirmation(event_id: Blob, subscription_id: Blob) : async Result.Result<Int, Types.DRouteError>{
            switch(broadcast_confirmation.get(event_id)){
                case(null){#err(Types.errors(#cannot_find_event_instance,"get_event_broadcast_confirmation cannot find event instance " # ulid.toText(Blob.toArray(event_id)), ?self))};
                case(?val){
                    switch(val.get(subscription_id)){
                        case(null){#err(Types.errors(#cannot_find_event_subscription,"get_event_broadcast_confirmation cannot find subscription instance " # ulid.toText(Blob.toArray(subscription_id)), ?self))};
                        case(?sub){return #ok(sub)};
                    };
                };
            };
        };

        public func set_event_broadcast_confirmation(event_id: Blob, subscription_id: Blob, time_stamp: ?Int) : async Result.Result<?Int, Types.DRouteError>{
            switch(broadcast_confirmation.get(event_id)){
                case(null){
                    switch(time_stamp){
                        case(null){//nulling a null - do nothing
                        };
                        case(?timestamp){
                            let subTree = RBTree.RBTree<Blob, Int>(Blob.compare);
                            subTree.put(subscription_id, timestamp);
                            broadcast_confirmation.put(event_id, subTree);
                        }
                    }
                };
                case(?subTree){
                    switch(time_stamp){
                        case(null){
                            subTree.delete(subscription_id);

                            /* //need a data structure that will let us know when we have 0 entries
                            if(subTree.size() == 0){
                                broadcast_confirmation.delete(event_id);
                            }; */
                        };
                        case(?timestamp){
                            subTree.put(subscription_id, timestamp);
                        }
                    }
                };
            };
            
            return #ok(time_stamp);
        };


        public func stabalize(items: ?[Text]): Types.PublisherStoreStable{
            //todo implement picklist
            return {
                pending_publish = ?Iter.toArray(pending_publish.entries());
                event_instances = ?Iter.toArray(event_instances.entries());
            };
        };

    };



};
