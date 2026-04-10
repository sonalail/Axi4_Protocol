package AxiGlobalPackage;

	parameter int ADDR_WIDTH = 32;

	parameter int DATA_WIDTH = 32;

	parameter int STROBE = DATA_WIDTH/8;

	typedef enum bit[1:0]{
							BYTE_1  = 'b00,
							BYTE_2  = 'b01,
							BYTE_4  = 'b10,
							BYTE_8  = 'b11
						}axi_size;
	
	typedef enum bit{
						WRITE = 1'b1,
						READ  = 1'b0
					}axi_write_read;

	typedef enum bit[1:0]{
					   	OKAY 	= 2'b00,	
					   	EX_OKAY = 2'b01,	
					    SLV_ERR = 2'b10,	
					   	DEC_ERR = 2'b11
						}axi_resp;
	
	typedef enum bit[1:0]{
					   	FIXED = 2'b00,	
					   	INCR  = 2'b01,	
					    WRAP  = 2'b10	
						}axi_trans_type;

endpackage
