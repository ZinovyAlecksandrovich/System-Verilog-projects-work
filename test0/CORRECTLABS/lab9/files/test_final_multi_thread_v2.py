 
import time   # time related library
import sys,os    # system related library
ok_sdk_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\x64"
ok_dll_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\lib\\x64"
import pyvisa as visa # You should pip install pyvisa and restart the kernel.
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
from scipy import ndimage

mpl.style.use('ggplot')

sys.path.append(ok_sdk_loc)   # add the path of the OK library
os.add_dll_directory(ok_dll_loc)

import ok     # OpalKelly library
import cv2


device_manager = visa.ResourceManager()
devices = device_manager.list_resources()
number_of_device = len(devices)

from scipy import ndimage
import threading

#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("") 
ConfigStatus=dev.ConfigureFPGA("U:\\ece437\\test0\\CORRECTLABS\\lab9\\lab9.runs\\impl_1\\BTPipeExample.bit");  #  C:\\Users\\zinovya2\\ece437\\CORRECTLABS\\lab9\\lab9.runs\\impl_1\\BTPipeExample.bit


# We will NOT load the bit file because it will be loaded using JTAG interface from Vivado

# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.")
else:    
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)))
    print("Exiting the program.")
    sys.exit ()
    
    
    
def twos_comp(val, bits):
    """compute the 2's complement of int value val"""
    if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)        # compute negative value
    return val                         # return positive value as is

#%%

#direction = 0  # toward to rod, clockwise 
#direction = 1 # counter-clockwise 

PC_Control = 0; # send a "stop" signal to the FSM
dev.SetWireInValue(0x07, PC_Control) 
dev.UpdateWireIns()  # Update the WireIns
time.sleep(1)


bit_num = 315392;
buf = bytearray(bit_num);   # 648*488     
buf1 = bytearray(bit_num);   # 648*488  
buf2 = bytearray(bit_num);   # 648*488  

img_final = np.zeros([488,648,100]);
image = np.zeros(488*648)
pix1 = 648;
pix2 = 488;

img1 = None; # np.zeros([488,648,2]);

im_array1 = None;

#time.sleep(0.000001)
#ACC XCORD     
DeviceAddress = int("00110010",2)
dev.SetWireInValue(0x01, DeviceAddress) 
SubRegisterAddress = int("10101000",2)         #("10101000",2)  int("00100000",2) 
dev.SetWireInValue(0x02, SubRegisterAddress) 
initializeRegisterValues = int("10010111",2)
dev.SetWireInValue(0x03, initializeRegisterValues) 
initializeRegisterAddress = int("00100000",2)
dev.SetWireInValue(0x04, initializeRegisterAddress) 
PC_Control = 1; # send a "go" signal to the FSM
dev.SetWireInValue(0x07, PC_Control) 
dev.UpdateWireIns()
PC_Control = 0; # send a "stop" signal to the FSM
dev.SetWireInValue(0x07, PC_Control) 
dev.UpdateWireIns()  # Update the WireIns
 
dev.SetWireInValue(0x00, 1); #Reset FIFOs and counter
dev.UpdateWireIns();  # Update the WireIns
dev.SetWireInValue(0x00, 0); #Release reset signal
dev.UpdateWireIns();  # Update the WireIns
dev.ReadFromBlockPipeOut(0xa0, 1024, buf);  # Read data from BT PipeOut
image[0:488*646] = buf[0:488*646]

#im_array = np.array(buf[0:488*646]).reshape(pix2, pix1)
im_array = np.array(image).reshape(pix2, pix1)  # Reshape array into a 2D array like image   #np.max(image)
im_array1 = im_array.astype(np.uint8)


#cv2.imshow('gray image',im_array1) #,origin='lower')    
#cv2.waitKey(1)
bbox = cv2.selectROI(im_array1,False)
tracker = cv2.legacy.TrackerMOSSE_create()
tracker.init(im_array1,bbox)    

    
 #%%   
 

