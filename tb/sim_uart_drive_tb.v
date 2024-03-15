`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/25 16:05:45
// Design Name: 
// Module Name: sim_uart_drive_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
// `define CLK_PERIOD 4//250MHZ

module sim_uart_drive_tb();
localparam CLK_PERIOD = 20;
reg clk;
reg rst;
reg clk_50;

wire w_uart_tx;

always begin
    clk = 0;
    #(CLK_PERIOD / 2);
    clk = 1;
    #(CLK_PERIOD / 2);
end
always begin
    clk_50 = 0;
    #10;
    clk_50 = 1;
    #10;
end

initial begin
    rst = 1;
    #100;
    @(posedge clk) rst = 0;
end

localparam P_UART_DATA_WIDTH = 8;

reg  [P_UART_DATA_WIDTH-1 : 0] r_usr_tx_data  ;
reg                            r_usr_tx_valid ;
wire                           w_usr_tx_ready ;
wire [P_UART_DATA_WIDTH-1 : 0] o_usr_rx_data  ;
wire                           o_usr_rx_valid ;
wire                           w_usr_tx_active;
wire                           w_user_clk     ;
wire                           w_user_rst     ;

assign w_usr_tx_active = r_usr_tx_valid & w_usr_tx_ready;

Uart_Drive#(
    .P_UART_CLK         (50_000_000) , 
    .P_UART_BAUDRATE    (9600)        , 
    .P_UART_DATA_WIDTH  (P_UART_DATA_WIDTH)           , 
    .P_UART_STOP_WIDTH  (1)           , 
    .P_UART_CHECK       (0)             
)Uart_Drive_u
(
    .i_clk          (clk),
    .i_rst          (rst),
    .i_uart_rx      (o_uart_tx),
    .o_uart_tx      (o_uart_tx),
    .i_usr_tx_data  (r_usr_tx_data ),
    .i_usr_tx_valid (r_usr_tx_valid),
    .o_usr_tx_ready (w_usr_tx_ready),
    .o_usr_rx_data  (o_usr_rx_data ),
    .o_usr_rx_valid (o_usr_rx_valid),
    .o_user_clk     (w_user_clk)    ,
    .o_user_rst     (w_user_rst)    
);
UART_TOP UART_TOP_u0(

    .i_sys_clk        (clk_50),
    .i_uart_rx        (o_uart_tx),
    .o_uart_tx        (w_uart_tx) 
    );

always @(posedge w_user_clk or posedge w_user_rst) begin
    if(w_user_rst)
        r_usr_tx_valid <= 'd0;
    else if(w_usr_tx_active)
        r_usr_tx_valid <= 'd0;
    else if(w_usr_tx_ready)
        r_usr_tx_valid <= 1;
    else
        r_usr_tx_valid <= r_usr_tx_valid;
end

always @(posedge w_user_clk or posedge w_user_rst) begin
    if(w_user_rst)
        r_usr_tx_data <= 8'h55;
    else if(w_usr_tx_active)
        r_usr_tx_data <= 8'h55;
    else
        r_usr_tx_data <= r_usr_tx_data;
end

endmodule
