

`default_nettype none

module spi_peripheral (
    input wire clk,
    input wire rst_n,
    input wire sclk,
    input wire copi,
    input wire ncs,

    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle
);

    reg nCS_ready;
    reg nCS_processed;
    reg nCS_sync1;
    reg nCS_sync2;
    reg nCS_prev;

    reg sclk_sync1;
    reg sclk_sync2;
    reg sclk_prev;

    reg copi_sync1;
    reg copi_sync2;

    reg [15:0] spi_shift;
    reg [3:0] spi_count;
    reg spi_ready;
    reg spi_sync1;
    reg spi_sync2;
    reg spi_prev;

    wire nCS_posedge = nCS_sync2 && !nCS_prev;
    wire spi_data_happy = spi_sync2 ^ spi_prev;
    wire sclk_posedge = sclk_sync2 && ! sclk_prev;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            spi_shift <= 16'b0;
            spi_count <= 4'b0;
            spi_ready <= 1'b0;
        end else if(!nCS_sync2) begin
            if(sclk_posedge) begin
                spi_shift <= {spi_shift[14:0], copi_sync2};
                if(spi_count == 4'd15) begin
                    spi_count <= 4'b0;
                    spi_ready <= ~spi_ready;
                end else begin
                    spi_count <= spi_count + 1'b1;
                end
            end
        end 
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            nCS_sync1 <= 1'b1;
            nCS_sync2 <= 1'b1;
            nCS_prev <= 1'b1;
        end else begin
            nCS_sync1 <= ncs;
            nCS_sync2 <= nCS_sync1;
            nCS_prev <= nCS_sync2;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sclk_sync1 <= 1'b0;
            sclk_sync2 <= 1'b0;
            sclk_prev <= 1'b0;
        end else begin
            sclk_sync1 <= sclk;
            sclk_sync2 <= sclk_sync1;
            sclk_prev <= sclk_sync2;

        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            copi_sync1 <= 1'b0;
            copi_sync2 <= 1'b0;
        end else begin
            copi_sync1 <= copi;
            copi_sync2 <= copi_sync1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            spi_sync1 <= 1'b0;
            spi_sync2 <= 1'b0;
            spi_prev <= 1'b0;
        end else begin
            spi_sync1 <= spi_ready;
            spi_sync2 <= spi_sync1;
            spi_prev <= spi_sync2;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            nCS_ready <= 1'b0;
            en_reg_out_7_0 <= 8'b0;
            en_reg_out_15_8 <= 8'b0;
            en_reg_pwm_7_0 <= 8'b0;
            en_reg_pwm_15_8 <= 8'b0;
            pwm_duty_cycle <= 8'b0;
        end else if (nCS_sync2 == 1'b0) begin   
            if(spi_data_happy == 1'b1) begin
                if(spi_shift[15] == 1'b1) begin
                    case(spi_shift[14:8]) 
                        7'h00: en_reg_out_7_0 <= spi_shift[7:0];
                        7'h01: en_reg_out_15_8 <= spi_shift[7:0];
                        7'h02: en_reg_pwm_7_0 <= spi_shift[7:0];
                        7'h03: en_reg_pwm_15_8 <= spi_shift[7:0];
                        7'h04: pwm_duty_cycle <= spi_shift[7:0];
                        default: begin end
                    endcase
                end
            end
        end else begin
            if(nCS_posedge) begin
                nCS_ready <= 1'b1;
            end else if (nCS_processed) begin
                nCS_ready <= 1'b0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            nCS_processed <= 1'b0;
        end else if (nCS_ready && !nCS_processed) begin
            nCS_processed <= 1'b1;
        end else if(!nCS_ready && nCS_processed) begin
            nCS_processed <= 1'b0;
        end
    end

endmodule