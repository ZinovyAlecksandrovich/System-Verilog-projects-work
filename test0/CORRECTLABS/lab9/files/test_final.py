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



'''
# assumes only the DC power supply is connected
for i in range (0, number_of_device):

# check that it is actually the power supply
    try:
        device_temp = device_manager.open_resource(devices[i])
        print("Instrument connect on USB port number [" + str(i) + "] is " + device_temp.query("*IDN?"))
        if (device_temp.query("*IDN?") == 'HEWLETT-PACKARD,E3631A,0,3.2-6.0-2.0\r\n'):
            power_supply_id = i        
        if (device_temp.query("*IDN?") == 'HEWLETT-PACKARD,E3631A,0,3.0-6.0-2.0\r\n'):
            power_supply_id = i
        if (device_temp.query("*IDN?") == 'Agilent Technologies,33511B,MY52301259,3.03-1.19-2.00-52-00\n'):
            waveform_generator_id = i
        if (device_temp.query("*IDN?") == 'Agilent Technologies,34461A,MY53207920,A.01.10-02.25-01.10-00.35-01-01\n'):
            digital_multimeter_id = i 
        if (device_temp.query("*IDN?") == 'Keysight Technologies,34461A,MY53212931,A.02.08-02.37-02.08-00.49-01-01\n'):
            digital_multimeter_id = i            
        if (device_temp.query("*IDN?") == 'KEYSIGHT TECHNOLOGIES,MSO-X 3024T,MY54440319,07.50.2021102830\n'):
            oscilloscope_id = i                        
        device_temp.close()
    except:
        print("Instrument on USB port number [" + str(i) + "] cannot be connected. The instrument might be powered of or you are trying to connect to a mouse or keyboard.\n")




#%%   
if (power_supply_id == -1):
    print("Power supply instrument is not powered on or connected to the PC.")    
else:
    print("Power supply is connected to the PC.")
    power_supply = device_manager.open_resource(devices[power_supply_id]) 
    
    
    output_voltage = np.arange(0, 5.5, .5)
    measured_voltage = np.array([]) # create an empty list to hold our values

    print(power_supply.write("OUTPUT ON")) # power supply output is turned on


            
    # for v in output_voltage:
     # apply the desired voltage on teh 6V power supply and limist the output current to 0.5A
    v = 3.5
    power_supply.write("APPLy P6V, %0.2f, 0.5" % v)
 
    # pause 50ms to let things settle
    time.sleep(.8)
    
    # read the output voltage on the 6V power supply
    # measured_voltage_tmp = power_supply.query("MEASure:VOLTage:DC? P25V"
    measured_voltage_tmp = power_supply.query(":MEASure:VOLTage:DC? P6V")
    measured_voltage = np.append(measured_voltage, measured_voltage_tmp)

'''


measured_X_ACC = np.array([]) # create an empty list to hold our values
measured_Y_ACC = np.array([]) # create an empty list to hold our values
measured_Z_ACC = np.array([]) # create an empty list to hold our values


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

