//=====================================================================================================
//
// Module:  mask_unit
//
// Description
// ===========
// 
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

	input [PACKET_LENGTH-1:0] packets	[0:W-1][0:MASK_W-1],
	input [MASK_W-1:0] mask, 	
	//input [PACKET_LENGTH-1:0] mask		[0:W-1][0:MASK_W-1], 	

//===========
//  outputs:
//===========

	output [PACKET_LENGTH-1:0] mask_product [0:W-1][0:MASK_W-1]

);

//======================
//  logic:
//======================
	
logic [PACKET_LENGTH-1:0] mask_ext	[0:W-1][0:MASK_W-1]; 	
	genvar i,j;
	generate
	
		for (i=0; i<W; i=i+1) begin
			for (j=0; j<MASK_W; j=j+1) begin
                assign mask_ext[i][j] = (mask[j] ? {PACKET_LENGTH{1'b1}} : {PACKET_LENGTH{1'b0}}); 
				assign mask_product[i][j] = packets[i][j] & mask_ext[i][j];
			end
		end
		
	endgenerate

endmodule
