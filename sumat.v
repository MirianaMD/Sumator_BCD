//fac suma de pe nivelul de jos
module Sumator(
  input [3:0] x,y,
  output [3:0]op,
  output cor);
  wire cin;
  wire [3:0] c;
  assign cin='0;
  fac l0(.x(x[0]), .y(y[0]), .o(op[0]), .cin(cin), .c(c[0]));
  fac l1(.x(x[1]), .y(y[1]), .o(op[1]), .cin(c[0]), .c(c[1]));
  fac l2(.x(x[2]), .y(y[2]), .o(op[2]), .cin(c[1]), .c(c[2])); 
  fac l3(.x(x[3]), .y(y[3]), .o(op[3]), .cin(c[2]), .c(c[3]));
  assign cor=c[3] | (op[3]&op[2]) | (op[3]&op[1]);
endmodule

//sumator pentru carry(daca primesc 1/0 il adun si dupa verific daca e necesara corectia
module sumat(
    input coractual,//daca am avut carry de la prima sa nu il pierd
    input cinn,//cor anterioara
    input [3:0]oul,//suma de la nivelul de jos
    output [3:0]oul_cor,//ce iese de acolo si trebuie sa se fac corectia la asta (just in case)
    output cor_dupa_add);
    wire cin;
    wire [3:0] c;
    assign cin='0;
    fac l00(.x(cinn), .y(oul[0]), .o(oul_cor[0]), .cin(cin), .c(c[0]));
    fac l01(.x(cin), .y(oul[1]), .o(oul_cor[1]), .cin(c[0]), .c(c[1]));
    fac l02(.x(cin), .y(oul[2]), .o(oul_cor[2]), .cin(c[1]), .c(c[2]));
    fac l03(.x(cin), .y(oul[3]), .o(oul_cor[3]), .cin(c[2]), .c(c[3]));
    assign cor_dupa_add= (c[3] | (oul_cor[3]&oul_cor[2]) | (oul_cor[3]&oul_cor[1])) | coractual;
endmodule
  
//aici am nivelul de sus
module level2(
  input xx,
  input [3:0]yy,
  output [3:0] oo);
  wire cin;
  wire [2:0] c;
  assign cin='0;
  assign oo[0]=yy[0];
  fac ll0(.x(xx), .y(yy[1]), .cin(cin), .c(c[0]), .o(oo[1]));
  fac ll1(.x(xx), .y(yy[2]), .cin(c[0]), .c(c[1]), .o(oo[2]));
  fac ll2(.x(cin), .y(yy[3]), .cin(c[1]), .c(c[2]), .o(oo[3]));
endmodule

module  BCDp#(parameter k=16)(
  input [k-1:0] x,y,
  output [k:0] o);
  wire [(k/4)-1:0]cor;
  wire [k-1:0]op;
  wire [k-1:0]oleg;//oul_cor
  wire [(k/4):0]cor_dupa_add;
  
  assign cor_dupa_add[0]='0;
  
  generate
    genvar i;
    for(i=0;i<(k/4);i=i+1)
    begin
      Sumator leg1(.x(x[(i+1)*4-1:i*4]), .y(y[(i+1)*4-1:i*4]), .op(op[(i+1)*4-1:i*4]), .cor(cor[i]));
      sumat leg2(.coractual(cor[i]), .cinn(cor_dupa_add[i]), .oul(op[(i+1)*4-1:i*4]), .oul_cor(oleg[(i+1)*4-1:i*4]), .cor_dupa_add(cor_dupa_add[(i+1)]));
      level2 leg3(.xx(cor_dupa_add[(i+1)]), .yy(oleg[(i+1)*4-1:i*4]), .oo(o[(i+1)*4-1:i*4]));
    end
    assign o[k]=cor_dupa_add[(k/4)];
  endgenerate
  
endmodule