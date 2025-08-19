`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/18/2025 09:11:41 AM
// Design Name: 
// Module Name: eth_stage3
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

// Stage 3 Parser: Ethernet + IPv$ + TCP/UDP
// Captures:
//    Ethernet: dst MAC, src MAC, eth_type
//    IPv4: src IP, dst IP, protocol
// TCP/UDP: src src_port, dst_port

    

module eth_stage3(
    input wire clk,
    input wire rst,
    
    // RX interface from PHY/test bench
    input wire [7:0] rx_data,
    input wire       rx_dv,
    
    // TX interface (forward full frame back out)
    output reg [7:0] tx_data,
    output reg       tx_en,
    
    // Metadata outputs
    output reg [47:0] dst_mac,
    output reg [47:0] src_mac,
    output reg [15:0] eth_type,
    output reg [31:0] src_ip,
    output reg [31:0] dst_ip,
    output reg [7:0] ip_protocol,
    output reg [15:0] src_port,
    output reg [47:0] dst_port
    );
    
    reg [10:0] byte_count;  // count bytes in frame
    reg [7:0] byte_accum [0:13]; // store ethernet header
    
    always @(posedge clk) begin
        if (rst) begin
            byte_count <= 0;
            tx_data    <= 0;
            dst_mac    <= 0;
            src_mac    <= 0;
            eth_type   <= 0;
            src_ip     <= 0;
            dst_ip     <= 0;
            ip_protocol <= 0;
            src_port    <= 0;
            dst_port    <= 0;
          end else begin
            if (rx_dv) begin   
                // Forward frame to Pi
                tx_data <= rx_data;
                tx_en   <= 1;
               
                // Count which byte of the frame we're on
                byte_count <= byte_count + 1;
                
                // Capture Ethernet header
                if (byte_count < 14) begin
                    byte_accum[byte_count] <= rx_data;
                end
                
                // Parse IPv4 Header if eth_type == 0x0800
                if (eth_type == 16'h0800) begin
                    // Protocl field @ byte 23
                    if (byte_count == 23) begin
                        ip_protocol <= rx_data;
                    end
                    
                    // Source IP @ bytes 26-29
                    if (byte_count == 26) src_ip[31:24] <= rx_data;
                    if (byte_count == 27) src_ip[23:16] <= rx_data;
                    if (byte_count == 28) src_ip[15:8] <= rx_data;
                    if (byte_count == 29) src_ip[7:0] <= rx_data;
                    
                    
                    // Destination IP @ bytes 30-33
                    if (byte_count == 30) dst_ip[31:24] <= rx_data;
                    if (byte_count == 31) dst_ip[23:16] <= rx_data;
                    if (byte_count == 32) dst_ip[15:8] <= rx_data;
                    if (byte_count == 33) dst_ip[7:0] <= rx_data;
                    
                    // Transport layer ports (only if TCP=6 or UDP=17)
                    if ((ip_protocol == 8'h06) || (ip_protocol == 8'h11)) begin
                        // TCP/UDP header starts at byte 34
                        if (byte_count == 34) src_port[15:8] <= rx_data;
                        if (byte_count == 35) src_port[7:0] <= rx_data;
                        if (byte_count == 36) dst_port[15:8] <= rx_data;
                        if (byte_count == 37) dst_port[7:0] <= rx_data;
                    end
                 end
              end else begin
                 tx_en <= 0;
                 byte_count <= 0;
              end
           end
        end
     endmodule
         
    
