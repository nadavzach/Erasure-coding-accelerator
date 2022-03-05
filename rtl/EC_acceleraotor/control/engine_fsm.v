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

module engine_fsm  #(

	//=================================
	//  user parameters 
	//=================================
	parameter K_MAX = 128,
	parameter K_MIN = 2,
	parameter M_MAX = 128,
	parameter M_MIN = 2,
	parameter W = 4,
	parameter PACKET_LENGTH =  2,


	//bitmatrix memory parameters:

	parameter BM_MEM_DEPTH = M_MAX,
	parameter BM_COL_W = W*W*K_MAX,
	parameter BM_MEM_W = BM_COL_W,
	parameter BM_MEM_ADDR_W = $clog2(BM_MEM_W),
	//
	//=================================
	//  local parameters (DON'T CHANGE)
	//=================================
	
	//states:
	localparam INIT_ST			= 2'd0,
	localparam CALC_ST			= 2'd1,
	localparam FINISH_CALC_ST	= 2'd2,
	localparam STATES_NUM		= 3

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
	
	//global outputs:
	output reg eng_rstn,
	
	//output to input buffer
	output reg cntrl_inbuff_rd_en,
	
	//output to output buffer
	output reg cntrl_outbuff_wr_en,
	
	//output to bitmatrix memory
	output reg cntrl_bm_mem_rd_en,
	
	//output to engine
	output reg cntrl_eng_calc_en,
	
	//output to registers
	output reg global_reg_wr_en


);

//======================
//  signals declaration:
//======================
logic [$clog2(STATES_NUM)-1:0] cur_st;
logic [$clog2(STATES_NUM)-1:0] nxt_st;


// cur state sync block
always_ff @(posedge clk or negedge rstn) begin
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
	
	case(cur_st)

	INIT_ST: begin
		if(start_eng) begin
			nxt_st	=	CALC_ST;
		end else begin //loop
			nxt_st	=	INIT_ST;
		end

	end

	CALC_ST: begin
		if(~start_eng) begin
			nxt_st	=	FINISH_CALC_ST;
		end else begin//loop
			nxt_st	=	CALC_ST;
		end
			
	end

	FINISH_CALC_ST: begin
		if(start_eng) begin
			nxt_st	=	CALC_ST;
		end else begin
			if(eng_empty) begin
				nxt_st	=	INIT_ST;
			end else begin//loop
					nxt_st = FINISH_CALC_ST;
			end
		end
		
	end
	
	endcase

end

//output comb block
always_comb begin

	//default:
	cntrl_inbuff_rd_en		=	1'b0;
	cntrl_outbuff_wr_en		=	1'b0;
	cntrl_bm_mem_rd_en		=	1'b0;
	global_reg_wr_en		=	1'b0;
	eng_rstn				=	1'b1;
//
	
	case(cur_st)

	INIT_ST:	
	begin
		global_reg_wr_en		=	1'b1;
		eng_rstn				=	1'b0;
	end

	CALC_ST:	
	begin
		cntrl_inbuff_rd_en		=	1'b1;
		cntrl_outbuff_wr_en		=	1'b1;
		cntrl_bm_mem_rd_en		=	1'b1;
	end

	FINISH_CALC_ST:	
	begin
		cntrl_outbuff_wr_en		=	1'b1;
		cntrl_bm_mem_rd_en		=	1'b1;
	end
	
	endcase

end


endmodule
