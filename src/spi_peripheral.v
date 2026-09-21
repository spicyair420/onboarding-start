

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

    reg transaction_ready <= 0'b0;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            transaction_ready <= 0'b0;
        end else if (ncs == 1'b0) begin
            
        end else begin

        end
    end

endmodule