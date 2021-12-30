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

module and_xor_unit #(

//=================================
//  user parameters 
//=================================
	paramater W = 3
//=================================
//  local parameters (DON'T CHANGE)
//=================================



)(
//===========
//  inputs:
//===========

	input [W-1:0] bitmatrix_cols [0:W-1], 
	input [W-1:0] data_word,


//===========
//  outputs:
//===========
	output [W-1:0] mult_product;

);

//======================
//  logic:
//======================

	genvar i;
	generate
	
		for (i=0 i<W; i=i+1) begin
			assign mult_product[i] = ^(data_word & bitmatrix_cols[i]);
		end
		
	endgenerate

endmodule