for i in range(100000):
    
    a = time.time()
    
    dev.SetWireInValue(0x00, 1); #Reset FIFOs and counter
    dev.UpdateWireIns();  # Update the WireIns
    dev.SetWireInValue(0x00, 0); #Release reset signal
    dev.UpdateWireIns();  # Update the WireIns
    dev.ReadFromBlockPipeOut(0xa0, 1024, buf);  # Read data from BT PipeOut
    image[0:488*646] = buf[0:488*646]
    
    #im_array = np.array(buf[0:488*646]).reshape(pix2, pix1)
    im_array = np.array(image/200).reshape(pix2, pix1)  # Reshape array into a 2D array like image   #np.max(image)
    
    
    #img_final[:,:,i+1] = im_array*np.max(image)
    img1[:,:,1] = im_array 
    
    b = time.time()
    print('Image acquisition Frame rate',1/(b-a))
    
    
    ##########################################################
    threshold_value = 0.4

    #frame = img1[:,:,1]
    #frame_prev = img1[:,:,0]
    # Compute the difference between consecutive frames
    #diff = img1[:,:,1]-img1[:,:,0]  #cv2.absdiff(frame, frame_prev)
    diff1 = np.where(img1[:,:,1]-img1[:,:,0]<threshold_value,0,img1[:,:,1]-img1[:,:,0])
    #diff2 = abs(np.where(diff<-threshold_value,0,diff))
    
    center_of_mass = np.nan_to_num(ndimage.center_of_mass(diff1),nan=0)  # y and x 
    img1[:,:,0] = img1[:,:,1]
    
    point= (int(center_of_mass[1]),int(center_of_mass[0]))
    cv2.circle(im_array,point,10,(0,255,0),-1)
    #cv2.imshow('gray image',im_array) #,origin='lower')    
    cv2.imshow('gray image',im_array) #,origin='lower')    
    cv2.waitKey(1)
    # b = time.time()
    #print('Time',1/(b-a))
    
    
    # each time, when doing rotation, re-initialize frame0
    # print('Max difference value   ',np.max(diff))
    if center_of_mass[1] > 324:  #648/2
        print("----------------------------------------------------")
        print("rotate clockwise")
        dev.SetWireInValue(0x05, cycles) 
        dev.SetWireInValue(0x06, 0) 
        dev.UpdateWireIns()
        #img1[:,:,0] = 0;
    elif center_of_mass[1] > 0:
        print("----------------------------------------------------")
        print("rotate counter-clockwise")
        dev.SetWireInValue(0x05, cycles) 
        dev.SetWireInValue(0x06, 1) 
        dev.UpdateWireIns()
        #img1[:,:,0] = 0;
    
    
    ##########################################################
    
    #dev.SetWireInValue(0x05, cycles) 
    #dev.SetWireInValue(0x06, direction) 
    
    
    ##########################################################
    for jj in range(5):
        
        #a = time.time()
        #time.sleep(0.000001)
        #ACC XCORD     
        DeviceAddress = int("00110010",2)
        dev.SetWireInValue(0x01, DeviceAddress) 
        SubRegisterAddress = int("10101000",2)         #("10101000",2)  int("00100000",2) 
        dev.SetWireInValue(0x02, SubRegisterAddress) 
        #initializeRegisterValues = int("10010111",2)
        #dev.SetWireInValue(0x03, initializeRegisterValues) 
        #initializeRegisterAddress = int("00100000",2)
        #dev.SetWireInValue(0x04, initializeRegisterAddress) 
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
        #LSB = bin_[:8]
        #MSB = bin_[-8:]
        #MSB = int(MSB,2)
        #LSB = int(LSB,2)
        Z_Decimal_ACL = twos_comp(int(float(((int(bin_[-8:],2)<<8) + int(bin_[:8],2)))), 16)/26000; #twos_comp(int(float(((MSB<<8) + LSB))), 16)/26000; 
        
        
        print("XYZ axis of Acclerator (g):  %s %s %s" % (X_Decimal_ACL,Y_Decimal_ACL,Z_Decimal_ACL))
        
    ###########################################################
    
    c= time.time()
    #print('Acceleration frame rate',1/(c-b))
    print('Total frame rate',1/(c-a))
    #measured_X_ACC = np.append(measured_X_ACC, X_Decimal_ACL)  # save ACC values
    #measured_Y_ACC = np.append(measured_Y_ACC, Y_Decimal_ACL)
    #measured_Z_ACC = np.append(measured_Z_ACC, Z_Decimal_ACL)
            



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
    
    
'''    
####################################################    

threshold_value = 30

frame = img_final[:,:,31]
frame_prev = img_final[:,:,30]
# Compute the difference between consecutive frames
diff = cv2.absdiff(frame, frame_prev)

# Threshold the difference image
_, thresh = cv2.threshold(diff, threshold_value, 255, cv2.THRESH_BINARY)

# Find contours in the thresholded image
contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    
plt.imshow(diff, cmap='gray') #,origin='lower')
plt.imshow(thresh , cmap='gray') #,origin='lower')
  
    

##########################################################

import cv2
import numpy as np

# Set the threshold value (you may need to adjust this)
threshold_value = 50

# Open the video capture
cap = cv2.VideoCapture(0)  # Use 0 for the default camera, you may need to change this

# Get the initial frame
_, frame_prev = cap.read()

while True:
    # Capture the current frame
    _, frame = cap.read()

    # Compute the difference between consecutive frames
    diff = cv2.absdiff(frame, frame_prev)

    # Threshold the difference image
    _, thresh = cv2.threshold(diff, threshold_value, 255, cv2.THRESH_BINARY)

    # Find contours in the thresholded image
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    if contours:
        # Calculate the center of mass (average of contour coordinates)
        moments = cv2.moments(contours[0])
        if moments["m00"] != 0:
            cx = int(moments["m10"] / moments["m00"])
            cy = int(moments["m01"] / moments["m00"])

            # Get the image center
            img_center_x, img_center_y = frame.shape[1] // 2, frame.shape[0] // 2

            # Determine motor direction based on the center of mass
            if cx < img_center_x:
                print("Turn motor counter clockwise")
                # Add your code to turn the motor counter clockwise here
            elif cx > img_center_x:
                print("Turn motor clockwise")
                # Add your code to turn the motor clockwise here

    # Display the frames
    cv2.imshow("Frame", frame)
    cv2.imshow("Threshold", thresh)

    # Update the previous frame
    frame_prev = frame.copy()

    # Break the loop if 'q' key is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release the video capture and close all windows
cap.release()
cv2.destroyAllWindows()

'''








    
