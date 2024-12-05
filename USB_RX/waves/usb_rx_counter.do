onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Gray70 -radix binary /tb_usb_rx_counter/DUT/clk
add wave -noupdate -color Gray70 -radix binary /tb_usb_rx_counter/DUT/n_rst
add wave -noupdate -divider Inputs
add wave -noupdate -color Orange -radix binary /tb_usb_rx_counter/DUT/clear
add wave -noupdate -color Orange -radix binary /tb_usb_rx_counter/DUT/count_enable
add wave -noupdate -color Orange -radix decimal /tb_usb_rx_counter/DUT/next_count
add wave -noupdate -divider Outputs
add wave -noupdate -radix decimal /tb_usb_rx_counter/DUT/count_out
add wave -noupdate -radix binary /tb_usb_rx_counter/DUT/rollover_flag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {525732 ps} 0}
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
WaveRestoreZoom {0 ps} {572250 ps}
