# -*- coding: utf-8 -*-
"""
Created on Mon Oct 23 16:50:33 2023

@author: zinovya2
"""

#%%
# import various libraries necessary to run your Python code
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


power_supply_id = -1;
waveform_generator_id = -1;
digital_multimeter_id = -1;
oscilloscope_id = -1;


#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("") 
ConfigStatus=dev.ConfigureFPGA("U:\\ece437\\test0\\CORRECTLABS\\lab9\\lab9.runs\\impl_1\\BTPipeExample.bit");



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


#%% 
# Define the two variables that will send data to the FPGA
# We will use WireIn instructions to send data to the FPGA

def twos_comp(val, bits):
    """compute the 2's complement of int value val"""
    if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)        # compute negative value
    return val                         # return positive value as is

 


measured_X_ACC = np.array([]) # create an empty list to hold our values
measured_Y_ACC = np.array([]) # create an empty list to hold our values
measured_Z_ACC = np.array([]) # create an empty list to hold our values


##################################################################################################
        
print("Start recording.")


cycles = 1
direction = 0  # toward to rod, clockwise 
#direction = 1 # counter-clockwise 

PC_Control = 0; # send a "stop" signal to the FSM
dev.SetWireInValue(0x07, PC_Control) 
time.sleep(1)

 

bit_num = 315392;
buf = bytearray(bit_num);   # 648*488     
buf1 = bytearray(bit_num);   # 648*488  
buf2 = bytearray(bit_num);   # 648*488  

img_final = np.zeros([488,648,100]);
image = np.zeros(488*648)
pix1 = 648;
pix2 = 488;

img1 = np.zeros([488,648,2]);
img1[:,:,0] =1;
img1[:,:,1] =1;

rotate_flag = 1;

for i in range(1):
    
    a = time.time()
    
    dev.SetWireInValue(0x00, 1); #Reset FIFOs and counter
    dev.UpdateWireIns();  # Update the WireIns
    dev.SetWireInValue(0x00, 0); #Release reset signal
    dev.UpdateWireIns();  # Update the WireIns
    dev.ReadFromBlockPipeOut(0xa0, 1024, buf);  # Read data from BT PipeOut
    image[0:488*646] = buf[0:488*646]
    
    #im_array = np.array(buf[0:488*646]).reshape(pix2, pix1)
    im_array = np.array(image).reshape(pix2, pix1)  # Reshape array into a 2D array like image   #np.max(image)
    im_array1 = im_array.astype(np.uint8)
    
    #img_final[:,:,i+1] = im_array*np.max(image)
    img1[:,:,1] = im_array 
    
    b = time.time()
    print('Image acquisition Frame rate',1/(b-a))
    
    
    img1[:,:,0] = img1[:,:,1]
    
    cv2.imshow('gray image',im_array1) #,origin='lower')    
    cv2.waitKey(1)
    # b = time.time()
    #print('Time',1/(b-a))

    bbox = cv2.selectROI(im_array1,False)
    tracker = cv2.legacy.TrackerMOSSE_create()
    tracker.init(im_array1,bbox)   #
    

