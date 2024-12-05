onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Gray70 -radix binary /tb_usb_rx/DUT/clk
add wave -noupdate -color Gray70 -radix binary /tb_usb_rx/DUT/n_rst
add wave -noupdate -divider Inputs
add wave -noupdate -color Orange -radix binary /tb_usb_rx/DUT/buffer_occupancy
add wave -noupdate -color Orange -radix binary /tb_usb_rx/DUT/dp_in
add wave -noupdate -color Orange -radix binary /tb_usb_rx/DUT/dm_in
add wave -noupdate -divider Internal
add wave -noupdate -radix binary /tb_usb_rx/DUT/dp_sync
add wave -noupdate -radix binary /tb_usb_rx/DUT/dm_sync
add wave -noupdate -radix binary /tb_usb_rx/DUT/dp_edge
add wave -noupdate /tb_usb_rx/DUT/fsm_state
add wave -noupdate /tb_usb_rx/DUT/next_state
add wave -noupdate -radix binary /tb_usb_rx/DUT/start_rx
add wave -noupdate -radix binary /tb_usb_rx/DUT/data_in_progress
add wave -noupdate -radix binary /tb_usb_rx/DUT/eop_new
add wave -noupdate -radix binary /tb_usb_rx/DUT/eop_old
add wave -noupdate -radix binary /tb_usb_rx/DUT/eop
add wave -noupdate -divider {889 clkdiv}
add wave -noupdate /tb_usb_rx/DUT/count_enable
add wave -noupdate -radix binary /tb_usb_rx/DUT/clear
add wave -noupdate -radix decimal /tb_usb_rx/DUT/count_out
add wave -noupdate -color Yellow -radix binary /tb_usb_rx/DUT/clkdiv
add wave -noupdate -divider NRZI
add wave -noupdate -radix binary /tb_usb_rx/DUT/d_orig
add wave -noupdate -radix binary /tb_usb_rx/DUT/prev_dp_sync
add wave -noupdate -divider {8FF Ser to Par}
add wave -noupdate -radix binary /tb_usb_rx/DUT/next_rdata
add wave -noupdate -radix binary /tb_usb_rx/DUT/rdata
add wave -noupdate -radix binary /tb_usb_rx/DUT/pid_value
add wave -noupdate -radix decimal /tb_usb_rx/DUT/bit_count
add wave -noupdate -radix binary /tb_usb_rx/DUT/bit16
add wave -noupdate -radix binary /tb_usb_rx/DUT/bit8
add wave -noupdate -radix binary /tb_usb_rx/DUT/bit2
add wave -noupdate -radix binary /tb_usb_rx/DUT/temp_data_reg
add wave -noupdate -radix binary /tb_usb_rx/DUT/token_data_reg
add wave -noupdate -radix binary /tb_usb_rx/DUT/data_packet_reg
add wave -noupdate -radix binary /tb_usb_rx/DUT/is_sync
add wave -noupdate -divider Outputs
add wave -noupdate -color {Medium Orchid} -radix binary /tb_usb_rx/DUT/rx_packet
add wave -noupdate -color {Medium Orchid} -radix binary /tb_usb_rx/DUT/rx_data_ready
add wave -noupdate -color {Medium Orchid} -radix binary /tb_usb_rx/DUT/rx_transfer_active
add wave -noupdate -color {Medium Orchid} -radix binary /tb_usb_rx/DUT/rx_error
add wave -noupdate -color {Medium Orchid} -radix binary /tb_usb_rx/DUT/flush
add wave -noupdate -color {Medium Orchid} -radix binary /tb_usb_rx/DUT/store_rx_packet_data
add wave -noupdate -color {Medium Orchid} -radix binary /tb_usb_rx/DUT/rx_packet_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6011288 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {5342526 ps} {6868964 ps}
