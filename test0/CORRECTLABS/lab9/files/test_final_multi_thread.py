 
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

cycles = 3
direction = 0  # toward to rod, clockwise 
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
#img1[:,:,0] =1;
#img1[:,:,1] =1;

im_array = None;
center_of_mass = None;

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
 
 

def acquire_image():
        global img1,im_array,center_of_mass
        
        image = np.zeros(488*648)
        pix1 = 648;
        pix2 = 488;
        img1 = np.zeros([488,648,2]);
        #img1[:,:,0] =1;
        #img1[:,:,1] =1;
        
        cycles = 25
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
                im_array = np.array(image/np.max(image)).reshape(pix2, pix1)  # Reshape array into a 2D array like image
                
                #img_final[:,:,i+1] = im_array*np.max(image)
                img1[:,:,1] = im_array*np.max(image)
                
                threshold_value = 40
                frame = img1[:,:,1]
                frame_prev = img1[:,:,0]
                # Compute the difference between consecutive frames
                diff = frame-frame_prev  #cv2.absdiff(frame, frame_prev)
                diff1 = np.where(diff<threshold_value,0,diff)
                
                center_of_mass = np.nan_to_num(ndimage.center_of_mass(diff1),nan=0)  # y and x 
                img1[:,:,0] = img1[:,:,1]
                
                print('Max value   ',np.max(diff))
                #if center_of_mass is not None:
                # each time, when doing rotation, re-initialize frame0
                if center_of_mass[1] > 324:  #648/2
                    print("----------------------------------------------------")
                    print("rotate clockwise")
                    dev.SetWireInValue(0x07, 1) 
                    dev.SetWireInValue(0x05, cycles) 
                    dev.SetWireInValue(0x06, 0) 
                    dev.UpdateWireIns()
                    
                    time.sleep(0.001)
                    dev.SetWireInValue(0x07, 0) 
                    
                    #img1[:,:,0] = 0;
                elif center_of_mass[1] > 0:
                    print("----------------------------------------------------")
                    print("rotate counter-clockwise")
                    dev.SetWireInValue(0x07, 1) 
                    dev.SetWireInValue(0x05, cycles) 
                    dev.SetWireInValue(0x06, 1) 
                    dev.UpdateWireIns()
                    
                    time.sleep(0.001)
                    dev.SetWireInValue(0x07, 0) 
                    #img1[:,:,0] = 0;
                    #print("not moving")   
                else:
                    print("----------------------------------------------------")
                    print("not moving")   
                
                #a = time.time()
                ##########################################################
                for jj in range(5):
                    
                    #a = time.time()
                    #time.sleep(0.000001)
                    #ACC XCORD     
                    DeviceAddress = int("00110010",2)
                    dev.SetWireInValue(0x01, DeviceAddress) 
                    SubRegisterAddress = int("10101000",2)         #("10101000",2)  int("00100000",2) 
                    dev.SetWireInValue(0x02, SubRegisterAddress) 
                    PC_Control = 1; # send a "go" signal to the FSM
                    dev.SetWireInValue(0x07, PC_Control) 
                    dev.UpdateWireIns()
                    PC_Control = 0; # send a "stop" signal to the FSM
                    dev.SetWireInValue(0x07, PC_Control) 
                    dev.UpdateWireIns()  # Update the WireIns
                    
                    # Since we are using a slow clock on the FPGA to compute the results
                    # we need to wait for the result to be computed
                    #time.sleep(0.000001)
                    dev.UpdateWireOuts() 
                    X_ACC = dev.GetWireOutValue(0x20)
                    bin_ = '{0:016b}'.format(X_ACC)
                    #LSB = bin_[:8]
                    #MSB = bin_[-8:]
                    #MSB = int(MSB,2)
                    #LSB = int(LSB,2)
                    X_Decimal_ACL = twos_comp(int(float(((int(bin_[-8:],2)<<8) + int(bin_[:8],2)))), 16)/26000; 
                    
                
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
                    #LSB = bin_[:8]
                    #MSB = bin_[-8:]
                    #MSB = int(MSB,2)
                    #LSB = int(LSB,2)
                    Y_Decimal_ACL = twos_comp(int(float(((int(bin_[-8:],2)<<8) + int(bin_[:8],2)))), 16)/26000; #= twos_comp(int(float(((MSB<<8) + LSB))), 16)/26000; 
                    
                    
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
                    Z_Decimal_ACL = twos_comp(int(float(((int(bin_[-8:],2)<<8) + int(bin_[:8],2)))), 16)/26000; #twos_comp(int(float(((MSB<<8) + LSB))), 16)/26000; 
                    
                    
                    print("XYZ axis of Acclerator (g):  %s %s %s" % (X_Decimal_ACL,Y_Decimal_ACL,Z_Decimal_ACL))
                    
                b = time.time()
                print('Image acquisition Frame rate',1/(b-a))
                ###########################################################
                
                time.sleep(0.0001)
            
def display_image():
    global im_array,img1,center_of_mass
   
    while True: 
        with threading.Lock():
    
            a = time.time()
            threshold_value = 60
            cycles = 3
            
            if im_array is not None:
                frame = img1[:,:,1]
                frame_prev = img1[:,:,0]
                
                # Compute the difference between consecutive frames
                diff = frame-frame_prev  #cv2.absdiff(frame, frame_prev)
                diff1 = np.where(diff<threshold_value,0,diff)
                
                center_of_mass0 = np.nan_to_num(ndimage.center_of_mass(diff1),nan=0)  # y and x 
                #img1[:,:,0] = img1[:,:,1]
                
                point= (int(center_of_mass0[1]),int(center_of_mass0[0]))
                cv2.circle(im_array,point,10,(255,255,0),-1)
                cv2.imshow('gray image',im_array) #,origin='lower')    
                cv2.waitKey(1)
                time.sleep(0.035)
                b = time.time()
                
                #bbox = cv2.selectROI(im_array,False)
                #tracker = cv2.TrackerKCF_create()
                #tracker.init(im_array,bbox)
                
                # update tracker 
                #ok,bbox = tracker.update(im_array)
                
                #if ok:
                #    p1 = (int(bbox[0]),int(bbox[1]))
                #    p2 = (int(bbox[0]+bbox[2]),int(bbox[1]+bbox[3]))
                #    cv2.rectangle(im_array,p1,p2,(255,255,0),2)
                
                print('Time',1/(b-a))
                #print(point)
            
       
         
acq_thred = threading.Thread(target=acquire_image)
display_thred = threading.Thread(target=display_image)
 

acq_thred.start() 
display_thred.start() 
 
       
