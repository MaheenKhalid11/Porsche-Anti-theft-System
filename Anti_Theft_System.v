// ===================================
// Anti-Theft System Top Module (with Debounce)
// ===================================

 module AntiTheftSystem (
    input clk,                          // 25 MHz clock
    input rst,                          // System reset
    //extra input for simulation only
    //input one_hz_enable_inp,
    input ignition_switch,              // From car (noisy)
    input brake_switch,                 // From car (noisy)
    input hidden_switch,                // Hidden switch (noisy)
    input driver_door,                  // Door switch (noisy)
    input passenger_door,               // Door switch (noisy)
    input reprogram,                    // Reprogram button (optional debounce)
    input [1:0] time_parameter_selector, // Selector for reprogramming
    input [3:0] new_time_value,         // New time value for reprogramming
    output fuel_pump_power,             // To fuel pump
    output status_led,                  // Status indicator
    output siren_out ,                   // Siren output
	 output [6:0] segments,
	  output [3:0] an
);

    // ===== Debounced signals =====
    wire ignition_db, brake_db, hidden_db, driver_door_db, passenger_door_db, reprogram_db;
	  
	 wire [3:0] count_out;

    // ===== Debounce all noisy inputs =====
    debounce db_ignition (
        .reset_in(rst),
        .clock_in(clk),
        .noisy_in(ignition_switch),
        .clean_out(ignition_db)
    );

    debounce db_brake (
        .reset_in(rst),
        .clock_in(clk),
        .noisy_in(brake_switch),
        .clean_out(brake_db)
    );

    debounce db_hidden (
        .reset_in(rst),
        .clock_in(clk),
        .noisy_in(hidden_switch),
        .clean_out(hidden_db)
    );

    debounce db_driver (
        .reset_in(rst),
        .clock_in(clk),
        .noisy_in(driver_door),
        .clean_out(driver_door_db)
    );

    debounce db_passenger (
        .reset_in(rst),
        .clock_in(clk),
        .noisy_in(passenger_door),
        .clean_out(passenger_door_db)
    );

    debounce db_reprogram (
        .reset_in(rst),
        .clock_in(clk),
        .noisy_in(reprogram),
        .clean_out(reprogram_db)
    );

    // ===== Internal control signals =====
    wire [1:0] interval;
    wire [3:0] selected_time;
    wire start_timer;
    wire expired;
    wire one_hz_enable;

    // ========== Fuel Pump Module ==========
    Fuel_Pump fuelpump_inst (
        .clk(clk),
        .rst(rst),
        .ignition(ignition_db),
        .brake(brake_db),
       .hidden_switch(hidden_db),
        .power(fuel_pump_power)
    );

    // ========== Time Parameters Module ==========
    Time_Parameters timeparams_inst (
        .clk(clk),
        .rst(rst),
        .interval(interval),                                // from FSM
        .time_parameter_selector(time_parameter_selector), // from external
        .new_value(new_time_value),                        // from external
        .reprogram(reprogram_db),                          // debounced reprogram
        .selected_time(selected_time)                      // to Timer
    );

    // ========== One Hz Divider ==========
    OneHzDivider divider_inst (
        .clk(clk),
        .rst(rst),
            // from FSM
        .one_hz_enable(one_hz_enable)      // to Timer
    );

    // ========== Timer ==========
    Timer timer_inst (
        .clk(clk),
        .rst(rst),
        .start_timer(start_timer),         // from FSM
        .one_hz_enable(one_hz_enable),     // from divider
        .load_value(selected_time),        // from Time_Parameters
        .expired(expired) ,
        .count(count_out)		  // to FSM
    );
    seven_segment seg_inst (
        .in(count_out),
        .an(an),             
        .segments(segments)
    );
    // ========== Anti-Theft FSM ==========
    anti_theft_fsm fsm_inst (
        .clk(clk),
        .reset(rst),
        .ignition(ignition_db),
        .driver_door(driver_door_db),
        .passenger_door(passenger_door_db),
        .expired(expired),
        .interval(interval),               // to Time_Parameters
        .start_timer(start_timer),         // to Timer
        .led(status_led),                  // to external LED
        .siren(siren_out)                  // to Siren Generator
    );

endmodule
