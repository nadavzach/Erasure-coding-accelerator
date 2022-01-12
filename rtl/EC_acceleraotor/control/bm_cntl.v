//=====================================================================================================
//
// Module:  bitmatrix memory controller
//
// Description
// ===========
// this module interacts with:
//		-the bitmatrix memory IF in order to read the bitmatrix coloum data
//		-the engine control signals in order to count the required m cycles and match them with the appropriate bm coloum
// 
//
//  
//======================================================================================================

// Sub Modules:


//Notes:

//TODO list:
//  - hard code bm_mem_col_addr_arr addresses
//	- add logic for memory IF
//  - add indication to eng and eng FSM that there are still columns to calc for this line of data 
//======================================================================================================
////######################################### MODULE ####################################################

`include "global_parameters.sv"
module bm_cntl #(

//=================================
//  user parameters 
//=================================
//
//=================================
//  local parameters (DON'T CHANGE)
//=================================


)(
//===========
//  inputs:
//===========
	input clk,
	input rstn,
	input eng_rstn,

	//input from controller
	input eng_fsm_bm_cntl_rd_en,

	//input from engine
	input eng_bm_cntl_new_col_req,
	//input from control regs:
	input MReg,

//===========
//  outputs:
//===========
	output [W-1:0] bm_col_data_out [0:W-1] [0:K_MAX-1],
	output bm_coloum_data_out_val,
//====================
//  bitmatrix mem I/F:
//====================

	input  [BM_COL_W-1:0]	bm_mem_bm_cntl_rd_data,
	input  bm_mem_bm_cntl_rd_data_val,

	output bm_cntl_bm_mem_rd_rq,
	output [BM_MEM_ADDR_W-1:0] bm_cntl_bm_mem_rd_addr

);

//======================
//  signals declaration:
//======================

// counter
logic bm_col_count_en;
logic [M_MAX-1:0] bm_col_counter;
logic [M_MAX-1:0] bm_col_counter_max_value;

//bm memory
logic [BM_COL_W-1:0] bm_coloum_data_out_reg;
logic [BM_MEM_ADDR_W-1:0] bm_mem_col_addr_arr [0:M_MAX-1];

//======================
//  coloumns counter:
//======================

//	description:
//	counter indicates what column shoud be read next from the bitmatrix memory

assign bm_col_count_en	= eng_fsm_bm_cntl_rd_en & bm_mem_bm_cntl_rd_data_val// - in CALC state and data is read from mem to data out reg

assign bm_col_counter_max_value = MReg-{{(M_MAX-1){1'b0}},1'b1}

always_ff @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		bm_col_counter	<=	{M_MAX{1'b0}};
	end else begin
		if(~eng_rstn) begin
			bm_col_counter	<=	{M_MAX{1'b0}};
		end else begin
			if(bm_col_count_en) begin
				if(bm_col_counter >= bm_col_counter_max_value) begin // wrap around when reaching M-1
					bm_col_counter	<=	{M_MAX{1'b0}};
				end else begin
					bm_col_counter	<=	bm_col_counter + ({(M_MAX-1){1'b0}},1'b1};
				end
			end
		end
	end
end

//always_ff @(posedge clk or negedge rstn) begin
//	if(~rstn) begin
//		bm_col_counter_count	<=	1'b0;
//	end else begin
//		if(~eng_rstn) begin
//			bm_col_counter_count	<=	1'b0;
//		end else begin
//			if(count_en)
//				bm_col_counter_count	<=	1'b1;
//			end else begin
//				bm_col_counter_count	<=	1'b0;
//			end
//		end
//	end
//

//============================
//  bitmatrix memory control:
//============================
assign bm_cntl_bm_mem_rd_rq = eng_fsm_bm_cntl_rd_en
					          &(
					          eng_bm_cntl_new_col_req//engine used the data in the output reg and he'll be calc in the next clk also
					          ||
					          ~bm_coloum_data_out_val//in calc mode but no data in output reg (no valid)
					          );

//output register + val sync block					   
always_ff @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		bm_coloum_data_out_reg	<=	{BM_COL_W{1'b0}};
		bm_coloum_data_out_val	<=	1'b0;
	end else begin
		if(~eng_rstn) begin
			bm_coloum_data_out_reg	<=	{BM_COL_W{1'b0}};
			bm_coloum_data_out_val	<=	1'b0;
		end else begin
			if(bm_mem_bm_cntl_rd_data_val) begin
				bm_coloum_data_out_reg	<=	bm_mem_bm_cntl_rd_data;
				bm_coloum_data_out_val	<=	1'b1;
			end
		end
	end
end

//assigning the memory data out register to the data output array
genvar i,j;
generate 
	for(i=0;i<K_MAX;i=i+1) begin
		for(j=0;j<W;j=j+1) begin
			bm_col_data_out[j][i] = bm_coloum_data_out_reg[i*j*W +: W];
		end
	end
endgenerate

//TODO - hard code bm_mem_col_addr_arr addresses
assign bm_cntl_bm_mem_rd_addr = bm_mem_col_addr_arr[bm_col_counter];

endmodule





