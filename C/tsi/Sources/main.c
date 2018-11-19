#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <time.h>

#include "../../shared/plasmaCoprocessors.h"
#include "../../shared/plasmaIsaCustom.h"
#include "../../shared/plasmaMisc.h"
#include "../../shared/plasmaSoPCDesign.h"
#include "../../shared/plasmaMyPrint.h"
#include "../../shared/plasma.h"

#include "../Includes/scale.h"

unsigned char wait_data()
{
	while( !(MemoryRead(IRQ_STATUS) & IRQ_UART_READ_AVAILABLE) );
	unsigned char cc = MemoryRead(UART_READ);
	return cc;
}

inline void printPixel(char row, char col, int color)
{
	int buff = 0x00000000;

	buff = color;
	buff = (buff << 8) | row;
	buff = (buff << 8) | col;

	MemoryWrite(OLED_BITMAP_RW, buff);
}

//char red[63][96];
//char filtered[63][96];

int main(int argc, char **argv) {

	int H = 63;
	int W = 96;
	int r, g, b, pixel;
	unsigned int start_c, stop_c;
	unsigned char image[63][96];

	/**********/
	// Reset the RGB OLED screen and display a white screen
	/**********/

	MemoryWrite(OLED_MUX, OLED_MUX_BITMAP); // Select the RGB OLED Bitmap controler
	MemoryWrite(OLED_BITMAP_RST, 1); // Reset the oled_rgb PMOD
	
	
	for(int py = 0; py < H; py++)
	{
		for(int px = 0; px < W; px ++){
			
			printPixel(py, px, 0x0000); // clear the RGB OLED screen
		}
	}

	/**********/
	// Read values coming from the UART
	/**********/

	puts("Please, send image from Matlab !\n");

	MemoryWrite(CTRL_SL_RST, 1); // reset the sw/led controler

	int i = 0;
	for(int py = 0; py < H; py++)
	{
		for(int px = 0; px < W; px ++){
			r = wait_data();
			g = wait_data();
			b = wait_data();
			pixel = (r+g+b) / 3;

			image[py][px] = pixel;
			//pixel = ((r >> 5) << 11) | ((g >> 6) << 5) | (b >> 5);
			pixel = ((pixel >> 5) << 11) | ((pixel >> 6) << 5) | (pixel >> 5);
			printPixel(py, px, pixel);
		}
	}

	/**********/
	// Processing
	/**********/
	MemoryWrite(CTRL_SL_RW, 1);
	// Read the timer value before the processing starts
	start_c = r_timer();
	//scale_no_opt(vga, H*W);

	// processing the loaded image
	//scale_no_opt(red, H*W);
	//scale_opt1(data, pixel_nb);
	//filtre_1(red, W, H, filtered, coef);

	// Read the timer value after the processing is over
	stop_c = r_timer();
	
	int fil;

	/**********/
	// Display the resulting image
	/**********/
	MemoryWrite(OLED_BITMAP_RST, 1); // Reset the oled_rgb PMOD

	/*for(int py = 0; py < H-2; py++)
	{
		for(int px = 0; px < W-2; px ++){
			//red[py][px] += 10;
			fil = (int) red[py][px];
			pixel = ((fil << 8)& 0xF800) | ((fil << 3)&0x07E0) | ((fil >> 3) & 0x1F);
			printPixel(py, px, pixel);
		}
	}*/

	/**********/
	// Affichage du nombre de cycles nécessaires au traitement
	/**********/
	MemoryWrite(SEVEN_SEGMENT_RST, 1); // reset the 7 segment controler
	MemoryWrite(SEVEN_SEGMENT_REG, (stop_c - start_c));
	
	return(0);
	
}