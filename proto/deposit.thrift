/**
 * Вводы
 */

namespace java   dev.vality.fistful.deposit
namespace erlang fistful.deposit

include "base.thrift"
include "fistful.thrift"
include "eventsink.thrift"
include "transfer.thrift"
include "deposit_status.thrift"
include "limit_check.thrift"
include "repairing.thrift"
include "context.thrift"
include "cashflow.thrift"
include "msgpack.thrift"

typedef base.EventID            EventID
typedef fistful.DepositID       DepositID
typedef fistful.WalletID        WalletID
typedef fistful.SourceID        SourceID
typedef base.ExternalID         ExternalID
typedef deposit_status.Status   Status
typedef base.EventRange         EventRange
typedef fistful.PartyID         PartyID

struct Deposit {
    1: required DepositID id
    2: required WalletID wallet_id
    3: required SourceID source_id
    4: required PartyID party_id
    5: required base.Cash body
    6: optional ExternalID external_id
    7: required base.Timestamp created_at
    8: required base.DataRevision domain_revision
    9: optional context.ContextSet metadata
    10: optional string description
}

struct DepositState {
    1: required DepositID id
    2: required WalletID wallet_id
    3: required SourceID source_id
    4: required PartyID party_id
    5: required base.Cash body
    6: optional ExternalID external_id
    7: required base.Timestamp created_at
    8: required base.DataRevision domain_revision
    9: optional context.ContextSet metadata
    10: optional string description
    11: optional Status status

    /** Контекст операции заданный при её старте */
    12: required context.ContextSet context
}

struct DepositParams {
    1: required DepositID id
    2: required WalletID wallet_id
    3: required SourceID source_id
    4: required PartyID party_id
    5: required base.Cash body
    6: optional ExternalID external_id
    7: optional context.ContextSet metadata
    8: optional string description
}

struct Event {
    1: required EventID        event_id
    2: required base.Timestamp occured_at
    3: required Change         change
}

struct TimestampedChange {
    1: required base.Timestamp occured_at
    2: required Change         change
}

union Change {
    1: CreatedChange    created
    2: StatusChange     status_changed
    3: TransferChange   transfer
    4: LimitCheckChange limit_check
}

struct CreatedChange {
    1: required Deposit deposit
}

struct StatusChange {
    1: required Status status
}

struct TransferChange {
    1: required transfer.Change payload
}

struct LimitCheckChange {
    1: required limit_check.Details details
}

exception InconsistentDepositCurrency {
    1: required base.CurrencyRef deposit_currency
    2: required base.CurrencyRef source_currency
    3: required base.CurrencyRef wallet_currency
}

service Management {

    DepositState Create(
        1: DepositParams params
        2: context.ContextSet context
    )
        throws (
            1: fistful.WalletNotFound ex1
            2: fistful.SourceNotFound ex2
            3: fistful.SourceUnauthorized ex3
            4: fistful.InvalidOperationAmount ex4
            5: fistful.ForbiddenOperationCurrency ex5
            6: InconsistentDepositCurrency ex6
            7: fistful.PartyNotFound ex7
        )

    DepositState Get(
        1: DepositID id
        2: EventRange range
    )
        throws (
            1: fistful.DepositNotFound ex1
        )

    context.ContextSet GetContext(
        1: DepositID id
    )
        throws (
            1: fistful.DepositNotFound ex1
        )

    list<Event> GetEvents(
        1: DepositID id
        2: EventRange range
    )
        throws (
            1: fistful.DepositNotFound ex1
        )
}

/// Repair

union RepairScenario {
    1: AddEventsRepair add_events
}

struct AddEventsRepair {
    1: required list<Change>            events
    2: optional repairing.ComplexAction  action
}

service Repairer {
    void Repair(1: DepositID id, 2: RepairScenario scenario)
        throws (
            1: fistful.DepositNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
