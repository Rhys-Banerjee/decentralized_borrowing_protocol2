import treasury "canister:treasury";
import Float "mo:base/Float";
import Text "mo:base/Text";
import Troves "Troves";
import Map "mo:base/HashMap";
import Nat "mo:base/Nat";
import D "mo:base/Debug";

//this will add troves to map and have functions for adding collateral, getting more sdr, paying back sdr, withdrawing collateral that call similar trove functions and alter overall parameters

actor product {

    //_______________________________________

    var icp_to_dollar : Float = 1.0; //null values to be rewritten using updateTreasury
    var sdr_to_dollar : Float = 1.0; //null values to be rewritten using updateTreasury
    var minCollateralRatio : Float = 1.1; //null values to be rewritten using updateTreasury

    func updateTreasury() : async (){
    icp_to_dollar := await treasury.icp_to_dollar(); //these need to be updated periodicaly (price of ICP in Dollars)
    sdr_to_dollar := await treasury.sdr_to_dollar(); //these need to be updated periodicaly (price of SDR in Dollars)
    minCollateralRatio := await treasury.getMinCollateralRatio();
    };

    //_______________________________________

    //Functionality needed to create Troves
    type Trove = Troves.Trove;
    type User = Text;
    let map = Map.HashMap<User, Trove>(0,Text.equal, Text.hash);

    public func createTrove(id: Text, icp_request: Nat, sdr_request: Nat): async Text{
       let ratio : Float = (Float.fromInt(icp_request)*icp_to_dollar)/(Float.fromInt(sdr_request)*sdr_to_dollar);
       if (ratio < minCollateralRatio){
           return "Failure, please improve your collateral ratio";
       }
       else{
           map.put(id, await Troves.Trove(id, icp_request, sdr_request, minCollateralRatio));
           return "Success, Trove for " # id # " created with " #Nat.toText(icp_request)# " ICP deposited and " # Nat.toText(sdr_request) # " SDR withdrawn.";
       };
    };

    public func increaseSDR (id: Text, sdr_request: Nat): async (Text,Bool){ //add more debt
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist",false);
            };

            case (?Trove){
                let temp = await Trove.increaseSDR(sdr_request);
                if (temp.1 == true){
                    return await treasury.mintSDR(sdr_request);
                };
                return temp; //this returns a failure in the Trove
            };
        };
        
    };
    

    public func increaseICP (id: Text, icp_request: Nat) : async (Text,Bool){ //add collateral
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist",false);
            };

            case (?Trove){
                let temp = await Trove.increaseICP(icp_request);
                if (temp.1 == true){
                    return await treasury.addICP(icp_request);
                };
                return temp; //this returns a failure in the Trove
            };
        };
    };

    public func decreaseSDR (id: Text, sdr_request: Nat) : async (Text,Bool){
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist",false);
            };

            case (?Trove){
                let temp = await Trove.decreaseSDR(sdr_request);
                if (temp.1 == true){
                    let temp2 = await treasury.burnSDR(sdr_request); //burning sdr
                    if (temp2.1 == true){
                        return temp2;
                    }
                    else{ //theoretically this should never trigger because they cannot return more than they borrowed, and the pool should always have at least what they owe
                        let ign = await Trove.increaseSDR(sdr_request); //overturn previous removal, ignore the value since it will have to execute since it's reverting to previous state which was shown to have worked
                        return temp2; //return error message
                    };
                };
                return temp; //this returns a failure
            };
        };
    };

    public func decreaseICP (id: Text, icp_request: Nat) : async (Text,Bool){
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist",false);
            };

            case (?Trove){
                let temp = await Trove.decreaseICP(icp_request);
                if (temp.1 == true){
                    let temp2 = await treasury.removeICP(icp_request); //burning sdr
                    if (temp2.1 == true){
                        return temp2;
                    }
                    else{ //theoretically this should never trigger because their ICP balance can never be greater than the total ICP balance (and if they request more than their balance the Trove triggers the error, not this)
                        let ign = await Trove.increaseICP(icp_request); //overturn previous removal
                        return temp2; //return error message
                    };
                };
                return temp; //this returns a failure
            };
        };
    };

    public func closeTrove (id: Text, sdr_request: Nat) : async (Text, Nat,Bool){
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist", 0, false);
            };

            case (?Trove){
                let temp = await Trove.closeTrove(sdr_request);
                if (temp.2 == true){
                    //neither of these should fail, otherwise we have a large problem and need to redo stuff
                    let temp2 = await treasury.burnSDR(sdr_request); //burning sdr
                    let temp3 = await Trove.decreaseICP(temp.1);
                    // eventually we need to figure out actual transfer features
                };
                let ignorE = map.remove(id);
                return temp;
            };
        };
    };

    public func getTroveICP (id: Text): async (Text,Nat,Bool){
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist",0,false);
            };

            case (?Trove){
                return ("Success", await Trove.icpAmount(),true);
            };
        };
        
    };
    public func getTroveSDR (id: Text): async (Text,Nat,Bool){
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist",0,false);
            };

            case (?Trove){
                return ("Success",await Trove.sdrAmount(),true);
            };
        };
        
    };

    public func getTroveCollateralRatio (id: Text): async (Text,Float,Bool){
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist",0,false);
            };

            case (?Trove){
                return ("Success",await Trove.collateralRatio(),true);
            };
        };
        
    };
      
};