def acquire_image():
    
        global img1,im_array1,tracker,ok,bbox
        
        image = np.zeros(488*648)
        pix1 = 648;
        pix2 = 488;


        while True: 
            with threading.Lock(): #while True:
               
                a = time.time()
                dev.SetWireInValue(0x00, 1); #Reset FIFOs and counter
                dev.UpdateWireIns();  # Update the WireIns
                dev.SetWireInValue(0x00, 0); #Release reset signal
                dev.UpdateWireIns();  # Update the WireIns
                dev.ReadFromBlockPipeOut(0xa0, 1024, buf);  # Read data from BT PipeOut
                image[0:488*646] = buf[0:488*646]
                
                #im_array = np.array(buf[0:488*646]).reshape(pix2, pix1)
                im_array = np.array(image).reshape(pix2, pix1)  # Reshape array into a 2D array like image
                im_array1 = im_array.astype(np.uint8)
                

                # update tracker 
                ok,bbox = tracker.update(im_array1)
                
        
                if ok:    
                    ## calculate the center of the object 
                    center0 = int(bbox[2]/2+bbox[0])
                    center1 = int(bbox[3]/2+bbox[1])
                    
                    print('----------', center0,center1) 
    
                    # each time, when doing rotation, re-initialize frame0
                    # print('Max difference value   ',np.max(diff))
                    block_size = 40
                    if  center0 > 324+block_size:  #648/2  center_of_mass[1]
                        print("----------------------------------------------------")
                        print("rotate clockwise")
                        dev.SetWireInValue(0x07, 1) 
                        dev.SetWireInValue(0x05, int(abs(center0/324-1)*30))  #  int(abs(center0/324-1)*3)+
                        dev.SetWireInValue(0x06, 0) 
                        dev.UpdateWireIns()
                        
                        time.sleep(0.001)
                        dev.SetWireInValue(0x07, 0) 
                        dev.UpdateWireIns()
                        print('Cycles',int(abs(center0/324-1)*30))
                        
                        #img1[:,:,0] = 0;
                    elif (center0  > 0) and (center0 < 324-block_size):  #center_of_mass[1]
                        print("----------------------------------------------------")
                        print("rotate counter-clockwise")
                        dev.SetWireInValue(0x07, 1) 
                        dev.SetWireInValue(0x05, int(abs(center0/324-1)*30))  # int(abs(center0/324-1)*3)+
                        dev.SetWireInValue(0x06, 1) 
                        dev.UpdateWireIns()
                        time.sleep(0.001)
                        dev.SetWireInValue(0x07, 0) 
                        dev.UpdateWireIns()
                        print('Cycles     ',int(abs(center0/324-1)*30))
                        #img1[:,:,0] = 0; 
                
                ##########################################################
                for jj in range(5):
                    
                    #a = time.time()
                    #time.sleep(0.000001)
                    #ACC XCORD     
                    dev.SetWireInValue(0x01, int("00110010",2)) 
                    dev.SetWireInValue(0x02, int("10101000",2)) 
                    dev.SetWireInValue(0x07, 1) 
                    dev.UpdateWireIns()
                    dev.SetWireInValue(0x07, 0) 
                    dev.UpdateWireIns()  # Update the WireIns
                    
                    # Since we are using a slow clock on the FPGA to compute the results
                    # we need to wait for the result to be computed
                    #time.sleep(0.000001)
                    dev.UpdateWireOuts() 
                    X_ACC = dev.GetWireOutValue(0x20)
                    bin_ = '{0:016b}'.format(X_ACC)
                    X_Decimal_ACL = twos_comp(int(float(((int(bin_[-8:],2)<<8) + int(bin_[:8],2)))), 16)/26000*1.8; 
                    
                
                    SubRegisterAddress = int("10101010",2)         
                    dev.SetWireInValue(0x02, SubRegisterAddress) 
                    PC_Control = 1; # send a "go" signal to the FSM
                    dev.SetWireInValue(0x07, PC_Control) 
                    dev.UpdateWireIns()
                    PC_Control = 0; # send a "stop" signal to the FSM
                    dev.SetWireInValue(0x07, PC_Control) 
                    dev.UpdateWireIns()  # Update the WireIns
                    
                    dev.UpdateWireOuts() 
                    Y_ACC = dev.GetWireOutValue(0x20)
                    bin_ = '{0:016b}'.format(Y_ACC)
                    Y_Decimal_ACL = twos_comp(int(float(((int(bin_[-8:],2)<<8) + int(bin_[:8],2)))), 16)/26000*1.8; #= twos_comp(int(float(((MSB<<8) + LSB))), 16)/26000; 
                    
                    
                    #time.sleep(0.000001)
                    #Z Cord ACCL 
                    SubRegisterAddress = int("10101100",2)         
                    dev.SetWireInValue(0x02, SubRegisterAddress) 
                    PC_Control = 1; # send a "go" signal to the FSM
                    dev.SetWireInValue(0x07, PC_Control) 
                    dev.UpdateWireIns()
                    PC_Control = 0; # send a "stop" signal to the FSM
                    dev.SetWireInValue(0x07, PC_Control) 
                    dev.UpdateWireIns()  # Update the WireIns
                                 
                    dev.UpdateWireOuts() 
                    Z_ACC = dev.GetWireOutValue(0x20)
                    bin_ = '{0:016b}'.format(Z_ACC)
                    Z_Decimal_ACL = twos_comp(int(float(((int(bin_[-8:],2)<<8) + int(bin_[:8],2)))), 16)/26000*1.8; #twos_comp(int(float(((MSB<<8) + LSB))), 16)/26000; 
                    
                    print("XYZ axis of Acclerator (g):  %s %s %s" % (X_Decimal_ACL,Y_Decimal_ACL,Z_Decimal_ACL))
                    
                b = time.time()
                print('Image acquisition Frame rate',1/(b-a))
                ###########################################################
                
                time.sleep(0.0001)
            
def display_image():
    global im_array1,ok,bbox
    
    image = np.zeros(488*648)
    pix1 = 648;
    pix2 = 488;


    while True: 
        with threading.Lock():
    
            a = time.time()
            
            if im_array1 is not None:
                
                if ok:
                    p1 = (int(bbox[0]),int(bbox[1]))
                    p2 = (int(bbox[0]+bbox[2]),int(bbox[1]+bbox[3]))
                    cv2.rectangle(im_array1,p1,p2,(255,255,0),2)  
                    
                cv2.imshow('gray image',im_array1) #,origin='lower')    
                cv2.waitKey(1)
                time.sleep(0.035)
                b = time.time()
                
                print('Time Frame rate',1/(b-a))
       
         
acq_thred = threading.Thread(target=acquire_image)
display_thred = threading.Thread(target=display_image)
 

acq_thred.start() 
display_thred.start() 
 
       
