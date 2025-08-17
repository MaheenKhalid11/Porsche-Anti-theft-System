module Time_Parameters (
    input clk,                     // Clock signal
    input rst,                     // Reset signal
    input [1:0] interval,          // Interval input from FSM (2-bit selector for reading)
    input [1:0] time_parameter_selector, // Selector to choose which time to reprogram
    input [3:0] new_value,         // New time value for reprogramming
    input reprogram,               // Write enable signal to reprogram a parameter
    output [3:0] selected_time // Output the selected time value
);
    // Time parameters memory (4 values)
    reg [3:0] time_values [0:3]; // 4 values: T_ARM_DELAY, T_DRIVER_DELAY, T_PASSENGER_DELAY, T_ALARM_ON

    // Initialize default values on power-up or reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            time_values[0] <= 4'd2;  // T_ARM_DELAY
            time_values[1] <= 4'd5;   // T_DRIVER_DELAY
            time_values[2] <= 4'd8;  // T_PASSENGER_DELAY
            time_values[3] <= 4'd10;  // T_ALARM_ON
        end else if (reprogram) begin
            // Reprogram the selected time parameter based on the time_parameter_selector
            time_values[time_parameter_selector] <= new_value;
        end
    end

    // Select the time parameter based on the interval (FSM will give this as input)
   
      assign  selected_time = time_values[interval];  // Output the selected time value based on FSM's interval input
    
    
endmodule
