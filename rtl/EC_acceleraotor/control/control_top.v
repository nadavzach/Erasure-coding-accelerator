//=====================================================================================================
//
// Module: top_control 
//
// Description
// ===========
// 
// 
// 
//
//  
//======================================================================================================

// Sub Modules:
//  - bm_cntl_i
//  - engine_fsm_i
//  - control_reg_top_i


//Notes:

//TODO list:

//======================================================================================================
////######################################### MODULE ####################################################

module control_top #(

//=================================
//  user parameters 
//=================================
`include "global_parameters.sv"

//=================================
//  local parameters (DON'T CHANGE)
//=================================



)(
	//===========
	//  inputs:
	//===========
	input clk,
	input rstn,
	
	//input from engine
	input eng_empty,
	input eng_top_bm_cntl_new_col_req,
	
	
	//===========
	//  outputs:
	//===========
	output eng_rstn_o,
	//output to output buffer
	output cntrl_inbuff_rd_en,
	//output to output buffer
	output cntrl_outbuff_wr_en,
	//output to engine
	output cntrl_eng_calc_en,
	output [W-1:0] bm_col_data_out [0:W-1] [0:K_MAX-1],
	output bm_coloum_data_out_val,
	
	//output to registers
	output global_reg_wr_en
	
	//================
	//  memories IFs:
	//================
	
	
	//  bitmatrix mem I/F:
	input  [BM_COL_W-1:0]	bm_mem_bm_cntl_rd_data,
	input  bm_mem_bm_cntl_rd_data_val,

	output bm_cntl_bm_mem_rd_rq,
	output [BM_MEM_ADDR_W-1:0] bm_cntl_bm_mem_rd_addr



);

//======================
//  signals declaration:
//======================
logic eng_rstn;
logic eng_fsm_bm_cntl_rd_en;
//==============================
//  submodules instantiations:
//==============================
assign eng_rstn_o = eng_rstn;

// bitmatrix control instantination:
bm_cntl bitmatrix_control_i(

//  inputs:
.clk(clk)
,.rstn(rstn)
,.eng_rstn(eng_rstn)
//input from controller
,.eng_fsm_bm_cntl_rd_en(eng_fsm_bm_cntl_rd_en)
//input from engine
,.eng_bm_cntl_new_col_req(eng_top_bm_cntl_new_col_req)
//input from control regs:
,.MReg(MReg)

//  outputs:
,.bm_col_data_out(bm_col_data_out)
,.bm_coloum_data_out_val(bm_coloum_data_out_val)

//  bitmatrix mem I/F:
,.bm_mem_bm_cntl_rd_data(bm_mem_bm_cntl_rd_data)
,.bm_mem_bm_cntl_rd_data_val(bm_mem_bm_cntl_rd_data_val)
,.bm_cntl_bm_mem_rd_rq(bm_cntl_bm_mem_rd_rq)
,.bm_cntl_bm_mem_rd_addr(bm_cntl_bm_mem_rd_addr)

);



engine_fsm engine_fsm_i(
//  inputs:
,.clk(clk)
,.rstn(rstn)
//user input - TODO - choose if it's a register or input to accelerator
,.start_eng(start_eng)
//input from control regs
,.MReg(MReg)
//input from engine
,.eng_empty(eng_empty)

//  outputs:
	
//global outputs:
,.eng_rstn(eng_rstn)
//output to input buffer
,.cntrl_inbuff_rd_en(cntrl_inbuff_rd_en)
//output to output buffer
,.cntrl_outbuff_wr_en(cntrl_outbuff_wr_en)
//output to bitmatrix memory
,.cntrl_bm_mem_rd_en(eng_fsm_bm_cntl_rd_en)
//output to engine
,.cntrl_eng_calc_en(cntrl_eng_calc_en)
//output to registers
,.global_reg_wr_en(global_reg_wr_en)

)

endmodule




