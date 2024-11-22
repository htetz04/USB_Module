`timescale 1ns/10ps

typedef enum logic [2:0] {
    IDLE_TX = 0, SYNC_TX = 1, PID_TX = 2, EOP_TX = 3,
    DATAWAIT_TX = 4, DATALOAD_TX = 5, CRC_TX = 6, ERROR_TX = 7
} state_TX;

/* -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
NOTEPAD
- Ask if TX can also take TX_Transfer == 4'b1011 (DATA1)

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_*/

module usb_TX (
    input logic clk, n_rst,
    input logic [3:0] TX_Packet,

    output logic Get_TX_Packet_Data, TX_Error, TX_Transfer_Active,
    output logic [7:0] byte_TX
);
    state_TX n_state_TX, c_state_TX;
    logic EOP_complete;
    logic [3:0] n_pID, pID;

    always_ff @(posedge clk, negedge n_rst) begin
        if(!n_rst) begin
            c_state_TX <= IDLE_TX;
            pID <= 3'b000;
        end
        else begin
            c_state_TX <= n_state_TX;
            pID <= n_pID;
        end
    end

    always_comb begin // n_state comb
        n_pID = pID;
        n_state_TX = c_state_TX;

        case(c_state_TX) begin

            IDLE_TX: begin
                if( (TX_Packet == 4'b0011) || // DATA0
                    (TX_Packet == 4'b1010) || // ACK
                    (TX_Packet == 4'b1010) || // NAK
                    (TX_Packet == 4'b1110) // STALL
                ) begin
                    n_state_TX = SYNC_TX;
                    n_pID = TX_Packet;
                end

                else if(TX_Packet == 4'b0000) begin // IDLE
                    n_state_TX = IDLE_TX;
                end

                else begin
                    n_state_TX = c_state_TX;
                end
            end

            ERROR_TX: begin
                if( (TX_Packet == 4'b0001) || // OUT
                    (TX_Packet == 4'b1001) || // IN
                    (TX_Packet == 4'b1011) // DATA1
                ) begin
                    n_state_TX = ERROR_TX;
                end

                else if( (TX_Packet == 4'b0011) || // DATA0
                    (TX_Packet == 4'b1010) || // ACK
                    (TX_Packet == 4'b1010) || // NAK
                    (TX_Packet == 4'b1110) // STALL
                ) begin
                    n_state_TX = SYNC_TX;
                    PID = TX_Packet;
                end
                else if(TX_Packet == 4'b0000) begin
                    n_state_TX = IDLE_TX;
                end
            end

            PID_TX: begin
                n_state_TX = EOP_TX;
                if(pID == 4'b0011) begin // DATA0
                    n_state_TX = DATAWAIT_TX;
                end
            end

            DATAWAIT_TX: begin
                n_state_TX = DATALOAD_TX;
            end

            DATALOAD_TX: begin
                n_state_TX = CRC_TX;
            end

            CRC_TX: begin
                n_state_TX = EOP_TX;
            end

            EOP_TX: begin
                if(EOP_complete) begin
                    n_state_TX = IDLE_TX;
                end
            end

        end
    end

    always_comb begin // output comb
        byte_TX = 8'b0;
        Get_TX_Packet_Data = 1'b0;
        TX_Error = 1'b0;
        TX_Transfer_Active = 1'b1;
        case(c_state_TX) begin

            IDLE_TX: begin
                TX_Transfer_Active = 1'b0;
            end

            SYNC_TX: begin
                byte_TX = 8'b00000001;
            end

            PID_TX: begin
                byte_TX = {4'b0, pID};
            end

            DATAWAIT_TX: begin
                Get_TX_Packet_Data = 1'b1;
            end

            DATALOD_TX: begin
                // Nothing Happens
                Get_TX_Packet_Data = 1'b0;
            end

            CRC_TX: begin
                byte_TX = 8'b11111111;
            end

            EOP_TX: begin
                // Nothing Happens
                Get_TX_Packet_Data = 1'b0;
            end

            ERROR_TX: begin
                TX_Error = 1'b1;
            end

        end
    end

    

endmodule