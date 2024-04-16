module fac#(parameter k=16)(
  input x,y,cin,
  output o,c);
  
  assign o=x^y^cin;
  assign c=cin&y|cin&x|x&y;
endmodule