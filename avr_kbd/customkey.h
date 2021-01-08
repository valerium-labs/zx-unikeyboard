//Custom keyboard definition
//Step 1. Enumerate the keys you'd like to use with UNIQUE numbers;
//Step 2. Put the aliases with a column and row numbers (so calles "addresses") into keyaddr[][] array below;
//Step 3. You may refer to the keys by these aliases in a keymatrix polling functions.

//Enumeration of keys used:
#define KEY_LCTRL	0
#define KEY_RCTRL	1
#define KEY_LALT	2
#define KEY_RALT	3
#define KEY_LSHIFT	4
#define KEY_RSHIFT	5
#define KEY_CAPSLOCK	6
#define KEY_ENTER	7
#define KEY_BACKSPACE	8
#define KEY_SPACE	9
#define KEY_Q	10
#define KEY_W	11
#define KEY_E	12
#define KEY_R	13
#define KEY_T	14
#define KEY_Y	15
#define KEY_U	16
#define KEY_I	17
#define KEY_O	18
#define KEY_P	19
#define KEY_A	20
#define KEY_S	21
#define KEY_D	22
#define KEY_F	23
#define KEY_G	24
#define KEY_H	25
#define KEY_J	26
#define KEY_K	27
#define KEY_L	28
#define KEY_Z	29
#define KEY_X	30
#define KEY_C	31
#define KEY_V	32
#define KEY_B	33	
#define KEY_N	34
#define KEY_M	35
#define KEY_1	36
#define KEY_2	37
#define KEY_3	38
#define KEY_4	39
#define KEY_5	40
#define KEY_6	41
#define KEY_7	42
#define KEY_8	43
#define KEY_9	44
#define KEY_0	45
#define KEY_LEFT	46
#define KEY_RIGHT	47
#define KEY_UP		48
#define KEY_DOWN	49
#define KEY_DELETE	50
#define KEY_INSERT	51
#define KEY_ESC		52
#define KEY_MINUS    53
#define KEY_EQ    54
#define KEY_LBRACKET	55
#define KEY_RBRACKET	56
#define KEY_COMMA	57
#define KEY_PERIOD	58
#define KEY_SEMICOLON	59
#define KEY_QUOTE	60
#define KEY_SLASH	61
#define KEY_F2		62
#define KEY_F10		63
#define KEY_F12		64
#define KEY_PRTSCR	65
#define KEY_BACKSLASH 66


//Keyset addressed by pins
//example data for Asus X200 keyboard
const uint8_t keyaddr[][3] =
{
{ KEY_LCTRL, 12, 4 },
{ KEY_RCTRL, 6, 4 },
{ KEY_LALT, 7, 2 },
{ KEY_RALT, 9, 2 },
{ KEY_LSHIFT, 11, 5 },
{ KEY_RSHIFT, 8, 5 },
{ KEY_CAPSLOCK, 10, 1 },
{ KEY_ENTER, 6, 20 },
{ KEY_BACKSPACE, 13, 23 },
{ KEY_SPACE, 7, 20 },
{ KEY_Q, 13, 21 },
{ KEY_W, 6, 15 },
{ KEY_E, 13, 16 },
{ KEY_R, 6, 16 },
{ KEY_T, 10, 17 },
{ KEY_Y, 6, 17 },
{ KEY_U, 6, 18 },
{ KEY_I, 9, 18 },
{ KEY_O, 6, 19 },
{ KEY_P, 11, 20 },
{ KEY_A, 9, 14 },
{ KEY_S, 7, 17 },
{ KEY_D, 9, 23 },
{ KEY_F, 8, 16 },
{ KEY_G, 9, 17 },        
{ KEY_H, 8, 18 },        
{ KEY_J, 8, 19 },        
{ KEY_K, 9, 21 },        
{ KEY_L, 10, 20 },        
{ KEY_Z, 8, 14 },        
{ KEY_X, 13, 14 },        
{ KEY_C, 7, 21 },        
{ KEY_V, 8, 17 },        
{ KEY_B, 7, 18 },	  
{ KEY_N, 7, 19 },        
{ KEY_M, 9, 20 },        
{ KEY_1, 11, 14 },        
{ KEY_2, 10, 14 },        
{ KEY_3, 11, 15 },        
{ KEY_4, 10, 15 },        
{ KEY_5, 11, 16 },        
{ KEY_6, 11, 17 },        
{ KEY_7, 10, 18 },        
{ KEY_8, 11, 18 },        
{ KEY_9, 10, 19 },        
{ KEY_0, 11, 19 },        
{ KEY_LEFT, 6, 23 },        
{ KEY_RIGHT, 7, 15 },        
{ KEY_UP, 12, 24 },        
{ KEY_DOWN, 8, 24 },        
{ KEY_DELETE, 12, 23 },        
{ KEY_INSERT, 12, 21 },        
{ KEY_ESC, 7, 24 },
{ KEY_MINUS, 13, 20 },
{ KEY_EQ, 11, 21 },
{ KEY_LBRACKET, 10, 21 },
{ KEY_RBRACKET, 11, 23 },
{ KEY_COMMA, 8, 20 },
{ KEY_PERIOD, 8, 21 },
{ KEY_SEMICOLON, 6, 21 },
{ KEY_QUOTE, 10, 23 },
{ KEY_SLASH, 9, 19 },
{ KEY_F2, 7, 14 },
{ KEY_F10, 13, 18 },
{ KEY_F12, 13, 19 },
{ KEY_PRTSCR, 9, 15 },
{ KEY_BACKSLASH, 11, 22 },
};
