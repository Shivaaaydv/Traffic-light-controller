# Traffic Light Controller (Verilog)

Verilog FSM for a traffic light with pedestrian button — simulation & testbench included.  
![Waveform](docs/waveform.png)




# Traffic-light-controller
Verilog Traffic Light Controller (FSM) + testbench + waveform
# Traffic Light Controller (Verilog)

**Description**  
Finite State Machine (FSM) based traffic light controller with North-South & East-West lanes and pedestrian request handling. RTL is synthesizable and testbench included.

## Features
- One-hot encoded FSM
- Parameterized timing
- Pedestrian request & safe handing off
- Icarus Verilog + GTKWave simulation

## Files
- `rtl/tlc.v` — main Verilog RTL
- `tb/tb_tlc.v` — testbench
- `docs/waveform.png` — simulation waveform (EDA Playground)

## How to simulate (local)
```bash
# compile and run
iverilog -o tlc_tb.vvp tb/tb_tlc.v rtl/tlc.v
vvp tlc_tb.vvp
gtkwave wave.vcd
