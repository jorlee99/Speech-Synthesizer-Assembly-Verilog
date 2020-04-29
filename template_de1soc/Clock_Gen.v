module Clock_Gen(inclk,divider,outclk);

input inclk;
reg[31:0] clk_count = 32'd0; //make it a register when ur using a variable in an always block
input [31:0] divider;

output reg outclk=0;

always @(posedge inclk)
begin

clk_count <= clk_count + 32'd1;

if (clk_count>=(divider-1))

begin
outclk <= ~outclk;
clk_count <= 32'd0;
end

end
endmodule
