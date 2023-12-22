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
    
    measured_X_ACC = np.array([]) # create an empty list to hold our values
    measured_Y_ACC = np.array([]) # create an empty list to hold our values
    measured_Z_ACC = np.array([]) # create an empty list to hold our values
    

    print(power_supply.write("OUTPUT ON")) # power supply output is turned on


            
    for v in output_voltage:
        # apply the desired voltage on teh 6V power supply and limist the output current to 0.5A
        power_supply.write("APPLy P6V, %0.2f, 0.5" % v)
 
         # pause 50ms to let things settle
        time.sleep(.8)
 
        # read the output voltage on the 6V power supply
        # measured_voltage_tmp = power_supply.query("MEASure:VOLTage:DC? P25V"
        measured_voltage_tmp = power_supply.query(":MEASure:VOLTage:DC? P6V")
        measured_voltage = np.append(measured_voltage, measured_voltage_tmp)

##################################################################################################
        
        print("Start recording.")


        cycles = 100
        direction = 0
        
        PC_Control = 0; # send a "stop" signal to the FSM
        dev.SetWireInValue(0x07, PC_Control) 
        dev.UpdateWireIns()  # Update the WireIns
        time.sleep(10)
            
        for i in range(10):

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
            dev.SetWireInValue(0x07, PC_Control) 
            dev.UpdateWireIns()
            
            # Since we are using a slow clock on the FPGA to compute the results
            # we need to wait for the result to be computed
            
            time.sleep(0.1)
            dev.UpdateWireOuts() 
            X_ACC = dev.GetWireOutValue(0x20)
            bin_ = '{0:016b}'.format(X_ACC)
            LSB = bin_[:8]
            MSB = bin_[-8:]
            MSB = int(MSB,2)
            LSB = int(LSB,2)
            X_Decimal_ACL = twos_comp(int(float(((MSB<<8) + LSB))), 16)/26000; 
            
            PC_Control = 0; # send a "stop" signal to the FSM
            dev.SetWireInValue(0x07, PC_Control) 
            dev.UpdateWireIns()  # Update the WireIns
        
            time.sleep(0.1)
            #ACC YCORD
            #DeviceAddress = int("00110010",2)
            #dev.SetWireInValue(0x01, DeviceAddress) 
            SubRegisterAddress = int("10101010",2)         
            dev.SetWireInValue(0x02, SubRegisterAddress) 
            #initializeRegisterValues = int("10010111",2)
            #dev.SetWireInValue(0x03, initializeRegisterValues) 
            #initializeRegisterAddress = int("00100000",2)
            #dev.SetWireInValue(0x04, initializeRegisterAddress) 
            PC_Control = 1; # send a "go" signal to the FSM
            dev.SetWireInValue(0x07, PC_Control) 
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
            dev.SetWireInValue(0x07, PC_Control) 
            dev.UpdateWireIns()  # Update the WireIns
            
            time.sleep(0.1)
            #Z Cord ACCL 
            #DeviceAddress = int("00110010",2)
            #dev.SetWireInValue(0x01, DeviceAddress) 
            SubRegisterAddress = int("10101100",2)         
            dev.SetWireInValue(0x02, SubRegisterAddress) 
            #initializeRegisterValues = int("10010111",2)
            #dev.SetWireInValue(0x03, initializeRegisterValues) 
            #initializeRegisterAddress = int("00100000",2)
            #dev.SetWireInValue(0x04, initializeRegisterAddress) 
            PC_Control = 1; # send a "go" signal to the FSM
            dev.SetWireInValue(0x07, PC_Control) 
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
            dev.SetWireInValue(0x07, PC_Control) 
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
            dev.SetWireInValue(0x07, PC_Control) 
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
            dev.SetWireInValue(0x07, PC_Control) 
            dev.UpdateWireIns()  # Update the WireIns
            
        
            #Ycord of Mag
            #DeviceAddress = int("00111100",2)
            #dev.SetWireInValue(0x01, DeviceAddress) 
            SubRegisterAddress = int("00000111",2)         #("10101000",2)  int("00100000",2) 
            dev.SetWireInValue(0x02, SubRegisterAddress) 
            #initializeRegisterValues = int("00000000",2)
            #dev.SetWireInValue(0x03, initializeRegisterValues) 
            #initializeRegisterAddress = int("00000010",2)
            #dev.SetWireInValue(0x04, initializeRegisterAddress) 
            PC_Control = 1; # send a "go" signal to the FSM
            dev.SetWireInValue(0x07, PC_Control) 
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
            dev.SetWireInValue(0x07, PC_Control) 
            dev.UpdateWireIns()  # Update the WireIns
            
            
            #Zcord of Mag
            #DeviceAddress = int("00111100",2)
            #dev.SetWireInValue(0x01, DeviceAddress) 
            SubRegisterAddress = int("00000101",2)         #("10101000",2)  int("00100000",2) 
            dev.SetWireInValue(0x02, SubRegisterAddress) 
            #initializeRegisterValues = int("00000000",2)
            #dev.SetWireInValue(0x03, initializeRegisterValues) 
            #initializeRegisterAddress = int("00000010",2)
            #dev.SetWireInValue(0x04, initializeRegisterAddress) 
            PC_Control = 1; # send a "go" signal to the FSM
            dev.SetWireInValue(0x07, PC_Control) 
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
            dev.SetWireInValue(0x07, PC_Control) 
            dev.UpdateWireIns()  # Update the WireIns
        
            print("XYZ axis of Magnet (gauss):  %s %s %s" % (X_Decimal_MAG,Y_Decimal_MAG,Z_Decimal_MAG))

            
            measured_X_ACC = np.append(measured_X_ACC, X_Decimal_ACL)  # save ACC values
            measured_Y_ACC = np.append(measured_Y_ACC, Y_Decimal_ACL)
            measured_Z_ACC = np.append(measured_Z_ACC, Z_Decimal_ACL)
            

