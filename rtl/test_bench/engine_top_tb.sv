/*------------------------------------------------------------------------------
 * File          : bm_mult_unit_tb.sv
 * Project       : RTL
 * Author        : epodnz
 * Creation date : Jan 13, 2022
 * Description   : Test bench for the bm_mult_unit module
 *------------------------------------------------------------------------------*/

module engine_top_tb#(
	  
	parameter K_MAX = 4,
		  K_MIN = 2,
		  W = 4,
		  PACKET_LENGTH =  2,
		  M_MAX = 128,
		  M_MIN = 2,

		  BM_MULT_UNIT_NUM = 4,
		  PCK_TREE_XOR_UNITS_NUM = BM_MULT_UNIT_NUM / K_MIN,
		  BMU_BM_MUX_SEL_W		 = $clog2(K_MAX),

	parameter CLK_CYCLE = 2
	
	);
 
	//General
	
	logic          clk;
	logic          rst_n;
	logic          eng_rstn;
	
	//input
	 
	//inbuff

	logic [PACKET_LENGTH-1:0] inbuf_eng_din_reg [0:BM_MULT_UNIT_NUM-1][0:W-1];
	logic inbuf_eng_din_reg_val;

	//control
	
	logic [BMU_BM_MUX_SEL_W-1:0] bmu_bm_mux_sel_reg_din [0:BM_MULT_UNIT_NUM-1];
	logic [W-1:0] cntl_eng_bm_col_din_reg [0:K_MAX-1][0:W-1];
	logic cntl_eng_bm_col_din_reg_val;
	logic cntrl_eng_calc_en;
	logic global_reg_wr_en;

    //user -temp

	logic bmu_bm_mux_sel_reg_wr;
	logic [BMU_BM_MUX_SEL_W-1:0] bmu_bm_mux_sel_reg_din [0:BM_MULT_UNIT_NUM-1];

	logic and_mask_mask_reg_wr;
	logic  [0:K_MAX-1] and_mask_mask_reg_din [0:PCK_TREE_XOR_UNITS_NUM-1];

	//outbuff
	
	logic outbuf_eng_wr_ack;
	logic outbuf_eng_full;
	
	//output
	//control
	logic data_used;
	logic eng_pl_empty;// indicates there is no valid calculated data in the engine that hav'nt been written to 

	// to outbuf mem

	logic  [PACKET_LENGTH-1:0] eng_outbuf_dout_reg [0:PCK_TREE_XOR_UNITS_NUM-1][0:W-1];
	logic  eng_outbuf_wr_req;

	 //Internal signals
	 logic start;
	 logic finish;

	 //Init
	 initial
	 begin
		clk	= 1'b0;
        rst_n = 1'b0;
        eng_rstn = 1'b0;
		inbuf_eng_din_reg_val = 1'b0;
		cntl_eng_bm_col_din_reg_val = 1'b0;
		cntrl_eng_calc_en = 1'b0;
		global_reg_wr_en = 1'b0;
		bmu_bm_mux_sel_reg_wr = 1'b0;
        and_mask_mask_reg_wr = 1'b0;

		#(4*CLK_CYCLE)
        rst_n = 1'b1;
        eng_rstn = 1'b1;


		#(4*CLK_CYCLE)
	    bmu_bm_mux_sel_reg_wr = 1'b1;
        and_mask_mask_reg_wr = 1'b1;

		#(4*CLK_CYCLE)
        bmu_bm_mux_sel_reg_wr = 1'b0;
        and_mask_mask_reg_wr = 1'b0;


		inbuf_eng_din_reg_val = 1'b1;
		cntl_eng_bm_col_din_reg_val = 1'b1;
		cntrl_eng_calc_en = 1'b1;
		global_reg_wr_en = 1'b1;
		outbuf_eng_wr_ack = 1'b1;
		outbuf_eng_full = 1'b0;
		
		 
		#(30*CLK_CYCLE) 
		finish = 1'b1;
	 
	 end

  //#################################################            
 // ================================================
 // ~~~~~~~~~~ Instantiations ~~~~~~~~~~
 // ================================================
 //#################################################
					
 //******************************************
 // Instantiation -  engine top
 //******************************************
 
	engine_top #(
	.K_MAX(K_MAX), .K_MIN(K_MIN), .W(W), .PACKET_LENGTH(PACKET_LENGTH), .BM_MULT_UNIT_NUM(BM_MULT_UNIT_NUM) 
	)engine_top_i(
	
	//input
	.clk(clk),
	.rstn(rst_n),
	.eng_rstn(eng_rstn),

	.bmu_bm_mux_sel_reg_wr(bmu_bm_mux_sel_reg_wr),
    .bmu_bm_mux_sel_reg_din(bmu_bm_mux_sel_reg_din),
    .and_mask_mask_reg_wr(and_mask_mask_reg_wr),
    .and_mask_mask_reg_din(and_mask_mask_reg_din),

	.inbuf_eng_din_reg(inbuf_eng_din_reg), 
	.inbuf_eng_din_reg_val(inbuf_eng_din_reg_val),

	.cntl_eng_bm_col_din_reg(cntl_eng_bm_col_din_reg),
	.cntl_eng_bm_col_din_reg_val(cntl_eng_bm_col_din_reg_val),
	.cntrl_eng_calc_en(cntrl_eng_calc_en),
	.global_reg_wr_en(global_reg_wr_en),

	.outbuf_eng_wr_ack(outbuf_eng_wr_ack),
	.outbuf_eng_full(outbuf_eng_full),

	//output
	.data_used(data_used), 	
	.eng_pl_empty(eng_pl_empty), 

	.eng_outbuf_dout_reg(eng_outbuf_dout_reg), 	//[PACKET_LENGTH-1:0]		 [0:PCK_TREE_XOR_UNITS_NUM-1][0:W-1]
	.eng_outbuf_wr_req(eng_outbuf_wr_req)
	
	);

 //input dly assignment 
 //******************************************
 //assign #IF_DLY <signal name>_dly = <signal name>;
	
	
 // ================================================
 // ~~~~~~~~~~ test bench logic ~~~~~~~~~~
 // ================================================

 //Init
 initial
 begin
	
	inbuf_eng_din_reg[0][0] = {1'b1,1'b1};
	
	inbuf_eng_din_reg[0][1] = {1'b1,1'b1};
	
	inbuf_eng_din_reg[0][2] = {1'b0,1'b1};
	
	inbuf_eng_din_reg[0][3] = {1'b0,1'b0};
	
	
	inbuf_eng_din_reg[1][0] = {1'b1,1'b1};
	
	inbuf_eng_din_reg[1][1] = {1'b1,1'b1};
	
	inbuf_eng_din_reg[1][2] = {1'b0,1'b1};
	
	inbuf_eng_din_reg[1][3] = {1'b1,1'b1};


	inbuf_eng_din_reg[2][0] = {1'b1,1'b1};
	
	inbuf_eng_din_reg[2][1] = {1'b1,1'b1};
	
	inbuf_eng_din_reg[2][2] = {1'b1,1'b1};
	
	inbuf_eng_din_reg[2][3] = {1'b1,1'b1};


	inbuf_eng_din_reg[3][0] = {1'b1,1'b1};
	
	inbuf_eng_din_reg[3][1] = {1'b0,1'b1};
	
	inbuf_eng_din_reg[3][2] = {1'b0,1'b0};
	
	inbuf_eng_din_reg[3][3] = {1'b0,1'b0};

	/////////////////////////////////////////////////////////////
	///////////////////////////////////////////////////////////
	
	cntl_eng_bm_col_din_reg[0][0] = {1'b1,1'b1,1'b0,1'b1} ;
	
	cntl_eng_bm_col_din_reg[0][1] = {1'b0,1'b0,1'b1,1'b1} ;
	
	cntl_eng_bm_col_din_reg[0][2] = {1'b0,1'b1,1'b0,1'b1} ;
	
	cntl_eng_bm_col_din_reg[0][3] = {1'b1,1'b1,1'b0,1'b0} ;
	
	////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////
	
	cntl_eng_bm_col_din_reg[1][0] = {1'b1,1'b1,1'b0,1'b1} ;
	
	cntl_eng_bm_col_din_reg[1][1] = {1'b1,1'b1,1'b0,1'b1} ;
	
	cntl_eng_bm_col_din_reg[1][2] = {1'b1,1'b1,1'b0,1'b1} ;
	
	cntl_eng_bm_col_din_reg[1][3] = {1'b1,1'b1,1'b0,1'b1} ;
	
	////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////
	
	cntl_eng_bm_col_din_reg[2][0] = {1'b1,1'b1,1'b0,1'b1} ;
	
	cntl_eng_bm_col_din_reg[2][1] = {1'b0,1'b1,1'b0,1'b0} ;
	
	cntl_eng_bm_col_din_reg[2][2] = {1'b1,1'b1,1'b0,1'b1} ;
	
	cntl_eng_bm_col_din_reg[2][3] = {1'b0,1'b1,1'b1,1'b0} ;
	
	////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////
	
	cntl_eng_bm_col_din_reg[3][0] = {1'b0,1'b1,1'b1,1'b0} ;
	
	cntl_eng_bm_col_din_reg[3][1] = {1'b1,1'b1,1'b0,1'b1} ;
	
	cntl_eng_bm_col_din_reg[3][2] = {1'b0,1'b1,1'b0,1'b1} ;
	
	cntl_eng_bm_col_din_reg[3][3] = {1'b1,1'b1,1'b1,1'b1} ;
	
	////////////////////////////////////////////////////////////
                //  bm mult unit mux sel regs
	////////////////////////////////////////////////////////////
    bmu_bm_mux_sel_reg_din[0] = {1'b0,1'b0};
    bmu_bm_mux_sel_reg_din[1] = {1'b0,1'b1};
    bmu_bm_mux_sel_reg_din[2] = {1'b0,1'b0};
    bmu_bm_mux_sel_reg_din[3] = {1'b0,1'b1};

	////////////////////////////////////////////////////////////
                //  mask regs
	////////////////////////////////////////////////////////////
    and_mask_mask_reg_din [0] = {1'b0,1'b0,1'b1,1'b1};
    and_mask_mask_reg_din [1] = {1'b0,1'b0,1'b1,1'b1};


 end

 //-----------------------------------
 //Clocks
 //-----------------------------------

 always
 begin
	 #(CLK_CYCLE/2) clk <= ~clk;
 end

 //-----------------------------------
 //Reseting logics
 //-----------------------------------

 always @(posedge clk or negedge rst_n)
 begin
	 if(~rst_n)
	 begin
	  
	 end
	 else
	 start                                <= 1'b1;
 end


 // ================================================
 // ~~~~~~~~~~ test bench flow ~~~~~~~~~~
 // ================================================

 always @(finish)
 begin
	 if (finish)
		 $finish;
 end

endmodule
