# docker-influx-historian
docker based influx historian / grafana  application

# historize data from twincat plc with mqtt and influxdbv2

* install docker for linux or wsl
* adjust environment settings for and `docker-compose.env`
* test configuration with `setup-historian.sh`
* docker compose configuration you will find `docker-compose.yml` 

## usage of `setup-historian.sh`

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