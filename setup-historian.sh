#!/bin/sh
#SPDX-License-Identifier: MIT

# set -x

#print header
printf "setup docker historian...\n"

#load enviroment variables
printf "load environment variables...\n"
. ./docker-compose.env

#print verion
printf "version of historian setup ${DOCKER_GENERAL_VERSION}\n"

#Check number of args
if [ $# -lt 1 ]; then
    printf "use at least one(1) argument\n\n"
    exit 1
fi

#Parameter/Arguments
option=$1

#Main Functions
main() {

    #Check Inputargs
    case $option in
            --test)
                printf "test Command for debugging $0\n"
                test_configuration
                ;;

            --setup)
                printf "setup historian...\n"
                check_requirements
                create_config_files
                docker_setup_images
                ;;

            --config)
                printf "create config files...\n"
                check_requirements
                create_config_files
                ;;

            --start)
                check_requirements
                printf "start historian...\n"
                docker_compose_start
                ;;

            --stop)
                check_requirements
                printf "stop historian...\n"
                docker_compose_stop
                ;;

            --reset)
                check_requirements
                printf "reset historian...\n"
                docker_compose_reset
                ;;

            --delete)
                check_requirements
                printf "delete historian...\n"
                docker_delete_data
                historian_delete_data
                ;;

            --state)
                docker_check_state
                ;;

            --help | --info | *)
                printf  "usage:\n \
                        test:      test command\n \
                        settp:     create historian\n \
                        start:     start historian\n \
                        delete:    delete historian\n \
                        config:    create config files\n \
                        state:     check docker state\n \
                        help:      help\n\n" 
                ;;
    esac
}

#create config files
create_config_files(){

    printf "create config files\n"

#write mosquitto.conf
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

#docker check state
docker_check_state() {

    printf "\nlist active container\n"
    docker ps -a

    printf "\nlist active images\n"
    docker images

    printf "\nlist active networks\n"
    docker network ls

    printf "\nlist active volumes\n"
    docker volume ls

}

#docker compose reset
docker_compose_reset() {
    printf "docker compose reset\n"
}

#docker compose stop
docker_compose_stop() {
    printf "docker compose stop\n"
}

#docker compose start
docker_compose_start() {
    printf "docker compose start\n"
}

#setup docker
docker_setup_system() {

    #add gpg key
    printf "add docker official gpg key\n"
    continue_yes_no
    apt-get update
    apt-get install ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    #add repo to sources
    printf "add repo to sources...\n"
    continue_yes_no
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "${VERSION_CODENAME}") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update

    #install software
    printf "install docker software...\n"
    continue_yes_no
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    #test docker
    printf "test docker system with hello world...\n\n"
    continue_yes_no
    docker run hello-world

}

#setup docker images
docker_setup_images() {

    printf "setup docker images...\n"

    #docker mosquitto image
    printf "docker mosquitto...\n"
    docker run -d \
        -p ${DOCKER_MQTT_BROKER_PORT}:${DOCKER_MQTT_BROKER_PORT} -p ${DOCKER_MQTT_WEBSOCKET_PORT}:${DOCKER_MQTT_WEBSOCKET_PORT} \
        --name mosquitto \
        -v ${DOCKER_MQTT_VOLUME}/config/${DOCKER_MQTT_CONFIGFILE}:/mosquitto/config/mosquitto.conf \
        -v ${DOCKER_MQTT_VOLUME}/data:/mosquitto/data \
        -v ${DOCKER_MQTT_VOLUME}/log:/mosquitto/log \
        --env-file "./docker-compose.env" \
        eclipse-mosquitto

    sleep 2
    docker ps -a
    printf "was docker mosquitto successful ?\n"
    continue_yes_no

    #docker influxdbv2 image
    printf "docker influxdb...\n"
    docker run -d \
        -p ${DOCKER_INFLUXDB_PORT}:${DOCKER_INFLUXDB_PORT} \
        --name influxdb2 \
        -v ${DOCKER_INFLUXDB_DATA}:/var/lib/influxdb2 \
        -v ${DOCKER_INFLUXDB_CONFIG}:/etc/influxdb2 \
        --env-file "./docker-compose.env" \
        influxdb:latest

    sleep 2
    docker ps -a
    printf "was docker influxdb successful ?\n"
    printf "check installation http://localhost:8086/\n\n"
    continue_yes_no

    #docker telegraf image
    printf "docker telegraf...\n"
    docker run -d \
        --name telegraf \
        -v ${DOCKER_TELEGRAF_VOLUME}/config/${DOCKER_TELEGRAF_CONFIGFILE}:/etc/telegraf/telegraf.conf:ro \
        --env-file "./docker-compose.env" \
        telegraf

    sleep 2
    docker ps -a
    printf "was docker telegraf successful ?\n"
    continue_yes_no

    #docker grafana image
    printf "docker grafana...\n"
    docker run -d \
        --name=grafana \
        -p ${DOCKER_GRAFANA_PORT}:${DOCKER_GRAFANA_PORT} \
        -v ${DOCKER_GRAFANA_VOLUME}/data:/var/lib/grafana \
        --env-file "./docker-compose.env" \
        grafana/grafana

    sleep 2
    docker ps -a
    printf "was docker grafana successful ?\n"
    continue_yes_no
}


