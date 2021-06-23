import product "canister:product";
import Float "mo:base/Float";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import D "mo:base/Debug";

actor user{
    var id : Text = "placeholder";
    var icp : Nat = 0; //this is in wallet not trove
    var sdr : Nat = 0; 

    public func create_Account (name: Text) : async () { //will eventually include other information like wallet
        id := name;
        icp := 10000 //starting icp given to play with Trove
    };
    public func test_run (name : Text) : async Text {
        return name # " has opened a new account!";
    };

    public func get_Free_ICP () : async Text {
        return Nat.toText(icp);
    };

    public func get_user_ID () : async Text {
        return id;
    };

    public func create_Trove () : async Text { //for now let's just create initially empty troves for the sake of a nicer UI
        return await product.createTrove(id, 0, 0);
    };

    public func close_Trove (sdr_request : Nat) : async Text {
        let temp = await product.closeTrove(id,sdr_request);
        icp += temp.1;
        return temp.0;
    };

    public func sdr_outstanding () : async Text {
        let temp = await product.getTroveSDR(id);
        if (temp.2){
            return Nat.toText(temp.1);
        };
        return temp.0;
    };

    public func icp_locked () : async Text {
        let temp = await product.getTroveICP(id);
        if (temp.2){
            return Nat.toText(temp.1);
        };
        return temp.0;
    };

    public func current_collateral_ratio () : async Text {
        let temp = await product.getTroveCollateralRatio(id);
        if (temp.2){
            return Float.toText(temp.1);
        };
        return temp.0;
    };

    public func withdraw_SDR(sdr_request : Nat) : async Text {
        let temp = await product.increaseSDR(id, sdr_request); //increase SDR debt
        if (temp.1){
            sdr+=sdr_request;
        };
        return temp.0; 
    };

    public func deposit_SDR(sdr_request : Nat) : async Text {
        if (sdr_request > sdr){
            return ("Failure - Deposit is larger than available balance");
        };
        let temp = await product.decreaseSDR(id, sdr_request);
        if (temp.1){
            sdr-=sdr_request;
        };
        return temp.0;
    };

    public func withdraw_ICP(icp_request : Nat) : async Text {
        let temp = await product.decreaseICP(id, icp_request);
        if (temp.1){
            icp+=icp_request;
        };
        return temp.0;
    };

    public func deposit_ICP(icp_request : Nat) : async Text {
        let temp = await product.increaseICP(id, icp_request);
        if (temp.1){
            icp-=icp_request;
        };
        return temp.0;
    };
 

};
