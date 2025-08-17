// ===============================
// Anti-Theft FSM (Corrected for Trigger Delay -> Alarm)
// ===============================

module anti_theft_fsm (
    input  wire clk,
    input  wire reset,
    input  wire ignition,
    input  wire driver_door,
    input  wire passenger_door,
    input  wire expired,             // 1-cycle pulse from Timer

    output wire [1:0] interval,      // To Time_Parameters module
    output reg  start_timer,         // To Timer module (1-cycle pulse)
    output reg  led,
    output reg  siren
);

    // === States ===
    parameter S_ARMED_IDLE          = 3'd0,
              S_TRIGGERED_COUNTDOWN = 3'd1,
              S_SOUND_ALARM         = 3'd2,
              S_DISARMED            = 3'd3,
              S_WAIT_DRIVER_OPEN    = 3'd4,
              S_WAIT_DRIVER_CLOSE   = 3'd5,
              S_ARM_DELAY_COUNTDOWN = 3'd6;

    reg [2:0] state, next_state;

    // === Blink for armed idle ===
    reg blink_flag;
    reg [24:0] blink_counter;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            blink_counter <= 0;
            blink_flag    <= 0;
        end else if (state == S_ARMED_IDLE) begin
            if (blink_counter >= 25_000_000 - 1) begin
                blink_counter <= 0;
                blink_flag    <= ~blink_flag;
            end else
                blink_counter <= blink_counter + 1;
        end else begin
            blink_counter <= 0;
            blink_flag    <= 0;
        end
    end

    // Interval register for Timer
    reg [1:0] interval_reg;
    assign interval = interval_reg;

    // Passenger-first flag
    reg passenger_first, passenger_first_next;

    // Expired latch
    reg expired_latched;
    always @(posedge clk or posedge reset) begin
        if (reset)
            expired_latched <= 0;
        else if (expired)
            expired_latched <= 1;
        else if ( (state == S_TRIGGERED_COUNTDOWN && next_state == S_SOUND_ALARM) ||
                  (state == S_ARM_DELAY_COUNTDOWN && next_state == S_ARMED_IDLE)   ||
                  (state == S_SOUND_ALARM         && next_state == S_ARMED_IDLE) )
            expired_latched <= 0;
    end

    // State register + start_timer
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state           <= S_ARMED_IDLE;
            passenger_first <= 0;
            interval_reg    <= 0;
            start_timer     <= 0;
        end else begin
            state           <= next_state;
            passenger_first <= passenger_first_next;
            start_timer     <= 0;

            // Timer triggers when entering countdowns
            if (next_state != state) begin
                case (next_state)
                    S_TRIGGERED_COUNTDOWN: begin
                        interval_reg <= passenger_first ? 2'b10 : 2'b01; // T_PASS or T_DRIVER
                        start_timer  <= 1;
                    end
                    S_ARM_DELAY_COUNTDOWN: begin
                        interval_reg <= 2'b00; // T_ARM_DELAY
                        start_timer  <= 1;
                    end
                    S_SOUND_ALARM: begin
                        interval_reg <= 2'b11; // T_ALARM_ON
                        start_timer  <= 1;
                    end
                endcase
            end
        end
    end

    // Next state & outputs
    always @(*) begin
        led  = 0;
        siren = 0;
        next_state = state;
        passenger_first_next = passenger_first;

        case (state)

            // Armed Idle
            S_ARMED_IDLE: begin
                led = blink_flag;
                if (ignition)
                    next_state = S_DISARMED;
                else if (driver_door || passenger_door) begin
                    passenger_first_next = (passenger_door && !driver_door);
                    next_state = S_TRIGGERED_COUNTDOWN;
                end
            end

           // Trigger countdown (driver/passenger delay)
S_TRIGGERED_COUNTDOWN: begin
    led = 1;
    if (ignition)
        next_state = S_DISARMED;
    else if (!driver_door && !passenger_door)  // 🚪 all doors closed -> re-arm immediately
        next_state = S_ARMED_IDLE;
    else if (expired_latched)                  // countdown finished -> alarm
        next_state = S_SOUND_ALARM;
end


            // Sound alarm (only after delay)
            S_SOUND_ALARM: begin
                led   = 1;
                siren = 1;
                if (ignition)
                    next_state = S_DISARMED;
                else if (expired_latched)   // alarm duration finished
                    next_state = S_ARMED_IDLE;
            end

            // Disarmed
            S_DISARMED: begin
    if (!ignition) begin
        if (!driver_door && !passenger_door)
            next_state = S_ARMED_IDLE;   // Direct re-arm if no doors touched
			else if(driver_door || passenger_door)
			   next_state= S_WAIT_DRIVER_CLOSE;
        else
            next_state = S_WAIT_DRIVER_OPEN; // Normal path if doors were used
    end
end


            // Wait driver open
            S_WAIT_DRIVER_OPEN: begin
                if (driver_door || passenger_door)
                    next_state = S_WAIT_DRIVER_CLOSE;
            end

            // Wait driver close
            S_WAIT_DRIVER_CLOSE: begin
                if (!driver_door && !passenger_door)
                    next_state = S_ARM_DELAY_COUNTDOWN;
            end

            // Arm delay
            S_ARM_DELAY_COUNTDOWN: begin
                led = 1;
                if (driver_door || passenger_door)
                    next_state = S_WAIT_DRIVER_CLOSE;
                else if (expired_latched)
                    next_state = S_ARMED_IDLE;
            end
        endcase
    end

endmodule
