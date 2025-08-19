`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2025 05:36:53 AM
// Design Name: 
// Module Name: mii_rx_assembler
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


module mii_rx_assembler(
    input wire mii_rx_clk,  // 25MHz (MII)
    input wire [3:0] mii_rxd,
    input wire mii_rx_dv,
    
    output reg [7:0] rx_data,
    output reg rx_valid,
    output reg rx_last
    );
    
    reg [3:0] nibble;
    reg       low_high;
    
    always @(posedge mii_rx_clk) begin
        if (!mii_rx_dv) begin
          rx_valid <= 0;
          low_high <= 0;
          nibble <= 4'h0;
          rx_last <= 0;
       end else begin
          if (!low_high) begin
            nibble <= mii_rxd;
            low_high <= 1;
            rx_valid <= 0;
        end else begin
            rx_data <= {mii_rxd, nibble}; // PHY high nibble, check ordering and adjust
            rx_valid <= 1;
            low_high <= 0;
            rx_last <= 0;
         end
      end
   end
endmodule
       
