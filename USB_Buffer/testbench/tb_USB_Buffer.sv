`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_USB_Buffer ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;
    logic Store_TX_Data, Store_RX_Packet_Data;
    logic Get_TX_Packet_Data, Get_RX_Data;
    logic flush, clear;
    logic [7:0] TX_Data, RX_Packet_Data;
    logic [6:0] Buffer_Occupancy;
    logic [7:0] TX_Packet_Data, RX_Data;

    // clockgen
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    task test_buffer (
        input logic storeTX, storeRXp, getTXp, getRX,
        input logic fl, cl,
        input logic [7:0] TX_d, RXp_d
    );
        Store_TX_Data = storeTX;
        Store_RX_Packet_Data = storeRXp;
        Get_TX_Packet_Data = getTXp;
        Get_RX_Data = getRX;
        flush = fl;
        clear = cl;
        TX_Data = TX_d;
        RX_Packet_Data = RXp_d;
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

    USB_Buffer DUT (
        .clk(clk), .n_rst(n_rst),
        .Store_TX_Data(Store_TX_Data), .Store_RX_Packet_Data(Store_RX_Packet_Data),
        .Get_TX_Packet_Data(Get_TX_Packet_Data), .Get_RX_Data(Get_RX_Data),
        .flush(flush), .clear(clear),
        .TX_Data(TX_Data), .RX_Packet_Data(RX_Packet_Data),
        .Buffer_Occupancy(Buffer_Occupancy), .TX_Packet_Data(TX_Packet_Data), .RX_Data(RX_Data)
    );



    initial begin
        n_rst = 1;
        Store_TX_Data = 1'b0;
        Store_RX_Packet_Data = 1'b0;
        Get_TX_Packet_Data = 1'b0;
        Get_RX_Data = 1'b0;
        flush = 1'b0;
        clear = 1'b0;
        TX_Data = 8'b0;
        RX_Packet_Data = 8'b0;

        reset_dut;
        // // Store_RX_Packet_Data (RX to Buffer)
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);
        // test_buffer(1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b11111111);
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);
        // test_buffer(1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b10101010);
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);

        // // Get_RX_Data (Buffer to AHB)
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 8'b0, 8'b0);
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 8'b0, 8'b0);
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);
        
        // Store_TX_Data (AHB to Buffer)
        test_buffer(1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b11110001, 8'b0);
        test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);
        test_buffer(1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b00110011, 8'b0);
        test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);

        // Get_TX_Packet_Data (Buffer to TX)
        // test_buffer(1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);
        // test_buffer(1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);


        // // Flush
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);
        // test_buffer(1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b11111111);
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);
        // test_buffer(1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b10101010);
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 8'b0, 8'b0);
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);
        // test_buffer(1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b10011001);
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);
        // test_buffer(1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b11111111);
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);
        // test_buffer(1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b00110011, 8'b0);
        // test_buffer(1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 8'b0, 8'b0);

        $finish;
    end
endmodule

/* verilator coverage_on */

