/**
 * Кошельки
 */

namespace java   dev.vality.fistful.wallet
namespace erlang wlt

include "base.thrift"
include "fistful.thrift"
include "account.thrift"
include "identity.thrift"
include "eventsink.thrift"
include "repairing.thrift"
include "context.thrift"
include "msgpack.thrift"

/// Domain

typedef fistful.WalletID WalletID
typedef account.Account Account
typedef account.AccountBalance AccountBalance
typedef base.ExternalID ExternalID
typedef base.ID ContractID
typedef base.Timestamp Timestamp
typedef base.CurrencySymbolicCode CurrencySymbolicCode
typedef account.AccountParams AccountParams
typedef fistful.Blocking Blocking
typedef base.EventRange EventRange

struct WalletParams {
    1: WalletID id
    2: required string name
    3: required AccountParams account_params
    4: optional context.ContextSet metadata
    5: optional ExternalID external_id
}

struct Wallet {
    1: optional string name
    2: optional ExternalID external_id
    4: optional Blocking blocking
    6: optional Timestamp created_at
    7: optional context.ContextSet metadata
}

struct WalletState {
    1: optional string name
    2: optional ExternalID external_id
    3: optional WalletID id
    4: optional Blocking blocking
    5: optional Account account
    6: optional Timestamp created_at
    7: optional context.ContextSet metadata

    /** Контекст сущности заданный при её старте */
    8: optional context.ContextSet context
}

/// Wallet events

struct Event {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

struct TimestampedChange {
    1: required base.Timestamp occured_at
    2: required Change change
}

union Change {
    1: Wallet           created
    2: AccountChange    account
}

union AccountChange {
    1: Account          created
}

///

service Management {
    WalletState Create (
        1: WalletParams params
        2: context.ContextSet context
    )
        throws (
            1: fistful.IdentityNotFound     ex1
            2: fistful.CurrencyNotFound     ex2
            3: fistful.PartyInaccessible    ex3
        )

    WalletState Get (
        1: WalletID id
        2: EventRange range
    )
        throws (1: fistful.WalletNotFound ex1)

    context.ContextSet GetContext(
        1: WalletID id
    )
        throws (
            1: fistful.WalletNotFound ex1
        )

    AccountBalance GetAccountBalance (
        1: WalletID id
    )
        throws (1: fistful.WalletNotFound ex1)
}

/// Event sink

struct SinkEvent {
    1: required eventsink.EventID    id
    2: required base.Timestamp       created_at
    3: required WalletID             source
    4: required Event                payload
}

service EventSink {

    list<SinkEvent> GetEvents (1: eventsink.EventRange range)
        throws ()

    eventsink.EventID GetLastEventID ()
        throws (1: eventsink.NoLastEvent ex1)

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
    void Repair(1: WalletID id, 2: RepairScenario scenario)
        throws (
            1: fistful.WalletNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
