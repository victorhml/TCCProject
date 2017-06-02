#-*-coding: utf-8 -*-
#Importar bibliotecas
import RPi.GPIO as GPIO
import time
import pyrebase
import socket
import sys
import Adafruit_DHT
import os
import requests
import spidev

#Configuração do Firebase
config = {
  "apiKey": "AIzaSyBSQnzFDfZ5fIVvraqGOqOchQNmnnxSmkw",
  "authDomain": "testproject-a8a37.firebaseapp.com",
  "databaseURL": "https://testproject-a8a37.firebaseio.com",
  "storageBucket": "testproject-a8a37.appspot.com"
}

firebase = pyrebase.initialize_app(config)

#Inicialização GPIO
GPIO.setmode(GPIO.BOARD)
GPIO.setwarnings(False)

#Portas
GPIO.setup(11, GPIO.OUT)
GPIO.setup(12, GPIO.OUT)
GPIO.setup(13, GPIO.OUT)
GPIO.setup(16, GPIO.OUT)

#Alarme
GPIO.setup(18, GPIO.OUT)
GPIO.output(18,GPIO.HIGH)

#Temperatura e umidade
GPIO.setup(15, GPIO.OUT)

#Presença
GPIO.setup(38, GPIO.IN)

#Inicialização do banco de dados do Firebase
db = firebase.database()

#IP
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect(('google.com', 0))
ip = s.getsockname()[0]
s.close

#Streaming da câmera
os.system('sudo pkill uv4l')
os.system('sudo uv4l -nopreview --auto-video_nr --driver raspicam --encoding mjpeg --width 640 --height 360 --framerate 120 --server-option \'--port=9090\' --server-option \'--max-queued-connections=30\' --server-option \'--max-streams=25\' --server-option \'--max-threads=29\'')

#Alarme
def morsecode():
        #DOT
        GPIO.output(18,GPIO.HIGH)
        time.sleep(.1)
        GPIO.output(18,GPIO.LOW)
        time.sleep(.1)
        GPIO.output(18,GPIO.HIGH)
        time.sleep(.1)
        GPIO.output(18,GPIO.LOW)
        time.sleep(.1)
        GPIO.output(18,GPIO.HIGH)
        time.sleep(.1)

        #DASH
        GPIO.output(18,GPIO.LOW)
        time.sleep(.2)
        GPIO.output(18,GPIO.HIGH)
        time.sleep(.2)
        GPIO.output(18,GPIO.LOW)
        time.sleep(.2)
        GPIO.output(18,GPIO.HIGH)
        time.sleep(.2)
        GPIO.output(18,GPIO.LOW)
        time.sleep(.2)
        GPIO.output(18,GPIO.HIGH)
        time.sleep(.2)
        GPIO.output(18,GPIO.LOW)
        time.sleep(.2)

        #DOT
        GPIO.output(18,GPIO.HIGH)
        time.sleep(.1)
        GPIO.output(18,GPIO.LOW)
        time.sleep(.1)
        GPIO.output(18,GPIO.HIGH)
        time.sleep(.1)
        GPIO.output(18,GPIO.LOW)
        time.sleep(.1)
        GPIO.output(18,GPIO.HIGH)
        time.sleep(.1)
        GPIO.output(18,GPIO.LOW)
        time.sleep(.7)

#Envia o IP
db.child("ip").set({"value": ip})        
        
#Inicializa o SPI
spi = spidev.SpiDev()
spi.open(0,0)

#Leitura dos dados do MCP3008
def ReadChannel(channel):
  adc = spi.xfer2([1,(8+channel)<<4,0])
  data = ((adc[1]&3) << 8) + adc[2]
  return data

#Canais do MCP3008
gas_channel = 0
flame_channel = 1

#Repetição
while(True):

    #Temperatura e umidade
    hum, temp = Adafruit_DHT.read_retry(Adafruit_DHT.DHT22, 22)
    db.child("temperatura").set({"value": "{0:.1f}ºC".format(temp)})
    db.child("umidade").set({"value": "{0:.1f}%".format(hum)})
    
    #Verifica LED
    ban = db.child("portas").child("banheiro").get()
    coz = db.child("portas").child("cozinha").get()
    qua = db.child("portas").child("quarto").get()
    sala = db.child("portas").child("sala").get()
    #Verifica alarme
    al = db.child("alarme").get()
    
    for user in ban.each():
      
        if(user.val() == "OFF"):
            #Se valor é OFF, LED apaga
            GPIO.output(11, False)
        else:
            #Se valor é ON, LED acende
            GPIO.output(11, True)

    for user in coz.each():
      
        if(user.val() == "OFF"):
            #Se valor é OFF, LED apaga
            GPIO.output(12, False)
        else:
            #Se valor é ON, LED acende
            GPIO.output(12, True)
        
    for user in qua.each():
      
        if(user.val() == "OFF"):
            #Se valor é OFF, LED apaga
            GPIO.output(13, False)
        else:
            #Se valor é ON, LED acende
            GPIO.output(13, True)

    for user in sala.each():
      
        if(user.val() == "OFF"):
            #Se valor é OFF, LED apaga
            GPIO.output(16, False)
        else:
            #Se valor é ON, LED acende
            GPIO.output(16, True)

    for user in al.each():
      
        if(user.val() == "ON"):
            #Se valor é ON, ativa alarme
            morsecode()
        else:
            #Se valor é OFF, desativa alarme
            GPIO.output(18, GPIO.HIGH)    

    #Verifica presnça
    if GPIO.input(38) == 1:
        db.child("presenca").set({"state": "ON"})
    elif GPIO.input(38) == 0:
        db.child("presenca").set({"state": "OFF"})

    #Envia valor de sensor de gás
    gas_level = ReadChannel(gas_channel)
    if gas_level < 300:
        db.child("gas").set({"nivel": "{}".format(gas_level), "state":"OFF"})
        time.sleep(.1)
    elif gas_level >= 300:
        db.child("gas").set({"nivel": "{}".format(gas_level), "state":"ON"})
        time.sleep(.1)
    
    #Envia valor de sensor de chamas
    flame_level = 1023-ReadChannel(flame_channel)
    if flame_level < 300:
        db.child("fogo").set({"nivel": "{}".format(flame_level), "state":"OFF"})
        time.sleep(.1)
    elif flame_level >= 300:
        db.child("fogo").set({"nivel": "{}".format(flame_level), "state":"ON"})
        time.sleep(.1)
