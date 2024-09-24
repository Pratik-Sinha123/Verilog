`timescale 1ns / 1ps

module processor_tb;
  
    reg clk;
    reg rst;
    reg [15:0] instruction;

    wire [15:0] result;
  
    integer i;

    // Instantiate the Unit Under Test (UUT)
    processor uut (
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .result(result)
    );

    // Generating clock signal
    always 
      begin
        #5 clk = ~clk;
      end
  
   // Observe the waveforms on GTKWave
    initial
      begin
        $dumpfile("processor.vcd");
        $dumpvars(0,processor_tb);
      end

    // Task to initialize the registers with predefined values
    task initialize_registers;
        begin
            uut.rf.registers[0] = 16'h0001;
            uut.rf.registers[1] = 16'h0002;
            uut.rf.registers[2] = 16'h0003;
            uut.rf.registers[3] = 16'h0004;
            uut.rf.registers[4] = 16'h0005;
            uut.rf.registers[5] = 16'h0006;
            uut.rf.registers[6] = 16'h0007;
            uut.rf.registers[7] = 16'h0008;
        end
    endtask

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 0;
        instruction = 16'b0;

        // Apply reset
        rst = 1;
        #10;
        rst = 0;
        #10;

        // Initialize registers with predefined values
        initialize_registers();
        #10;

        // Display initial register values
        for (i = 0; i < 8; i = i + 1) begin
          $display("Initial R%d: %h", i, uut.rf.registers[i]);
        end

        // Test ADD instruction
        instruction = 16'b0001_000_001_010_000; // R2 = R0 + R1 = 1 + 2
        #10;
        $display("ADD Result: %h (Expected: %h)", result, 16'h0003);
        

        // Test SUB instruction
        instruction = 16'b0010_010_001_011_000; // R3 = R2 - R1 = 3 - 2
        #10;
        $display("SUB Result: %h (Expected: %h)", result, 16'h0001);

        // Test AND instruction
        instruction = 16'b0011_011_000_100_000; // R4 = R3 & R0 = 1 & 1
        #10;
        $display("AND Result: %h (Expected: %h)", result, 16'h0001);

        // Test OR instruction
        instruction = 16'b0100_100_011_101_000; // R5 = R4 | R3 = 1 | 1
        #10;
        $display("OR Result: %h (Expected: %h)", result, 16'h0001);

        // Test XOR instruction
        instruction = 16'b0101_101_100_110_000; // R6 = R5 ^ R4 = 1 ^ 1
        #10;
        $display("XOR Result: %h (Expected: %h)", result, 16'h0000);

        // Test NOT instruction
        instruction = 16'b0110_110_000_111_000; // R7 = ~R6 = ~0
        #10;
        $display("NOT Result: %h (Expected: %h)", result, 16'hFFFF);

        // Test LOAD instruction
        instruction = 16'b0111_000_000_000_000;
        #10;
        $display("LOAD Result: %h", result);
