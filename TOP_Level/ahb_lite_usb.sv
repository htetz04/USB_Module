`timescale 1ns / 10ps

module ahb_lite_usb ( 
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
   input logic dp_in,
   input logic dm_in,
   output logic dp_out,
   output logic dm_out,
   output logic d_mode
);

logic [3:0] rx_packet, tx_packet;
logic rx_data_ready, rx_transfer_active, rx_error, get_rx_data, store_tx_data, clear, tx_transfer_active, tx_error, flush, store_rx_packet_data, get_tx_packet_data;
logic [6:0] buffer_occupancy;
logic [7:0] rx_data, tx_data, rx_packet_data, tx_packet_data;

ahb_usb_sat SAT (.clk(clk), .n_rst(n_rst), .hsel(hsel), .haddr(haddr), .htrans(htrans), .hsize(hsize), .hwrite(hwrite), .hwdata(hwdata), .hburst(hburst), .hrdata(hrdata), .hresp(hresp), .hready(hready),
 .rx_packet(rx_packet), .rx_data_ready(rx_data_ready), .rx_transfer_active(rx_transfer_active), .rx_error(rx_error), .d_mode(d_mode), .buffer_occupancy(buffer_occupancy), .rx_data(rx_data), .get_rx_data(get_rx_data), .store_tx_data(store_tx_data), .tx_data(tx_data), .clear(clear), .tx_packet(tx_packet), .tx_transfer_active(tx_transfer_active), .tx_error(tx_error));

usb_rx RX (.clk(clk), .n_rst(n_rst), .dp_in(dp_in), .dm_in(dm_in), .flush(flush), .rx_packet(rx_packet), .rx_data_ready(rx_data_ready), .rx_transfer_active(rx_transfer_active), .rx_error(rx_error), .store_rx_packet_data(store_rx_packet_data), .rx_packet_data(rx_packet_data), .buffer_occupancy(buffer_occupancy));

USB_TX TX (.clk(clk), .n_rst(n_rst), .dp_out(dp_out), .dm_out(dm_out), .buffer_occupancy(buffer_occupancy), .get_tx_packet_data(get_tx_packet_data), .tx_packet_data(tx_packet_data), .tx_packet(tx_packet), .tx_transfer_active(tx_transfer_active), .tx_error(tx_error));

USB_Buffer DB (.clk(clk), .n_rst(n_rst), .buffer_occupancy(buffer_occupancy), .flush(flush), .store_rx_packet_data(store_rx_packet_data), .rx_packet_data(rx_packet_data), .get_tx_packet_data(get_tx_packet_data), .tx_packet_data(tx_packet_data), .clear(clear), .tx_data(tx_data), .store_tx_data(store_tx_data), .get_rx_data(get_rx_data), .rx_data(rx_data));



endmodule