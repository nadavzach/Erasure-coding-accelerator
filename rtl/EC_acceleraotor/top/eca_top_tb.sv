/*------------------------------------------------------------------------------
 * File          : eca_top_tb.sv
 * Project       : RTL
 * Author        : epodnz
 * Creation date : Jan 13, 2022
 * Description   : Test bench for the whole chip!
 *------------------------------------------------------------------------------*/

module eca_top_tb#(
	  
	parameter K_MAX = 4,
			  K_MIN = 2,
			  W = 4,
			  PACKET_LENGTH =  2,
			  M_MAX = 4,
			  M_MIN = 2,

			  BM_MULT_UNIT_NUM = 4,
			  PCK_TREE_XOR_UNITS_NUM = BM_MULT_UNIT_NUM / K_MIN,
			  BMU_BM_MUX_SEL_W		 = $clog2(K_MAX),
			  
	//bitmatrix memory parameters:

			  BM_MEM_DEPTH = M_MAX,
			  BM_COL_W = W*W*K_MAX,
			  BM_MEM_W = BM_COL_W,
			  BM_MEM_ADDR_W = $clog2(BM_MEM_W),
	
	
			  INBUF_DATA_W = W*PACKET_LENGTH*K_MAX,

	parameter CLK_CYCLE = 2
	
	);
 
	//General
	
	logic          clk;
	logic          rstn;

	//input
	 
	logic eca_en;
	logic engine_en;
	logic [$clog2(M_MAX)-1:0] m_val;
	logic m_val_wr;
	
	//input from user - TEMP
	logic bmu_bm_mux_sel_reg_wr;
	logic [BMU_BM_MUX_SEL_W-1:0] bmu_bm_mux_sel_reg_din [0:BM_MULT_UNIT_NUM-1];

	logic and_mask_mask_reg_wr;
	logic [K_MAX-1:0] and_mask_mask_reg_din [0:PCK_TREE_XOR_UNITS_NUM-1];

	//bitmatrix memory user IF:
	logic user_bm_mem_wr_req;
	logic [BM_MEM_W-1:0] user_bm_mem_wr_data;
	logic [BM_MEM_ADDR_W-1:0] user_bm_mem_wr_addr;

	//input buffer IF:
	logic inbuf_wr_req;
	logic [INBUF_DATA_W-1:0] inbuf_wr_data;

	//output buffer IF:
	logic outbuf_rd_req;
	logic outbuf_rd_data_val;
	logic [INBUF_DATA_W-1:0] outbuf_rd_data;
	
	
	//Internal signals
	logic start;
	logic finish;

	//Init
	initial
	begin
					
		clk 					= 1'b0;
		rstn					= 1'b0;
		
		eca_en					= 1'b0;
		engine_en				= 1'b0;
		m_val					= 2'b00;
		m_val_wr				= 1'b0;
		
		bmu_bm_mux_sel_reg_wr	= 1'b0;
		and_mask_mask_reg_wr	= 1'b0;
		
		user_bm_mem_wr_req		= 1'b0;
		
		inbuf_wr_req			= 1'b0;
		
		//////////////////////////////////////////////////////
		
		#(4*CLK_CYCLE)	// rise rstn
		
		rstn			 = 1'b1;
		
		//////////////////////////////////////////////////////
		
		#(4*CLK_CYCLE)	//write to bitmatrix memory ,M value
		
		user_bm_mem_wr_req		= 1'b1;
		m_val_wr				= 1'b1;
		m_val					= 2'b10;	// m = 2
		
		//////////////////////////////////////////////////////
		
		#(4*CLK_CYCLE)	//write to bm and mask registers
		
		bmu_bm_mux_sel_reg_wr	= 1'b1;
		and_mask_mask_reg_wr	= 1'b1;
		
		//////////////////////////////////////////////////////
		
		#(4*CLK_CYCLE)	//write data to inbuffer

		inbuf_wr_req			= 1'b1;
		 
		 //////////////////////////////////////////////////////
		
		#(4*CLK_CYCLE)	//rise enable signals
		
		eca_en					= 1'b1;
		engine_en				= 1'b1;
		
		//////////////////////////////////////////////////////
		
		 
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
 
	eca_top #(
	.K_MAX(K_MAX), .K_MIN(K_MIN), .W(W), .PACKET_LENGTH(PACKET_LENGTH), .BM_MULT_UNIT_NUM(BM_MULT_UNIT_NUM) 
	)engine_top_i(
	
	//input
	.clk(clk)
	,.rstn(rstn)
	,.eca_en(eca_en)
	,.engine_en(engine_en)
	,.m_val(m_val)
	,.m_val_wr(m_val_wr)
	
	//input from user - TEMP
	,.bmu_bm_mux_sel_reg_wr(bmu_bm_mux_sel_reg_wr)
	,.bmu_bm_mux_sel_reg_din(bmu_bm_mux_sel_reg_din)

	,.and_mask_mask_reg_wr(and_mask_mask_reg_wr)
	,.and_mask_mask_reg_din(and_mask_mask_reg_din)

	//bitmatrix memory user IF:
	,.user_bm_mem_wr_req(user_bm_mem_wr_req)
	,.user_bm_mem_wr_data(user_bm_mem_wr_data)
	,.user_bm_mem_wr_addr(user_bm_mem_wr_addr)

	//input buffer IF:
	,.inbuf_wr_req(inbuf_wr_req)
	,.inbuf_wr_data(inbuf_wr_data)

	//output buffer IF:
	,.outbuf_rd_req(outbuf_rd_req)
	,.outbuf_rd_data_val(outbuf_rd_data_val)
	,.outbuf_rd_data(outbuf_rd_data)
	
	);


 // ================================================
 // ~~~~~~~~~~ test bench logic ~~~~~~~~~~
 // ================================================

 //Init
 initial
 begin
	
	//logic [BMU_BM_MUX_SEL_W-1:0] bmu_bm_mux_sel_reg_din [0:BM_MULT_UNIT_NUM-1];
	
	bmu_bm_mux_sel_reg_din[0] = {1'b0, 1'b0};
	bmu_bm_mux_sel_reg_din[1] = {1'b0, 1'b1};
	bmu_bm_mux_sel_reg_din[2] = {1'b0, 1'b0};
	bmu_bm_mux_sel_reg_din[3] = {1'b0, 1'b1};
	
	//logic [K_MAX-1:0] and_mask_mask_reg_din [0:PCK_TREE_XOR_UNITS_NUM-1];
	
	and_mask_mask_reg_din[0] = {1'b0, 1'b0 , 1'b1 , 1'b1 };
	and_mask_mask_reg_din[1] = {1'b0, 1'b0 , 1'b1 , 1'b1 };

	//bitmatrix memory user IF:
	//logic [BM_MEM_W-1:0] user_bm_mem_wr_data;
	
	user_bm_mem_wr_data = { 1'b0, 1'b0 , 1'b1 , 1'b1,
							1'b0, 1'b1 , 1'b0 , 1'b0,
							1'b1, 1'b0 , 1'b0 , 1'b0,
							1'b1, 1'b0 , 1'b1 , 1'b0,
							
							1'b0, 1'b0 , 1'b0 , 1'b1,
							1'b0, 1'b1 , 1'b1 , 1'b1,
							1'b0, 1'b1 , 1'b0 , 1'b1,
							1'b0, 1'b0 , 1'b0 , 1'b0,
							
							1'b0, 1'b0 , 1'b1 , 1'b1,
							1'b0, 1'b1 , 1'b1 , 1'b1,
							1'b1, 1'b0 , 1'b0 , 1'b0,
							1'b0, 1'b0 , 1'b0 , 1'b1,
							
							1'b0, 1'b0 , 1'b1 , 1'b0,
							1'b1, 1'b1 , 1'b1 , 1'b0,
							1'b0, 1'b1 , 1'b1 , 1'b1,
							1'b1, 1'b0 , 1'b1 , 1'b1};
										 
 end
 
 //-----------------------------------
 //Memory address and data
 //-----------------------------------
 

 logic [INBUF_DATA_W-1:0] data1 = {INBUF_DATA_W{1'b0}};
 logic [INBUF_DATA_W-1:0] data2 = {INBUF_DATA_W{1'b1}};
 logic [INBUF_DATA_W-1:0] data3 = { 1'b1, 1'b1 , 1'b1 , 1'b1,
									1'b1, 1'b1 , 1'b1 , 1'b0,
									1'b1, 1'b0 , 1'b1 , 1'b0,
									1'b0, 1'b0 , 1'b1 , 1'b0,
							
									1'b0, 1'b0 , 1'b0 , 1'b1,
									1'b0, 1'b0 , 1'b0 , 1'b1,
									1'b1, 1'b0 , 1'b0 , 1'b0,
									1'b0, 1'b0 , 1'b0 , 1'b1};
 
 always @(posedge clk or negedge rstn)
 begin
	if(~rstn) begin
		user_bm_mem_wr_addr <= {BM_MEM_ADDR_W{1'b0}};
		inbuf_wr_data <= {INBUF_DATA_W{1'b0}};
	end
	 
	else begin
	
		user_bm_mem_wr_addr <= user_bm_mem_wr_addr + 1;
		
		case(inbuf_wr_data)

			data1:	
			begin
				inbuf_wr_data <= data2;
			end

			data2:
			begin
				inbuf_wr_data <= data3;
			end
			
			data3:
			begin
				inbuf_wr_data <= data1;
			end
		
		endcase
	end

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

 always @(posedge clk or negedge rstn)
 begin
	 if(~rstn)
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
