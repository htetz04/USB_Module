`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_USB_TX_Counter ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;
    logic clear, count_enable, rollover_flag;
    logic [9:0] rollover_val, count_out;

    // clockgen
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    task test_count (
        input logic cl, ce,
        input logic [9:0] rv
    );
        clear = cl;
        count_enable = ce;
        rollover_val = rv;
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

    USB_TX_Counter #(.SIZE(10), .INC_SIZE(8)) DUT (
        .clk(clk), .n_rst(n_rst), .clear(clear),
        .count_enable(count_enable), .rollover_val(rollover_val),
        .count_out(count_out), .rollover_flag(rollover_flag)
    );

    initial begin
        n_rst = 1;
        clear = 1'b0;
        count_enable = 1'b0;
        rollover_val = 4'b0;

        reset_dut;
        /*
        test_count(1'b0, 1'b1, 4'd5);
        test_count(1'b0, 1'b1, 4'd5);
        test_count(1'b0, 1'b1, 4'd5);
        test_count(1'b0, 1'b1, 4'd5);
        test_count(1'b0, 1'b1, 4'd5);
        test_count(1'b0, 1'b1, 4'd5);
        test_count(1'b0, 1'b1, 4'd5);
        test_count(1'b0, 1'b1, 4'd5);
        test_count(1'b0, 1'b1, 4'd5);
        test_count(1'b0, 1'b1, 4'd5);
        test_count(1'b0, 1'b1, 4'd5);
        */

        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);
        test_count(1'b0, 1'b1, 10'd544);

        $finish;
    end
endmodule

/* verilator coverage_on */

