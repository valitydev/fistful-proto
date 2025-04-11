/**
 * Счета
 */

namespace java   dev.vality.fistful.account
namespace erlang fistful.account

include "base.thrift"
include "fistful.thrift"

/// Domain

typedef fistful.PartyID PartyID
typedef i64 AccountID
typedef base.CurrencySymbolicCode CurrencySymbolicCode

struct Account {
    1: optional PartyID party_id
    2: required base.Realm realm
    3: required base.CurrencyRef currency
    4: required AccountID account_id
}
