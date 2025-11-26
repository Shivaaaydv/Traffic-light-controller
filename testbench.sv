// tb/tb_tlc.v
`timescale 1ns/1ps


module tb_tlc;
    reg clk;
    reg rst_n;
    reg ped_req;
    wire [2:0] ns_light;
    wire [2:0] ew_light;
    wire ped_walk;

    // instantiate with small timing params for fast sim
    tlc #(
        .T_NS_GREEN(8),
        .T_NS_YELLOW(2),
        .T_EW_GREEN(6),
        .T_EW_YELLOW(2),
        .T_PED(4)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .ped_req(ped_req),
        .ns_light(ns_light),
        .ew_light(ew_light),
        .ped_walk(ped_walk)
    );

    initial begin
        $dumpfile("wave.vcd"); // vcd for GTKWave
        $dumpvars(0, tb_tlc);
        clk = 0;
        rst_n = 0;
        ped_req = 0;
        #20;
        rst_n = 1;
        #50;
        // request a pedestrian crossing during EW green
        #70 ped_req = 1;
        #10 ped_req = 0;
        // another request later
        #200 ped_req = 1;
        #10 ped_req = 0;
        // long run
        #500 $finish;
    end

    // 10ns clock => 100MHz
    always #5 clk = ~clk;

endmodule
