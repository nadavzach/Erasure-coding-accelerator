//=====================================================================================================
//
// Module: sram_fifo
//
// Description
// ===========
// fifo with sram as memory.
//
// 
// 
//
//  
//======================================================================================================

// Sub Modules:
//  - sram_wrapper_i


//Notes:

// wr & rd together arn't supported.priority will be given to read
// last data is always ready, the second one will take 1 clk cycle delay. can be fixed with another samp reg level, should be OK for this project.

//TODO list:
//======================================================================================================
////######################################### MODULE ####################################################

module sram_fifo #(

//=================================
//  user parameters 
//=================================
	parameter SRAM_WRAP_WIDTH = 32,//defines the 2 ports combined width, have to be a complete multp of 2
	parameter SRAM_WRAP_DEPTH = 100, //num of sramwidth rows



//=================================
//  local parameters (DON'T CHANGE)
//=================================

	parameter SRAM_ADDR_W = $clog2(SRAM_WRAP_DEPTH)



)(
//===========
//  inputs:
//===========

input clk,
input rst_n,

input wr_req,
input rd_req,

input mem_en,
input [SRAM_WRAP_WIDTH-1:0] wr_data_in,



//===========
//  outputs:
//===========

output rd_data_val,
output [SRAM_WRAP_WIDTH-1:0] rd_data,
 output wr_ack,
//status:

output full,
output empty

);

//======================
//  signals declaration:
//======================

logic wr_req_l ;

logic [SRAM_ADDR_W:0] wptr;
logic [SRAM_ADDR_W:0] rptr;

logic [SRAM_WRAP_WIDTH-1:0] dout_samp_reg_0;
logic [SRAM_WRAP_WIDTH-1:0] dout_samp_reg_1;
logic dout_samp_reg_0_val;
logic dout_samp_reg_1_val;

//sram control:
logic sram_wr_req;
logic sram_rd_req;
logic [SRAM_ADDR_W-1:0] sram_addr;
logic [SRAM_WRAP_WIDTH-1:0] sram_dout;
logic sram_dout_val;
//dout samp reg control:
logic wr_sram_dout_to_samp_reg_0; 
logic wr_sram_dout_to_samp_reg_1; 
logic wr_din_to_samp_reg_0;		
logic wr_din_to_samp_reg_1;		
logic wr_samp_reg_1_to_0;

logic samp_reg_0_nxt;
logic samp_reg_1_nxt;
//======================
// module logic:
//======================

assign rd_data = dout_samp_reg_0;
assign rd_data_val = dout_samp_reg_0_val;
assign wr_ack = sram_wr_req || wr_din_to_samp_reg_0 || wr_din_to_samp_reg_1;
assign wr_req_l = wr_req & ~rd_req;
// sram control  logic:


assign ptrs_eq = (rptr[SRAM_ADDR_W-1:0] == wptr[SRAM_ADDR_W-1:0]);
assign ptrs_tu_bit_eq = (rptr[SRAM_ADDR_W] == wptr[SRAM_ADDR_W]);

assign sram_full  = ptrs_eq & ~ptrs_tu_bit_eq;
assign sram_empty = ptrs_eq & ptrs_tu_bit_eq;

assign sram_addr = (sram_rd_req ? rptr[SRAM_ADDR_W-1:0] : wptr[SRAM_ADDR_W-1:0]);

assign sram_rd_req = rd_req & ~sram_empty;
assign sram_wr_req = wr_req_l & ~sram_full & ~wr_din_to_samp_reg_0 & ~wr_din_to_samp_reg_1 & ~sram_rd_req;

assign samp_reg_0_nxt = (dout_samp_reg_0_val & ~rd_req) | (wr_sram_dout_to_samp_reg_0 | wr_din_to_samp_reg_0 | wr_samp_reg_1_to_0);
assign samp_reg_1_nxt = (dout_samp_reg_1_val & ~wr_samp_reg_1_to_0) | ( wr_sram_dout_to_samp_reg_1| wr_din_to_samp_reg_1  );


assign full = sram_full & dout_samp_reg_0_val & dout_samp_reg_1_val;
assign empty = sram_empty & ~dout_samp_reg_0_val & ~dout_samp_reg_1_val;


// sampled register 0 :

