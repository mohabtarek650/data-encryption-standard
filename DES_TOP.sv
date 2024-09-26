module DES_TOP  #(parameter data_width=64,key_width=64,gen_key_48_width=48)  (
  
input  logic                             slave_clk,       
input  logic                             slave_rst,    
input  logic                             PSEL,       
input  logic                             PENABLE,   
input  logic                             PWRITE,     
input  logic  [11:0]                     PADDR,                                                                      
input  logic  [31:0]                     PWDATA,    
output logic                             PREADY,     
output logic                             PSLVERR,  
input  logic                             clk,
input  logic                             rst,
input  logic                             enable,
input  logic                             encryption_enable,
input  logic  [key_width-1:0]            cipher_key,
input  logic  [data_width-1:0]           in_data,
output  logic                            data_valid,
output  logic  [data_width-1:0]          out_data
);

logic                             enable_reg;
logic                             encryption_enable_reg;
logic  [key_width-1:0]            cipher_key_reg;
logic  [data_width-1:0]           in_data_reg;
logic                            data_valid_reg;
logic  [data_width-1:0]          out_data_reg;

always_ff @ (posedge clk,negedge rst) begin
  if (!rst) begin
     enable_reg <= 0;
    encryption_enable_reg <= 0 ;
    cipher_key_reg <= 0;
    in_data_reg <= 0;
    data_valid <= 0;
    out_data <= 0;
  end else begin
     enable_reg <= enable;
    encryption_enable_reg <= encryption_enable ;
    cipher_key_reg <= cipher_key;
    in_data_reg <= in_data;
    data_valid <= data_valid_reg;
    out_data <= out_data_reg;
  end 
end


logic [15:0][47:0] gen_key_48_top ;
logic [31:0]       data_sync_out;
logic              data_sync_out_en; 
logic [11:0]       data_sync_out_1;
logic              data_sync_out_en_1;  
logic [31:0]       data_sync_in;  
logic [11:0]       sbox_addr;

        

data_rounds u0_data_rounds(
.CLK(clk),
.RST(rst),
.enable(enable_reg),
.subkeys(gen_key_48_top),
.message(in_data_reg),
.data_valid(data_valid_reg),
.ciphertext(out_data_reg),
.S_ADDR(data_sync_out_1),
.S_ADDR_en(data_sync_out_en_1),
.PRDATA_en(data_sync_out_en),
.PRDATA(data_sync_out)
);


DATA_SYNC u0_DATA_SYNC(
.CLK(clk),
.RST(rst),
.unsync_bus(data_sync_in),
.bus_enable(PREADY),
.sync_bus(data_sync_out),
.enable_pulse_d(data_sync_out_en)
);

DATA_SYNC#(
        .BUS_WIDTH(12)                 
    ) u1_DATA_SYNC(
.CLK(clk),
.RST(rst),
.unsync_bus(sbox_addr),
.bus_enable(PREADY),
.sync_bus(data_sync_out_1),
.enable_pulse_d(data_sync_out_en_1)
);
    
                  
apb_slave u0_apb_slave (
.PCLK(slave_clk),       
.PRESETn(slave_rst),    
.PSEL(PSEL),      
.PENABLE(PENABLE),   
.PWRITE(PWRITE),    
.PADDR(PADDR),      
.PWDATA(PWDATA),    
.PRDATA(data_sync_in),  
.PADDR_out(sbox_addr), 
.PREADY(PREADY),
.PSLVERR(PSLVERR)    
);

key_48_gen u0_key_48_gen(
.encryption_en(encryption_enable_reg),
.key(cipher_key_reg),
.subkey(gen_key_48_top)
);


endmodule

