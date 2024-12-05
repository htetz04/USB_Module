`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_ahb_lite_usb ();

    localparam CLK_PERIOD = 10ns;
    localparam USB_PERIOD = 83.33ns;

    string testcasename;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;
    logic hsel;
    logic [3:0] haddr;
    logic [1:0] htrans;
    logic [2:0] hsize;
    logic hwrite;
    logic [31:0] hwdata;
    logic [2:0] hburst;
    logic [31:0] hrdata;
    logic hresp;
    logic hready;
    logic dp_in;
    logic dm_in;
    logic dp_out;
    logic dm_out;
    logic d_mode;

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

   task run_wait(
    integer len
   );
   for(int i = 0; i < len; i++) begin
    @(negedge clk);
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
       if (hready == 1)
       @(posedge clk);
       // Turn off the bus model
       @(negedge clk);
       enable_transactions = 1'b0;
   end

   endtask

    ahb_lite_usb #() DUT (
        .clk(clk), .n_rst(n_rst),
        .hsel(hsel), .haddr(haddr),
        .htrans(htrans), .hsize(hsize),
        .hwrite(hwrite), .hwdata(hwdata),
        .hburst(hburst), .hrdata(hrdata),
        .hresp(hresp), .hready(hready),
        .dp_in(dp_in), .dm_in(dm_in),
        .dp_out(dp_out), .dm_out(dm_out),
        .d_mode(d_mode)
    );

    

    //USED TO STREAM BITS FOR TESTING
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

    task load_buff(
        input n
    );
        for(int i = 0; i < n; i++ ) begin
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(10);
        end
    endtask

    initial begin
        n_rst = 1;

        dp_in = 1;
        dm_in = 0;
        
        reset_model;
        reset_dut;
        

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
        enqueue_transaction(1, 0, 4'h4, 32'b10000000000000000000000000000100, 0, 1);
        execute_transactions(1);
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


        //-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
        // ACK / NAK / STALL TRANSMISSIONS
        //-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
        // Test A.2 (2) Endpoint to Host 
        // Test A.2 (4) USB TX Handling ACK from AHB
        // TEST_NAME: Transmitting ACK Packet
        testcasename = "TX ACK";
            enqueue_transaction(1, 1, 4'hc, 32'd2, 0, 2);
            execute_transactions(1);
            run_wait(200);

        // Test A.2 (2) Endpoint to Host 
        // Test A.2 (4) USB TX Handling NAK from AHB
        // TEST_NAME: Transmitting NAK Packet
        testcasename = "TX NAK";
            enqueue_transaction(1, 1, 4'hc, 32'd3, 0, 2);
            execute_transactions(1);
            run_wait(200);

        // Test A.2 (2) Endpoint to Host 
        // Test A.2 (4) USB TX Handling STALL from AHB
        // TEST_NAME: Transmitting STALL Packet
        testcasename = "TX STALL";
            enqueue_transaction(1, 1, 4'hc, 32'd4, 0, 2);
            execute_transactions(1);
            run_wait(200);

        //-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
        // DATA TRANSMISSIONS
        //-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.

        // Test A.2 (6) Data Buffer stores from SoC and provides USB TX
        // Test B.1 (4) AHB loads to Buffer
        // TEST_NAME: Fill Data Buffer to 4 Bytes
        testcasename = "Fill Data Buffer 4 Bytes";
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);

        // Test A.2 (2) Endpoint to Host 
        // Test A.2 (4) USB TX Handling DATA0 from AHB
        // Test B.1 (4) Buffer drains to USB TX
        // TEST_NAME: Transmitting DATA0 Packet
        testcasename = "TX DATA0 Packet";

            enqueue_transaction(1, 1, 4'hc, 32'd1, 0, 2);
            execute_transactions(1);
            run_wait(800);

        // READ DATA BUFFER TEST
            testcasename = "Fill Data Buffer 1 Byte";
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 0);
            execute_transactions(1);
            run_wait(100);

            testcasename = "Read Data Buffer 1 Byte";
            enqueue_transaction(1, 0, 4'h0, 32'h0, 0, 2);
            execute_transactions(1);
            
            
            run_wait(100);

        // CLEAR DATA BUFFER TEST
            testcasename = "Fill Data Buffer 4 Byte and CLEAR";
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);

            enqueue_transaction(1, 1, 4'hd, 32'h1, 0, 0);
            execute_transactions(1);
            run_wait(100);

            enqueue_transaction(1, 1, 4'hd, 32'h0, 0, 0);
            execute_transactions(1);
            run_wait(100);

         //-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
        // Test A.2 (6) Data Buffer stores from SoC and provides USB TX
        // Test B.1 (4) AHB loads to Buffer
        // TEST_NAME: Fill Data Buffer to 1 Byte
            testcasename = "Fill Data Buffer 1 Byte";
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 0);
            execute_transactions(1);
            run_wait(100);

        // Test A.2 (2) Endpoint to Host 
        // Test A.2 (4) USB TX Handling DATA0 from AHB
        // Test B.1 (4) Buffer drains to USB TX
        // TEST_NAME: Transmitting DATA0 Packet
            testcasename = "TX DATA0 Packet";
            enqueue_transaction(1, 1, 4'hc, 32'd1, 0, 2);
            execute_transactions(1);
            enqueue_transaction(1, 0, 4'hc, 32'd1, 0, 2);
            execute_transactions(1);
            run_wait(500);
            

        //-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
        // Test A.2 (6) Data Buffer stores from SoC and provides USB TX
        // Test B.1 (4) AHB loads to Buffer
        // TEST_NAME: Fill Data Buffer to 64 Bytes
         testcasename = "Fill Data Buffer to 64 Bytes";

            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);
            enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);enqueue_transaction(1, 1, 4'h0, 32'b10000001100000011000000110000001, 0, 2);
            execute_transactions(1);
            run_wait(100);

            enqueue_transaction(1, 1, 4'hc, 32'h1, 0, 2);
            execute_transactions(1);
            run_wait(5000);

        reset_dut;
        reset_model;


        

        @(negedge clk);
        @(negedge clk);
        #(USB_PERIOD * 3);



        $finish;
    end
endmodule

/* verilator coverage_on */

