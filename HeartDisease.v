// top module
`define TimeExpireSeven 32'd50000000
`define TimeExpireDot 13'd5000

module HeartDisease(    input game_mode,
								input clk,
                        input rst,
                        input btn1,
                        input btn2,
                       // output wire [6:0] seven1,
                       // output wire [6:0] seven2,
                        output wire [7:0] dot_row,
                        output wire [15:0] dot_col,
                        output wire led1,
                        output wire led2);

wire clk_seven, clk_dot;
wire [3:0] number1, number2;
wire btn1push, btn2push;

ClockDividerSeven (clk, rst, clk_seven);

ClockDivDot (clk, rst, clk_dot);

ButtonControl button1(btn1, clk, rst, btn1push);
ButtonControl button2(btn2, clk, rst, btn2push);

StateMachineControl (game_mode,clk_seven, rst, btn1push, btn2push, number1, number2, led1, led2);


DotMatrixDisplay dot(game_mode, clk_dot, number1, number2, rst, dot_row, dot_col);

//SevenSegmentDisplay sevenSegment1(number1, seven1);
//SevenSegmentDisplay sevenSegment2(number2, seven2);

endmodule

// finite state machine
module StateMachineControl( input game_mode,
									 input clk,
                            input rst,
                            input btn1push,
                            input btn2push,
                            output reg [3:0] number1,
                            output reg [3:0] number2,
                            output reg led1,
                            output reg led2);

reg [3:0] state, next;
reg [3:0] tmp1 = 4'd2, tmp2 = 4'd3;
parameter s0 = 4'd0, s1 = 4'd1, s2 = 4'd2;


// next state logic              
always @(*) begin
	if(!rst) begin
		next = s0;
   end
   else begin
		case (state)
			s0: begin
				if (btn1push) begin
					if (number1 == number2) begin
						next = s1;
					end
					else begin
						next = s2;
					end
				end
				else if (btn2push) begin
					if (number1 == number2) begin
						next = s2;
					end
					else begin
						next = s1;
					end
				end
				else 
					next = s0;
			end
			s1: begin
				next = s1;
			end
			s2: begin
				next = s2;
			end
		endcase
		case (next)
			s0: begin
				led1 = 0;
				led2 = 0;
			end
			s1: begin
				led1 = 1;
				led2 = 0;
			end
			s2: begin
				led1 = 0;
				led2 = 1;
			end
		endcase
	end
end

