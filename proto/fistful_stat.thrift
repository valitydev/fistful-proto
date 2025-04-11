/**
 * Интерфейс сервиса статистики и связанные с ним определения предметной области, основанные на моделях домена.
 */

include "base.thrift"
include "fistful.thrift"
include "cashflow.thrift"

namespace java dev.vality.fistful.fistful_stat
namespace erlang fistful.stat

typedef fistful.WalletID WalletID
typedef fistful.WithdrawalID WithdrawalID
typedef fistful.DepositID DepositID
typedef fistful.DestinationID DestinationID
typedef fistful.SourceID SourceID
typedef base.CurrencySymbolicCode CurrencySymbolicCode
typedef fistful.ProviderID ProviderID
typedef fistful.TerminalID TerminalID
typedef fistful.PartyID PartyID
typedef base.Realm Realm

/**
* Информация о выводе
*/
struct StatWithdrawal {
    1:  required WithdrawalID         id
    2:  required base.Timestamp       created_at
    3:  required PartyID              party_id
    4:  required WalletID             source_id
    5:  required DestinationID        destination_id
    6:  optional base.ExternalID      external_id
    7:  required base.Amount          amount
    8:  required base.Amount          fee
    9:  required CurrencySymbolicCode currency_symbolic_code
    10: required WithdrawalStatus     status
    11: optional ProviderID           provider_id
    12: optional TerminalID           terminal_id
}

union WithdrawalStatus {
    1: WithdrawalPending pending
    2: WithdrawalSucceeded succeeded
    3: WithdrawalFailed failed
}

struct WithdrawalPending {}
struct WithdrawalSucceeded {}
struct WithdrawalFailed {
    1: optional Failure failure
    2: optional base.Failure base_failure
}

struct Failure {
    // TODO
}

/**
* Информация о пополнении
*/
struct StatDeposit {
    1:  required DepositID            id
    2:  required base.Timestamp       created_at
    3:  required PartyID              party_id
    4:  required WalletID             destination_id
    5:  required SourceID             source_id
    6:  required base.Amount          amount
    7:  required base.Amount          fee
    8:  required CurrencySymbolicCode currency_symbolic_code
    9: required DepositStatus         status
    10: optional string               description
}

enum RevertStatus {
    none
    partial
    full
}

union DepositStatus {
    1: DepositPending pending
    2: DepositSucceeded succeeded
    3: DepositFailed failed
}

struct DepositPending {}
struct DepositSucceeded {}
struct DepositFailed {
    1: required Failure failure
}

/**
* Информация о источнике средств
*/

struct StatSource {
    1: required SourceID id
    2: required Realm realm
    3: required PartyID party_id
    4: required string name
    5: optional base.Timestamp created_at
    6: optional bool is_blocked
    7: required CurrencySymbolicCode currency_symbolic_code
    8: required SourceResource resource
    9: optional base.ExternalID external_id
}

union SourceResource {
    1: SourceResourceInternal internal
}

struct SourceResourceInternal {
    1: optional string  details
}

/**
* Информация о приёмнике средств
*/

struct StatDestination {
    1: required DestinationID id
    2: required Realm realm
    3: required PartyID party_id
    4: required string name
    5: optional base.Timestamp created_at
    6: optional bool is_blocked
    7: required CurrencySymbolicCode currency_symbolic_code
    8: required DestinationResource resource
    9: optional base.ExternalID external_id
}

union DestinationResource {
    1: base.BankCard bank_card
    2: base.CryptoWallet crypto_wallet
    3: base.DigitalWallet digital_wallet
}

/**
* Данные запроса к сервису. Формат и функциональность запроса зависят от DSL.
 * DSL содержит условия выборки, а также id мерчанта, по которому производится выборка.
 * continuation_token - токен, который передается в случае обращения за следующим блоком данных, соответствующих dsl
*/
struct StatRequest {
    1: required string dsl
    2: optional string continuation_token
}

/**
* Данные ответа сервиса.
* data - данные, тип зависит от целевой функции.
* total_count - ожидаемое общее количество данных (т.е. размер всех данных результата, без ограничений по количеству)
* continuation_token - токен, сигнализирующий о том, что в ответе передана только часть данных, для получения следующей части
* нужно повторно обратиться к сервису, указав тот-же набор условий и continuation_token. Если токена нет, получена последняя часть данных.
*/
struct StatResponse {
    1: required StatResponseData data
    2: optional i32 total_count
    3: optional string continuation_token
}

/**
* Возможные варианты возвращаемых данных
*/
union StatResponseData {
    1: list<StatWithdrawal> withdrawals
    2: list<StatDeposit> deposits
    3: list<StatSource> sources
    4: list<StatDestination> destinations
}

/**
* Ошибка обработки переданного токена, при получении такой ошибки клиент должен заново запросить все данные, соответсвующие dsl запросу
*/
exception BadToken {
    1: string reason
}

/**
 * Исключение, сигнализирующее о непригодных с точки зрения бизнес-логики входных данных
 */
exception InvalidRequest {
    /** Список пригодных для восприятия человеком ошибок во входных данных */
    1: required list<string> errors
}

service FistfulStatistics {
    /**
     * Возвращает набор данных о выводах
     */
    StatResponse GetWithdrawals(1: StatRequest req) throws (1: InvalidRequest ex1, 3: BadToken ex3)

    /**
     * Возвращает набор данных о пополнениях
     */
    StatResponse GetDeposits(1: StatRequest req) throws (1: InvalidRequest ex1, 3: BadToken ex3)

    /**
     * Возвращает набор данных о источниках средств
     */
    StatResponse GetSources(1: StatRequest req) throws (1: InvalidRequest ex1, 2: BadToken ex3)

    /**
     * Возвращает набор данных о приёмниках средств
     */
    StatResponse GetDestinations(1: StatRequest req) throws (1: InvalidRequest ex1, 2: BadToken ex3)
}
