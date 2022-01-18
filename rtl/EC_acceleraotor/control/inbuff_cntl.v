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
// check the read req from the counter, make sure its aliging 
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
logic new_data_req;
logic compute_cyc_count_en;

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

assign new_data_req =  ~|(compute_cyc_counter ^ compute_cyc_counter_req_value);//comparator


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
					compute_cyc_counter	<=	compute_cyc_counter + ({(M_MAX-1){1'b0}},1'b1};
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
assign bm_cntl_bm_mem_rd_rq = cntrl_inbuff_rd_en
					          &(
					          new_data_req// TODO add some logic so it will not read while no operation in the engine - maybe smg with eng_inbuf_cntl_data_used
							  ||
					          ~inbuf_eng_dout_reg_val//in calc mode but no data in output reg (no valid)
					          );

//output register + val sync block					   
always_ff @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		inbuf_mem_dout_reg_val_0	<=	1'b0;
	end else begin
		if(~eng_rstn) begin
			inbuf_mem_dout_reg_val_0	<=	1'b0;
		end else begin
			if(inbuf_mem_rd_data_val) begin
				inbuf_mem_dout_reg_val_0	<=	1'b1;
			end
		end
	end
end


//assigning the memory data out  to the data reg array
genvar i,j;
generate 
	for(i=0;i<BM_MULT_UNIT_NUM;i=i+1) begin
		for(j=0;j<W;j=j+1) begin

//output register + val sync block					   
			always_ff @(posedge clk or negedge rstn) begin
				if(~rstn) begin
					inbuf_mem_dout_reg_0[j][i]	<=	{PACKET_LENGTH{1'b0}};
				end else begin
					if(~eng_rstn) begin
						inbuf_mem_dout_reg_0[j][i]	<=	{PACKET_LENGTH{1'b0}};
					end else begin
						if(bm_mem_bm_cntl_rd_data_val) begin
							inbuf_mem_dout_reg_0[j][i]	<=	inbuf_mem_rd_data[i*j*W +: W];
						end
					end
				end
			end
		end
	end


endgenerate


endmodule






