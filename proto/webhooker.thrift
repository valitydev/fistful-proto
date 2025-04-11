include "base.thrift"

namespace java dev.vality.fistful.webhooker
namespace erlang fistful.webhooker

typedef base.ID PartyID
typedef base.ID WalletID
typedef string Url
typedef string Key
typedef i64 WebhookID
exception WebhookNotFound {}

struct Webhook {
    1: required WebhookID id
    2: required PartyID party_id
    3: optional WalletID wallet_id
    4: required EventFilter event_filter
    5: required Url url
    6: required Key pub_key
    7: required bool enabled
}

struct WebhookParams {
    1: required PartyID party_id
    2: optional WalletID wallet_id
    3: required EventFilter event_filter
    4: required Url url
}

struct EventFilter {
    1: required set<EventType> types
}

union EventType {
    1: WithdrawalEventType withdrawal

    2: DestinationEventType destination
}

union WithdrawalEventType {
    1: WithdrawalStarted started
    2: WithdrawalSucceeded succeeded
    3: WithdrawalFailed failed
}

union DestinationEventType {
    1: DestinationCreated created
    2: DestinationUnauthorized unauthorized
    3: DestinationAuthorized authorized
}

struct WithdrawalStarted {}
struct WithdrawalSucceeded {}
struct WithdrawalFailed {}

struct DestinationCreated {}
struct DestinationUnauthorized {}
struct DestinationAuthorized {}

service WebhookManager {
    list<Webhook> GetList(1: PartyID party_id)
    Webhook Get(1: WebhookID webhook_id) throws (1: WebhookNotFound ex1)
    Webhook Create(1: WebhookParams webhook_params)
    void Delete(1: WebhookID webhook_id) throws (1: WebhookNotFound ex1)
}