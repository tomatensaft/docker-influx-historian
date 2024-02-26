## mosquitto
mosquitto broker for data conneciton

### broker bridge
* the best way ist to use the brige function of the mosquitto to bring the data into the docker container
* adjust the bridge at the `mosquitto.conf`

### mosquitto example commands
subscrbe to topic
```
mosquitto_sub -h localhost -t \# -d
```
