module register_file (
    input wire clk,
    input wire [2:0] read_reg1,
    input wire [2:0] read_reg2,
    input wire [2:0] write_reg,
    input wire [15:0] write_data,
    input wire reg_write,
    output wire [15:0] read_data1,
    output wire [15:0] read_data2
);
    reg [15:0] registers [7:0];
    
    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];
    
    always @(posedge clk)
      begin
        if (reg_write) 
          begin
            registers[write_reg] <= write_data;
          end
     end
endmodule

module alu (
    input wire [15:0] a,
    input wire [15:0] b,
    input wire [3:0] alu_control,
    output reg [15:0] result
);
    always @(*) 
      begin
        case (alu_control)
            4'b0001: result = a + b;    // ADD
            4'b0010: result = a - b;    // SUB
            4'b0011: result = a & b;    // bitwise AND
            4'b0100: result = a | b;    // bitwise OR
            4'b0101: result = a ^ b;    // biwise XOR
            4'b0110: result = ~a;       // bitwise NOT
            default: result = 16'b0;
        endcase
    end
endmodule

module control_unit (
    input wire [3:0] opcode,
    output reg reg_write,
    output reg [3:0] alu_control,
    output reg mem_read,
    output reg mem_write
);
    always @(*) 
      begin
        // Initialize all signals to default values
        reg_write = 0;
        alu_control = 4'b0000;
        mem_read = 0;
        mem_write = 0;

        case (opcode)
            4'b0001: begin // ADD
                reg_write = 1;
                alu_control = 4'b0001; // ALU operation for ADD
            end
            4'b0010: begin // SUB
                reg_write = 1;
                alu_control = 4'b0010; // ALU operation for SUB
            end
            4'b0011: begin // AND
                reg_write = 1;
                alu_control = 4'b0011; // ALU operation for AND
            end
            4'b0100: begin // OR
                reg_write = 1;
                alu_control = 4'b0100; // ALU operation for OR
            end
            4'b0101: begin // XOR
                reg_write = 1;
                alu_control = 4'b0101; // ALU operation for XOR
            end
            4'b0110: begin // NOT
                reg_write = 1;
                alu_control = 4'b0110; // ALU operation for NOT
            end
            4'b0111: begin // LOAD
                reg_write = 1;
                alu_control = 4'b0000; // No ALU operation needed for LOAD
                mem_read = 1; // Read from memory
            end
            4'b1000: begin // STORE
                reg_write = 0;
                alu_control = 4'b0000; // No ALU operation needed for STORE
                mem_write = 1; // Write to memory
            end
            default: begin
                reg_write = 0;
                alu_control = 4'b0000; // Default ALU operation
            end
        endcase
       end
endmodule

module processor (
    input wire clk,
    input wire [15:0] instruction,
    output wire [15:0] result,
    output wire mem_read,
    output wire mem_write
);
    wire [2:0] read_reg1, read_reg2, write_reg;
    wire [15:0] read_data1, read_data2, write_data;
    wire reg_write;
    wire [3:0] alu_control;
  
    assign read_reg1 = instruction[11:9];
    assign read_reg2 = instruction[8:6];
    assign write_reg = instruction[5:3];

    register_file rf (
        .clk(clk),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .reg_write(reg_write),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    alu my_alu (
        .a(read_data1),
        .b(read_data2),
        .alu_control(alu_control),
        .result(result)
    );

    control_unit cu (
        .opcode(instruction[15:12]),
        .reg_write(reg_write),
        .alu_control(alu_control),
        .mem_read(mem_read),
        .mem_write(mem_write)
    );
  
      assign write_data = result;
endmodule
