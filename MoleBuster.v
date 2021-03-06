module MoleBuster(game_mode,clk,rst,keypad_row,keypad_col,dot_row,dot_col,score);
	input clk,rst;
	input game_mode;
	output [3:0] keypad_row;
	input [3:0] keypad_col;
	output reg [7:0] dot_row,dot_col;
	//output wire [6:0] seven_seg;
	output wire [6:0] score;

	reg [31:0] cnt_div,cnt_dot;
	reg [7:0] dot_col_buf[0:7];
	wire [4:0] keypad_buf;
	reg [2:0] row_count;
	reg [3:0] score_count = 4'd0;
	wire clk_div, clk_dot, clk_spn; // assign dot matrix column, scan dot matrix row, turn on dot matrix, respectively
	
	clk_divide div(.clk(clk), .rst(rst), .div_clk(clk_div), .frequency(32'd250000));
	clk_divide dot(.clk(clk), .rst(rst), .div_clk(clk_dot), .frequency(32'd5000));
	clk_divide spn(.clk(clk), .rst(rst), .div_clk(clk_spn), .frequency(32'd25000000));
	
	//BCD cur(.in(rnd_num[5:2]), .out(seven_seg));
	BCD scr(.in(cur2), .out(score), .game_mode(game_mode));
	
	checkkeypad keypad_detect(game_mode,clk,rst,keypad_row,keypad_col,keypad_buf);

	
	/***********************************************************/
	// lfsr ( pseudo-random sequence generator )
	
	reg [7:0] rnd_seq;
	reg [7:0] rnd_num;

	always @(rnd_seq) begin
		rnd_num = (rnd_seq[6:3] * rnd_seq[4:1]);
		rnd_num[3:0] = {rnd_seq[7], rnd_num[3], rnd_num[5], rnd_seq[0]};
	end

	always @(posedge clk_spn or negedge rst) begin		
	if (~rst)
		rnd_seq <= 8'd1; 
	else if (game_mode!=1)
		rnd_seq <= 8'd1; 
	else
		rnd_seq <= {rnd_seq[6:0], rnd_seq[7] ^ rnd_seq[5] ^ rnd_seq[4] ^ rnd_seq[3]};
	end
	
	/**********************************************************/
	
	/**********************************************************/
	// scan row
	integer it;
	
	always@ (posedge clk_dot or negedge rst)
	begin
		if (~rst)
		begin
			dot_row <= 8'd0;
			dot_col <= 8'd0;
			row_count <= 3'd0;
		end
		else if (game_mode!=1)
		begin
			dot_row <= 8'd0;
			dot_col <= 8'd0;
			row_count <= 3'd0;
		end
		else
		begin
		    row_count <= row_count + 4'd1;
		    dot_col <= dot_col_buf[row_count];
		    case (row_count)
				3'd0: dot_row <= 8'b01111111;
				3'd1: dot_row <= 8'b10111111;
				3'd2: dot_row <= 8'b11011111;
				3'd3: dot_row <= 8'b11101111;
				3'd4: dot_row <= 8'b11110111;
				3'd5: dot_row <= 8'b11111011;
				3'd6: dot_row <= 8'b11111101;
				3'd7: dot_row <= 8'b11111110;
			endcase
		end
	end
	/**********************************************************/
	
	/**********************************************************/
	// assign column
	
	reg [15:0] signal;
	reg [31:0] count [15:0];
	
	
	
	/**********************************************************/
	// finite state machine
	reg [3:0] cur2;
	reg [3:0] nxt;
	
	always@(*)begin
		case(cur2)
			0:nxt=1;
			1:nxt=2;
			2:nxt=3;
			3:nxt=4;
			4:nxt=5;
			5:nxt=6;
			6:nxt=7;
			7:nxt=8;
			8:nxt=9;
			9:nxt=0;
			default:nxt=0;
		endcase
	end
	
	always@(posedge clk_div or negedge rst)
	begin
		if (~rst)
		begin
			cur2<=0;
			dot_col_buf[0] <= 8'd0;
			dot_col_buf[1] <= 8'd0;
			dot_col_buf[2] <= 8'd0;
			dot_col_buf[3] <= 8'd0;
			dot_col_buf[4] <= 8'd0;
			dot_col_buf[5] <= 8'd0;
			dot_col_buf[6] <= 8'd0;
			dot_col_buf[7] <= 8'd0;
		end
		else if (game_mode!=1)
		begin
			cur2<=0;
			dot_col_buf[0] <= 8'd0;
			dot_col_buf[1] <= 8'd0;
			dot_col_buf[2] <= 8'd0;
			dot_col_buf[3] <= 8'd0;
			dot_col_buf[4] <= 8'd0;
			dot_col_buf[5] <= 8'd0;
			dot_col_buf[6] <= 8'd0;
			dot_col_buf[7] <= 8'd0;
		end
		else
		begin
			//score_count = 4'b0;
			case(rnd_num[5:2])
				4'hf:begin
					signal[0]<=1'b1;
					dot_col_buf[0]<=8'b11000000|dot_col_buf[0];
					dot_col_buf[1]<=8'b11000000|dot_col_buf[1];
				end
				4'he:begin
					signal[1]<=1'b1;
					dot_col_buf[0]<=8'b00110000|dot_col_buf[0];
					dot_col_buf[1]<=8'b00110000|dot_col_buf[1];
				end
				4'hd:begin
					signal[2]<=1'b1;
					dot_col_buf[0]<=8'b00001100|dot_col_buf[0];
					dot_col_buf[1]<=8'b00001100|dot_col_buf[1];
				end
				4'hc:begin
					signal[3]<=1'b1;
					dot_col_buf[0]<=8'b00000011|dot_col_buf[0];
					dot_col_buf[1]<=8'b00000011|dot_col_buf[1];
				end
				4'hb:begin
					signal[4]<=1'b1;
					dot_col_buf[2]<=8'b11000000|dot_col_buf[2];
					dot_col_buf[3]<=8'b11000000|dot_col_buf[3];
				end
				4'h3:begin
					signal[5]<=1'b1;
					dot_col_buf[2]<=8'b00110000|dot_col_buf[2];
					dot_col_buf[3]<=8'b00110000|dot_col_buf[3];
				end
				4'h6:begin
					signal[6]<=1'b1;
					dot_col_buf[2]<=8'b00001100|dot_col_buf[2];
					dot_col_buf[3]<=8'b00001100|dot_col_buf[3];
				end
				4'h9:begin
					signal[7]<=1'b1;
					dot_col_buf[2]<=8'b00000011|dot_col_buf[2];
					dot_col_buf[3]<=8'b00000011|dot_col_buf[3];
				end
				4'ha:begin
					signal[8]<=1'b1;
					dot_col_buf[4]<=8'b11000000|dot_col_buf[4];
					dot_col_buf[5]<=8'b11000000|dot_col_buf[5];
				end
				4'h2:begin
					signal[9]<=1'b1;
					dot_col_buf[4]<=8'b00110000|dot_col_buf[4];
					dot_col_buf[5]<=8'b00110000|dot_col_buf[5];
				end
				4'h5:begin
					signal[10]<=1'b1;
					dot_col_buf[4]<=8'b00001100|dot_col_buf[4];
					dot_col_buf[5]<=8'b00001100|dot_col_buf[5];
				end
				4'h8:begin
					signal[11]<=1'b1;
					dot_col_buf[4]<=8'b00000011|dot_col_buf[4];
					dot_col_buf[5]<=8'b00000011|dot_col_buf[5];
				end
				4'h0:begin
					signal[12]<=1'b1;
					dot_col_buf[6]<=8'b11000000|dot_col_buf[6];
					dot_col_buf[7]<=8'b11000000|dot_col_buf[7];
				end
				4'h1:begin
					signal[13]<=1'b1;
					dot_col_buf[6]<=8'b00110000|dot_col_buf[6];
					dot_col_buf[7]<=8'b00110000|dot_col_buf[7];
				end
				4'h4:begin
					signal[14]<=1'b1;
					dot_col_buf[6]<=8'b00001100|dot_col_buf[6];
					dot_col_buf[7]<=8'b00001100|dot_col_buf[7];
				end
				4'h7:begin
					signal[15]<=1'b1;
					dot_col_buf[6]<=8'b00000011|dot_col_buf[6];
					dot_col_buf[7]<=8'b00000011|dot_col_buf[7];
				end
			endcase
			case(keypad_buf)
				5'hf:begin
					if(dot_col_buf[0][6])
						cur2 <= nxt;
					dot_col_buf[0]<=8'b00111111&dot_col_buf[0];
					dot_col_buf[1]<=8'b00111111&dot_col_buf[1];
				end
				5'he:begin
					//signal[1]<=1'b0;
					if(dot_col_buf[0][4])
						cur2 <= nxt;
					dot_col_buf[0]<=8'b11001111&dot_col_buf[0];
					dot_col_buf[1]<=8'b11001111&dot_col_buf[1];
				end
				5'hd:begin
					//signal[2]<=1'b0;
					if(dot_col_buf[0][2])
						cur2 <= nxt;
					dot_col_buf[0]<=8'b11110011&dot_col_buf[0];
					dot_col_buf[1]<=8'b11110011&dot_col_buf[1];
				end
				5'hc:begin
					//signal[3]<=1'b0;
					if(dot_col_buf[0][0])
						cur2 <= nxt;
					dot_col_buf[0]<=8'b11111100&dot_col_buf[0];
					dot_col_buf[1]<=8'b11111100&dot_col_buf[1];
				end
				5'hb:begin
					//signal[4]<=1'b0;
					if(dot_col_buf[2][6])
						cur2 <= nxt;
					dot_col_buf[2]<=8'b00111111&dot_col_buf[2];
					dot_col_buf[3]<=8'b00111111&dot_col_buf[3];
				end
				5'h3:begin
					//signal[5]<=1'b0;
					if(dot_col_buf[2][4])
						cur2 <= nxt;
					dot_col_buf[2]<=8'b11001111&dot_col_buf[2];
					dot_col_buf[3]<=8'b11001111&dot_col_buf[3];
				end
				5'h6:begin
					//signal[6]<=1'b0;
					if(dot_col_buf[2][2])
						cur2 <= nxt;
					dot_col_buf[2]<=8'b11110011&dot_col_buf[2];
					dot_col_buf[3]<=8'b11110011&dot_col_buf[3];
				end
				5'h9:begin
				if(dot_col_buf[2][0])
						cur2 <= nxt;
					dot_col_buf[2]<=8'b11111100&dot_col_buf[2];
					dot_col_buf[3]<=8'b11111100&dot_col_buf[3];
				end
				5'ha:begin
				if(dot_col_buf[4][6])
						cur2 <= nxt;
					dot_col_buf[4]<=8'b00111111&dot_col_buf[4];
					dot_col_buf[5]<=8'b00111111&dot_col_buf[5];
				end
				5'h2:begin
				if(dot_col_buf[4][4])
						cur2 <= nxt;
					dot_col_buf[4]<=8'b11001111&dot_col_buf[4];
					dot_col_buf[5]<=8'b11001111&dot_col_buf[5];
				end
				5'h5:begin
				if(dot_col_buf[4][2])
						cur2 <= nxt;
					dot_col_buf[4]<=8'b11110011&dot_col_buf[4];
					dot_col_buf[5]<=8'b11110011&dot_col_buf[5];
				end
				5'h8:begin
					//signal[11]<=1'b0;
					if(dot_col_buf[4][0])
						cur2 <= nxt;
					dot_col_buf[4]<=8'b11111100&dot_col_buf[4];
					dot_col_buf[5]<=8'b11111100&dot_col_buf[5];
				end
				5'h0:begin
				if(dot_col_buf[6][6])
						cur2 <= nxt;
					dot_col_buf[6]<=8'b00111111&dot_col_buf[6];
					dot_col_buf[7]<=8'b00111111&dot_col_buf[7];
				end
				5'h1:begin
				if(dot_col_buf[6][4])
						cur2 <= nxt;
					dot_col_buf[6]<=8'b11001111&dot_col_buf[6];
					dot_col_buf[7]<=8'b11001111&dot_col_buf[7];
				end
				5'h4:begin
				if(dot_col_buf[6][2])
						cur2 <= nxt;
					dot_col_buf[6]<=8'b11110011&dot_col_buf[6];
					dot_col_buf[7]<=8'b11110011&dot_col_buf[7];
				end
				5'h7:begin
				if(dot_col_buf[6][0])
						cur2 <= nxt;
					dot_col_buf[6]<=8'b11111100&dot_col_buf[6];
					dot_col_buf[7]<=8'b11111100&dot_col_buf[7];
				end
			endcase
			for(it=0;it<16;it=it+1) begin
				if(signal[it]==1'b1) begin
				   // clock divider for stay time
					if(count[it]==32'd500) begin
						count[it]<=32'd0;
						case(it)
							0:begin
								signal[0]<=1'b0;
								dot_col_buf[0]<=8'b00111111&dot_col_buf[0];
								dot_col_buf[1]<=8'b00111111&dot_col_buf[1];
							end
							1:begin
								signal[1]<=1'b0;
								dot_col_buf[0]<=8'b11001111&dot_col_buf[0];
								dot_col_buf[1]<=8'b11001111&dot_col_buf[1];
							end
							2:begin
								signal[2]<=1'b0;
								dot_col_buf[0]<=8'b11110011&dot_col_buf[0];
								dot_col_buf[1]<=8'b11110011&dot_col_buf[1];
							end
							3:begin
								signal[3]<=1'b0;
								dot_col_buf[0]<=8'b11111100&dot_col_buf[0];
								dot_col_buf[1]<=8'b11111100&dot_col_buf[1];
							end
							4:begin
								signal[4]<=1'b0;
								dot_col_buf[2]<=8'b00111111&dot_col_buf[2];
								dot_col_buf[3]<=8'b00111111&dot_col_buf[3];
							end
							5:begin
								signal[5]<=1'b0;
								dot_col_buf[2]<=8'b11001111&dot_col_buf[2];
								dot_col_buf[3]<=8'b11001111&dot_col_buf[3];
							end
							6:begin
								signal[6]<=1'b0;
								dot_col_buf[2]<=8'b11110011&dot_col_buf[2];
								dot_col_buf[3]<=8'b11110011&dot_col_buf[3];
							end
							7:begin
								signal[7]<=1'b0;
								dot_col_buf[2]<=8'b11111100&dot_col_buf[2];
								dot_col_buf[3]<=8'b11111100&dot_col_buf[3];
							end
							8:begin
								signal[8]<=1'b0;
								dot_col_buf[4]<=8'b00111111&dot_col_buf[4];
								dot_col_buf[5]<=8'b00111111&dot_col_buf[5];
							end
							9:begin
								signal[9]<=1'b0;
								dot_col_buf[4]<=8'b11001111&dot_col_buf[4];
								dot_col_buf[5]<=8'b11001111&dot_col_buf[5];
							end
							10:begin
								signal[10]<=1'b0;
								dot_col_buf[4]<=8'b11110011&dot_col_buf[4];
								dot_col_buf[5]<=8'b11110011&dot_col_buf[5];
							end
							11:begin
								signal[11]<=1'b0;
								dot_col_buf[4]<=8'b11111100&dot_col_buf[4];
								dot_col_buf[5]<=8'b11111100&dot_col_buf[5];
							end
							12:begin
								signal[12]<=1'b0;
								dot_col_buf[6]<=8'b00111111&dot_col_buf[6];
								dot_col_buf[7]<=8'b00111111&dot_col_buf[7];
							end
							13:begin
								signal[13]<=1'b0;
								dot_col_buf[6]<=8'b11001111&dot_col_buf[6];
								dot_col_buf[7]<=8'b11001111&dot_col_buf[7];
							end
							14:begin
								signal[14]<=1'b0;
								dot_col_buf[6]<=8'b11110011&dot_col_buf[6];
								dot_col_buf[7]<=8'b11110011&dot_col_buf[7];
							end
							15:begin
								signal[15]<=1'b0;
								dot_col_buf[6]<=8'b11111100&dot_col_buf[6];
								dot_col_buf[7]<=8'b11111100&dot_col_buf[7];
							end
						endcase
					end	
					else begin
						count[it] <= count[it] + 32'd1;
					end
				end
				else begin end
			end
		end
	end
endmodule

module checkkeypad (game_mode,clk,rst,keypadRow,keypadCol,keypadBuf);  // output keypad buffer
	input clk,rst;
	input game_mode;
	input [3:0]keypadCol;
	output reg[3:0]keypadRow;
	output reg [4:0]keypadBuf;
	reg [31:0]keypadDelay;
	
	always @(posedge clk or negedge rst)
	begin 
		if (!rst)
		begin
			keypadRow <= 4'b1110;
			keypadBuf <= 5'b11111;
			keypadDelay <= 31'd0;
		end
		else if (game_mode!=1)
		begin
			keypadRow <= 4'b1110;
			keypadBuf <= 5'b11111;
			keypadDelay <= 31'd0;
		end
		else
		begin
			if (keypadDelay == 32'd250000) 
			begin 
				keypadDelay <= 31'd0;
				case ({keypadRow, keypadCol})
					8'b1110_1110: keypadBuf <= 5'h7;
					8'b1110_1101: keypadBuf <= 5'h4;
					8'b1110_1011: keypadBuf <= 5'h1;
					8'b1110_0111: keypadBuf <= 5'h0;
					8'b1101_1110: keypadBuf <= 5'h8;
					8'b1101_1101: keypadBuf <= 5'h5;
					8'b1101_1011: keypadBuf <= 5'h2;
					8'b1101_0111: keypadBuf <= 5'ha;
					8'b1011_1110: keypadBuf <= 5'h9;
					8'b1011_1101: keypadBuf <= 5'h6;
					8'b1011_1011: keypadBuf <= 5'h3;
					8'b1011_0111: keypadBuf <= 5'hb;
					8'b0111_1110: keypadBuf <= 5'hc;
					8'b0111_1101: keypadBuf <= 5'hd;
					8'b0111_1011: keypadBuf <= 5'he;
					8'b0111_0111: keypadBuf <= 5'hf;
					default: keypadBuf <= keypadBuf;
				endcase
				case (keypadRow)
					4'b1110: keypadRow <= 4'b1101;
					4'b1101: keypadRow <= 4'b1011;
					4'b1011: keypadRow <= 4'b0111;
					4'b0111: keypadRow <= 4'b1110;
					default: keypadRow <= 4'b1110;
				endcase
			end
			else
				keypadDelay <= keypadDelay + 1'b1;
		end
	end
endmodule

module clk_divide(clk, rst, div_clk, frequency);
input clk, rst;
input [31:0] frequency;
output div_clk;

reg div_clk;
reg [31:0] count;

always@(posedge clk)
begin
	if(!rst)
	begin
		count <= 32'd0;
		div_clk <= 1'b0;
	end
	else
	begin
		if(count==frequency)
		begin
			count <= 32'd0;
			div_clk <= ~div_clk;
		end
		else
		begin
			count <= count + 32'd1;
		end
	end
end
endmodule

module BCD(in, out,game_mode);
input game_mode;
input [3:0] in;
output [6:0] out;

reg [6:0] out;

always@(in or game_mode)
	begin
		case(in)
			1:	out=7'b1111001;
			2:	out=7'b0100100;
			3:	out=7'b0110000;
			4:	out=7'b0011001;
			5:	out=7'b0010010;
			6:	out=7'b0000010;
			7:	out=7'b1111000;
			8:	out=7'b0000000;
			9:	out=7'b0010000;
			10:out=7'b0001000;
			11:out=7'b0000011;
			12:out=7'b1000110;
			13:out=7'b0100001;
			14:out=7'b0000110;
			15:out=7'b0001110;
			default:	begin
			case(game_mode) 
			0:out=7'b1111111;
			1:out=7'b1000000;
			endcase
			end
		endcase
	end
endmodule
