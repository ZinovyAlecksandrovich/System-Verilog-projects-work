 # import various libraries necessary to run your Python code
import sys,os    # system related library
ok_sdk_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\x64"
ok_dll_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\lib\\x64"

sys.path.append(ok_sdk_loc)   # add the path of the OK library
os.add_dll_directory(ok_dll_loc)
import numpy as np
import matplotlib.pyplot as plt
import time   # time related library
import ok     # OpalKelly library
import cv2

#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel();  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("");      # open USB communication with the OK board
ConfigStatus=dev.ConfigureFPGA(""); # Configure the FPGA with this bit file C:/Users/zinovya2/ece437/lab9/lab9.runs/impl_1/BTPipeExample.bit

# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.");
else:    
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)));
    print("Exiting the program.");
    sys.exit ();


'''
if ConfigStatus == 0:
    print ("Your bit file is successfully loaded in the FPGA.");
else:
    print ("Your bit file did not load. The error code number is:" + str(int(ConfigStatus)));
    print ("Exiting the progam.");
    sys.exit ();
    

print("----------------------------------------------------")
print("----------------------------------------------------")

'''


#before we begin reading pixel data, need to initalize the SPI registers using previous lab code

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
   
    
    #plt.plot(image)

    #%% show image ##

    #image = np.array(image)                         # convert list to array
    #print(np.max(image))
    
    
    
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
     
dev.UpdateWireOuts()
Res_N = dev.GetWireOutValue(0x21)
dev.UpdateWireOuts()
Test = dev.GetWireOutValue(0x22)
 

#%%

dev.Close
    

#%%%%%%%%
## image processing

pixel50 = img_final[50,50,:]
plt.plot(pixel50)




for i in range(10):
    fig = plt.figure()
    plt.imshow(img_final[:,:,i], cmap='gray') #,origin='lower')    
    plt.title(i)   
    plt.pause(0.2)
    #plt.figure().clear()

plt.plot(img_final[49,49,:])
 
np.std(img_final[49,49,:])



'''
for i in range(10):
    fig,ax = plt.subplots()
    ax.imshow(img_final[:,:,i], cmap='gray')
    ax.set_title(i)
    plt.pause(0.1)
    ax.clear()
    
plt.close()
'''

'''
for i in range(10):
    cv2.imshow('gray',img_final[:,:,i]) #,origin='lower')    
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    #plt.figure().clear()

'''