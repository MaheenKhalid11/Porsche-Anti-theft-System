module OneHzDivider(
    input  wire clk,          // 100 MHz clock input
    input  wire rst,          // Reset input
    output reg  one_hz_enable // 1-cycle enable pulse every second
);
    reg [26:0] counter; // Enough bits to hold 100,000,000

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter        <= 0;
            one_hz_enable  <= 0;
        end 
        else if (counter == 100_000_000 - 1) begin
            one_hz_enable <= 1;
            counter       <= 0;
        end 
        else begin
            one_hz_enable <= 0;
            counter       <= counter + 1;
        end
    end
endmodule
