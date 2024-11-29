`timescale 1ns / 10ps

module ahb_usb_sat ( 
   input logic clk,
   input logic n_rst,
   input logic hsel,
   input logic [3:0] haddr,
   input logic [1:0] htrans,
   input logic [2:0] hsize,
   input logic hwrite,
   input logic [31:0] hwdata,
   input logic [2:0] hburst,
   output logic [31:0] hrdata,
   output logic hresp,
   output logic hready,
   input logic [3:0] rx_packet,
   input logic rx_data_ready,
   input logic rx_transfer_active,
   input logic rx_error,
   output logic d_mode,
   input logic [6:0] buffer_occupancy,
   input logic [7:0] rx_data,
   output logic get_rx_data,
   output logic store_tx_data,
   output logic [7:0] tx_data,
   output logic clear,
   output logic [3:0] tx_packet,
   input logic tx_transfer_active,
   input logic tx_error
);

logic [1:0] htrans_sync;
logic hsel_sync, hwrite_sync;
logic [1:0] hsize_sync;
logic [3:0] haddr_sync;

localparam OUT = 4'b0001;
localparam IN = 4'b1001;
localparam DATA0 = 4'b0011;
localparam DATA1 = 4'b1011;
localparam ACK = 4'b0010;
localparam NACK = 4'b1010;
localparam STALL = 4'b1110;
localparam IDLE = 4'b0000;


// REGISTER WRITE INPUTS
always_ff @ (negedge n_rst, posedge clk) begin
   if (!n_rst) begin
       htrans_sync <= 0;
       hsel_sync <= 0;
       hwrite_sync <= 0;
       haddr_sync <= 0;
       hsize_sync <= 0;
   end else begin
       htrans_sync <= htrans;
       hsel_sync <= hsel;
       hwrite_sync <= hwrite;
       haddr_sync <= haddr;
       hsize_sync <= hsize;
   end
end

//Buffer Occupancy Block
logic [31:0] buffer_occupancy_reg;
always_comb begin
   buffer_occupancy_reg = buffer_occupancy;
end

//Status Register Block
logic [31:0] status_reg;
always_comb begin
   status_reg = 0;
   status_reg[0] = rx_data_ready;
   status_reg[1] = rx_packet == IN;
   status_reg[2] = rx_packet == OUT;
   status_reg[3] = rx_packet == ACK;
   status_reg[4] = rx_packet == NACK;
   status_reg[8] = rx_transfer_active;
   status_reg[9] = rx_transfer_active;
end

//Error Register Block
logic [31:0] error_reg;
always_comb begin
   error_reg = 0;
   error_reg[0] = rx_error;
   error_reg[8] = tx_error;
end

//TX PACKET BLOCK
logic [31:0] tx_packet_control_reg;

always_comb begin
   tx_packet = IDLE;
   if (tx_transfer_active == 0)
       tx_packet = IDLE;
   else if (tx_packet_control_reg == 1)
       tx_packet = DATA0;
   else if (tx_packet_control_reg == 2)
       tx_packet = ACK;
   else if (tx_packet_control_reg == 3)
       tx_packet = NACK;
   else if (tx_packet_control_reg == 4)
       tx_packet = STALL;

end
logic [3:0] cnt, n_cnt;
logic thresp, hresp1, hresp2;
//HRESP BLOCK
always_comb begin
   thresp = 0;
   if (hsel) begin
       if (htrans == 2'b10) begin
       if (hwrite) begin
           if ((haddr == 4'd4) || (haddr == 4'd5) || (haddr == 4'd6) || (haddr == 4'd7) || (haddr == 4'd8) || (haddr > 4'hD)) begin
               thresp = 1;
               //$display("1");
           end else if ((haddr == 4'hC) || (haddr == 4'hD) || (haddr < 4'd4))begin
               thresp = 0;
           end else
               thresp = 1;
       end else begin
           if ((haddr == 4'd9) || (haddr == 4'd10) || (haddr == 4'd11) || (haddr > 4'hD)) begin
               thresp = 1;
               //$display("3");
            end else begin
               thresp = 0;
            end
       end
   end
end
end

always_ff @(posedge clk, negedge n_rst) begin

if (!n_rst) begin
   hresp1 <= 0;
   hresp2 <= 0;
end else begin
   hresp1 <= thresp;
   hresp2 <= hresp1;
end
end

assign hresp = thresp || hresp1;

//D_MODE BLOCK
always_comb begin
   d_mode = 0;
   if (status_reg[8] == 1)
       d_mode = 0;
   else if (status_reg[9] == 1)
       d_mode = 1;
end


//WRITE COMB BLOCK
logic [31:0] n_data_buffer_reg, data_buffer_store, n_tx_store, tx_store, n_tx_packet_control_reg, n_flush_buffer_control_reg, flush_buffer_control_reg;
always_comb begin

   n_data_buffer_reg = data_buffer_store;
   n_tx_store = tx_store;
   n_tx_packet_control_reg = tx_packet_control_reg;
   n_flush_buffer_control_reg = flush_buffer_control_reg;
   n_tx_store = 0;
         

   if (hsel && (htrans_sync == 2'b10)) begin
       if (hwrite_sync) begin
           if (hsize_sync == 2'd2) begin
               
               case (haddr_sync)
                   8'h0, 8'h1, 8'h2, 8'h3: begin
                       n_data_buffer_reg = hwdata;
                       n_tx_store = 4'b1111;
                   end
                   8'hC: n_tx_packet_control_reg = hwdata;
                   
                   8'hD: n_flush_buffer_control_reg = hwdata[7:0];
               endcase
           end
           else if (hsize_sync == 1) begin
               case (haddr_sync)
                   8'h0, 8'h1: begin
                       n_tx_store = 4'b0011;
                       n_data_buffer_reg = {16'h0, hwdata[15:0]};
                   end
                   8'h2, 8'h3: begin
                       n_tx_store = 4'b1100;
                       n_data_buffer_reg = {hwdata[31:16], 16'h0};
                   end
                   8'hC: n_tx_packet_control_reg = hwdata[7:0];
                   8'hD: n_flush_buffer_control_reg = hwdata[7:0];
               endcase
           end
           else if (hsize_sync == 0) begin
               case (haddr_sync)
                   8'h0:begin
                       n_tx_store = 4'b0001;
                       n_data_buffer_reg = {24'h0, hwdata[7:0]};
                   end
                   8'h1: begin
                       n_tx_store = 4'b0010;
                       n_data_buffer_reg = {16'h0, hwdata[15:8], 8'h0};
                   end
                   8'h2:begin
                       n_tx_store = 4'b0100;
                       n_data_buffer_reg = {8'h0, hwdata[23:16], 16'h0};
                   end
                   8'h3:begin
                       n_tx_store = 4'b1000;
                       n_data_buffer_reg = {hwdata[31:24], 24'h0};
                   end
                   8'hC: n_tx_packet_control_reg = hwdata[7:0];
                   8'hD: n_flush_buffer_control_reg = hwdata[7:0];
               endcase
           end
       end
   end

   if (hsel_sync && tx_store != 0 && (cnt != 0))
       n_tx_store = tx_store;
   
end

//HREADY LOGIC BLOCK
logic reg_filled, buffer_filled;
always_comb begin
   hready = 1;
   if (hresp && htrans == 2'b10)
       hready = 0;
   // if (hwrite_sync && hsel_sync && (htrans_sync == 2'b10) && 
   // ((haddr_sync == 4'd0) || (haddr_sync == 4'd1) || (haddr_sync == 4'd2) || (haddr_sync == 4'd3))) begin
   if ((n_tx_store != 0)) begin
       if (!buffer_filled)
           hready = 0;
       else
           hready = 1;
   end
   if (!hwrite && hsel && (htrans == 2'b10) && 
   ((haddr == 4'd0) || (haddr == 4'd1) || (haddr == 4'd2) || (haddr == 4'd3)) && (get_rx_data)) begin
       if (!reg_filled && (cnt != 6))
           hready = 0;
   end
end

//tx_store ff block
always_ff @(posedge clk, negedge n_rst) begin
   if (!n_rst)
       tx_store <= 0;
   else 
       tx_store <= n_tx_store;
end

//WRITE Register FF Block

always_ff @(posedge clk, negedge n_rst) begin
   if (!n_rst) begin
       data_buffer_store <= 0;
       tx_packet_control_reg <= 0;
       flush_buffer_control_reg <= 0;
   end else begin
       data_buffer_store <= n_data_buffer_reg;
       tx_packet_control_reg <= n_tx_packet_control_reg;
       flush_buffer_control_reg <= n_flush_buffer_control_reg;
   end
end

assign clear = (flush_buffer_control_reg == 1);
logic [31:0] data_buffer_reg;

//TX BLOCK

always_comb begin
   n_cnt = cnt;
   buffer_filled = 0;
   store_tx_data = 0;
   tx_data = 0;

   if (cnt == 4) begin
       //tx_store = 0;
       n_cnt = 0;
       buffer_filled = 1;
   end

   if (n_tx_store != 0) begin
       if (n_tx_store[cnt]) begin
           case (cnt)
               0: begin
                   tx_data = n_data_buffer_reg[7:0];
                   store_tx_data = 1;
               end
               1: begin
                   tx_data = data_buffer_store[15:8];
                   store_tx_data = 1;
               end
               2: begin
                   tx_data = data_buffer_store[23:16];
                   store_tx_data = 1;
               end
               3: begin
                   tx_data = data_buffer_store[31:24];
                   store_tx_data = 1;
               end
           endcase
       end
       if (cnt < 4)
           n_cnt += 1;
       else    
           n_cnt = 0;
   end
   
end

always_ff @ (posedge clk, negedge n_rst) begin
   if (!n_rst)
       cnt <= 0;
   else 
       cnt <= n_cnt;
end

logic start_rx;


//RX BLOCK
logic [3:0] rx_cnt, n_rx_cnt;
always_comb begin
   n_rx_cnt = rx_cnt;
   reg_filled = 0;
   get_rx_data = 0;


   if (!hwrite && hsel && (htrans == 2'b10) && (haddr < 4'd4)) begin
       //data_buffer_reg[7:0] = rx_data;

       case (rx_cnt)
            0: begin
               get_rx_data = 1;
               n_rx_cnt += 1;
            end

           1: if (hsize > 0) begin
               data_buffer_reg = {24'b0, rx_data};
               n_rx_cnt += 1;
               get_rx_data = 1;
           end else begin
               data_buffer_reg = {24'b0, rx_data};
               reg_filled = 1;
               n_rx_cnt = 5;
               start_rx = 0;
           end

           2: if (hsize > 1) begin
               data_buffer_reg[15:8] = rx_data;
               n_rx_cnt += 1;
               get_rx_data = 1;
           end else begin
               data_buffer_reg[15:8] = rx_data;
               reg_filled = 1;
               n_rx_cnt = 5;
               start_rx = 0;
           end

           3:  begin
               data_buffer_reg[23:16] = rx_data;
               n_rx_cnt += 1;
               get_rx_data = 1;
           end


           4: begin
               data_buffer_reg[31:24] = rx_data;
               reg_filled = 1;
               n_rx_cnt = 5;
               get_rx_data = 0;
               start_rx = 0;
           end
           5: begin
               reg_filled = 1;
               n_rx_cnt = 6;
           end
           6: begin
               n_rx_cnt = 0;
           end
           
       endcase
   end else
       data_buffer_reg = 0;
end

always_ff @ (posedge clk, negedge n_rst) begin
   if (!n_rst)
       rx_cnt <= 0;
   else 
       rx_cnt <= n_rx_cnt;
end

//READ BLOCK
logic [31:0] n_hrdata;
always_comb begin
   n_hrdata = hrdata;
   if (hsel && !hwrite && (htrans == 2'b10)) begin
       // if ((hwrite_sync && !hwrite) && (haddr == haddr_sync)) begin
       //     n_hrdata = hwdata;24'b0, 24'b0, 
       // end else begin
            if (hsize == 2'd2) begin
               case (haddr)
                   8'h0, 8'h1, 8'h2, 8'h3: n_hrdata = data_buffer_reg;
                   8'h4, 8'h5: n_hrdata = status_reg;
                   8'h6, 8'h7: n_hrdata = error_reg;
                   8'h8: n_hrdata = buffer_occupancy_reg;
                   8'hC: n_hrdata = n_tx_packet_control_reg;
                   8'hD: n_hrdata = n_flush_buffer_control_reg;

               endcase
           end
           else if (hsize == 2'd1) begin
               case (haddr)
                   8'h0, 8'h1: n_hrdata = {16'b0, data_buffer_reg[15:0]};
                   8'h2, 8'h3: n_hrdata = {data_buffer_reg[31:16], 16'b0};
                   8'h4, 8'h5: n_hrdata = {16'b0, status_reg[15:0]};
                   8'h6, 8'h7: n_hrdata = {16'b0, error_reg[15:0]};
                   8'h8: n_hrdata = {16'b0, buffer_occupancy_reg};
                   8'hC: n_hrdata = {16'b0, n_tx_packet_control_reg};
                   8'hD: n_hrdata = {16'b0, n_flush_buffer_control_reg};
               endcase
           end else if (hsize == 2'd0) begin
               case (haddr)
                   8'h0: n_hrdata = {24'b0, data_buffer_reg[7:0]};
                   8'h1: n_hrdata = {16'b0, data_buffer_reg[15:8], 8'b0};
                   8'h2: n_hrdata = {8'b0, data_buffer_reg[23:16], 16'b0};
                   8'h3: n_hrdata = {data_buffer_reg[31:24], 24'b0};
                   8'h4: n_hrdata = {24'b0, status_reg[7:0]};
                   8'h5: n_hrdata = {16'b0, status_reg[15:8], 8'b0};
                   8'h6: n_hrdata = {24'b0, error_reg[7:0]};
                   8'h7: n_hrdata = {16'b0, error_reg[15:8], 8'b0};
                   8'h8: n_hrdata = {24'b0, buffer_occupancy_reg[7:0]};
                   8'hC: n_hrdata = {24'b0, n_tx_packet_control_reg[7:0]};
                   8'hD: n_hrdata = {24'b0, n_flush_buffer_control_reg[7:0]};
               endcase
       end
   end
end


always_ff @ (posedge clk, negedge n_rst) begin
   if (!n_rst) begin
       hrdata <= 0;
   end else begin
       hrdata <= n_hrdata;
   end
end

endmodule

