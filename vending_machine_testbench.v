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
		$display("time=%d: state:%d, pswrd:%d, mon:%d, it_no:%d\n",$time,state,pswrd,mon,it_no);	//display every state etc. on console
	end
	
	//scenerio: adding a item as admin, after that buying item as user
	initial begin
		//admin simulation
		mode=0; ent=0;		// STATE 0 -> 0, initial state
		#10
		mode=1; ent=1;		// STATE 0 -> 1, mode selection
		#10
		mode=1; ent=1;		// STATE 1 -> 2, admin mode selection
		#10
		ent=1; pswrd=4'd0;		// STATE 2 -> 3, get admin password, STATE 3 -> 4
		#10
		/*ent=1; pswrd=4'd1;		// STATE 2 -> 3, STATE 3 -> 2, set current state=2 to test this situation, wrong admin password
		#10*/
		ent=1; it_no=4'd2;		// STATE 4 -> 5, this will also lead STATE 5 -> 7, get unique item no
		#10
		/*//testing of existed item no
		ent=1; it_no=4'd0;		// STATE 5 -> 6, STATE 6 -> 0, default item no is 0, 15 item slot other than the first two, the rest has item no 0, get existing item no
		#10
		*/
		ent=1; mon=3'd2;		// STATE 7 -> 8, get money, add to the balance
		#10
		// STATE 8 -> 0, automatically
		//end of admin simulation,

		//user simulation
		mode=0; ent=1;		// STATE 1 -> 9, user mode
		#10
		add_mon=1; mon=3'd2;		// STATE 9 -> 10, add money, STATE 10 -> 9
		#10
		ent=1;		// STATE 9 -> 11
		#10
		ent=1; it_no=4'd2;		// STATE 11 -> 12, select item no 2, STATE 12 -> 13, STATE 13 -> 14
		#10
		/*//select incorrect item no
		ent=1; it_no=4'd5;		// STATE 12 -> 11
		#10
		*/
		/*//set balance to 0 and state to 13 to perform this
		// STATE 13 -> 9
		#10
		*/
		ent=1;		// STATE 14 -> 15
		#10
		/*
		rem=0;		// STATE 15 -> 9, no reminder option
		#10
		*/
		rem=1;		// STATE 15 -> 16, STATE 16 -> 0
		#10
		//end of user simulation
	end
	
endmodule 