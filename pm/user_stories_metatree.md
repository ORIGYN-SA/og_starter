

# Stakeholders

1. Application Developers(AppDev) - Application developers build application that use a mix of IC tech and traditional tech to build apps for their customers.

2. App user(App User) - an app user uses a service that implements metatree.

3. Data Retrievier(Retriever) - a program requesting a set of data.

4. Data Writer(Writer) - a program writing data to a set.

# Form Language

Application - An computer program that seeks to accomplish some type of work.


# Pattern Language

## xxx

Supported by -

Description

# User Stories

1. AA AppDev IWT store my structured data in an infinately scaleable object STI don't have to think about storage

2. AA Reader IWT quickly get to the dataset with a minimum of xcanister calls STI can server get my data quickly.

3. AA Writer IWT not have to care about where the data is written STI can do other work.

4. AA AppDev IWT have the storage canisters manage themselves STI don't have to do that work.

5. AA Reader IWT know I can always go back to the same canister to get the data I think is there STI don't have to requery data

6. AA AppDev IWT have my data preserved across upgrades STI don't lose my data.

7. AA AppDev IWT be able to archive/delete my data STI don't have to keep paying for its storage;

8. AA AppDEv IWT know that the data returned is less than the 2MB intercanister limit STI can always get a page of data.

9. AA AppDev IWT specify if I want the metatree to use the global service or a local service STI reduce my complexity

10. AA AppDev IWT replace a value in the metaTree if it is a singleton value STI can use it as a datastore

Status: Started

11. AA AppDev IWT have my index recalculated if I replace and item STI don't pull wrong data.

12. AA AppDev IWT have my index point to the raw data STI don't have data duplication.

13. AA AppDev IWT have my primary values indexed in a merkleTree so that I can keep track of certified values in my tree;

14. AA AppDev IWT not have to keep track of my marker if I'm using unique values STI don't have more data to keep track of.

Status Started





# Interface design

metatree.read("com.test.log");
metatree.readPage("com.test.log", nextID, nextMarker)
metatree.readFilter("com.test.log", ?minID, ?maxID)
metatree.readFilterPage("com.test.log", ?minID, ?maxID, lastID, lastMarker)

{
  #data: [AddressedChunkArray];
  #lastID: ?Nat;
  #lastMarker: ?Nat;
}

metatree.write("com.test.log", primaryID, AddressedChunkArray);
metatree.writeAndIndex("com.test.log", primaryID,AddressedChunkArray, index : [{ namespace: Text; dataZone: Nat; dataChunk: Nat; type: {#Nat;Nat32; etc}}}])
metatree.manageNamespace({
  #addSimpleIndex: [{
    namespace: Text;
    dataZone: Nat;
    dataChunk: Nat;
    type : {
      #Nat;
      #Nat32;
      #Int;
      #Nat8;
      #Text;
      #dynamic: Principal //will query the principal on __metatreeCalcIndexNamespace;
    }
  }]
  #reserve: {
    namespace : Text
  };
  #addController {
    namespace : Text;
    controller: Principal;
  };
  #addWriter {

  }
});


Index: [
  (min, max, Principal),
  (min, max, Principal)
]