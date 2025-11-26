/**
 * Сессии
 */

namespace java   dev.vality.fistful.withdrawal_session
namespace erlang fistful.wthd.session

include "base.thrift"
include "fistful.thrift"
include "eventsink.thrift"
include "repairing.thrift"
include "destination.thrift"
include "msgpack.thrift"
include "context.thrift"
include "withdrawal.thrift"

typedef fistful.WithdrawalID WithdrawalID
typedef fistful.PartyID PartyID
typedef base.ID SessionID
typedef msgpack.Value AdapterState
typedef base.Resource Resource
typedef base.ID IdentityToken
typedef base.ID ChallengeID
typedef base.EventRange EventRange

/// Domain

/**
 * Структура, которую вернул нам адаптер в damsel/withdrawals_provider_adapter.
 */
struct Quote {
    1: required base.Cash cash_from
    2: required base.Cash cash_to
    3: required base.Timestamp created_at
    4: required base.Timestamp expires_on
    5: optional msgpack.Value quote_data
}

struct SessionState {
    1: required SessionID id
    2: required Withdrawal withdrawal
    3: required Route route
    4: required SessionStatus status

    5: optional context.ContextSet context
}

struct Session {
    1: required SessionID id
    2: required Withdrawal withdrawal
    3: required Route route
    4: required SessionStatus status
}

union SessionStatus {
    1: SessionActive    active
    2: SessionFinished  finished
}

struct SessionActive {}
struct SessionFinished {
    1: SessionFinishedStatus status
}

union SessionFinishedStatus {
    1: SessionFinishedSuccess success
    2: SessionFinishedFailed  failed
}

struct SessionFinishedSuccess {}
struct SessionFinishedFailed {
    1: optional base.Failure failure
}

struct Withdrawal {
    1: required WithdrawalID id
    2: required Resource destination_resource
    3: required base.Cash cash
    8: optional PartyID sender
    9: optional PartyID receiver
    6: optional SessionID session_id
    7: optional Quote quote
    10: optional destination.AuthData auth_data
    11: optional base.ContactInfo contact_info
}

struct Route {
    1: required fistful.ProviderID provider_id
    2: optional fistful.TerminalID terminal_id
}

struct Callback {
    1: required base.Tag tag
}

/// Session events

struct Event {
    1: required eventsink.SequenceID sequence
    2: required base.Timestamp occured_at
    3: required list<Change> changes
}

struct TimestampedChange {
    1: required base.Timestamp       occured_at
    2: required Change               change
}

union Change {
    1: Session created
    2: AdapterState next_state
    3: SessionResult finished
    4: CallbackChange callback
    5: TransactionBoundChange transaction_bound
}

union SessionResult {
    1: SessionResultSuccess  success
    2: SessionResultFailed   failed
}

struct SessionResultSuccess {
    // deprecated
    1: optional base.TransactionInfo trx_info
}

struct SessionResultFailed {
    1: required base.Failure failure
}

struct CallbackChange {
    1: required base.Tag tag
    2: required CallbackChangePayload payload
}

struct TransactionBoundChange {
    1: required base.TransactionInfo trx_info
}

union CallbackChangePayload {
    1: CallbackCreatedChange  created
    2: CallbackStatusChange   status_changed
    3: CallbackResultChange   finished
}

struct CallbackCreatedChange {
    1: required Callback callback
}

struct CallbackStatusChange {
    1: required CallbackStatus status
}

union CallbackStatus {
    1: CallbackStatusPending pending
    2: CallbackStatusSucceeded succeeded
}

struct CallbackStatusPending {}
struct CallbackStatusSucceeded {}

struct CallbackResultChange {
    1: required binary payload
}

///

service Management {
    SessionState Get (
        1: SessionID id
        2: EventRange range
    )
        throws (1: fistful.WithdrawalSessionNotFound ex1)

    context.ContextSet GetContext(
        1: SessionID id
    )
        throws (
            1: fistful.WithdrawalSessionNotFound ex1
        )

    list<Event> GetEvents(
        1: SessionID id
        2: EventRange range
    )
        throws (1: fistful.WithdrawalSessionNotFound ex1)
}

/// Repair

union RepairScenario {
    1: AddEventsRepair add_events
    2: SetResultRepair set_session_result
}

struct AddEventsRepair {
    1: required list<Event>             events
    2: optional repairing.ComplexAction  action
}

struct SetResultRepair {
    1: required SessionResult           result
}

service Repairer {
    void Repair(1: SessionID id, 2: RepairScenario scenario)
        throws (
            1: fistful.WithdrawalSessionNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
