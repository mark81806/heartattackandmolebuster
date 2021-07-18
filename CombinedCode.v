`include "HeartDisease.v"
module CombinedCode(clk,rst,switch, btn1, btn2,keypad_col,keypad_row, dot_row, dot_col, seven_right, led1, led2);

input clk,rst;
input switch;
//gm1:
input btn1, btn2;
input [3:0] keypad_col;
output [3:0] keypad_row;
output reg [7:0] dot_row;
output reg [15:0] dot_col;
//output wire [6:0] seven_left;
output wire [6:0] seven_right;
output wire led1, led2;
							
wire [15:0]col1;
wire [7:0]col2;
wire [7:0]row1;
wire[7:0]row2;
							
HeartDisease gm1(.game_mode(switch),.clk(clk),.rst(rst),.btn1(btn1),.btn2(btn2),
					.dot_row(row1),.dot_col(col1),.led1(led1),.led2(led2));
MoleBuster gm2(.game_mode(switch),.clk(clk),.rst(rst),.keypad_row(keypad_row),
					.keypad_col(keypad_col),.dot_row(row2),.dot_col(col2),.score(seven_right));
					
always@(*) begin
case(switch)
	1'd0:begin
		dot_col = col1;
		dot_row = row1;
	end
	1'd1:begin
		dot_col = {8'd0, col2};
		dot_row = row2;
	end
endcase
end

							
endmodule

