#!/bin/sh
#SPDX-License-Identifier: MIT

#set -x

# set absolute path of root app for global use - relative path from this point
# ${PWD%/*} -> one folder up / ${PWD%/*/*} -> two folders up 
SCRIPT_ROOT_PATH="${PWD%/*}/posix-lib-utils"

# test include external libs from debian submodule
if [ -f  ${SCRIPT_ROOT_PATH}/docker_lib.sh ]; then
    . ${SCRIPT_ROOT_PATH}/docker_lib.sh
else
    printf "$0: docker external libs not found - exit.\n"
    exit 1
fi

# print header
print_header "setup docker historian"


# load enviroment variables
log -info "load environment variables"
. ./.env

# print verion
log -info "version of historian setup ${DOCKER_GENERAL_VERSION}"

# check number of args
check_args 1

#Parameter/Arguments
option=$1

# main Functions
main() {

    #check inputargs
    case $option in
            --test)
                log -info "test Command for debugging $0"
                test_configuration
                ;;

            --setup)
                log -info "setup historian"
                check_requirements
                create_config_files
                docker_setup_images
                ;;

            --config)
                log -info "create config files"
                check_requirements
                create_config_files
                ;;

            --start)
                check_requirements
                log -info "start historian"
                docker_compose_start
                ;;

            --stop)
                check_requirements
                log -info "stop historian"
                docker_compose_stop
                ;;

            --reset)
                check_requirements
                log -info "reset historian"
                docker_compose_reset
                ;;

            --delete)
                check_requirements
                log -info "delete historian"
                docker_delete_data
                docker_delete_local_data
                ;;

            --state)
                docker_check_state
                ;;

            --help | --info | *)
                usage   "\-\-test:              test command" \
                        "\-\-setup:             setup historian" \
                        "\-\-start:             start container" \
                        "\-\-stop:              stop container" \
                        "\-\-reset:             reset container" \
                        "\-\-delete:            delete docker data" \
                        "\-\-state:             state of docker system" \
                        "\-\-help:              help"
                ;; 
    esac
}

# create config files
create_config_files(){

    log -info "create config files"

# write mosquitto.conf
    cat << EOF > ${DOCKER_MQTT_VOLUME}/config/${DOCKER_MQTT_CONFIGFILE}
#standard configuration
allow_anonymous true
listener ${DOCKER_MQTT_BROKER_PORT}
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log

#bridge configuration
connection broker-home-local
address ${DOCKER_MQTT_BRIDGE_ADDRESS}:${DOCKER_MQTT_BROKER_PORT}
topic # both 0

#bridge parameter
cleansession false
notifications false
bridge_insecure false
EOF

}

