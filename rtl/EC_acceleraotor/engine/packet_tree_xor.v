//=====================================================================================================
//
// Module:  dyn_xor_unit
//
// Description
// ===========
// 
// takes K_MAX packets (each packet consists of PACKET_LENGTH words)
// XOR the respective bits of K_MAX words (one word from every packet)
// output is the XOR result. its size is PACKET_LENGTH*W.
//
//======================================================================================================

// Sub Modules:


//Notes:

//TODO list:

//======================================================================================================
////######################################### MODULE ####################################################

module dyn_xor_unit #(

//=================================
//  user parameters 
//=================================
	include "global_parameters.v"
//=================================
//  local parameters (DON'T CHANGE)
//=================================


)(
//===========
//  inputs:
//===========

	input [PACKET_LENGTH-1:0] packets [0:W-1][0:K_MAX-1], 

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
	
		for (i=0 i<W; i=i+1) begin
	
			tree_xor #(
			.INPUT_NUM(K_MAX)
			) tree_xor_i (
			//input
			.packets_arr(packets[i]),
			//output
			.xor_product(xor_product[i])
			);



		end
		
	endgenerate

endmodule
