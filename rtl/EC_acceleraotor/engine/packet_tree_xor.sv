//=====================================================================================================
//
// Module:  packet_tree_xor
//
// Description
// ===========
// 
// takes MASK_W packets (each packet consists of PACKET_LENGTH words)
// XOR the respective bits of MASK_W words (one word from every packet)
// output is the XOR result. its size is PACKET_LENGTH*W.
//
//======================================================================================================

// Sub Modules:


//Notes:

//TODO list:

//======================================================================================================
////######################################### MODULE ####################################################

module packet_tree_xor #(

//=================================
//  user parameters 
//=================================
	parameter MASK_W = 128,
	parameter K_MIN = 2,
	parameter M_MAX = 128,
	parameter M_MIN = 2,
	parameter W = 4,
	parameter K = 2,
	parameter PACKET_LENGTH =  2 

//=================================
//  local parameters (DON'T CHANGE)
//=================================


)(
//===========
//  inputs:
//===========

	input [PACKET_LENGTH-1:0] packets [0:W-1][0:MASK_W-1], 

//===========
//  outputs:
//===========

	output [PACKET_LENGTH-1:0] xor_product [0:W-1]

);

//======================
//  logic:
//======================
	
	genvar i;
	generate
	
		for (i=0; i<W; i=i+1) begin
	
			tree_xor #(
			.INPUT_NUM(MASK_W)
            ,.PACKET_LENGTH(PACKET_LENGTH)
			) tree_xor_i (
			//input
			.packets_arr(packets[i]),
			//output
			.xor_product(xor_product[i])
			);



		end
		
	endgenerate

endmodule