# setup docker images
docker_setup_images() {

    log -info "setup docker images"

    # convert relative path to absolute
    log -info "convert raltive to absolute path docker mosquitto"
    DOCKER_MQTT_VOLUME=$(echo ${DOCKER_MQTT_VOLUME} | sed -e  's|^./|'"$(pwd)/"'|g')


    # docker mosquitto image
    log -info "docker mosquitto"
    docker run -d \
        -p ${DOCKER_MQTT_BROKER_PORT}:1883 -p ${DOCKER_MQTT_WEBSOCKET_PORT}:9001 \
        --name mosquitto \
        -v ${DOCKER_MQTT_VOLUME}/config/${DOCKER_MQTT_CONFIGFILE}:/mosquitto/config/mosquitto.conf \
        -v ${DOCKER_MQTT_VOLUME}/data:/mosquitto/data \
        -v ${DOCKER_MQTT_VOLUME}/log:/mosquitto/log \
        --env-file "./.env" \
        eclipse-mosquitto

    sleep 2
    docker ps -a
    log -info "was docker mosquitto successful ?"
    continue_yes_no

    # convert relative path to absolute
    log -info "convert raltive to absolute path docker influxdb"
    DOCKER_INFLUXDB_VOLUME=$(echo ${DOCKER_INFLUXDB_VOLUME} | sed -e  's|^./|'"$(pwd)/"'|g')

    # docker influxdbv2 image
    log -info "docker influxdb"
    docker run -d \
        -p ${DOCKER_INFLUXDB_PORT}:8086 \
        --name influxdb2 \
        -v ${DOCKER_INFLUXDB_VOLUME}/data:/var/lib/influxdb2 \
        -v ${DOCKER_INFLUXDB_VOLUME}/config:/etc/influxdb2 \
        --env-file "./.env" \
        influxdb:latest

    sleep 2
    docker ps -a
    log -info "was docker influxdb successful ?"
    log -info "check installation http://localhost:8086/"
    continue_yes_no


    # convert relative path to absolute
    log -info "convert raltive to absolute path docker telegraf"
    DOCKER_TELEGRAF_VOLUME=$(echo ${DOCKER_TELEGRAF_VOLUME} | sed -e  's|^./|'"$(pwd)/"'|g')

    #docker telegraf image
    log -info "docker telegraf"
    docker run -d \
        --name telegraf \
        -v ${DOCKER_TELEGRAF_VOLUME}/config/${DOCKER_TELEGRAF_CONFIGFILE}:/etc/telegraf/telegraf.conf:ro \
        --env-file "./.env" \
        telegraf

    sleep 2
    docker ps -a
    log -info "was docker telegraf successful ?"
    continue_yes_no


    # convert relative path to absolute
    log -info "convert raltive to absolute path docker grafana"
    DOCKER_GRAFANA_VOLUME=$(echo ${DOCKER_GRAFANA_VOLUME} | sed -e  's|^./|'"$(pwd)/"'|g')

    #docker grafana image
    log -info "docker grafana"
    docker run -d \
        --name=grafana \
        -p ${DOCKER_GRAFANA_PORT}:3000 \
        -v ${DOCKER_GRAFANA_VOLUME}/data:/var/lib/grafana \
        --env-file "./.env" \
        grafana/grafana

    sleep 2
    docker ps -a
    log -info "was docker grafana successful ?"
    continue_yes_no
}

# delete productive files
docker_delete_local_data() {

    log -info "delete prductive data"

    # remove mosquitto data
    if [ -d ${DOCKER_MQTT_VOLUME} ] && \
        [ ! ${DOCKER_MQTT_VOLUME} = "/" ] && \
        [ ! -z ${DOCKER_MQTT_VOLUME} ]; then
            log -info "delete filed in ${DOCKER_MQTT_VOLUME}"
            rm -r ${DOCKER_MQTT_VOLUME}/data/*
            rm -r ${DOCKER_MQTT_VOLUME}/log/*
    fi

    # remove influxdbv2 data
    if [ -d ${DOCKER_INFLUXDB_VOLUME} ] && \
        [ ! ${DOCKER_INFLUXDB_VOLUME} = "/" ] && \
        [ ! -z ${DOCKER_INFLUXDB_VOLUME} ]; then
            log -info "delete filed in ${DOCKER_INFLUXDB_VOLUME}"
            rm -r ${DOCKER_INFLUXDB_VOLUME}/data/*
            rm -r ${DOCKER_INFLUXDB_VOLUME}/config/*
    fi

    # remove grafana data
    if [ -d ${DOCKER_GRAFANA_VOLUME} ] && \
        [ ! ${DOCKER_GRAFANA_VOLUME} = "/" ] && \
        [ ! -z ${DOCKER_INFLUXDB_VOLUME} ]; then
            log -info "delete filed in ${DOCKER_GRAFANA_VOLUME}"
            rm -r ${DOCKER_GRAFANA_VOLUME}/data/*
    fi

}

# Check requirements
check_requirements() {

    # check root
    check_root

    # Check Command
    if command -v docker >/dev/null 2>&1 ; then
        log -info "docker found OK"
    else
        log -info "docker not found MISSING"

        #install docker system or abort
        log -info "install docker system [y] or abort [n] setup ?"
        continue_yes_no
        docker_setup_system
    fi 
}

#call main Function manually - if not need uncomment
main "$@"; exit