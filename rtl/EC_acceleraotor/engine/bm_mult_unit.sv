/*------------------------------------------------------------------------------
 * File          : bm_mult_unit.sv
 * Project       : RTL
 * Author        : epodnz
 * Creation date : Jan 13, 2022
 * Description   :
 *------------------------------------------------------------------------------*/

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
 
	parameter K_MAX = 128,
	parameter K_MIN = 2,
	parameter M_MAX = 128,
	parameter M_MIN = 2,
	parameter K = 2,
	parameter W = 4,
	parameter PACKET_LENGTH =  2


    
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
				assign and_product[j][i] = (data_packet[i] & {PACKET_LENGTH{bitmatrix_cols[j][i]}});
			end
		end
	// tree xor between packets:

		for(k=0; k < W; k=k+1) begin
		
			tree_xor #(
			.INPUT_NUM(W)
            ,.PACKET_LENGTH(PACKET_LENGTH)
			) tree_xor_i (
			//input
			.packets_arr(and_product[k]),
			//output
			.xor_product(mult_product[k])
			);


		end
	endgenerate

endmodule
