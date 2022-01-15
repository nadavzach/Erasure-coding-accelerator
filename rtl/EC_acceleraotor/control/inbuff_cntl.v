//=====================================================================================================
//
// Module:  input buffer controller
//
// Description
// ===========
// this module interacts with:
//		- the input buffer memory. the mem holds the incoming data to encode. it should read new line every M clk cycles
//		- the two buffer regs that holds the sampled data in a FIFO manner (with the mem it self) so they will cover the SRAM reading delay for M < 3
//
//  
//======================================================================================================

// Sub Modules:


//Notes:

//TODO list:

// make sure that the data read to the buffer regs will not be overwritten, so rst(eng or main) will not cause lost data.

//======================================================================================================
////######################################### MODULE ####################################################
module bm_cntl #(

//=================================
//  user parameters 
//=================================
//

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
	input eng_rstn,

	//input from controller
	input cntrl_inbuff_rd_en,
	//input from engine
	input eng_inbuf_cntl_data_used,//one of M uses for each data line
	//input from control regs:
	input MReg,

//===========
//  outputs:
//===========
	output [PACKET_LENGTH-1:0] inbuf_eng_dout_reg [0:W-1] [0:BM_MULT_UNIT_NUM-1],
	output inbuf_eng_dout_reg_val,

//====================
//   mem I/F:
//====================

	input  [INBUF_MEM_DATA_W-1:0]	inbuf_mem_rd_data,
	input  inbuf_mem_rd_data_val,

	output [INBUF_MEM_DATA_W-1:0]	inbuf_mem_wr_data,
	output inbuf_mem_rd_req,
	output inbuf_mem_wr_req,
	output [INBUF_MEM_ADDR_W-1:0]  inbuf_mem_rd_addr,
	output [INBUF_MEM_ADDR_W-1:0]  inbuf_mem_wr_addr

);

//======================
//  signals declaration:
//======================

// counter
logic compute_cyc_count_en;
logic [M_MAX-1:0] compute_cyc_counter;
logic [M_MAX-1:0] compute_cyc_counter_max_value;

//bm memory
logic [PACKET_LENGTH-1:0] inbuf_mem_dout_reg_0 [0:W-1] [0:BM_MULT_UNIT_NUM-1];
logic [PACKET_LENGTH-1:0] inbuf_mem_dout_reg_1 [0:W-1] [0:BM_MULT_UNIT_NUM-1];
logic inbuf_mem_dout_reg_val_0;
logic inbuf_mem_dout_reg_val_1;

//======================
//  compute cycle counter:
//======================

//	description:
// countes the M compute cycles for each data line, to indicate when there's a need for a new data line/ the engine can be emptied
assign compute_cyc_count_en	=  eng_inbuf_cntl_data_used;

assign compute_cyc_counter_max_value = MReg-{{(M_MAX-1){1'b0}},1'b1}

always_ff @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		compute_cyc_counter	<=	{M_MAX{1'b0}};
	end else begin
		if(~eng_rstn) begin
			compute_cyc_counter	<=	{M_MAX{1'b0}};
		end else begin
			if(compute_cyc_count_en) begin
				if(compute_cyc_counter >= compute_cyc_counter_max_value) begin // wrap around when reaching M-1
					compute_cyc_counter	<=	{M_MAX{1'b0}};
				end else begin
					compute_cyc_counter	<=	compute_cyc_counter + ({(M_MAX-1){1'b0}},1'b1};
				end
			end
		end
	end
end

//============================
//  bitmatrix memory control:
//============================
assign bm_cntl_bm_mem_rd_rq = eng_fsm_bm_cntl_rd_en
					          &(
					          eng_bm_cntl_data_used//engine used the data in the output reg and he'll be calc in the next clk also
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

//assigning the memory data out  to the data reg array
genvar i,j;
generate 
	for(i=0;i<BM_MULT_UNIT_NUM;i=i+1) begin
		for(j=0;j<W;j=j+1) begin
			inbuf_mem_dout_reg_0[j][i] = inbuf_mem_rd_data[i*j*W +: W];
		end
	end
endgenerate


endmodule






