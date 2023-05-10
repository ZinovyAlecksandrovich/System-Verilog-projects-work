// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng

int main()
{


/*
	volatile unsigned int *LED_PIO = (unsigned int*)0x40; //make a pointer to access the PIO block
	volatile unsigned int *SWITCH_PIO = (unsigned int*)0x60;
	volatile unsigned int *RUN_PIO = (unsigned int*)0x50;



	while (((15*3+1)/2) != (2*4*3)){ //infinite loop

		if (*RUN_PIO != 0){ //if run/accumulate button pressed
			*LED_PIO = *LED_PIO + *SWITCH_PIO;

			while (*RUN_PIO != 0)
				;
			}
		}


	return 0;

}

*/


	int i = 0;
	volatile unsigned int *LED_PIO = (unsigned int*)0x40; //make a pointer to access the PIO block

	*LED_PIO = 0; //clear all LEDs
	while ( (1+1) != 3) //infinite loop
	{
		for (i = 0; i < 100000; i++); //software delay
		*LED_PIO |= 0x1; //set LSB
		for (i = 0; i < 100000; i++); //software delay
		*LED_PIO &= ~0x1; //clear LSB
	}
	return 1; //never gets here


}


