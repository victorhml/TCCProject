from tkinter import *
import RPi.GPIO as GPIO
import time
import pyrebase
import socket
import sys
import Adafruit_DHT
import os
import requests
import spidev
from picamera import PiCamera

camera = PiCamera()

#Firebase Configuration
config = {
    "apiKey": "AIzaSyBSQnzFDfZ5fIVvraqGOqOchQNmnnxSmkw",
    "authDomain": "testproject-a8a37.firebaseapp.com",
    "databaseURL": "https://testproject-a8a37.firebaseio.com",
    "storageBucket": "testproject-a8a37.appspot.com"
}
firebase = pyrebase.initialize_app(config)

db = firebase.database()

#GPIO Setup
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
#GPIO.setup(15, GPIO.OUT)

#Presença
GPIO.setup(38, GPIO.IN)

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.connect(('google.com', 0))
ip = s.getsockname()[0]
s.close

gp = "OFF"

ala = db.child("alarme").get()
for user in ala.each():
        if user.val() == "OFF":
                gp = "OFF"                 
        else:
                gp = "ON"

def morsecode():
        #gp = 'ON'
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

spi = spidev.SpiDev()
spi.open(0,0)

def ReadChannel(channel):
  adc = spi.xfer2([1,(8+channel)<<4,0])
  data = ((adc[1]&3) << 8) + adc[2]
  return data

gas_channel = 0
flame_channel = 1

class Welcome():

        def __init__(self,master):

                self.master = master
                self.master.geometry("640x480")
                self.master.title("IoT Security")
                self.buttonCam = Button(self.master, text="Camera", font="Helvetica 30 bold", command=self.gotoWagesCam, height=4, width=10).grid(row=0, column=0)
                self.buttonSens = Button(self.master, text="Sensores", font="Helvetica 30 bold", command=self.gotoWagesSens, height=4, width=11).grid(row=0, column=1)
                self.buttonAla = Button(self.master, text="Alarme", font="Helvetica 30 bold", command=self.gotoWagesAla, height=4, width=10).grid(row=1, column=0)
                self.buttonPor = Button(self.master, text="Portas", font="Helvetica 30 bold", command=self.gotoWagesPor, height=4, width=11).grid(row=1, column=1)
                
        def gotoWagesCam(self):
            
                os.system('sudo pkill uv4l')
                camera.start_preview(fullscreen=False, window = (80, 80, 480,360))
                root=Toplevel(self.master)
                myGUI=WagesCam(root)

        def gotoWagesSens(self):

                root=Toplevel(self.master)
                myGUI=WagesSens(root)

        def gotoWagesAla(self):

                root=Toplevel(self.master)
                myGUI=WagesAla(root)

        def gotoWagesPor(self):

                root=Toplevel(self.master)
                myGUI=WagesPor(root)

class WagesCam():

        def __init__(self, master):

                self.master = master
                self.master.geometry("640x480")
                self.master.title("Camera")
                
                self.buttonBack = Button(self.master, text="Voltar", command=self.finish, width=75).pack(side='bottom')

        def finish(self):
                camera.stop_preview()
                self.master.destroy()
                os.system('sudo uv4l -nopreview --auto-video_nr --driver raspicam --encoding mjpeg --width 640 --height 360 --framerate 120 --server-option \'--port=9090\' --server-option \'--max-queued-connections=30\' --server-option \'--max-streams=25\' --server-option \'--max-threads=29\'')

