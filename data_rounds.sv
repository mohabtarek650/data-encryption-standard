module data_rounds #(parameter KEY_WIDTH=64,GEN_KEY_48_WIDTH=48)(
  
output logic [KEY_WIDTH-1:0]             ciphertext, 
input logic[KEY_WIDTH-1:0]               message, 
input logic [15:0][GEN_KEY_48_WIDTH-1:0] subkeys, 
input logic                              enable, 
output logic                             data_valid, 
input  logic   [31:0]                    PRDATA,
input  logic                             PRDATA_en,
input  logic   [11:0]                    S_ADDR, 
input  logic                            S_ADDR_en,
input logic                              CLK, 
input logic                              RST
);


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  function [KEY_WIDTH-1:0] perm_IP(input  [KEY_WIDTH-1:0] message);
    logic [KEY_WIDTH-1:0] temp_msg;
    integer i;
    begin
		 const int IP[64] = '{ 
        58, 50, 42, 34, 26, 18,  10, 2, 60, 52, 44, 36, 28, 20, 12,  4, 62, 54, 46, 38, 30, 22, 14,  6, 64, 56, 48, 40, 
        32, 24, 16, 8, 57, 49, 41,33, 25, 17, 9, 1, 59, 51,43,  35, 27, 19, 11, 3, 61, 53, 45, 37, 29, 21, 13, 5,63,55,47,39,31,23,15,7 
    };

			for(i=0; i<64; i=i+1)
        temp_msg[63-i] = message[64-IP[i]];
      perm_IP = temp_msg;      
    end
  endfunction
  
  function [KEY_WIDTH-1:0] perm_IP_inverse(input [KEY_WIDTH-1:0] message);
    logic [KEY_WIDTH-1:0] temp_msg;
    integer i;
 	  begin
 	    const int IP_inverse[64] = '{ 
        40, 8, 48, 16, 56, 24,  64, 32, 39, 7, 47, 15, 55, 23, 63,  31, 38, 6, 46, 14, 54, 22, 62,30, 37, 5, 45, 13, 
        53, 21, 61, 29, 36, 4, 44,12, 52, 20, 60, 28, 35, 3,43, 11, 51, 19, 59, 27, 34, 2, 42, 10, 50, 18, 58,26,33,1,41,9,49,17,57,25 
    };
			for(i=0; i<64; i=i+1)
        temp_msg[63-i] = message[64-IP_inverse[i]];
      perm_IP_inverse = temp_msg;
 	  end
  endfunction
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  function [GEN_KEY_48_WIDTH-1:0] perm_E(input  [(KEY_WIDTH/2)-1:0] R);
    logic[GEN_KEY_48_WIDTH-1:0] temp_E;
    integer i;
    begin
		 const int E [48] = '{ 
        32, 1, 2, 3, 4, 5,  4, 5, 6, 7, 8, 9, 8, 9, 10,  11, 12, 13, 12, 13, 14, 15, 16,17, 16, 17, 18, 19, 
        20, 21, 20, 21, 22, 23, 24,25, 24, 25, 26, 27, 28, 29,28, 29, 30, 31, 32, 1  
    };
		
      for(i=0; i<48; i=i+1)
        temp_E[47-i] = R[32-E[i]];

      perm_E = temp_E;
    end
  endfunction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  function [(KEY_WIDTH/2)-1:0] perm_P(input  [(KEY_WIDTH/2)-1:0] s_res);
    integer i;
    logic [(KEY_WIDTH/2)-1:0] temp_P;
    begin
       const int P[32] = '{ 
        16, 7, 20, 21, 29, 12,  28, 17, 1, 15, 23, 26, 5, 18, 31,  10, 2, 8, 24, 14, 32, 27, 3,9, 19, 13, 30, 6, 
        22, 11, 4, 25
    };
    
      for(i=0; i<32; i=i+1)
        temp_P[31-i] = s_res[32-P[i]];
      perm_P = temp_P;
    end
  endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 logic [3:0] S[7:0][3:0][15:0] ;
 function [3:0] SBOX(input logic [6:1] B, input [4:0] s_table_id);
    logic [1:0] i;
    logic [3:0] j;
  
    begin
	/*	S[0] = '{'{14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7},
                '{ 0,15, 7, 4,14, 2,13, 1,10, 6,12,11, 9, 5, 3, 8},
                '{ 4, 1,14, 8,13, 6, 2,11,15,12, 9, 7, 3,10, 5, 0},
                '{15,12, 8, 2, 4, 9, 1, 7, 5,11, 3,14,10, 0, 6,13}};
    // S2
    S[1] = '{'{15, 1, 8,14, 6,11, 3, 4, 9, 7, 2,13,12, 0, 5,10},
                '{ 3,13, 4, 7,15, 2, 8,14,12, 0, 1,10, 6, 9,11, 5},
                '{ 0,14, 7,11,10, 4,13, 1, 5, 8,12, 6, 9, 3, 2,15},
                '{13, 8,10, 1, 3,15, 4, 2,11, 6, 7,12, 0, 5,14, 9}};
    // S3
    S[2] = '{'{10, 0, 9,14, 6, 3,15, 5, 1,13,12, 7,11, 4, 2, 8},
                '{13, 7, 0, 9, 3, 4, 6,10, 2, 8, 5,14,12,11,15, 1},
                '{13, 6, 4, 9, 8,15, 3, 0,11, 1, 2,12, 5,10,14, 7},
                '{ 1,10,13, 0, 6, 9, 8, 7, 4,15,14, 3,11, 5, 2,12}};
    // S4
    S[3] = '{'{ 7,13,14, 3, 0, 6, 9,10, 1, 2, 8, 5,11,12, 4,15},
                '{13, 8,11, 5, 6,15, 0, 3, 4, 7, 2,12, 1,10,14, 9},
                '{10, 6, 9, 0,12,11, 7,13,15, 1, 3,14, 5, 2, 8, 4},
                '{ 3,15, 0, 6,10, 1,13, 8, 9, 4, 5,11,12, 7, 2,14}};
    // S5
    S[4] = '{'{ 2,12, 4, 1, 7,10,11, 6, 8, 5, 3,15,13, 0,14, 9},
                '{14,11, 2,12, 4, 7,13, 1, 5, 0,15,10, 3, 9, 8, 6},
                '{ 4, 2, 1,11,10,13, 7, 8,15, 9,12, 5, 6, 3, 0,14},
                '{11, 8,12, 7, 1,14, 2,13, 6,15, 0, 9,10, 4, 5, 3}};
    // S6
    S[5] = '{'{12, 1,10,15, 9, 2, 6, 8, 0,13, 3, 4,14, 7, 5,11},
                '{10,15, 4, 2, 7,12, 9, 5, 6, 1,13,14, 0,11, 3, 8},
                '{ 9,14,15, 5, 2, 8,12, 3, 7, 0, 4,10, 1,13,11, 6},
                '{ 4, 3, 2,12, 9, 5,15,10,11,14, 1, 7, 6, 0, 8,13}};
    // S7
    S[6] = '{'{ 4,11, 2,14,15, 0, 8,13, 3,12, 9, 7, 5,10, 6, 1},
                '{13, 0,11, 7, 4, 9, 1,10,14, 3, 5,12, 2,15, 8, 6},
                '{ 1, 4,11,13,12, 3, 7,14,10,15, 6, 8, 0, 5, 9, 2},
                '{ 6,11,13, 8, 1, 4,10, 7, 9, 5, 0,15,14, 2, 3,12}};
    // S8
    S[7] = '{'{13, 2, 8, 4, 6,15,11, 1,10, 9, 3,14, 5, 0,12, 7},
                '{ 1,15,13, 8,10, 3, 7, 4,12, 5, 6,11, 0,14, 9, 2},
                '{ 7,11, 4, 1, 9,12,14, 2, 0, 6,10,13,15, 3, 5, 8},
                '{ 2, 1,14, 7, 4,10, 8,13,15,12, 9, 0, 3, 5, 6,11}};
	*/		
      i[1:0] = {B[6], B[1]};
      j[3:0] = B[5:2];
      
      case(s_table_id)
        5'b01: SBOX = S[0][i][j];
        5'b10: SBOX =  S[1][i][j];
        5'b11: SBOX =  S[2][i][j];
        5'b100: SBOX =  S[3][i][j];
        5'b101: SBOX =  S[4][i][j];
        5'b110: SBOX =  S[5][i][j];
        5'b111: SBOX =  S[6][i][j];
        5'b1000: SBOX =  S[7][i][j];
      endcase
      
    end
  endfunction
