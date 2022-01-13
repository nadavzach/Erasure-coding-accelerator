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
//  - bm_mult_units X BM_MULT_UNIT_NUM 
//  - (and_mask + packet tree xor) X PCK_TREE_XOR_UNITS_NUM


//Notes:
// - bmu = bitmatrix multplication unit
// - tx  = tree xor
//TODO list:

// - implement ack from outbuff logic

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
	input outbuf_eng_full,


//===========
//  outputs:
//===========

// to control
	output data_used, 	
	output eng_pl_empty,// indicates there is no valid calculated data in the engine that hav'nt been written to 

// to outbuf mem

	output [PACKET_LENGTH-1:0] eng_outbuf_dout_reg [0:W-1] [0:PCK_TREE_XOR_UNITS_NUM-1],
	output eng_outbuf_wr_req
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
logic [BMU_BM_MUX_SEL_W-1:0] bmu_bm_mux_sel_reg_arr [0:BM_MULT_UNIT_NUM-1];


//stage 2 AND mask + xor

logic [PACKET_LENGTH-1:0] and_mask_d_in_arr		[0:W-1] [0:K_MAX-1] [0:PCK_TREE_XOR_UNITS_NUM-1];
logic [PACKET_LENGTH-1:0] and_mask_mask_reg_arr [0:W-1] [0:K_MAX-1] [0:PCK_TREE_XOR_UNITS_NUM-1];
logic [PACKET_LENGTH-1:0] and_mask_d_out_arr	[0:W-1] [0:K_MAX-1] [0:PCK_TREE_XOR_UNITS_NUM-1];
logic [PACKET_LENGTH-1:0] tree_xor_d_out_arr	[0:W-1] [0:PCK_TREE_XOR_UNITS_NUM-1];

//==================================
// general control : 
//==================================

//outbuf
assign eng_outbuf_dout_reg	= eng_pl_reg_2;
assign eng_outbuf_wr_req	= eng_pl_reg_val_2 & cntrl_eng_calc_en & ~outbuf_eng_full;

//cntl
assign data_used = cntrl_eng_calc_en & eng_pl_reg_val_0;
assign eng_pl_empty = ~(eng_pl_reg_val_0 | eng_pl_reg_val_1 | eng_pl_reg_val_2)

//==================================
// pipe line logic : 
//==================================

//stage_0 comb

assign eng_pl_reg_val_0 = inbuf_eng_din_reg_val & cntl_eng_bm_col_din_reg_val & cntrl_eng_calc_en;



//stage_1

// valid logic - 
always_ff @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		eng_pl_reg_val_1			<=	1'b0;
	end else begin
		if(~eng_rstn) begin
			eng_pl_reg_val_1		<=	1'b0;
		end else begin
			if(cntrl_eng_calc_en) begin
				eng_pl_reg_val_1	<=	eng_pl_reg_val_0;
			end
		end
	end

