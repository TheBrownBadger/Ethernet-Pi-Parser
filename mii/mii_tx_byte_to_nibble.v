`timescale 1ns / 1ps


module mii_tx_byte_to_nibble(
    input wire  mii_tx_clk, // 25 MHz
    input wire [7:0] tx_data,
    input wire       tx_valid,
    
    output reg [3:0] mii_txd,
    output reg       mii_tx_en

    );
    
    reg [7:0] tx_buf;
    reg       phase; // 0 = low nibble, 1 = high nibble
    
    always @(posedge mii_tx_clk) begin
        if (!tx_valid) begin
            mii_tx_en <= 0;
            phase <= 0;
            mii_txd <= 4'h0;
            tx_buf <= 8'h00;
         end else begin 
            mii_tx_en <= 1;
            if (!phase) begin
                tx_buf <= tx_data;
                // Reverse these two if data is backwards in hardware
                // Assumption the second byte is the high 4 bits
                mii_txd <= tx_data[3:0]; // low nibble first
                phase <= 1;
              end else begin
                mii_txd <= tx_buf[7:4]; // high nibble second
                phase <= 0;
             end
          end
       end
          
              
            
endmodule
