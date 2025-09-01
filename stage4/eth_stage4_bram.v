`timescale 1ns / 1ps

// Stage 4: Buffer full ethernet frame into BRAM,
// parse header fields, apply filtering rules,
// then forward or drop

module eth_stage4_bram (
        input wire clk,
        input wire rst,
        
        // RX interface from PHY or previous module
        input wire [7:0] data_in,
        input wire       data_valid,
        input wire       data_last,   // asserted on last byte of frame
        
        // TX interface to PHY or next module
        output reg [47:0] dst_mac,
        output reg [47:0] src_mac,
        output reg [15:0] eth_type,
        output reg [15:0] ip_proto_ports,
        output reg pkt_accept,
        output reg pkt_drop
        );
      
        
        // FSM states
        localparam IDLE = 2'd0;
        localparam CAPTURE = 2'd1;
        localparam FILTER = 2'd2;
        reg [1:0] state;
        reg [1:0] next_state;
        
        // BRAM packet buffer
        reg [7:0] bram [0:2047];
        reg [10:0] wr_ptr;
        reg [10:0] rd_ptr;
        reg [10:0] total_len;
        
        // Sequential FSM
        always @(posedge clk) begin
            if (rst) begin
                state <= IDLE;
                wr_ptr <= 0;
                total_len <= 0;
                pkt_accept <= 0;
                pkt_drop <= 0;
            end else begin
                state <= next_state;
                
                if (state == FILTER) begin
                    bram[wr_ptr] <= data_in;
                    wr_ptr       <= wr_ptr + 1;
                    total_len    <= wr_ptr + 1;
                end
                
                if (state == FILTER) begin
                // Extract key fields
                // Destination MAC
                dst_mac <= {bram[0], bram[1], bram[2], bram[3], bram[4], bram[5]}; 
                // Source MAC
                src_mac <= {bram[6], bram[7], bram[8], bram[9], bram[10], bram[11]};
                // Ethertypte
                eth_type <= {bram[12], bram[13]}; 
              
                // Protocol field @ offset 23
                // TCP = 6, UDP = 17
                ip_proto_ports[15:8] <= bram[23];
                // TCP/UDP dest port - offset 36/37
                ip_proto_ports[7:0] <= bram[37];
                
                // Example filter rule;
                // Drop TCP with dst port 80
                if (bram[23] == 8'h06 && {bram[36], bram[37]} == 16'd80) begin
                    pkt_drop <= 1;
                    pkt_accept <= 0;
                end else begin
                    pkt_accept <= 1;
                    pkt_drop   <= 0;
                end
            end else begin
                pkt_accept <= 1; // non-IPv4 -> pass
                pkt_drop   <= 0;
            end
         end
      end
  
  
   
            // Next-state logic
            always @(*) begin 
            next_state = state;
                case(state)
                    IDLE: begin
                        if (data_valid)
                            next_state = CAPTURE;
                     end
                     
                     CAPTURE: begin
                        if (data_last)
                            next_state = FILTER;
                        end
                        
                     FILTER: begin
                        next_state = IDLE;
                     end
                  endcase
               end
               
                       
           endmodule
           
                   
          
  
