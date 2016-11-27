/*
 * Final state machine implementation of a vending machine in verilog hdl.
 * Some states takes progres by getting enter signal, others just wait or they turn.
 * Reset signal sets the current state to STATE_0.
 * #100 is set to reset ent signal. This time can be incremented to the human reactive level?
 *
 * Inputs:
 * 	mode:			@switch0, 		1 admin, 0 user
 * 	ent: 			@switch8, 		1 enter
 * 	res: 			@switch9, 		1 reset
 * 	pswrd: 		@switch[0:3], 	password
 * 	mon: 			@switch[0:2], 	money
 * 	it_no: 		@switch[0:3], 	item no
 * 	rem: 			@switch0, 		remainder option
 *		add_mon:		@switch5,		option to add multiple money values consecutively
 *
 * Outputs:
 * 	err_pswrd:	@led0,			wrong password (admin)
 *		err_it_no:	@led1,			wrong item no (admin)
 *		suc_it_no:	@led2,			correct item no (user)
 *		suc_rem:		@7segment,		remaining money (user)
 *		state	@led[3:7],		current state information
 *		all_led		@led[0:9],		all led bits
 */
 //Used/not used:			OK	 OK	OK	  OK	OK		OK	 OK	OK			 -				-			-			-		  OK		OK
module vending_machine(mode,ent,res,pswrd,mon,it_no,rem,add_mon,err_pswrd,err_it_no,suc_it_no,suc_rem,state,all_led);
	//----------------------------------------------------------------
	//Variables
	//Inputs
	input mode,ent,res,rem,add_mon;			//1-bit
	input [0:3] pswrd;							//4-bits
	input [0:2] mon;								//3-bits
	input [0:3] it_no;							//4-bits
	//Outputs
	output err_pswrd,err_it_no,suc_it_no;
	output suc_rem;								//7segment
	output reg [0:4] state;						//5-bits
	output reg [0:9] all_led;					//10-bits
	//Locals
	reg [0:3] password = 4'd0;
	reg [0:3] item_no_array [15:0];
	reg [0:2] item_money_array [15:0];
	integer i;										//for iterations
	integer save_i;								//specific iteration of i used in necessary states
	integer balance;								//user balance
	//----------------------------------------------------------------
	//constants
	localparam  //money constants
					MONEY_025 	= 3'b000,
					MONEY_050 	= 3'b001,
					MONEY_1		= 3'b010,
					MONEY_5		= 3'b011,
					MONEY_10		= 3'b100,
					MONEY_20		= 3'b101,
					MONEY_50		= 3'b110,
					MONEY_NONE	= 3'b111,
					//state constants
					STATE_0		= 5'd0,
					STATE_1		= 5'd1,
					STATE_2		= 5'd2,
					STATE_3		= 5'd3,
					STATE_4		= 5'd4,
					STATE_5		= 5'd5,
					STATE_6		= 5'd6,
					STATE_7		= 5'd7,
					STATE_8		= 5'd8,
					STATE_9		= 5'd9,
					STATE_10		= 5'd10,
					STATE_11		= 5'd11,
					STATE_12		= 5'd12,
					STATE_13		= 5'd13,
					STATE_14		= 5'd14,
					STATE_15		= 5'd15,
					STATE_16		= 5'd16,
					//other
					TEN_BITS_ON	= 10'b1111111111,
					TEN_BITS_OFF= 10'b0000000000;
	//----------------------------------------------------------------
	//Initial assignments
	initial begin
		item_no_array[0] = 4'd1;				//current items (if item no is 0, place is available):
		item_money_array[0] = MONEY_1;		//item no: 1, item money: 1
		item_no_array[1] = 4'd2;
		item_money_array[1] = MONEY_5;		//item no: 2, item money: 5
		for (i=2; i<15; i=i+1) begin			//set the rest of the product array to available
			item_no_array[i] = 4'd0;			//default item no
			item_money_array[i] = MONEY_NONE;//default item money
		end
		balance = 0;								//initial balance
		save_i = 0;									//unnecessary value
		state = STATE_15;							//initiate with first state, CHANGE THIS TO TEST THE STATES
	end
	//----------------------------------------------------------------
	//State table
	always @(state or ent or res) begin
		if(res) begin
			state = STATE_0;						//if reset is hitted go to the initial state
		end
		
		case (state)
			STATE_0: begin							//initial state
				all_led = TEN_BITS_ON;
				#15
				all_led = TEN_BITS_OFF;			//show user that program is at the beginning by powering all the leds for a bit
				if(ent) begin
					state = STATE_1;				//if user hits enter go to next state
					#100;								//time to reset ent switch
				end
			end
			STATE_1: begin							//admin or user selection, waits until enter
				if(ent) begin						//if user hits enter go to next state
					if(mode)
						state = STATE_2;			//admin mode is selected
					else
						state = STATE_9;			//user mode is selected
					#100;								//time to reset ent switch
				end
			end
			STATE_2: begin							//wait in this state until password is set and enter is hitted
				if(ent) begin
					state = STATE_3;
					#100;								//time to reset ent switch
				end
			end
			STATE_3: begin							//password comparison state
				if(password == pswrd)
					state = STATE_4;				//password is correct move to next state
				else
					state = STATE_2;				//if password is not correct, go back to previous state and try again
			end
			STATE_4: begin							//get item no while waiting for enter
				if(ent) begin
					state = STATE_5;
					#100;								//time to reset ent switch
				end
			end
			STATE_5: begin							//compare item no with item no array if it exists
				state = STATE_7;					//set state as item no does not exist by default
				for (i=0; i<15; i=i+1) begin
					if(item_no_array[i] == it_no) begin		//item exists
						state = STATE_6;			//if item exists, this will overwrite STATE_7 assignment above
					end
				end
			end
			STATE_6: begin							//tell admin item no exists via leds
				all_led = TEN_BITS_ON;
				#50
				all_led = TEN_BITS_OFF;
				#50
				all_led = TEN_BITS_ON;
				#50
				all_led = TEN_BITS_OFF;	
				state = STATE_0;					//go back to initial state
			end
			STATE_7: begin							//item no is not found, get money while waiting for the enter
				if(ent) begin
					state = STATE_8;
					#100;								//time to reset ent switch
				end
			end
			STATE_8: begin							//save item no and item money into the arrays
				for (i=0; i<15; i=i+1) begin
					if(item_no_array[i] == 4'd0) begin		//next available place in the arrays
						item_no_array[i] = it_no;
						item_money_array[i] = mon;	//save new item credentials
					end
				end
				state = STATE_0;					//admin has finished entering item credentials
			end
			STATE_9: begin							//user mode is selected, set user money input while waiting for enter signal
				if(add_mon) begin					//with add_mon signal new money is added to the balance
					state = STATE_10;
					#100;								//time to reset add_mon switch
				end
				if(ent) begin
					state = STATE_11;				//enter skips addition process
					#100;								//time to reset ent switch
				end
			end
			STATE_10: begin						//add money
				balance = balance + mon;		//is this the proper way?
				state = STATE_9;
			end
			STATE_11: begin
				if(ent) begin						//wait for item no input while waiting for enter
					state = STATE_12;
					#100;								//time to reset ent switch
				end
			end
			STATE_12: begin
				state = STATE_11;					//set default state change (if item no does not exist)
				for (i=0; i<15; i=i+1) begin
					if(item_no_array[i] == it_no) begin		//item no found
						state = STATE_13;			//overwrite the above state change, go to buy state
						save_i = i;					//save i for the buying
					end
				end
			end
			STATE_13: begin						//where the buying happens
				state = STATE_9;					//value is not enough, default state
				if(balance > item_money_array[save_i]) begin	//if there is enough money
					balance = balance - item_money_array[save_i];	//is this the proper way?
					//7segment
					state = STATE_14;				//overwrite the above state change
				end
			end
			STATE_14: begin						//tell user that the item is bought via leds
				all_led = TEN_BITS_ON;
				#50
				all_led = TEN_BITS_OFF;
				#50
				all_led = TEN_BITS_ON;
				#50
				all_led = TEN_BITS_OFF;
				if(ent) begin
					state = STATE_15;
					#100;								//time to reset ent switch
				end
			end
			STATE_15: begin						//check if user wants remainder or continue buying
				if(rem)								//give remainder
					state = STATE_16;
				else									//continue buying
					state = STATE_9;
			end
			STATE_16: begin
				//7segment remainder display
				#200									//wait for a moment
				state = STATE_0;					//restart
			end
		endcase
	end
	//----------------------------------------------------------------
endmodule 