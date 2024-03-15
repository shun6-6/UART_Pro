`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/25 15:50:04
// Design Name: 
// Module Name: UART_TOP
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


module UART_TOP(
    // input      i_clk_p          ,
    //input      i_clk_n          ,
    input      i_sys_clk        ,
    input      i_uart_rx        ,
    output     o_uart_tx         
    );
    
wire        w_clk_250m          ;
wire        w_clk_rst           ;
wire        w_clk_locked        ;

wire  [7:0] w_usr_tx_data       ;
wire        w_usr_tx_ready      ;
wire  [7:0] w_usr_rx_data       ;
wire        w_usr_rx_valid      ;
wire        w_user_clk          ; 
wire        w_user_rst          ; 
wire        w_fifo_full         ;
wire        w_fifo_empty        ;

reg         r_usr_tx_valid      ;
reg         r_fifo_rden         ;
reg         r_rden_lock         ;
reg         r_user_tx_ready     ;


assign w_clk_rst = ~w_clk_locked ;

// clk_pll_250mhz clk_pll_250mhz_u
//    (
//     .clk_out1  (w_clk_250m  ),     // output clk_out1
//     .locked    (w_clk_locked),       // output locked
//     .clk_in1_p (i_clk_p     ),    // input clk_in1_p
//     .clk_in1_n (i_clk_n     )    // input clk_in1_n
// ); 
clk_pll_250mhz clk_pll_50mhz_u
(
 // Clock out ports
 .clk_out1(w_clk_250m),     // output clk_out1
 // Status and control signals
 .locked(w_clk_locked),       // output locked
// Clock in ports
 .clk_in1(i_sys_clk)      // input clk_in1
);

Uart_Drive#(
    .P_UART_CLK         (50_000_000) , //输入时钟频率
    .P_UART_BAUDRATE    (9600       ) , //波特率
    .P_UART_DATA_WIDTH  (8          ) , //数据位宽
    .P_UART_STOP_WIDTH  (1          ) , //停止位位宽
    .P_UART_CHECK       (0          )   //0:无校验，1：奇校验 2：偶校验
)Uart_Drive_u
(
    .i_clk          (w_clk_250m     ),
    .i_rst          (w_clk_rst      ),
    .i_uart_rx      (i_uart_rx      ),
    .o_uart_tx      (o_uart_tx      ),

    .i_usr_tx_data  (w_usr_tx_data  ),
    .i_usr_tx_valid (r_usr_tx_valid ),
    .o_usr_tx_ready (w_usr_tx_ready ),

    .o_usr_rx_data  (w_usr_rx_data  ),
    .o_usr_rx_valid (w_usr_rx_valid ),

    .o_user_clk     (w_user_clk     ),
    .o_user_rst     (w_user_rst     )
);
  
// fifo_UART fifo_UART_u (
//   .clk        (w_user_clk       ),              
//   .srst       (w_user_rst       ),              
//   .din        (w_usr_rx_data    ),           
//   .wr_en      (w_usr_rx_valid   ),          
//   .rd_en      (r_fifo_rden      ),             
//   .dout       (w_usr_tx_data    ),           
//   .full       (w_fifo_full      ),            
//   .empty      (w_fifo_empty     ),            
//   .wr_rst_busy(),  
//   .rd_rst_busy()  
// );
fifo_UART fifo_UART_u (
  .clk      (w_user_clk),      // input wire clk
  .srst     (w_user_rst),    // input wire srst
  .din      (w_usr_rx_data),      // input wire [7 : 0] din
  .wr_en    (w_usr_rx_valid),  // input wire wr_en
  .rd_en    (r_fifo_rden),  // input wire rd_en
  .dout     (w_usr_tx_data),    // output wire [7 : 0] dout
  .full     (w_fifo_full),    // output wire full
  .empty    (w_fifo_empty)  // output wire empty
);

always@(posedge w_user_clk,posedge w_user_rst)
begin
    if(w_user_rst)
        r_user_tx_ready <= 'd0;
    else
        r_user_tx_ready <= w_usr_tx_ready;
end

always@(posedge w_user_clk,posedge w_user_rst)
begin
    if(w_user_rst)
        r_rden_lock <= 'd0;
    else if(w_usr_tx_ready && !r_user_tx_ready)
        r_rden_lock <= 'd0;
    else if(~w_fifo_empty && w_usr_tx_ready)
        r_rden_lock <= 'd1;
    else 
        r_rden_lock <= r_rden_lock;
end

always@(posedge w_user_clk or posedge w_user_rst)begin
    if(w_user_rst)
        r_fifo_rden <= 'd0;
    else if(~w_fifo_empty && w_usr_tx_ready && !r_rden_lock)
        r_fifo_rden <= 1;
    else
        r_fifo_rden <= 'd0;
end

always@(posedge w_user_clk or posedge w_user_rst)begin
    if(w_user_rst)
        r_usr_tx_valid <= 'd0;
    else
        r_usr_tx_valid <= r_fifo_rden;
end


endmodule
