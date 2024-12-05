`timescale 1ns / 10ps

module usb_rx (
    input logic clk, n_rst, dp_in, dm_in,
    input logic [6:0] buffer_occupancy,
    output logic [3:0] rx_packet,
    output logic rx_data_ready, rx_transfer_active, rx_error, flush, store_rx_packet_data,
    output logic [7:0] rx_packet_data
);

    typedef enum logic [3:0] {IDLE, SYNC_CHECK, PID_CHECK, ACK_NAK_STALL,
        EOP_ANS, TOKEN, CRC_TOKEN, EOP_TOKEN, DATA_WAIT1, DATA_WAIT2,
        DATA, CRC_DATA, EOP_DATA, ERROR, TOGGLE_STORE
    } state_t;

    state_t fsm_state, next_state;

    //CRC VALUES
    localparam TOKEN_CRC_VALUE = 5'b11011;
    localparam DATA_CRC_VALUE = 16'b1111011100110001;

    localparam ADDRESS_VALUE = 7'b1111001;

    //SYNC - this section syncs the dp_in and dm_in inputs
    logic dp_in_1, dp_in_2, dm_in_1, dm_in_2;
    logic dp_sync, dm_sync;

    always_ff @( posedge clk, negedge n_rst ) begin : syncBlock
        if (n_rst == 1'b0) begin
            dp_in_1 <= 1'b1;
            dp_in_2 <= 1'b1;
            dm_in_1 <= 1'b0;
            dm_in_2 <= 1'b0;
        end
        else begin
            dp_in_1 <= dp_in;
            dp_in_2 <= dp_in_1;
            dm_in_1 <= dm_in;
            dm_in_2 <= dm_in_1;
        end
    end
    
    //these are the signals to be used throughout rx module
    assign dp_sync = dp_in_2;
    assign dm_sync = dm_in_2;

    //#################################################################

    //EDGE DET - this detects a transition in dp_sync signal
    logic dp_edge, dp_sync_old;
    logic dm_sync_old;
    always_ff @( posedge clk, negedge n_rst ) begin : edgeDet
        if (n_rst == 1'b0) begin
            dp_sync_old <= 1'b1;
            dm_sync_old <= 1'b1;
        end
        else begin
            dp_sync_old <= dp_sync;
            dm_sync_old <= dm_sync;
        end
    end

    assign dp_edge = dp_sync_old ^ dp_sync;

    //#################################################################

    //START_CHECK - check if signal has started
    logic start_rx;
    logic eop, eop_new, eop_old;

    assign start_rx = (dp_sync == 1'b0 && dp_edge == 1'b1);

    logic data_in_progress, next_data_in_progress;

    /*
    always_ff @( posedge clk, negedge n_rst ) begin
        if (n_rst == 1'b0) begin
            data_in_progress <= 1'b0;
        end
        else begin
            data_in_progress <= next_data_in_progress;
        end
    end
    */
    
    always_comb begin : startCheck
        next_data_in_progress = data_in_progress;
        if (start_rx) begin
            next_data_in_progress = 1'b1;
        end
        //TODO COME BACK TO THIS. TOOK OUT EOP FROM THE IF
        //BECAUSE I STILL WANT TO COUNT AFTER EOP
        //NEED TO FIGURE OUT WHEN TO RESET IT
        else if (rx_error) begin
            next_data_in_progress = 1'b0;
        end
    end

    //todo seems i can just always have count enable on, clear is what matters
    logic count_enable;
    //this is original count enable. will try only disabling count if we're in IDLE
    //assign count_enable = start_rx || data_in_progress; 
    
    assign count_enable = (fsm_state != IDLE);
    
    //start rx continuously triggers on edge and dpsync 0 so
    //ORing it with data_in_progress makes sure it just stays on 

    //#################################################################

    //889 Counter
    logic clear, clkdiv;
    logic [4:0] count_out;

    always_comb begin
        clear = 0;
        //TODO CHECK IF THIS IS CORRECT HAVING FSM STATE IDLE HERE
        //BEFORE I JUST HAD COUNT ENABLE
        //if (count_enable || fsm_state == IDLE) begin
        if (count_enable) begin
            clear = 0;
        end
        else if (eop || rx_error || fsm_state == IDLE) begin
            clear = 1;
        end
    end

    usb_rx_counter DUT (.clk(clk), .n_rst(n_rst), .clear(clear),
        .count_enable(1'b1), .count_out(count_out),
        .rollover_flag(clkdiv)
    );

    //#################################################################

    //EOP DET - eop detection section
    logic next_eop_new;

    //todo validate this works with both high in a test
    logic both_dpdm_high, next_both_dpdm_high; //this is to check if both are high
    
    always_ff @( posedge clk, negedge n_rst ) begin : eopFF
        if (n_rst == 1'b0) begin
            eop_new <= 1'b0;
            eop_old <= 1'b0;
            data_in_progress <= 1'b0; //moved here
            both_dpdm_high <= 1'b0;
        end
        else begin
            eop_new <= next_eop_new;
            eop_old <= eop_new;
            data_in_progress <= next_data_in_progress; //moved here
            both_dpdm_high <= next_both_dpdm_high;
        end
    end

    always_comb begin
        next_eop_new = eop_new;
        next_both_dpdm_high = both_dpdm_high;
        if (fsm_state == IDLE) begin
            next_eop_new = 1'b0;
        end
        else if (clkdiv) begin
            next_eop_new = ~(dp_sync | dm_sync);
            next_both_dpdm_high = (dp_sync & dm_sync);
        end
    end

    assign eop = (eop_new == 1'b1) && (eop_old == 1'b1);

    //#################################################################


    //NRZI decoder - added this to make d_orig signal decoded dplus

    logic d_orig;
    logic prev_dp_sync;

    logic next_prev_dp_sync;

    always_ff @( posedge clk, negedge n_rst ) begin
        //TODO TRYING TO ADD IDLE TO THIS SO IF WE'RE IN IDLE
        //THEN PREV DPSYNC IS 1
        if (n_rst == 1'b0) begin
            prev_dp_sync <= 1'b1;
        end
        else begin
            prev_dp_sync <= next_prev_dp_sync;
        end
    end

    always_comb begin
        next_prev_dp_sync = prev_dp_sync;
        if (fsm_state == IDLE) begin
            next_prev_dp_sync = 1'b1;
        end
        else if (clkdiv) begin
            next_prev_dp_sync = dp_sync;
        end
    end

    assign d_orig = (dp_sync == prev_dp_sync);


    //#################################################################

    //8FF Serial to Parallel SR
    logic [7:0] rdata, next_rdata;

    always_ff @( posedge clk, negedge n_rst ) begin
        if (n_rst == 1'b0) begin
            rdata <= 8'b11111111;
        end
        else begin
            rdata <= next_rdata;
        end
    end

    always_comb begin
        if (clkdiv) begin
            //next_rdata = {rdata[6:0], d_orig};
            next_rdata = {d_orig, rdata[7:1]};
        end
        else begin
            next_rdata = rdata;
        end
    end


    //#################################################################

    //BYTE COUNTER - outputs anytime 8 or 16 bits have been counted

    logic [9:0] bit_count;
    logic bit16, bit8;

    always_ff @( posedge clk, negedge n_rst ) begin
        if (n_rst == 1'b0) begin
            bit_count <= 10'd0;
        end
        //TODO COME BACK TO THIS. TOOK OUT EOP FROM THE IF
        //BECAUSE I STILL WANT TO COUNT AFTER EOP
        //NEED TO FIGURE OUT WHEN TO RESET IT
        //TODO CHECK IF THIS IS CORRECT HAVING FSM STATE IDLE HERE
        //BEFORE I JUST HAD clear AND rx_error
        else if (clear || rx_error || fsm_state == IDLE) begin
            bit_count <= 10'd0;
        end
        else if (clkdiv) begin
            bit_count <= bit_count + 1;
        end
    end    


    always_comb begin
        bit16 = 1'b0;
        bit8 = 1'b0;
        if (clkdiv) begin
            if (bit_count != 0) begin
                bit16 = (bit_count % 16 == 0);
                bit8 = (bit_count % 8 == 0);
            end
        end
    end

    //#################################################################

    //BUFFER TO HOLD DATA EVERY 8 BITS
    logic [7:0] temp_data_reg;

    always_ff @( posedge clk, negedge n_rst ) begin
        if (n_rst == 1'b0) begin
            temp_data_reg <= 8'd0;
        end
        else if (bit8) begin
            temp_data_reg <= rdata;
        end
    end

    //TRYING A 16 BIT REG FOR TOKEN DATA
    logic [15:0] token_data_reg;

    always_ff @( posedge clk, negedge n_rst ) begin
        if (n_rst == 1'b0) begin
            token_data_reg <= 16'd0;
        end
        else if (fsm_state == TOKEN && bit16) begin
            token_data_reg <= {rdata, temp_data_reg};
        end
    end


    //TRYING A 24 BIT REG FOR DATA DATA
    logic [23:0] data_packet_reg;

    always_ff @( posedge clk, negedge n_rst ) begin
        if (n_rst == 1'b0) begin
            data_packet_reg <= 24'd0;
        end
        else if ((fsm_state == DATA || fsm_state == DATA_WAIT1 || fsm_state == DATA_WAIT2) && bit8) begin
            //data_packet_reg <= {data_packet_reg[15:0], rdata};
            data_packet_reg <= {rdata, data_packet_reg[23:8]};
        end
    end


    //DONT THINK I NEED THIS IF I DO THE ABOVE WITH TEMP and rdata
    //always_comb begin
    //    next_temp_data_reg = temp_data_reg;
    //    if (bit8) begin
    //        next_temp_data_reg = rdata;
    //    end
    //end

    //#################################################################

    //SYNC CHECK - check for sync byte
    logic is_sync;

    always_comb begin
        is_sync = 1'b0;
        //TODO CHANGED THIS TO RDATA INSTEAD OF TEMP_DATA_REG
        //HAVE TO USE RDATA HERE CAUSE TEMPDATA ONLY UPDATES
        //THE CLOCK CYCLE AFTER
        if (rdata == 8'b10000000) begin
            is_sync = 1'b1;
        end
    end


    //#################################################################

    //FSM
    localparam OUT_PID =   8'b11100001;
    localparam IN_PID =    8'b01101001;
    localparam DATA0_PID = 8'b11000011;
    localparam DATA1_PID = 8'b01001011;
    localparam ACK_PID =   8'b11010010;
    localparam NAK_PID =   8'b01011010;
    localparam STALL_PID = 8'b00011110;

    logic [3:0] pid_value, next_pid_value;
    logic valid_crc;
    assign valid_crc = 1'b1; //TODO: NEED TO FIX THIS

    //GOING TO REGISTER store_rx_packet_data CAUSE I ONLY WANT IT TO GO HIGH ONCE
    logic next_store_rx_packet_data;

    always_ff @( posedge clk, negedge n_rst ) begin
        if (n_rst == 0) begin
            fsm_state <= IDLE;
            pid_value <= 4'b0;
            store_rx_packet_data <= 1'b0; //TODO ADDED THIS NEW TO ONLY MAKE IT HIGH ONCE
        end
        else begin
            fsm_state <= next_state;
            pid_value <= next_pid_value;
            store_rx_packet_data <= next_store_rx_packet_data; //TODO ADDED SAME AS ABOVE
        end
    end

    always_comb begin : nextState
        next_state = fsm_state;
        next_pid_value = pid_value;
        next_store_rx_packet_data = 1'b0; //TODO TRYING THIS TO MAKE IT HIGH ONCE

        rx_packet = 4'b0000;
        rx_data_ready = 1'b0;
        rx_transfer_active = 1'b0;
        rx_error = 1'b0;
        flush = 1'b0;
        //store_rx_packet_data = 1'b0;
        //rx_packet_data = 8'd0;
        rx_packet_data = data_packet_reg[7:0];

        case (fsm_state)
            IDLE: begin
                //TODO CHANGED THIS BACK TO STARTRX FROM DATAIN PROGRESS
                next_pid_value = 4'd0;
                if (start_rx) begin
                    next_state = SYNC_CHECK;
                end
            end
            SYNC_CHECK: begin
                rx_transfer_active = 1'b1;
                flush = 1'b1;
                //Check if there is ever eop in middle of sync byte
                if (clkdiv) begin
                    if (eop_new || both_dpdm_high) begin
                        next_state = ERROR;
                    end
                end
                if (bit8 & is_sync) begin
                    next_state = PID_CHECK;
                end
                else if (bit8 & ~is_sync) begin
                    next_state = ERROR;
                end
            end
            PID_CHECK: begin
                rx_transfer_active = 1'b1;
                //Check if there is ever eop in middle of PID bits
                if (clkdiv) begin
                    if (eop_new || both_dpdm_high) begin
                        next_state = ERROR;
                    end
                end
                if (bit8) begin
                    next_pid_value = rdata[3:0];
                    if (rdata == ACK_PID || rdata == NAK_PID || rdata == STALL_PID) begin
                        next_state = ACK_NAK_STALL;
                    end
                    else if (rdata == OUT_PID || rdata == IN_PID) begin
                        next_state = TOKEN;
                    end
                    else if (rdata == DATA0_PID || rdata == DATA1_PID) begin
                        next_state = DATA_WAIT1;
                    end
                    else begin
                        next_state = ERROR;
                    end
                end
            end
            ACK_NAK_STALL: begin
                rx_transfer_active = 1'b1;
                rx_packet = pid_value;
                if (clkdiv) begin
                    if (eop_new) begin
                        next_state = EOP_ANS;
                    end
                    else begin
                        next_state = ERROR;
                    end
                end
            end
            EOP_ANS: begin
                rx_transfer_active = 1'b1;
                rx_packet = pid_value;
                if (clkdiv) begin
                    if (eop_new) begin
                        next_state = IDLE;
                    end
                    else begin
                        next_state = ERROR;
                    end
                end
            end
            TOKEN: begin
                rx_transfer_active = 1'b1;
                rx_packet = pid_value;
                //Check if there is ever eop in middle of 16 token bits
                if (clkdiv) begin
                    if (eop_new || both_dpdm_high) begin
                        next_state = ERROR;
                    end
                end
                if (bit16) begin
                    next_state = CRC_TOKEN;
                end
            end
            CRC_TOKEN: begin
                rx_transfer_active = 1'b1;
                rx_packet = pid_value;
                //TODO: added clk div if to cap it all and included eop into if
                if (clkdiv) begin
                    if (token_data_reg == {TOKEN_CRC_VALUE, 4'b0, ADDRESS_VALUE} && eop_new) begin
                        next_state = EOP_TOKEN;
                    end
                    else begin
                        next_state = ERROR;
                    end
                end
            end
            EOP_TOKEN: begin
                rx_transfer_active = 1'b1;
                rx_packet = pid_value;
                if (clkdiv) begin
                    if (eop_new) begin
                        next_state = IDLE;
                    end
                    else begin
                        next_state = ERROR;
                    end
                end
            end
            DATA_WAIT1: begin
                rx_transfer_active = 1'b1;
                rx_packet = pid_value;
                //Check if there is ever eop in middle of first 8 bits
                if (clkdiv) begin
                    if (eop_new || both_dpdm_high) begin
                        next_state = ERROR;
                    end
                end
                if (bit8) begin
                    next_state = DATA_WAIT2;
                end
            end
            DATA_WAIT2: begin
                rx_transfer_active = 1'b1;
                rx_packet = pid_value;
                //Check if there is ever eop in middle of second 8 bits
                if (clkdiv) begin
                    if (eop_new || both_dpdm_high) begin
                        next_state = ERROR;
                    end
                end
                if (bit8) begin
                    next_state = DATA;
                end
            end
            DATA: begin
                rx_transfer_active = 1'b1;
                rx_packet = pid_value;
                //Check if there is ever eop in middle of 8 bits
                if (clkdiv) begin
                    if (eop_new || both_dpdm_high) begin
                        next_state = ERROR;
                    end
                end
                if (bit8) begin
                    if (buffer_occupancy >= 7'd64) begin
                        next_state = ERROR;
                    end
                    else begin
                        next_state = TOGGLE_STORE;
                    end
                end
            end
            TOGGLE_STORE: begin
                rx_transfer_active = 1'b1;
                rx_packet = pid_value;
                next_store_rx_packet_data = 1'b1;
                next_state = CRC_DATA;
            end
            CRC_DATA: begin
                rx_transfer_active = 1'b1;
                rx_packet = pid_value;
                rx_data_ready = 1'b1;
                if (clkdiv) begin
                    if ((data_packet_reg[23:8] == DATA_CRC_VALUE) && eop_new) begin
                        next_state = EOP_DATA;
                    end
                    else if ((eop_new && (data_packet_reg[23:8] != DATA_CRC_VALUE)) || (~eop_new && (data_packet_reg[23:8] == DATA_CRC_VALUE))) begin
                        next_state = ERROR;
                    end
                    else begin
                        next_state = DATA;
                    end
                end
            end
            EOP_DATA: begin
                rx_transfer_active = 1'b1;
                rx_packet = pid_value;
                if (clkdiv) begin
                    if (eop_new) begin
                        next_state = IDLE;
                    end
                    else begin
                        next_state = ERROR;
                    end
                end
            end
            ERROR: begin
                rx_error = 1'b1;
                flush = 1'b1;
                if (clkdiv && eop_new) begin
                    next_state = IDLE;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end


endmodule
