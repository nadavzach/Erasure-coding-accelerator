//=====================================================================================================
//
// Module:  dyn_xor_unit
//
// Description
// ===========
// 
//	takes K_MAX packets (each packet consists of PACKET_LENGTH words) mask
// and another packets vector of the same length.
// performs the masking by bit wise AND between the two given vectors
//
//======================================================================================================

// Sub Modules:


//Notes:

//TODO list:

//======================================================================================================
////######################################### MODULE ####################################################

module mask_unit #(

//=================================
//  user parameters 
//=================================
	`include "global_parameters.v"
//=================================
//  local parameters (DON'T CHANGE)
//=================================


)(
//===========
//  inputs:
//===========

	input [PACKET_LENGTH-1:0] packets	[0:W-1][0:K_MAX-1],
	input [PACKET_LENGTH-1:0] mask		[0:W-1][0:K_MAX-1], 	

//===========
//  outputs:
//===========

	output [PACKET_LENGTH-1:0] mask_product [0:W-1][0:K_MAX-1]

);

//======================
//  logic:
//======================
	
	genvar i,j;
	generate
	
		for (i=0 i<W; i=i+1) begin
			for (j=0 j<K_MAX; j=j+1) begin
				assign mask_product[i][j] = packets[i][j] & mask[i][j];
			end
		end
		
	endgenerate

endmodule


