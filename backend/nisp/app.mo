///////////////////////////////
/*
©2021 RIVVIR Tech LLC
All Rights Reserved.
This code is released for code verification purposes. All rights are retained by RIVVIR Tech LLC and no re-distribution or alteration rights are granted at this time.
*/
///////////////////////////////

import Text "mo:base/Text";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Int "mo:base/Int";
import Prelude "mo:base/Prelude";
import Blob "mo:base/Blob";

import Buffer "mo:base/Buffer";

import Array "mo:base/Array";
import Debug "mo:base/Debug";

import HashMap "mo:base/HashMap";
import Candy "mo:candy/types";
import SHA256 "../dRouteUtilities/SHA256";
import MerkleTree "../dRouteUtilities/MerkleTree";
import CertifiedData "mo:base/CertifiedData";
//import Result "mo:base/Result";

import PipelinifyTypes "mo:pipelinify/types";

module {

    public type NIspError = {
        text: Text;
        code: Nat;
    };

    public type NIspAppConfig = {
        getMenu : ?(() -> async NIspMenu);
        registeredFromNIsp : ?(() -> async Bool);
    };

    public type NIspMenuItem = {
        function: Text;
        certified: Bool;
        costStructure: {
             #flat: Nat;
            #metered: {
                base: Nat;
                perByte: Nat};
            #dynamic: Principal; //sends a workspace to the server to get a cost.
            #retroactive;//ask me later, trust me.
        };
    };

    public type NIspMenu = [NIspMenuItem];




    public class NIspApp(__config: NIspAppConfig){

        let __getMenu : () -> async NIspMenu = switch (__config.getMenu){
            case(null){
                func _getMenu() : async NIspMenu{
                    //just returns nothing
                    return [];
                }
            };
            case(?_getMenu){
                _getMenu;
            }
        };

        let __registeredFromNIsp : () -> async Bool = switch (__config.registeredFromNIsp){
            case(null){
                func __registeredFromNIsp() : async Bool{
                    //just returns nothing
                    return false;
                }
            };
            case(?__registeredFromNIsp){
                __registeredFromNIsp;
            }
        };

        public func getMenu() : async Result.Result<NIspMenu, NIspError>{
            let result = await __getMenu();

            return #ok(result);
        };


        public func registeredFromNIsp(principal: Principal) : async Result.Result<Bool, NIspError>{
            //this should be a droute application.
            //todo make sure that the calling principal is part of nisp

            let result = await __registeredFromNIsp();

            return #ok(true);
        };
    };



};