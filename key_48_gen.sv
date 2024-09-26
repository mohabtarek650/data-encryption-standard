module key_48_gen #(KEY_WIDTH=64, GEN_KEY_WIDTH=56,GEN_KEY_48_WIDTH=48) (
	
	input  logic                 encryption_en,
	input  logic [KEY_WIDTH-1:0] key, 
  output logic [15:0][GEN_KEY_48_WIDTH-1:0] subkey // 16 48-bit subkeys
);

    logic [ GEN_KEY_WIDTH-1:0] permuted_key; // 56-bit permuted key
    logic [16:0][ GEN_KEY_WIDTH-1:0] shifted_keys; // 16 56-bit shifted keys
    logic [16:0][27:0] R;
    logic [16:0][27:0]L ;
///////////////////////////////////////////////////////////////////////////////////////
    // Permuted Choice 1 (PC-1) table
 const int PC1[56] = '{ 
        57, 49, 41, 33, 25, 17,  9, 
         1, 58, 50, 42, 34, 26, 18, 
        10,  2, 59, 51, 43, 35, 27, 
        19, 11,  3, 60, 52, 44, 36, 
        63, 55, 47, 39, 31, 23, 15, 
         7, 62, 54, 46, 38, 30, 22, 
        14,  6, 61, 53, 45, 37, 29, 
        21, 13,  5, 28, 20, 12,  4 
    };
    
    // Permuted Choice 2 (PC-2) table
    const int PC2[48] = '{ 
        14, 17, 11, 24,  1,  5, 
         3, 28, 15,  6, 21, 10, 
        23, 19, 12,  4, 26,  8, 
        16,  7, 27, 20, 13,  2, 
        41, 52, 31, 37, 47, 55, 
        30, 40, 51, 45, 33, 48, 
        44, 49, 39, 56, 34, 53, 
        46, 42, 50, 36, 29, 32 
    };

/////////////////////////////////////////////////////////////////////////////////////////
    
function logic [27:0] rotate_left (input logic [27:0] data, input int amount);
  logic [27:0] result;
  result = data << amount; // Shift left
  result = result | (data >> (28 - amount)); // Wrap around bits
  return result;
endfunction
///////////////////////////////////////////////////////////////////////////////////////////
		  always_comb begin
        for (int i =0; i <56; i++) begin
            permuted_key[55-i] = key[64-PC1[i]];
        end
    end
////////////////////////////////////////////////////////////////////////////////////////////
    // Generate 16 subkeys
   always_comb begin
 if (encryption_en)
begin 
        shifted_keys[0] = permuted_key;
        for (int round = 1; round <= 16; round++) begin
      
     if (round == 1 ||  round == 2 || round == 9 || round == 16) begin
       R[round][27:0]= rotate_left (shifted_keys[round-1][27:0],1);
       L[round][27:0]  = rotate_left (shifted_keys[round-1][55:28],1);
       shifted_keys[round][55:0] ={L[round][27:0],R[round][27:0]};
       
            end
          else begin
                R[round][27:0] = rotate_left (shifted_keys[round-1][27:0],2);
                L[round][27:0]= rotate_left (shifted_keys[round-1][55:28],2);
               shifted_keys[round][55:0] ={L[round][27:0],R[round][27:0]};
             end
              // Apply PC-2 permutation to generate subkeys
        for (int round = 1; round <= 16; round++) begin
           for (int i = 0; i < 48; i++) begin
             subkey[round-1][47-i] =shifted_keys[round][56-PC2[i]];
              
            end  
            
        end
      end
            
end          
       
        else if (!encryption_en) begin
           shifted_keys[0] = permuted_key;
        for (int round = 1; round <= 16; round++) begin
      
     if (round == 1 ||  round == 2 || round == 9 || round == 16) begin
       R[round][27:0]= rotate_left (shifted_keys[round-1][27:0],1);
       L[round][27:0]  = rotate_left (shifted_keys[round-1][55:28],1);
       shifted_keys[round][55:0] ={L[round][27:0],R[round][27:0]};
       
            end
          else begin
                R[round][27:0] = rotate_left (shifted_keys[round-1][27:0],2);
                L[round][27:0]= rotate_left (shifted_keys[round-1][55:28],2);
               shifted_keys[round][55:0] ={L[round][27:0],R[round][27:0]};
             end
          
        // Apply PC-2 permutation to generate subkeys
        for (int round =0; round < 16; round++) begin
           for (int i = 0; i < 48; i++) begin
               subkey[round][47-i] = shifted_keys[16-round][56-PC2[i]];
                
            end
     
       
        end
  
    end
    
 end
 
end

endmodule






