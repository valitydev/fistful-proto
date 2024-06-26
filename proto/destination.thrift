/**
 * Место ввода денег в систему
 */

namespace java   dev.vality.fistful.destination
namespace erlang fistful.destination

include "base.thrift"
include "fistful.thrift"
include "account.thrift"
include "identity.thrift"
include "eventsink.thrift"
include "context.thrift"
include "repairing.thrift"

/// Domain

typedef fistful.DestinationID     DestinationID
typedef account.Account           Account
typedef identity.IdentityID       IdentityID
typedef base.ExternalID           ExternalID
typedef base.CurrencySymbolicCode CurrencySymbolicCode
typedef base.Timestamp            Timestamp
typedef fistful.Blocking          Blocking
typedef base.Resource             Resource
typedef base.EventID              EventID
typedef base.EventRange           EventRange


struct Destination {
    1: required string name
    2: required Resource resource
    3: optional ExternalID external_id
    7: optional Timestamp created_at
    9: optional context.ContextSet metadata
    10: optional AuthData auth_data
}

struct DestinationState {
    1: required string name
    2: required Resource resource
    3: optional ExternalID external_id
    4: optional Account account
    5: optional Status status

    6: optional DestinationID id
    7: optional Timestamp created_at
    8: optional Blocking blocking
    9: optional context.ContextSet metadata

    /** Контекст сущности заданный при её старте */
    10: optional context.ContextSet context

    11: optional AuthData auth_data
}

struct DestinationParams {
    1: required DestinationID         id
    2: required IdentityID            identity
    3: required string                name
    4: required CurrencySymbolicCode  currency
    5: required Resource              resource
    6: optional ExternalID            external_id
    7: optional context.ContextSet    metadata
    8: optional AuthData              auth_data
}

union Status {
    1: Authorized       authorized
    2: Unauthorized     unauthorized
}

struct Authorized {}
struct Unauthorized {}

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
            2: fistful.IdentityNotFound ex2
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
    3: StatusChange     status
}

union AccountChange {
    1: Account          created
}

union StatusChange {
    1: Status          changed
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
