module apb_slave (
    input  logic        PCLK,       // APB clock
    input  logic        PRESETn,    // APB reset (active low)
    input  logic        PSEL,       // Slave select
    input  logic        PENABLE,    // Enable signal
    input  logic        PWRITE,     // Write enable (1 = write, 0 = read)
    input  logic [11:0] PADDR,      // Address bus ( the last hex for the num of sbox , the second for the num of row and the 
                                                                     //first for the part of the row)
    input  logic [31:0] PWDATA,     // Write data
    output logic [31:0] PRDATA,     // Read data
    output  logic [11:0] PADDR_out,
    output logic        PREADY,     // Ready signal 
    output logic        PSLVERR     // Slave error
);
    // Internal signals
  logic [63:0] array ;
    // Initialize signals
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PREADY     <= 1'b0;
            PSLVERR    <= 1'b0;
            array     <= 64'b0;
        end else begin
            if (PSEL && PENABLE) begin
                if (PWRITE) begin
                   PREADY     <= 1'b0;
                    // Write operation
                       if (PADDR[3:0]==0) begin  
                           array[31:0] <= PWDATA;
                       end else begin 
                           array[63:32] <= PWDATA;
                   end//////////////////////////////////////////////////////////////////////////// 
                end else begin
                    // Read operation
                  if (PADDR[3:0]==0) begin  
                        PRDATA <= array[31:0] ; 
                        PREADY     <= 1'b1;
                        PADDR_out <= PADDR;
                    end else if (PADDR[3:0]==1) begin 
                        PRDATA <= array[63:32]; 
                        PREADY     <= 1'b1;
                        PADDR_out <= PADDR;
                     end else begin 
                       PSLVERR <= 1'b1;
                       PREADY  <= 1'b0;
                   end//////////////////////////////////////////////////////////////////////////// 
                   
                end
            end
        end
    end

endmodule

