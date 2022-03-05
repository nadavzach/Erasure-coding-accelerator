//=====================================================================================================
//
// Module: eca (erasure coding accelerator) top module
//
// Description
// ===========
// this module is the top module of the eca
// 
// 
//
//  
//======================================================================================================

// Sub Modules:
//  - control_top_i
//  - engine_top_i
//	- inbuf_top_i
//	- outbuf_top_i
//	- bitmatrix_mem_i
//	- regs_top_i



//Notes:

//TODO list:

//======================================================================================================
////######################################### MODULE ####################################################

module eca_top #(

//=================================
//  user parameters 
//=================================


`include "global_parameters.sv"
//=================================
//  local parameters (DON'T CHANGE)
//=================================



)(

	input clk,
	input rstn,
	
	input eca_en,
	input engine_en,
	input m_val,
//input from user - TEMP
	input bmu_bm_mux_sel_reg_wr,
	input [BMU_BM_MUX_SEL_W-1:0] bmu_bm_mux_sel_reg_din [0:BM_MULT_UNIT_NUM-1],

	input and_mask_mask_reg_din,
	input [PACKET_LENGTH-1:0] and_mask_mask_reg_din [0:PCK_TREE_XOR_UNITS_NUM-1][0:W-1][0:K_MAX-1],


//registers IF:
//	input regs_wr_req,
//	input regs_rd_req,
//	input  [COMMON_REG_W-1:0] regs_wr_data,
//	input  [REGS_ADDR_W-1:0] regs_wr_addr,
//	output [COMMON_REG_W-1:0] regs_rd_data,
//	output regs_rd_data_val,

//bitmatrix memory user IF:
	input user_bm_mem_wr_req,
	input [BM_MEM_W-1:0] user_bm_mem_wr_data,
	input [BM_MEM_ADDR_w-1:0] user_bm_mem_wr_addr,

//input buffer IF:
	input inbuf_wr_req,
	input [INBUF_DATA_W-1:0] inbuf_wr_data,

//output buffer IF:
	output outbuf_rd_req,
	output outbuf_rd_data_val,
	output [INBUF_DATA_W-1:0] outbuf_rd_data


);

//======================
//  signals declaration:
//======================

// engine top:

logic [PACKET_LENGTH-1:0] inbuf_eng_din_reg [0:BM_MULT_UNIT_NUM-1][0:W-1];  
logic inbuf_eng_din_reg_val; 
logic [W-1:0] cntl_eng_bm_col_din_reg [0:K_MAX-1][0:W-1] ; 
logic cntl_eng_bm_col_din_reg_val; 
logic global_reg_wr_en; 
logic outbuf_eng_wr_ack; 
logic outbuf_eng_full; 
logic eng_pl_empty;
logic [PACKET_LENGTH-1:0] eng_outbuf_dout_reg [0:PCK_TREE_XOR_UNITS_NUM-1][0:W-1]; 
logic eng_outbuf_wr_req;
logic eng_cntl_data_used;

// control top:

logic eng_rstn_o;
logic cntrl_inbuff_rd_en;
logic cntrl_outbuff_wr_en;
logic cntrl_eng_calc_en;
logic [W-1:0] bm_col_data_out [0:W-1] [0:K_MAX-1];
logic bm_coloum_data_out_val;

// IF between control & bm mem
logic [BM_COL_W-1:0] bm_mem_bm_cntl_rd_data;
logic bm_mem_bm_cntl_rd_data_val;
logic bm_cntl_bm_mem_rd_rq;
logic [BM_MEM_ADDR_W-1:0] bm_cntl_bm_mem_rd_addr;

logic [BM_MEM_ADDR_w-1:0] bm_mem_addr,

//==============================
//  local logic:
//==============================

//MReg:

always_ff @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		bm_col_counter	<=	{M_MAX{1'b0}};
	end else begin
		if(m_val_wr_req) begin
			if(bm_col_counter >= bm_col_counter_max_value) begin // wrap around when reaching M-1
				bm_col_counter	<=	{M_MAX{1'b0}};
			end
		end
	end
end


//==============================
//  submodules instantinations:
//==============================


//------- engine top start --------//


module engine_top engine_top_i (

	.clk                            ( clk                         )
	,.rstn                          ( rstn                        )
	,.eng_rstn                      ( eng_rstn                    )
	,.bmu_bm_mux_sel_reg_wr         (  bmu_bm_mux_sel_reg_wr	  )                                                                                          
	,.bmu_bm_mux_sel_reg_din		( bmu_bm_mux_sel_reg_din	  )
	,.
	,.and_mask_mask_reg_wr			( and_mask_mask_reg_wr		  )
	,.and_mask_mask_reg_din			( and_mask_mask_reg_din		  )

//input from inbuff
	,.inbuf_eng_din_reg             ( inbuf_eng_din_reg           )
	,.inbuf_eng_din_reg_val         ( inbuf_eng_din_reg_val       )
//input from control 
	,.cntl_eng_bm_col_din_reg       ( cntl_eng_bm_col_din_reg     )
	,.cntl_eng_bm_col_din_reg_val   ( cntl_eng_bm_col_din_reg_val )
	,.cntrl_eng_calc_en             ( cntrl_eng_calc_en           )
	,.global_reg_wr_en              ( global_reg_wr_en            )
// inputs from outbuff
	,.outbuf_eng_wr_ack             ( outbuf_eng_wr_ack           )
	,.outbuf_eng_full               ( outbuf_eng_full             )
// output to control
	,.data_used  	                ( eng_cntl_data_used          )
	,.eng_pl_empty                  ( eng_pl_empty                )
// output to outbuf mem
	,.eng_outbuf_dout_reg           ( eng_outbuf_dout_reg         )
	,.eng_outbuf_wr_req             ( eng_outbuf_wr_req           )
);


//------- engine top end --------//


//------- control top start --------//

module control_top control_top_i #(

	,.clk                            ( clk                        )
	,.rstn                           ( rstn                       )
	//input from engine
	,.eng_empty                      ( eng_pl_empty               )
	,.eng_cntl_data_used		     ( eng_cntl_data_used	      )

	,.EcaEnReg				         ( eca_en					  )
	,.engine_en						 ( engine_en				  )	
	,.MReg							 ( MReg						  )

	//output to input buffer
	,.cntrl_inbuff_rd_en             ( cntrl_inbuff_rd_en         )
	//output to output buffer
	,.cntrl_outbuff_wr_en            ( cntrl_outbuff_wr_en        )
	//output to engine
	,.cntrl_eng_calc_en              ( cntrl_eng_calc_en          )
	,.bm_col_data_out                ( cntl_eng_bm_col_din_reg    )
	,.bm_coloum_data_out_val         ( cntl_eng_bm_col_din_reg_val)
	,.eng_rstn_o                     (  eng_rstn                  )
	//output to registers
	,.global_reg_wr_en               ( global_reg_wr_en           )
	//  bitmatrix mem I/F:
	,.bm_mem_bm_cntl_rd_data         ( bm_mem_bm_cntl_rd_data     )
	,.bm_mem_bm_cntl_rd_data_val     ( bm_mem_bm_cntl_rd_data_val )
	,.bm_cntl_bm_mem_rd_rq           ( bm_cntl_bm_mem_rd_rq       )
	,.bm_cntl_bm_mem_rd_addr         ( bm_cntl_bm_mem_rd_addr     )
);


//------- control top end --------//



//------- bitmatrix memory sram start --------//

assign bm_mem_addr = (user_bm_mem_wr_req ? user_bm_mem_addr : bm_cntl_bm_mem_rd_addr);

module sram_wrapper #(

	.SRAM_WRAP_WIDTH(BM_MEM_W)	
	,.SRAM_WRAP_DEPTH(BM_MEM_DEPTH)

) 
bit_matrix_memory_i
(
	.clk(clk)
	,.rst_n(rstn)
	
	,.mem_en(EcaEnReg)
	,.rd_req(bm_cntl_bm_mem_rd_rq)
	,.wr_req(user_bm_mem_wr_req)
	,.address(bm_mem_addr)
	,.wr_data_in(user_bm_mem_wr_data)
	
	,.rd_data_val(bm_mem_bm_cntl_rd_data_val)
	,.rd_data(bm_mem_bm_cntl_rd_data)
);

//-------bitmatrix memory sram end --------//


module sram_fifo output_buffer_i #(

	.SRAM_WRAP_WIDTH//TODO
	.SRAM_WRAP_DEPTH//TODO
)(
.clk(clk)
,.rst_n(rst_n)
,.wr_req(eng_outbuf_wr_req)
,.rd_req(user_outbuf_rd_req)
,.mem_en(outbuf_mem_en)
,.wr_data_in(eng_outbuf_data)
,.rd_data_val(outbuf_user_rd_data_val)
,.rd_data(outbuf_user_rd_data)
,.wr_ack(wr_ack)
,.full(full)
,.empty(empty)

);

endmodule





