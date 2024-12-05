`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_usb_rx_counter ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;

    // clockgen
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

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

    localparam SIZE = 5;

    logic clear, count_enable;
    //logic [SIZE - 1: 0] rollover_val; removed for 889
    logic [SIZE - 1: 0] count_out;
    logic rollover_flag;

    //usb_rx_counter DUT (.clk(clk), .n_rst(n_rst), .clear(clear),
    //    .count_enable(count_enable), .rollover_val(rollover_val), .count_out(count_out),
    //    .rollover_flag(rollover_flag)
    //);

    usb_rx_counter DUT (.clk(clk), .n_rst(n_rst), .clear(clear),
        .count_enable(count_enable), .count_out(count_out),
        .rollover_flag(rollover_flag)
    );

    initial begin
        clear = 0;
        count_enable = 0;
        //rollover_val = 5'd8;

        n_rst = 1;

        reset_dut;

        #(3 * CLK_PERIOD);
        
        count_enable = 1;
        #(12 * CLK_PERIOD);

        count_enable = 0;
        clear = 1;
        #(3 * CLK_PERIOD);
        clear = 0;

        //rollover_val = 5'd9;
        count_enable = 1;
        #(60 * CLK_PERIOD);

        count_enable = 0;
        #(3 * CLK_PERIOD);


        $finish;
    end
endmodule

/* verilator coverage_on */

