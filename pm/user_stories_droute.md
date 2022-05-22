

# Stakeholders

1. Application Developers(AppDev) - Application developers build application that use a mix of IC tech and traditional tech to build apps for their customers.
2. Dependent Application Developers(DepDev) - Dependent application developers build applications that use a mix of IC tech and traditional tech to build apps and their apps depend on the behaviors of other apps in the IC ecosystem.
3. nISP token users(nISP User) - nISP token users have to own nISP tokens to utilize services overed by dRoute.  They stake tokens to receive preferential notifications of events on the dRoute network.
4. nISP governor(Governor) - a nISP token governor makes decisions to benefit the network. As the network grows in importance they receive a larger payment for their work of governing the network.
5. App user(App User) - an app user uses a service that implements dRoute.
6. dRoute(Service) - the dRoute system.

# Form Language

Application - An computer program that seeks to accomplish some type of work.

Event - an event is raised by an application and represents the occurrence of a particular computation on that application. It includes the event identifier and event metadata

Event Identifier - represents a particular type of event

Event Metadata - represents instance specific data about an event.

Encrypted Event - An Event that has been encrypted so that only certain users can decode it.

Event Subscription - A application can subscribe to an event an in order to have dRoute reserve the occurrence of that event for the subscribing application.

Registration Canister - Canister used to map dRoute notification canisters and dRoute Queues to AppDevs and DepDevs.

Event Notification Canisters - Canisters used to distribute notification and queue entries. Event Notification Canisters are owned by AppDevs.

Event Queue - An event queue will keep a running queue of events that can be handled at an applications leisure.  Event Queue canisters are owned by DepDevs.

Event Notification - A event that is delivered directly to a subscribing application.

Implicit Notifications - A set of notifications that an AppDev or DepDev must implement so that they stay current about registrations.

Event Filter - A filter put in place to limit the types, kind, or content of events that are reserved for an event subscription.

Event Throttle - A throttle puts in place limits to the number or speed of messages that can be handled and details how dropped messages should be chosen.


# Pattern Language

## Self Directed Management

Supported by - Message Throttles, Message Filters

AppDevs and DepDevs should be able to decide how their assigned canisters are managed/paid for.

## Message Throttles -

Supports: Self Directed Management

Allow DepDevs to throttle the messages they receive in order to control costs.

## Message Filters

Supports: Self Directed Management

Allows DepDevs to filter out messages they receive based on the content of the message in order to control costs.

## Secure Data

The System should provides secure data so that outside observers cannot divine what is going on with the system from the outside.

## Prompt Notification

The system should provide for prompt notification of events to be maximally useful.

## Dynamic Registration

The system should dynamically create and move canisters assignments to distribute load in the system.

## Complexity Shield

The dRoute libraries should shield the AppDev and DepDev from most of the complexity of the dRoute system.


# Current Priorities

x. Basic Reporting
1. Encryption of data <- You are here
2. Certification of subscriptions
3. Distribution of processing canisters
4. Staking

# User Stories

1. AA AppDev IWT notify other apps of events that have ocurred during the processing of my application STI increase the network effects of my application.

Status: Pending 11

Notes:

I'm going to assume the multiple canister architecture from the beginning because other wise I'm just going to have a frustrating time trying to pull them apart.

We are going to use piplineify data structures to handle data passing so that we have all the pipelinify options like push pull, included, etc.

I had to add the following to matchers.  I need to fork and reference the branch

  public let nat8Testable : Testable<Nat8> = {
        display = func (nat : Nat8) : Text {Nat8.toText(nat)};
        equals = func (n1 : Nat8, n2 : Nat8) : Bool {n1 == n2};
    };

    public func nat8(n : Nat8) : TestableItem<Nat8> = {
        item = n;
        display = nat8Testable.display;
        equals = nat8Testable.equals;
    };

    public let nat16Testable : Testable<Nat16> = {
        display = func (nat : Nat16) : Text {Nat16.toText(nat)};
        equals = func (n1 : Nat16, n2 : Nat16) : Bool {n1 == n2};
    };

    public func nat16(n : Nat16) : TestableItem<Nat16> = {
        item = n;
        display = nat16Testable.display;
        equals = nat16Testable.equals;
    };

    public let nat32Testable : Testable<Nat32> = {
        display = func (nat : Nat32) : Text {Nat32.toText(nat)};
        equals = func (n1 : Nat32, n2 : Nat32) : Bool {n1 == n2};
    };

    public func nat32(n : Nat32) : TestableItem<Nat32> = {
        item = n;
        display = nat32Testable.display;
        equals = nat32Testable.equals;
    };


    public let nat64Testable : Testable<Nat64> = {
        display = func (nat : Nat64) : Text {Nat64.toText(nat)};
        equals = func (n1 : Nat64, n2 : Nat64) : Bool {n1 == n2};
    };

    public func nat64(n : Nat64) : TestableItem<Nat64> = {
        item = n;
        display = nat64Testable.display;
        equals = nat64Testable.equals;
    };


