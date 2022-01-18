//=====================================================================================================
//
// Module: sram_fifo
//
// Description
// ===========
// fifo with sram as memory.
//
// 
// 
//
//  
//======================================================================================================

// Sub Modules:
//  - sram_wrapper_i


//Notes:

//TODO list:
// - set guide line to read and write together + pushback
// - TODO everything - currently just a IF
//======================================================================================================
////######################################### MODULE ####################################################

module sram_fifo #(

//=================================
//  user parameters 
//=================================
	parameter SRAM_WRAP_WIDTH = 32,//defines the 2 ports combined width, have to be a complete multp of 2
	parameter SRAM_WRAP_DEPTH = 100 //num of sramwidth rows



//=================================
//  local parameters (DON'T CHANGE)
//=================================



)(
//===========
//  inputs:
//===========

input clk,
input rst_n,

input wr_req,
input rd_req,

input mem_en,
input [SRAM_WRAP_WIDTH-1:0] wr_data_in,



//===========
//  outputs:
//===========

output rd_data_val,
output [SRAM_WRAP_WIDTH-1:0] rd_data,
output wr_ack,

//status:

output full,
output empty

);

//======================
//  signals declaration:
//======================


//==============================
//  submodules instantinations:
//==============================




endmodule





