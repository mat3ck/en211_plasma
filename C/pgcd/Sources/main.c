#include "../../shared/plasmaCoprocessors.h"
#include "../../shared/plasmaIsaCustom.h"
#include "../../shared/plasmaMisc.h"
#include "../../shared/plasmaSoPCDesign.h"
#include "../../shared/plasma.h"
#include "../../shared/plasmaMyPrint.h"

#define MemoryRead(A)     (*(volatile unsigned int*)(A))
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)


#define RIGHT_BUTTON  0x00000010
#define LEFT_BUTTON   0x00000008
#define DOWN_BUTTON   0x00000004
#define UP_BUTTON     0x00000002
#define CENTER_BUTTON 0x00000001

#define PLAYER 32

//Taille du labirynthe (les deux tailles DOIVENT être impaires)
#define WIDTH 51
#define HEIGHT 51

//Taille de l'écran Oled
#define WIDTH_SCREEN 96
#define HEIGHT_SCREEN 64

char dx[] = {1, 0, -1, 0};
char dy[] = {0, -1, 0, 1};

int px, py;//Coordonnées du joueur à tout instant
int sens;//Dernier sens de déplacement (utile pour le pathfinding
int pixel_size;//Taille de pixel (pour le zoom)

unsigned int grid[WIDTH][HEIGHT];//Grille de stockage du labirynthe

//                         RRRRRGGGGGGBBBBB    RRRRRGGGGGGBBBBB    RRRRRGGGGGGBBBBB
unsigned int colors[] = {0b0000000000000000, 0b0000000000011111, 0b1111100000000000, 0b1111111111111111, 0b1111111111111111, 0b1111111111111111};
char conversion[] = {' ', '#', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};

unsigned int random = 1862345436;

//Renvoie un nombre aléatoire sur 32 bits en utilisant le module externe
unsigned int rand32() {
	//random = (16807*random)%(1862345435);
	while(!MemoryRead(LFSR_READY));
	random = MemoryRead(LFSR_DATA);
	MemoryWrite(LFSR_SEED, random);
	return random;
}

//Génère le labyrinthe dans le tableau "grid". Le paramètre "loop" définit le nombre de boucles dans le labyrinthe
//Pour loop=0, le labyrinthe est parfait
void generate(int loop) {
	//On bouche toutes les interconnexions
	for(int b = 0; b < HEIGHT; b++) {
		for(int a = 0; a < WIDTH; a++) {
			if((a&1) == 0 || (b&1) == 0) {
				grid[a][b] = 1;
			} else {
				grid[a][b] = 0;
			}
		}
	}
	//On remplit les cases libres par des entiers tous différents
	int c = 0;
	for(int b = 1; b < HEIGHT; b+=2) {
		for(int a = 1; a < WIDTH; a+=2) {
			grid[a][b] = c;
			c++;
		}
	}
	
	//On ouvre le nombre exact de liaisons pour créer un labirynthe parfait
	for(int i = 0; i < (WIDTH/2)*(HEIGHT/2)-1; i++) {
		unsigned int s, x, y;
		s = -1;
		while(s == -1 || grid[x*2+1+s][y*2+2-s] == 0 || (loop == 0 && grid[x*2+1+s-s][y*2+2-s-1+s] == grid[x*2+1+s+s][y*2+2-s+1-s])) {
			s = rand32();
			s ^= (s>>4);
			s ^= (s>>2);
			s = (s^(s>>1))&1;
			x = rand32()%((WIDTH/2)-s);
			y = rand32()%((HEIGHT/2)-1+s);
		}
		if(grid[x*2+1+s-s][y*2+2-s-1+s] == grid[x*2+1+s+s][y*2+2-s+1-s]) {
			loop--;
		}
		grid[x*2+1+s][y*2+2-s] = 0;
		unsigned int v1 = grid[x*2+1+s-s][y*2+2-s-1+s];
		unsigned int v2 = grid[x*2+1+s+s][y*2+2-s+1-s];
		if(v1 > v2) {
			s = v1;
			v1 = v2;
			v2 = s;
		}
		for(int b = 1; b < HEIGHT; b+=2) {
			for(int a = 1; a < WIDTH; a+=2) {
				if(grid[a][b] == v2) {
					grid[a][b] = v1;
				}
			}
		}
	}

	//Formattage de fin
	for(int b = 1; b < HEIGHT-1; b++) {
		for(int a = 1; a < WIDTH-1; a++) {
			if(grid[a][b]) {
				if(grid[a-1][b] == 0 && grid[a][b-1] == 0)
					grid[a][b]|=2;
				if(grid[a-1][b] == 0 && grid[a][b+1] == 0)
					grid[a][b]|=4;
				if(grid[a+1][b] == 0 && grid[a][b+1] == 0)
					grid[a][b]|=8;
				if(grid[a+1][b] == 0 && grid[a][b-1] == 0)
					grid[a][b]|=16;
			}
		}
	}
}

