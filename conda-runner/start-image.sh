#!/bin/bash

set -e

# The _log function is used for everything this script wants to log. It will
# always log errors and warnings, but can be silenced for other messages
# by setting LOGGING_QUIET environment variable.
_log () {
    if [[ "$*" == "ERROR:"* ]] || [[ "$*" == "WARNING:"* ]] || [[ "${LOGGING_QUIET}" == "" ]]; then
        echo "$@"
    fi
}
_log "Entered start-image.sh with args:" "$@"

_log "in start-image.sh"
_log "RUNNER_CONDA_ENV:" "$RUNNER_CONDA_ENV"
_log "RUNNER_CMD:" "${RUNNER_CMD[@]}"

# Check 
# conda env list --json
# {
#   "envs": [
#     "C:\\Miniconda3",
#     "C:\\Miniconda3\\envs\\basepy37",
#     "C:\\Miniconda3\\envs\\campy",
#     "C:\\Miniconda3\\envs\\mabe2022",
#     "C:\\Miniconda3\\envs\\mabe2022-preproc",
#     "C:\\Miniconda3\\envs\\sleap_v1.2.1"
#   ]
# }


conda run -n "$RUNNER_CONDA_ENV" ${RUNNER_CMD[@]}