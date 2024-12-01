`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_USB_TX ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;
    logic [3:0] TX_Packet;
    logic [6:0] Buffer_Occupancy;
    logic [7:0] TX_Packet_Data;
    logic TX_Transfer_Active, TX_Error;
    logic DP_OUT, DM_OUT;

    // clockgen
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    task TX_seq(
        input logic [3:0] txP,
        input logic [6:0] bo,
        input logic [7:0] txD
    );
        TX_Packet = txP;
        Buffer_Occupancy = bo;
        TX_Packet_Data = txD;
        #(CLK_PERIOD);
    endtask

    task wait_seq();
        TX_seq(4'b0, 7'd0, 8'b0);
        TX_seq(4'b0, 7'd0, 8'b0);
        TX_seq(4'b0, 7'd0, 8'b0);
        TX_seq(4'b0, 7'd0, 8'b0);
        TX_seq(4'b0, 7'd0, 8'b0);
        TX_seq(4'b0, 7'd0, 8'b0);
        TX_seq(4'b0, 7'd0, 8'b0);
        TX_seq(4'b0, 7'd0, 8'b0);
        TX_seq(4'b0, 7'd0, 8'b0);
        TX_seq(4'b0, 7'd0, 8'b0);
        TX_seq(4'b0, 7'd0, 8'b0); 
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

    USB_TX DUT (
        .clk(clk), .n_rst(n_rst),
        .TX_Packet(TX_Packet), .Buffer_Occupancy(Buffer_Occupancy),
        .TX_Packet_Data(TX_Packet_Data), .TX_Transfer_Active(TX_Transfer_Active), .TX_Error(TX_Error),
        .DP_OUT(DP_OUT), .DM_OUT(DM_OUT)
    );

    initial begin
        n_rst = 1;
        TX_Packet = 4'b0;
        Buffer_Occupancy = 7'b0;
        TX_Packet_Data = 8'b0;
        reset_dut;

        // ALTER USB_TX_STATES SO THAT IT WILL LOAD UNTIL BUFFER OCCUPANCY IS EQUAL TO 0

        TX_seq(4'b0, 7'b0, 8'b0);
        TX_seq(4'b1110, 7'b0, 8'b0);
        wait_seq();
        wait_seq();
        wait_seq();
        wait_seq();
        wait_seq();
        wait_seq();
        wait_seq();
        wait_seq();
        wait_seq();
        wait_seq();
        wait_seq();
        wait_seq();
        wait_seq();
        wait_seq();
        wait_seq();
        wait_seq();
        wait_seq();
        wait_seq();
        
        

        $finish;
    end
endmodule

/* verilator coverage_on */