//Teste si la valeur correspond à un bloc solide, c'est à dire non traversable
unsigned char is_solid_block(int v) {
	return v == 1 || v == 2;
}

//Fait avancer le curseur de une case en utilisant la technique du mur à droite
void tickSolve() {
	if(grid[px+dx[sens]][py+dy[sens]] == 0) {
		sens = (sens+3)&3;
	} else {
		while(is_solid_block(grid[px+dx[(sens+1)&3]][py+dy[(sens+1)&3]])) {
			sens = (sens+1)&3;
		}
	}
	px+=dx[(sens+1)&3];
	py+=dy[(sens+1)&3];
}

//Affiche un pixel sur l'écran Oled
void printPixel(char row, char col, int color) {
	int buff = 0x00000000;
	buff = color;
	buff = (buff << 8) | row;
	buff = (buff << 8) | col;

	MemoryWrite(OLED_BITMAP_RW, buff);
}

//Affiche un carré sur l'écran Oled
void printPixel2(char row, char col, int color, int size) {
	for(int b = row; b < row+size; b++) {
		for(int a = col; a < col+size; a++) {
			int buff = 0x00000000;
			buff = color;
			buff = (buff << 8) | b;
			buff = (buff << 8) | a;
			MemoryWrite(OLED_BITMAP_RW, buff);
		}
	}
}

//Affiche un carré arondi sur l'écran Oled
void printPixel3(char row, char col, int color, int size, int corner) {
	for(int b = 0; b < size; b++) {
		for(int a = 0; a < size; a++) {
			int buff = 0x00000000;
			if(	size != 4 || (
				!(a == 0 && b == 0 && (corner&1)) && !(a == 0 && b == size-1 && (corner&2)) &&
			   	!(a == size-1 && b == size-1 && (corner&4)) && !(a == size-1 && b == 0 && (corner&8)))) {
				buff = color;
			}
			buff = (buff << 8) | (b+row);
			buff = (buff << 8) | (a+col);
			MemoryWrite(OLED_BITMAP_RW, buff);
		}
	}
}

//Affiche la grille sur l'UART
void printScreen() {
	for(int b = 0; b < HEIGHT; b++) {
		for(int a = 0; a < WIDTH; a++) {
			char str[] = " ";
			str[0] = conversion[grid[a][b]];
			puts(str);
		}
		puts("\r\n");
	}
	my_printf("x = ", px);
	my_printf("y = ", py);
	my_printf("s = ", sens);
}

//Affiche la grille sur l'écran Oled
void printScreen2() {
	for(int b = 0; b < HEIGHT; b++) {
		for(int a = 0; a < WIDTH; a++) {
			printPixel(b, a, colors[grid[a][b]]);
		}
	}
}

//Renvoie si les coordonnées en paramètres sont inclues dans le périmètre du labirynthe
unsigned char out_or_range(int x, int y) {
	return x < 0 || y < 0 || x >= WIDTH || y >= HEIGHT;
}

