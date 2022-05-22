

# Stakeholders

1. Application Developers(AppDev) - Application developers build application that use a mix of IC tech and traditional tech to build apps for their customers.
2. Dependent Application Developers(DepDev) - Dependent application developers build applications that use a mix of IC tech and traditional tech to build apps and their apps depend on the behaviors of other apps in the IC ecosystem.
3. Application User(AppUser) - Application users use services and applications on the IC.
4. nISP token users(nISP User) - nISP token users have to own nISP tokens to utilize certainservices offered by nISP. They stake tokens to receive network services on the network.
5. nISP governor(Governor) - a nISP token governor makes decisions to benefit the network. As the network grows in importance they receive a larger payment for their work of governing the network.
6. App user(App User) - an app user uses a service that implements dRoute.

# Form Language

Application - An computer program that seeks to accomplish some type of work.


# Pattern Language


## Complexity Shield

The nIsp libraries should shield the AppUser most of the complexity of the dRoute system.


# Current Priorities



# User Stories

1. AA AppUser IWT sign up for a nISP account and pay once to have all my services "just work" STI don't have to manage how I pay for IC services.

2. AA AppUser IWT not have to send extra information along with my IC requests to take advantage of the nISP network STI don't have to worry about more complexity.

3. AA AppUser IWT gain ownership in the nISP network as I use more and more of it STI reduce my costs for using the network.

4. AA AppDev IWT get reimbursed for the cycles an AppUser uses on my service STI don't run out of cycles.

5. AA DepDev IWT get reimbursed for the cycles an AppDev uses from my services STI don't run out of cycles.

6. AA DepDev IWT initiate function on behalf other users and still get paid for the cycles that I use.

7. AA AppDev IWT submit certified requests to allocate cycles STI don't have the user run out of cycles.

9. AA AppDev IWT ask a user to validate their transactions STI get paid more quickly.

10. AA Service IWT have a signed token that validates tha a principal is authenticated against a particular service and has the proper delegation.

12. AA AppDev I don't want nISP calls slowing down my calls with extra calls STI have a fast services.

13. AA AppDev I want to query the nISP service for a proof of nISP on my app and then send that to my canister STI before the user makes a call so I have them properly classified.

Status: Started

14. AA AppDev I want the nISP service to help me price my services.

15. AA AppDev I want to have all my canisters orgainzed under a single app STI have an easier time managing them.

# Completed user stories

8. AA AppDev IWT to publish a menu of services for the agent to use when calculating confirmations STI get paid what I want.

Status: Completed

11. AA AppDev I want to be able to know if a user is a nISP member STI can decide if I want to let them use my service or not.

Status: Complete

# Discarded user stories


nISP serve serves up a witness that the user has a cycle balance
nISP.verifyFunds(Principal, witness)

The agent pulls down the funds verification so it can be included in calls.
Each reservation extracts the max cycles and provides a proof of reciept.  How to keep it from being replayed?

Trust but verify?

Function calls return a set of reciepts...or maybe a seperate function for reciepts? If reciepts are confirmed, the user gets nISP tokens.

Perhaps I can't confirm the principal because it is a delegation? Need to review the deligation workflow.

each service can provide a menu of services with prices.

Give the services a choice of asking for a verified reservation.

public type ServiceMenu : [{
    function : Text;
    certified: Bool;
    costStructure: {
        #flat: Nat;
        #metered: {base: Nat; perByte: Nat};
        #dynamic: Principal; //sends a workspace to the server to get a cost.
        #retroactive;//ask me later, trust me.
    }
}]

How does nISP know about the principal in the first place
App -> nisp Agetn -> getWitness
App -> Doesn't exist!
App -> Alerts user and gives them a link to the nISP canister wherethey can hook up the principal to their account.

App -> NISP is principal a nISP user and give me their witness
App <- here is the witness Contains(principal, isBlocked(canister), balance, )
App -> canister.__nispRegister(witness) msg.caller must match witness
    -> canister records proof of funds

App -> canister.serviceCall() -> intecept by agent -> if certifed then call nISP first and reserve -> send to canister -> canister is responsible for checking for the certification and only using it once
    -> record nISP reciept in local collection
App <- service value return
App -> nisp Agent, check that function call was in menu -> ask nISP to confirm reciepts. nISP will pull service.__pull reciepts

Did we just make an ingress + xcanister call to confirm one ingress call?   What does that accounting look like?

AppDev -> -X cylces intially +X cycles upon reciept
nISP -> -X cycles for querying for the reciepts. +X from User
User -> -X cycles to AppDev -X cycles to nISP. +T from nISP


We sell earned nISP if they go over quota.

voting:

-block canister
-verify canister