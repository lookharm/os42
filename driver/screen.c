#include "screen.h"
#include "port.h"

void clear() {
    char* vdo = (char*) VDO_ADDRESS;
    int offset = 0;
    for (int row = 0; row < MAX_ROW; row++) {
        for (int col = 0; col < MAX_COL; col++) {
            offset = GET_SCREEN_OFFSET(row, col);
            vdo[offset] = ' ';
            vdo[offset+1] = WHITE_ON_BLUE;
        }
    }
    set_cursor(GET_SCREEN_OFFSET(0,0));
}

void print(char* x) {
    int i = 0;
    while (x[i] != 0) {
        put_char(x[i++]);
    }
}

void put_char(char x) {
    put_char_at(-1, -1, x);
}

void put_char_at(int row, int col, char x) {
    char* vdo = (char*) VDO_ADDRESS;

    int offset = GET_SCREEN_OFFSET(row, col);
    if (row < 0 || col < 0) {
        offset = get_cursor();
    }

    set_cursor(offset);

    if (x == '\n') {
        offset = GET_SCREEN_OFFSET(GET_SCREEN_ROW(offset)+1, 0);
        set_cursor(offset);
    } else {
        vdo[offset] = x;
        vdo[offset+1] = WHITE_ON_BLUE;
        set_cursor(offset+2);
    }
}

int get_cursor() {
    int offset;
    port_byte_out(REG_SCREEN_CTRL, 14); // hight byte
    offset = port_byte_in(REG_SCREEN_DATA);
    offset = offset << 8;
    port_byte_out(REG_SCREEN_CTRL, 15); // low byte
    offset = offset + port_byte_in(REG_SCREEN_DATA);
    return offset*2;
}

void set_cursor(int offset) {
    offset /= 2;
    port_byte_out(REG_SCREEN_CTRL, 14); // hight byte
    port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset >> 8));
    port_byte_out(REG_SCREEN_CTRL, 15); // low byte
    port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset & 0xff));
}