assign wr_sram_dout_to_samp_reg_0 = sram_dout_val & ~dout_samp_reg_1_val & (~dout_samp_reg_0_val || rd_req);
assign wr_din_to_samp_reg_0	      = wr_req_l & ~dout_samp_reg_0_val ;
assign wr_samp_reg_1_to_0         = rd_req & dout_samp_reg_1_val ;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		dout_samp_reg_0_val	<=	1'b0;
	end else begin
		if(wr_sram_dout_to_samp_reg_0 | wr_din_to_samp_reg_0 | wr_samp_reg_1_to_0 ) begin
			dout_samp_reg_0_val	<=	1'b1;
		end else begin
			if(rd_req) begin
				dout_samp_reg_0_val	<=	1'b0;
			end
		end
	end
end



always_ff @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
		dout_samp_reg_0	<=	{SRAM_WRAP_WIDTH{1'b0}};
	end else begin
		if(wr_sram_dout_to_samp_reg_0) begin
			dout_samp_reg_0	<=	sram_dout;
		end else begin
			if(wr_din_to_samp_reg_0) begin
				dout_samp_reg_0	<=	wr_data_in;
			end else begin
                if(wr_samp_reg_1_to_0) begin
				    dout_samp_reg_0	<=	dout_samp_reg_1;
                end
            end
		end
	end
end

// sampled register 1 :

assign wr_sram_dout_to_samp_reg_1 = sram_dout_val & (~dout_samp_reg_1_val || wr_samp_reg_1_to_0);
assign wr_din_to_samp_reg_1	      = wr_req_l & dout_samp_reg_0_val & ~dout_samp_reg_1_val & ~wr_sram_dout_to_samp_reg_1 & ~wr_sram_dout_to_samp_reg_1 ;

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		dout_samp_reg_1_val	<=	1'b0;
	end else begin
		if(wr_sram_dout_to_samp_reg_1 | wr_din_to_samp_reg_1 ) begin
			dout_samp_reg_1_val	<=	1'b1;
		end else begin
			if(wr_samp_reg_1_to_0) begin
				dout_samp_reg_1_val	<=	1'b0;
			end
		end
	end
end



always_ff @(posedge clk or negedge rst_n) begin
if(~rst_n) begin
		dout_samp_reg_1	<=	{SRAM_WRAP_WIDTH{1'b0}};
	end else begin
		if(wr_sram_dout_to_samp_reg_1) begin
			dout_samp_reg_1	<=	sram_dout;
		end else begin
			if(wr_din_to_samp_reg_1) begin
				dout_samp_reg_1	<=	wr_data_in;
			end
		end
	end
end




// rptr:


always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		rptr	<=	{SRAM_ADDR_W{1'b0}};
	end else begin
		if(sram_rd_req ) begin
			if(rptr[SRAM_ADDR_W-1:0] == {SRAM_ADDR_W-1{1'b1}}) begin
				rptr[SRAM_ADDR_W-1:0]	<=  {SRAM_ADDR_W-1{1'b0}};
				rptr[SRAM_ADDR_W]		<=	~rptr[SRAM_ADDR_W];
			end else begin
				rptr[SRAM_ADDR_W-1:0] <= rptr[SRAM_ADDR_W-1:0] + 1'b1;
			end
		end
	end
end

// wptr:

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		wptr	<=	{SRAM_ADDR_W{1'b0}};
	end else begin
		if(sram_wr_req) begin
			if(wptr[SRAM_ADDR_W-1:0] == {SRAM_ADDR_W-1{1'b1}}) begin
				wptr[SRAM_ADDR_W-1:0]	<=  {SRAM_ADDR_W-1{1'b0}};
				wptr[SRAM_ADDR_W]		<=	~wptr[SRAM_ADDR_W];
			end else begin
				wptr[SRAM_ADDR_W-1:0] <= wptr[SRAM_ADDR_W-1:0] + 1'b1;
			end
		end
	end
end
  

//==============================
//  submodules instantinations:
//==============================

sram_wrapper #(
	.SRAM_WRAP_WIDTH(SRAM_WRAP_WIDTH)
	,.SRAM_WRAP_DEPTH(SRAM_WRAP_DEPTH) 
)
sram_wrapper_fifo_i
(
	.clk(clk)
	,.rst_n(rst_n)
	
	,.mem_en(mem_en)
	,.rd_req(sram_rd_req)
	,.wr_req(sram_wr_req)
	,.address(sram_addr)
	,.wr_data_in(wr_data_in)
	
	,.rd_data_val(sram_dout_val)
	,.rd_data(sram_dout)
);


endmodule
