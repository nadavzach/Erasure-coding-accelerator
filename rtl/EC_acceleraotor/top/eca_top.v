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
	  
	parameter K_MAX                     = 4,
	parameter K_MIN                     = 2,
	parameter W                         = 4,
	parameter PACKET_LENGTH             = 2,
	parameter M_MAX                     = 128,
	parameter M_MIN                     = 2,

	parameter BM_MULT_UNIT_NUM          = 4,

  

    parameter OUTBUF_MEM_DEPTH          = 10,
    parameter INBUF_DATA_DEPTH          = 10,
//=================================
//  local parameters (DON'T CHANGE)
//=================================

    parameter MREG_W                    = $clog2(M_MAX),

	parameter PCK_TREE_XOR_UNITS_NUM    = BM_MULT_UNIT_NUM / K_MIN,
	parameter BMU_BM_MUX_SEL_W		    = $clog2(K_MAX),


    parameter OUTBUF_DATA_W             = PACKET_LENGTH*W*PCK_TREE_XOR_UNITS_NUM,
    parameter INBUF_DATA_W              = PACKET_LENGTH*W*BM_MULT_UNIT_NUM,

    parameter BM_MEM_W                  = K_MAX * W * W,	
    parameter BM_MEM_DEPTH              = M_MAX,      
	parameter BM_MEM_ADDR_W             = $clog2(BM_MEM_DEPTH)

)(

	input clk,
	input rstn,
	
	input eca_en,
	input engine_en,
	input [MREG_W-1:0] m_val,
    input m_val_wr,
//input from user - TEMP
	input bmu_bm_mux_sel_reg_wr,
	input [BMU_BM_MUX_SEL_W-1:0] bmu_bm_mux_sel_reg_din [0:BM_MULT_UNIT_NUM-1],

	input and_mask_mask_reg_wr,
	input  [BM_MULT_UNIT_NUM-1:0]and_mask_mask_reg_din [0:PCK_TREE_XOR_UNITS_NUM-1],

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
	input [BM_MEM_ADDR_W-1:0] user_bm_mem_wr_addr,

//input buffer IF:
	input inbuf_wr_req,
    output inbuf_user_wr_ack,
    output inbuf_user_full,
	input [INBUF_DATA_W-1:0] inbuf_wr_data,

//output buffer IF:
	input outbuf_rd_req,
	output outbuf_rd_data_val,
    output outbuf_user_rd_ack,
	output [OUTBUF_DATA_W-1:0] outbuf_rd_data


);

//======================
//  signals declaration:
//======================

logic [MREG_W-1:0] MReg;

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
logic [W-1:0] bm_col_data_out [0:K_MAX-1] [0:W-1];
logic bm_coloum_data_out_val;
logic cntl_inbuf_fifo_mem_en;

// IF between control & bm mem
logic [BM_MEM_W-1:0] bm_mem_bm_cntl_rd_data;
logic bm_mem_bm_cntl_rd_data_val;
logic bm_cntl_bm_mem_rd_rq;
logic [BM_MEM_ADDR_W-1:0] bm_cntl_bm_mem_rd_addr;

logic [BM_MEM_ADDR_W-1:0] bm_mem_addr;

// outbuf:
logic outbuf_fifo_cntl_empty;

//==============================
//  local logic:
//==============================

//MReg:

