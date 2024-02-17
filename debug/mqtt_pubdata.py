#mqtt test for historian

import logging
import time
import datetime
import paho.mqtt.client as mqtt
import random
import json
import sys

#enable logging
logging.basicConfig()
log = logging.getLogger(__name__)
log.setLevel(logging.INFO)

#connect to broker
def on_connect(client, _userdata, _flags, rc):
    log.info("Connected with result code " + str(rc))

def json_data(debugLevel):

    #timestamp
    actualDate = datetime.datetime.now()
    unix_timestamp = datetime.datetime.timestamp(actualDate)*1000

    #jsonValue
    jsonValue = f"""{{"Timestamp":{unix_timestamp},"Value01":{random.uniform(-100,100)},"Value02":{random.uniform(-100,100)},"Value03":{random.uniform(-100,100)},"Value04":{random.uniform(-100,100)},"Value05":{random.uniform(-100,100)},"Value06":{random.uniform(-100,100)},"Value07":{random.uniform(-100,100)},"Value08":{random.uniform(-100,100)},"Value09":{random.uniform(-100,100)},"Value10":{random.uniform(-100,100)}}}"""
    jsonMessage = json.dumps(jsonValue)

    #msg = json.dumps({"Timestamp":1707209998050,"Value01":56.0,"Value02":-58.0,"Value03":46.0,"Value04":-48.0,"Value05":36.0,"Value06":-38.0,"Value07":93.0,"Value08":61.0,"Value09":96.0,"Value10":62.0})
    #print(msg)

    #debug message
    if debugLevel == 1:
        print(jsonValue)

    #return json message
    return jsonValue

#mqtt client
client = mqtt.Client()
client.on_connect = on_connect
client.connect("localhost", 1883, 60)
client.loop_start()

#loop for publish data
while True:

    client.publish("historizeData/historizeSlow", json_data(0))
    client.publish("historizeData/historizeMiddle", json_data(0))
    client.publish("historizeData/historizeFast", json_data(0))
    time.sleep(0.15) #150ms

client.loop_stop()