`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_usb_rx ();

    localparam CLK_PERIOD = 10ns;
    localparam USB_PERIOD = 83.33ns;

    string testcasename;


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

    logic dp_in, dm_in;
    logic [6:0] buffer_occupancy;
    logic [3:0] rx_packet;
    logic rx_data_ready, rx_transfer_active, rx_error, flush, store_rx_packet_data;
    logic [7:0] rx_packet_data;

    usb_rx DUT (
        .clk(clk), .n_rst(n_rst), .dp_in(dp_in), .dm_in(dm_in), 
        .buffer_occupancy(buffer_occupancy),
        .rx_packet(rx_packet),
        .rx_data_ready(rx_data_ready), .rx_transfer_active(rx_transfer_active), .rx_error(rx_error),
        .flush(flush), .store_rx_packet_data(store_rx_packet_data), .rx_packet_data(rx_packet_data)
    );

    task stream_bits; 
        input logic [127:0] d_plus;
        input logic [127:0] d_minus;
        input int num_bits;
        integer i; 
        begin 
            for(i = 0; i < num_bits; i++) begin 
                dp_in = d_plus[i];
                dm_in = d_minus[i];
                #(USB_PERIOD); 
            end 
        end 
    endtask

    initial begin
        dp_in = 1'b1;
        dm_in = 1'b0;
        buffer_occupancy = 7'b0;
        
        n_rst = 1;

        reset_dut;

        buffer_occupancy = 7'd0;

        //******Verify Correct Behavior***********//
        //ACK PID
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Valid ACK Packet";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b00011011, 8'b11100100, 8); //ACK PID
        stream_bits(2'b00, 2'b00, 2);             //EOP


        //IN TOKEN PID
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Valid IN Packet";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b01110010, 8'b10001101, 8); //IN PID
        //crc,    endpoint, address
        //11011   0000      1111001
        stream_bits(16'b1110001010000010, 16'b0001110101111101, 16);
        stream_bits(2'b00, 2'b00, 2);             //EOP


        //OUT TOKEN PID
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Valid OUT Packet";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b00001010, 8'b11110101, 8); //OUT PID
        //crc,    endpoint, address
        //11011   0000      1111001
        stream_bits(16'b1110001010000010, 16'b0001110101111101, 16);
        stream_bits(2'b00, 2'b00, 2);             //EOP


        //DATA0 PID: 1 BYTE
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Valid DATA0 1 Byte Packet";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b00010100, 8'b11101011, 8); //DATA0 PID
        stream_bits(8'b10101010, 8'b01010101, 8); //00000001
        //CRC Value: 1111011100110001
        stream_bits(16'b1111100001000101, 16'b0000011110111010, 16); //DATA CRC IF LAST BIT BEFORE IS A 1
        stream_bits(2'b00, 2'b00, 2);             //EOP


        //DATA1 PID: 3 BYTES
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Valid DATA1 3 Byte Packet";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b01101100, 8'b10010011, 8); //DATA1 PID
        stream_bits(8'b10101010, 8'b01010101, 8); //00000001
        stream_bits(8'b11101100, 8'b00010011, 8); //11001010
        stream_bits(8'b01111010, 8'b10000101, 8); //01110000
        stream_bits(16'b0000011110111010, 16'b1111100001000101, 16); //DATA CRC IF LAST BIT BEFORE IS A 0
        stream_bits(2'b00, 2'b00, 2);             //EOP


        //DATA1 PID: 64 BYTES
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Valid DATA1 64 Byte Packet";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b01101100, 8'b10010011, 8); //DATA1 PID
        stream_bits(8'b10101010, 8'b01010101, 8); //00000001
        stream_bits(8'b11101100, 8'b00010011, 8); //11001010
        stream_bits(8'b01111010, 8'b10000101, 8); //01110000
                                                  //00000001
                                                  //11001010
                                                  //01110000
                                                  //11111110
                                                  //11111100
                                                  //11111000
                                                  //11110000
                                                  //11100000
                                                  //11111110
                                                  //11111100
                                                  //11111000
                                                  //11110000
                                                  //11100000
                                                  //11000000
                                                  //10000000
                                                  //11111111
        stream_bits(40'b1111010100000101000000101111111011111111,40'b0000101011111010111111010000000100000000 , 40);
        stream_bits(64'b1111111111010101000101010000101011111010111111010000000100000000, 
                    64'b0000000000101010111010101111010100000101000000101111111011111111, 64);
        stream_bits(64'b1111111111010101000101010000101011111010111111010000000100000000, 
                    64'b0000000000101010111010101111010100000101000000101111111011111111, 64);
        stream_bits(64'b1111111111010101000101010000101011111010111111010000000100000000, 
                    64'b0000000000101010111010101111010100000101000000101111111011111111, 64);
        stream_bits(64'b1111111111010101000101010000101011111010111111010000000100000000, 
                    64'b0000000000101010111010101111010100000101000000101111111011111111, 64);
        stream_bits(64'b1111111111010101000101010000101011111010111111010000000100000000, 
                    64'b0000000000101010111010101111010100000101000000101111111011111111, 64);
        stream_bits(64'b1111111111010101000101010000101011111010111111010000000100000000, 
                    64'b0000000000101010111010101111010100000101000000101111111011111111, 64);
        stream_bits(64'b1111111111010101000101010000101011111010111111010000000100000000, 
                    64'b0000000000101010111010101111010100000101000000101111111011111111, 64);
        stream_bits(16'b1111100001000101, 16'b0000011110111010, 16); //DATA CRC IF LAST BIT BEFORE IS A 1
        stream_bits(2'b00, 2'b00, 2);             //EOP



        //******Verify Invalid Token Behavior***********//
        //IN TOKEN INVALID ADDRESS
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Invalid TOKEN Address";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b01110010, 8'b10001101, 8); //IN PID
        //crc,    endpoint, address
        //11011   0000      1111001
        stream_bits(16'b1100001010000010, 16'b0011110101111101, 16);
        stream_bits(2'b00, 2'b00, 2);             //EOP


        //IN TOKEN INVALID ENDPOINT
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Invalid TOKEN Endpoint";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b01110010, 8'b10001101, 8); //IN PID
        //crc,    endpoint, address
        //11011   0000      1111001
        stream_bits(16'b1110001110000010, 16'b0001110001111101, 16);
        stream_bits(2'b00, 2'b00, 2);             //EOP

        
        //OUT TOKEN INVALID CRC
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Invalid OUT TOKEN CRC";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b00001010, 8'b11110101, 8); //OUT PID
        //crc,    endpoint, address
        //11011   0000      1111001
        stream_bits(16'b1010001010000010, 16'b0101110101111101, 16);
        stream_bits(2'b00, 2'b00, 2);             //EOP


        //******Verify Invalid Data Behavior***********//
        //DATA0 PID: INVALID CRC
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Invalid DATA0 CRC";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b00010100, 8'b11101011, 8); //DATA0 PID
        stream_bits(8'b10101010, 8'b01010101, 8); //00000001
        //CRC Value: 1111011100110001
        stream_bits(16'b1101100001000101, 16'b0010011110111010, 16); //DATA CRC IF LAST BIT BEFORE IS A 1
        stream_bits(2'b00, 2'b00, 2);             //EOP


        //DATA1 PID: 66 Bytes
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Invalid 66 byte DATA1 packet";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b01101100, 8'b10010011, 8); //DATA1 PID
        stream_bits(8'b10101010, 8'b01010101, 8); //00000001
        stream_bits(8'b11101100, 8'b00010011, 8); //11001010
        stream_bits(8'b01111010, 8'b10000101, 8); //01110000
                                                  //00000001
                                                  //11001010
                                                  //01110000
                                                  //11111110
                                                  //11111100
                                                  //11111000
                                                  //11110000
                                                  //11100000
        stream_bits(40'b1111010100000101000000101111111011111111,40'b0000101011111010111111010000000100000000 , 40);
        stream_bits(64'b1111111111010101000101010000101011111010111111010000000100000000, 
                    64'b0000000000101010111010101111010100000101000000101111111011111111, 64);
        stream_bits(64'b1111111111010101000101010000101011111010111111010000000100000000, 
                    64'b0000000000101010111010101111010100000101000000101111111011111111, 64);
        stream_bits(64'b1111111111010101000101010000101011111010111111010000000100000000, 
                    64'b0000000000101010111010101111010100000101000000101111111011111111, 64);
        stream_bits(64'b1111111111010101000101010000101011111010111111010000000100000000, 
                    64'b0000000000101010111010101111010100000101000000101111111011111111, 64);
        stream_bits(64'b1111111111010101000101010000101011111010111111010000000100000000, 
                    64'b0000000000101010111010101111010100000101000000101111111011111111, 64);
        stream_bits(64'b1111111111010101000101010000101011111010111111010000000100000000, 
                    64'b0000000000101010111010101111010100000101000000101111111011111111, 64);
        stream_bits(64'b1111111111010101000101010000101011111010111111010000000100000000, 
                    64'b0000000000101010111010101111010100000101000000101111111011111111, 64);
        //NOW SENDING 2 MORE BYTES AFTER 64
        stream_bits(8'b10101010, 8'b01010101, 8); //00000001
        stream_bits(8'b11101100, 8'b00010011, 8); //11001010
        stream_bits(16'b1111100001000101, 16'b0000011110111010, 16); //DATA CRC IF LAST BIT BEFORE IS A 1
        stream_bits(2'b00, 2'b00, 2);             //EOP


        //DATA0 PID: 13 Bits
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Invalid 13 bit DATA0 packet";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b00010100, 8'b11101011, 8); //DATA0 PID
        stream_bits(13'b0011110101010, 13'b01010101, 13); //1011100000001
        //CRC Value: 1111011100110001
        stream_bits(16'b1111100001000101, 16'b0000011110111010, 16); //DATA CRC IF LAST BIT BEFORE IS A 1
        stream_bits(2'b00, 2'b00, 2);             //EOP
        

        //******Verify EDGE Cases B.2.5***********//
        //Invalid PID
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Invalid PID";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b10011011, 8'b01100100, 8); //ACK PID
        stream_bits(2'b00, 2'b00, 2);             //EOP

        //IN TOKEN Premature EOP
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Premature EOP";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b01110010, 8'b10001101, 8); //IN PID
        //crc,    endpoint, address
        //11011   0000      1111001
        stream_bits(13'b1110001010010, 13'b0001110101101, 13);
        stream_bits(2'b00, 2'b00, 2);             //EOP


        //Invalid Sync
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Invalid Sync";
        stream_bits(8'b10101010, 8'b01010101, 8); //SYNC BYTE
        stream_bits(8'b00011011, 8'b11100100, 8); //ACK PID
        stream_bits(2'b00, 2'b00, 2);             //EOP


        //******Verify NRZI B.2.6***********//
        //IN TOKEN PID
        testcasename = "";
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "NRZI Check";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b01110010, 8'b11001101, 8); //IN PID
        //crc,    endpoint, address
        //11011   0000      1111001
        stream_bits(16'b1110001010000010, 16'b0001110101111101, 16);
        stream_bits(2'b00, 2'b00, 2);             //EOP
        

        /*
        //NAK PID
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Valid NAK Packet";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b01100011, 8'b10011100, 8); //NAK PID
        stream_bits(2'b00, 2'b00, 2);             //EOP

        //STALL PID
        stream_bits(6'b111111, 6'b000000, 6);     //IDLE
        testcasename = "Valid STALL Packet";
        stream_bits(8'b00101010, 8'b11010101, 8); //SYNC BYTE
        stream_bits(8'b01011111, 8'b10100000, 8); //STALL PID
        stream_bits(2'b00, 2'b00, 2);             //EOP
        */
    

        @(negedge clk);
        @(negedge clk);
        #(USB_PERIOD * 3);

        $finish;
    end
endmodule

/* verilator coverage_on */