always_ff @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		MReg	<=	{MREG_W{1'b0}};
	end else begin
		if(m_val_wr) begin
			MReg	<=	m_val;
		end
	end
end


//==============================
//  submodules instantinations:
//==============================


//------- engine top start --------//


engine_top #(
    .K_MAX(K_MAX),
	.K_MIN(K_MIN),
	.M_MAX(M_MAX),
	.M_MIN(M_MIN),
	.W(W),
	.PACKET_LENGTH(PACKET_LENGTH),
	.BM_MULT_UNIT_NUM(BM_MULT_UNIT_NUM)

)engine_top_i (

	.clk                            ( clk                         )
	,.rstn                          ( rstn                        )
	,.eng_rstn                      ( eng_rstn                    )
	,.bmu_bm_mux_sel_reg_wr         (  bmu_bm_mux_sel_reg_wr	  )                                                                                          
	,.bmu_bm_mux_sel_reg_din		( bmu_bm_mux_sel_reg_din	  )
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

control_top #(
    .K_MAX(K_MAX),
	.K_MIN(K_MIN),
	.M_MAX(M_MAX),
	.M_MIN(M_MIN),
	.W(W),
	.PACKET_LENGTH(PACKET_LENGTH)
) control_top_i (

	.clk                            ( clk                        )
	,.rstn                           ( rstn                       )
	//input from engine
	,.eng_empty                      ( eng_pl_empty               )
	,.eng_cntl_data_used		     ( eng_cntl_data_used	      )

	,.EcaEnReg				         ( eca_en					  )
	,.engine_en						 ( engine_en				  )	
	,.MReg							 ( MReg						  )
	// input from input buffer		 
	,.inbuf_fifo_cntl_empty			 ( inbuf_fifo_cntl_empty	  )
	//output to input buffer
	,.cntl_inbuf_fifo_rd_rq			 ( cntl_inbuf_fifo_rd_rq	  ) 	
	,.cntl_inbuf_fifo_mem_en		 ( cntl_inbuf_fifo_mem_en	  )

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

assign bm_mem_addr = (user_bm_mem_wr_req ? user_bm_mem_wr_addr : bm_cntl_bm_mem_rd_addr);

sram_wrapper #(

	.SRAM_WRAP_WIDTH(BM_MEM_W)	
	,.SRAM_WRAP_DEPTH(BM_MEM_DEPTH)

) 
bit_matrix_memory_i
(
	.clk(clk)
	,.rst_n(rstn)
	
	,.mem_en(1'b1)//TODO - set
	,.rd_req(bm_cntl_bm_mem_rd_rq)
	,.wr_req(user_bm_mem_wr_req)
	,.address(bm_mem_addr)
	,.wr_data_in(user_bm_mem_wr_data)
	
	,.rd_data_val(bm_mem_bm_cntl_rd_data_val)
	,.rd_data(bm_mem_bm_cntl_rd_data)
);

//-------bitmatrix memory sram end --------//


//-------output buffer start  --------//
output_buffer  #(

	.PACKET_LENGTH(PACKET_LENGTH),         
	.W(W),                     
    .PCK_TREE_XOR_UNITS_NUM( PCK_TREE_XOR_UNITS_NUM),  
    .OUTBUF_MEM_DEPTH( OUTBUF_MEM_DEPTH)        

)output_buffer_i(
    .clk(clk)
    ,.rst_n(rstn)
    ,.cntrl_outbuff_wr_en(cntrl_outbuff_wr_en)
    ,.eng_outbuf_wr_req(eng_outbuf_wr_req)
    ,.user_outbuf_rd_req(outbuf_rd_req)
    ,.outbuf_wr_data(eng_outbuf_dout_reg)
    ,.outbuf_fifo_cntl_empty(outbuf_fifo_cntl_empty)
    ,.outbuf_dout_reg_val(outbuf_rd_data_val)
    ,.outbuf_dout_reg(outbuf_rd_data)
    ,.outbuf_eng_wr_ack(outbuf_eng_wr_ack)
    ,.outbuf_eng_full(outbuf_eng_full)
    ,.outbuf_user_rd_ack(outbuf_user_rd_ack)

);

//-------output buffer end  --------//


//-------input buffer start  --------//


input_buffer #(
	.PACKET_LENGTH(PACKET_LENGTH),         
	.W(W),                     
    .BM_MULT_UNIT_NUM(BM_MULT_UNIT_NUM),
    .INBUF_DATA_DEPTH(INBUF_DATA_DEPTH)
) input_buffer_i (
    .clk(clk)
    ,.rst_n(rstn)
	,.cntl_inbuf_fifo_rd_rq(cntl_inbuf_fifo_rd_rq)
	,.cntl_inbuf_fifo_mem_en(cntl_inbuf_fifo_mem_en)
	,.inbuf_wr_req(inbuf_wr_req)
	,.inbuf_wr_data( inbuf_wr_data)
	,.inbuf_fifo_cntl_empty(inbuf_fifo_cntl_empty)
	,.inbuf_dout_reg_val(inbuf_eng_din_reg_val)
	,. inbuf_dout_reg( inbuf_eng_din_reg) 
    ,.wr_ack(inbuf_user_wr_ack)
    ,.inbuf_user_full(inbuf_user_full)


);
//	input inbuf_wr_req,
//	input [INBUF_DATA_W-1:0] inbuf_wr_data,
//	output inbuf_fifo_cntl_empty,
//	output inbuf_dout_reg_val,
//	output [PACKET_LENGTH-1:0] inbuf_dout_reg [0:BM_MULT_UNIT_NUM-1][0:W-1] 



//-------input buffer end  --------//

endmodule





