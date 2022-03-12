//=====================================================================================================
//
// Module: output buffer
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

module output_buffer #(

//=================================
//  user parameters 
//=================================

    parameter PACKET_LENGTH             = 2,
    parameter W                         = 4,
    parameter PCK_TREE_XOR_UNITS_NUM    = 6,
    parameter OUTBUF_MEM_DEPTH          = 10,
    parameter OUTBUF_DATA_W = PACKET_LENGTH*W*PCK_TREE_XOR_UNITS_NUM

//=================================
//  local parameters (DON'T CHANGE)
//=================================


)(
//===========
//  inputs:
//===========
    input clk,
    input rst_n,
	input cntrl_outbuff_wr_en,
    
	input eng_outbuf_wr_req,
    input user_outbuf_rd_req,
	input [PACKET_LENGTH-1:0] outbuf_wr_data [0:PCK_TREE_XOR_UNITS_NUM-1][0:W-1],


//===========
//  outputs:
//===========
	output outbuf_fifo_cntl_empty,
	output outbuf_dout_reg_val,
	output [OUTBUF_DATA_W-1:0] outbuf_dout_reg,
    output outbuf_eng_wr_ack,
    output outbuf_eng_full,
    output outbuf_user_rd_ack//TODO - all acks to regs


);

//======================
//  signals declaration:
//======================

logic [OUTBUF_DATA_W-1:0] outbuf_fifo_din;

//==============================
//  submodules instantinations:
//==============================

assign outbuf_user_rd_ack = user_outbuf_rd_req & ~eng_outbuf_wr_req;

//---	sram_fifo instance ---//

sram_fifo #(

	.SRAM_WRAP_WIDTH(OUTBUF_DATA_W)
	,.SRAM_WRAP_DEPTH(OUTBUF_MEM_DEPTH)


) outbuf_fifo_i(

	.clk(clk)
	,.rst_n(rst_n)

	,.wr_req(eng_outbuf_wr_req)
	,.rd_req(user_outbuf_rd_req & ~eng_outbuf_wr_req)
	,.mem_en(1'b1) // TODO what to connect here?
	,.wr_data_in(outbuf_fifo_din)
    ,.wr_ack(outbuf_eng_wr_ack)
	,.rd_data_val(outbuf_dout_reg_val)
	,.rd_data(outbuf_dout_reg)
	,.full(outbuf_eng_full)
	,.empty(outbuf_fifo_cntl_empty)

);
//---	sram_fifo instance end ---//


//assigning the fifo data array out  to the mem in vector
genvar i,j;
generate 
	for(i=0;i<PCK_TREE_XOR_UNITS_NUM;i=i+1) begin
		for(j=0;j<W;j=j+1) begin
		    assign outbuf_fifo_din[(i*W + j)*PACKET_LENGTH +: PACKET_LENGTH] = outbuf_wr_data[PCK_TREE_XOR_UNITS_NUM-1-i][W-1-j];
end
end
endgenerate


endmodule