#delete docker data
docker_delete_data() {

    printf "try shutdown all instances\n"
    docker compose down

    printf "reset docker instances\n"
    docker rm -f $(docker ps -a -q)
    docker rmi $(docker images -a -q)
    docker network rm $(docker network ls -q)
    docker volume rm $(docker volume ls -q)

    printf "running instances\n"
    docker ps -a
    printf "available offline images\n"
    docker images

}
#delete productive files
historian_delete_data() {

    printf "delete prductive data\n"

    #remove mosquitto data
    if [ -d ${DOCKER_MQTT_VOLUME} ] && \
        [ ! ${DOCKER_MQTT_VOLUME} = "/" ] && \
        [ ! -z ${DOCKER_MQTT_VOLUME} ]; then
            printf "delete filed in ${DOCKER_MQTT_VOLUME}\n"
            rm -r ${DOCKER_MQTT_VOLUME}/data/*
            rm -r ${DOCKER_MQTT_VOLUME}/log/*
    fi

    #remove influxdbv2 data
    if [ -d ${DOCKER_INFLUXDB_VOLUME} ] && \
        [ ! ${DOCKER_INFLUXDB_VOLUME} = "/" ] && \
        [ ! -z ${DOCKER_INFLUXDB_VOLUME} ]; then
            printf "delete filed in ${DOCKER_INFLUXDB_VOLUME}\n"
            rm -r ${DOCKER_INFLUXDB_VOLUME}/data/*
            rm -r ${DOCKER_INFLUXDB_VOLUME}/config/*
    fi

    #remove grafana data
    if [ -d ${DOCKER_GRAFANA_VOLUME} ] && \
        [ ! ${DOCKER_GRAFANA_VOLUME} = "/" ] && \
        [ ! -z ${DOCKER_INFLUXDB_VOLUME} ]; then
            printf "delete filed in ${DOCKER_GRAFANA_VOLUME}\n"
            rm -r ${DOCKER_GRAFANA_VOLUME}/data/*
    fi

}

#yes/no to continue
continue_yes_no() {

    while true; do
        read -p "continue setup [y]es or [n]o ?" result
        case ${result} in
            [Yy]* ) make install; break;;
            [Nn]* ) exit;;
            * ) printf "only [y]es or [n]o.\n";;
        esac
    done

}


#Check requirements
check_requirements() {

    #check root
    if [ $(id -u) -ne 0 ]; then
        printf "usage: run '$0' as sudo\n"
        exit 1
    fi

    #Check Command
    if command -v docker >/dev/null 2>&1 ; then
        printf "docker found OK\n"
    else
        printf "docker not found MISSING\n"

        #install docker system or abort
        printf "install docker system [y] or abort [n] setup ?\n"
        continue_yes_no
        docker_setup_system
    fi 
}

#test configuration
test_configuration() {

    printf "test configuration\n"
}

#call main Function manually - if not need uncomment
main "$@"; exit