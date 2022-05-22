//import RegCanister "canister:droute";
import C "mo:matchers/Canister";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";
import S "mo:matchers/Suite";
import Principal "mo:base/Principal";
import Candy "mo:candy/types";
import DrouteUtilities "../DRouteUtilities/lib";
import Nat8 "mo:base/Nat8";
import Debug "mo:base/Debug";
import Error "mo:base/Error";

actor class test_runner_droute_utilities(initArgs : {regPrincipal : Principal}) = this{
    let it = C.Tester({ batchSize = 8 });





    public shared func test() : async {#success; #fail : Text} {


          try {
            /*
            let data = [
            (0,0,Candy.nat16ToBytes(1:Nat16)),
            (0,1,Candy.nat16ToBytes(2:Nat16)),
            (1,0,Candy.nat16ToBytes(3:Nat16))];


            let dRouteEvent = DrouteUtilities.createEvent(
              "com.test.construction",
              Principal.fromActor(this),
              1,
              1,
              data);

            Debug.print("principal" # debug_show(Principal.fromActor(this)));

            //Debug.print("input " # debug_show(dRouteEvent));


            let stableDRouteEvent = DrouteUtilities.toStableEvent(dRouteEvent);

            Debug.print("result " # debug_show(stableDRouteEvent));
            let stableTextFieldIndex = 0;
            let stablePrincipalFieldIndex = 1;
            let stableUserIDFieldIndex = 2;
            let stableDRouteIDFieldIndex = 3;

            let stableTextField : Text = Candy.bytesToText(stableDRouteEvent[stableTextFieldIndex].2);
            let stableUserIDField : Nat = Conversion.bytesToNat(stableDRouteEvent[stableUserIDFieldIndex].2);
            let stableDRouteIDField : Nat = Conversion.bytesToNat(stableDRouteEvent[stableDRouteIDFieldIndex].2);


            let dataFieldIndexStart = 4;

            let suite = S.suite("test Addresed Chunk Construction", [
              S.test("1", dRouteEvent.eventType : Text, M.equals<Text>(T.text(stableTextField : Text))),
              S.test("2", Principal.toText(dRouteEvent.source), M.equals(T.text(Principal.toText(Candy.bytesToPrincipal(stableDRouteEvent[stablePrincipalFieldIndex].2))))),

              S.test("3", 4, M.equals<Nat>(T.nat(stableDRouteEvent[dataFieldIndexStart].0))),
              S.test("4", 0, M.equals(T.nat(stableDRouteEvent[dataFieldIndexStart].1))),
              S.test("5", dRouteEvent.data.get(0).get(0).toArray(), M.equals(T.array<Nat8>(T.nat8Testable, stableDRouteEvent[dataFieldIndexStart].2))),

              S.test("6", 4, M.equals(T.nat(stableDRouteEvent[dataFieldIndexStart+1].0))),
              S.test("7", 1, M.equals(T.nat(stableDRouteEvent[dataFieldIndexStart+1].1))),
              S.test("8", dRouteEvent.data.get(0).get(1).toArray(), M.equals(T.array<Nat8>(T.nat8Testable, stableDRouteEvent[dataFieldIndexStart+1].2))),

              S.test("9", 5, M.equals(T.nat(stableDRouteEvent[dataFieldIndexStart+2].0))),
              S.test("10", 0, M.equals(T.nat(stableDRouteEvent[dataFieldIndexStart+2].1))),
              S.test("11", dRouteEvent.data.get(1).get(0).toArray(), M.equals(T.array<Nat8>(T.nat8Testable, stableDRouteEvent[dataFieldIndexStart+2].2))),

              //entire array should have lenth5
              S.test("12", true, M.equals(T.bool(stableDRouteEvent.size() == 7))),

              //test userid
              //test droute id

              S.test("drouteid", dRouteEvent.dRouteID : Nat, M.equals<Nat>(T.nat(stableDRouteIDField : Nat))),
              S.test("userid", dRouteEvent.userID : Nat, M.equals<Nat>(T.nat(stableUserIDField : Nat))),
            ]);

            S.run(suite);

            */

            return #success;
          } catch(err) {
            //Debug.Print(debug_show(err));
            Debug.print("err  " # Error.message(err));
            return #fail(Error.message(err));
          }



        // await it.run()
    }
}