//data logic
generate
	for(genvar stg_1_data_bmu_idx = 0; stg_1_data_bmu_idx < BM_MULT_UNIT_NUM; stg_1_data_bmu_idx = stg_1_data_bmu_idx + 1) begin
		for(genvar stg_1_data_word_bit_idx = 0; stg_1_data_word_bit_idx < W; stg_1_data_word_bit_idx = stg_1_data_word_bit_idx + 1) begin
			always_ff @(posedge clk or negedge rstn) begin
				if(~rstn) begin
					eng_pl_reg_1[stg_1_data_word_bit_idx][stg_1_data_bmu_idx]			<=	{W{1'b0}};
				end else begin
					if(~eng_rstn) begin
						eng_pl_reg_1[stg_1_data_word_bit_idx][stg_1_data_bmu_idx]		<=	{W{1'b0}};
					end else begin
						if(cntrl_eng_calc_en & eng_pl_reg_val_0) begin
							eng_pl_reg_1[stg_1_data_word_bit_idx][stg_1_data_bmu_idx]	<=	bmu_bm_mux_arr_o[stg_1_data_word_bit_idx][stg_1_data_bmu_idx];
						end
					end
				end
			end
endgenerate


//stage_2 

//valid logic

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

//data logic
generate
	for(genvar stg_2_tx_unit_idx = 0; stg_2_tx_unit_idx < BM_MULT_UNIT_NUM; stg_2_tx_unit_idx = stg_2_tx_unit_idx + 1) begin
		for(genvar stg_2_data_word_bit_idx = 0; stg_2_data_word_bit_idx < BM_MULT_UNIT_NUM; stg_2_data_word_bit_idx = stg_2_data_word_bit_idx + 1) begin
			always_ff @(posedge clk or negedge rstn) begin
				if(~rstn) begin
					eng_pl_reg_2[stg_2_data_word_bit_idx][stg_2_tx_unit_idx]			<=	{W{1'b0}};
				end else begin
					if(~eng_rstn) begin
						eng_pl_reg_2[stg_2_data_word_bit_idx][stg_2_tx_unit_idx]		<=	{W{1'b0}};
					end else begin
						if(cntrl_eng_calc_en & eng_pl_reg_val_1) begin
							eng_pl_reg_2[stg_2_data_word_bit_idx][stg_2_tx_unit_idx]	<=	tree_xor_d_out_arr[stg_2_data_word_bit_idx][stg_2_tx_unit_idx];
						end
					end
				end
			end
endgenerate


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
			,.data_packet	( inbuf_eng_din_reg[bmu_inst_idx]	)
			
			//  outputs:
		    ,.mult_product	( bm_mult_d_out_arr[bmu_inst_idx]	)
		);

		bmu_bm_mux_arr_o[bmu_inst_idx] = cntl_eng_bm_col_din_reg[bmu_bm_mux_sel_reg_arr[bmu_inst_idx]];// TODO - ask bnya if this bus mux is ok or need more implicit coding

	end//for - bm_mult_idx
endgenerate

// mask + tree xor

genvar tree_xor_inst_idx;
generate
	for(tree_xor_inst_idx = 0;tree_xor_inst_idx < PCK_TREE_XOR_UNITS_NUM;tree_xor_inst_idx = tree_xor_inst_idx + 1) begin

		mask_unit mask_unit_i(
			//  inputs:
			.packets		( and_mask_d_in_arr[tree_xor_inst_idx]		) 
			,.mask			( and_mask_mask_reg_arr[tree_xor_inst_idx]	)
			
			//  outputs:
		    ,.mask_product	(and_mask_d_out_arr[tree_xor_inst_idx]		)
		);


		dyn_xor_unit dyn_xor_unit_i(
			//  inputs:
			.packets		( and_mask_d_out_arr[tree_xor_inst_idx]		) 
			
			//  outputs:
		    ,.xor_product	( tree_xor_d_out_arr[tree_xor_inst_idx]		)
		);


	end//for  
endgenerate

// assigning stage 1 output to the different mask + xor units:
genvar  mask_unit_idx,k_idx,w_idx;
generate
	for( mask_unit_idx = 0; mask_unit_idx < PCK_TREE_XOR_UNITS_NUM; mask_unit_idx = mask_unit_idx + 1) begin
		for( k_idx = 0; k_idx < K_MAX; k_idx = k_idx + 1) begin
			if(K_MIN*mask_unit_idx + k_idx < BM_MULT_UNIT_NUM) begin
				and_mask_d_in_arr[k_idx][mask_unit_idx] = eng_pl_reg_1[K_MIN*mask_unit_idx + k_idx];
			end else begin
				for ( w_idx = 0;w_idx < W; w_idx = w_idx + 1 ) begin
					and_mask_d_in_arr[w_idx][k_idx][mask_unit_idx] = {W{1'b0}};
				end
			end
		end
	end
endgenerate





endmodule




