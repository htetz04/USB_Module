A guide to the project files for the cooperative design lab in ECE33700 .

Team members contributing to this project were :
    Ashwin Patel
    Usman Chaudhary
    Zay Linn Htet

All files for this project can be found in
    ~ mg ####/ ece337 / Project ( or whatever path you used )

Source /
    TOP_Level.sv - top level RTL code for entire design
    USB_AHB.sv - ###
    USB_RX.sv - ###

    USB_TX.sv - top level code for USB Transmitter
    USB_TX_States.sv - state controller code for USB Transmitter
    USB_TX_Compiler.sv - transmitting packet compiling code for USB Transmitter
    USB_TX_Loader.sv - transmitting packet loader and encoder code for USB Transmitter
    USB_TX_Output_Clock.sv - clock divider for 12M Hz output code for USB Transmitter
    USB_TX_Counter.sv - counter with variable increment size for USB Transmitter

    USB_Buffer.sv - top level code for 64 Byte USB Buffer
    USB_Buffer_Counter.sv - counter with increment and decrement setting for USB Buffer


Reports /
    top_level . log - synthesis report file for top level