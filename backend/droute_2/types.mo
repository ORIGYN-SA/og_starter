import PipelinifyTypes "mo:pipelinify/types";
import Result "mo:base/Result";
import RBTree "mo:base/RBTree";

module {

    public type EventDeliveryConfirmation = {
        event_id : Blob;
        caller: Principal;
        subscription_id: Blob;
    };

    public type DRoutePublisherInitArgs = {
        #StartUp: { //used when the actor is created
            reg_canister: Principal;
            self: Principal;
            store : PublisherStore;
            onEventPublish: ?((EventInstance, PublisherStore) -> async ());
            onEventRecieved: ?((Blob, PublisherStore) -> async ());
            onEventBroadcastConfirmation: ?((EventDeliveryConfirmation, PublisherStore) -> async ());
            onEventDeliveryConfirmation: ?((EventDeliveryConfirmation, PublisherStore) -> async ());
            onEventDeliveryComplete: ?((Blob, PublisherStore) -> async());
        };
        #Rehydrate: {  //used during an upgrade to pickup where the class left off
            reg_canister: Principal; 
            self: Principal;
            store : PublisherStore;
            onEventPublish: ?((EventInstance, PublisherStore) -> async ());
            onEventRecieved: ?((Blob, PublisherStore) -> async ());
            onEventBroadcastConfirmation: ?((EventDeliveryConfirmation, PublisherStore) -> async ());
            onEventDeliveryConfirmation: ?((EventDeliveryConfirmation, PublisherStore) -> async ());
            onEventDeliveryComplete: ?((Blob, PublisherStore) -> async ());
        };
    };

    public type DRoutePublisherStoreInitArgs = {
            self: Principal;
            pending_publish: [(Blob, Nat)];
            event_instances: [(Blob, EventInstance)];
            delivery_confirmation: [(Blob, (Blob, Int))];
            broadcast_confirmation: [(Blob, (Blob, Int))];
    };

    public type DRoutePublisherProcessorInitArgs = {
        self: Principal;
    };


    public type PublisherStore = {
        get_event_instance: (Blob) -> async Result.Result<EventInstance, DRouteError>;
        set_event_instance: (Blob, ?EventInstance) -> async Result.Result<?EventInstance, DRouteError>;

        get_pending_publish: (Blob) -> async Result.Result<Nat, DRouteError>;
        set_pending_publish: (Blob, ?Nat) -> async Result.Result<?Nat, DRouteError>;

        get_event_delivery_confirmations: (Blob) -> Result.Result<RBTree.RBTree<Blob, Int>, DRouteError>;
        get_event_delivery_confirmation: (Blob,Blob) -> async Result.Result<Int, DRouteError>;
        set_event_delivery_confirmation: (Blob,Blob, ?Int) -> async Result.Result<?Int, DRouteError>;

        get_event_broadcast_confirmations: (Blob) -> Result.Result<RBTree.RBTree<Blob, Int>, DRouteError>;
        get_event_broadcast_confirmation: (Blob,Blob) -> async Result.Result<Int, DRouteError>;
        set_event_broadcast_confirmation: (Blob,Blob, ?Int) -> async Result.Result<?Int, DRouteError>;
    };

    public type PublisherProcessor = {
        handleEventPublish: (EventInstance, PublisherStore) -> ();
        handleEventRecieved: (Blob, PublisherStore) -> ();
        handleEventBroadcastConfirmation: (EventDeliveryConfirmation, PublisherStore) -> ();
        handleEventDeliveryConfirmation: (EventDeliveryConfirmation, PublisherStore) -> ();
        handleEventDeliveryComplete: (Blob, PublisherStore) -> ();
    };

    public type DRouteListener = {
        subscribe : (EventSubscriptionRequest, ?Blob) -> async Result.Result<EventSubscriptionResponse, DRouteError>;
    };

    public type DRouteListenerInitArgs = {
        #StartUp: { //used when the actor is created
            reg_canister: Principal;
            self: Principal;
            store : ListenerStore;
            onEventSubscriptionConfirmation: ?((EventSubscription, ListenerStore) -> async ());
            onEventNotification: ?((EventInstance, ListenerStore) -> async ());
            onEventHandlerRequest : ?((EventSubscription, ListenerStore) -> async ());
            onEventHandlerResponse : ?((EventSubscription, [Principal], ListenerStore) -> async());
            onEventSubscription: ?((EventSubscription, ListenerStore) -> async ());
            onEventSubscriptionRequest : ?((Blob, ListenerStore) -> async ());
            onInit: ?((DRouteListener) -> ());
        };
        #Rehydrate: {  //used during an upgrade to pickup where the class left off
            reg_canister: Principal; 
            self: Principal;
            store : ListenerStore;
            onEventSubscriptionConfirmation: ?((EventSubscription, ListenerStore) -> async ());
            onEventNotification: ?((EventInstance, ListenerStore) -> async ());
            onEventHandlerRequest : ?((EventSubscription, ListenerStore) -> async ());
            onEventHandlerResponse : ?((EventSubscription, [Principal], ListenerStore) -> async());
            onEventSubscription: ?((EventSubscription, ListenerStore) -> async ());
            onEventSubscriptionRequest : ?((Blob, ListenerStore) -> async ());
            onInit: ?((DRouteListener) -> ());
        };
    };

    public type DRouteListenerStoreInitArgs = {
            self: Principal;
            pending_subscriptions: [(Blob, Nat)];
            event_subscriptions: [(Blob, EventSubscription)];
            pending_handlers: [(Blob, Nat)];
    };

    public type DRouteListenerProcessorInitArgs = {
        self: Principal;
    };

    public type ListenerStore = {
        get_event_subscription: (Blob) -> async Result.Result<EventSubscription, DRouteError>;
        set_event_subscription: (Blob, ?EventSubscription) -> async Result.Result<?EventSubscription, DRouteError>;

        get_pending_subscription: (Blob) -> async Result.Result<Nat, DRouteError>;
        set_pending_subscription: (Blob, ?Nat) -> async Result.Result<?Nat, DRouteError>;

        get_subscription_handler: (Text) -> async Result.Result<[Principal], DRouteError>;
        set_subscription_handler: (Text, ?[Principal]) -> async Result.Result<?[Principal], DRouteError>;

        get_pending_handler: (Blob) -> async Result.Result<EventSubscription, DRouteError>;
        set_pending_handler: (Blob, ?EventSubscription) -> async Result.Result<?EventSubscription, DRouteError>;
    };

    public type ListenerProcessor = {
        handleEventSubscriptionConfirmation: (EventSubscription, ListenerStore) -> ();
        handleEventNotification: (Blob, ListenerStore) -> ();
        handleEventHandlerRequest: (EventSubscription, ListenerStore) -> ();
        handleEventHandlerResponse: (EventSubscription, [Principal], ListenerStore) -> ();
        handleEventSubscription: (EventSubscription, ListenerStore) -> ();
        handleEventSubscriptionRequest: (Blob, ListenerStore) -> ();
    };
    

    

    public type EventPublishable = {
        event_type: Text;
        user_id: Principal;
        dataConfig: PipelinifyTypes.DataConfig;
        notifications: ?{
            recieved: ?Principal;
            subscription_broadcast: ?Principal;
            subscription_confirmed: ?Principal;
            subscription_fulfiled: ?Principal;
            delivery_complete: ?Principal;
        };
    };

    public type EventRegistration = {
        event_type: Text;
        notifications: {
            recieved: Principal;
            subscription_broadcast: Principal;
            subscription_confirmed: Principal;
            subscription_fulfiled: Principal;
            delivery_complete: Principal;
        };
    };

    public type EventInstance = {
        event_id : Blob;
        timestamp: Int;
        event: EventPublishable;
    };

    public type PublishStatus = {
        #recieved;
        #delivery_confirmation : {
            target : Principal;
        };
        #delivery_complete;
    };

    public type EventPublishConfirmationRequest = {
        event_id: Blob;
        caller: Principal;
        status: PublishStatus;
    };

    public type PublisherStable = {
        pending_publish: ?[(Blob, EventInstance)];
    };

    public type PublisherStoreStable = {
        pending_publish: ?[(Blob, Nat)];
        event_instances: ?[(Blob, EventInstance)];
    };

    public type ListenerStoreStable = {
        pending_subscriptions: ?[(Blob, Nat)];
        event_subscriptions: ?[(Blob, EventSubscription)];
    };

    public type RegCanisterActor = actor{
        get_publishing_canisters_request_droute : shared (instances : Nat) -> ();
        get_handler_canisters_for_event_droute : shared(event_type: Text, subscription_id: Blob) -> ();
    };

    public type PublishingCanisterActor = actor {

        publish_event_droute : shared (EventInstance) -> ();
        get_publishing_canister_for_event_response_droute: shared([Principal]) ->();

        subscribe_event_droute: shared (EventSubscription) -> ();
        notify_event_confirm_droute : shared (EventDeliveryConfirmation) -> ();

        
    };

    public type PublisherCanisterActor = actor {
        get_publishing_canisters_confirm_droute : shared ([Principal]) -> ();
        event_recieved_droute : shared(Blob) -> ();
        subscription_broadcast_droute : shared(Blob, Blob) -> ();
    };

    public type ListenerCanisterActor = actor {
        subscribe_event_response_droute : shared (Result.Result<EventSubscription, DRouteError>) -> ();
        notify_event_droute : shared (EventInstance) -> ();
        get_handler_canisters_for_event_response_droute: shared([Principal], Blob) -> ();
    };

    public type DRouteRegMetrics = {
        time : Int;
    };

    public type SubscriptionFilter = {
        #notImplemented;
    };

    public type SubscriptionThrottle = {
        #notImplemented;
    };

    public type EventSubscription = {
        subscription_id: Blob;
        event_type: Text;
        filter: ?SubscriptionFilter;
        throttle: ?SubscriptionThrottle;
        destination_set: [Principal]; // subscriptions can be sent to multiple canisters if necessary...determine cost
        user_id: Principal; 
        status: {#running; #stopped;};
        controllers: [Principal];
        request: ?EventSubscriptionRequest;
    };

    public type EventSubscriptionRequest = {
        event_type: Text;
        filter: ?SubscriptionFilter;
        throttle: ?SubscriptionThrottle;
        destination_set: ?[Principal]; // subscriptions can be sent to multiple canisters if necessary...determine cost...if null just subscriber
        user_id: Principal;
        controllers: ?[Principal]; //subscription can be controlled by multiple controllers if null just add subscriber
        auto_start: Bool;
        notifications: ?{
            recieved: ?Principal;
            throttled: ?Principal;
        };
    };

    public type EventSubscriptionResponse = {
        #needHandler: Blob;
        #pendingResponse: Blob;
    };

    public type DRouteError = {
        number : Nat32; 
        text: Text; 
        error: Errors; 
        flag_point: Text; caller: ?Principal};

    public type Errors = {
        #nyi;
        #cannot_find_event_instance;
        #cannot_find_event_subscription;
        #cannot_find_event_type;
        #listener_not_initilized;
    };

    public func errors(the_error : Errors, flag_point: Text, caller: ?Principal) : DRouteError {
        switch(the_error){
            
            //
            case(#nyi){
                return {
                    number = 0; 
                    text = "not yet implemented";
                    error = the_error;
                    flag_point = flag_point;
                    caller = caller}
            };
            case(#cannot_find_event_instance){
                return {
                    number = 1; 
                    text = "cannot find event instance";
                    error = the_error;
                    flag_point = flag_point;
                    caller = caller}
            };
            case(#cannot_find_event_type){
                return {
                    number = 2; 
                    text = "cannot find event type";
                    error = the_error;
                    flag_point = flag_point;
                    caller = caller}
            };
            //subscriptions 1000
             case(#cannot_find_event_subscription){
                return {
                    number = 1001; 
                    text = "cannot find subscription instance";
                    error = the_error;
                    flag_point = flag_point;
                    caller = caller}
            };
            //configuration 2000
            case(#listener_not_initilized){
                return {
                    number = 2000; 
                    text = "listener not initilized";
                    error = the_error;
                    flag_point = flag_point;
                    caller = caller}
            };

            

            
            
        };
    };

}