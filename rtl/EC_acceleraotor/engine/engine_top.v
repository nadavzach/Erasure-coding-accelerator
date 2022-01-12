//=====================================================================================================
//
// Module: engine top
//
// Description
// ===========
//  this module containes the algo pipeline that preforms the data encoding.
// there are 2 stages - bitmatrix mult + AND masking and k bitmatrix outputs addition (with xor)
// 
//
//  
//======================================================================================================

// Sub Modules:
//  - sub-module1
//  - sub-module2


//Notes:
// - bmu = bitmatrix multplication unit
//TODO list:

//======================================================================================================
////######################################### MODULE ####################################################

module engine_top #(

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

//input from inbuff

	input [PACKET_LENGTH-1:0] inbuf_eng_din_reg [0:W-1] [0:BM_MULT_UNIT_NUM-1],
	input inbuf_eng_din_reg_val,

//input from control 
	input [W-1:0] cntl_eng_bm_col_din_reg [0:W-1] [0:K_MAX-1],
	input cntl_eng_bm_col_din_reg_val,
	input cntrl_eng_calc_en,
	input global_reg_wr_en,

// inputs from outbuff

	input outbuf_eng_wr_ack,


//===========
//  outputs:
//===========

// to control
	output data_used, //TODO - this signal indicates that the ata from bm and engine was used in a calc. the control use this to know when to count. find better name?
	output eng_empty,// indicates there is no valid calculated data in the engine that hav'nt been written to 

// to outbuf mem

	output [PACKET_LENGTH-1:0] eng_outbuf_dout_reg [0:W-1] [0:PCK_TREE_XOR_UNITS_NUM-1],
	output eng_outbuf_wr_req,
	output [OUTBUF_MEM_ADDR_W-1:0] eng_outbuf_wr_addr
);

//======================
//  signals declaration:
//======================

// pipeline regs and cntl:

//logic [PACKET_LENGTH-1:0] eng_pl_stage_0_din_reg [0:W-1] [0:K_MAX-1];
//logic [W-1:0] eng_pl_stage_0_bd_col_reg  [0:W-1] [0:K_MAX-1];
logic [PACKET_LENGTH-1:0] eng_pl_reg_1 [0:W-1] [0:BM_MULT_UNIT_NUM-1];
logic [PACKET_LENGTH-1:0] eng_pl_reg_2 [0:W-1] [0:PCK_TREE_XOR_UNITS_NUM-1];

logic eng_pl_reg_val_0;
logic eng_pl_reg_val_1;
logic eng_pl_reg_val_2;


//stage 1 bm mult:

logic [W-1:0] bmu_bm_mux_arr_o [W-1:0] [0:BM_MULT_UNIT_NUM-1];
logic [W-1:0] bmu_bm_mux_sel_reg_arr [0:BM_MULT_UNIT_NUM-1];

//==================================
// pipe line logic : 
//==================================

//stage_0 comb

assign eng_pl_reg_val_0 = inbuf_eng_din_reg_val & cntl_eng_bm_col_din_reg_val & cntrl_eng_calc_en;



//stage_1

always_ff @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		eng_pl_reg_val_1	<=	1'b0;
	end else begin
		if(~eng_rstn) begin
			eng_pl_reg_val_1	<=	1'b0;
		end else begin
			if(cntrl_eng_calc_en) begin
				eng_pl_reg_val_1	<=	eng_pl_reg_val_0;
			end
		end
	end



//stage_2 

always_ff @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		eng_pl_reg_val_2	<=	1'b0;
	end else begin
		if(~eng_rstn) begin
			eng_pl_reg_val_2	<=	1'b0;
		end else begin
			if(cntrl_eng_calc_en) begin
				eng_pl_reg_val_2	<=	eng_pl_reg_val_1;
			end
		end
	end



//==============================
//  submodules instantinations:
//==============================

//bm_mult_unit

genvar bmu_inst_idx;
generate
	for(bmu_inst_idx = 0;bmu_inst_idx < BM_MULT_UNIT_NUM;bmu_inst_idx = bmu_inst_idx + 1) begin
		 bm_mult_unit bm_mult_unit_i(
			//  inputs:
		    .bitmatrix_cols	( bmu_bm_mux_arr_o[bmu_inst_idx]	) 
			,.data_packet	( inbuf_eng_din_reg[bmu_inst_idx]			)
			
			//  outputs:
		    ,.mult_product(bm_mult_d_out_arr[bmu_inst_idx])
			);



	end//for - bm_mult_idx


endmodule





