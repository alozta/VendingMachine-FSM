module VendingMachine(switches, clock, leds, seven_seg0, seven_seg1, seven_seg2, seven_seg3);

/* Inputs */
input wire[0:9] switches;
input wire clock;

/* Outputs */
output reg [9:0] leds;
output reg [6:0] seven_seg0;
output reg [6:0] seven_seg1;
output reg [6:0] seven_seg2;
output reg [6:0] seven_seg3;

/* Constants */
localparam	
				// money constants
				MONEY_025 	= 3'b000,
				MONEY_050 	= 3'b001,
				MONEY_1		= 3'b010,
				MONEY_5		= 3'b011,
				MONEY_10		= 3'b100,
				MONEY_20		= 3'b101,
				MONEY_50		= 3'b110,
				MONEY_NONE	= 3'b111,
				// state constants
				STATE_Initial = 5'd0,
				STATE_1 = 5'd1,
				STATE_2 = 5'd2,
				STATE_3 = 5'd3,
				STATE_4 = 5'd4,
				STATE_5 = 5'd5,
				STATE_6 = 5'd6,
				STATE_7 = 5'd7,
				STATE_8 = 5'd8,
				STATE_9 = 5'd9,
				STATE_10 = 5'd10,
				STATE_11 = 5'd11,
				STATE_12 = 5'd12,
				STATE_13 = 5'd13,
				STATE_14 = 5'd14,
				STATE_15 = 5'd15,
				STATE_16 = 5'd16,
				// led constants
				TEN_BITS_ON	= 10'b1111111111,
				TEN_BITS_OFF= 10'b0000000000,
				// item constants
				ITEM_NONE = 4'b1111,
				ITEM_CAP = 5'd15;

/* Variables */
reg [0:4] currentState;
reg [0:4] nextState;
reg [0:3] password;
reg [0:3] enteredPW;
reg [0:3] enteredItemNo;
reg [0:2] enteredMoney;
reg [0:3] itemNoArray [15:0];
reg [0:2] itemMoneyArray [15:0];
integer i;										//for iterations
integer balance;
integer moneyTaken = 0;			// booleans to avoid
integer moneyLoaded = 0;		// multiple addings or decreasings
reg itemSize = 4'd1;

// integer values belong to each seven segment digit
integer seg_0 = 0;
integer seg_1 = 0;
integer seg_2 = 0;
integer seg_3 = 0;

/* Initial assignments */
initial begin
	//set all the product array to available
	for (i=0; i<ITEM_CAP; i=i+1) begin			
		itemNoArray[i] = ITEM_NONE;			//default item no
		itemMoneyArray[i] = MONEY_NONE;	//default item price
	end
	itemNoArray[0] = 4'd1;
	itemMoneyArray[0] = MONEY_025;
	
	balance = 32'd0;								//initial balance
	enteredItemNo = ITEM_NONE;
	enteredPW = 4'd0;
	moneyTaken = 0;
	moneyLoaded = 0;
	nextState = STATE_Initial;
	leds = 10'd0;
end

always@ (posedge clock) begin
	// check reset bit
	if ( switches[9] == 1 ) currentState <= STATE_Initial;
	else currentState <= nextState;
end

