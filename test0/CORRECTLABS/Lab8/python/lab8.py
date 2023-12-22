# -*- coding: utf-8 -*-
"""
Created on Thu Oct 26 17:38:14 2023

@author: zinovya2
"""

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
ConfigStatus=dev.ConfigureFPGA("U:\ece437\CORRECTLABS\Lab8\Lab8.runs\impl_1\JTEG_Test_File.bit");

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
    
    
    
    
  
   
arradd = [57, 58, 59, 60, 68, 69, 80, 83, 117, 97, 98, 100, 101,102, 103, 106, 107, 108, 109, 110, 55, 56, 42, 43, 44]          # for 10ms 42:1 43:3 44:0    # for 1ms 42:77 43:0 44:0
valadd = [3, 44, 240, 10, 1, 9, 2, 187, 91, 240, 10, 112, 98, 34 ,64, 94, 110, 91, 82, 80, 1, 0, 1, 3, 0]                                   
 
for i in range(len(arradd)):
        
        RegAddress = arradd[i] + 128
        dev.SetWireInValue(0x01, RegAddress) 
        Value = valadd[i]
        dev.SetWireInValue(0x02, Value) 
        PC_Control = 1;
        dev.SetWireInValue(0x00, PC_Control) 
        dev.UpdateWireIns()
        
        time.sleep(0.2)
    
        PC_Control = 0; # send a "stop" signal to the FSM
        dev.SetWireInValue(0x00, PC_Control) 
        dev.UpdateWireIns()  # Update the WireI
        
        RegAddress = arradd[i]
        dev.SetWireInValue(0x01, RegAddress) 
        PC_Control = 1;
        dev.SetWireInValue(0x00, PC_Control) 
        dev.UpdateWireIns()
        time.sleep(0.2)
        dev.UpdateWireOuts()
        Vl = dev.GetWireOutValue(0x20)
        
        PC_Control = 0; # send a "stop" signal to the FSM
        dev.SetWireInValue(0x00, PC_Control) 
        dev.UpdateWireIns()  # Update the WireIns
        
        time.sleep(0.2)
        print("REG: %s has Value %s" % (arradd[i],Vl ) )
        
        

dev.Close
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    