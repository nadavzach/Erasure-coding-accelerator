/*------------------------------------------------------------------------------
 * File          : bm_mult_unit_tb.sv
 * Project       : RTL
 * Author        : epodnz
 * Creation date : Jan 13, 2022
 * Description   : Test bench for the bm_mult_unit module
 *------------------------------------------------------------------------------*/

module partial_engine_tb#(

	//------------------------------------------
	//--- Interface Parameters:
	//------------------------------------------
	
	  
	parameter K_MAX = 8,
	parameter K_MIN = 2,
	parameter W = 4,
	parameter K = 2,
	parameter PACKET_LENGTH =  2, 


	//------------------------------------------
	//---testbench Parameters:
	//------------------------------------------

	parameter CLK_CYCLE = 2
	
	);
 
	 //General
	 logic          clk;
	 logic          rst_n;

	 //Internal signals
	 logic start;
	 logic finish;
	 //logics:
	 logic [W-1:0] bitmatrix_cols [0:W-1];

	 logic [PACKET_LENGTH-1:0] data_packet [0:K-1][0:W-1];

	 logic [PACKET_LENGTH-1:0] mult_product [0:K_MAX-1][0:W-1];
	
	 logic [PACKET_LENGTH-1:0] mult_product_transposed [0:W-1][0:K_MAX-1];
	 
	 logic [PACKET_LENGTH-1:0] mask		[0:W-1][0:K_MAX-1];
	
	 logic [PACKET_LENGTH-1:0] mask_product [0:W-1][0:K_MAX-1];
	 
	 logic [PACKET_LENGTH-1:0] result [0:W-1];

	//******************************************
	//  output for TB and debugging
	//******************************************

	 //Init
	 initial
	 begin
		 clk		    	 <= 1'b0;
		 
		  #(30*CLK_CYCLE) 
		 finish = 1'b1;
	 
	 end

  //#################################################            
 // ================================================
 // ~~~~~~~~~~ Instantiations ~~~~~~~~~~
 // ================================================
 //#################################################
					
 //******************************************
 // Instantiation -  partial_engine
 //******************************************

	genvar i, j, w, k;
	generate

	for(i=0; i < K; i=i+1) begin
		bm_mult_unit #(
		.K_MAX(K_MAX), .K(K)
		)bm_mult_unit_i(
		//input
		.bitmatrix_cols(bitmatrix_cols), 
		.data_packet(data_packet[i]),

		//output
		.mult_product(mult_product[i])
		);
	end

	//Transpose the mult_product matrix
	for(w=0; w < W; w=w+1) begin
		for(k=0; k < K_MAX; k=k+1) begin
			assign mult_product_transposed[w][k] = mult_product[k][w];
		end
	end

	endgenerate


	mask_unit #(
	.K_MAX(K_MAX), .K(K)
	)mask_unit_i(
	//input
	.packets(mult_product_transposed), 
	.mask(mask),

	//output
	.mask_product(mask_product)
	);
	
	
	packet_tree_xor #(
	.K_MAX(K_MAX), .K(K)
	)packet_tree_i(
	//input
	.packets(mask_product), 

	//output
	.xor_product(result)
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

  bitmatrix_cols[0] = {1'b1,1'b1,1'b0,1'b1} ;
  bitmatrix_cols[1] = {1'b0,1'b1,1'b1,1'b1} ;
  bitmatrix_cols[2] = {1'b0,1'b0,1'b0,1'b1} ;
  bitmatrix_cols[3] = {1'b1,1'b1,1'b1,1'b1} ;

  data_packet[0][0] = {1'b1,1'b0};
  data_packet[0][1] = {1'b0,1'b1};
  data_packet[0][2] = {1'b0,1'b1};
  data_packet[0][3] = {1'b1,1'b1};

  data_packet[1][0] = {1'b1,1'b1};
  data_packet[1][1] = {1'b1,1'b0};
  data_packet[1][2] = {1'b0,1'b0};
  data_packet[1][3] = {1'b1,1'b1};

  mask[0][0] = {1'b1,1'b1};
  mask[0][1] = {1'b1,1'b1};
  mask[0][2] = {1'b0,1'b0};
  mask[0][3] = {1'b0,1'b0};
  mask[0][4] = {1'b0,1'b0};
  mask[0][5] = {1'b0,1'b0};
  mask[0][6] = {1'b0,1'b0};
  mask[0][7] = {1'b0,1'b0};

  mask[1][0] = {1'b1,1'b1};
  mask[1][1] = {1'b1,1'b1};
  mask[1][2] = {1'b0,1'b0};
  mask[1][3] = {1'b0,1'b0};
  mask[1][4] = {1'b0,1'b0};
  mask[1][5] = {1'b0,1'b0};
  mask[1][6] = {1'b0,1'b0};
  mask[1][7] = {1'b0,1'b0};
  
  mask[2][0] = {1'b1,1'b1};
  mask[2][1] = {1'b1,1'b1};
  mask[2][2] = {1'b0,1'b0};
  mask[2][3] = {1'b0,1'b0};
  mask[2][4] = {1'b0,1'b0};
  mask[2][5] = {1'b0,1'b0};
  mask[2][6] = {1'b0,1'b0};
  mask[2][7] = {1'b0,1'b0};
  
  mask[3][0] = {1'b1,1'b1};
  mask[3][1] = {1'b1,1'b1};
  mask[3][2] = {1'b0,1'b0};
  mask[3][3] = {1'b0,1'b0};
  mask[3][4] = {1'b0,1'b0};
  mask[3][5] = {1'b0,1'b0};
  mask[3][6] = {1'b0,1'b0};
  mask[3][7] = {1'b0,1'b0};

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
