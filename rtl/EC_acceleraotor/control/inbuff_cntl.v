//=====================================================================================================
//
// Module:  input buffer controller
//
// Description
// ===========
// this module interacts with:
//		- the input buffer memory. the mem holds the incoming data to encode. it should read new line every M clk cycles
//
//  
//======================================================================================================

// Sub Modules:


//Notes:

//TODO list:

// make sure that the data read to the buffer regs will not be overwritten, so rst(eng or main) will not cause lost data.
// check the read req from the counter, make sure its aligning 
//======================================================================================================
////######################################### MODULE ####################################################
module inbuff_cntl #(

//=================================
//  user parameters 
//=================================
	parameter K_MAX = 128,
	parameter K_MIN = 2,
	parameter M_MAX = 128,
	parameter M_MIN = 2,
	parameter W = 4,
	parameter PACKET_LENGTH =  2,


//=================================
//  local parameters (DON'T CHANGE)
//=================================

    parameter MREG_W    = $clog2(M_MAX),
	//bitmatrix memory parameters:

	parameter BM_MEM_DEPTH = M_MAX,
	parameter BM_COL_W = W*W*K_MAX,
	parameter BM_MEM_W = BM_COL_W,
	parameter BM_MEM_ADDR_W = $clog2(BM_MEM_W)

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
	input [MREG_W-1:0] MReg,


//====================
//  sram FIFO I/F:
//====================

	output cntl_inbuf_fifo_rd_rq,
	output cntl_inbuf_fifo_mem_en,
	
	input inbuf_fifo_cntl_empty//TODO add logic to when there's rd req to FIFO and it's empty



);

//======================
//  signals declaration:
//======================

// counter
logic compute_cyc_count_en;
logic [M_MAX-1:0] compute_cyc_counter;
logic [M_MAX-1:0] compute_cyc_counter_req_value;
logic [M_MAX-1:0] compute_cyc_counter_max_value;
logic new_data_req;

//logic pending_data_used;
//bm memory

//======================
//  compute cycle counter:
//======================

//	description:
// countes the M compute cycles for each data line, to indicate when there's a need for a new data line/ the engine can be emptied
assign compute_cyc_count_en	=  eng_inbuf_cntl_data_used ;

assign new_data_req =  (~|(compute_cyc_counter ^ compute_cyc_counter_max_value)) & eng_inbuf_cntl_data_used;//comparator

assign cntl_inbuf_fifo_mem_en = 1'b1;// TODO - remove if not needed

//always_ff @(posedge clk or negedge rstn) begin
//	if(rstn) begin
//		pending_data_used	<=	1'b0;
//	end else begin
//		if(eng_inbuf_cntl_data_used & inbuf_fifo_cntl_empty) begin
//			pending_data_used	<=	1'b1;
//		end else begin
//			if(pending_data_used
//		end
//	end
//end
// counter logic
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
					compute_cyc_counter	<=	compute_cyc_counter + {{(M_MAX-1){1'b0}},1'b1};
				end
			end
		end
	end
end


//setting the the registers used to compare against the counter:
always_ff @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		compute_cyc_counter_req_value	<=	{M_MAX{1'b0}};
		compute_cyc_counter_max_value	<=	{M_MAX{1'b0}};

		end else begin
			if(~eng_rstn) begin
				compute_cyc_counter_req_value	<=	{M_MAX{1'b0}};
				compute_cyc_counter_max_value	<=	{M_MAX{1'b0}};
			end else begin
				if(cntrl_inbuff_rd_en) begin
					compute_cyc_counter_req_value	<=  (MReg-{{(M_MAX-2){1'b0}},1'b1,1'b0});	
					compute_cyc_counter_max_value	<=	(MReg-{{(M_MAX-1){1'b0}},1'b1});		

			end
		end
	end
end


//============================
//  input buffer memory control:
//============================
assign cntl_inbuf_fifo_rd_rq = cntrl_inbuff_rd_en & new_data_req;





endmodule
