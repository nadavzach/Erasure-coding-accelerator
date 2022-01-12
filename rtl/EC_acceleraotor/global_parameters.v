// global parameters across the design:

parameter BM_MULT_UNIT_NUM = 264,
parameter K_MAX = 128,
parameter K_MIN = 2,
parameter M_MAX = 128,
parameter M_MIN = 2,
parameter W = 4,
parameter PACKET_LENGTH =  2,



//bitmatrix memory parameters:
parameter BM_MEM_DEPTH = M_MAX,
parameter BM_COL_W = W*W*K_MAX,
parameter BM_MEM_W = BM_COLOUMN_W,
parameter BM_MEM_ADDR_W = $clog2(BM_MEM_W),


//engine parameters

parameter PCK_TREE_XOR_UNITS_NUM = BM_MULT_UNIT_NUM / K_MIN;

//output buffer parameters:

parameter OUTBUF_MEM_WIDTH  = PACKET_LENGTH*W*PCK_TREE_XOR_UNITS_NUM,
parameter OUTBUF_MEM_DEPTH  = 100,//TODO - set
parameter OUTBUF_MEM_ADDR_W = $clog2(OUTBUF_MEM_DEPTH);