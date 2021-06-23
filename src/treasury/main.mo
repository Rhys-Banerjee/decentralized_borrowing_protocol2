import Float "mo:base/Float";
import Text "mo:base/Text";
import Map "mo:base/HashMap";
import Nat "mo:base/Nat";
import D "mo:base/Debug";

actor treasury {
    //initialize stuff
    private let initial_SDR_supply : Int = 1000000; // in stability pool
    let minCollateralRatio : Float = 1.1; //make this information and some of the other information come from a different file

    private var sdr_supply : Int = 0; //total supply
    private var icp_supply : Int = 0; //total supply

    public query func get_SDR_Supply () : async Int {
        return sdr_supply;
    };

    public query func get_ICP_Supply () : async Int {
        return icp_supply;
    };

    public func init () {
        sdr_supply := initial_SDR_supply;
    };

    public query func icp_to_dollar () : async Float {
        return 1.0;
    };

    public query func sdr_to_dollar () : async Float {
        return 1.0;
    };

    public query func getMinCollateralRatio () : async Float {
        return minCollateralRatio;
    };

    public func mintSDR (amount : Nat) : async (Text, Bool){
        sdr_supply += amount;
        return ("Success", true);
    };

    public func burnSDR (amount : Nat) : async (Text, Bool){
        if (sdr_supply > amount){
            sdr_supply -= amount;
            return ("Success", true);
        };
        return ("Failure - Burn Amount Exceeds Supply", false);
        
    };

    public func addICP (amount: Nat) : async (Text, Bool) {
        icp_supply += amount;
        return ("Success", true);
    };

    public func removeICP (amount : Nat) : async (Text, Bool){
        if (icp_supply > amount){
            icp_supply -= amount;
            return ("Success", true);
        };
        return ("Failure - Withdrawal Amount Exceeds Supply", false);
        
    };

    
};
