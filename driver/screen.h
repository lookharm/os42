#define VDO_ADDRESS 0xb8000
#define MAX_ROW 25
#define MAX_COL 80

#define WHITE_ON_BLUE 0x1b

#define REG_SCREEN_CTRL 0x3d4
#define REG_SCREEN_DATA 0x3d5
#define GET_SCREEN_OFFSET(row, col) (2*MAX_COL*row) + (2*col)
#define GET_SCREEN_ROW(offset) offset / (2 * MAX_COL)

void clear();
void print(char*);
void put_char(char);