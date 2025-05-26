/**
 * Место ввода денег в систему
 */

namespace java   dev.vality.fistful.destination
namespace erlang fistful.destination

include "base.thrift"
include "fistful.thrift"
include "account.thrift"
include "eventsink.thrift"
include "context.thrift"
include "repairing.thrift"

/// Domain

typedef fistful.DestinationID     DestinationID
typedef account.Account           Account
typedef fistful.PartyID           PartyID
typedef base.Realm                Realm
typedef base.ExternalID           ExternalID
typedef base.CurrencySymbolicCode CurrencySymbolicCode
typedef base.Timestamp            Timestamp
typedef fistful.Blocking          Blocking
typedef base.Resource             Resource
typedef base.EventID              EventID
typedef base.EventRange           EventRange


struct Destination {
    1: required DestinationID id
    2: required Realm realm
    3: required PartyID party_id
    4: required Resource resource
    5: required string name
    6: required Timestamp created_at
    7: optional ExternalID external_id
    8: optional context.ContextSet metadata
    9: optional AuthData auth_data
}

struct DestinationState {
    1: required DestinationID id
    2: required Realm realm
    3: required PartyID party_id
    4: required Resource resource
    5: required string name
    6: required Timestamp created_at
    7: optional ExternalID external_id
    8: optional context.ContextSet metadata
    9: optional AuthData auth_data

    10: optional Account account
    11: optional Blocking blocking

    /** Контекст сущности заданный при её старте */
    12: optional context.ContextSet context

}

struct DestinationParams {
    1: required DestinationID         id
    2: required Realm                 realm
    3: required PartyID               party_id
    4: required string                name
    5: required CurrencySymbolicCode  currency
    6: required Resource              resource
    7: optional ExternalID            external_id
    8: optional context.ContextSet    metadata
    9: optional AuthData              auth_data
}

union AuthData {
    1: SenderReceiverAuthData sender_receiver
}

struct SenderReceiverAuthData {
    1: required base.Token sender
    2: required base.Token receiver
}

service Management {

    DestinationState Create(
        1: DestinationParams params
        2: context.ContextSet context
    )
        throws(
            2: fistful.PartyNotFound ex2
            3: fistful.CurrencyNotFound ex3
            4: fistful.PartyInaccessible ex4
            5: fistful.ForbiddenWithdrawalMethod ex5
        )

    DestinationState Get(
        1: DestinationID id
        2: EventRange range
    )
        throws(
            1: fistful.DestinationNotFound ex1
        )

    context.ContextSet GetContext(
        1: DestinationID id
    )
        throws (
            1: fistful.DestinationNotFound ex1
        )

    list<Event> GetEvents(
        1: DestinationID id
        2: EventRange range
    )
        throws (
            1: fistful.DestinationNotFound ex1
        )
}

/// Source events
struct Event {
    1: required EventID              event_id
    2: required base.Timestamp       occured_at
    3: required Change               change
}

struct TimestampedChange {
    1: required base.Timestamp       occured_at
    2: required Change               change
}

union Change {
    1: Destination      created
    2: AccountChange    account
}

union AccountChange {
    1: Account          created
}

/// Repair

union RepairScenario {
    1: AddEventsRepair add_events
}

struct AddEventsRepair {
    1: required list<Event>             events
    2: optional repairing.ComplexAction  action
}

service Repairer {
    void Repair(1: DestinationID id, 2: RepairScenario scenario)
        throws (
            1: fistful.DestinationNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
