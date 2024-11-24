`timescale 1ns/10ps

typedef enum logic [2:0] {
    IDLE_TX = 0, SYNC_TX = 1, PID_TX = 2, EOP_TX = 3,
    DATA_TX = 4, CRC_TX = 5, ERROR_TX = 6
} state_TX;

/* -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
NOTEPAD
- Ask if TX can also take TX_Transfer == 4'b1011 (DATA1)

// -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_*/

module USB_TX_States(
    input logic clk, n_rst,
    input logic packet_load_complete_TX, complete_TX,
    input logic [3:0] TX_Packet,
    output logic TX_Transfer_Active, TX_Error, byte_ready_TX,
    output logic [2:0] c_state_TX,
    output logic [7:0] byte_TX
);

    state_TX c_state_TX, n_state_TX;
    logic [1:0] n_pID, pID;


    always_ff @(posedge clk, negedge n_rst) begin
        if(!n_rst) begin
            c_state_TX <= 3'b0;
            pID <= 2'b0;
        end
        else begin
            c_state_TX <= n_state_TX;
            pID <= n_pID;
        end
    end

    always_comb begin
        n_state_TX = c_state_TX;
        n_pID = pID;
        case(c_state_TX) // Next_State
            IDLE_TX: begin
                if( TX_Packet == 4'b0011 || // DATA0
                    TX_Packet == 4'b0010 || // ACK
                    TX_Packet == 4'b1010 || // NAK
                    TX_Packet == 4'b1110    // STALL
                ) begin
                    n_pID = TX_Packet;
                    n_state_TX = SYNC_TX;
                end

                else if(TX_Packet == 4'b0000) begin
                    n_state_TX = c_state_TX;
                end

                else begin
                    n_state_TX = ERROR_TX;
                end
            end

            ERROR_TX: begin
                if( TX_Packet == 4'b0011 || // DATA0
                    TX_Packet == 4'b0010 || // ACK
                    TX_Packet == 4'b1010 || // NAK
                    TX_Packet == 4'b1110    // STALL
                ) begin
                    n_pID = TX_Packet;
                    n_state_TX = SYNC_TX;
                end

                else if(TX_Packet == 4'b0000) begin
                    n_state_TX = c_state_TX;
                end

                else begin
                    n_state_TX = ERROR_TX;
                end
            end

            SYNC_TX: begin
                n_state_TX = PID_TX;
            end

            PID_TX: begin
                if(pID == 4'b0011) begin
                    n_state_TX = DATA_TX;
                end
                else begin
                    n_state_TX = EOP_TX;
                end
            end

            DATA_TX: begin
                if(packet_load_complete_TX) begin
                    n_state_TX = CRC_TX;
                end
                else begin
                    n_state_TX = c_state_TX;
                end
            end

            CRC_TX: begin
                n_state_TX = EOP_TX;
            end

            EOP_TX: begin
                if(complete_TX) begin
                    n_state_TX = IDLE_TX;
                end
            end

        endcase
    end

    always_comb begin
        TX_Transfer_Active = 1'b1;
        TX_Error = 1'b0;
        byte_ready_TX = 1'b0;
        byte_TX = 8'b0;

        case(c_state_TX)
            IDLE_TX: begin
                TX_Transfer_Active = 1'b0;
            end

            ERROR_TX: begin
                TX_Error = 1'b1;
            end

            SYNC_TX: begin
                byte_read_TX = 1'b1;
                byte_TX = 8'b00000001;
            end

            PID_TX: begin
                byte_read_TX = 1'b1;
                byte_TX = {4'b0, pID};
            end

            // Nothing changes during DATA_TX

            CRC_TX: begin
                byte_read_TX = 1'b1;
                byte_TX = 8'b11111111;
            end

            // Nothing changes during EOP_TX


        endcase
    end

endmodule