/////////////////////////////////////////////////////////////////////////////////////////////////////////
  function [(KEY_WIDTH/2)-1:0] f(input [(KEY_WIDTH/2)-1:0] R, input [GEN_KEY_48_WIDTH-1:0] K);
    logic [GEN_KEY_48_WIDTH-1:0] temp;
    logic [(KEY_WIDTH/2)-1:0] temp_after_s_box;
    logic [5:0] B[8:1];
    begin
      temp = K ^ perm_E(R);
      B[1] = temp[47:42];
      B[2] = temp[41:36];
      B[3] = temp[35:30];
      B[4] = temp[29:24];
      B[5] = temp[23:18];
      B[6] = temp[17:12];
      B[7] = temp[11:6];
      B[8] = temp[5:0];
      
      temp_after_s_box = {SBOX(B[1], 5'd1), SBOX(B[2], 5'd2), SBOX(B[3], 5'd3), SBOX(B[4], 5'd4),
                          SBOX(B[5], 5'd5), SBOX(B[6], 5'd6), SBOX(B[7], 5'd7), SBOX(B[8], 5'd8)};

      f = perm_P(temp_after_s_box);
    end
  endfunction
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
 integer i , z;
// Internal signals
    logic [KEY_WIDTH-1:0] new_msg, ciphertext_1;
    logic [KEY_WIDTH/2-1:0] L[16:0], R[16:0];
    logic data_valid_1;

 