// switch 8: enter, switch 9: reset
always@ ( * ) begin

	nextState = currentState;
	
	case ( currentState )
	
		STATE_Initial : begin
			leds = 10'b1111111111;
			
			if ( switches[8] == 1 ) begin
				nextState = STATE_1;
			end
			enteredMoney = MONEY_NONE;
			enteredItemNo = ITEM_NONE;
			moneyTaken = 0;
			balance = 0;
		end
		
		STATE_1 : begin
			leds = STATE_1;
			
			// pressed enter
			if ( switches[8] == 0 ) begin
				// admin
				if(switches[0] == 1) nextState = STATE_2;
					
				// user
				else 
					nextState = STATE_9;	
			end
		end
		
		/*-----------------ADMIN-------------------*/
		STATE_2 : begin
			leds = STATE_2;
			
			// pressed enter
			if ( switches[8] == 1 )
				nextState = STATE_3;
		end
		
		STATE_3 : begin
			leds = STATE_3;
			
			// check for password
			enteredPW = switches[0:3];
			if( enteredPW == password )
					nextState = STATE_4;
			else	nextState = STATE_Initial;
		end
		
		STATE_4 : begin
			leds = STATE_4;
			
			// pressed enter
			if ( switches[8] == 0 )
				nextState = STATE_5;
		end
		
		STATE_5 : begin
			leds = STATE_5;
			
			// get item no from switches
			enteredItemNo = switches[0:3];
			
			// item not found
			// if item array size is full
			if( itemSize < ITEM_CAP )
				nextState = STATE_7;
			// capacity is full - ERROR
			else
				nextState = STATE_6;
			
			// search the item in array
			for(i=0; i<itemSize; i=i+1) begin
				// item found - ERROR
				if( itemNoArray[i] == enteredItemNo )
					nextState = STATE_6;
			end
			
			
		end
		
		STATE_6 : begin
			nextState = STATE_Initial;
		end
		
		STATE_7 : begin
			leds = STATE_7;
			
			// pressed enter
			if ( switches[8] == 1 )
				nextState = STATE_8;
		end
		
		STATE_8 : begin
			leds = STATE_8;
			
			// get money input from switches
			// put money and number info into arrays
			enteredMoney = switches[0:2];
			itemMoneyArray[i] = enteredMoney;
			itemNoArray[i] = enteredItemNo;
			itemSize = itemSize + 1;
			nextState = STATE_Initial;
		end
		
		/*-----------------USER-------------------*/
		STATE_9 : begin
			leds = STATE_9;
			
			// add money to current balance
			if ( switches[5] == 1 ) begin
				moneyLoaded = 0;
				nextState = STATE_10;
			end
				
			// pressed enter finish adding money
			if ( switches[8] == 1 )
				nextState = STATE_11;
		end
		
		STATE_10 : begin
			leds = STATE_10;
			
			// get money input from switches
			// add money to balance
			enteredMoney = switches[0:2];
			if ( !moneyLoaded ) begin
				if( enteredMoney == MONEY_025 )
					balance = balance + 25;
				else if( enteredMoney == MONEY_050 )
					balance = balance + 50;
				else if( enteredMoney == MONEY_1 )
					balance = balance + 100;
				else if( enteredMoney == MONEY_5 )
					balance = balance + 500;
				else if( enteredMoney == MONEY_10 )
					balance = balance + 1000;
				else if( enteredMoney == MONEY_20 )
					balance = balance + 2000;
				else if( enteredMoney == MONEY_50 )
					balance = balance + 5000;
				moneyLoaded = 1;
			end
			
			// reset moneyTaken for state 14
			moneyTaken = 0;
			
			// reset moneyLoaded
			if ( switches[5] == 0 )
				nextState = STATE_9;
		end
		
		STATE_11 : begin
			leds = STATE_11;
			
			// pressed enter
			if ( switches[8] == 0 )
				nextState = STATE_12;
		end
		/*
		STATE_12 : begin
			leds = STATE_12;
			
			// get item no from switches
			enteredItemNo = switches[0:3];
			
			// search the item in array
			for(i=0; i<itemSize; i=i+1) begin
			
				// item found
				if( itemNoArray[i] == enteredItemNo )
					nextState = STATE_13;
					
				// item not found
				else if ( i == itemSize - 1 )
					nextState = STATE_11;
			end
		end
		
		STATE_13 : begin
			leds = STATE_13;
			
			// balance is enough - give the item
			if ( balance >= itemMoneyArray[i] )
				nextState = STATE_14;
				
			// balance is not enough - add more money
			else
				nextState = STATE_9;
		end
		
		STATE_14 : begin
			leds = STATE_14;
			
			if(!moneyTaken) begin
				// take money and give item
				balance = balance - itemMoneyArray[i];
				moneyTaken = 1;
			end
			
			if ( switches[8] == 1 )
				nextState = STATE_15;
		end
		
		STATE_15 : begin
			leds = STATE_15;
			
			// give remainder money
			if ( switches[0] == 1 )
				nextState = STATE_16;
				
			// continue buying
			else
				nextState = STATE_9;
		end
		
		STATE_16 : begin
			leds = STATE_16;
			
			// give remainder
			#1000
			balance = 0;
			nextState = STATE_Initial;
		end
		*/
	endcase
	
	// display balance at 7-seg
	seg_0 = balance % 10;
	seg_1 = (balance / 10) % 10;
	seg_2 = (balance / 100) % 10;
	seg_3 = (balance / 1000) % 10;
	
	case (seg_0)
	
		0: seven_seg0 = 7'b1000000;
		1: seven_seg0 = 7'b1111001;
		2: seven_seg0 = 7'b0100100;
		3: seven_seg0 = 7'b0110000;
		4: seven_seg0 = 7'b0011001;
		5: seven_seg0 = 7'b0010010;
		6: seven_seg0 = 7'b0000010;
		7: seven_seg0 = 7'b1111000;
		8: seven_seg0 = 7'b0000000;
		9: seven_seg0 = 7'b0010000;
	
	endcase
	
	case (seg_1)
	
		0: seven_seg1 = 7'b1000000;
		1: seven_seg1 = 7'b1111001;
		2: seven_seg1 = 7'b0100100;
		3: seven_seg1 = 7'b0110000;
		4: seven_seg1 = 7'b0011001;
		5: seven_seg1 = 7'b0010010;
		6: seven_seg1 = 7'b0000010;
		7: seven_seg1 = 7'b1111000;
		8: seven_seg1 = 7'b0000000;
		9: seven_seg1 = 7'b0010000;
	
	endcase
	
	case (seg_2)
	
		0: seven_seg2 = 7'b1000000;
		1: seven_seg2 = 7'b1111001;
		2: seven_seg2 = 7'b0100100;
		3: seven_seg2 = 7'b0110000;
		4: seven_seg2 = 7'b0011001;
		5: seven_seg2 = 7'b0010010;
		6: seven_seg2 = 7'b0000010;
		7: seven_seg2 = 7'b1111000;
		8: seven_seg2 = 7'b0000000;
		9: seven_seg2 = 7'b0010000;
	
	endcase
	
	case (seg_3)
	
		0: seven_seg3 = 7'b1000000;
		1: seven_seg3 = 7'b1111001;
		2: seven_seg3 = 7'b0100100;
		3: seven_seg3 = 7'b0110000;
		4: seven_seg3 = 7'b0011001;
		5: seven_seg3 = 7'b0010010;
		6: seven_seg3 = 7'b0000010;
		7: seven_seg3 = 7'b1111000;
		8: seven_seg3 = 7'b0000000;
		9: seven_seg3 = 7'b0010000;
	
	endcase
	
end

endmodule

