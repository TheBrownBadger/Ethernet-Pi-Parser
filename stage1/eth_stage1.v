`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/15/2025 06:19:12 PM
// Design Name: 
// Module Name: ethernet_stage1
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

            
            
            
            
    /*
    input wire clk,  // 25 MHz for 100Mbs MII
    input wire rst,  // synchronous reset
    
    // MII RX Interface (from PHY to FPGA)
    input wire [3:0] mii_rxd,    // receive data nibble
    input wire mii_rx_dv,        // data valid
    input wire mii_rx_clk,       // receive clock (from PHY)
    
    // MII TX Interface (from FPGA to PHY)
    output reg [3:0] mii_txd,   // transmit data nibble
    output reg mii_tx_en,       // transmit enable
    input wire mii_tx_clk,       // transmit clock (from PHY)
    
    // Simple debug output
    output reg [47:0] dst_mac,
    output reg [47:0] src_mac,
    output reg [15:0] eth_type
    );
    
    //----------------------------------------
    //RX Logic
    //----------------------------------------
    reg [7:0] rx_byte;       // store assembled byte
    reg       rx_half;       // track nibble assembly
    reg [15:0] byte_count;   // count byte in frame
    
    reg [7:0] frame_data [0:1518];   // buffer for one frame
    reg       frame_done;            // flag when frame complete
    
    always @(posedge mii_rx_clk) begin
        if (rst) begin
            rx_half <= 0;
            byte_count  <= 0;
            frame_done  <= 0;
        end
        
        else if (mii_rx_dv) begin
            // Assemble two nibbles into one byte
            if (!rx_half) begin 
                rx_byte[3:0] <= mii_rxd;
                rx_half      <= 1;
            end else begin
                rx_byte[7:4] <= mii_rxd;
                frame_data[byte_count]  <= rx_byte;
                byte_count   <= byte_count + 1;
                rx_half      <= 0;
            end
         end
         else begin
            // End of frame
            if (byte_count > 0) begin   
                frame_done  <= 1;
            end
         end
      end
      
      //--------------------------------------------
      // Parse Ethernet Header once frame is received
      //--------------------------------------------
      always @(posedge clk) begin   
        if (rst) begin
            dst_mac <= 0;
            src_mac <= 0;
            eth_type <= 0;
        end
        else if (frame_done) begin
            // Bytes 0-5: Destination MAC
            dst_mac <= { frame_data[0], frame_data[1], frame_data[2],
                         frame_data[3], frame_data[4], frame_data[5] };
            // Bytes 6-11: Source MAC
            src_mac <= { frame_data[6], frame_data[7], frame_data[8],
                         frame_data[9], frame_data[10], frame_data[11] };
            // Bytes 12-13: EtherType
            eth_type <= { frame_data[12], frame_data[13] };
         end
      end
      
     //----------------------------------------------
     // TX Echo Logic (send frame back)
     //----------------------------------------------
     reg [15:0] tx_byte_count;
     reg        tx_sending;
     reg [7:0]  tx_byte;
     
     always @(posedge mii_tx_clk) begin
     if (rst) begin
        mii_txd    <= 4'h0;
        mii_tx_en  <= 0;
        tx_sending <= 0;
        tx_byte_count <= 0;
     end
     else if (frame_done && !tx_sending) begin
        // Start sending frame back
        tx_sending  <= 1;
        tx_byte_count   <= 0;
        mii_tx_en       <= 0;
     end
     else if (tx_sending) begin
        // Send each byte as two nibbles
        if (tx_byte_count < byte_count) begin
            tx_byte <= frame_data[tx_byte_count];
            mii_txd <= frame_data[tx_byte_count][3:0];
        end else begin
            mii_txd <= tx_byte[7:4];
        end
            tx_byte_count <= tx_byte_count + 1;
        end
        else begin  
            mii_tx_en <= 0;
            tx_sending <= 0;
        end
     end
 
  
    
  endmodule
*/
