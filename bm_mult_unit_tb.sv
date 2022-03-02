/*------------------------------------------------------------------------------
 * File          : bm_mult_unit_tb.sv
 * Project       : RTL
 * Author        : epodnz
 * Creation date : Jan 13, 2022
 * Description   : Test bench for the bm_mult_unit module
 *------------------------------------------------------------------------------*/

module bm_mult_unit_tb#(

	//------------------------------------------
	//--- Interface Parameters:
	//------------------------------------------
	
	  
	parameter K_MAX = 128,
	parameter K_MIN = 2,
	parameter M_MAX = 128,
	parameter M_MIN = 2,
	parameter W = 4,
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

	 logic [PACKET_LENGTH-1:0] data_packet [0:W-1];

	 logic [PACKET_LENGTH-1:0] mult_product [0:W-1];

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
 // Instantiation -  bm mult unit
 //******************************************
 bm_mult_unit dut (

 .bitmatrix_cols(bitmatrix_cols), 
 .data_packet(data_packet),
 .mult_product(mult_product)

 );
 //input dly assignment 
 //******************************************
 //assign #IF_DLY <signal name>_dly = <signal name>;
	
	 

 // ================================================
 // ~~~~~~~~~~ test bench logic ~~~~~~~~~~
 // ================================================

 int i;


 //Init
 initial
 begin
  bitmatrix_cols[0] = {1'b1,1'b1,1'b0,1'b1} ;
  bitmatrix_cols[1] = {1'b0,1'b1,1'b1,1'b1} ;
  bitmatrix_cols[2] = {1'b0,1'b0,1'b0,1'b1} ;
  bitmatrix_cols[3] = {1'b1,1'b1,1'b1,1'b1} ;

  data_packet[0] = {1'b1,1'b0};
  data_packet[1] = {1'b0,1'b1};
  data_packet[2] = {1'b0,1'b1};
  data_packet[3] = {1'b1,1'b1};



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
