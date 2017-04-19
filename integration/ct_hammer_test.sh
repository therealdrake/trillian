#!/bin/bash
set -e
INTEGRATION_DIR="$( cd "$( dirname "$0" )" && pwd )"
. "${INTEGRATION_DIR}"/common.sh

# Default to one RPC server and one HTTP server.
RPC_SERVER_COUNT=${1:-1}
HTTP_SERVER_COUNT=${2:-1}
SIGNER_COUNT=${3:-1}

go build ./integration/ct_hammer
. "${INTEGRATION_DIR}"/ct_prep_test.sh "${RPC_SERVER_COUNT}" "${HTTP_SERVER_COUNT}" "${SIGNER_COUNT}"

# Ensure everything is tidied on exit
TO_DELETE="${TO_DELETE} ${CT_CFG} ${ETCD_DB_DIR}"
TO_KILL+=(${HTTP_SERVER_PIDS[@]})
TO_KILL+=(${LOG_SIGNER_PIDS[@]})
TO_KILL+=(${LB_SERVER_PID})
TO_KILL+=(${RPC_SERVER_PIDS[@]})
TO_KILL+=(${ETCD_PID})

echo "Running test(s)"
set +e
./ct_hammer --log_config "${CT_CFG}" --ct_http_servers=${CT_SERVERS} --testdata_dir=${TESTDATA} --mmd=30s
RESULT=$?
set -e

. "${INTEGRATION_DIR}"/ct_stop_test.sh
TO_KILL=()

exit $RESULT
