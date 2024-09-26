`timescale 1ns/1ps

module sys_top_tb();

parameter data_width=64;
parameter key_width=64;
parameter gen_key_48_width=48;
/////////////////////////////////////////////////////////
//////////////////// DUT Signals ////////////////////////
/////////////////////////////////////////////////////////
logic                             clk_des;
logic                             rst_des;
logic                             clk_abp;
logic                             rst_abp;
logic                             enable_data_rounds;
logic                             encryption_enable;
logic  [key_width-1:0]            cipher_key;
logic  [data_width-1:0]           in_data;
logic                             abp_en;
logic                             abp_write_en;       
logic  [11:0]                      abp_address;      
logic  [31:0]                     abp_write_data;        
logic                            data_valid;
logic  [data_width-1:0]          out_data;
logic                            PSEL;
logic                            PREADY;
logic                            PSLVERR; 
////////////////////////////////////////////////////////
////////////////// initial block /////////////////////// 
////////////////////////////////////////////////////////
initial
begin
  $dumpfile("DES_TOP.vcd"); // waveforms in this file      
  $dumpvars;     
    // Initialization
    initialize();
    // Reset
    reset_des();
    reset_APD();
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////filling the sbox///////////////////////////////////////////////////////////
        data_abp_in_row(32'h8BF21D4E,12'h000);
        data_abp_in_row(32'h7095C6A3,12'h001);
        data_abp_in_row(32'h1D2E47F0,12'h010);
        data_abp_in_row(32'h8359BC6A,12'h011);
        data_abp_in_row(32'hB26D8E14,12'h020);
        data_abp_in_row(32'h05A379CF,12'h021); 
        data_abp_in_row(32'h719428CF,12'h030);
        data_abp_in_row(32'hD60AE3B5,12'h031);
        data_abp_in_row(32'h9436E81F,12'h100);
        data_abp_in_row(32'hC0A50D27,12'h101);
        data_abp_in_row(32'hE82F7D43,12'h110);
        data_abp_in_row(32'hB596A10C,12'h111);
        data_abp_in_row(32'h1D4AB7E0,12'h120);
        data_abp_in_row(32'hF2396C85,12'h121);
        data_abp_in_row(32'h24F3B18D,12'h130);
        data_abp_in_row(32'h9E50C7B6,12'h131); 
        data_abp_in_row(32'h5F36E90A,12'h200);
        data_abp_in_row(32'h824BC7D1,12'h201);
        data_abp_in_row(32'hA643907D,12'h210);
        data_abp_in_row(32'h1FBC5E82,12'h211);
        data_abp_in_row(32'h3F8694D6,12'h220);
        data_abp_in_row(32'h7A5C21B0,12'h221);
        data_abp_in_row(32'h78960DA1,12'h230); 
        data_abp_in_row(32'hC25B3EF4,12'h231);      
        data_abp_in_row(32'h1093E7D6,12'h300);
        data_abp_in_row(32'hF4FC5B82,12'h301);
        data_abp_in_row(32'h63F5C8D,12'h310);
        data_abp_in_row(32'h9E8C1274,12'h311);
        data_abp_in_row(32'hBD690EFA,12'h320);
        data_abp_in_row(32'h4E35B87E,12'h321);
        data_abp_in_row(32'h80D160F3,12'h330); 
        data_abp_in_row(32'hE2CB7549,12'h331);
        data_abp_in_row(32'h6BA714C2,12'h400);
        data_abp_in_row(32'h9E0DF358,12'h401);
        data_abp_in_row(32'h3F517CBE,12'h410);
        data_abp_in_row(32'h6658901A,12'h411);
        data_abp_in_row(32'h7DA314B2,12'h420);
        data_abp_in_row(32'hE0635C9F,12'h421);
        data_abp_in_row(32'h2DE1C7B8,12'h430); 
        data_abp_in_row(32'h354A9F06,12'h431);
        data_abp_in_row(32'h08629FAC,12'h500);
        data_abp_in_row(32'hB57E430D,12'h501);
        data_abp_in_row(32'h597C24FA,12'h510);
        data_abp_in_row(32'h83B0ED16,12'h511);
        data_abp_in_row(32'hC328F59E,12'h520);
        data_abp_in_row(32'hB6D1407B,12'h521);
        data_abp_in_row(32'hF7A95234,12'h530); 
        data_abp_in_row(32'hD806071E,12'h531);
        data_abp_in_row(32'hD8CF2EB4,12'h600);
        data_abp_in_row(32'h16579C93,12'h601);  
        data_abp_in_row(32'h1E497BD0,12'h610);
        data_abp_in_row(32'h68F2C5A3,12'h611); 
        data_abp_in_row(32'h7EC37D41,12'h620);
        data_abp_in_row(32'h058B06FA,12'h621); 
        data_abp_in_row(32'h741ABD6B,12'h630); 
        data_abp_in_row(32'h2C93EF54,12'h631); 
        data_abp_in_row(32'hBCF6C482,12'h700); 
        data_abp_in_row(32'h7305AE93,12'h701);
        data_abp_in_row(32'h7A836DF1,12'h710);
        data_abp_in_row(32'h2E0B7653,12'h711);        
        data_abp_in_row(32'hF29C14B7,12'h720);
        data_abp_in_row(32'h8A0E683D,12'h721);
        data_abp_in_row(32'hD48AE712,12'h730);
        data_abp_in_row(32'hB3069CBF,12'h731); 
        #30
	////////////////////////////////////////////////////////////////////////////////////////////////////////     
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////Testing the encryption ///////////////////////////////////////////////////////////////////////////
    $display("Test case 1");
   data_in_1(64'h0123456789ABCDEF,64'h133457799BBCDFF1,1'b1 , 1'b1); 
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
   //////////Testing the decryption ///////////////////////////////////////////////////////////////////////////
    $display("Test case 2"); 
   // data_in_2(64'h85E813540F0AB405,64'h133457799BBCDFF1,1'b0 , 1'b1); 
     
     
     
   
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
   //////////Testing 2 inputs in two cycles ///////////////////////////////////////////////////////////////
    $display("Test case 3"); 
    // data_2cycle(64'h123456789ABCDEF, 64'h133457799BBCDFF1,1'b1 ,1'b1);
   
   
    /////////////////////////////////////////////////////////////////////////////////////////////////////
   //////////Testing 2 inputs in two cycles one for enc and the other for dec  //////////////////////////

   $display("Test case 4"); 
 //   data_2states(64'h123456789ABCDEF, 64'h133457799BBCDFF1,1'b1 ,1'b1);
   
    

    #3000
    $stop;
end

/////////////// Signals Initialization //////////////////////////////////////////////////////////////
task initialize;
  begin
    clk_des = 1'b0;
    rst_des = 1'b1; // rst is deactivated
    clk_abp = 1'b0;
    rst_abp = 1'b1; 
    encryption_enable = 1'b0;
    enable_data_rounds = 1'b0;
    in_data = 64'b0;
    cipher_key = 64'b0;
    PSEL       = 1'b0;
  end
endtask

///////////////////////// RESET /////////////////////////////////////////////////////////////////////
task reset_des;
  begin
    #10
    rst_des = 1'b0; // rst is activated
    #10
    rst_des = 1'b1;
    #10;
  end
endtask

task reset_APD;
  begin
    #20
    rst_abp = 1'b0; // rst is activated
    #20
    rst_abp = 1'b1;
    #20;
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////
task data_in_1(input [data_width-1:0] data1, input [key_width-1:0] key1, input enc_en, input en);
  begin
    @(posedge clk_des)
    encryption_enable = enc_en;
    enable_data_rounds = en;
    cipher_key = key1;
    in_data = data1;
    @(posedge clk_des)
    enable_data_rounds = 1'b0;
    @(negedge clk_des)
    if (out_data == 64'h85E813540F0AB405 && data_valid == 1)
    begin
        $display("Operation is succeeded");
    end
    else
    begin
        $display("Operation is failed");
    end
  end
endtask

/////////////////////////////////////////////////////////////////////////////////////////////////////////
task data_in_2(input [data_width-1:0] data2, input [key_width-1:0] key2, input enc_en, input en);
  begin
    @(posedge clk_des)
    encryption_enable = enc_en;
    enable_data_rounds = en;
    cipher_key = key2;
    in_data = data2;
    @(posedge clk_des)
    enable_data_rounds = 1'b0;
    @(negedge clk_des)
    if (out_data == 64'h123456789ABCDEF && data_valid == 1)
    begin
        $display("Operation is succeeded");
    end
    else
    begin
        $display("Operation is failed");
    end
  end
endtask

///////////////////////////////////////////////////////////////////////////////////////////////////////////
task data_abp_in_row(input [31:0] data_1, input [11:0] address_1);
  begin
    #20
    PSEL = 1;       
    abp_en = 1; 
    abp_write_en = 1;
    abp_address = address_1;
    abp_write_data = data_1;
    #20
    abp_write_en = 0;
    
 
end
endtask
//////////////////////////////////////////////////////////////////////////////////////////////////////////
task data_2cycle(input [data_width-1:0] data3, input [key_width-1:0] key3, input enc_en, input en);
  begin
    @(posedge clk_des)
    encryption_enable = enc_en;
    enable_data_rounds = en;
    cipher_key = key3;
    in_data = data3;
    @(posedge clk_des)
    cipher_key = 64'h0E329232EA6D0D73;
    in_data = 64'h8787878787878787;
    @(negedge clk_des)
    if (out_data == 64'h85E813540F0AB405 && data_valid == 1)
    begin
        $display("Operation is succeeded");
    end
    else
    begin
        $display("Operation is failed");
    end
    @(posedge clk_des)
    enable_data_rounds = 1'b0;
    @(negedge clk_des)
    if (out_data == 64'h0000000000000000 && data_valid == 1)
    begin
        $display("Operation is succeeded");
    end
    else
    begin
        $display("Operation is failed");
    end
  end
endtask

////////////////////////////////////////////////////////////////////////////////////////////////////////////
task data_2states(input [data_width-1:0] data4, input [key_width-1:0] key4, input enc_en, input en);
  begin
    @(posedge clk_des)
    encryption_enable = enc_en;
    enable_data_rounds = en;
    cipher_key = key4;
    in_data = data4;
    @(posedge clk_des)
    encryption_enable = !enc_en;
    cipher_key = key4;
    in_data = 64'h85E813540F0AB405;
    @(negedge clk_des)
    if (out_data == 64'h85E813540F0AB405 && data_valid == 1)
    begin
        $display("Operation is succeeded");
    end
    else
    begin
        $display("Operation is failed");
    end
    @(posedge clk_des)
    enable_data_rounds = 1'b0;
    @(negedge clk_des)
    if (out_data == 64'h0000000000000000 && data_valid == 1)
    begin
        $display("Operation is succeeded");
    end
    else
    begin
        $display("Operation is failed");
    end
  end
endtask

//////////////////////// Clock ///////////////////////////////////////////
always #5 clk_des = ~clk_des; 

always #10 clk_abp = ~clk_abp; 

DES_TOP DUT (
.clk(clk_des),
.rst(rst_des),
.slave_clk(clk_abp),
.slave_rst(rst_abp),
.enable(enable_data_rounds),
.encryption_enable(encryption_enable),
.cipher_key(cipher_key),
.in_data(in_data),
.PENABLE(abp_en),    
.PWRITE(abp_write_en),       
.PADDR(abp_address),      
.PWDATA(abp_write_data), 
.PSEL(PSEL),
.PREADY(PREADY),
.PSLVERR(PSLVERR),     
.data_valid(data_valid),
.out_data(out_data)
);
 


endmodule