#%%
bit_num = 315392;
buf = bytearray(bit_num);   # 648*488     
buf1 = bytearray(bit_num);   # 648*488  
buf2 = bytearray(bit_num);   # 648*488  

  #%% 



img_final = np.zeros([488,648,100]);
image = np.zeros(488*648)
pix1 = 648;
pix2 = 488;

jj = 0;
while(1):  #for jj in range(100):
      
      a = time.time()
      
      dev.SetWireInValue(0x00, 1); #Reset FIFOs and counter
      dev.UpdateWireIns();  # Update the WireIns

      dev.SetWireInValue(0x00, 0); #Release reset signal
      dev.UpdateWireIns();  # Update the WireIns
      
     

      dev.ReadFromBlockPipeOut(0xa0, 1024, buf);  # Read data from BT PipeOut
      
      

  #%%
      
      #buf1 = buf[0*832:bit_num];
      #buf_tmp = buf;
      
      image[0:488*646] = buf[0:488*646]
      
      ''' 
      # counter = 0
      for i in range(0, bit_num-1-0*832,4):
          # print(( buf[i] + (buf[i+1]<<8) + (buf[i+2]<<16) ))
          image[i] = buf[i+3]<<2  # ( buf[i] + (buf[i+1]<<8) + (buf[i+2]<<16) ) # transfer length is 16 bits
          image[i+1] = buf[i+2]<<2
          image[i+2] = buf[i+1]<<2
          image[i+3] = buf[i]<<2
          # counter = counter + 1
          #if i<50:
          #    print (buf[i])
      '''
     
  
      
      
      #im_array = np.array(buf[0:488*646]).reshape(pix2, pix1)
      im_array = np.array(image/np.max(image)).reshape(pix2, pix1)  # Reshape array into a 2D array like image
      #img_final[:,:,jj] = im_array
      #jj = jj + 1
      
      #plt.imshow(im_array, cmap='gray') #,origin='lower')           
      #ax.colorbar()
      #plt.savefig("pic.png")
      #plt.pause(0.03)
      
      cv2.imshow('gray image',im_array) #,origin='lower')    
      cv2.waitKey(1)
      #cv2.destroyAllWindows()
      #time.sleep(0.0001)

      b = time.time()
      print('Time',1/(b-a))
       
   


    
    print(power_supply.write("OUTPUT OFF"))
    power_supply.close()
    
    PC_Control = 0; # send a "stop" signal to the FSM
    dev.SetWireInValue(0x07, PC_Control) 
    dev.UpdateWireIns()  # Update the WireIns
    dev.Close
    
    
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
        
        
    # plot results 
    plt.figure()
    plt.plot(voltage_list, X_ACC_Max_list)
    plt.title("Applied Volts vs. Max Acceleration in X")
    plt.xlabel("Applied Volts [V]")
    plt.ylabel("Acceleration [G]")
    plt.draw()
    # show all plots
    plt.show()
    
    plt.figure()
    plt.plot(voltage_list, Y_ACC_Max_list)
    plt.title("Applied Volts vs. Max Acceleration in Y")
    plt.xlabel("Applied Volts [V]")
    plt.ylabel("Acceleration [G]")
    plt.draw()
    # show all plots
    plt.show()
    
    plt.figure()
    plt.plot(voltage_list, Z_ACC_Max_list)
    plt.title("Applied Volts vs. Max Acceleration in Z")
    plt.xlabel("Applied Volts [V]")
    plt.ylabel("Acceleration [G]")
    plt.draw()
    # show all plots
    plt.show()
    
    plt.figure()
    plt.plot(voltage_list, X_ACC_Mean_list)
    plt.title("Applied Volts vs. Mean Acceleration in X")
    plt.xlabel("Applied Volts [V]")
    plt.ylabel("Acceleration [G]")
    plt.draw()
    # show all plots
    plt.show()
    
    plt.figure()
    plt.plot(voltage_list, Y_ACC_Mean_list)
    plt.title("Applied Volts vs. Mean Acceleration in Y")
    plt.xlabel("Applied Volts [V]")
    plt.ylabel("Acceleration [G]")
    plt.draw()
    # show all plots
    plt.show()
    
    plt.figure()
    plt.plot(voltage_list, Z_ACC_Mean_list)
    plt.title("Applied Volts vs. Mean Acceleration in Z")
    plt.xlabel("Applied Volts [V]")
    plt.ylabel("Acceleration [G]")
    plt.draw()
    # show all plots
    plt.show()
    
    
    
    
    
    
        
        
        
   
    












    
