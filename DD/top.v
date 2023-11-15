module clock1s (
	// inputs:
	clk,
	reset_n,

	// outputs:
	out
);
	input						clk;
	input						reset_n;
	output					out;

	wire						out;
	reg			[31: 0]	counter;

	always @ (posedge clk or negedge reset_n) begin
		if (!reset_n)
			counter <= 0;
		else if (counter < 50000000)
			counter <= counter + 1;
		else
			counter <= 0;
	end

	assign out = (counter == 50000000) ? 1'b1 : 1'b0;

endmodule

module DFlipFlop (
	// inputs:
	clk,
	reset_n,
	d,

	// outputs:
	q
);
	input		clk;
	input		reset_n;
	input		d;
	output	q;

	reg			q;

	always @ (posedge clk or negedge reset_n) begin
		if (!reset_n)
			q <= 0;
		else
			q <= d;
	end

endmodule

module counter4b (
	// inputs:
	clk,
	reset_n,

	// outputs:
	hexcount
);
	input						clk;
	input						reset_n;
	output	[ 3: 0]	hexcount;

	reg			[ 3: 0]	hexcount;

	always @ (posedge clk or negedge reset_n) begin
		if (!reset_n)
			hexcount <= 0;
		else
			hexcount <= hexcount + 4'b1;
	end

endmodule

module toHEX (
	// inputs:
	hexcount,

	// outputs:
	toHEX
);
	input		[ 3: 0]	hexcount;
	output	[ 6: 0]	toHEX;

	wire		[ 6: 0]	toHEX;
	reg			[ 6: 0]	toHEX_reg;

	always @ (*) begin
		case (hexcount)
			4'b0000: toHEX_reg <= 7'b1000000;
			4'b0001: toHEX_reg <= 7'b1111001;
			4'b0010: toHEX_reg <= 7'b0100100;
			4'b0011: toHEX_reg <= 7'b0110000;
			4'b0100: toHEX_reg <= 7'b0011001;
			4'b0101: toHEX_reg <= 7'b0010010;
			4'b0110: toHEX_reg <= 7'b0000010;
			4'b0111: toHEX_reg <= 7'b1111000;
			4'b1000: toHEX_reg <= 7'b0000000;
			4'b1001: toHEX_reg <= 7'b0010000;
			4'b1010: toHEX_reg <= 7'b0001000;
			4'b1011: toHEX_reg <= 7'b0000011;
			4'b1100: toHEX_reg <= 7'b1000110;
			4'b1101: toHEX_reg <= 7'b0100001;
			4'b1110: toHEX_reg <= 7'b0000110;
			default: toHEX_reg <= 7'b0001110;
		endcase
	end
	
	assign toHEX = toHEX_reg;

endmodule

module top (
	// inputs:
	CLOCK_50,
	KEY,
	
	// outputs:
	HEX0
);
	input						CLOCK_50;
	input		[ 0: 0]	KEY;
	output	[ 6: 0] HEX0;

	wire		[ 6: 0] HEX0;
	wire						clk;
	wire						reset_n;
	wire		[ 3: 0] counter;
	wire		[ 3: 0] buffered_counter;

	assign reset_n = KEY;

	clock1s _clock1s (
		.clk			(CLOCK_50),
		.reset_n	(reset_n),
		.out			(clk)
	);

	counter4b _counter4b (
		.clk			(clk),
		.reset_n	(reset_n),
		.hexcount	(counter)
	);

	DFlipFlop _DFF1 (
		.clk			(clk),
		.reset_n	(reset_n),
		.d				(counter[0]),
		.q				(buffered_counter[0])
	);

	DFlipFlop _DFF2 (
		.clk			(clk),
		.reset_n	(reset_n),
		.d				(counter[1]),
		.q				(buffered_counter[1])
	);

	DFlipFlop _DFF3 (
		.clk			(clk),
		.reset_n	(reset_n),
		.d				(counter[2]),
		.q				(buffered_counter[2])
	);

	DFlipFlop _DFF4 (
		.clk			(clk),
		.reset_n	(reset_n),
		.d				(counter[3]),
		.q				(buffered_counter[3])
	);

	toHEX _toHEX (
		.hexcount	(buffered_counter),
		.toHEX		(HEX0)
	);

endmodule