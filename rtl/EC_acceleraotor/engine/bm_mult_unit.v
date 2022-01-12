//=====================================================================================================
//
// Module:  and_xor_unit
//
// Description
// ===========
// 
// takes w bits of data and w x w bits of bitmatrix.
// output is the mult product
//
//  
//======================================================================================================

// Sub Modules:


//Notes:

//TODO list:

//======================================================================================================
////######################################### MODULE ####################################################

module bm_mult_unit #(

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

	input [W-1:0] bitmatrix_cols [0:W-1], 
	input [PACKET_LENGTH-1:0] data_packet [0:W-1],


//===========
//  outputs:
//===========
	output [PACKET_LENGTH-1:0] mult_product [0:W-1]

);
//======================
//  signal decl:
//======================

	logic [PACKET_LENGTH-1:0] and_product [0:W-1] [0:W-1];

//======================
//  logic:
//======================

	genvar i,j,k;
	generate

	// and between data word and each coloum:

		for (j=0; j<  W; j=j+1) begin
			for (i=0; i < W; i=i+1) begin
				assign and_product[j][i] = (data_packet[i] & {PACKET_LENGTH{bitmatrix_cols[j]}});
			end
		end
	// tree xor between packets:

		for(k=0; k < W; k=k+1) begin
		
			tree_xor #(
			.INPUT_NUM(W)
			) tree_xor_i (
			//input
			.packets_arr(and_product[k]),
			//output
			.xor_product(mult_product[k])
			);


		end
	endgenerate

endmodule





