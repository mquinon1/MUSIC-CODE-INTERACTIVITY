// Define frequency of our chip
#define F_CPU 8000000

// Include helper libraries
#include <avr/io.h>
#include <util/delay.h>
#include <stdlib.h>

// delay: helper function
void delay(unsigned long Period)
{
	// Count down period until it hits zero
	while (Period--)
	{
		// Delay 1 microsecond
		_delay_us(1);
	}
}

int main()
{
	// Set data-direction of all pins of port B to output
	DDRB = 255;
	
	// "unsigned short" has 2^16 possible values, 0 to 65535
	unsigned short Period = 40;
	unsigned short Counter = 10;
	
	// "unsigned char" has 2^8 possible values, 0 to 255
	unsigned char On = 1;
	
	while (1)
	{
		// Wait until counter hits zero
		if (!--Counter)
		{
			// Reset counter
			Counter = 5;
			
			// Lengthen the period
			Period = (rand() % 1000) ^ (rand() % 200);
		}
		
		// If on, turn on the outputs
		if (On)
			PORTB = 255;
		
		// Delay
		delay(Period);
		
		// If on, turn off the outputs
		if (On)
			PORTB = 200;
			
		// Delay
		delay(Period);
	}
}
