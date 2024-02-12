## debug app

### [json/mqtt example structure](mqtt_strucutre.json)

### [python test pub mqtt data](mqtt_pubdata.py)

### start manually docker instances

start mosquitto
```
sudo docker run -it -p 1883:1883 -p 9001:9001 -v $PWD/mosquitto/config/mosquitto.conf:/mosquitto/config/mosquitto.conf -v $PWD/mosquitto/data -v $PWD/mosquitto/log eclipse-mosquitto
```

start influxdb2
```
sudo docker run -d -p 8086:8086 --name influxdb2 -v $PWD/influxdb2/data:/var/lib/influxdb2 -v $PWD/influxdb2/config:/etc/influxdb2 influxdb:latest
```

start telegraf
```
sudo docker run -v $PWD/telegraf/config/telegraf.conf:/etc/telegraf/telegraf.conf:ro telegraf
```