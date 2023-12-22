# -*- coding: utf-8 -*-
"""
Created on Sat Oct 21 15:56:00 2023

@author: zinovya2
"""

# -*- coding: utf-8 -*-


# -*- coding: utf-8 -*-

#%%
# import various libraries necessary to run your Python code
import time   # time related library
import sys,os    # system related library
ok_sdk_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\x64"
ok_dll_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\lib\\x64"

sys.path.append(ok_sdk_loc)   # add the path of the OK library
os.add_dll_directory(ok_dll_loc)

import ok     # OpalKelly library
#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("") 

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





for i in range(1000):

    #ACC XCORD     
    
    
    PC_Control = 1; # send a "stop" signal to the FSM
    dev.SetWireInValue(0x00, PC_Control) 
        
    cycles = 255
    direction = 0
    dev.SetWireInValue(0x05, cycles) 
    dev.SetWireInValue(0x06, direction) 
    DeviceAddress = int("00110010",2)
    dev.SetWireInValue(0x01, DeviceAddress) 
    SubRegisterAddress = int("10101000",2)         #("10101000",2)  int("00100000",2) 
    dev.SetWireInValue(0x02, SubRegisterAddress) 
    initializeRegisterValues = int("10010111",2)
    dev.SetWireInValue(0x03, initializeRegisterValues) 
    initializeRegisterAddress = int("00100000",2)
    dev.SetWireInValue(0x04, initializeRegisterAddress) 
    dev.UpdateWireIns()
    
   
    
    
    

    
    
    
PC_Control = 0; # send a "stop" signal to the FSM
dev.SetWireInValue(0x00, PC_Control) 
dev.UpdateWireIns()  # Update the WireIns
    
     
dev.Close