always_comb begin
if(enable) begin
            new_msg = perm_IP(message);
            {L[0], R[0]} = new_msg;
            for(i = 1; i <= 16; i = i + 1) begin
                L[i] = R[i-1];
                R[i] = L[i-1] ^ f(R[i-1], subkeys[i-1]);  
            end
            ciphertext_1 = perm_IP_inverse({R[16], L[16]});
            data_valid_1 = 1;
    end else begin
            ciphertext_1 = 'b0;
            data_valid_1 = 0;
        end
end
  

  always_ff @(posedge CLK or negedge RST) begin
        if(!RST) begin
            ciphertext <= 'b0;
            data_valid <= 0;
        end else begin
          if(PRDATA_en && S_ADDR_en) begin
           if (S_ADDR[3:0]==0) begin  
                       for (z=0;z<=7;z++)begin
                           case (z)
                              0:S[S_ADDR[11:8]][S_ADDR[7:4]][z]<= PRDATA[3:0];
                              1:S[S_ADDR[11:8]][S_ADDR[7:4]][z]<= PRDATA[7:4];
                              2:S[S_ADDR[11:8]][S_ADDR[7:4]][z]<= PRDATA[11:8]; 
                              3:S[S_ADDR[11:8]][S_ADDR[7:4]][z]<= PRDATA[15:12];
                              4:S[S_ADDR[11:8]][S_ADDR[7:4]][z]<= PRDATA[19:16];
                              5:S[S_ADDR[11:8]][S_ADDR[7:4]][z]<= PRDATA[23:20]; 
                              6:S[S_ADDR[11:8]][S_ADDR[7:4]][z]<= PRDATA[27:24];
                              7:S[S_ADDR[11:8]][S_ADDR[7:4]][z]<= PRDATA[31:28];  
                              default :S[S_ADDR[11:8]][S_ADDR[7:4]][z]<=0; 
                           endcase
                          end
                       end else begin 
                          for (z=8;z<=15;z++)begin
                             case (z)
                               8:S[S_ADDR[11:8]][S_ADDR[7:4]][z]  <=PRDATA[3:0];
                               9:S[S_ADDR[11:8]][S_ADDR[7:4]][z]  <=PRDATA[7:4];
                               10:S[S_ADDR[11:8]][S_ADDR[7:4]][z] <=PRDATA[11:8];
                               11:S[S_ADDR[11:8]][S_ADDR[7:4]][z] <=PRDATA[15:12]; 
                               12:S[S_ADDR[11:8]][S_ADDR[7:4]][z] <=PRDATA[19:16];
                               13:S[S_ADDR[11:8]][S_ADDR[7:4]][z] <=PRDATA[23:20];
                               14:S[S_ADDR[11:8]][S_ADDR[7:4]][z] <=PRDATA[27:24]; 
                               15:S[S_ADDR[11:8]][S_ADDR[7:4]][z]<=PRDATA[31:28];   
                               default :S[S_ADDR[11:8]][S_ADDR[7:4]][z]<=0; 
                             endcase
                         end    
                   end//////////////////////////////////////////////////////////////////////////// 
           
          end else begin
          ciphertext <= ciphertext_1;
          data_valid <= data_valid_1;
          end
      
    end

end

endmodule
