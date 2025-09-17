`timescale 1ns / 1ps


module eth_stage1 (
    
    
    input wire clk,
    input wire rst,
    input wire mii_rx_clk,
    input wire mii_rx_dv,
    input wire [3:0] mii_rxd,
    
    output reg [47:0] dst_mac,
    output reg [47:0] src_mac,
    output reg [15:0] eth_type
    
    );
    
    reg [7:0] byte_accum;
    reg nibble_sel;
    reg [6:0] byte_cnt;
    
    always @(posedge mii_rx_clk or posedge rst) begin    
        if (rst) begin
            byte_accum <= 0;
            nibble_sel <= 0;
            byte_cnt <= 0;
            dst_mac <= 0;
            src_mac <= 0;
            eth_type <= 0;
         end else if (mii_rx_dv) begin
            // Assemble bytes from nibbles
            if (!nibble_sel) begin
            byte_accum[3:0] <= mii_rxd;
            nibble_sel <= 1;
         end else begin
            byte_accum[7:4] <= mii_rxd;
            nibble_sel <= 0;
           
       
            case(byte_cnt)
            0: dst_mac[47:40] <= byte_accum;
            1: dst_mac[39:32] <= byte_accum;
            2: dst_mac[31:24] <= byte_accum;
            3: dst_mac[23:16] <= byte_accum;
            4: dst_mac[15:8] <= byte_accum;
            5: dst_mac[7:0] <= byte_accum;
            
            6: src_mac[47:40] <= byte_accum;
            7: src_mac[39:32] <= byte_accum;
            8: src_mac[31:24] <= byte_accum;
            9: src_mac[23:16] <= byte_accum;
            10: src_mac[15:8] <= byte_accum;
            11: src_mac[7:0] <= byte_accum; 
            
            12: eth_type[15:8] <= byte_accum; 
            13: eth_type[7:0] <= byte_accum;
         endcase
         
         byte_cnt <= byte_cnt + 1;
       end
   
     end else begin
        byte_cnt <= 0;
        nibble_sel <= 0;
     end
  end
endmodule