for i in range(100000):
    
    
    
    dev.SetWireInValue(0x00, 1); #Reset FIFOs and counter
    dev.UpdateWireIns();  # Update the WireIns
    dev.SetWireInValue(0x00, 0); #Release reset signal
    dev.UpdateWireIns();  # Update the WireIns
    dev.ReadFromBlockPipeOut(0xa0, 1024, buf);  # Read data from BT PipeOut
    
   
    
    image[0:488*646] = buf[0:488*646]
    
    #im_array = np.array(buf[0:488*646]).reshape(pix2, pix1)
    im_array = np.array(image).reshape(pix2, pix1)  # Reshape array into a 2D array like image   #np.max(image)
    im_array1 = im_array.astype(np.uint8)
    
    
   

    a = time.time()
    # update tracker 
    ok,bbox = tracker.update(im_array1)
    

    if ok:
        p1 = (int(bbox[0]),int(bbox[1]))
        p2 = (int(bbox[0]+bbox[2]),int(bbox[1]+bbox[3]))
        cv2.rectangle(im_array1,p1,p2,(255,255,0),2)  
    cv2.imshow('gray image',im_array1) #,origin='lower')    
    cv2.waitKey(1)
    
    b = time.time()
    print('Image acquisition Frame rate',1/(b-a))

    if ok:    
        ## calculate the center of the object 
        center0 = int(bbox[2]/2+bbox[0])
        center1 = int(bbox[3]/2+bbox[1])
        
        print('----------', center0,center1) 
    
        
        # each time, when doing rotation, re-initialize frame0
        # print('Max difference value   ',np.max(diff))
        if  center0 > 324:  #648/2  center_of_mass[1]
            print("----------------------------------------------------")
            print("rotate clockwise")
            dev.SetWireInValue(0x07, 1) 
            dev.SetWireInValue(0x05, 10)  #  int(abs(center0/324-1)*3)+
            dev.SetWireInValue(0x06, 0) 
            dev.UpdateWireIns()
            
            time.sleep(0.001)
            dev.SetWireInValue(0x07, 0) 
            dev.UpdateWireIns()
            print('Cycles    ',10)
            
            #img1[:,:,0] = 0;
        elif (center0  > 0) and (center0 < 324):  #center_of_mass[1]
            print("----------------------------------------------------")
            print("rotate counter-clockwise")
            dev.SetWireInValue(0x07, 1) 
            dev.SetWireInValue(0x05, 10)  # int(abs(center0/324-1)*3)+
            dev.SetWireInValue(0x06, 1) 
            dev.UpdateWireIns()
            time.sleep(0.001)
            dev.SetWireInValue(0x07, 0) 
            dev.UpdateWireIns()
            print('Cycles    ',10)
            #img1[:,:,0] = 0;
            
    
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
        
    ###########################################################
    
    c= time.time()
    #print('Acceleration frame rate',1/(c-b))
    print('Total frame rate',1/(c-a))
            



#%% 

##################################################################################################
 

##################################################################################################

   
    
#print(power_supply.write("OUTPUT OFF"))
#power_supply.close()

PC_Control = 0; # send a "stop" signal to the FSM
dev.SetWireInValue(0x07, PC_Control) 
dev.UpdateWireIns()  # Update the WireIns
dev.Close


'''
## plot ACC vs voltage 
voltage_list=np.zeros(np.size(output_voltage))
for i in range(len(measured_voltage)):
    voltage_list[i]= float(measured_voltage [i])


X_ACC_Max_list = np.zeros(np.size(output_voltage))
Y_ACC_Max_list = np.zeros(np.size(output_voltage))
Z_ACC_Max_list = np.zeros(np.size(output_voltage))
X_ACC_Mean_list = np.zeros(np.size(output_voltage))
Y_ACC_Mean_list = np.zeros(np.size(output_voltage))
Z_ACC_Mean_list = np.zeros(np.size(output_voltage))
for i in range(len(measured_voltage)):
    X_ACC_Max_list[i]= np.max(measured_X_ACC[0+i*10:9+i*10])
    Y_ACC_Max_list[i]= np.max(measured_Y_ACC[0+i*10:9+i*10])
    Z_ACC_Max_list[i]= np.max(measured_Z_ACC[0+i*10:9+i*10])
    X_ACC_Mean_list[i]= np.mean(measured_X_ACC[0+i*10:9+i*10])
    Y_ACC_Mean_list[i]= np.mean(measured_Y_ACC[0+i*10:9+i*10])
    Z_ACC_Mean_list[i]= np.mean(measured_Z_ACC[0+i*10:9+i*10])
'''   
        

for i in range(50):
    fig = plt.figure()
    plt.imshow(img_final[:,:,i], cmap='gray') #,origin='lower')    
    plt.title(i)   
    plt.pause(0.2)
    #plt.figure().clear()
    
    





    
