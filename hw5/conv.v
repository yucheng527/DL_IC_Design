module conv(
    input clk, 
    input rst, 
    output reg finish,
    input start,

    output reg M0_R_req,
    output reg [31:0]M0_addr,
    input [31:0]M0_R_data,
    output reg [3:0]M0_W_req,
    output reg [31:0]M0_W_data,
  
    output reg  M1_R_req,
    output reg [31:0]M1_addr,
    input  [31:0]M1_R_data,
    output reg  [3:0]M1_W_req,
    output reg  [31:0]M1_W_data
);
reg [10:0] i, j;
reg [31:0] data [0:783];
reg [31:0] weight [0:8];
reg [31:0] bias;
reg [4:0] count;
reg signed [63:0] mult [0:8];
always@(posedge clk)begin
    if (start) begin
        M0_R_req <= 1;
        M0_addr <= 0;
        i <= -1;
        finish <= 0;
    end else if ($signed(i)<794) begin
        if (i<784) data[i] <= M0_R_data;
        else if (i<793) weight[i-784] <= M0_R_data;
        else bias <= M0_R_data;
        
        M0_addr <= M0_addr + 4;
        i <= i + 1;
    end else if (i == 794) begin
        M1_R_req <= 1;
        M1_W_req <= 4'b1111;
        M1_addr <= -8;
        i <= i+1;
        j <= 0;
        count <= 0;
    end else begin
        mult[0] <= $signed(data[j])*$signed(weight[0]);
        mult[1] <= $signed(data[j+1])*$signed(weight[1]);
        mult[2] <= $signed(data[j+2])*$signed(weight[2]);
        mult[3] <= $signed(data[j+28])*$signed(weight[3]);
        mult[4] <= $signed(data[j+29])*$signed(weight[4]);
        mult[5] <= $signed(data[j+30])*$signed(weight[5]);
        mult[6] <= $signed(data[j+56])*$signed(weight[6]);
        mult[7] <= $signed(data[j+57])*$signed(weight[7]);
        mult[8] <= $signed(data[j+58])*$signed(weight[8]);
        M1_W_data <=  mult[0][47:16] + {{31'b0},mult[0][15]}
                    + mult[1][47:16] + {{31'b0},mult[1][15]}
                    + mult[2][47:16] + {{31'b0},mult[2][15]}
                    + mult[3][47:16] + {{31'b0},mult[3][15]}
                    + mult[4][47:16] + {{31'b0},mult[4][15]}
                    + mult[5][47:16] + {{31'b0},mult[5][15]}
                    + mult[6][47:16] + {{31'b0},mult[6][15]}
                    + mult[7][47:16] + {{31'b0},mult[7][15]}
                    + mult[8][47:16] + {{31'b0},mult[8][15]}
                    + bias;
        if (count == 25) begin
            j <= j + 3;
            count <= 0;
        end 
        else begin
            j <= j + 1;
            count <= count + 1;
        end
        M1_addr <= M1_addr + 4;

        if (j==725) begin
            finish<=1;
        end
    end
end
endmodule
