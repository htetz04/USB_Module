`timescale 1ns / 10ps

module usb_rx_counter #(
    parameter SIZE = 5
) (
    input logic clk, n_rst, clear, count_enable,
    //input logic [SIZE - 1: 0] rollover_val, removed for 889
    output logic [SIZE - 1: 0] count_out,
    output logic rollover_flag
);

    logic [SIZE - 1: 0] next_count;
    logic next_roll_flag;

    //889 variables
    logic [1:0] stage, next_stage;
    logic [3:0] rollover_val;

    always_ff @( posedge clk, negedge n_rst ) begin
        if (n_rst == 1'b0) begin
            count_out <= 0;
            rollover_flag <= 0;
            stage <= 0;
        end
        else begin
            count_out <= next_count;
            rollover_flag <= next_roll_flag;
            stage <= next_stage;
        end
    end

    always_comb begin
        if (stage == 2'b00) begin
            rollover_val = 4'd4;
        end
        else if (stage == 2'b01 || stage == 2'b10) begin
            rollover_val = 4'd8;
        end
        else if (stage == 2'b11) begin
            rollover_val = 4'd5;
        end
    end

    always_comb begin
        next_count = count_out;
        next_roll_flag = 1'b0;
        next_stage = stage;
        if (clear) begin
            next_count = 0;
            next_roll_flag = 1'b0;
            next_stage = 0;
        end
        else if (count_enable) begin
            if (count_out >= rollover_val) begin
                next_count = 1;
                next_roll_flag = 1'b0;
                next_stage = stage + 1;
            end
            else begin
                next_count = next_count + 1;
                if (next_count >= rollover_val && (stage != 2'b11)) begin
                    next_roll_flag = 1'b1;
                end
                else begin
                    next_roll_flag = 1'b0;
                end
            end
        end
        else begin
            next_count = count_out;
            next_roll_flag = 1'b0;
        end
    end

    /*
    logic [SIZE - 1: 0] next_count;
    logic next_roll_flag;

    //889 variables
    logic [1:0] stage, next_stage;
    logic [3:0] rollover_val;

    always_ff @( posedge clk, negedge n_rst ) begin
        if (n_rst == 1'b0) begin
            count_out <= 0;
            rollover_flag <= 0;
            stage <= 0;
        end
        else begin
            count_out <= next_count;
            rollover_flag <= next_roll_flag;
            stage <= next_stage;
        end
    end

    always_comb begin
        if (stage[1] == 1'b1) begin
            rollover_val = 4'd9;
        end
        else begin
            rollover_val = 4'd8;
        end
    end

    always_comb begin
        next_count = count_out;
        next_roll_flag = 1'b0;
        next_stage = stage;
        if (clear) begin
            next_count = 0;
            next_roll_flag = 1'b0;
            next_stage = 0;
        end
        else if (count_enable) begin
            if (count_out >= rollover_val) begin
                next_count = 1;
                next_roll_flag = 1'b0;
                next_stage = (stage == 2'b10) ? 2'b0 : stage + 1;
            end
            else begin
                next_count = next_count + 1;
                if (next_count >= rollover_val) begin
                    next_roll_flag = 1'b1;
                end
                else begin
                    next_roll_flag = 1'b0;
                end
            end
        end
        else begin
            next_count = count_out;
            next_roll_flag = 1'b0;
        end
    end
    */
    /*
    logic [SIZE - 1: 0] next_count;
    logic next_roll_flag;

    always_ff @( posedge clk, negedge n_rst ) begin
        if (n_rst == 1'b0) begin
            count_out <= 0;
            rollover_flag <= 0;
        end
        else begin
            count_out <= next_count;
            rollover_flag <= next_roll_flag;
        end
    end

    always_comb begin
        if (clear) begin
            next_count = 0;
            next_roll_flag = 1'b0;
        end
        else if (count_enable) begin
            if (count_out >= rollover_val) begin
                next_count = 1;
                next_roll_flag = 1'b0;
            end
            else begin
                next_count = next_count + 1;
                if (next_count >= rollover_val) begin
                    next_roll_flag = 1'b1;
                end
                else begin
                    next_roll_flag = 1'b0;
                end
            end
        end
        else begin
            next_count = count_out;
            next_roll_flag = 1'b0;
        end
    end
    */

endmodule

