`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_USB_Buffer_Counter ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;
    logic clear, countUP_enable, countDOWN_enable, rollover_flag;
    logic [9:0] rollover_val, count_out;

    // clockgen
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    task test_count (
        input logic cl, cUe, cDe,
        input logic [9:0] rv
    );
        clear = cl;
        countUP_enable = cUe;
        countDOWN_enable = cDe;
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


    USB_Buffer_Counter #(.SIZE(10), .INC_SIZE(1)) DUT (
    .clk(clk), .n_rst(n_rst),
    .clear(clear), .countUP_enable(countUP_enable), .countDOWN_enable(countDOWN_enable),
    .rollover_val(rollover_val), .count_out(count_out), .rollover_flag(rollover_flag)
    );

    initial begin
        n_rst = 1;
        clear = 1'b0;
        countUP_enable = 1'b0;
        countDOWN_enable = 1'b0;
        rollover_val = 4'b0;

        reset_dut;

        test_count(1'b0, 1'b1, 1'b0, 4'd10);
        test_count(1'b0, 1'b1, 1'b0, 4'd10);
        test_count(1'b0, 1'b1, 1'b0, 4'd10);
        test_count(1'b0, 1'b1, 1'b0, 4'd10);
        test_count(1'b0, 1'b1, 1'b0, 4'd10);
        test_count(1'b0, 1'b1, 1'b0, 4'd10);

        test_count(1'b0, 1'b0, 1'b1, 4'd10);
        test_count(1'b0, 1'b0, 1'b1, 4'd10);
        test_count(1'b0, 1'b0, 1'b1, 4'd10);
        test_count(1'b0, 1'b0, 1'b1, 4'd10);
        test_count(1'b0, 1'b0, 1'b1, 4'd10);
        test_count(1'b0, 1'b0, 1'b1, 4'd10);

        $finish;
    end
endmodule

/* verilator coverage_on */

