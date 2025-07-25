/**
 * Выводы
 */

namespace java   dev.vality.fistful.withdrawal
namespace erlang fistful.wthd

include "base.thrift"
include "fistful.thrift"
include "eventsink.thrift"
include "repairing.thrift"
include "context.thrift"
include "transfer.thrift"
include "cashflow.thrift"
include "withdrawal_adjustment.thrift"
include "withdrawal_status.thrift"
include "limit_check.thrift"
include "msgpack.thrift"

typedef base.ID                  SessionID
typedef base.EventID             EventID
typedef fistful.WithdrawalID     WithdrawalID
typedef fistful.AdjustmentID     AdjustmentID
typedef fistful.WalletID         WalletID
typedef fistful.DestinationID    DestinationID
typedef base.ExternalID          ExternalID
typedef withdrawal_status.Status Status
typedef base.EventRange          EventRange
typedef base.Resource            Resource
typedef base.Timestamp           Timestamp
typedef base.Token               PersonalDataToken
typedef base.ID                  ValidationID
typedef fistful.PartyID          PartyID

/// Domain

struct Quote {
    1: required base.Cash cash_from
    2: required base.Cash cash_to
    3: required base.Timestamp created_at
    4: required base.Timestamp expires_on
    5: required msgpack.Value quote_data

    6: required Route route
    7: optional base.ResourceDescriptor resource
    8: required base.Timestamp operation_timestamp
    9: optional base.DataRevision domain_revision
}

struct QuoteParams {
    1: required WalletID wallet_id
    2: required PartyID party_id
    3: required base.CurrencyRef currency_from
    4: required base.CurrencyRef currency_to
    5: required base.Cash body
    6: optional DestinationID destination_id
    7: optional ExternalID external_id
}

struct QuoteState {
    1: required base.Cash cash_from
    2: required base.Cash cash_to
    3: required base.Timestamp created_at
    4: required base.Timestamp expires_on
    6: optional msgpack.Value quote_data

    7: optional Route route
    8: optional base.ResourceDescriptor resource

    // deprecated
    5: optional context.ContextSet quote_data_legacy
}

struct WithdrawalParams {
    1: required WithdrawalID id
    2: required PartyID party_id
    3: required WalletID wallet_id
    4: required DestinationID destination_id
    5: required base.Cash body
    6: optional ExternalID external_id
    7: optional Quote quote
    8: optional context.ContextSet metadata
}

struct Withdrawal {
    1: required WithdrawalID id
    2: required base.Cash body
    3: required WalletID wallet_id
    4: required DestinationID destination_id
    5: required PartyID party_id
    6: optional QuoteState quote
    7: required base.Timestamp created_at
    8: required base.DataRevision domain_revision
    9: optional Route route
    10: optional context.ContextSet metadata
    11: optional ExternalID external_id
}

struct WithdrawalState {
    1: required WithdrawalID id
    2: required base.Cash body
    3: required WalletID wallet_id
    4: required DestinationID destination_id
    5: required PartyID party_id
    7: required base.Timestamp created_at
    8: required base.DataRevision domain_revision
    9: optional Route route
    10: optional context.ContextSet metadata
    11: optional ExternalID external_id

    12: optional Status status
    13: optional QuoteState quote

    /** Контекст операции заданный при её старте */
    14: required context.ContextSet context

    /**
      * Набор проводок, который отражает предполагаемое движение денег между счетами.
      * Может меняться в процессе прохождения операции или после применения корректировок.
      */
    15: required cashflow.FinalCashFlow effective_final_cash_flow

    /** Текущий действующий маршрут */
    16: optional Route effective_route

    /** Перечень сессий взаимодействия с провайдером */
    17: required list<SessionState> sessions

    /** Перечень корректировок */
    18: required list<withdrawal_adjustment.AdjustmentState> adjustments

    19: optional WithdrawalValidation withdrawal_validation
}

struct SessionState {
    1: required SessionID id
    2: optional SessionResult result
}

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
    1: CreatedChange       created
    2: StatusChange        status_changed
    6: ResourceChange      resource
    5: RouteChange         route
    3: TransferChange      transfer
    8: LimitCheckChange    limit_check
    4: SessionChange       session
    7: AdjustmentChange    adjustment
    9: ValidationChange    validation
}

struct CreatedChange {
    1: required Withdrawal withdrawal
}

struct StatusChange {
    1: required Status status
}

struct TransferChange {
    1: required transfer.Change payload
}

struct AdjustmentChange {
    1: required AdjustmentID id
    2: required withdrawal_adjustment.Change payload
}

struct LimitCheckChange {
    1: required limit_check.Details details
}

struct SessionChange {
    1: required SessionID id
    2: required SessionChangePayload payload
}

