//=====================================================================================================
//
// Module:  generic mux
//
// Description
// ===========
// parametrized mux
// 
// 
//
//  
//======================================================================================================

// Sub Modules:
//  - sub-module1
//  - sub-module2


//Notes:

//TODO list:

//======================================================================================================
////######################################### MODULE ####################################################

module module_name #(

//=================================
//  user parameters 
//=================================

	parameter DATA_WIDTH = 1,
	parameter INPUTS_NUM = 3,

//=================================
//  local parameters (DON'T CHANGE)
//=================================
	localparam SELECT_WIDTH	=	$clog2(INPUTS_NUM)


)(
//===========
//  inputs:
//===========
	input [DATA_WIDTH-1:0]	inputs_arr	[0:INPUTS_NUM-1],
	input [SELECT_WIDTH-1:0] sel,

//===========
//  outputs:
//===========
	output [DATA_WIDTH-1:0]	data_out

);

assign data_out = inputs_arr[sel];

endmodule





