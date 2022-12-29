import Candy "mo:candy/types";
import Confirm "./modules/confirm";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Errors "../../common/errors";
import Info "./modules/info";
import Migrations "../../migrations";
import MigrationTypes "../../migrations/types";
import Publish "./modules/publish";
import Request "./modules/request";
import { defaultArgs } "../../migrations";

let Types = MigrationTypes.Types;

shared actor class Broadcast(
  mainId: ?Principal,
  publishersIndexId: ?Principal,
  subscribersIndexId: ?Principal,
  subscribersStoreIds: [Principal],
) {
  stable var migrationState: MigrationTypes.StateList = #v0_0_0(#data(#Broadcast));

  let args = { defaultArgs with mainId; publishersIndexId; subscribersIndexId; subscribersStoreIds }:MigrationTypes.Args;

  migrationState := Migrations.migrate(migrationState, #v0_1_0(#id), args);

  let state = switch (migrationState) { case (#v0_1_0(#data(#Broadcast(state)))) state; case (_) Debug.trap(Errors.CURRENT_MIGRATION_STATE) };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public shared (context) func confirmEventProcessed(params: Confirm.ConfirmEventParams): async Confirm.ConfirmEventResponse {
    return Confirm.confirmEventProcessed(context.caller, state, params);
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public shared (context) func getEventInfo(params: Info.EventInfoParams): async Info.EventInfoResponse {
    return Info.getEventInfo(context.caller, state, params);
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public query (context) func publish(params: Publish.PublishParams): async Publish.PublishResponse {
    return Publish.publish(context.caller, state, params);
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public query (context) func requestEvents(params: Request.RequestEventsParams): async Request.RequestEventsResponse {
    return Request.requestEvents(context.caller, state, params);
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public query func addCycles(): async Nat {
    return Cycles.accept(Cycles.available());
  };
};
