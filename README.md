# docker-influx-historian :whale:

## docker based influx historian / grafana  application

historize data from twincat plc with mqtt and influxdbv2

## contents
* [installation](#installation)
* [usage](#usage)
* [tests](#tests)
* [version](#version)

## installation
* install docker for linux or wsl
* adjust environment settings for and `.env`
* test configuration with `setup-historian.sh --test`
* generate config files and missing folders `setup-historian.sh --config`
* docker compose configuration you will find `docker-compose.yml` 
* influxdb (e.g. http://localhost:8086) login you find in `.env`
* grafana (e.g. http://localhost:3000) inital login admin/admin

## usage
* setup docker container for testing
  - `setup-historian.sh --setup`

* write configutation file manually - for docker compose usage
  - `setup-historian.sh --config`
  
* docker compose start historian
  - `setup-historian.sh --start`

* docker compose stop historian
  - `setup-historian.sh --stop`

* docker compose reset historian
  - `setup-historian.sh --reset`

* delete all docker and configuration data
  - `setup-historian.sh --delete`

* state of docker container
  - `setup-historian.sh --state`

## resources
* debug for [tests](debug/)

## tests
* not testet completly

## version
* 0.1
  - init document
