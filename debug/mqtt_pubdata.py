import logging
import time
import paho.mqtt.client as mqtt
from random import randrange

logging.basicConfig()
log = logging.getLogger(__name__)
log.setLevel(logging.INFO)

import random
import json

def on_connect(client, _userdata, _flags, rc):
    log.info("Connected with result code " + str(rc))

client = mqtt.Client()
client.on_connect = on_connect
client.connect("localhost", 1883, 60)
client.loop_start()

while True:
    #msg = json.dumps({"name": "giordon", "value": 50.0*random.random(), "timestamp": int(time.time()), "tags": [{"make": "Digikey", "model": "HYT271"}]})
    msg = json.dumps({"Temperatures":{"Zone01":34.0,"Zone02":35.0,"Zone03":150.0,"Zone06":200.0},"Pressure":{"Extruder":150.0,"Tool":200.0,"System":300},"Rotations":{"Extruder":1450,"Tool":340,"Puller":340}})
    client.publish("historizeData", msg)
    time.sleep(1)

client.loop_stop()