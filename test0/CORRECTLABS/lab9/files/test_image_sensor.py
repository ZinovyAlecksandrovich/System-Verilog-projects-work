# -*- coding: utf-8 -*-
"""
Created on Mon Dec 11 15:00:44 2023

@author: zinovya2
"""

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



##################################################################################################
        
print("Start recording.")


cycles = 5
direction = 0  # toward to rod, clockwise 
#direction = 1 # counter-clockwise 

PC_Control = 0; # send a "stop" signal to the FSM
dev.SetWireInValue(0x07, PC_Control) 
dev.UpdateWireIns()  # Update the WireIns
time.sleep(1)


bit_num = 315392;
buf = bytearray(bit_num);   # 648*488     
 

img_final = np.zeros([488,648,100]);
image = np.zeros(488*648)
pix1 = 648;
pix2 = 488;

img1 = np.zeros([488,648,2]);
img1[:,:,0] =1;
img1[:,:,1] =1;

rotate_flag = 1;

for i in range(100):
    
    a = time.time()
    
    dev.SetWireInValue(0x00, 1); #Reset FIFOs and counter
    dev.UpdateWireIns();  # Update the WireIns
    dev.SetWireInValue(0x00, 0); #Release reset signal
    dev.UpdateWireIns();  # Update the WireIns
    dev.ReadFromBlockPipeOut(0xa0, 1024, buf);  # Read data from BT PipeOut
    image[0:488*646] = buf[0:488*646]
    
    #im_array = np.array(buf[0:488*646]).reshape(pix2, pix1)
    im_array = np.array(image/np.max(image)).reshape(pix2, pix1)  # Reshape array into a 2D array like image   #np.max(image)
    
    
    img_final[:,:,i] = im_array*np.max(image)
   
    b = time.time()
    print('Image acquisition Frame rate',1/(b-a))
    
    cv2.imshow('gray image',im_array) #,origin='lower')    
    cv2.waitKey(1)
    # b = time.time()
    #print('Time',1/(b-a))
    
    
   
    



#%% 

##################################################################################################
 

##################################################################################################

   
    
#print(power_supply.write("OUTPUT OFF"))
#power_supply.close()

PC_Control = 0; # send a "stop" signal to the FSM
dev.SetWireInValue(0x07, PC_Control) 
dev.UpdateWireIns()  # Update the WireIns
dev.Close



for i in range(10):
    fig = plt.figure()
    plt.imshow(img_final[:,:,i], cmap='gray') #,origin='lower')    
    plt.title(i)   
    plt.grid(False)
    plt.pause(0.2)
    
    #plt.figure().clear()
    
    
np.save('img_data.npy',img_final)

#np.save('noise_data.npy',img_final)
np.mean(img_final[:,:,50])


snr0 = 20*np.log10(81.8335/0.9783510106759765)


img_final = np.load('img_data.npy')

img_final = np.load('noise_data.npy')