union SessionChangePayload {
    1: SessionStarted   started
    2: SessionFinished  finished
}

struct WithdrawalValidation {
    1: optional list<ValidationResult> sender
    2: optional list<ValidationResult> receiver
}

union ValidationResult {
    1: PersonalDataValidationResult personal
}

union ValidationChange {
    1: ValidationResult sender
    2: ValidationResult receiver
}

struct PersonalDataValidationResult {
    1: required ValidationID validation_id
    2: required PersonalDataToken token
    3: required ValidationStatus validation_status
}

enum ValidationStatus {
    valid
    invalid
}

struct SessionStarted {}

struct SessionFinished {
    1: required SessionResult result
}

union SessionResult {
    1: SessionSucceeded succeeded
    2: SessionFailed    failed
}

struct SessionSucceeded {
    // deprecated
    1: optional base.TransactionInfo trx_info
}

struct SessionFailed {
    1: required base.Failure failure
}

struct RouteChange {
    1: required Route route
}

struct Route {
    3: required fistful.ProviderID provider_id
    4: optional fistful.TerminalID terminal_id

    // deprecated
    1: optional base.ID provider_id_legacy
    2: optional base.ID terminal_id_legacy
}

union ResourceChange {
    1: ResourceGot got
}

struct ResourceGot {
    1: required Resource resource
}

exception InconsistentWithdrawalCurrency {
    1: required base.CurrencyRef withdrawal_currency
    2: required base.CurrencyRef destination_currency
    3: required base.CurrencyRef wallet_currency
}

exception NoDestinationResourceInfo {}

exception InvalidWithdrawalStatus {
    1: required Status withdrawal_status
}

exception ForbiddenStatusChange {
    1: required Status target_status
}

exception AlreadyHasStatus {
    1: required Status withdrawal_status
}

exception AnotherAdjustmentInProgress {
    1: required AdjustmentID another_adjustment_id
}

exception AlreadyHasDataRevision {
    1: required base.DataRevision domain_revision
}

service Management {

    Quote GetQuote(
        1: QuoteParams params
    )
        throws (
            1: fistful.WalletNotFound ex1
            2: fistful.DestinationNotFound ex2
            4: fistful.ForbiddenOperationCurrency ex4
            5: fistful.ForbiddenOperationAmount ex5
            6: fistful.InvalidOperationAmount ex6
            7: InconsistentWithdrawalCurrency ex7
            8: fistful.RealmsMismatch ex8
            9: fistful.ForbiddenWithdrawalMethod ex9
            10: fistful.PartyNotFound ex10
        )

    WithdrawalState Create(
        1: WithdrawalParams params
        2: context.ContextSet context
    )
        throws (
            2: fistful.WalletNotFound ex2
            3: fistful.DestinationNotFound ex3
            5: fistful.ForbiddenOperationCurrency ex5
            6: fistful.ForbiddenOperationAmount ex6
            7: fistful.InvalidOperationAmount ex7
            8: InconsistentWithdrawalCurrency ex8
            9: NoDestinationResourceInfo ex9
            10: fistful.RealmsMismatch ex10
            11: fistful.WalletInaccessible ex11
            12: fistful.ForbiddenWithdrawalMethod ex12
            13: fistful.PartyNotFound ex13
        )

    WithdrawalState Get(
        1: WithdrawalID id
        2: EventRange range
    )
        throws (
            1: fistful.WithdrawalNotFound ex1
        )

    context.ContextSet GetContext(
        1: WithdrawalID id
    )
        throws (
            1: fistful.WithdrawalNotFound ex1
        )

    list<Event> GetEvents(
        1: WithdrawalID id
        2: EventRange range
    )
        throws (
            1: fistful.WithdrawalNotFound ex1
        )

    withdrawal_adjustment.AdjustmentState CreateAdjustment(
        1: WithdrawalID id
        2: withdrawal_adjustment.AdjustmentParams params
    )
        throws (
            1: fistful.WithdrawalNotFound ex1
            2: InvalidWithdrawalStatus ex2
            3: ForbiddenStatusChange ex3
            4: AlreadyHasStatus ex4
            5: AnotherAdjustmentInProgress ex5
            6: AlreadyHasDataRevision ex6
        )
}

/// Repair

union RepairScenario {
    1: AddEventsRepair add_events
}

struct AddEventsRepair {
    1: required list<Change>             events
    2: optional repairing.ComplexAction  action
}

service Repairer {
    void Repair(1: WithdrawalID id, 2: RepairScenario scenario)
        throws (
            1: fistful.WithdrawalNotFound ex1
            2: fistful.MachineAlreadyWorking ex2
        )
}
