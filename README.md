# Porsche-Anti-theft-System
# 🚗 FPGA-Based Anti-Theft Car Security System

This project implements a **digital anti-theft system for vehicles** using Verilog HDL on an FPGA board.  
The design integrates **debounced inputs, programmable timing parameters, finite state machines (FSMs), a fuel pump lock, siren activation, and a 7-segment display** for countdown visualization.

---

## ✨ Features
- 🔑 **Ignition & Hidden Switch Authentication** – Fuel pump powers only with correct sequence.
- 🚪 **Door Sensors (Driver & Passenger)** – Triggers alarms if unauthorized entry is detected.
- ⏱ **Reprogrammable Timers** – Arm delay, driver delay, passenger delay, and alarm duration can be dynamically updated.
- 🕒 **Accurate Timer** – One-second pulse divider drives countdown timers.
- 🔄 **Debouncing** – All noisy inputs (switches, buttons) are debounced for reliability.
- 🔊 **Siren & Status LED** – Visual and audio alerts on intrusion.
- 🔢 **7-Segment Countdown Display** – Displays active timer values.

---

## 📂 Project Structure
├── AntiTheftSystem.v       # Top-level module (integrates all components)
├── debounce.v              # Input debouncer for switches & buttons
├── Fuel_Pump.v             # Controls fuel pump authentication
├── Time_Parameters.v       # Stores & reprograms time values
├── OneHzDivider.v          # Clock divider for 1 Hz enable signal
├── Timer.v                 # Countdown timer with expiration flag
├── seven_segment.v         # Display timer value on 7-segment
├── anti_theft_fsm.v        # Main FSM handling states & transitions
└── constraints.ucf         # FPGA pin mappings (buttons, switches, LEDs, display)

## ⚙️ State Machine Design
The **Anti-Theft FSM** handles different system states:
- `S_ARMED_IDLE` → System armed, LED blinking.
- `S_TRIGGERED_COUNTDOWN` → Delay before alarm if door is opened.
- `S_SOUND_ALARM` → Siren and LED active.
- `S_DISARMED` → Valid ignition disables system.
- `S_WAIT_DRIVER_OPEN / CLOSE` → Ensures proper arming after usage.
- `S_ARM_DELAY_COUNTDOWN` → Delay before returning to armed state.

---

## 🛠 Requirements
- FPGA Board (e.g., Xilinx Spartan-6 / Artix-7 or similar)  
- Xilinx ISE / Vivado for synthesis & simulation  
- Verilog HDL
