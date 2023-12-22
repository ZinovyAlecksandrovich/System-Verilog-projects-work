#%% 

# analysis data 


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

measured_X_ACC = np.array([]) # create an empty list to hold our values
measured_Y_ACC = np.array([]) # create an empty list to hold our values
measured_Z_ACC = np.array([]) # create an empty list to hold our values



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


for i in range(100):
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
        
        measured_X_ACC = np.append(measured_X_ACC, X_Decimal_ACL)  # save ACC values
        measured_Y_ACC = np.append(measured_Y_ACC, Y_Decimal_ACL)
        measured_Z_ACC = np.append(measured_Z_ACC, Z_Decimal_ACL)

###########################################################              
        
 
plt.plot(measured_X_ACC)
std0 = np.std(measured_X_ACC)
mean0 = np.mean(measured_X_ACC)

snr0 = 20*np.log10(mean0/std0)


plt.plot(measured_Y_ACC)
np.std(measured_Y_ACC)

plt.plot(measured_Z_ACC)
np.std(measured_Z_ACC)


np.save('dataX.npy',measured_X_ACC)

np.save('dataY.npy',measured_Y_ACC)

np.save('dataZ.npy',measured_Z_ACC)
