//import RegCanister "canister:droute";
//import UtilityTestCanister "canister:test_runner_droute_utilities";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import C "mo:matchers/Canister";
import Candy "mo:candy/types";
import DRouteTypes "../droute_2/types";
import Debug "mo:base/Debug";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import Iter "mo:base/Iter";
import M "mo:matchers/Matchers";
import Option "mo:base/Option";
import Principal "mo:base/Principal";
import PublisherStore "../droute_2/publisherStore";
import PublisherProcessor "../droute_2/publisherProcessor";
import ListenerStore "../droute_2/listenerStore";
import ListenerProcessor "../droute_2/listenerProcessor";
import Result "mo:base/Result";
import S "mo:matchers/Suite";
import T "mo:matchers/Testable";
import Types "../droute_2/types";
import dRoutePublisher "../droute_2/publisher";
import dRouteListener "../droute_2/listener";
import dRouteRegistration "../droute_2/registration";

actor class test_droute_2() = this {


    private func default_pub_store(principal : Principal) : PublisherStore.DefaultPublisherStore {
        PublisherStore.DefaultPublisherStore({
                self = principal;
                pending_publish = [];
                event_instances = [];
                delivery_confirmation = [];
                broadcast_confirmation = [];
            }
        );
    };

    //let recievedEvents : Buffer.Buffer<DRouteTypes.DRouteEvent> = Buffer.Buffer<DRouteTypes.DRouteEvent>(16);
    //dummy instantiation...reset in each test
    var dRoutePub = dRoutePublisher.dRoutePublisher(#StartUp({
            self = Principal.fromText("aaaaa-aa");
            reg_canister = Principal.fromText("aaaaa-aa");
            store = default_pub_store(Principal.fromText("aaaaa-aa"));
            onEventPublish = null;
            onEventRecieved = null;
            onEventBroadcastConfirmation = null;
            onEventDeliveryConfirmation = null;
            onEventDeliveryComplete = null;
        }));

    var dRouteLis = dRouteListener.dRouteListener(#StartUp({
            self = Principal.fromText("aaaaa-aa");
            reg_canister = Principal.fromText("aaaaa-aa");
            store = ListenerStore.DefaultListenerStore({
                self = Principal.fromText("aaaaa-aa");
                pending_subscriptions=[];
                event_subscriptions=[];
                pending_handlers=[];
            });
            onEventNotification = null;
            onEventSubscriptionConfirmation = null;
            onEventHandlerRequest = null;
            onEventHandlerResponse = null;
            onEventSubscription = null;
            onEventSubscriptionRequest = null;
            onInit = null;
        }));

    var publish_recieved_buffer = Buffer.Buffer<Blob>(1);
    var subscription_recieved_buffer = Buffer.Buffer<Blob>(1);
    var event_recieved_buffer = Buffer.Buffer<Blob>(1);

    public shared func test() : async {#success; #fail : Text} {
        Debug.print("running tests for droute_2");

        let suite = S.suite("test publisher", [
            
                    S.test("test testSubscription", switch(await testSubscription()){case(#success){true};case(_){false};}, M.equals<Bool>(T.bool(true))),
                    S.test("test getPublishingCanisters", switch(await testGetPublishingCanisters()){case(#success){true};case(_){false};}, M.equals<Bool>(T.bool(true))),
                    S.test("test testPublishRecieved", switch(await testPublishRecieved()){case(#success){true};case(_){false};}, M.equals<Bool>(T.bool(true))),

                    
                    
                ]);
        S.run(suite);



        return #success;

    };


    public shared func testGetPublishingCanisters() : async {#success; #fail : Text} {
        Debug.print("running testGetPublishingCanisters");

        let regCanister = await dRouteRegistration.DRouteRegistration();

        dRoutePub := dRoutePublisher.dRoutePublisher(#StartUp({
            self = Principal.fromActor(this);
            reg_canister = Principal.fromActor(regCanister);
            store = default_pub_store(Principal.fromActor(this));
            onEventPublish = null;
            onEventRecieved = null;
            onEventBroadcastConfirmation = null;
            onEventDeliveryConfirmation = null;
            onEventDeliveryComplete = null;
        }));
            
        Debug.print("should have called");
        let regResult = dRoutePub.syncRegistration();
        Debug.print("did it callcalled");

        label waitForResponse for(thisItem in Iter.range(0,10)){
            Debug.print("waiting on a round");
            let result = await regCanister.getMetrics_reg_droute();
            if(dRoutePub.b_registration_updated == true){
                break waitForResponse;
            };
        };

        

        let suite = S.suite("test testGetPublishingCanisters", [
            S.test("registration size is updated", dRoutePub.b_registration_updated, M.equals<Bool>(T.bool(true))), //update to actual value when allocations occur
            S.test("registration is regcanister", if(dRoutePub.get_publishing_canisters().size() == 1){
                Principal.toText(dRoutePub.get_publishing_canisters()[0])
            } else{"notaprincipal"}, M.equals<Text>(T.text(Principal.toText(Principal.fromActor(regCanister))))) //update to allocation when set up
        ]);

        Debug.print("running suite");
        S.run(suite);
        Debug.print("suite done");

        return #success;


    };

    

    public shared func testPublishRecieved() : async {#success; #fail : Text} {
        Debug.print("running testPublishRecieved");

        let regCanister = await dRouteRegistration.DRouteRegistration();

        let  store = default_pub_store(Principal.fromActor(this));
        
        let processor = PublisherProcessor.DefaultPublisherProcessor({
            self = Principal.fromActor(this);
            store = store;
        });

        dRoutePub := dRoutePublisher.dRoutePublisher(#StartUp({
            self = Principal.fromActor(this);
            reg_canister = Principal.fromActor(regCanister);
            store = store;
            onEventPublish = ?processor.handleEventPublish;
            onEventRecieved = ?processor.handleEventRecieved;
            onEventBroadcastConfirmation = ?processor.handleEventBroadcastConfirmation;
            onEventDeliveryConfirmation = ?processor.handleEventDeliveryConfirmation;
            onEventDeliveryComplete = null;
        }));

        //empty the buffer
        publish_recieved_buffer := Buffer.Buffer<Blob>(1);
            
        Debug.print("should have called");
        let regResult = dRoutePub.syncRegistration();
        Debug.print("did it callcalled");

        label waitForResponse for(thisItem in Iter.range(0,10)){
            Debug.print("waiting on a round");
            let result = await regCanister.getMetrics_reg_droute();
            if(dRoutePub.b_registration_updated == true){
                break waitForResponse;
            };
        };

        let event  = {
            event_type = "test123";
            user_id : Principal = Principal.fromActor(this);
            dataConfig  = #dataIncluded{
                data = [(0,0,#Bytes(#frozen([1:Nat8,2:Nat8,3:Nat8,4:Nat8])) : Candy.CandyValue)]};
            notifications = ?{
                recieved = ?Principal.fromActor(this);
                subscription_broadcast = ?Principal.fromActor(this);
                subscription_confirmed = ?Principal.fromActor(this);
                subscription = ?Principal.fromActor(this);
                subscription_fulfiled = ?Principal.fromActor(this);
                delivery_complete = ?Principal.fromActor(this);
            }

        };

        Debug.print(debug_show(event));


        

        let event_instance = switch(await dRoutePub.publish(event)){
            case(#ok(val)){val;};
            case(#err(err)){Debug.print("ERROR ERROR ERROR - Cant publish"); return #fail("cant publish");};
        };

        label waitForResponse for(thisItem in Iter.range(0,10)){
            Debug.print("waiting on a round");
            let handleFuture = regCanister.processQueue();
            let result = await regCanister.getMetrics_reg_droute();
            switch(await store.get_pending_publish(event_instance.event_id)){
                case(#ok(val)){Debug.print("checking the store" # debug_show(val))};
                case(#err(err)){break waitForResponse;};
            };
        };

        let suite = S.suite("test testPublishRecieved", [
            S.test("pending publish is called", switch(await store.get_pending_publish(event_instance.event_id)){
                case(#ok(val)){
                    Nat.toText(val);
                };
                case(#err(err)){
                    if(err.number == 1){
                        "expected error";
                    } else {
                        debug_show(err);
                    }
                };
            } , M.equals<Text>(T.text("expected error"))), //update to actual value when allocations occur
            
        ]);

        Debug.print("running suite");
        S.run(suite);
        Debug.print("suite done");

        return #success;
    };


    public shared func testSubscription() : async {#success; #fail : Text} {
        Debug.print("running testSubscription");

        let regCanister = await dRouteRegistration.DRouteRegistration();

        let store = ListenerStore.DefaultListenerStore({
                self = Principal.fromActor(this);
                pending_subscriptions = [];
                event_subscriptions = [];
                pending_handlers =[];}
            );
        
        let processor = ListenerProcessor.DefaultListenerProcessor({
            self = Principal.fromActor(this);
            store = store;
        });

        dRouteLis := dRouteListener.dRouteListener(#StartUp({
            self = Principal.fromActor(this);
            reg_canister = Principal.fromActor(regCanister);
            store = store;
            onEventNotification = ?processor.handleEventNotification;
            onEventSubscriptionConfirmation = ?processor.handleEventSubscriptionConfirmation;
            onEventHandlerRequest = ?processor.handleEventHandlerRequest;
            onEventHandlerResponse = ?processor.handleEventHandlerResponse;
            onEventSubscription = ?processor.handleEventSubscription;
            onEventSubscriptionRequest = ?processor.handleEventSubscriptionRequest;
            onInit = ?processor.handleInit;
        }));

        dRouteLis.init();

        //empty the buffer
        subscription_recieved_buffer := Buffer.Buffer<Blob>(1);
            

        let subscription_request : Types.EventSubscriptionRequest = {
            event_type = "test123";
            filter = null;
            throttle = null;
            destination_set = null;
            user_id = Principal.fromActor(this);
            controllers = null;
            auto_start = true;
            notifications = ?{
                recieved = ?Principal.fromActor(this);
                throttled = null;
            };
        };


        Debug.print(debug_show(subscription_request));


        

        let subscription_id = switch(await dRouteLis.subscribe(subscription_request, null)){
            case(#ok(val)){
                Debug.print("response from subscribe was" # debug_show(val));
                switch(val){
                    case(#needHandler(new_id)){new_id};
                    case(#pendingResponse(new_id)){new_id};
                };
            };
            case(#err(err)){Debug.print("ERROR ERROR ERROR - Cant subscribe"); return #fail("cant subscribe");};
        };

        label waitForResponse for(thisItem in Iter.range(0,10)){
            Debug.print("waiting on a round handler");
            let result = await regCanister.getMetrics_reg_droute();
            switch(await store.get_pending_handler(subscription_id)){
                case(#ok(val)){Debug.print("checking the store" # debug_show(val))};
                case(#err(err)){
                    Debug.print("found a breaking error for handler" # debug_show(err));
                    break waitForResponse;};
            };
        };

        //wait to see the request
        label waitForResponse for(thisItem in Iter.range(0,10)){
            Debug.print("waiting on a round sub 1");
            let result = await regCanister.getMetrics_reg_droute();
            switch(await store.get_pending_subscription(subscription_id)){
                case(#ok(val)){
                    Debug.print("found a breaking item for sub" # debug_show(val));
                    break waitForResponse;
                };
                case(#err(err)){
                    Debug.print("havent found it yet" # debug_show(err));
                 };
            };
        };

        label waitForResponse for(thisItem in Iter.range(0,10)){
            Debug.print("waiting on a round sub 2");
            let result = await regCanister.getMetrics_reg_droute();
            switch(await store.get_pending_subscription(subscription_id)){
                case(#ok(val)){Debug.print("checking the store" # debug_show(val))};
                case(#err(err)){
                    Debug.print("found a breaking error for sub" # debug_show(err));
                    break waitForResponse;};
            };
        };

        // At this point we have a subscription and now we need to make sure the subscriptoin is serviced when an event comesthrough

        let  pubstore = default_pub_store(Principal.fromActor(this));
        
        let pubprocessor = PublisherProcessor.DefaultPublisherProcessor({
            self = Principal.fromActor(this);
            store = store;
        });

        dRoutePub := dRoutePublisher.dRoutePublisher(#StartUp({
            self = Principal.fromActor(this);
            reg_canister = Principal.fromActor(regCanister);
            store = pubstore;
            onEventPublish = ?pubprocessor.handleEventPublish;
            onEventRecieved = ?pubprocessor.handleEventRecieved;
            onEventBroadcastConfirmation = ?pubprocessor.handleEventBroadcastConfirmation;
            onEventDeliveryConfirmation = ?pubprocessor.handleEventDeliveryConfirmation;
            onEventDeliveryComplete = null;
        }));

        //empty the buffer
        publish_recieved_buffer := Buffer.Buffer<Blob>(1);
        event_recieved_buffer := Buffer.Buffer<Blob>(1);
            
        Debug.print("should have called");
        let regResult = dRoutePub.syncRegistration();
        Debug.print("did it callcalled");

        label waitForResponse for(thisItem in Iter.range(0,10)){
            Debug.print("waiting on a round");
            let result = await regCanister.getMetrics_reg_droute();
            if(dRoutePub.b_registration_updated == true){
                break waitForResponse;
            };
        };

        let event = {
            event_type = "test123";
            user_id = Principal.fromActor(this);
            dataConfig = #dataIncluded{
                data = [(0,0,#Bytes(#frozen([1:Nat8,2:Nat8,3:Nat8,4:Nat8])) : Candy.CandyValue)]};
            notifications = ?{
                recieved = ?Principal.fromActor(this);
                subscription_broadcast = ?Principal.fromActor(this);
                subscription_confirmed = ?Principal.fromActor(this);
                subscription_fulfiled = ?Principal.fromActor(this);
                delivery_complete = ?Principal.fromActor(this);
            }

        };

        Debug.print(debug_show(event));


        

        let event_instance = switch(await dRoutePub.publish(event)){
            case(#ok(val)){val;};
            case(#err(err)){Debug.print("ERROR ERROR ERROR - Cant publish"); return #fail("cant publish");};
        };

        label waitForResponse for(thisItem in Iter.range(0,10)){
            Debug.print("waiting on a round for the item to be published");
            let result = await regCanister.getMetrics_reg_droute();
            switch(await pubstore.get_pending_publish(event_instance.event_id)){
                case(#ok(val)){Debug.print("checking the store" # debug_show(val))};
                case(#err(err)){break waitForResponse;};
            };
        };


        label waitForResponse for(thisItem in Iter.range(0,10)){
            Debug.print("waiting on a round for the item to be broadcast");
            let handleFuture = regCanister.processQueue();
            let result = await regCanister.getMetrics_reg_droute();
            switch(await pubstore.get_event_broadcast_confirmation(event_instance.event_id, subscription_id)){
                case(#ok(val)){
                    Debug.print("found a breaking item for broadcast" # debug_show(val));
                    break waitForResponse;
                };
                case(#err(err)){
                    Debug.print("havent found it yet" # debug_show(err));
                 };
            };
        };

        let suite = S.suite("test testSubscribeRecieved", [
            S.test("pending handler is cleared", switch(await store.get_pending_handler(subscription_id)){
                case(#ok(val)){
                    "should not have found " # val.event_type;
                };
                case(#err(err)){
                    if(err.number == 1001){
                        "expected error";
                    } else {
                        debug_show(err);
                    }
                };
            } , M.equals<Text>(T.text("expected error"))),
            S.test("pending subscribe is cleared", switch(await store.get_pending_subscription(subscription_id)){
                case(#ok(val)){
                    Nat.toText(val);
                };
                case(#err(err)){
                    if(err.number == 1001){
                        "expected error";
                    } else {
                        debug_show(err);
                    }
                };
            } , M.equals<Text>(T.text("expected error"))), 
            S.test("event subscription collection has event", switch(await store.get_event_subscription(subscription_id)){
                case(#ok(val)){
                    if(val.event_type == "test123"){
                        "correct event";
                    } else {
                        "wrong event " # debug_show(val);
                    }
                    
                };
                case(#err(err)){
                    debug_show(err);
                };
            } , M.equals<Text>(T.text("correct event"))), 
            S.test("event broadcast is confirmed", switch(await pubstore.get_event_broadcast_confirmation(event_instance.event_id, subscription_id)){
                case(#ok(val)){
                    
                        "correct subscription";
                   
                    
                };
                case(#err(err)){
                    debug_show(err);
                };
            } , M.equals<Text>(T.text("correct subscription"))), 
            S.test("listener recieved event", if(event_recieved_buffer.size() == 1){
                if(event_recieved_buffer.get(0) == event_instance.event_id){
                   
                    "correct event"
                }else {
                "wrong event " # debug_show(event);
           
                };
            } else {
                "no event found"
            }, M.equals<Text>(T.text("correct event"))), 
            
        ]);

        Debug.print("running suite");
        S.run(suite);
        Debug.print("suite done");

        return #success;
    };


    public shared(msg) func get_publishing_canisters_confirm_droute(items: [Principal]) : (){
        Debug.print("get_publishing_canisters_confirm_droute was called with " # debug_show(items));
        let result = dRoutePub.sync_registration_confirm(items, msg.caller);
        return;
    };

    

    public shared(msg) func event_recieved_droute(event_id: Blob) : (){
        Debug.print("event_recieved_droute was called with " # debug_show(event_id));
        let result = dRoutePub.publish_recieved(event_id, msg.caller);
        return;
    };

    public shared(msg) func get_handler_canisters_for_event_response_droute(items: [Principal], subscription_id: Blob) : (){
        Debug.print("get_handler_canisters_for_event_response_droute was called with " # debug_show(subscription_id));
        let result = dRouteLis.subscription_handler_recieved(items, subscription_id, msg.caller);
        return;
    };

    

    public shared(msg) func subscribe_event_response_droute(response : Result.Result<Types.EventSubscription, Types.DRouteError>) : (){
        Debug.print("subscribe_event_response_droute was called with " # debug_show(response));
        switch(response){
            case(#err(err)){
                Debug.print("We need to do something with this error");
            };
            case(#ok(sub)){
                let result = dRouteLis.subscription_confirm_recieved(sub, msg.caller);
            };
        };
        
        return;
    };

    public shared(msg) func notify_event_droute(event: Types.EventInstance) : (){
        Debug.print("notify_event_droute was called with " # debug_show(event.event.event_type));
        event_recieved_buffer.add(event.event_id);
        let result = dRouteLis.notify_event_recieved(event, msg.caller);
        return;
    };

    public shared(msg) func subscription_broadcast_droute(event_id: Blob, subscription_id : Blob) : (){
        Debug.print("notify_event_droute subscription_broadcast_droute called with " # debug_show(event_id) # debug_show(subscription_id));
        
        let result = dRoutePub.publish_broadcast({
            event_id = event_id;
            subscription_id = subscription_id;
            caller=msg.caller;
            //todo: probably need heap process id
        });
        return;

    };

    

    /* public func __dRouteSubValidate(principal : Principal.Principal, user_id: Nat) : async (Bool, Blob, DRouteTypes.MerkleTreeWitness){

        return (true, Blob.fromArray([1:Nat8]), #empty);
    };

    public shared func testSubscribe() : async {#success; #fail : Text} {
        Debug.print("running testSubscribe");

        let dRouteList  = dRouteListener.dRouteListener({regPrincipal = initArgs.regPrincipal});

        let eventSub : DRouteTypes.SubscriptionRequest = {
            eventType = "test123";
            filter : ?DRouteTypes.SubscriptionFilter = null;
            throttle: ?DRouteTypes.SubscriptionThrottle = null;
            destinationSet = [Principal.fromActor(this)];//send notifications to this canister
            user_id = 1;
        };

        Debug.print(debug_show(eventSub));


        let result = await dRouteList.subscribe(eventSub);

        let pubCanister : DRouteTypes.PublishingCanisterActor = actor(Principal.toText(dRouteList.regPrincipal));


        let pubResult = await pubCanister.publish({
            eventType = "test123";
            user_id = 2;
            dataConfig = #dataIncluded{
            data = [(0,0,#Bytes(#frozen([1:Nat8,2:Nat8,3:Nat8,4:Nat8])))]};
        });

        Debug.print("pubResult " # debug_show(pubResult));

        var pendingItems = true;
        var handbreak = 0;
        label clearQueue while(pendingItems == true){
            handbreak +=1;
            if(handbreak > 1000){
                return #fail("handbreak overrun");
            };
            let processResult = await pubCanister.processQueue();
            Debug.print("processResult " # debug_show(processResult));
            switch(processResult){
                case(#ok(aResult)){
                    if(aResult.queueLength == 0){
                        pendingItems := false;
                    } else {
                        recievedEvents.clear();
                    };
                };
                case(#err(aErr)){
                    return #fail(aErr.text);
                };
            };

        };


        //result should now be saved in another var
        var bMessageDelivered : Bool = false;

        Debug.print("recievedevents " # debug_show(recievedEvents.size()));
        for(thisItem in recievedEvents.vals()){
            Debug.print("an Item " # debug_show(thisItem.eventType) # " " # debug_show(thisItem.user_id));
            if(thisItem.eventType == "test123" and thisItem.user_id == 2){
                bMessageDelivered := true;
            }
        };

        //check to see if the publish is in the logs
        Debug.print("getting logs");
        var logs = await pubCanister.getProcessingLogs("test123");
        //Debug.print(debug_show(logs.data.size()) # " full log " # debug_show(logs));


        switch(logs){
            case(#pointer(logs)){
                return #fail("returned a pointer");
            };
            case(#notFound){
                return #fail("returned a not found");
            };
            case(#data(logs)){
                let logArray = Array.map<MetaTree.Entry, ?DRouteTypes.BroadcastLogItem>(logs.data, func(a){
                    DRouteUtilities.deserializeBroadcastLogItem(a.data);
                });


                let dataSize = logs.data.size();
                let lastlog = DRouteUtilities.deserializeBroadcastLogItem(logs.data[dataSize-1].data);
                Debug.print("last log " # debug_show(lastlog));



                //Debug.print("full log "# debug_show(logArray));

                switch(result, pubResult, lastlog){
                    case(#ok(result), #ok(pubResult), ?lastlog){
                        var eventDRouteIDLogs = await pubCanister.getProcessingLogsByIndex("__eventDRouteID", pubResult.dRouteID);
                        var eventuser_idLogs = await pubCanister.getProcessingLogsByIndex("__eventuser_id", 2);
                        var subscriptionDRouteIDLogs = await pubCanister.getProcessingLogsByIndex("__subscriptionDRouteID", result.subscriptionID);
                        var subscriptionuser_idLogs = await pubCanister.getProcessingLogsByIndex("__subscriptionuser_id", 1);

                        switch(eventDRouteIDLogs, eventuser_idLogs, subscriptionDRouteIDLogs, subscriptionuser_idLogs){
                            case(#data(eventDRouteIDLogs),#data(eventuser_idLogs),#data(subscriptionDRouteIDLogs),#data(subscriptionuser_idLogs)){
                                var eventDRouteIDLog = Option.unwrap(DRouteUtilities.deserializeBroadcastLogItem(eventDRouteIDLogs.data[eventDRouteIDLogs.data.size()-1].data));
                                var eventuser_idLog = Option.unwrap(DRouteUtilities.deserializeBroadcastLogItem(eventuser_idLogs.data[eventuser_idLogs.data.size()-1].data));
                                var subscriptionDRouteIDLog = Option.unwrap(DRouteUtilities.deserializeBroadcastLogItem(subscriptionDRouteIDLogs.data[subscriptionDRouteIDLogs.data.size()-1].data));
                                var subscriptionuser_idLog = Option.unwrap(DRouteUtilities.deserializeBroadcastLogItem(subscriptionuser_idLogs.data[subscriptionuser_idLogs.data.size()-1].data));

                                Debug.print("running suite" # debug_show(result));

                                let suite = S.suite("test subscribe", [
                                    S.test("subscription id exists", result.subscriptionID, M.anything<Int>()),
                                    //todo test the signature

                                    ///test that the event was recieved
                                    S.test("message was recived", bMessageDelivered : Bool, M.equals<Bool>(T.bool(true))),
                                    ///test that the event was logged
                                    S.test("log was written user_id", lastlog.eventuser_id : Nat, M.equals<Nat>(T.nat(2))),
                                    S.test("log was written eventType", lastlog.eventType : Text, M.equals<Text>(T.text("test123"))),
                                    S.test("log was written eventdrouteID", lastlog.eventDRouteID : Nat, M.equals<Nat>(T.nat(pubResult.dRouteID))),

                                    ///test indexes were created
                                    S.test("index event droute id was written", eventDRouteIDLog.eventDRouteID : Nat, M.equals<Nat>(T.nat(pubResult.dRouteID))),
                                    S.test("index event user id was written", eventuser_idLog.eventuser_id : Nat, M.equals<Nat>(T.nat(2))),
                                    S.test("index subscription droute id was written", subscriptionDRouteIDLog.eventDRouteID : Nat, M.equals<Nat>(T.nat(pubResult.dRouteID))),
                                    S.test("index subscription user id was written", subscriptionuser_idLog.eventuser_id : Nat, M.equals<Nat>(T.nat(2))),



                                ]);

                                S.run(suite);

                                return #success;
                            };
                            case(_,_,_,_){
                                Debug.print("an error pointer result" # debug_show(result));
                                return #fail("check logs for pointer");
                            };
                        };
                    };
                    case(#err(err), _, _){
                        Debug.print("an error sub result" # debug_show(result));
                        return #fail(err.text);
                    };
                    case(_, #err(err), _){
                        Debug.print("an error pubresult" # debug_show(result));
                        return #fail(err.text);
                    };
                    case(_,_,_){
                        Debug.print("an error pubresult" # debug_show(result));
                        return #fail("err.text");
                    };
                };
            };

        };


    }; */




};