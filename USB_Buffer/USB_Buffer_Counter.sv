`timescale 1ns / 10ps

module USB_Buffer_Counter #(
    parameter SIZE = 5,     // Counter Width
    parameter INC_SIZE = 1 // Increment Size
    ) (
    input logic clk, n_rst, clear, countUP_enable, countDOWN_enable,
    input logic [(SIZE - 1):0] rollover_val,
    output logic [(SIZE - 1):0] count_out,
    output logic rollover_flag
);

    logic [(SIZE - 1):0] n_count_out;
    logic n_rollover_flag;

    always_ff @(posedge clk, negedge n_rst) begin
        if(n_rst == 0) begin
            count_out <= '0;
            rollover_flag <= 1'b0;
        end
        else begin
            count_out <= n_count_out;
            rollover_flag <= n_rollover_flag;
        end
    end

    always_comb begin
        if(clear) begin
            n_count_out = '0;
            n_rollover_flag = 1'b0;
        end
        else if(countUP_enable) begin
            if(count_out >= rollover_val) begin
                n_count_out = 1;
                n_rollover_flag = 1'b0;
            end
            else begin
                n_count_out = count_out + INC_SIZE;
                if(n_count_out >= rollover_val) begin
                    n_rollover_flag = 1'b1;
                end
                else begin
                    n_rollover_flag = 1'b0;
                end
            end

        end
        else if(countDOWN_enable) begin
            if(count_out >= rollover_val) begin
                n_count_out = 1;
                n_rollover_flag = 1'b0;
            end
            else begin
                n_count_out = count_out - INC_SIZE;
                if(n_count_out >= rollover_val) begin
                    n_rollover_flag = 1'b1;
                end
                else begin
                    n_rollover_flag = 1'b0;
                end
            end

        end
        else begin
            n_count_out = count_out;
            n_rollover_flag = 1'b0;
        end
    end

endmodule
