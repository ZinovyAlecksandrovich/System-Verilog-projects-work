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


for i in range(100):

    

    cycles = 100
    direction = 0
    dev.SetWireInValue(0x05, cycles) 
    dev.SetWireInValue(0x06, direction) 
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
    dev.SetWireInValue(0x00, PC_Control) 
    dev.UpdateWireIns()
    
    # Since we are using a slow clock on the FPGA to compute the results
    # we need to wait for the result to be computed
               
    dev.UpdateWireOuts() 
    X_ACC = dev.GetWireOutValue(0x20)
    bin_ = '{0:016b}'.format(X_ACC)
    LSB = bin_[:8]
    MSB = bin_[-8:]
    MSB = int(MSB,2)
    LSB = int(LSB,2)
    X_Decimal_ACL = twos_comp(int(float(((MSB<<8) + LSB))), 16)/26000; 
    
    PC_Control = 0; # send a "stop" signal to the FSM
    dev.SetWireInValue(0x00, PC_Control) 
    dev.UpdateWireIns()  # Update the WireIns

    time.sleep(0.1)
    #ACC YCORD
    DeviceAddress = int("00110010",2)
    dev.SetWireInValue(0x01, DeviceAddress) 
    SubRegisterAddress = int("10101010",2)         
    dev.SetWireInValue(0x02, SubRegisterAddress) 
    initializeRegisterValues = int("10010111",2)
    dev.SetWireInValue(0x03, initializeRegisterValues) 
    initializeRegisterAddress = int("00100000",2)
    dev.SetWireInValue(0x04, initializeRegisterAddress) 
    PC_Control = 1; # send a "go" signal to the FSM
    dev.SetWireInValue(0x00, PC_Control) 
    dev.UpdateWireIns()
    
                
    dev.UpdateWireOuts() 
    Y_ACC = dev.GetWireOutValue(0x20)
    bin_ = '{0:016b}'.format(Y_ACC)
    LSB = bin_[:8]
    MSB = bin_[-8:]
    MSB = int(MSB,2)
    LSB = int(LSB,2)
    Y_Decimal_ACL = twos_comp(int(float(((MSB<<8) + LSB))), 16)/26000; 
    
    PC_Control = 0; # send a "stop" signal to the FSM
    dev.SetWireInValue(0x00, PC_Control) 
    dev.UpdateWireIns()  # Update the WireIns
    
    time.sleep(0.1)
    #Z Cord ACCL 
    DeviceAddress = int("00110010",2)
    dev.SetWireInValue(0x01, DeviceAddress) 
    SubRegisterAddress = int("10101100",2)         
    dev.SetWireInValue(0x02, SubRegisterAddress) 
    initializeRegisterValues = int("10010111",2)
    dev.SetWireInValue(0x03, initializeRegisterValues) 
    initializeRegisterAddress = int("00100000",2)
    dev.SetWireInValue(0x04, initializeRegisterAddress) 
    PC_Control = 1; # send a "go" signal to the FSM
    dev.SetWireInValue(0x00, PC_Control) 
    dev.UpdateWireIns()
    
                 
    dev.UpdateWireOuts() 
    Z_ACC = dev.GetWireOutValue(0x20)
    bin_ = '{0:016b}'.format(Z_ACC)
    LSB = bin_[:8]
    MSB = bin_[-8:]
    MSB = int(MSB,2)
    LSB = int(LSB,2)
    Z_Decimal_ACL = twos_comp(int(float(((MSB<<8) + LSB))), 16)/26000; 
    
    PC_Control = 0; # send a "stop" signal to the FSM
    dev.SetWireInValue(0x00, PC_Control) 
    dev.UpdateWireIns()  # Update the WireIns

    print("XYZ axis of Acclerator (g):  %s %s %s" % (X_Decimal_ACL,Y_Decimal_ACL,Z_Decimal_ACL))
    
    ########################################
    # X cord of Magnet
    DeviceAddress = int("00111100",2)
    dev.SetWireInValue(0x01, DeviceAddress) 
    SubRegisterAddress = int("00000011",2)         #("00000011",2)  int("00100000",2) 
    dev.SetWireInValue(0x02, SubRegisterAddress) 
    initializeRegisterValues = int("00000001",2)
    dev.SetWireInValue(0x03, initializeRegisterValues) 
    initializeRegisterAddress = int("00000010",2)
    dev.SetWireInValue(0x04, initializeRegisterAddress) 
    PC_Control = 1; # send a "go" signal to the FSM
    dev.SetWireInValue(0x00, PC_Control) 
    dev.UpdateWireIns()

               
    dev.UpdateWireOuts() 
    X_MAG = dev.GetWireOutValue(0x20)
    bin_ = '{0:016b}'.format(X_MAG)
    MSB = bin_[:8]
    LSB = bin_[-8:]
    MSB = int(MSB,2)
    LSB = int(LSB,2)
    X_Decimal_MAG = twos_comp(int(float(((MSB<<8) + LSB))), 16)/1100;

    PC_Control = 0; # send a "stop" signal to the FSM
    dev.SetWireInValue(0x00, PC_Control) 
    dev.UpdateWireIns()  # Update the WireIns
    

    #Ycord of Mag
    DeviceAddress = int("00111100",2)
    dev.SetWireInValue(0x01, DeviceAddress) 
    SubRegisterAddress = int("00000111",2)         #("10101000",2)  int("00100000",2) 
    dev.SetWireInValue(0x02, SubRegisterAddress) 
    initializeRegisterValues = int("00000000",2)
    dev.SetWireInValue(0x03, initializeRegisterValues) 
    initializeRegisterAddress = int("00000010",2)
    dev.SetWireInValue(0x04, initializeRegisterAddress) 
    dev.UpdateWireIns()  # Update the WireIns
    PC_Control = 1; # send a "go" signal to the FSM
    dev.SetWireInValue(0x00, PC_Control) 
    dev.UpdateWireIns()
    
             
    dev.UpdateWireOuts() 
    Y_MAG = dev.GetWireOutValue(0x20)
    bin_ = '{0:016b}'.format(Y_MAG)
    MSB = bin_[:8]
    LSB = bin_[-8:]
    MSB = int(MSB,2)
    LSB = int(LSB,2)
    Y_Decimal_MAG = twos_comp(int(float(((MSB<<8) + LSB))), 16)/1100; 
    
    PC_Control = 0; # send a "stop" signal to the FSM
    dev.SetWireInValue(0x00, PC_Control) 
    dev.UpdateWireIns()  # Update the WireIns
    
    
    #Zcord of Mag
    DeviceAddress = int("00111100",2)
    dev.SetWireInValue(0x01, DeviceAddress) 
    SubRegisterAddress = int("00000101",2)         #("10101000",2)  int("00100000",2) 
    dev.SetWireInValue(0x02, SubRegisterAddress) 
    initializeRegisterValues = int("00000000",2)
    dev.SetWireInValue(0x03, initializeRegisterValues) 
    initializeRegisterAddress = int("00000010",2)
    dev.SetWireInValue(0x04, initializeRegisterAddress) 
    PC_Control = 1; # send a "go" signal to the FSM
    dev.SetWireInValue(0x00, PC_Control) 
    dev.UpdateWireIns()  # Update the WireIns
    
             
    dev.UpdateWireOuts() 
    Z_MAG = dev.GetWireOutValue(0x20)
    bin_ = '{0:016b}'.format(Z_MAG)
    MSB = bin_[:8]
    LSB = bin_[-8:]
    MSB = int(MSB,2)
    LSB = int(LSB,2)
    Z_Decimal_MAG = twos_comp(int(float(((MSB<<8) + LSB))), 16)/980;  
    
    PC_Control = 0; # send a "stop" signal to the FSM
    dev.SetWireInValue(0x00, PC_Control) 
    dev.UpdateWireIns()  # Update the WireIns

    print("XYZ axis of Magnet (gauss):  %s %s %s" % (X_Decimal_MAG,Y_Decimal_MAG,Z_Decimal_MAG))

PC_Control = 0; # send a "stop" signal to the FSM
dev.SetWireInValue(0x00, PC_Control) 
dev.UpdateWireIns()  # Update the WireIns
    
     
dev.Close