//Affiche la vue partielle du labyrinthe à l'écran Oled (suivant le zoom sélectionné)
void printScreen3() {
	for(int b = 0; b < HEIGHT_SCREEN; b+=pixel_size) {
		for(int a = 0; a < WIDTH_SCREEN; a+=pixel_size) {
			int v = grid[px-(WIDTH_SCREEN/(2*pixel_size))+(a/pixel_size)][py-(HEIGHT_SCREEN/(2*pixel_size))+(b/pixel_size)];
			if(out_or_range(px-(WIDTH_SCREEN/(2*pixel_size))+(a/pixel_size), py-(HEIGHT_SCREEN/(2*pixel_size))+(b/pixel_size))) {
				v = 0;
			}
			printPixel3(b, a, v==0?colors[0]:((v==PLAYER)?colors[3]:colors[1]), pixel_size, v>>1);
		}
	}
}

//Attend le temps défini
void sleep( unsigned int ms ) // fonction qui impose un delay en millisecondes
{	// la fréquence d'horloge vaut 50 MHz
	unsigned int t0 = MemoryRead( TIMER_ADR  );
	while ( MemoryRead( TIMER_ADR  ) - t0 < 50000*ms ) // On compte 50000 périodes pour 1 ms
		;
}

//Main (pas comme si c'était explicite lol)
int main(int argc, char ** argv) {
/*
	//Test du joystick
	while(1) {
		sleep(500);
		unsigned v = MemoryRead(JOYSTICK_VALUE);
		my_printf("x ", v>>13);
		my_printf("y ", (v>>3)&0b1111111111);
		my_printf("b ", v&0b111);
	}*/
	while(!(MemoryRead(JOYSTICK_VALUE)&4));//Lecture du joystick
	while(1) {//Boucle principale
		unsigned int joystick = MemoryRead(JOYSTICK_VALUE);//Lecture du joystick

		//Initialisation de la SEED du générateur de nombre aléatoire par les valeurs du joystick
		MemoryWrite(LFSR_SEED, joystick);

		//Initialisations du jeu
		generate(0);

		sens = 0;
		px = py = 1;
		pixel_size = 8;
		grid[px][py] = PLAYER;

		MemoryWrite(CTRL_SL_RST, 1);

		MemoryWrite(OLED_MUX, OLED_MUX_BITMAP);
		MemoryWrite(OLED_BITMAP_RST, 1);

		while(MemoryRead(JOYSTICK_VALUE)&4);

		printScreen3();
		grid[px][py] = 0;
		
		//Boucle du jeu
		while(!(joystick&4)) {
			int buttons = MemoryRead(BUTTONS_VALUES);
			int switches = MemoryRead(CTRL_SL_RW);
			
			if(buttons&CENTER_BUTTON) {//Si le pathFinding est activé
				while(MemoryRead(BUTTONS_CHANGE) == 0 && MemoryRead(CTRL_SL_RW) == switches){
					tickSolve();
					grid[px][py] = PLAYER;
					printScreen3();
					grid[px][py] = 0;
				}
			} else {
				//while(MemoryRead(BUTTONS_CHANGE) == 0 && MemoryRead(CTRL_SL_RW) == switches){}
				sleep(100);
			}
			//Mise à jour de toutes les entrées des différents modules matériels
			switches = MemoryRead(CTRL_SL_RW);
			buttons = MemoryRead(BUTTONS_VALUES);
			joystick = MemoryRead(JOYSTICK_VALUE);
			
			//Calcul des nouvelles coordonnées
			int jx = ((int)(joystick>>3)&0b1111111111) - 512;
			int jy = ((int)(joystick>>13)) - 512;
			if((jx > 200 || buttons&RIGHT_BUTTON) && grid[px+1][py] == 0) {
				px++;
			}
			if((jx < -200 || buttons&LEFT_BUTTON) && grid[px-1][py] == 0) {
				px--;
			}
			if((jy > 200 || buttons&DOWN_BUTTON) && grid[px][py+1] == 0) {
				py++;
			}
			if((jy < -200 || buttons&UP_BUTTON) && grid[px][py-1] == 0) {
				py--;
			}
			if(buttons&CENTER_BUTTON) {
				tickSolve();
			}
			pixel_size = 1<<switches;
			//Rafraichissement de l'écran
			grid[px][py] = PLAYER;
			printScreen3();
			grid[px][py] = 0;
			joystick = MemoryRead(JOYSTICK_VALUE);
		}
	}
}//*/
