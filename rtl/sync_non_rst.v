    module sync_non_rst
    (
    input  wire    in_data     ,
    input  wire    dest_clk    ,
    output wire    out_data
    );
    reg regA /* synthesis syn_preserve=1 CDC_Register=2 */;
    reg regB;

    always @ (posedge dest_clk)
		begin
			regA <= in_data;
			regB <= regA;	
		end
    assign out_data = regB;
    endmodule