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
//  - bitmatrix_control_i
//  - engine_fsm_i
//  - control_reg_top_i
//  - inbuff_cntl_i


//Notes:

//TODO list:

//======================================================================================================
////######################################### MODULE ####################################################

module control_top #(

//=================================
//  user parameters 
//=================================
	parameter K_MAX = 128,
	parameter K_MIN = 2,
	parameter M_MAX = 128,
	parameter M_MIN = 2,
	parameter W = 4,
	parameter PACKET_LENGTH =  2,

	// inbuffer parameters:
	INBUF_MEM_DATA_W = 32,	// TODO: put correct value
	INBUF_MEM_ADDR_W = 32, 	// TODO: put correct value
	
//=================================
//  local parameters (DON'T CHANGE)
//=================================

    parameter MREG_W    = $clog2(M_MAX),


	//bitmatrix memory parameters:

	parameter BM_MEM_DEPTH = M_MAX,
	parameter BM_COL_W = W*W*K_MAX,
	parameter BM_MEM_W = BM_COL_W,
	parameter BM_MEM_ADDR_W = $clog2(BM_MEM_DEPTH)
	

)(
	//===========
	//  inputs:
	//===========
	input clk,
	input rstn,
	input engine_en,
	
	//input from engine
	input eng_empty,
	input eng_cntl_data_used,
	// input from input buffer:
	//input from registers:

	input EcaEnReg,
	input [MREG_W-1:0] MReg,

	//===========
	//  outputs:
	//===========
	output eng_rstn_o,
	//output to output buffer
	output cntrl_outbuff_wr_en,
	//output to engine
	output cntrl_eng_calc_en,
	output [W-1:0] bm_col_data_out [0:K_MAX-1] [0:W-1],
	output bm_coloum_data_out_val,
	
	//output to registers
	output global_reg_wr_en,
	
	//================
	//  memories IFs:
	//================
	
	
	//  bitmatrix mem I/F:
	input  [BM_COL_W-1:0]	bm_mem_bm_cntl_rd_data,
	input  bm_mem_bm_cntl_rd_data_val,

	output bm_cntl_bm_mem_rd_rq,
	output [BM_MEM_ADDR_W-1:0] bm_cntl_bm_mem_rd_addr,
	
	// input buffer fifo rd IF
	output cntl_inbuf_fifo_rd_rq,
	output cntl_inbuf_fifo_mem_en,
	input  inbuf_fifo_cntl_empty
);

//======================
//  signals declaration:
//======================
logic eng_rstn;
logic eng_fsm_bm_cntl_rd_en;


// inbuf memory IF signals:
logic inbuf_mem_rd_data_val;
logic inbuf_mem_rd_req;
logic inbuf_mem_wr_req;
logic [INBUF_MEM_DATA_W-1:0]  inbuf_mem_rd_data; 
logic [INBUF_MEM_DATA_W-1:0]  inbuf_mem_wr_data; 
logic [INBUF_MEM_ADDR_W-1:0]  inbuf_mem_rd_addr;
logic [INBUF_MEM_ADDR_W-1:0]  inbuf_mem_wr_addr;


//==============================
//  submodules instantiations:
//==============================
assign eng_rstn_o = eng_rstn;


//-------------------------------------
// bitmatrix control:
//--------------------------------------


bm_cntl #(
.K_MAX(K_MAX)
,.K_MIN(K_MIN)
,.M_MAX(M_MAX)
,.M_MIN(M_MIN)
,.W(W)
,.PACKET_LENGTH(PACKET_LENGTH)
) bitmatrix_control_i(

//  inputs:
.clk(clk)
,.rstn(rstn)
,.eng_rstn(eng_rstn)
//input from controller
,.eng_fsm_bm_cntl_rd_en(eng_fsm_bm_cntl_rd_en)
//input from engine
,.eng_bm_cntl_data_used(eng_cntl_data_used)
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

//------------------------
// engine fsm
//------------------------

engine_fsm #(
.K_MAX(K_MAX)
,.K_MIN(K_MIN)
,.M_MAX(M_MAX)
,.M_MIN(M_MIN)
,.W(W)
,.PACKET_LENGTH(PACKET_LENGTH)

) engine_fsm_i(
//  inputs:
.clk(clk)
,.rstn(rstn)
//user input 
,.start_eng(engine_en)
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

);

//----------------------------
//	input buffer control: 
//----------------------------


inbuff_cntl #(
.K_MAX(K_MAX)
,.K_MIN(K_MIN)
,.M_MAX(M_MAX)
,.M_MIN(M_MIN)
,.W(W)
,.PACKET_LENGTH(PACKET_LENGTH)

)inbuff_cntl_i (
	.clk(clk)
	,.rstn(rstn)
	,.eng_rstn(eng_rstn)

	//input from controller
	,.cntrl_inbuff_rd_en(cntrl_inbuff_rd_en)
	//input from engine
	,.eng_inbuf_cntl_data_used(eng_cntl_data_used)
	//input from control regs:
	,.MReg(MReg)

//====================
//  sram FIFO I/F:
//====================

	,.cntl_inbuf_fifo_rd_rq(cntl_inbuf_fifo_rd_rq)
	,.cntl_inbuf_fifo_mem_en(cntl_inbuf_fifo_mem_en)
	,.inbuf_fifo_cntl_empty(inbuf_fifo_cntl_empty)

);

	
endmodule
