/**
 * Статусы ввода
 */

namespace java   dev.vality.fistful.deposit.status
namespace erlang fistful.deposit.status

include "base.thrift"
typedef base.Failure          Failure

union Status {
    1: Pending pending
    2: Succeeded succeeded
    3: Failed failed
}

struct Pending {}
struct Succeeded {}
struct Failed {
    1: required Failure failure
}
