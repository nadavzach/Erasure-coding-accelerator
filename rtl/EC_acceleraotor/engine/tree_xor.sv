/*------------------------------------------------------------------------------
 * File          : tree_xor.sv
 * Project       : RTL
 * Author        : epodnz
 * Creation date : Jan 13, 2022
 * Description   :
 *------------------------------------------------------------------------------*/

//=====================================================================================================
//
// Module:  tree_xor
//
// Description
// ===========
// 
//
// output is the product of all  packets
//
//  
//======================================================================================================

// Sub Modules:


//Notes:

//TODO list:

//======================================================================================================
////######################################### MODULE ####################################################

module tree_xor #(

//=================================
//  user parameters 
//=================================
	//`include "../global_parameters.sv"
parameter K_MAX = 128,
parameter K_MIN = 2,
parameter M_MAX = 128,
parameter M_MIN = 2,
parameter W = 4,
parameter PACKET_LENGTH =  2, 


parameter INPUT_NUM = 12
//=================================
//  local parameters (DON'T CHANGE)
//=================================
)(
//===========
//  inputs:
//===========

	input [PACKET_LENGTH-1:0] packets_arr [0:INPUT_NUM-1],


//===========
//  outputs:
//===========
	output [PACKET_LENGTH-1:0] xor_product 

);
//======================
//  signal decl:
//======================

logic [PACKET_LENGTH-1:0] mid_res [0:2*INPUT_NUM-2];

//======================
//  logic:
//======================

	genvar i,j;
	generate
		for (i=0; i < INPUT_NUM; i=i+1) begin
			assign mid_res[i] = packets_arr[i];
		end

		for (j=0; j < INPUT_NUM-1; j=j+1) begin
			assign mid_res[INPUT_NUM + j] = mid_res[2 * j] ^ mid_res[2 * j + 1];
		end
	endgenerate
assign xor_product = mid_res[2*INPUT_NUM-2];
endmodule
