//=====================================================================================================
//
// Module: sram wrapper
//
// Description
// ===========
// 
// 
// changes the sram IF to rd/wr_req + data_val
//
//  
//======================================================================================================

// Sub Modules:
//  - sram


//Notes:

// - assumption: rd_req and wr_req are not 1'b1 together

//TODO list:

//======================================================================================================
////######################################### MODULE ####################################################

module sram_wrapper #(

//=================================
//  user parameters 
//=================================
	parameter SRAM_WRAP_WIDTH = 32,//defines the 2 ports combined width, have to be a complete multp of 2
	parameter SRAM_WRAP_DEPTH = 100, //num of sramwidth rows

//=================================
//  local parameters (DON'T CHANGE)
//=================================

	parameter SRAM_WRAP_ADDR_W = $clog2(SRAM_DEPTH),
	parameter INT_MEM_W = SRAM_WRAP_WIDTH/2,
	parameter INT_MEM_DEPTH = SRAM_WRAP_DEPTH,
	parameter INT_MEM_ADDR_W = SRAM_WRAP_ADDR_W + 1

)(
//===========
//  inputs:
//===========

input clk,
input_rst_n,

input mem_en,
input rd_req,
input wr_req,
input [SRAM_WRAP_ADDR_W-1:0] address,
input [SRAM_WRAP_WIDTH-1:0] wr_data_in,

//===========
//  outputs:
//===========

output rd_data_val,
output [SRAM_WRAP_WIDTH-1:0] rd_data
);

//======================
//  signals declaration:
//======================

logic [INT_MEM_W-1:0] I1;
logic [INT_MEM_W-1:0] I2;

logic [INT_MEM_W-1:0] O1;
logic [INT_MEM_W-1:0] O2;

//internal memory control

logic CEB1;
logic WEB1;
logic OEB1;
logic CSB1;
logic CEB2;
logic WEB2;
logic OEB2;
logic CSB2;

logic [INT_MEM_ADDR_W-1:0] A1;
logic [INT_MEM_ADDR_W-1:0] A2;


//==============================
//  control IF change:
//==============================

assign A1 = {address,1'b0};
assign A2 = {address,1'b1};

assign rd_data = {O1,O2};

assign I1 = wr_data_in[INT_MEM_W-1:0];
assign I2 = wr_data_in[2*INT_MEM_W-1:INT_MEM_W];

assign CEB1 = clk;//TODO - check this - should work on clk negedge?
assign CEB2 = clk;//TODO - check this - should work on clk negedge? 

assign CSB1 = ~mem_en;
assign CSB2 = ~mem_en;
assign OEB1 = ~mem_en;
assign OEB2 = ~mem_en;


assign WEB1 = ~wr_req & rd_req;
assign WEB2 = ~wr_req & rd_req;

always_ff @( posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		rd_data_val <= 1'b0;
	end else begin
		rd_data_val <= rd_req;
	end//else
end//always_ff



//==============================
//  submodules instantinations:
//==============================



//TODO instantiate sram






endmodule





