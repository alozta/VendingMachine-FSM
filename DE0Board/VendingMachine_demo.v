// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

module VendingMachine_demo
(
// {ALTERA_ARGS_BEGIN} DO NOT REMOVE THIS LINE!

	clock,
	leds,
	switches,
	seven_seg,
	seven_seg1,
	seven_seg2,
	seven_seg3
// {ALTERA_ARGS_END} DO NOT REMOVE THIS LINE!

);

// {ALTERA_IO_BEGIN} DO NOT REMOVE THIS LINE!
input			clock;
output	[9:0]	leds;
input	[0:9]	switches;
output [6:0] seven_seg;
output [6:0] seven_seg1;
output [6:0] seven_seg2;
output [6:0] seven_seg3;

// {ALTERA_IO_END} DO NOT REMOVE THIS LINE!
// {ALTERA_MODULE_BEGIN} DO NOT REMOVE THIS LINE!
VendingMachine testme (switches, clock, leds, seven_seg, seven_seg1, seven_seg2, seven_seg3);
// {ALTERA_MODULE_END} DO NOT REMOVE THIS LINE!
endmodule
