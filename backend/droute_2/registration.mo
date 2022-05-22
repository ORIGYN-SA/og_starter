import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Heap "mo:base/Heap";
import List "mo:base/List";

import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Order "mo:base/Order";
import RBTree "mo:base/RBTree";
import Text "mo:base/Text";
import Types "types";
import XorShift "mo:rand/XorShift";
import Source "mo:ulid/Source";

shared (deployer) actor class  DRouteRegistration() = this {


    



    public shared(msg) func get_publishing_canisters_request_droute(instances : Nat) : () {
        //allocate the publishing canisters
        //one shot them back to the requestor
        let publisherActor : Types.PublisherCanisterActor = actor(Principal.toText(msg.caller));

        //for now we are just going to have the reg canister do everything
        let confirmAllocation = publisherActor.get_publishing_canisters_confirm_droute([Principal.fromActor(this)]);
    };

    //we only need the subscription id so we can pass it back
    public shared(msg) func get_handler_canisters_for_event_droute(event_type: Text, subscription_id: Blob) : () {
        Debug.print("in get_handler_canisters_for_event_droute");
        let listeningActor : Types.ListenerCanisterActor = actor(Principal.toText(msg.caller));

        //for now we are just going to have the reg canister do everything
        let confirmList = listeningActor.get_handler_canisters_for_event_response_droute([Principal.fromActor(this)], subscription_id);
    };


    /////////////////////////////////////////
    //todo: probably needs to be moved to a different class for the PublishingCanister Class
    //keep below chunk seperated to move to a different canister
    ////////////////////////////////////////
    func broadcastOrder(x : Types.EventSubscription, y :  Types.EventSubscription) : Order.Order{
        //todo: US 3; convert this to staked tokens
        //right now, first subscription in
        return Blob.compare(x.subscription_id, y.subscription_id);
    };

    //move to publishing canister
    stable var pendingQueue: List.List<Types.EventInstance> = List.nil<Types.EventInstance>();
    stable var upgradePendingHeap: Heap.Tree<Types.EventSubscription> = null;
    var pendingHeap: Heap.Heap<Types.EventSubscription> = Heap.Heap<Types.EventSubscription>(broadcastOrder);


    //move to publishing canister
    public shared(msg) func publish_event_droute(event : Types.EventInstance) : () {
        
        
        //let the publisher know you recieved
        //todo: check the event registration and notification config
        let publisherActor : Types.PublisherCanisterActor = actor(Principal.toText(msg.caller));

        Debug.print("in publish event on the reg canister");

        //for now we are just going to have the reg canister do everything

        //do we need to notify the senderthat we recieved the event?
        switch(event.event.notifications){
            case(null){Debug.print("skipping notify notification null");};
            case(?val){
                switch(val.recieved){
                    case(null){Debug.print("skipping notify recieved null");};
                    case(?recieved){
                        //for now the principal shold be the caller
                        if(recieved == msg.caller){
                            Debug.print("found notify of reciept,calling");
                            let confirmRecieved = publisherActor.event_recieved_droute(event.event_id);
                        } else {
                            Debug.print("skipping notify equality");
                        };
                    };
                };
            };
        };

        //file the event so it can be broadcast
        pendingQueue := List.push(event, pendingQueue);
        
    };

    //move to publishing canister
    let subscriptions : RBTree.RBTree<Text, RBTree.RBTree<Blob, Types.EventSubscription>> = RBTree.RBTree<Text, RBTree.RBTree<Blob, Types.EventSubscription>>(Text.compare);

    //move to publishing canister
    public shared(msg) func subscribe_event_droute(subscription : Types.EventSubscription) : () {
        
        
        //let the listener know you recieved - probably need to move it lower if we want to honor notification principals
        let listenerActor : Types.ListenerCanisterActor = actor(Principal.toText(msg.caller));

        Debug.print("in publish event on the reg canister");

        //todo determine if the subscription should be started or not - maybe it always starts stopped?

        let request = switch(subscription.request){
            case(null){
                //probably an error  do we send an error in the response?
                return;
            };
            case(?val){val};
        };

        //do we need to notify the senderthat we recieved the event?
        switch(request.notifications){
            case(null){Debug.print("skipping notify notification null");};
            case(?val){
                switch(val.recieved){
                    case(null){Debug.print("skipping notify recieved null");};
                    case(?recieved){
                        //for now the principal shold be the caller
                        if(recieved == msg.caller){
                            Debug.print("found notify of reciept of sub,calling");
                            let confirmRecieved = listenerActor.subscribe_event_response_droute(#ok(subscription));
                        } else {
                            Debug.print("skipping notify equality");
                        };
                    };
                };
            };
        };

        //todo: file the subscription so it can be serviced
        switch(subscriptions.get(subscription.event_type)){
            case(null){
                let sub_list = RBTree.RBTree<Blob,Types.EventSubscription>(Blob.compare);
                sub_list.put(subscription.subscription_id, subscription);
                subscriptions.put(subscription.event_type, sub_list);
            };
            case(?sub_list){
                switch(sub_list.get(subscription.subscription_id)){
                    case(null){
                        sub_list.put(subscription.subscription_id, subscription);
                    };
                    case(existing_sub){
                        //this sub exists...do we replace?
                        //todo validate replacement permissions
                        sub_list.put(subscription.subscription_id, subscription);
                    };
                };
            };
        };
        
    };

    //move to publishing canister
    public shared(msg) func processQueue() : (){
        //see if there are events in the queue - we always get the first event

        //used to create ulids - add in timestamp or is it already in there?
        let rr = XorShift.toReader(XorShift.XorShift64(?Nat64.fromNat(Nat32.toNat(Principal.hash(Principal.fromActor(this))))));
        let se = Source.Source(rr, 1);


        var thisEvent : ?Types.EventInstance = List.last<Types.EventInstance>(pendingQueue);
        switch(thisEvent){
            case(null){
                //there are no events in the queue to be procesed
                return;
            };
            case(?thisEvent){
                var currentHeap : Heap.Heap<Types.EventSubscription> = switch(pendingHeap.peekMin()){
                    case(null){
                        //there is nothing in the heap, lets fill it up

                        //see if there are subscriptions
                        //todo: US 21; the following function should apply any filters and throttles
                        //create a heap of subscription calls
                        let heapResult = buildSubscriptionsHeap(thisEvent.event.event_type);
                        //todo: US 34; handle what to do if there are too many subscriptions
                        pendingHeap := heapResult;

                        pendingHeap;

                    };
                    case(?item){
                        pendingHeap;
                    };
                };


                switch(currentHeap.peekMin()){
                    case(null){
                        //there is nothing in the heap, we don't have anything to do

                        //.the last item must be done or have no subscriptions and was abandoned, so lets remove it
                        pendingQueue := List.take<Types.EventInstance>(pendingQueue, List.size<Types.EventInstance>(pendingQueue)-1);

                        return;
                    };
                    case(?item){

                        //lets process the heap!
                        let heapCycleID = se.new();

                        var itemsProcessed = 0;

                        //todo: handbreak!
                        label doHeap while(1==1){


                            let thisSub = pendingHeap.removeMin();
                            switch(thisSub){
                                case(null){
                                    //we are done
                                    break doHeap;
                                };
                                case(?thisSub){
                                    let aActorPrincipal = if(thisSub.destination_set.size() == 0){
                                        thisSub.destination_set[0];
                                    } else {
                                        thisSub.destination_set[Nat.rem(Int.abs(Time.now()) + itemsProcessed, thisSub.destination_set.size())];
                                    };
                                    let aActor : Types.ListenerCanisterActor = actor(Principal.toText(aActorPrincipal));
                                    
                                    Debug.print("in processing" # debug_show(thisEvent.event.user_id));

                                    //if we await the response we may not get the log item written with atomicity
                                    Debug.print("calling actor notify.");
                                    let responseFuture = aActor.notify_event_droute(thisEvent);

                                    

                                    //notify publisher that a subscripton has been delivered
                                    switch(thisEvent.event.notifications){
                                        case(null){Debug.print("skipping subscription notification null");};
                                        case(?val){
                                            switch(val.subscription_broadcast){
                                                case(null){Debug.print("skipping subscription recieved null");};
                                                case(?subscription_broadcast){
                                                    //for now the principal is called, but should likely be validated
                                                    Debug.print("found notify of subscription delivery,calling");
                                                    let publisherActor : Types.PublisherCanisterActor = actor(Principal.toText(subscription_broadcast));
                                                    let confirmSent = publisherActor.subscription_broadcast_droute(thisEvent.event_id, thisSub.subscription_id);
                                                };
                                            };
                                            switch(val.subscription_fulfiled){
                                                case(null){Debug.print("skipping subscription recieved null");};
                                                case(?subscription_broadcast){
                                                    //todo: add the event/sub to the pending subscription confirmations so when 100% are back we can send the fulfilled
                                                };
                                            };
                                        };
                                    };

                                    //todo: move this calculation of namespace out of the loop
                                    /* let aLogItem :  DRouteTypes.BroadcastLogItem = {
                                        eventType = thisEvent.eventType;
                                        eventDRouteID = thisEvent.dRouteID;
                                        eventUserID = thisEvent.userID;
                                        destination = aActorPrincipal;
                                        //todo: move this calc out of the loop
                                        processor = Principal.fromActor(this);
                                        subscriptionUserID = thisSub.userID;
                                        subscriptionDRoutID = thisSub.dRouteID;
                                        index = itemsProcessed;
                                        heapCycleID = heapCycleID;
                                        dateSent = Time.now();
                                        notifyResponse = aResponse;
                                        //todo figure out how to do errors correctly;
                                        error = aError;
                                    }; */

                                    //not awiting this at this point
                                   /*  Debug.print("writing to metatree " # debug_show(aLogItem));
                                    let marker = metatree.writeAndIndex("com.dRoute.eventbroadcast." # thisEvent.eventType,
                                        Int.abs(Time.now()),
                                        #dataIncluded({data = DRouteUtilities.serializeBroadcastLogItem(aLogItem)}),
                                        true,
                                        broadcastLogItemIndex); */


                                };
                            };

                            itemsProcessed += 1;
                            //todo: US34; figure out handbreak
                            if(itemsProcessed > 10000){
                                break doHeap;
                            };


                        };



                        //take the last item off the pending eventlist
                        //todo: US34 if we haven't fiished then we need to save the event the heap is currenlty processing
                        //remove item from the processing queue
                        pendingQueue := List.take<Types.EventInstance>(pendingQueue, List.size<Types.EventInstance>(pendingQueue)-1);

                        return;
                    };
                };
            };
        };



        //loop through pending heap and send messages.

        return;
    };

    //move to publishing cansiter
    func buildSubscriptionsHeap(event_type : Text) : Heap.Heap<Types.EventSubscription>{
        let thisHeap = Heap.Heap<Types.EventSubscription>(broadcastOrder);
        let aMap = subscriptions.get(event_type);
        switch(aMap){
            case(null){
                return thisHeap;
            };
            case(?aMap){
                //todo: currently we use the heap functionality to order the alert queue but this is not going to be 'infinately scaleable' we will need to keep active track of stake order and use that list, even if it is a multi canister list
                for((thisKey,thisSub) in aMap.entries()){
                    thisHeap.put(thisSub);
                };
                return thisHeap;
            };
        };

    };


    public query(msg) func getMetrics_reg_droute() : async Types.DRouteRegMetrics{
        return {
            time = Time.now();
        };
    };

    public shared(msg) func getMetrics_reg_secure_droute() : async Types.DRouteRegMetrics{
        return {
            time = Time.now();
        };
    };

};