class WagesSens():
        
        def __init__(self, master):
                
                self.master = master
                self.master.geometry("640x480")
                self.master.title("Sensores")
                alTxt = StringVar()
                alTxt.set('OFF')
                fogNvl = IntVar()
                fogNvl.set(0)
                fogTxt = StringVar()
                fogTxt.set('OFF')
                gasNvl = IntVar()
                gasNvl.set(0)
                gasTxt = StringVar()
                gasTxt.set('OFF')
                ipTxt = StringVar()
                ipTxt.set('192.168.1.15')
                preTxt = StringVar()
                preTxt.set('OFF')
                temTxt = StringVar()
                temTxt.set('0ºC')
                umiTxt = StringVar()
                umiTxt.set('0%')
                j = 10
                tmTxt = IntVar()
                tmTxt.set(j)
                
                m1 = Frame(master)
                
                self.labAl = Label(m1, text="Alarme", height=3, width=20).grid(row=0, column=0)
                self.stAl = Label(m1, textvariable=alTxt, height=3, width=20).grid(row=0, column=2)
                
                self.labFo = Label(m1, text="Fogo", height=3).grid(row=1, column=0)
                self.nvFo = Label(m1, textvariable=str(fogNvl), height=3).grid(row=1, column=1)
                self.stFo = Label(m1, textvariable=fogTxt, height=3).grid(row=1, column=2)
                
                self.labGa = Label(m1, text="Gas", height=3).grid(row=2, column=0)
                self.nvGa = Label(m1, textvariable=str(gasNvl), height=3).grid(row=2, column=1)
                self.stGa = Label(m1, textvariable=gasTxt, height=3).grid(row=2, column=2)

                self.labIp = Label(m1, text="IP", height=3).grid(row=3, column=0)
                self.stIp = Label(m1, textvariable=ipTxt, height=3).grid(row=3, column=2)

                self.labPr = Label(m1, text="Presença", height=3).grid(row=4, column=0)
                self.stPr = Label(m1, textvariable=preTxt, height=3).grid(row=4, column=2)

                self.labTe = Label(m1, text="Temperatura", height=3).grid(row=5, column=0)
                self.stTe = Label(m1, textvariable=temTxt, height=3).grid(row=5, column=2)

                self.labUm = Label(m1, text="Umidade", height=3).grid(row=6, column=0)
                self.stUm = Label(m1, textvariable=umiTxt, height=3).grid(row=6, column=2)

                self.labTm = Label(m1, text="Tempo", height=3).grid(row=7, column=0)
                self.stTm = Label(m1, textvariable=str(tmTxt), height=3).grid(row=7, column=2)


                m1.pack(side=TOP)
                m2 = Frame(master)
                self.buttonBack = Button(m2, text="Voltar", command=self.finish, width=75).pack(side='bottom')
                m2.pack(side=BOTTOM)
                        
                for i in range(j):
                #while(True):
                        j-=1
                        time.sleep(1)
                        if gp == 'ON':
                                alTxt.set('ON')
                                db.child('alarme').set({'state' : 'ON'})
                                
                        elif gp == 'OFF':
                                alTxt.set('OFF')
                                db.child('alarme').set({'state' : 'OFF'})
                                
                        gas_level = ReadChannel(gas_channel)
                        gasNvl.set(gas_level)
                        db.child('gas').set({'nivel' : gas_level})

                        
                        if gas_level < 300:
                                gasTxt.set('OFF')
                                db.child('gas').set({'state' : 'OFF'})
                        elif gas_level >= 300:
                                gasTxt.set('ON')
                                db.child('gas').set({'state' : 'ON'})
    
                        flame_level = 1023-ReadChannel(flame_channel)
                        fogNvl.set(flame_level)
                        db.child('fogo').set({'nivel' : flame_level})
                        
                        if flame_level < 300:
                                fogTxt.set('OFF')
                                db.child('fogo').set({'state' : 'OFF'})
                        elif flame_level >= 300:
                                fogTxt.set('ON')
                                db.child('gas').set({'state' : 'ON'})
                                
                        if GPIO.input(38):
                                preTxt.set('ON')
                                db.child('presenca').set({'state' : 'ON'})
                        elif GPIO.input(38) == 0:
                                preTxt.set('OFF')
                                db.child('presenca').set({'state' : 'OFF'})
                                
                        umid, temp = Adafruit_DHT.read_retry(Adafruit_DHT.DHT22, 22)
                        temTxt.set("{0:.1f}ºC".format(temp))
                        db.child('umidade').set({'value' : "{0:.1f}ºC".format(temp)})
                        umiTxt.set("{0:.1f}%".format(umid))
                        db.child('umidade').set({'value' : "{0:.1f}%".format(umid)})
                        tmTxt.set(j)
                        
                        
                        '''
                        al = db.child("alarme").get()
                        for user in al.each():
                                if user.val() == "ON":
                                        alTxt.set('ON')
                                else:
                                        alTxt.set('OFF')
                                        
                        fg = db.child("fogo").get()
                        for user in fg.each():
                                if user.val() == "ON":
                                        fogTxt.set('ON')
                                elif user.val() == "OFF":
                                        fogTxt.set('OFF')
                                else:
                                        fogNvl.set(user.val())
                                        
                        ga = db.child("gas").get()
                        for user in ga.each():
                                if user.val() == "ON":
                                        gasTxt.set('ON')
                                elif user.val() == "OFF":
                                        gasTxt.set('OFF')
                                else:
                                        gasNvl.set(user.val())

                        ip = db.child("ip").get()
                        for user in ip.each():
                                ipTxt.set(user.val())

                        pr = db.child("presenca").get()
                        for user in pr.each():
                                if user.val() == "ON":
                                        preTxt.set('ON')
                                else:
                                        preTxt.set('OFF')

                        temp = db.child("temperatura").get()
                        for user in temp.each():
                                temTxt.set(user.val())

                        umid = db.child("umidade").get()
                        for user in umid.each():
                                umiTxt.set(user.val())
                        '''
                        #self.master.mainloop()
                        self.master.update_idletasks()
                        #self.master.mainloop()
                        
        
                        
        def finish(self):

                        self.master.destroy()
