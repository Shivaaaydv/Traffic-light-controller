// rtl/tlc.v
`timescale 1ns/1ps
module tlc #(
    parameter integer CLK_FREQ_HZ = 50_000_000, // clock freq (for doc)
    parameter integer T_NS_GREEN = 10,    // cycles for NS green (for sim keep small)
    parameter integer T_NS_YELLOW = 3,
    parameter integer T_EW_GREEN = 10,
    parameter integer T_EW_YELLOW = 3,
    parameter integer T_PED = 8          // pedestrian walk time
)(
    input  wire clk,
    input  wire rst_n,        // active low reset
    input  wire ped_req,      // pedestrian request (pulse or level)
    output reg [2:0] ns_light, // {R, Y, G}
    output reg [2:0] ew_light,
    output reg ped_walk       // pedestrian walk signal (1 = walk)
);

    // One-hot states
    localparam S_NS_GREEN   = 5'b00001;
    localparam S_NS_YELLOW  = 5'b00010;
    localparam S_EW_GREEN   = 5'b00100;
    localparam S_EW_YELLOW  = 5'b01000;
    localparam S_PED        = 5'b10000;

    reg [4:0] state_n, state;
    reg [31:0] cnt;
    reg ped_pending;

    // Default lights assignment combinational
    always @(*) begin
        // default all red
        ns_light = 3'b100; // R=1, Y=0, G=0
        ew_light = 3'b100;
        ped_walk = 1'b0;
        case (state)
            S_NS_GREEN: begin ns_light = 3'b001; ew_light = 3'b100; end // NS green
            S_NS_YELLOW: begin ns_light = 3'b010; ew_light = 3'b100; end
            S_EW_GREEN: begin ew_light = 3'b001; ns_light = 3'b100; end
            S_EW_YELLOW: begin ew_light = 3'b010; ns_light = 3'b100; end
            S_PED: begin ns_light = 3'b100; ew_light = 3'b100; ped_walk = 1'b1; end
            default: begin ns_light = 3'b100; ew_light = 3'b100; end
        endcase
    end

    // State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_NS_GREEN;
            cnt <= 0;
            ped_pending <= 1'b0;
        end else begin
            state <= state_n;
            // latch pedestrian request (level or pulse)
            if (ped_req) ped_pending <= 1'b1;
            // decrement/count handled in next block
        end
    end

    // Next-state + counter logic
    always @(*) begin
        // default
        state_n = state;
    end

    // Synchronous counter/state transition
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_NS_GREEN;
            cnt <= 0;
            ped_pending <= 1'b0;
        end else begin
            case (state)
                S_NS_GREEN: begin
                    if (cnt < T_NS_GREEN-1) begin
                        cnt <= cnt + 1;
                    end else begin
                        cnt <= 0;
                        state <= S_NS_YELLOW;
                    end
                end
                S_NS_YELLOW: begin
                    if (cnt < T_NS_YELLOW-1) begin
                        cnt <= cnt + 1;
                    end else begin
                        cnt <= 0;
                        // if ped pending, go to PED only after both directions red? we'll go to EW green unless ped pending
                        if (ped_pending) begin
                            state <= S_PED;
                            ped_pending <= 1'b0;
                        end else begin
                            state <= S_EW_GREEN;
                        end
                    end
                end
                S_EW_GREEN: begin
                    if (cnt < T_EW_GREEN-1) begin
                        cnt <= cnt + 1;
                    end else begin
                        cnt <= 0;
                        state <= S_EW_YELLOW;
                    end
                end
                S_EW_YELLOW: begin
                    if (cnt < T_EW_YELLOW-1) begin
                        cnt <= cnt + 1;
                    end else begin
                        cnt <= 0;
                        if (ped_pending) begin
                            state <= S_PED;
                            ped_pending <= 1'b0;
                        end else begin
                            state <= S_NS_GREEN;
                        end
                    end
                end
                S_PED: begin
                    if (cnt < T_PED-1) begin
                        cnt <= cnt + 1;
                    end else begin
                        cnt <= 0;
                        // after pedestrian, go to NS green
                        state <= S_NS_GREEN;
                    end
                end
                default: begin
                    state <= S_NS_GREEN;
                    cnt <= 0;
                end
            endcase
        end
    end

endmodule
