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


for i in range(10):
    dev.SetWireInValue(0x07, 1) 
    dev.SetWireInValue(0x05, 50)  
    dev.SetWireInValue(0x06, 1) 
    dev.UpdateWireIns()
    time.sleep(0.001)
    dev.SetWireInValue(0x07, 0) 
    dev.UpdateWireIns()
    print(i)
    time.sleep(1)
    #dev.SetWireInValue(0x07, 0) 
    #dev.SetWireInValue(0x05, 0)  
    #dev.SetWireInValue(0x06, 0) 
    #dev.UpdateWireIns()
    #time.sleep(0.01)