class WagesAla():

        
        
        def __init__(self, master):

                self.master = master
                self.master.geometry("640x480")
                self.master.title("Alarmes")
                global gp
                al = db.child("alarme").get()
                for user in al.each():
                        if user.val() == "OFF":
                                gp = "ON"
                                self.swAla()
                                print(gp)
                        else:
                                gp = "OFF"
                                self.swAla()
                                print(gp)
                
                self.buttonBack = Button(self.master, text="Voltar", command=self.finish, width=75).pack(side='bottom')
                self.buttonAl = Button(self.master, text="Alarme", font="Helvetica 50 bold", command=self.swAla,height=30, width=75).pack(side='bottom')

        def swAla(self):
                
                al = db.child("alarme").get()
                global gp
                global alTxt
                if gp == "OFF":
                        morsecode()
                        db.child("alarme").set({"state": "ON"})
                        gp = "ON"
                else:
                        GPIO.output(18, GPIO.HIGH)
                        db.child("alarme").set({"state": "OFF"})
                        gp = "OFF"
                
                '''
                for user in al.each():
                                if user.val() == "OFF":
                                        gp=1
                                        morsecode()
                                        db.child("alarme").set({"state": "ON"})
                                else:
                                        gp=0
                                        GPIO.output(18,GPIO.HIGH)
                                        db.child("alarme").set({"state": "OFF"})
        '''
                
        def finish(self):

                self.master.destroy()

