
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
			  PACKET_LENGTH =  8,
			  M_MAX = 8,
			  M_MIN = 2,

			  BM_MULT_UNIT_NUM = 4,
			  PCK_TREE_XOR_UNITS_NUM = BM_MULT_UNIT_NUM / K_MIN,
			  BMU_BM_MUX_SEL_W		 = $clog2(K_MAX),
			  OUTBUF_MEM_DEPTH       = 60,
              INBUF_DATA_DEPTH       = 60,

	//bitmatrix memory parameters:

			  BM_MEM_DEPTH = M_MAX,
			  BM_COL_W = W*W*K_MAX,
			  BM_MEM_W = BM_COL_W,
			  BM_MEM_ADDR_W = $clog2(BM_MEM_DEPTH),
	
	          OUTBUF_DATA_W             = PACKET_LENGTH*W*PCK_TREE_XOR_UNITS_NUM,
			  INBUF_DATA_W = W*PACKET_LENGTH*BM_MULT_UNIT_NUM,

    // TB PARAMS:          
    parameter SIMPLE_TEST = 0,
	parameter CLK_CYCLE = 2,
	parameter WRITE_CHANCE_PER = 50, // out of 100
    parameter READ_CHANCE_PER = 50, // out of 100
    parameter STOP_ENG_CHANCE_PER = 0, // out of 100
    parameter SIM_CLK_NUM = 150,
    parameter MAX_INBUF_DATA = 100

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
	logic [BM_MEM_W-1:0] and_mask_mask_reg_din [0:PCK_TREE_XOR_UNITS_NUM-1];

	//bitmatrix memory user IF:
	logic user_bm_mem_wr_req;
	logic [BM_MEM_W-1:0] user_bm_mem_wr_data;
	logic [BM_MEM_W-1:0] user_bm_mem_wr_data_1;
	logic [BM_MEM_W-1:0] user_bm_mem_wr_data_2;
	logic [BM_MEM_W-1:0] user_bm_mem_wr_data_3;
	logic [BM_MEM_W-1:0] user_bm_mem_wr_data_4;
	logic [BM_MEM_ADDR_W-1:0] user_bm_mem_wr_addr;

	//input buffer IF:
	logic inbuf_wr_req;
    logic inbuf_user_wr_ack;
	logic [INBUF_DATA_W-1:0] inbuf_wr_data;
    logic inbuf_user_full;
	logic [INBUF_DATA_W-1:0] data1;
	logic [INBUF_DATA_W-1:0] data2;
	logic [INBUF_DATA_W-1:0] data3;
	logic [INBUF_DATA_W-1:0] data4;
	logic [INBUF_DATA_W-1:0] data5;

	//output buffer IF:
	logic outbuf_rd_req;
	logic outbuf_rd_data_val;
	logic [OUTBUF_DATA_W-1:0] outbuf_rd_data;
    logic outbuf_user_rd_ack;
	
    // TEST BENCH signals:
    
    logic inbuf_user_wr_ack_reg;
    logic outbuf_user_rd_ack_reg;
    logic outbuf_rd_data_val_reg;
    logic tried_to_wr;
    logic tried_to_rd;
    logic [OUTBUF_DATA_W-1:0] sim_output_arr [$];
    // read & write file
    int iter,fd,fd_w,i,j;
    string line;

    // control
	logic start;
	logic finish;
    int stop_eng;
    int m_val_int;
    int line_len,m,inbuf_data_count,inbuf_data_count_idx; 
    int inbuf_wr_data_arr_init_size;
    int sim_write; // rand
    int sim_read; // rand
    
	logic [BM_MEM_W-1:0] user_bm_mem_wr_data_arr [M_MAX];
	logic [INBUF_DATA_W-1:0] inbuf_wr_data_arr [MAX_INBUF_DATA];



    ///////////////////////////////////////////////////////////
    ///////////////////// SIM FLOW 
    ///////////////////////////////////////////////////////////
	initial
	begin

    //if(SIMPLE_TEST) begin
	//				
	//	clk 					= 1'b0;
	//	rstn					= 1'b0;
	//	
	//	eca_en					= 1'b0;
	//	engine_en				= 1'b0;
	//	m_val					= 3'b000;
	//	m_val_wr				= 1'b0;
	//	
	//	bmu_bm_mux_sel_reg_wr	= 1'b0;
	//	and_mask_mask_reg_wr	= 1'b0;
	//	
	//	user_bm_mem_wr_req		= 1'b0;
	//	
	//	inbuf_wr_req			= 1'b0;
	//	
   	//    user_bm_mem_wr_addr     = {BM_MEM_ADDR_W{1'b0}};

	//	outbuf_rd_req           = 1'b0;
	//	//////////////////////////////////////////////////////
	//	
	//	#(4*CLK_CYCLE)	// rise rstn
	//	
	//	rstn			 = 1'b1;
	//	
	//	//////////////////////////////////////////////////////
	//	
	//	#(4*CLK_CYCLE)	//write to bitmatrix memory ,M value
	//	
	//	user_bm_mem_wr_req		= 1'b1;
	//	m_val_wr				= 1'b1;
	//	m_val					= 3'b100;	// m = 2
    //    user_bm_mem_wr_data     = user_bm_mem_wr_data_1;

	//	#(1*CLK_CYCLE)	
	//	user_bm_mem_wr_addr     = user_bm_mem_wr_addr + 1'b1;
	//	m_val_wr				= 1'b0;

	//	#(1*CLK_CYCLE)	
	//	user_bm_mem_wr_addr     = user_bm_mem_wr_addr + 1'b1;
    //    user_bm_mem_wr_data     = user_bm_mem_wr_data_2;

	//	#(1*CLK_CYCLE)	
	//	user_bm_mem_wr_addr     = user_bm_mem_wr_addr + 1'b1;
    //    user_bm_mem_wr_data     = user_bm_mem_wr_data_3;

	//	#(1*CLK_CYCLE)	
	//	user_bm_mem_wr_addr     = user_bm_mem_wr_addr + 1'b1;
    //    user_bm_mem_wr_data     = user_bm_mem_wr_data_4;


	//	#(1*CLK_CYCLE)	
	//	user_bm_mem_wr_req		= 1'b0;

	//		//////////////////////////////////////////////////////
	//	
	//	#(4*CLK_CYCLE)	//write to bm mult unit mux sel and mask registers
	//	
	//	bmu_bm_mux_sel_reg_wr	= 1'b1;
	//	and_mask_mask_reg_wr	= 1'b1;
	//	
	//	//////////////////////////////////////////////////////
	//	
	//	#(4*CLK_CYCLE)	//write data to inbuffer

	//	inbuf_wr_req			= 1'b1;
	//	inbuf_wr_data           = data1;

	//	#(1*CLK_CYCLE)	//write data to inbuffer
	//	inbuf_wr_data           = data2;

	//	#(1*CLK_CYCLE)	//write data to inbuffer
	//	inbuf_wr_data           = data3;
	//	#(1*CLK_CYCLE)	//write data to inbuffer
	//	inbuf_wr_data           = data4;

    //    #(1*CLK_CYCLE)	//write data to inbuffer
	//	inbuf_wr_data           = data5;

	//	#(1*CLK_CYCLE)	//write data to inbuffer
	//	inbuf_wr_req			= 1'b0;



	//	 //////////////////////////////////////////////////////
	//	
	//	#(4*CLK_CYCLE)	//rise enable signals
	//	
	//	eca_en					= 1'b1;
	//	engine_en				= 1'b1;
	//	
	//	//////////////////////////////////////////////////////

	//	#(14*CLK_CYCLE)	//rise enable signals
	//	outbuf_rd_req           = 1'b1;

	//	 
	//	#(30*CLK_CYCLE)
	//	
	//	finish = 1'b1;


    //end else begin // RAND_TEST 
        // read test setup file:
        // default values:
	    clk                                = 1'b0;                                                                    
	    rstn                               = 1'b0;                                                                     
	    eca_en                             = 1'b0;                                                                       
	    engine_en                          = 1'b0;                                                                          
	    m_val                              = {$clog2(M_MAX){1'b0}};                                                                      
	    m_val_wr                           = 1'b0;                                                                         
	    
	    //input from user - TEMP
	    bmu_bm_mux_sel_reg_wr              = 1'b0;                                                                                      
	    bmu_bm_mux_sel_reg_din             = '{default:0};                                                                                       

	    and_mask_mask_reg_wr               = 1'b0;                                                                                     
	    and_mask_mask_reg_din              = '{default:0};                                                                                      

	    //bitmatrix memory user IF:
	    user_bm_mem_wr_req                 = 1'b0;                                                                                   
	    user_bm_mem_wr_data                = {BM_MEM_W{1'b0}};                                                                                    
	    user_bm_mem_wr_addr                = 1'b0;                                                                                    

	    //input buffer IF:
	    inbuf_wr_req                       = 1'b0;                                                                             
	    inbuf_wr_data                      = {INBUF_DATA_W{1'b0}};                                                                              

	    //output buffer IF:
	    outbuf_rd_req                      = 1'b0;                                                                              

        // step 0 - reset

	    #(5*CLK_CYCLE)	

        rstn    =   1'b1;

	    #(5*CLK_CYCLE)	

	    eca_en  =   1'b1;                                                                       

	    #(5*CLK_CYCLE)	
        fd = $fopen("/nfs/iil/proj/perc/percsi_users3/eng/nzaharia/bpu/bpu_a0/results/sim_setup.txt","r");
        i = 0;
        while(!$feof(fd)) begin
            $fgets(line,fd);

            if(line == "m value\n") begin // m value
                $fgets(line,fd);
                m_val = line.atobin();
            end

            if(line == "bitmatrix data start\n") begin // m value
                $fgets(line,fd);
                j=0;
                while(line != "bitmatrix data end\n") begin
                    line_len = line.len();
                    if(line_len > 33) begin
                        for(m = 0;m<(line_len/32);m=m+1) begin
                            user_bm_mem_wr_data_arr[j][m*32+:32]= (line.substr(m*32,m*32+31).atobin());
                        end
                    end else begin
                        user_bm_mem_wr_data_arr[j]= (line.atobin());
                    end
                    j=j+1;
                    $fgets(line,fd);
                end
            end
            if(line == "input buffer data start\n") begin // m value
                $fgets(line,fd);
                inbuf_data_count=0;
                while(line != "input buffer data end\n") begin
                    line_len = line.len();
                    if(line_len > 33) begin
                        for(m = 0;m<(line_len/32);m=m+1) begin
                            inbuf_wr_data_arr[inbuf_data_count][m*32+:32]= (line.substr(m*32,m*32+31).atobin());
                        end
                    end else begin
                        inbuf_wr_data_arr[inbuf_data_count]= (line.atobin());
                    end
                    $fgets(line,fd);
                    inbuf_data_count=inbuf_data_count+1;
                end
                $fdisplay(1,"test 3");
            end
            if(line == "bitmatrix mux select start\n") begin // m value
                $fgets(line,fd);
                for(j=0;j<BM_MULT_UNIT_NUM;j=j+1) begin
                    bmu_bm_mux_sel_reg_din[j] = line.atobin();
                    $fgets(line,fd);
                end
            end
            if(line == "mask regs start\n") begin // m value
                $fgets(line,fd);
                for(j=0;j<PCK_TREE_XOR_UNITS_NUM;j=j+1) begin
                    and_mask_mask_reg_din[j] = line.atobin();
                    $fgets(line,fd);
                end
            end

        end

                $fdisplay(1,"test - end of eof while");
        $fclose(fd);

	    #(5*CLK_CYCLE)	


        // step 1 - registers write
	    m_val_wr				= 1'b1;
        bmu_bm_mux_sel_reg_wr   = 1'b1;
        and_mask_mask_reg_wr    = 1'b1;
	    #(1*CLK_CYCLE)	
	    m_val_wr				= 1'b0;
        bmu_bm_mux_sel_reg_wr   = 1'b0;
        and_mask_mask_reg_wr    = 1'b0;
	    #(1*CLK_CYCLE)	
        
        // step 2 - write bitmatrix memory

        for(i=0;i<m_val;i=i+1) begin
            user_bm_mem_wr_data = user_bm_mem_wr_data_arr[i];
	        user_bm_mem_wr_req		= 1'b1;
	        #(1*CLK_CYCLE)	
	        user_bm_mem_wr_req		= 1'b0;
	        user_bm_mem_wr_addr     = user_bm_mem_wr_addr + 1'b1;
	        #(1*CLK_CYCLE)	
	        user_bm_mem_wr_req		= 1'b0;

        end

        // step 3 - start eng
        engine_en  =   1'b1;
	    #(1*CLK_CYCLE)	

        // step 4 - set random operations
        tried_to_wr = 1'b0;
        tried_to_rd = 1'b0;
        j = 0;
        //while(sim_output_arr.size() < inbuf_wr_data_arr_init_size*m_val) begin
        inbuf_data_count_idx = 0;
        fd = $fopen("/nfs/iil/proj/perc/percsi_users3/eng/nzaharia/bpu/bpu_a0/results/sim_out.txt","w");
        for(i = 0;i<SIM_CLK_NUM;i=i+1) begin
        
            if($urandom_range(1,100) < WRITE_CHANCE_PER + 1) begin
                sim_write   = 1; 
            end
            if($urandom_range(1,100) < READ_CHANCE_PER + 1) begin
                sim_read   = 1; 
            end
            if($urandom_range(1,100) < STOP_ENG_CHANCE_PER + 1) begin
                stop_eng   = 1; 
            end
            
            outbuf_rd_req   =   1'b0;
            inbuf_wr_req   =   1'b0;
            tried_to_rd = 1'b0;

            if(tried_to_wr) begin
                if(inbuf_user_wr_ack_reg) begin
                    inbuf_data_count_idx = inbuf_data_count_idx+1;
                end
                tried_to_wr = 1'b0;
            end
          



            if(sim_write == 1 && (inbuf_data_count_idx < inbuf_data_count) ) begin

	            inbuf_wr_req    = 1'b1;
	    	    inbuf_wr_data   = inbuf_wr_data_arr[inbuf_data_count_idx];
                tried_to_wr     = 1'b1;

            end
            //$fdisplay(1,"line 382 before insert to sim output arr");

            if((outbuf_rd_data_val & (~outbuf_rd_data_val_reg | outbuf_user_rd_ack_reg))) begin
                $fdisplay(1," read outbuf data %0d : ,%0b,",j,outbuf_rd_data);
                $fdisplay(fd," read outbuf data %0d : ,%0b,",j,outbuf_rd_data);
                j = j + 1;
                //sim_output_arr.push_back(outbuf_rd_data);
            end

            if(sim_read == 1) begin
                outbuf_rd_req   =   1'b1;
                tried_to_rd = 1'b1;
            end

            //if(stop_eng) begin
            //    engine_en = 1'b1;
	        //    #(10*CLK_CYCLE)	

            //end

	        #(1*CLK_CYCLE)	
            engine_en  =   1'b1;// this is irrelevent,just for compilation

        end
        outbuf_rd_req   =   1'b0;
        inbuf_wr_req   =   1'b0;


	    #(100*CLK_CYCLE)	
        
        //write to output text file

       // fd = $fopen("/nfs/iil/proj/perc/percsi_users3/eng/nzaharia/bpu/bpu_a0/results/sim_out.txt","w");
       // iter = 0;
       // while(sim_output_arr.size() > 0)begin
       //     $fdisplay(fd,"data %0d = ,%0b,",iter,sim_output_arr.pop_front());
       //     iter = iter + 1;
       // end
       $fclose(fd);

        finish = 1'b1;



end


always_ff @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        inbuf_user_wr_ack_reg   <=  1'b0;
        outbuf_user_rd_ack_reg  <=  1'b0;
        outbuf_rd_data_val_reg  <=  1'b0;
    end else begin
        inbuf_user_wr_ack_reg   <=  inbuf_user_wr_ack;
        outbuf_user_rd_ack_reg  <=  outbuf_user_rd_ack;
        outbuf_rd_data_val_reg  <=  outbuf_rd_data_val;
    end
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
    .K_MAX(K_MAX)
    ,.K_MIN(K_MIN)
    ,.W(W)
    ,.PACKET_LENGTH(PACKET_LENGTH)
    ,.M_MAX(M_MAX)
    ,.M_MIN(M_MIN)
    ,.BM_MULT_UNIT_NUM(BM_MULT_UNIT_NUM)
    ,.OUTBUF_MEM_DEPTH(OUTBUF_MEM_DEPTH)
    ,.INBUF_DATA_DEPTH(INBUF_DATA_DEPTH)
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
	,.inbuf_user_full(inbuf_user_full)
	,.inbuf_wr_data(inbuf_wr_data)
    ,.inbuf_wr_req(inbuf_wr_req)
    ,.inbuf_user_wr_ack(inbuf_user_wr_ack)

	//output buffer IF:
	,.outbuf_rd_req(outbuf_rd_req)
	,.outbuf_rd_data_val(outbuf_rd_data_val)
	,.outbuf_rd_data(outbuf_rd_data)
    ,.outbuf_user_rd_ack(outbuf_user_rd_ack)
	);


 // ================================================
 // ~~~~~~~~~~ test bench logic ~~~~~~~~~~
 // ================================================

// //Init
// initial
// begin
//	
//	//logic [BMU_BM_MUX_SEL_W-1:0] bmu_bm_mux_sel_reg_din [0:BM_MULT_UNIT_NUM-1];
//	
//	bmu_bm_mux_sel_reg_din[0] = {1'b0, 1'b0};
//	bmu_bm_mux_sel_reg_din[1] = {1'b0, 1'b1};
//	bmu_bm_mux_sel_reg_din[2] = {1'b0, 1'b0};
//	bmu_bm_mux_sel_reg_din[3] = {1'b0, 1'b1};
//	
//	//logic [K_MAX-1:0] and_mask_mask_reg_din [0:PCK_TREE_XOR_UNITS_NUM-1];
//	
//	and_mask_mask_reg_din[0] = {1'b0, 1'b0 , 1'b1 , 1'b1 };
//	and_mask_mask_reg_din[1] = {1'b0, 1'b0 , 1'b1 , 1'b1 };
//
//	//bitmatrix memory user IF:
//	//logic [BM_MEM_W-1:0] user_bm_mem_wr_data;
//	
//	user_bm_mem_wr_data_1 = { 1'b0, 1'b0 , 1'b1 , 1'b1,
//							  1'b0, 1'b1 , 1'b0 , 1'b0,
//							  1'b1, 1'b0 , 1'b0 , 1'b0,
//							  1'b1, 1'b0 , 1'b1 , 1'b0,
//							  
//							  1'b0, 1'b0 , 1'b0 , 1'b1,
//							  1'b0, 1'b1 , 1'b1 , 1'b1,
//							  1'b0, 1'b1 , 1'b0 , 1'b1,
//							  1'b0, 1'b0 , 1'b0 , 1'b0,
//							  
//							  1'b0, 1'b0 , 1'b1 , 1'b1,
//							  1'b0, 1'b1 , 1'b1 , 1'b1,
//							  1'b1, 1'b0 , 1'b0 , 1'b0,
//							  1'b0, 1'b0 , 1'b0 , 1'b1,
//							  
//							  1'b0, 1'b0 , 1'b1 , 1'b0,
//							  1'b1, 1'b1 , 1'b1 , 1'b0,
//							  1'b0, 1'b1 , 1'b1 , 1'b1,
//							  1'b1, 1'b0 , 1'b1 , 1'b1};
//
//user_bm_mem_wr_data_2   = { 1'b1, 1'b0 , 1'b1 , 1'b0,
//							1'b1, 1'b0 , 1'b1 , 1'b0,
//							1'b1, 1'b0 , 1'b1 , 1'b0,
//							1'b1, 1'b0 , 1'b1 , 1'b0,
//							
//							1'b1, 1'b0 , 1'b1 , 1'b0,
//							1'b1, 1'b0 , 1'b1 , 1'b0,
//							1'b1, 1'b0 , 1'b1 , 1'b0,
//							1'b1, 1'b0 , 1'b1 , 1'b0,
//							
//							1'b1, 1'b0 , 1'b1 , 1'b0,
//							1'b1, 1'b0 , 1'b1 , 1'b0,
//							1'b1, 1'b0 , 1'b1 , 1'b0,
//							1'b1, 1'b0 , 1'b1 , 1'b0,
//							
//							1'b1, 1'b0 , 1'b1 , 1'b0,
//							1'b1, 1'b0 , 1'b1 , 1'b0,
//							1'b1, 1'b0 , 1'b1 , 1'b0,
//							1'b1, 1'b0 , 1'b1 , 1'b0};
//
//user_bm_mem_wr_data_3   = { 1'b0, 1'b1 , 1'b0 , 1'b1,
//							1'b0, 1'b1 , 1'b0 , 1'b1,
//							1'b0, 1'b1 , 1'b0 , 1'b1,
//							1'b0, 1'b1 , 1'b0 , 1'b1,
//							
//							1'b0, 1'b1 , 1'b0 , 1'b1,
//							1'b0, 1'b1 , 1'b0 , 1'b1,
//							1'b0, 1'b1 , 1'b0 , 1'b1,
//							1'b0, 1'b1 , 1'b0 , 1'b1,
//							
//							1'b0, 1'b1 , 1'b0 , 1'b1,
//							1'b0, 1'b1 , 1'b0 , 1'b1,
//							1'b0, 1'b1 , 1'b0 , 1'b1,
//							1'b0, 1'b1 , 1'b0 , 1'b1,
//							
//							1'b0, 1'b1 , 1'b0 , 1'b1,
//							1'b0, 1'b1 , 1'b0 , 1'b1,
//							1'b0, 1'b1 , 1'b0 , 1'b1,
//							1'b0, 1'b1 , 1'b0 , 1'b1};
//
//user_bm_mem_wr_data_4   = { 1'b1, 1'b1 , 1'b0 , 1'b1,
//							1'b1, 1'b1 , 1'b0 , 1'b1,
//							1'b1, 1'b1 , 1'b0 , 1'b1,
//							1'b1, 1'b1 , 1'b0 , 1'b1,
//							
//							1'b1, 1'b1 , 1'b0 , 1'b1,
//							1'b1, 1'b1 , 1'b0 , 1'b1,
//							1'b1, 1'b1 , 1'b0 , 1'b1,
//							1'b1, 1'b1 , 1'b0 , 1'b1,
//							
//							1'b1, 1'b1 , 1'b0 , 1'b1,
//							1'b1, 1'b1 , 1'b0 , 1'b1,
//							1'b1, 1'b1 , 1'b0 , 1'b1,
//							1'b1, 1'b1 , 1'b0 , 1'b1,
//							
//							1'b1, 1'b1 , 1'b0 , 1'b1,
//							1'b1, 1'b1 , 1'b0 , 1'b1,
//							1'b1, 1'b1 , 1'b0 , 1'b1,
//							1'b1, 1'b1 , 1'b0 , 1'b1};
//
//
//
// data1 = { 1'b1, 1'b1 , 1'b1 , 1'b1,
//		1'b1, 1'b1 , 1'b1 , 1'b0,
//		1'b1, 1'b1 , 1'b1 , 1'b0,
//		1'b0, 1'b0 , 1'b1 , 1'b0,
//		
//		1'b0, 1'b0 , 1'b1 , 1'b1,
//		1'b0, 1'b0 , 1'b0 , 1'b1,
//		1'b1, 1'b0 , 1'b1 , 1'b0,
//		1'b0, 1'b0 , 1'b0 , 1'b1};
//
//
// data2 = { 1'b1, 1'b1 , 1'b1 , 1'b1,
//		1'b1, 1'b1 , 1'b1 , 1'b0,
//		1'b1, 1'b1 , 1'b1 , 1'b1,
//		1'b1, 1'b0 , 1'b1 , 1'b1,
//		
//		1'b0, 1'b1 , 1'b0 , 1'b1,
//		1'b0, 1'b0 , 1'b0 , 1'b1,
//		1'b1, 1'b1 , 1'b0 , 1'b0,
//		1'b1, 1'b0 , 1'b0 , 1'b1};
//
//  data3 = { 1'b1, 1'b1 , 1'b1 , 1'b1,
//		1'b1, 1'b1 , 1'b1 , 1'b0,
//		1'b1, 1'b0 , 1'b1 , 1'b0,
//		1'b0, 1'b0 , 1'b1 , 1'b0,
//		
//		1'b0, 1'b0 , 1'b0 , 1'b1,
//		1'b0, 1'b0 , 1'b0 , 1'b1,
//		1'b1, 1'b0 , 1'b0 , 1'b0,
//		1'b0, 1'b0 , 1'b0 , 1'b1};
//
// data4 = { 1'b1, 1'b1 , 1'b1 , 1'b1,
//		1'b1, 1'b1 , 1'b1 , 1'b0,
//		1'b1, 1'b0 , 1'b1 , 1'b0,
//		1'b0, 1'b0 , 1'b1 , 1'b0,
//		
//		1'b0, 1'b0 , 1'b0 , 1'b1,
//		1'b0, 1'b1 , 1'b1 , 1'b1,
//		1'b1, 1'b0 , 1'b0 , 1'b0,
//		1'b0, 1'b0 , 1'b0 , 1'b1};
//
//data5 = { 1'b0, 1'b0 , 1'b1 , 1'b1,
//		1'b1, 1'b0 , 1'b1 , 1'b0,
//		1'b1, 1'b0 , 1'b1 , 1'b0,
//		1'b0, 1'b0 , 1'b1 , 1'b0,
//		
//		1'b0, 1'b0 , 1'b0 , 1'b1,
//		1'b0, 1'b0 , 1'b0 , 1'b1,
//		1'b1, 1'b0 , 1'b0 , 1'b0,
//		1'b0, 1'b0 , 1'b0 , 1'b1};
//

								 
// end
 
 //-----------------------------------
 //Memory address and data
 //-----------------------------------
 

  
// always_ff @(posedge clk or negedge rstn)
// begin
//	if(~rstn) begin
//		user_bm_mem_wr_addr <= {BM_MEM_ADDR_W{1'b0}};
//		inbuf_wr_data <= {INBUF_DATA_W{1'b0}};
//	end
//	 
//	else begin
//	
//		user_bm_mem_wr_addr <= user_bm_mem_wr_addr + 1;
//		
//		case(inbuf_wr_data)
//
//			data1:	
//			begin
//				inbuf_wr_data <= data2;
//			end
//
//			data2:
//			begin
//				inbuf_wr_data <= data3;
//			end
//			
//			data3:
//			begin
//				inbuf_wr_data <= data1;
//			end
//		
//		endcase
//	end
//
// end

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
