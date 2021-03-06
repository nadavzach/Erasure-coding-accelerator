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
    parameter PACKET_LENGTH             = 2,
    parameter W                         = 4,
	parameter BM_MULT_UNIT_NUM          = 4,
    parameter INBUF_DATA_DEPTH          = 10,
    parameter INBUF_DATA_W             = PACKET_LENGTH*W*BM_MULT_UNIT_NUM


//=================================
//  local parameters (DON'T CHANGE)
//=================================



)(
//===========
//  inputs:
//===========

    input clk,
    input rst_n,
	input cntl_inbuf_fifo_rd_rq,
	input cntl_inbuf_fifo_mem_en,

	input inbuf_wr_req,
	input [INBUF_DATA_W-1:0] inbuf_wr_data,


//===========
//  outputs:
//===========
	output inbuf_fifo_cntl_empty,
    output inbuf_user_full,
	output inbuf_dout_reg_val,
	output [PACKET_LENGTH-1:0] inbuf_dout_reg [0:BM_MULT_UNIT_NUM-1][0:W-1],
    output wr_ack

);

//======================
//  signals declaration:
//======================

logic [INBUF_DATA_W-1:0] inbuf_rd_data;

//==============================
//  submodules instantinations:
//==============================

//---	sram_fifo instance ---//

sram_fifo #(

	.SRAM_WRAP_WIDTH(INBUF_DATA_W)
	,.SRAM_WRAP_DEPTH(INBUF_DATA_DEPTH)


) inbuf_fifo_i(

	.clk(clk)
	,.rst_n(rst_n)

	,.wr_req(inbuf_wr_req)
	,.rd_req(cntl_inbuf_fifo_rd_rq)
	,.mem_en(cntl_inbuf_fifo_mem_en)
	,.wr_data_in(inbuf_wr_data)
    ,.wr_ack(wr_ack)
	,.rd_data_val(inbuf_dout_reg_val)
	,.rd_data(inbuf_rd_data)
	,.full(inbuf_user_full)
	,.empty(inbuf_fifo_cntl_empty)

);
//---	sram_fifo instance end ---//


//assigning the fifo data out  to the data array
genvar i,j;
generate 
	for(i=0;i<BM_MULT_UNIT_NUM;i=i+1) begin
		for(j=0;j<W;j=j+1) begin
			assign inbuf_dout_reg[BM_MULT_UNIT_NUM-1 - i][W-1-j]	 =	inbuf_rd_data[(i*W +j)*PACKET_LENGTH +: PACKET_LENGTH];
        end
    end
endgenerate


endmodule





