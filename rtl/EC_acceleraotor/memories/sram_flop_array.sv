//=====================================================================================================
//
// Module: sram  like flop array
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


//Notes:

//TODO list:

//======================================================================================================
////######################################### MODULE ####################################################

module sram_flop_array#(

//=================================
//  user parameters 
//=================================
	parameter SRAM_WRAP_WIDTH = 32,//defines the 2 ports combined width, have to be a complete multp of 2
	parameter SRAM_WRAP_DEPTH = 100, //num of sramwidth rows

//=================================
//  local parameters (DON'T CHANGE)
//=================================

	parameter SRAM_WRAP_ADDR_W = $clog2(SRAM_WRAP_DEPTH),
	parameter INT_MEM_W = SRAM_WRAP_WIDTH/2,
	parameter INT_MEM_DEPTH = 2*SRAM_WRAP_DEPTH,
	parameter INT_MEM_ADDR_W = SRAM_WRAP_ADDR_W + 1

)(
//===========
//  inputs:
//===========

input [INT_MEM_W-1:0] I1,
input [INT_MEM_W-1:0] I2,

output reg [INT_MEM_W-1:0] O1,
output reg [INT_MEM_W-1:0] O2,


input CEB1,
input WEB1,
input OEB1,
input CSB1,
input CEB2,
input WEB2,
input OEB2,
input CSB2,

input [INT_MEM_ADDR_W-1:0] A1,
input [INT_MEM_ADDR_W-1:0] A2

);

//======================
//  signals declaration:
//======================

logic port_1_rd_en;
logic port_2_rd_en;
logic port_1_wr_en;
logic port_2_wr_en;


logic [INT_MEM_W-1:0] mem [INT_MEM_DEPTH-1:0];

//======================
//  logic:
//======================


assign port_1_rd_en =  ~CSB1 & WEB1 & ~OEB1;
assign port_2_rd_en =  ~CSB2 & WEB2 & ~OEB2;
assign port_1_wr_en =  ~CSB1 &~WEB1;
assign port_2_wr_en =  ~CSB2 &~WEB2;



always_ff @( posedge CEB1  ) begin
    if(port_1_rd_en) begin
		O1 <= mem[A1];
	end
end//always_ff



always_ff @( posedge CEB2 ) begin
    if(port_2_rd_en) begin
		O2 <= mem[A2];
	end
end//always_ff


always_ff @( posedge CEB1 ) begin
    if(port_2_wr_en & ~port_2_rd_en) begin
        mem[A2] <= I2;
    end
    if(port_1_wr_en & ~port_1_rd_en) begin
        mem[A1] <= I1;
    end

end//always_ff




endmodule
