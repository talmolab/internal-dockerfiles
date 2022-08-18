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

if [[ $RUNNER_CONDA_ENV == *":"* ]]; then
    _log "Installing new environment."
    IFS=":" read -ra ENV_PARTS <<< "$RUNNER_CONDA_ENV"
    RUNNER_CONDA_ENV="${ENV_PARTS[0]}"
    CONDA_ENV_FILE="${ENV_PARTS[1]}"
    _log "RUNNER_CONDA_ENV:" "$RUNNER_CONDA_ENV"
    _log "CONDA_ENV_FILE:" "$CONDA_ENV_FILE"
    install-environment "$CONDA_ENV_FILE" "$RUNNER_CONDA_ENV"
fi

# conda run -n "$RUNNER_CONDA_ENV" ${RUNNER_CMD[@]}
# conda run -n "$RUNNER_CONDA_ENV" "${RUNNER_CMD[@]}"
# conda run -n "$RUNNER_CONDA_ENV" "$RUNNER_CMD"
eval conda run -n "$RUNNER_CONDA_ENV" "$RUNNER_CMD"