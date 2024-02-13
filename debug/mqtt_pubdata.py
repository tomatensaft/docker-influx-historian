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
    msg = json.dumps({"Timestamp":1707209998050,"Value01":56.0,"Value02":-58.0,"Value03":46.0,"Value04":-48.0,"Value05":36.0,"Value06":-38.0,"Value07":93.0,"Value08":61.0,"Value09":96.0,"Value10":62.0})
    client.publish("historizeData/historizeSlow", msg)
    msg = json.dumps({"Timestamp":1907209998050,"Value01":156.0,"Value02":-158.0,"Value03":146.0,"Value04":-148.0,"Value05":136.0,"Value06":-138.0,"Value07":193.0,"Value08":161.0,"Value09":196.0,"Value10":162.0})
    client.publish("historizeData/historizeMiddle", msg)
    msg = json.dumps({"Timestamp":1907209998050,"Value01":256.0,"Value02":-258.0,"Value03":246.0,"Value04":-248.0,"Value05":236.0,"Value06":-238.0,"Value07":293.0,"Value08":261.0,"Value09":296.0,"Value10":262.0})
    client.publish("historizeData/historizeFast", msg)
    time.sleep(0.15) #500ms

client.loop_stop()