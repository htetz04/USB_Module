`timescale 1ns/10ps

typedef enum logic [2:0] {
    IDLE_TX = 0, SYNC_TX = 1, PID_TX = 2, EOP_TX = 3,
    DATAWAIT_TX = 4, DATALOAD_TX = 5, CRC_TX = 6, ERROR_TX = 7
} state_TX;

/* -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
NOTEPAD
- Ask if TX can also take TX_Transfer == 4'b1011 (DATA1)

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_*/