onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Gray65 /tb_ahb_usb_sat/clk
add wave -noupdate -color Gray65 /tb_ahb_usb_sat/n_rst
add wave -noupdate /tb_ahb_usb_sat/testbenchname
add wave -noupdate -divider inputs
add wave -noupdate -color Orange /tb_ahb_usb_sat/hsel
add wave -noupdate -color Orange /tb_ahb_usb_sat/haddr
add wave -noupdate -color Orange /tb_ahb_usb_sat/htrans
add wave -noupdate -color Orange /tb_ahb_usb_sat/hsize
add wave -noupdate -color Orange /tb_ahb_usb_sat/hwrite
add wave -noupdate -color Orange /tb_ahb_usb_sat/hwdata
add wave -noupdate -color Orange /tb_ahb_usb_sat/rx_packet
add wave -noupdate -color Orange /tb_ahb_usb_sat/rx_data_ready
add wave -noupdate -color Orange /tb_ahb_usb_sat/rx_transfer_active
add wave -noupdate -color Orange /tb_ahb_usb_sat/rx_error
add wave -noupdate -color Orange /tb_ahb_usb_sat/buffer_occupancy
add wave -noupdate -color Orange /tb_ahb_usb_sat/rx_data
add wave -noupdate -color Orange /tb_ahb_usb_sat/tx_transfer_active
add wave -noupdate -color Orange /tb_ahb_usb_sat/tx_error
add wave -noupdate -divider outputs
add wave -noupdate -color {Light Blue} /tb_ahb_usb_sat/hrdata
add wave -noupdate -color {Light Blue} /tb_ahb_usb_sat/hready
add wave -noupdate -color {Light Blue} /tb_ahb_usb_sat/hresp
add wave -noupdate -color {Light Blue} /tb_ahb_usb_sat/get_rx_data
add wave -noupdate -color {Light Blue} /tb_ahb_usb_sat/store_tx_data
add wave -noupdate -color {Light Blue} /tb_ahb_usb_sat/tx_packet
add wave -noupdate -color {Light Blue} /tb_ahb_usb_sat/tx_data
add wave -noupdate -color {Light Blue} /tb_ahb_usb_sat/clear
add wave -noupdate -color {Light Blue} /tb_ahb_usb_sat/d_mode
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {264426 ps} 0}
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
WaveRestoreZoom {231226 ps} {745831 ps}
