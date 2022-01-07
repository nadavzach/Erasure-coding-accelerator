//=====================================================================================================
//
// Module: control fsm
//
// Description
// ===========
// 
// controls reading and writing from both memories and the bitmatrix memories reading during the calculation steps
// 
//
//  
//======================================================================================================

// Sub Modules:


//Notes:

//TODO list:

//======================================================================================================
////######################################### MODULE ####################################################

module module_name #(

//=================================
//  user parameters 
//=================================
	`include "global_parameters.v"
//
//=================================
//  local parameters (DON'T CHANGE)
//=================================

//states:
localparam INIT_ST			= 2'd0,
localparam CALC_ST			= 2'd1,
localparam FINISH_CALC_ST	= 2'd2


)(
//===========
//  inputs:
//===========

input clk,
input rstn,


//user input - TODO - choose if it's a register or input to accelerator
input start_eng,

//input from control regs
input MReg,

//input from engine
input eng_empty,

//===========
//  outputs:
//===========


//output to input buffer
output cntrl_inbuff_rd_en,

//output to output buffer
output cntrl_outbuff_wr_en,

//output to bitmatrix memory
output [M_MAX-1:0] bitmatrix_nxt_col,
output cntrl_bm_mem_rd_en,

//output to engine
output cntrl_eng_calc_eng,

//output to registers
output global_reg_wr_en


);

//======================
//  signals declaration:
//======================
logic [STATES_NUM-1:0] cur_st;
logic [STATES_NUM-1:0] nxt_st;


// cur state sync block
always_ff( posedge clk or negedge rstn) begin
	if(~rstn) begin
		cur_st	<=	INIT_ST;
	end else begin
		cur_st	<=	nxt_st;
	end
end

// state comb block
always_comb begin

	//default:
	nxt_st	=	INIT_ST;
	
	case(cur_st):

	INIT_ST begin
		if(start_eng) begin
			nxt_st	=	CALC_ST;
		end else begin //loop
			nxt_st	=	INIT_ST;
		end

	end

	CALC_ST	begin
		if(~start_eng) begin
			nxt_st	=	FINISH_CALC_ST;
		end else begin//loop
			nxt_st	=	CALC_ST;
			
	
	end

	FINISH_CALC_ST begin
		if(start_eng)
			nxt_st	=	CALC_ST;
		end else begin
			if(eng_empty) begin
				nxt_st	=	INIT_ST;
			end else begin//loop
					nxt_st = FINISH_CALC_ST;
				end
		end

	end


end

//output comb block
always_comb begin

	//default:
	cntrl_inbuff_rd_en		=	1'b0;
	cntrl_outbuff_wr_en		=	1'b0;
	cntrl_bm_mem_rd_en		=	1'b0;
	global_reg_wr_en		=	1'b0;
//
	
	case(cur_st):

	INIT_ST begin
		global_reg_wr_en		=	1'b1;
	end

	end

	CALC_ST	begin
		cntrl_inbuff_rd_en		=	1'b1;
		cntrl_outbuff_wr_en		=	1'b1;
		cntrl_bm_mem_rd_en		=	1'b1;

	
	end

	FINISH_CALC_ST begin
		cntrl_outbuff_wr_en		=	1'b1;
		cntrl_bm_mem_rd_en		=	1'b1;
	end


end



endmodule