// state register
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		state <= s0;
		tmp1 <= 3'd2;
		tmp2 <= 3'd3;
		number1<=4'd2;
		number2<=4'd3;
	end
	else if(game_mode != 1'd0) begin
		state <= s0;
		tmp1 <= 3'd2;
		tmp2 <= 3'd3;
		number1<=4'd2;
		number2<=4'd3;
	end
	else begin
		if (state==s0) begin	
			number1 <= (number1 + tmp1) % 4'd10;
			number2 <= (number2 + tmp2) % 4'd10;
			tmp1 = tmp1 + 4'd1;
			tmp2 = tmp2 + 4'd1;
		end
	end
end

endmodule

// dot matrix display
module DotMatrixDisplay(    input game_mode,
									 input clk,
									 input [3:0] number1,
									 input [3:0] number2,
                            input rst,
                            output reg [7:0] dot_row,
                            output reg [15:0] dot_col);

reg [3:0] counter;
reg [3:0] row_count;

always @ (posedge clk or negedge rst) begin
    if(~rst)
    begin
        row_count<=4'd0;
    end
    else begin
	 if (game_mode==0)
    begin
		row_count <= row_count+4'd1;
		case(row_count)
			3'd0:dot_row<=8'b01111111;
			3'd1:dot_row<=8'b10111111;
			3'd2:dot_row<=8'b11011111;
			3'd3:dot_row<=8'b11101111;
			3'd4:dot_row<=8'b11110111;
			3'd5:dot_row<=8'b11111011;
			3'd6:dot_row<=8'b11111101;
			3'd7:dot_row<=8'b11111110;
			endcase
		case(number1)
		4'd0:
			case(row_count)
			3'd0:dot_col[7:0]<=8'b01111110;
			3'd1:dot_col[7:0]<=8'b01100110;
			3'd2:dot_col[7:0]<=8'b01100110;
			3'd3:dot_col[7:0]<=8'b01100110;
			3'd4:dot_col[7:0]<=8'b01100110;
			3'd5:dot_col[7:0]<=8'b01100110;
			3'd6:dot_col[7:0]<=8'b01100110;
			3'd7:dot_col[7:0]<=8'b01111110;
			endcase
		4'd1:
		    case(row_count)
		   3'd0:dot_col[7:0]<=8'b00111000;
			3'd1:dot_col[7:0]<=8'b11011000;
			3'd2:dot_col[7:0]<=8'b11011000;
			3'd3:dot_col[7:0]<=8'b00011000;
			3'd4:dot_col[7:0]<=8'b00011000;
			3'd5:dot_col[7:0]<=8'b00011000;
			3'd6:dot_col[7:0]<=8'b00011000;
			3'd7:dot_col[7:0]<=8'b01111110;
			endcase
		4'd2:
		    case(row_count)
		    3'd0:dot_col[7:0]<=8'b01111110;
			3'd1:dot_col[7:0]<=8'b00000110;
			3'd2:dot_col[7:0]<=8'b00000110;
			3'd3:dot_col[7:0]<=8'b01111110;
			3'd4:dot_col[7:0]<=8'b01111110;
			3'd5:dot_col[7:0]<=8'b01100000;
			3'd6:dot_col[7:0]<=8'b01100000;
			3'd7:dot_col[7:0]<=8'b01111110;
			endcase
		4'd3:
		    case(row_count)
		    3'd0:dot_col[7:0]<=8'b01111110;
			3'd1:dot_col[7:0]<=8'b00000110;
			3'd2:dot_col[7:0]<=8'b00000110;
			3'd3:dot_col[7:0]<=8'b01111110;
			3'd4:dot_col[7:0]<=8'b01111110;
			3'd5:dot_col[7:0]<=8'b00000110;
			3'd6:dot_col[7:0]<=8'b00000110;
			3'd7:dot_col[7:0]<=8'b01111110;
			endcase
		4'd4:
		    case(row_count)
		    3'd0:dot_col[7:0]<=8'b01100110;
			3'd1:dot_col[7:0]<=8'b01100110;
			3'd2:dot_col[7:0]<=8'b01100110;
			3'd3:dot_col[7:0]<=8'b01111110;
			3'd4:dot_col[7:0]<=8'b01111110;
			3'd5:dot_col[7:0]<=8'b00000110;
			3'd6:dot_col[7:0]<=8'b00000110;
			3'd7:dot_col[7:0]<=8'b00000110;
			endcase
		4'd5:
		    case(row_count)
		    3'd0:dot_col[7:0]<=8'b01111110;
			3'd1:dot_col[7:0]<=8'b01100000;
			3'd2:dot_col[7:0]<=8'b01100000;
			3'd3:dot_col[7:0]<=8'b01111110;
			3'd4:dot_col[7:0]<=8'b01111110;
			3'd5:dot_col[7:0]<=8'b00000110;
			3'd6:dot_col[7:0]<=8'b00000110;
			3'd7:dot_col[7:0]<=8'b01111110;
			endcase
		4'd6:
		    case(row_count)
		    3'd0:dot_col[7:0]<=8'b01100000;
			3'd1:dot_col[7:0]<=8'b01100000;
			3'd2:dot_col[7:0]<=8'b01100000;
			3'd3:dot_col[7:0]<=8'b01111110;
			3'd4:dot_col[7:0]<=8'b01111110;
			3'd5:dot_col[7:0]<=8'b01100110;
			3'd6:dot_col[7:0]<=8'b01100110;
			3'd7:dot_col[7:0]<=8'b01111110;
			endcase
		4'd7:
		    case(row_count)
		    3'd0:dot_col[7:0]<=8'b01111110;
			3'd1:dot_col[7:0]<=8'b01111110;
			3'd2:dot_col[7:0]<=8'b00000110;
			3'd3:dot_col[7:0]<=8'b00000110;
			3'd4:dot_col[7:0]<=8'b00000110;
			3'd5:dot_col[7:0]<=8'b00000110;
			3'd6:dot_col[7:0]<=8'b00000110;
			3'd7:dot_col[7:0]<=8'b00000110;
			endcase
		4'd8:
		    case(row_count)
		   3'd0:dot_col[7:0]<=8'b01111110;
			3'd1:dot_col[7:0]<=8'b01100110;
			3'd2:dot_col[7:0]<=8'b01100110;
			3'd3:dot_col[7:0]<=8'b01111110;
			3'd4:dot_col[7:0]<=8'b01111110;
			3'd5:dot_col[7:0]<=8'b01100110;
			3'd6:dot_col[7:0]<=8'b01100110;
			3'd7:dot_col[7:0]<=8'b01111110;
			endcase
		4'd9:
		    case(row_count)
		   3'd0:dot_col[7:0]<=8'b01111110;
			3'd1:dot_col[7:0]<=8'b01100110;
			3'd2:dot_col[7:0]<=8'b01100110;
			3'd3:dot_col[7:0]<=8'b01111110;
			3'd4:dot_col[7:0]<=8'b01111110;
			3'd5:dot_col[7:0]<=8'b00000110;
			3'd6:dot_col[7:0]<=8'b00000110;
			3'd7:dot_col[7:0]<=8'b01111110;
			endcase
		default:
			case(row_count)
			3'd0:dot_col[7:0]<=8'b01111110;
			3'd1:dot_col[7:0]<=8'b01111110;
			3'd2:dot_col[7:0]<=8'b01111110;
			3'd3:dot_col[7:0]<=8'b01111110;
			3'd4:dot_col[7:0]<=8'b01111110;
			3'd5:dot_col[7:0]<=8'b01111110;
			3'd6:dot_col[7:0]<=8'b01111110;
			3'd7:dot_col[7:0]<=8'b01111110;
			endcase
		endcase
			
		case(number2)
		4'd0:
			case(row_count)
			3'd0:dot_col[15:8]<=8'b01111110;
			3'd1:dot_col[15:8]<=8'b01100110;
			3'd2:dot_col[15:8]<=8'b01100110;
			3'd3:dot_col[15:8]<=8'b01100110;
			3'd4:dot_col[15:8]<=8'b01100110;
			3'd5:dot_col[15:8]<=8'b01100110;
			3'd6:dot_col[15:8]<=8'b01100110;
			3'd7:dot_col[15:8]<=8'b01111110;
			endcase
		4'd1:
		    case(row_count)
		   3'd0:dot_col[15:8]<=8'b00111000;
			3'd1:dot_col[15:8]<=8'b11011000;
			3'd2:dot_col[15:8]<=8'b11011000;
			3'd3:dot_col[15:8]<=8'b00011000;
			3'd4:dot_col[15:8]<=8'b00011000;
			3'd5:dot_col[15:8]<=8'b00011000;
			3'd6:dot_col[15:8]<=8'b00011000;
			3'd7:dot_col[15:8]<=8'b01111110;
			endcase
		4'd2:
		    case(row_count)
		    3'd0:dot_col[15:8]<=8'b01111110;
			3'd1:dot_col[15:8]<=8'b00000110;
			3'd2:dot_col[15:8]<=8'b00000110;
			3'd3:dot_col[15:8]<=8'b01111110;
			3'd4:dot_col[15:8]<=8'b01111110;
			3'd5:dot_col[15:8]<=8'b01100000;
			3'd6:dot_col[15:8]<=8'b01100000;
			3'd7:dot_col[15:8]<=8'b01111110;
			endcase
		4'd3:
		    case(row_count)
		    3'd0:dot_col[15:8]<=8'b01111110;
			3'd1:dot_col[15:8]<=8'b00000110;
			3'd2:dot_col[15:8]<=8'b00000110;
			3'd3:dot_col[15:8]<=8'b01111110;
			3'd4:dot_col[15:8]<=8'b01111110;
			3'd5:dot_col[15:8]<=8'b00000110;
			3'd6:dot_col[15:8]<=8'b00000110;
			3'd7:dot_col[15:8]<=8'b01111110;
			endcase
		4'd4:
		    case(row_count)
		    3'd0:dot_col[15:8]<=8'b01100110;
			3'd1:dot_col[15:8]<=8'b01100110;
			3'd2:dot_col[15:8]<=8'b01100110;
			3'd3:dot_col[15:8]<=8'b01111110;
			3'd4:dot_col[15:8]<=8'b01111110;
			3'd5:dot_col[15:8]<=8'b00000110;
			3'd6:dot_col[15:8]<=8'b00000110;
			3'd7:dot_col[15:8]<=8'b00000110;
			endcase
		4'd5:
		    case(row_count)
		    3'd0:dot_col[15:8]<=8'b01111110;
			3'd1:dot_col[15:8]<=8'b01100000;
			3'd2:dot_col[15:8]<=8'b01100000;
			3'd3:dot_col[15:8]<=8'b01111110;
			3'd4:dot_col[15:8]<=8'b01111110;
			3'd5:dot_col[15:8]<=8'b00000110;
			3'd6:dot_col[15:8]<=8'b00000110;
			3'd7:dot_col[15:8]<=8'b01111110;
			endcase
		4'd6:
		    case(row_count)
		    3'd0:dot_col[15:8]<=8'b01100000;
			3'd1:dot_col[15:8]<=8'b01100000;
			3'd2:dot_col[15:8]<=8'b01100000;
			3'd3:dot_col[15:8]<=8'b01111110;
			3'd4:dot_col[15:8]<=8'b01111110;
			3'd5:dot_col[15:8]<=8'b01100110;
			3'd6:dot_col[15:8]<=8'b01100110;
			3'd7:dot_col[15:8]<=8'b01111110;
			endcase
		4'd7:
		    case(row_count)
		    3'd0:dot_col[15:8]<=8'b01111110;
			3'd1:dot_col[15:8]<=8'b01111110;
			3'd2:dot_col[15:8]<=8'b00000110;
			3'd3:dot_col[15:8]<=8'b00000110;
			3'd4:dot_col[15:8]<=8'b00000110;
			3'd5:dot_col[15:8]<=8'b00000110;
			3'd6:dot_col[15:8]<=8'b00000110;
			3'd7:dot_col[15:8]<=8'b00000110;
			endcase
		4'd8:
		    case(row_count)
		   3'd0:dot_col[15:8]<=8'b01111110;
			3'd1:dot_col[15:8]<=8'b01100110;
			3'd2:dot_col[15:8]<=8'b01100110;
			3'd3:dot_col[15:8]<=8'b01111110;
			3'd4:dot_col[15:8]<=8'b01111110;
			3'd5:dot_col[15:8]<=8'b01100110;
			3'd6:dot_col[15:8]<=8'b01100110;
			3'd7:dot_col[15:8]<=8'b01111110;
			endcase
		4'd9:
		    case(row_count)
		    3'd0:dot_col[15:8]<=8'b01111110;
			3'd1:dot_col[15:8]<=8'b01100110;
			3'd2:dot_col[15:8]<=8'b01100110;
			3'd3:dot_col[15:8]<=8'b01111110;
			3'd4:dot_col[15:8]<=8'b01111110;
			3'd5:dot_col[15:8]<=8'b00000110;
			3'd6:dot_col[15:8]<=8'b00000110;
			3'd7:dot_col[15:8]<=8'b01111110;
			endcase
		default:
			case(row_count)
			3'd0:dot_col[15:8]<=8'b01111110;
			3'd1:dot_col[15:8]<=8'b01111110;
			3'd2:dot_col[15:8]<=8'b01111110;
			3'd3:dot_col[15:8]<=8'b01111110;
			3'd4:dot_col[15:8]<=8'b01111110;
			3'd5:dot_col[15:8]<=8'b01111110;
			3'd6:dot_col[15:8]<=8'b01111110;
			3'd7:dot_col[15:8]<=8'b01111110;
			endcase
		endcase
    end
	 end
end

endmodule

// button control 
module ButtonControl(   input btn,
                        input clk,
                        input rst,
                        output reg isPushed);
reg [31:0] cnt;
always@(posedge clk or negedge rst)
begin
    if(~rst)
    begin
        isPushed <= 1'b0;
        cnt <= 32'd0;
    end
    else
    begin
        if(cnt == 12500000)
        begin
            isPushed <= 1'b0;
            cnt  <= 32'd0;
        end
        else if(cnt[7:0] == 8'd0)
        begin
            isPushed <= (!btn)? 1'b1 : isPushed;
            cnt <= cnt + 32'b1;
        end
        else 
        begin
            cnt <= cnt + 32'b1;
        end
    end
end

endmodule

// seven segment clock divider
module ClockDividerSeven(  input clk,
									input rst,
									output reg clk_seven);
reg [31:0] count;
always@(posedge clk or negedge rst) begin
    if(!rst) begin
        count <= 32'd0;
        clk_seven <= 1'b0;
    end
    else begin
		if(count == `TimeExpireSeven) begin
			count <= 32'd0;
			clk_seven <= ~clk_seven;
		end
		else count <= count + 32'd1;
    end
end
endmodule

// dot display clock divider
module ClockDivDot(	input clk, 
							input rst, 
							output reg clk_dot);

reg [31:0] count;
always @(posedge clk or negedge rst) begin
	if (!rst) begin
		count <= 32'd0;
		clk_dot <= 1'b0;
	end
	else begin
		if (count == `TimeExpireDot) begin
			count <= 32'd0;
			clk_dot <= ~clk_dot;
		end
		else count <= count + 32'd1;
	end
end
endmodule
