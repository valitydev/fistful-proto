/**
 * Сервис кошельков
 */

namespace java dev.vality.fistful
namespace erlang fistful.fistful

include "base.thrift"
include "context.thrift"

typedef base.ID ID
typedef ID AccountID
typedef ID SourceID
typedef ID DestinationID
typedef ID DepositID
typedef ID DepositRevertID
typedef ID AdjustmentID
typedef ID WithdrawalID
typedef ID W2WTransferID
typedef ID IdentityID
typedef ID WalletID
typedef i64 Amount
typedef string SourceName
typedef base.ObjectID ProviderID
typedef base.ObjectID TerminalID

typedef base.CurrencyRef CurrencyRef
typedef base.Cash DepositBody
typedef base.CashRange CashRange

enum Blocking {
    unblocked
    blocked
}

union WithdrawalMethod {
    1: base.PaymentServiceRef digital_wallet
    2: base.CryptoCurrencyRef crypto_currency
    3: BankCardWithdrawalMethod bank_card
    4: base.PaymentServiceRef generic
}

struct BankCardWithdrawalMethod {
    1: optional base.PaymentSystemRef payment_system
}

exception PartyNotFound             {}
exception IdentityNotFound          {}
exception CurrencyNotFound          {}
exception SourceNotFound            {}
exception DestinationNotFound       {}
exception DepositNotFound           {}
exception SourceUnauthorized        {}
exception PartyInaccessible         {}
exception WalletInaccessible {
    1: required WalletID id
}
exception ProviderNotFound          {}
exception IdentityClassNotFound     {}
exception ChallengeNotFound         {}
exception ChallengePending          {}
exception ChallengeClassNotFound    {}
exception ChallengeLevelIncorrect   {}
exception ChallengeConflict         {}
exception ProofNotFound             {}
exception ProofInsufficient         {}
exception WalletNotFound            {
    1: optional WalletID id
}
exception WithdrawalNotFound        {}
exception WithdrawalSessionNotFound {}
exception MachineAlreadyWorking     {}
exception DestinationUnauthorized   {}
exception ForbiddenWithdrawalMethod {}

/** Условия запрещают проводить операцию с такой валютой */
exception ForbiddenOperationCurrency {
    1: required CurrencyRef currency
    2: required set<CurrencyRef> allowed_currencies
}

/** Условия запрещают проводить операцию с такой суммой */
exception ForbiddenOperationAmount {
    1: required base.Cash amount
    2: required base.CashRange allowed_range
}

/** Операцию с такой суммой невозможно провести */
exception InvalidOperationAmount {
    1: required base.Cash amount
}

exception OperationNotPermitted { 1: optional string details }
exception W2WNotFound {}
