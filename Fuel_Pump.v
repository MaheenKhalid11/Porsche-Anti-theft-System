`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2025 11:16:02 PM
// Design Name: 
// Module Name: Fuel_Pump
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Fuel_Pump(
input clk,rst,ignition,brake,hidden_switch,
output reg power
    );
    
 always@(posedge clk) begin
 if(rst) begin
 power<=0; end
 else begin
     if(!ignition) begin
     power<=0; end
     else if(ignition && brake && hidden_switch) begin
     power<=1; end
     else begin
     power<=0; end
     end
     end
endmodule
