`timescale 1ns / 1ps



module eth_stage2(
    input wire clk,
    input wire rst,
    
    // RX from PHY (Pi + FPGA)
    input wire [7:0] rx_data,
    input wire       rx_dv,
    
    // TX to PHY ( FPGA -> Pi)
    output reg [7:0] tx_data,
    output reg       tx_en,
    
    // Metadata outputs
    output reg [47:0] dst_mac,
    output reg [47:0] src_mac,
    output reg [15:0] eth_type,
    output reg [31:0] src_ip,
    output reg [7:0]  dst_ip,
    output reg [7:0]  ip_protocol
    );
  
 
    // Byte Counter
    reg [10:0] byte_count;
    reg [7:0] byte_accum [0:13]; // Store first 14 bytes, ethernet header)
    
    always @(posedge clk) begin
        if (rst) begin
            byte_count <= 0;
            tx_data <= 8'd0;
            tx_en <= 0;
            dst_mac <= 0;
            src_mac <= 0;
            eth_type <= 0;
            src_ip <= 0;
            dst_ip <= 0;
            ip_protocol <= 0;
            
        end else begin
            if (rx_dv) begin
                //Forward immediately
                tx_data <= rx_data;
                tx_en <= 1;
                
                // Count bytes
                byte_count <= byte_count + 1;
                
                // Capture ethernet header bytes
                if (byte_count < 14) begin
                    byte_accum[byte_count] <= rx_data;
                end
                
                // After ethernet header is received 
                if (byte_count == 13) begin
                dst_mac <= {byte_accum[0], byte_accum[1], byte_accum[2], byte_accum[3], byte_accum[4], byte_accum[5]};
                
                src_mac <= {byte_accum[6], byte_accum[7], byte_accum[8], byte_accum[9], byte_accum[10], byte_accum[11]};
                
                eth_type <= {byte_accum[12], byte_accum[13]};
             end
             
             // If IPv4 (0x0800), parse IP header
             if (eth_type == 16'h0800) begin
                // Protocol field is at byte 23 (counting from 0 = DST MAC[0])
                if (byte_count == 23) begin
                    ip_protocol <= rx_data;
                end
                
                // Source IP: bytes 26-29
                if (byte_count == 26) src_ip[31:24] <= rx_data;               
                if (byte_count == 27) src_ip[23:16] <= rx_data;
                if (byte_count == 28) src_ip[15:8] <= rx_data;
                if (byte_count == 29) src_ip[7:0] <= rx_data;
                
                // Destination IP: bytes 30-33
                if (byte_count == 30) src_ip[31:24] <= rx_data;
                if (byte_count == 31) src_ip[23:16] <= rx_data;
                if (byte_count == 32) src_ip[15:8] <= rx_data;
                if (byte_count == 33) src_ip[7:0] <= rx_data;
             end
          end else begin
            tx_en <= 0;
            byte_count <= 0;
         end
      end
   end
endmodule
