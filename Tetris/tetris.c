void lc4_putc(char c) ;		/* calls TRAP_PUTC, needs a character to write to display */
char lc4_getc(); /* calls TRAP_GETC */
void lc4_video_color(int z); /* calls TRAP_video_color */
void lc4_video_box(int c, int y, int x); /* calls TRAP_video box */

int main()
{

	char* string = "GAME OVER!\n" ;
  	int locationX;
  	int locationY;
  	int i;
  	int z = 0;
  	char x = string[z];

  	for(i = 0; i < 10; i+=1){
  		locationX = 0;
  		locationY = 41;
  		lc4_video_box(31744, locationX, locationY);
  		while ((locationX + 20) < 126){
  			int key = lc4_getc();
  			if (key == 106){
  				if ((locationY - 10) > 0){ //check if left is allowed
  					lc4_video_box(0, locationX, locationY); //fill in old box
  					locationY = locationY - 10; //move left
  					locationX = locationX + 10; //move down
  					lc4_video_box(31744, locationX, locationY); //draw new box
  				}
  			}
  			else if (key == 107){
  				if ((locationY + 10) < 120){
  					lc4_video_box(0, locationX, locationY);
  					locationY = locationY + 10;
  					locationX = locationX + 10;
  					lc4_video_box(31744, locationX, locationY);
  				}
  			}
  			else if (key == 109){
  				lc4_video_box(0, locationX, locationY);
  				locationX = locationX + 10;
  				lc4_video_box(31744, locationX, locationY);
  			}
  		}
  	}
  	while (x != '\0'){
		lc4_putc (x) ;
		z = z + 1;
		x = string[z];
  	}


	return 0 ;
}
