module Timer (
    input  wire       clk,           // Fast clock (e.g., 25 MHz)
    input  wire       rst,
    input  wire       start_timer,
    input  wire       one_hz_enable, // Slow enable pulse from divider
    input  wire [3:0] load_value,
    output reg        expired,
    output reg [3:0]  count
);
    
    reg counting;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count    <= 0;
            counting <= 0;
            expired  <= 0;
        end 
        else begin
            

            // Start the timer
            if (start_timer) begin
                count    <= load_value;
                counting <= 1;
					 expired<=0;
            end
            // Count down only on 1 Hz pulse
            else if (counting && one_hz_enable) begin
                if (count > 0) begin
                    count <= count - 1;
                end else if (count == 0) begin
                    count    <= 0;
                    counting <= 0;
                    expired  <= 1;
                end
            end
        end
    end
endmodule
