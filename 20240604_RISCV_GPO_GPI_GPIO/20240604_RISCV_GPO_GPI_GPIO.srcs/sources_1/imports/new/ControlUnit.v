`timescale 1ns / 1ps
 
`include "RV32I_define.v"

module ControlUnit(
    input [6:0] opcode,
    input [2:0] func3,
    input [6:0] func7,
    //PC signal
    output reg pcload,
    //RegFiles signal
    output reg RFWriteEn,
    output reg RFWrDataSrcMuxSel,
    //ALU signal
    output reg [4:0] ALUControl,
    //Mux signal
    output reg aluSrcMuxSel,
    //Branch signal
    output reg branch,
    //BUS signal
    output reg write,
    //Jump Signal ((to mux sel))
    output reg RFWrDataJumpMuxSel,
    output reg jal,
    output reg jalr,
    //AUI Signal select mux signal///now �߰�
    output reg AUIPcSrcMuxSel
    
    );
     always @(*) begin
        case (opcode)
            `OPCODE_TYPE_R: begin
                pcload = 1'b1;
                RFWriteEn = 1'b1;
                aluSrcMuxSel = 1'b0;
                RFWrDataSrcMuxSel = 1'b0;  // ALU���� ���� ���
                write = 1'b0;
                branch = 1'b0;
                RFWrDataJumpMuxSel = 1'b0;
                jal = 1'b0; 
                jalr = 1'b0;
                AUIPcSrcMuxSel = 1'b0;                                       
            end
            `OPCODE_TYPE_I: begin
                pcload = 1'b1;
                RFWriteEn = 1'b1;
                aluSrcMuxSel = 1'b1;
                RFWrDataSrcMuxSel = 1'b0;  // ALU���� ���� ���
                write = 1'b0;
                branch = 1'b0;
                RFWrDataJumpMuxSel = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;                                           
                AUIPcSrcMuxSel = 1'b0;             
            end
            `OPCODE_TYPE_IL: begin
                pcload = 1'b1;
                RFWriteEn = 1'b1;
                aluSrcMuxSel = 1'b1; 
                RFWrDataSrcMuxSel = 1'b1;  // RAM Data
                write = 1'b0;
                branch = 1'b0;              // RAM Data �д´�
                RFWrDataJumpMuxSel = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                AUIPcSrcMuxSel = 1'b0;                                   
            end
            `OPCODE_TYPE_S: begin
                pcload = 1'b1;
                RFWriteEn = 1'b0;
                aluSrcMuxSel = 1'b1; 
                RFWrDataSrcMuxSel = 1'b1;  // RAM Data
                write = 1'b1;
                branch = 1'b0;              // RAM�� Data ����
                RFWrDataJumpMuxSel = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                AUIPcSrcMuxSel = 1'b0;                                  
            end
            `OPCODE_TYPE_B: begin
                pcload = 1'b1;
                RFWriteEn = 1'b0;
                aluSrcMuxSel = 1'b0; 
                RFWrDataSrcMuxSel = 1'b0;  // AluValue Data
                write = 1'b0;
                branch = 1'b1;             // Branch true
                RFWrDataJumpMuxSel = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                AUIPcSrcMuxSel = 1'b0;                                  
            end
            `OPCODE_TYPE_J: begin
                pcload = 1'b1;
                RFWriteEn = 1'b1;
                aluSrcMuxSel = 1'b1; 
                RFWrDataSrcMuxSel = 1'b0;  // AluValue Data
                write = 1'b0;
                branch = 1'b0;  
                RFWrDataJumpMuxSel = 1'b1;
                jal = 1'b1;
                jalr = 1'b0;
                AUIPcSrcMuxSel = 1'b0;                                           
            end
            `OPCODE_TYPE_JI: begin
                pcload = 1'b1;
                RFWriteEn = 1'b1;
                aluSrcMuxSel = 1'b1; 
                RFWrDataSrcMuxSel = 1'b0;  // AluValue Data
                write = 1'b0;
                branch = 1'b0;  
                RFWrDataJumpMuxSel = 1'b1;
                jal = 1'b0;
                jalr = 1'b1;
                AUIPcSrcMuxSel = 1'b0;                          
            end                                    
            `OPCODE_TYPE_LUI: begin // 
                pcload = 1'b1;
                RFWriteEn = 1'b1;
                aluSrcMuxSel = 1'b1; 
                RFWrDataSrcMuxSel = 1'b0;  // AluValue Data
                write = 1'b0;
                branch = 1'b0;  
                RFWrDataJumpMuxSel = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                AUIPcSrcMuxSel = 1'b0;   
            end
           `OPCODE_TYPE_AUIPC: begin // 
                pcload = 1'b1;
                RFWriteEn = 1'b1;
                aluSrcMuxSel = 1'b1; 
                RFWrDataSrcMuxSel = 1'b0;  // AluValue Data
                write = 1'b0;
                branch = 1'b0;  
                RFWrDataJumpMuxSel = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                AUIPcSrcMuxSel = 1'b1;   
            end
            /*
            OPCODE_TYPE_J:
            */
            default: begin
                pcload = 1'b1;
                RFWriteEn = 1'b1;
                aluSrcMuxSel = 1'b0;
                RFWrDataSrcMuxSel = 1'b0;
                write = 1'b0;
                branch = 1'b0;
                RFWrDataJumpMuxSel = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                AUIPcSrcMuxSel = 1'b1;   
            end
       endcase     
    end    

    always @(*) begin
    ALUControl = {func3,`ADD};
    case (opcode)
        `OPCODE_TYPE_R: begin
            case ({func7[5], func3})
                4'b0000: ALUControl = `ADD;
                4'b1000: ALUControl = `SUB;
                4'b0001: ALUControl = `SLL;
                4'b0101: ALUControl = `SRL;
                4'b1101: ALUControl = `SRA;
                4'b0010: ALUControl = `SLT;  
                4'b0011: ALUControl = `SLTU;
                4'b0100: ALUControl = `XOR;
                4'b0110: ALUControl = `OR;
                4'b0111: ALUControl = `AND;
                default: ALUControl = `ADD;
            endcase    
        end
            `OPCODE_TYPE_I: begin
            case({func7[5], func3})
                4'b0000 : ALUControl =`ADD;
                4'b0010 : ALUControl =`SLT;
                4'b0011 : ALUControl =`SLTU;
                4'b0100 : ALUControl =`XOR;
                4'b0110 : ALUControl =`OR;
                4'b0111 : ALUControl =`AND;
                
                4'b0001 : ALUControl =`SLLI;
                4'b0101 : ALUControl =`SRLI;
                4'b1101 : ALUControl =`SRAI;
                default : ALUControl =`ADD;
            endcase 
        end
        `OPCODE_TYPE_IL: begin
            case(func3)
            3'b000 : ALUControl = `LB ;
            3'b001 : ALUControl = `LH ;
            3'b010 : ALUControl = `ADD ;
            3'b100 : ALUControl = `LBU ;
            3'b101 : ALUControl = `LHU;
            endcase 
        end
        `OPCODE_TYPE_S: begin
             case(func3)
            3'b000 : ALUControl = `SB ;
            3'b001 : ALUControl = `SH ;
            3'b010 : ALUControl = `ADD ;
            endcase 
        end
        `OPCODE_TYPE_B: begin
            case(func3)
            3'b000 : ALUControl = `BEQ ;
            3'b001 : ALUControl = `BNE ;
            3'b100 : ALUControl = `BLT ;
            3'b101 : ALUControl = `BGE ;
            3'b110 : ALUControl = `BLTU;
            3'b111 : ALUControl = `BGEU;
            endcase 
        end
     `OPCODE_TYPE_LUI:begin
        ALUControl =`LUI;
        end
      `OPCODE_TYPE_AUIPC:begin
           ALUControl =`AUIPC;
           end       
       endcase
     end   
endmodule