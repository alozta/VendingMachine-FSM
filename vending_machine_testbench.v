module vending_machine_testbench;
	reg mode,ent,res,rem,add_mon;					//inputs
	reg [0:3] pswrd;
	reg [0:2] mon;
	reg [0:3] it_no;
	wire err_pswrd,err_it_no,suc_it_no;			//outputs
	wire suc_rem;										//7segment
	wire [0:4] state;
	wire [0:9] all_led;
	
	vending_machine vm(mode,ent,res,pswrd,mon,it_no,rem,add_mon,err_pswrd,err_it_no,suc_it_no,suc_rem,state,all_led);
	
	always @(state) begin
		$display("time=%d: state:%d, pswrd:%d, mon:%d, it_no:%d\n",$time,state,pswrd,mon,it_no);
	end
	
	initial begin
		mode=0; ent=0; res=0; pswrd=0; mon=0; it_no=0; rem=1; add_mon=0; pswrd=4'd0; it_no=4'd2; mon=3'd2;
		#10
		mode=0; ent=1; res=0; pswrd=0; mon=0; it_no=0; rem=1; add_mon=1;
		#10;
	end
	
endmodule 