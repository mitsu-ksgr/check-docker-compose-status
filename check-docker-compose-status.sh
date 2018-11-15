#!/bin/bash

#
# Usage
#
usage () {
    cat << __EOS__
Check docker-compose containers status.

Usage:
    check-docker-compose-status.sh [OPTIONS]

Options:
    -h          Show help.
    -v          Verbose mode.

__EOS__
}

if [ "$1" = '-h' ]; then
    usage
    exit 0
fi


#
# Constants.
#
PROJECT_NAME=${PWD##*/}
VERBOSE=$([ "$1" = '-v' ] && echo "true" || echo "false")



#
# Check helpers
#
is_running () { [ $1 = "running" ] ; }
is_paused () { [ $1 = "paused" ] ; }
is_exit () { [ $1 = "exited" ] ; }


#
# Check function
# - TODO: if possible, i want to read the definitions of accepted state for
#         each containers from external config file.
#
check_state () {
    local container=$(echo $1 | sed 's/^'${PROJECT_NAME}'_//')
    local state=$2

    # !!! UPDATE CONDITIONS ACCRODING TO YOUR PROJECT'S CONTAINERS !!!
    case "${container}" in
        "web" )
            return $(is_running $state)
            ;;

        "db" )
            return $(is_running $state)
            ;;
    esac
}


#
# Get container list
#
containers=$(
    docker-compose ps | \
        sed -e '1,2d' | \
        awk '/'${PROJECT_NAME}'/ { print $1 }'
)
containers=(${containers}) # convert to array


#
# Check container status
#
failed=false
for container in "${containers[@]}" ; do
    state=$(
        docker container inspect --format='{{.State.Status}}' ${container}
    )

    if $(check_state "${container}" "${state}") ; then
        $VERBOSE && echo "OK: ${container}, state=${state}"
    else
        $VERBOSE && echo "NG: ${container}, state=${state}"
        failed=true
    fi
done


$failed && exit 1 || exit 0

