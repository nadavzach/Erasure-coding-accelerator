//=====================================================================================================
//
// Module: eca (erasure coding accelerator) top module
//
// Description
// ===========
// this module is the top module of the eca
// 
// 
//
//  
//======================================================================================================

// Sub Modules:
//  - control_top_i
//  - engine_top_i
//	- inbuf_top_i
//	- outbuf_top_i
//	- bitmatrix_mem_i
//	- regs_top_i



//Notes:

//TODO list:

//======================================================================================================
////######################################### MODULE ####################################################

module eca_top #(

//=================================
//  user parameters 
//=================================


//=================================
//  local parameters (DON'T CHANGE)
//=================================



)(

//registers IF:

input regs_wr_req;
input regs_rd_req;
input  [COMMON_REG_W-1:0] regs_wr_data;
output [COMMON_REG_W-1:0] regs_rd_data;
output regs_rd_data_val;

//input buffer IF:
input inbuf_wr_req;
input [inbuf_wr_addr;

);

//======================
//  signals declaration:
//======================


//==============================
//  submodules instantinations:
//==============================




endmodule





