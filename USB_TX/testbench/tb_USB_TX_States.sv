`timescale 1ns / 10ps
/* verilator coverage_off */

    
module tb_USB_TX_States ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;
    logic packet_load_complete_TX, complete_TX;
    logic TX_Transfer_Active, TX_Error;
    logic [2:0] out_state_TX;
    logic [3:0] TX_Packet, pID;

    // clockgen
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    task set_seq(
        input logic pk_ld_cmp, cmp,
        input logic [3:0] tx_pk
    );

        packet_load_complete_TX = pk_ld_cmp;
        complete_TX = cmp;
        TX_Packet = tx_pk;

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

    USB_TX_States #() DUT (
        .clk(clk), .n_rst(n_rst), 
        .packet_load_complete_TX(packet_load_complete_TX),
        .complete_TX(complete_TX),
        .TX_Packet(TX_Packet), .TX_Transfer_Active(TX_Transfer_Active),
        .TX_Error(TX_Error),
        .out_state_TX(out_state_TX),
        .pID(pID)
    );

    initial begin
        n_rst = 1;
        packet_load_complete_TX = 1'b0;
        complete_TX = 1'b0;
        TX_Packet = 4'b0;

        reset_dut;

        
        // ACK
        set_seq(1'b0, 1'b0, 4'b0010);
        set_seq(1'b0, 1'b0, 4'b0000); // SYNC
        set_seq(1'b0, 1'b0, 4'b0000); // PID
        set_seq(1'b0, 1'b0, 4'b0000); // EOP
        set_seq(1'b0, 1'b1, 4'b0000); // EOP
        set_seq(1'b0, 1'b0, 4'b0000); // IDLE
        reset_dut;

        // NAK
        set_seq(1'b0, 1'b0, 4'b1010);
        set_seq(1'b0, 1'b0, 4'b0000); // SYNC
        set_seq(1'b0, 1'b0, 4'b0000); // PID
        set_seq(1'b0, 1'b0, 4'b0000); // EOP
        set_seq(1'b0, 1'b1, 4'b0000); // EOP
        set_seq(1'b0, 1'b0, 4'b0000); // IDLE
        reset_dut;

        // STALL
        set_seq(1'b0, 1'b0, 4'b1110);
        set_seq(1'b0, 1'b0, 4'b0000); // SYNC
        set_seq(1'b0, 1'b0, 4'b0000); // PID
        set_seq(1'b0, 1'b0, 4'b0000); // EOP
        set_seq(1'b0, 1'b1, 4'b0000); // EOP
        set_seq(1'b0, 1'b0, 4'b0000); // IDLE
        reset_dut;


        // DATA0
        set_seq(1'b0, 1'b0, 4'b0011);
        set_seq(1'b0, 1'b0, 4'b0000); // SYNC
        set_seq(1'b0, 1'b0, 4'b0000); // PID
        set_seq(1'b0, 1'b0, 4'b0000); // DATA
        set_seq(1'b0, 1'b0, 4'b0000); // DATA
        set_seq(1'b1, 1'b0, 4'b0000); // DATA
        set_seq(1'b0, 1'b0, 4'b0000); // CRC
        set_seq(1'b0, 1'b0, 4'b0000); // EOP
        set_seq(1'b0, 1'b1, 4'b0000); // EOP
        set_seq(1'b0, 1'b0, 4'b0000); // IDLE
        reset_dut;
        

        // ERROR and IDLE
        set_seq(1'b0, 1'b0, 4'b0001); // ERROR
        set_seq(1'b0, 1'b0, 4'b0000); // IDLE
        set_seq(1'b0, 1'b0, 4'b1011); // ERROR
        set_seq(1'b0, 1'b0, 4'b0011); // DATA0
        set_seq(1'b0, 1'b0, 4'b0000); // SYNC
        set_seq(1'b0, 1'b0, 4'b0000); // PID
        set_seq(1'b0, 1'b0, 4'b0000); // DATA0
        set_seq(1'b0, 1'b0, 4'b0000); // DATA0


        $finish;
    end
endmodule

/* verilator coverage_on */
