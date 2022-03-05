//=====================================================================================================
//
// Module: input buffer
//
// Description
// ===========
// wrapper around the generic sram fifo 
// 
// 
//
//  
//======================================================================================================

// Sub Modules:
// sram_fifo_i
//  


//Notes:

//TODO list:

//======================================================================================================
////######################################### MODULE ####################################################

module input_buffer #(

//=================================
//  user parameters 
//=================================


//=================================
//  local parameters (DON'T CHANGE)
//=================================



)(
//===========
//  inputs:
//===========

	input cntrl_inbuff_rd_en,
	input cntl_inbuf_fifo_rd_rq,
	input cntl_inbuf_fifo_mem_en,

	input inbuf_wr_req,
	input [INBUF_DATA_W-1:0] inbuf_wr_data,


//===========
//  outputs:
//===========
	output inbuf_fifo_cntl_empty,
	output inbuf_dout_reg_val,
	output [PACKET_LENGTH-1:0] inbuf_dout_reg [0:BM_MULT_UNIT_NUM-1][0:W-1] 


);

//======================
//  signals declaration:
//======================


//==============================
//  submodules instantinations:
//==============================

//---	sram_fifo instance ---//

module sram_fifo #(

	.SRAM_WRAP_WIDTH(SRAM_WRAP_WIDTH)
	,.SRAM_WRAP_DEPTH(SRAM_WRAP_DEPTH)


)(

	.clk(clk)
	,.rst_n(rst_n)

	,.wr_req(wr_req)
	,.rd_req(rd_req)
	,.mem_en(mem_en)
	,.wr_data_in(wr_data_in)

	,.rd_data_val(rd_data_val)
	,.rd_data(rd_data)
	,.full(full)
	,.empty(empty)


//---	sram_fifo instance end ---//


//TODO
//assigning the fifo data out  to the data array
genvar i,j;
generate 
	for(i=0;i<BM_MULT_UNIT_NUM;i=i+1) begin
		for(j=0;j<W;j=j+1) begin
			inbuf_mem_dout_reg_0[j][i]	<=	inbuf_mem_rd_data[i*j*W +: W];
end
end
endgenerate


endmodule





