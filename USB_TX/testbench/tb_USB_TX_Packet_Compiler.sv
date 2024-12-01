`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_USB_TX_Packet_Compiler ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;
    logic [2:0] c_state_TX;
    logic [3:0] pID;
    logic [6:0] Buffer_Occupancy;
    logic [7:0] TX_Packet_Data;
 
    logic Get_TX_Packet_Data, packet_load_complete_TX;
    logic [9:0] packet_counter_TX;
    logic [543:0] packet_TX;

    logic copy_signal;

    // clockgen
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    task compile_seq(
        input logic [2:0] cs,
        input logic [6:0] bo,
        input logic [7:0] pd,
        input logic [3:0] pid
    );
        c_state_TX = cs;
        Buffer_Occupancy = bo;
        TX_Packet_Data = pd;
        pID = pid;
        #(CLK_PERIOD);
        
    endtask

    task reset_dut;
    begin
        n_rst = 0;
        @(posedge clk);
        @(posedge clk);
        @(negedge clk);
        n_rst = 1;
        @(posedge clk);
        @(posedge clk);
    end
    endtask


    USB_TX_Packet_Compiler DUT (
        .clk(clk), .n_rst(n_rst),
        .c_state_TX(c_state_TX), .Buffer_Occupancy(Buffer_Occupancy),
        .TX_Packet_Data(TX_Packet_Data), .pID(pID), .copy_signal(copy_signal),
        .Get_TX_Packet_Data(Get_TX_Packet_Data), .packet_load_complete_TX(packet_load_complete_TX),
        .packet_counter_TX(packet_counter_TX), .packet_TX(packet_TX)
    );



    initial begin
        n_rst = 1;
        c_state_TX = 3'b0; // IDLE
        Buffer_Occupancy = 7'b0;
        TX_Packet_Data = 8'b0;
        pID = 4'b0; // IDLE

        reset_dut;

        // compile_seq(3'd0, 7'b0, 8'b0, 4'b0011); // IDLE
        // compile_seq(3'd1, 7'd4, 8'd0, 4'b0011); // SYNC
        // compile_seq(3'd2, 7'd4, 8'b0, 4'b0011); // PID
        // compile_seq(3'd4, 7'd4, 8'b00000000, 4'b0011); // DATA
        // compile_seq(3'd4, 7'd3, 8'b11111111, 4'b0011); // DATA 1
        // compile_seq(3'd4, 7'd2, 8'b10101010, 4'b0011); // DATA 2
        // compile_seq(3'd4, 7'd1, 8'b10001000, 4'b0011); // DATA 3
        // compile_seq(3'd4, 7'd0, 8'b01110111, 4'b0011); // DATA 4
        // compile_seq(3'd5, 7'd0, 8'b0, 4'b0011); // Complete
        // compile_seq(3'd3, 7'd0, 8'b0, 4'b0011); // Complete
        // compile_seq(3'd3, 7'd0, 8'b0, 4'b0011); // Complete
        // compile_seq(3'd3, 7'd0, 8'b0, 4'b0011); // Complete

        compile_seq(3'd0, 7'b0, 8'b0, 4'b0010); // IDLE
        compile_seq(3'd1, 7'd0, 8'd0, 4'b0010); // SYNC
        compile_seq(3'd2, 7'd0, 8'b0, 4'b0010); // PID
        compile_seq(3'd3, 7'd0, 8'b0, 4'b0010); // EOP
        compile_seq(3'd3, 7'd0, 8'b0, 4'b0010); // Complete
        compile_seq(3'd3, 7'd0, 8'b0, 4'b0010); // Complete
        compile_seq(3'd3, 7'd0, 8'b0, 4'b0010); // Complete


        $finish;
    end
endmodule

/* verilator coverage_on */

