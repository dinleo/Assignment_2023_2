module top_SlotMachine(
   input CLOCK_50,   //50MHz -> 1sec per 5000000 clock cycle
   input [1:0]KEY,
   output [0:6] HEX0, HEX1, HEX2
);
//KEY[1]: Stop all values
//KEY[0]: reset

localparam  IDLE = 0,
            GAME = 1,
            REPORT = 2;

localparam HEX0_delay = 'd50000000,
           HEX1_delay = 'd8000000,
           HEX2_delay = 'd15000000;

reg [3:0]val[0:2];                           //7-segment value in the GAME state
reg [3:0]_7seg[0:2];                         //7segment displaying value
reg [31:0]cnt_reg[0:2];                      //counter register
reg [31:0]cmp_reg[0:2];                      //compare register

wire clk, rst, next;
assign clk=CLOCK_50;
assign rst=KEY[0];
assign next=KEY[1];
reg state=IDLE;
reg stop=1;

///////////Displaying 7-segment value//////////////
digit_to_hex hex0(_7seg[0],HEX0);
digit_to_hex hex1(_7seg[1],HEX1);
digit_to_hex hex2(_7seg[2],HEX2);
//////////////////////////////////////////////////

//////////////////Compare register setting////////
always@(*) begin
      cmp_reg[0] = HEX0_delay;
      cmp_reg[1] = HEX1_delay;
      cmp_reg[2] = HEX2_delay;
end
//////////////////////////////////////////////////

///////////////////Clock/////////////////////////
always@(posedge clk or negedge rst) begin
   if (!rst) begin                           //Reset
      cnt_reg[0] <= 0;
      val[0] <= 0;
   end
   else if(stop) begin                  //Stop
      cnt_reg[0] <= cnt_reg[0];
      val[0] <= val[0];
   end
   else if (cnt_reg[0] == cmp_reg[0])begin   //Increase 7-segment value
      cnt_reg[0] <= 0;
      if(val[0] == 9) begin
         val[0] <= 0;
      end
      else begin
         val[0] <= val[0] + 1;
      end
   end
   else begin                                //Increase counter register
      cnt_reg[0] <= cnt_reg[0] + 1;
      val[0] <= val[0];
   end
end

always@(posedge clk or negedge rst) begin
   if (!rst) begin                           //Reset
      cnt_reg[1] <= 0;
      val[1] <= 0;
   end
   else if(stop) begin                  //Stop
      cnt_reg[1] <= cnt_reg[1];
      val[1] <= val[1];
   end
   else if (cnt_reg[1] == cmp_reg[1])begin   //Increase 7-segment value
      cnt_reg[1] <= 0;
      if(val[1] == 9) begin
         val[1] <= 0;
      end
      else begin
         val[1] <= val[1] + 1;
      end
   end
   else begin                                //Increase counter register
      cnt_reg[1] <= cnt_reg[1] + 1;
      val[1] <= val[1];
   end
end

always@(posedge clk or negedge rst) begin
   if (!rst) begin                          //Reset
      cnt_reg[2] <= 0;
      val[2] <= 0;
   end
   else if(stop) begin                 //Stop
      cnt_reg[2] <= cnt_reg[2];
      val[2] <= val[2];
   end
   else if (cnt_reg[2] == cmp_reg[2])begin  //Increase 7-segment value
      cnt_reg[2] <= 0;
      if(val[2] == 9) begin
         val[2] <= 0;
      end
      else begin
         val[2] <= val[2] + 1;
      end
   end
   else begin                               //Increase counter register
      cnt_reg[2] <= cnt_reg[2] + 1;
      val[2] <= val[2];
   end
end
////////////////////////////////////////////////////

reg [3:0] score=4'b0000;
reg [1:0] round=0;

always@(posedge clk or negedge rst) begin
	if(!rst) begin
		_7seg[0] <= 0;
		_7seg[1] <= 0;
		_7seg[2] <= 0;
	end
	else if (state == IDLE) begin
		_7seg[0] <= 0;
		_7seg[1] <= 0;
		_7seg[2] <= 0;
	end
	else if (state == GAME) begin
		_7seg[0] = val[0];
		_7seg[1] = val[1];
		_7seg[2] = val[2];
	end
	else if (state == REPORT) begin
		_7seg[0] <= score;
		_7seg[1] <= 0;
		_7seg[2] <= 0;
	end
end

always@(negedge next or negedge rst) begin
	// RESET
   if(!rst) begin
      round<=0;
      stop<=1;
      score<=4'b0000;
      state<=IDLE;
   end
	else if(!next) begin
		// IDLE
		if(state==IDLE) begin
			state<=GAME;
			stop<=0;
		end
		// GAME
		else if(state==GAME) begin
			if (!stop) begin
				stop<=1;
				score <= score + ((val[0] == 4'b0111) + (val[1] == 4'b0111) + (val[2] == 4'b0111));
				round <= round + 1;
			end
			else if (round < 3) begin
				stop<=0;
			end
			else begin
				state<=REPORT;
			end
		end
		// REPORT
		else if(state==REPORT) begin
			state<=IDLE;
		end
	end
end

////////////////////////////////////////////////////

endmodule

///////////////////////7-segment display module////////////////////
module digit_to_hex(
   input [3:0] digit,
   output reg [0:6] hex
);

parameter Seg9 = 7'b000_1100; parameter Seg8 = 7'b000_0000; parameter Seg7 = 7'b000_1111; parameter Seg6 = 7'b010_0000; parameter Seg5 = 7'b010_0100;
parameter Seg4 = 7'b100_1100; parameter Seg3 = 7'b000_0110; parameter Seg2 = 7'b001_0010; parameter Seg1 = 7'b100_1111; parameter Seg0 = 7'b000_0001;

always @(*) begin
   case(digit)
      9:hex=Seg9;
      8:hex=Seg8;
      7:hex=Seg7;
      6:hex=Seg6;
      5:hex=Seg5;
      4:hex=Seg4;
      3:hex=Seg3;
      2:hex=Seg2;
      1:hex=Seg1;
      0:hex=Seg0;
      default: hex = 7'b1111111;
   endcase
end
endmodule