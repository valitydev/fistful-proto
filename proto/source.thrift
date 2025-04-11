/**
 * Место ввода денег в систему
 */

namespace java   dev.vality.fistful.source
namespace erlang fistful.source

include "base.thrift"
include "fistful.thrift"
include "account.thrift"
include "eventsink.thrift"
include "repairing.thrift"
include "context.thrift"

/// Domain

typedef fistful.SourceID SourceID
typedef fistful.PartyID PartyID
typedef base.Realm Realm
typedef account.Account Account
typedef base.ExternalID ExternalID
typedef base.Timestamp Timestamp
typedef fistful.Blocking Blocking
typedef fistful.SourceName SourceName
typedef base.CurrencyRef CurrencyRef
typedef base.EventID EventID
typedef base.EventRange EventRange

struct Source {
    1: required Resource resource
    2: required SourceID id
    3: required Realm realm
    4: required PartyID party_id
    5: required string name
    6: optional ExternalID external_id
    7: optional Timestamp created_at
    8: optional context.ContextSet metadata
}

struct SourceState {
    1: required Resource resource
    2: required SourceID id
    3: required Realm realm
    4: required PartyID party_id
    5: required string name
    6: optional ExternalID external_id
    7: optional Timestamp created_at
    8: optional context.ContextSet metadata

    9: optional Account account
    10: optional Blocking blocking

    /** Контекст сущности заданный при её старте */
    11: optional context.ContextSet context
}

struct SourceParams {
    1: required SourceID id
    2: required Realm realm
    3: required PartyID party_id
    4: required SourceName name
    5: required CurrencyRef currency
    6: required Resource resource
    7: optional ExternalID external_id
    8: optional context.ContextSet metadata
}

union Resource {
    1: Internal         internal
}

struct Internal {
    1: optional string  details
}

service Management {

    SourceState Create (
        1: SourceParams params
        2: context.ContextSet context
    )
        throws (
            2: fistful.PartyNotFound ex2
            3: fistful.CurrencyNotFound ex3
            4: fistful.PartyInaccessible ex4
        )

    SourceState Get (
        1: SourceID id
        2: EventRange range
    )
        throws (
            1: fistful.SourceNotFound ex1
        )

    context.ContextSet GetContext(
        1: SourceID id
    )
        throws (
            1: fistful.SourceNotFound ex1
        )

    list<Event> GetEvents(
        1: SourceID id
        2: EventRange range
    )
        throws (
            1: fistful.SourceNotFound ex1
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
    1: Source           created
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
    void Repair(1: SourceID id, 2: RepairScenario scenario)
        throws (
            1: fistful.SourceNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