class WagesPor():

        def __init__(self, master):
                        
                self.master = master
                self.master.geometry("640x480")
                self.master.title("Portas")
                
                banTxt = StringVar()
                banTxt.set('Banheiro')
                cozTxt = StringVar()
                cozTxt.set('Cozinha')
                quaTxt = StringVar()
                quaTxt.set('Quarto')
                salTxt = StringVar()
                salTxt.set('Sala')

                ba = db.child("portas").child("banheiro").get()
                for user in ba.each():
                        if user.val() == "ON":
                                GPIO.output(11, GPIO.LOW)
                                self.swBan()
                                #banTxt.set('Banheiro: ON')
                        else:
                                GPIO.output(11, GPIO.HIGH)
                                self.swBan()
                                #banTxt.set('Banheiro: OFF')
                                        
                co = db.child("portas").child("cozinha").get()
                for user in co.each():
                        if user.val() == "ON":
                                GPIO.output(12, GPIO.LOW)
                                self.swCoz()
                                #cozTxt.set('Cozinha: ON')
                        else:
                                GPIO.output(12, GPIO.HIGH)
                                self.swCoz()
                                #cozTxt.set('Cozinha: OFF')
                                        
                qu = db.child("portas").child("quarto").get()
                for user in qu.each():
                        if user.val() == "ON":
                                GPIO.output(13, GPIO.LOW)
                                self.swQua()
                                #quaTxt.set('Quarto: ON')
                        else:
                                GPIO.output(13, GPIO.HIGH)
                                self.swQua()
                                #quaTxt.set('Quarto: OFF')

                sa = db.child("portas").child("sala").get()
                for user in sa.each():
                        if user.val() == "ON":
                                GPIO.output(16, GPIO.LOW)
                                self.swSal()
                                #salTxt.set('Sala: ON')
                        else:
                                GPIO.output(16, GPIO.HIGH)
                                self.swSal()
                                #salTxt.set('Sala: OFF')
                
                m1 = Frame(master)
                self.buttonBan = Button(m1, textvariable=banTxt, font="Helvetica 30 bold", command=self.swBan, height=4, width=10).grid(row=0, column=0)
                self.buttonCoz = Button(m1, textvariable=cozTxt, font="Helvetica 30 bold", command=self.swCoz, height=4, width=11).grid(row=0, column=1)
                self.buttonQua = Button(m1, textvariable=quaTxt, font="Helvetica 30 bold", command=self.swQua, height=4, width=10).grid(row=1, column=0)
                self.buttonSal = Button(m1, textvariable=salTxt, font="Helvetica 30 bold", command=self.swSal, height=4, width=11).grid(row=1, column=1)
                m1.pack(side=TOP)

                m2 = Frame(master)
                self.buttonBack = Button(m2, text="Voltar", command=self.finish, width=75).pack(side=BOTTOM)
                m2.pack(side=BOTTOM)

                
                '''
                for i in range(3600):
                        time.sleep(1)
                        ba = db.child("portas").child("banheiro").get()
                        for user in ba.each():
                                if user.val() == "ON":
                                        banTxt.set('Banheiro: ON')
                                else:
                                        banTxt.set('Banheiro: OFF')
                                        
                        co = db.child("portas").child("cozinha").get()
                        for user in co.each():
                                if user.val() == "ON":
                                        cozTxt.set('Cozinha: ON')
                                else:
                                        cozTxt.set('Cozinha: OFF')
                                        
                        qu = db.child("portas").child("quarto").get()
                        for user in qu.each():
                                if user.val() == "ON":
                                        quaTxt.set('Quarto: ON')
                                else:
                                        quaTxt.set('Quarto: OFF')

                        sa = db.child("portas").child("sala").get()
                        for user in sa.each():
                                if user.val() == "ON":
                                        salTxt.set('Sala: ON')
                                else:
                                        salTxt.set('Sala: OFF')

                        self.master.update_idletasks()
                        '''
        def swBan(self):
                if GPIO.input(11):
                        GPIO.output(11, GPIO.LOW)
                        db.child("portas").child("banheiro").set({"state": "OFF"})
                else:
                        GPIO.output(11, GPIO.HIGH)
                        db.child("portas").child("banheiro").set({"state": "ON"})
                '''
                ba = db.child("portas").child("banheiro").get()
                
                for user in ba.each():
                        if user.val() == "OFF":
                                db.child("portas").child("banheiro").set({"state": "ON"})
                        else:
                                db.child("portas").child("banheiro").set({"state": "OFF"})
        '''
        def swCoz(self):
                if GPIO.input(12):
                        GPIO.output(12, GPIO.LOW)
                        db.child("portas").child("cozinha").set({"state": "OFF"})
                else:
                        GPIO.output(12, GPIO.HIGH)
                        db.child("portas").child("cozinha").set({"state": "ON"})
                '''
                co = db.child("portas").child("cozinha").get()
                
                for user in co.each():
                        if user.val() == "OFF":
                                db.child("portas").child("cozinha").set({"state": "ON"})
                        else:
                                db.child("portas").child("cozinha").set({"state": "OFF"})
        '''
        def swQua(self):
                if GPIO.input(13):
                        GPIO.output(13, GPIO.LOW)
                        db.child("portas").child("quarto").set({"state": "OFF"})
                else:
                        GPIO.output(13, GPIO.HIGH)
                        db.child("portas").child("quarto").set({"state": "ON"})
                '''
                qu = db.child("portas").child("quarto").get()
                
                for user in qu.each():
                        if user.val() == "OFF":
                                db.child("portas").child("quarto").set({"state": "ON"})
                        else:
                                db.child("portas").child("quarto").set({"state": "OFF"})
        '''
        def swSal(self):
                if GPIO.input(16):
                        GPIO.output(16, GPIO.LOW)
                        db.child("portas").child("sala").set({"state": "OFF"})
                else:
                        GPIO.output(16, GPIO.HIGH)
                        db.child("portas").child("sala").set({"state": "ON"})
                '''
                sa = db.child("portas").child("sala").get()
                
                for user in sa.each():
                        if user.val() == "OFF":
                                db.child("portas").child("sala").set({"state": "ON"})
                        else:
                                db.child("portas").child("sala").set({"state": "OFF"})
        '''                       

        def finish(self):

                self.master.destroy()
        
                
def main():

        root = Tk()
        app=Welcome(root)
        root.mainloop()

if __name__ == '__main__':
        main()
        


