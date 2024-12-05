A guide to the project files for the cooperative design lab in ECE33700 .

Team members contributing to this project were :
    Ashwin Patel
    Usman Chaudhary
    Zay Linn Htet

All files for this project can be found in
    ~ mg 086/ece337/USB_MODULE

Source /
    ahb_lite_usb.sv - top level RTL code for entire design
    
    ahb_usb_sat.sv - ###
    usb_rx_counter.sv - clock divider for rx
    usb_rx.sv - all receiver related code aside from clock divider

    USB_TX.sv - top level code for USB Transmitter
    USB_TX_States.sv - state controller code for USB Transmitter
    USB_TX_Compiler.sv - transmitting packet compiling code for USB Transmitter
    USB_TX_Loader.sv - transmitting packet loader and encoder code for USB Transmitter
    USB_TX_Output_Clock.sv - clock divider for 12M Hz output code for USB Transmitter
    USB_TX_Counter.sv - counter with variable increment size for USB Transmitter

    USB_Buffer.sv - top level code for 64 Byte USB Buffer
    USB_Buffer_Counter.sv - counter with increment and decrement setting for USB Buffer

Testbench /
    tb_ahb_lite_usb.sv  - testbench for AHB Lite USB
    tb_ahb_usb_sat.sv   - testbench for AHB USB Satellite
    tb_USB_Buffer.sv    - testbench for USB Buffer
    tb_USB_Buffer_Counter.sv    - testbench for USB Buffer Counter
    tb_usb_rx.sv    - testbench for USB RX
    tb_usb_rx_counter.sv    - testbench for USB RX Counter
    tb_USB_TX.sv    - testbench for USB TX 
    tb_USB_TX_States.sv -   testbench for USB TX States
    tb_USB_TX_Packet_Compiler.sv    - testbench for USB TX Packet Compiler
    tb_USB_TX_Packet_Loader.sv  - testbench for USB TX Packet Loader
    tb_USB_TX_Output_Clock.sv   - testbench for USB TX Output Clock
    tb_USB_TX_Counter.sv    - testbench for USB TX Counter

Reports /
    synth.log - synthesis report file for top level