1A. AA AppDev IWT have my event auto registered with the dRoute canister STI am discoverable by other services

Status: Pending 1C

1B. AA Service IWT forward event messages to the least busy processing queue STI get it processed in a timely manner.

Status: Pending 1C

1C. AA Service IWT have my registration be scalable STI can handle more than 2GB of registrations


3. [stake] AA DepDev User IWT stake my tokens in dRoute STI can get notification priority.


4. [stake] AA DepDev User IWT see where my stake ranks in relation to other dRoute stakers STI can make decisions about my stake.


5. [stake] AA DepDev User IWT have my stake be reliable and maintainable STI don't have to pay attention to it.


6. AA AppUser IWT never have to think about nISP or dRoute STI have a clean user experience.


7. AA Governor IWT support the use of dRoute STI get a larger payment.


8. AA DepDev IWT be assured that my events are delivered as fast as possible STI can respond in a timely manner.


9. AA DepDev IWT be assured that no messages are missed STI don't miss information.


10. AA DepDev IWT have what I pay for message delivery to be predictable STI am not surprised by unexpected expenses.


12. AA AppDev IWT encrypt my event information STI keep my users information safely.


13. AA AppDev IWT control who can subscribe to my events STI can monetize the information coming out of my system.


14. AA DepDev IWT easily pay for data subscriptions from AppDevs STI can easily integrate.


15. AA Governor IWT reward popular events STI incentivize use of the network.


16. AA DepDev IWT transparently receive encrypted data STI don't have to think about encryption.


17. AA Service IWT quickly return function calls STI can handle a large volume of calls.


18. AA Service IWT distribute my processing STI can handle a large volume of calls.


21. AA DepDev IWT  filter out events based on their metadata content STI don't get bombarded by events that I don't care about.


22. AA AppDev IWT keep track of my dRoute canisters STI can manage the cycles needed to run it.


23. AA AppDev IWT give access to my dRout canisters to someone else STI can have them manage the cycles in my canisters.


24. AA AppDev IWT recover the cost of notifying DepDevs of events from my dRoute canisters STI can control expenses.


25. AA DepDev IWT throttle the incoming messages STI don't over spend on cycles.


26. AA AppDev IWT submit events for another canister that has approved me STI can offload event creation from my main process.

27. AA AppDev IWT request my own private set of publication canisters that only I can publish to STI won't get blocked by other apps.

28. AA AppDev IWT request shared publication canisters STI can reduce my costs if I'm willing for reduced delivery times.

29. AA AppDev IWT request a certain number of publication canisters STI can spread the load of my messages across a wide range of servers.

Notes:

We are hard coding the server for the moment and we'll load up the reg canister with the publish functions for the POC and split out later.

Status: Freezer

30. AA Service IWT distribute relevant registrations to assigned publishing canisters STI don't require a query call back to the main canister for registration info.


32. AA DepDev IWT assign a set of destinations that the system can round robin notification to STI can scale my listeners if necessary.

33. AA DepDev IWT have the system ask me if a subscription is valid before it starts broadcasting STI don't get unwanted messages.

34. AA Service IWT chunk broadcasts STI don't overrun the cycle limit.

35. AA AppDev IWT limit who can subscribe to my events STI maintain privacy.

36. AA DepDev IWT have the option to have my subscription measured in start/stoped mode STI can register my sub without immediately getting blasted with events incase I need to do further config.




# Completed user stories

2. AA DepDev IWT subscribe to events of another app STI can trigger processing in my app based on that information.

Status: Completed

11. AA AppDev ITW know who is using my event notifications STI can understand the importance of my application.

Status: Completed

Notes:  AppDevs can query the Broadcast logs to see where their events are going

19. AA DepDev IWT have the option to have events pushed to me by dRoute STI can handle them automatically.

Status: Completed

31. AA AppDev IWT assign a discoverable ID to my events STI can find them later.

Status: Completed

37. AA AppDev IWT query the service for my eventID or eventUserID and get back a report on how that event was handled STI can audit my application.

Status: Completed

38. AA DepDev IWT query the service for my subscriptionID or subscriptionUserID and get back a report on how that subscription was handled STI can audit my application

Status: Completed

# Discarded user stories

20. AA DepDev IWT have the option to have events queue up STI can handle them at my own pace.

Status: Discarded - I think we can handle this with just an event processing canister and the only thing a user has to do is to point the subscription to their processing canisters