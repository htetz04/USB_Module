`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_ahb_usb_sat ();

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
       // bus model signals
   logic enqueue_transaction_en;
   logic transaction_write;
   logic transaction_fake;
   logic [3:0] transaction_addr;
   bit [31:0] transaction_data [1];
   logic transaction_error;
   logic [2:0] transaction_size;
   logic [2:0] transaction_burst;

   logic model_reset;
   logic enable_transactions;
   integer current_transaction_num;
   logic current_transaction_error;

   logic hsel;
   logic [1:0] htrans;
   logic [3:0] haddr;
   logic [2:0] hsize;
   logic hwrite;
   logic [31:0] hwdata;
   logic [31:0] hrdata;
   logic hresp;
   logic hready;
   logic [31:0] current_addr_beat_num, current_addr_transaction_num, current_data_beat_num, current_data_transaction_num;
   logic  current_addr_transaction_error, current_data_transaction_error;

   ahb_lite_model_adv #(4,4) BFM (.clk(clk),
       // Testing setup signals
       .enqueue_transaction(enqueue_transaction_en),
       .transaction_write(transaction_write),
       .transaction_fake(transaction_fake),
       .transaction_addr(transaction_addr),
       .transaction_data(transaction_data),
       .transaction_error(transaction_error),
       .transaction_size(transaction_size),
       // Testing controls
       .model_reset(model_reset),
       .enable_transactions(enable_transactions),
       .current_addr_transaction_num(current_addr_transaction_num),
       .current_addr_beat_num(current_addr_beat_num),
       .current_addr_transaction_error(current_addr_transaction_error),
       .current_data_transaction_num(current_data_transaction_num),
       .current_data_beat_num(current_data_beat_num),
       .current_data_transaction_error(current_data_transaction_error),

       // AHB-Lite-Satellite Side
       .hsel(hsel),
       .htrans(htrans),
       .haddr(haddr),
       .hsize(hsize),
       .hwrite(hwrite),
       .hwdata(hwdata),
       .hrdata(hrdata),
       .hresp(hresp),
       .hready(hready)
   );

   // bus model tasks
   task reset_model;
   begin
       model_reset = 1'b1;
       #(0.1);
       model_reset = 1'b0;
   end
   endtask
   
   task enqueue_transaction;
       input logic for_dut;
       input logic write_mode;
       input logic [3:0] address;
       input bit [31:0] data;
       input logic expected_error;
       input logic [1:0] size;
   begin
       // Make sure enqueue flag is low (will need a 0->1 pulse later)
       enqueue_transaction_en = 1'b0;
       #(0.1ns);
   
       // Setup info about transaction
       transaction_fake  = ~for_dut;
       transaction_write = write_mode;
       transaction_addr  = address;
       transaction_data[0]  = data;
       transaction_error = expected_error;
       transaction_size  = {1'b0,size};
       transaction_burst = 0;
   
       // Pulse the enqueue flag
       enqueue_transaction_en = 1'b1;
       #(0.1ns);
       enqueue_transaction_en = 1'b0;
   end
   endtask
   
   task execute_transactions;
       input integer num_transactions;
       integer wait_var;
   begin
       // Activate the bus model
       enable_transactions = 1'b1;
       @(posedge clk);
   
       // Process the transactions (all but last one overlap 1 out of 2 cycles
       for(wait_var = 0; wait_var < num_transactions; wait_var++) begin
            if (hready == 1)
           @(posedge clk);
       end
   
       // Run out the last one (currently in data phase)
       @(posedge clk);
   
       // Turn off the bus model
       @(negedge clk);
       enable_transactions = 1'b0;
   end
   endtask
   logic [3:0] rx_packet;
   logic [3:0] tx_packet;
   logic [6:0] buffer_occupancy;
   logic [7:0] rx_data, tx_data;
   logic rx_data_ready, rx_transfer_active, rx_error, d_mode, get_rx_data, store_tx_data, clear, tx_transfer_active, tx_error;
   logic [2:0] hburst;

   ahb_usb_sat DUT (.clk(clk), .n_rst(n_rst), .hsel(hsel), .haddr(haddr), .htrans(htrans), .hsize(hsize), .hwrite(hwrite), .hwdata(hwdata), .hburst(hburst), .hrdata(hrdata), .hresp(hresp), .hready(hready),
   .rx_packet(rx_packet), .rx_data_ready(rx_data_ready), .rx_transfer_active(rx_transfer_active), .rx_error(rx_error), .d_mode(d_mode), .buffer_occupancy(buffer_occupancy), .rx_data(rx_data), .get_rx_data(get_rx_data), .store_tx_data(store_tx_data),
   .tx_data(tx_data), .clear(clear), .tx_packet(tx_packet), .tx_transfer_active(tx_transfer_active), .tx_error(tx_error));

   integer i = 0;
   string testbenchname;

   initial begin
       n_rst = 1;
       rx_packet = 0;
       rx_data_ready = 0;
       rx_transfer_active = 0;
       rx_error = 0;
       buffer_occupancy = 0;
       rx_data = 0;
       //tx_packet = 0;
       tx_transfer_active = 0;
       tx_error = 0;

       reset_dut;
       reset_model;

       buffer_occupancy = 1;

       testbenchname = "TX_PACKET R/W";

       enqueue_transaction(1, 1, 4'hC, 32'h00000001, 0, 1);
       execute_transactions(1);
       enqueue_transaction(1, 0, 4'hC, 32'h00000001, 0, 1);
       execute_transactions(1);
       if (hrdata != 32'h00000001)
           $display("WRITE to TX packet control register failed");

       testbenchname = "TX_PACKET R/W_SIZE_0";

        enqueue_transaction(1, 1, 4'hC, 32'h000000ff, 0, 0);
       execute_transactions(1);
       enqueue_transaction(1, 0, 4'hC, 32'h0000000f, 0, 0);
       execute_transactions(1);
       if (hrdata != 32'h000000ff)
           $display("WRITE to TX packet control register failed");

       testbenchname = "CLEAR R/W";
       enqueue_transaction(1, 1, 4'hD, 32'h00000001, 0, 1);
       execute_transactions(1);
       enqueue_transaction(1, 0, 4'hD, 32'h00000001, 0, 1);
       execute_transactions(1);
       if (hrdata != 32'h00000001)
           $display("WRITE to clear packet control register failed");

       testbenchname = "ERROR R";
       rx_error = 1;
       tx_error = 1;
       enqueue_transaction(1, 0, 4'h6, 16'h00000101, 0, 1);
       execute_transactions(1);
       if (hrdata != 16'h00000101)
           $display("Read to error register failed");


       testbenchname = "DATA_BUFFER R/W";

       //Write to Data Buffer
       enqueue_transaction(1, 1, 4'h0, 32'h12345678, 0, 1);
       execute_transactions(1);

       @(negedge clk);
       @(negedge clk);
       @(negedge clk);
       @(negedge clk);
       @(negedge clk);
       @(negedge clk);

        enqueue_transaction(1, 1, 4'h1, 32'h12345678, 0, 0);
       execute_transactions(1);

       @(negedge clk);
       @(negedge clk);
       @(negedge clk);
       @(negedge clk);
       @(negedge clk);
       @(negedge clk);

       reset_dut;
       reset_model;

       rx_data = 8'h12;

       //Read from Data BUffer

       enqueue_transaction(1, 0, 4'h0, 32'h1234ABCD, 0, 2);
       execute_transactions(1);

       @(negedge clk);
       @(negedge clk);
       @(negedge clk);
       @(negedge clk);
       @(negedge clk);
       @(negedge clk);

       testbenchname = "PIPELINED";

       enqueue_transaction(1, 1, 4'hC, 16'h000f, 0, 1);
       enqueue_transaction(1, 1, 4'hd, 16'h0001, 0, 1);
       execute_transactions(2);

       enqueue_transaction(1, 0, 4'hC, 16'h000f, 0, 0);
       enqueue_transaction(1, 0, 4'hd, 16'h0001, 0, 0);
       execute_transactions(2);
       if (hrdata != 32'h0001)
           $display("PIPELINED failed");


       testbenchname = "HRESP";
       //HRESP
       enqueue_transaction(1, 0, 4'hF, 16'h000f, 0, 1);
       execute_transactions(1);

       @(negedge clk);

       enqueue_transaction(1, 1, 4'h6, 16'h000f, 0, 1);
       execute_transactions(1);

       @(negedge clk);


       
       reset_model;

       $finish;
   end
endmodule

/* verilator coverage_on */