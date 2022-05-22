
import C "mo:matchers/Canister";
//import DRouteTypes "../dRouteTypes";
//import DRouteUtilities "../dRouteUtilities";
import Debug "mo:base/Debug";
import M "mo:matchers/Matchers";
import Principal "mo:base/Principal";
//import PublisherTestCanisterDef "test_publisher";
//import RegCanisterDef "../droute/main";
import T "mo:matchers/Testable";
//import UtilityTestCanisterDef "test_runner_droute_utilities";
import DRoute2TestCanisterDef "test_droute_2";

actor {
    let it = C.Tester({ batchSize = 8 });

    
    public shared func test() : async Text {

          //this is annoying, but it is gets around the "not defined bug";
      //let RegCanister : RegCanisterDef.DRoute = await RegCanisterDef.DRoute();
      //let UtilityTestCanister : UtilityTestCanisterDef.test_runner_droute_utilities = await UtilityTestCanisterDef.test_runner_droute_utilities({regPrincipal= Principal.fromActor(RegCanister)});
      //let PublisherTestCanister : PublisherTestCanisterDef.test_publisher = await PublisherTestCanisterDef.test_publisher({regPrincipal= Principal.fromActor(RegCanister)});
      let Droute2TestCanister : DRoute2TestCanisterDef.test_droute_2 = await DRoute2TestCanisterDef.test_droute_2();
    
      it.should("run droute2 tests", func () : async C.TestResult = async {
          let result = await Droute2TestCanister.test();
          Debug.print("result");
          Debug.print(debug_show(result));
          //M.attempt(greeting, M.equals(T.text("Hello, Christoph!")))
          return result;
        });

        /* it.should("run utility tests", func () : async C.TestResult = async {
          let result = await UtilityTestCanister.test();
          Debug.print("result");
          Debug.print(debug_show(result));
          //M.attempt(greeting, M.equals(T.text("Hello, Christoph!")))
          return result;
        });


        it.should("run publisher tests", func () : async C.TestResult = async {
          let result = await PublisherTestCanister.test();
          Debug.print("result");
          Debug.print(debug_show(result));
          //M.attempt(greeting, M.equals(T.text("Hello, Christoph!")))
          return result;
        });
 */
       




        await it.runAll()
        // await it.run()
    }
}