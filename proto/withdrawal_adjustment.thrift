/**
 * Корректировка вывода
 */

namespace java   dev.vality.fistful.withdrawal.adjustment
namespace erlang fistful.wthd.adj

include "base.thrift"
include "fistful.thrift"
include "cashflow.thrift"
include "transfer.thrift"
include "withdrawal_status.thrift"

typedef fistful.AdjustmentID     AdjustmentID
typedef base.ExternalID          ExternalID
typedef withdrawal_status.Status TargetStatus

struct Adjustment {
     1: required AdjustmentID        id
     2: required Status              status
     3: required ChangesPlan         changes_plan
     4: required base.Timestamp      created_at
     5: required base.DataRevision   domain_revision
     7: optional ExternalID          external_id
     8: required base.Timestamp      operation_timestamp
}

struct AdjustmentParams {
     /** Глобально уникальный идентификатор корректировки */
     1: required AdjustmentID        id
     2: required ChangeRequest       change
     3: optional ExternalID          external_id
}

struct AdjustmentState {
    1: required AdjustmentID        id
    2: required Status              status
    3: required ChangesPlan         changes_plan
    4: required base.Timestamp      created_at
    5: required base.DataRevision   domain_revision
    7: optional ExternalID          external_id
    8: required base.Timestamp      operation_timestamp
}

union Status {
    1: Pending pending
    2: Succeeded succeeded
}

struct Pending {}
struct Succeeded {}

union Change {
    1: CreatedChange     created
    2: StatusChange      status_changed
    3: TransferChange    transfer
}

struct CreatedChange {
    1: required Adjustment adjustment
}

struct StatusChange {
    1: required Status status
}

struct TransferChange {
    1: required transfer.Change payload
}

struct ChangesPlan {
    1: optional CashFlowChangePlan new_cash_flow
    2: optional StatusChangePlan new_status
    3: optional DataRevisionChangePlan new_domain_revision
}

struct CashFlowChangePlan {
    1: required cashflow.FinalCashFlow old_cash_flow_inverted
    2: required cashflow.FinalCashFlow new_cash_flow
}

struct StatusChangePlan {
    1: required TargetStatus new_status
}

struct DataRevisionChangePlan {
    1: required base.DataRevision new_domain_revision
}

union ChangeRequest {
    1: ChangeStatusRequest change_status
    2: ChangeCashFlowRequest change_cash_flow
}

struct ChangeStatusRequest {
    1: required TargetStatus new_status
}

struct ChangeCashFlowRequest {
    /** Ревизия, относительно которой необходимо пересчитать граф финансовых потоков. */
    1: optional base.DataRevision domain_revision
}
