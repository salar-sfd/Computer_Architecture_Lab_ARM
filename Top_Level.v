module Top_Level(
    input clk, rst
);
    wire [31:0] pc_IF, pc_IF_Reg, pc_EXE, pc_EXE_Reg, pc_MEM, pc_MEM_Reg, pc_WB, pc_WB_Reg;
    wire [31:0] inst_IF, inst_IF_Reg;

    // ID Stage
    wire [31:0] valRn_ID, valRm_ID;
    wire [23:0] signedImm24_ID;
    wire [11:0] shiftOperand_ID;
    wire [3:0] exeCmd_ID, destID_ID;
    wire imm_ID, writeBackEnID_ID, memReadEn_ID, memWriteEn_ID, b_ID, s_ID;
    wire [3:0] src1_ID, src2_ID;
    wire twoSrc_ID;

    // ID Stage Reg
    wire writeBackEn_ID_Reg, memReadEn_ID_Reg, memWriteEn_ID_Reg, b_ID_Reg, s_ID_Reg;
    wire[3:0] exeCmd_ID_Reg;
    wire[31:0] pc_ID_Reg, valRn_ID_Reg, valRm_ID_Reg;
    wire imm_ID_Reg;
    wire[11:0] shiftOperand_ID_Reg;
    wire[23:0] signedImm24_ID_Reg;
    wire[3:0] dest_ID_Reg;
    wire[3:0] statusReg_ID_Reg;

    // EXE Stage
    wire[31:0]resultALU_EXE, branchAddress_EXE;
    wire[3:0] statusReg_EXE;

    // EXE Stage Reg
    wire writeBackEn_EXE_Reg, memReadEn_EXE_Reg, memWriteEn_EXE_Reg;
    wire[31:0] resultALU_EXE_Reg, storeVal_EXE_Reg;
    wire[3:0] dest_EXE_Reg;

    // Status Reg
    wire[3:0] statusReg;

    // MEM Stage
    wire[31:0] memResult_MEM;

    // MEM Stage Reg
    wire writeBackEn_MEM_Reg, memReadEn_MEM_Reg;
    wire[31:0] resultALU_MEM_Reg, memResult_MEM_Reg;
    wire[3:0] dest_MEM_Reg;

    // WB Stage
    wire[31:0] writeBackValue_WB;
    wire[3:0] writeBackDest_WB;
    wire writeBackEn_WB;

    IF_Stage        IF(clk, rst, 1'b0, b_ID_Reg, branchAddress_EXE, pc_IF, inst_IF);
    IF_Stage_Reg    IF_Reg(clk, rst, 1'b0, b_ID_Reg, pc_IF, inst_IF, pc_IF_Reg, inst_IF_Reg);
    ID_Stage        ID(clk, rst, inst_IF_Reg, writeBackValue_WB, writeBackDest_WB, writeBackEn_WB, 1'b0, statusReg, valRn_ID, valRm_ID, signedImm24_ID, shiftOperand_ID,exeCmd_ID, destID_ID, imm_ID, writeBackEnID_ID, memReadEn_ID, memWriteEn_ID, b_ID, s_ID, src1_ID, src2_ID,  twoSrc_ID);
    ID_Stage_Reg    ID_Reg(clk, rst, b_ID_Reg, writeBackEnID_ID, memReadEn_ID, memWriteEn_ID, b_ID, s_ID, exeCmd_ID, pc_IF_Reg, valRn_ID, valRm_ID, imm_ID, shiftOperand_ID, signedImm24_ID, destID_ID, statusReg, writeBackEn_ID_Reg, memReadEn_ID_Reg, memWriteEn_ID_Reg, b_ID_Reg, s_ID_Reg, exeCmd_ID_Reg, pc_ID_Reg, valRn_ID_Reg, valRm_ID_Reg, imm_ID_Reg, shiftOperand_ID_Reg, signedImm24_ID_Reg, dest_ID_Reg, statusReg_ID_Reg);
    EXE_Stage       EXE(clk, rst, exeCmd_ID_Reg, memReadEn_ID_Reg, memWriteEn_ID_Reg, pc_ID_Reg, valRn_ID_Reg, valRm_ID_Reg, imm_ID_Reg, shiftOperand_ID_Reg, signedImm24_ID_Reg, statusReg_ID_Reg, resultALU_EXE, branchAddress_EXE, statusReg_EXE);
    Status_Reg      Status(clk, rst, s_ID_Reg, statusReg_EXE, statusReg);
    EXE_Stage_Reg   EXE_Reg(clk, rst, writeBackEn_ID_Reg, memReadEn_ID_Reg, memWriteEn_ID_Reg, resultALU_EXE, valRm_ID_Reg, dest_ID_Reg, writeBackEn_EXE_Reg, memReadEn_EXE_Reg, memWriteEn_EXE_Reg, resultALU_EXE_Reg, storeVal_EXE_Reg, dest_EXE_Reg);
    MEM_Stage       MEM(clk, rst, memReadEn_EXE_Reg, memWriteEn_EXE_Reg, resultALU_EXE_Reg, valRm_ID_Reg, memResult_MEM);
    MEM_Stage_Reg   MEM_Reg(clk, rst, writeBackEn_EXE_Reg, memReadEn_EXE_Reg, resultALU_EXE_Reg, memResult_MEM, dest_EXE_Reg, writeBackEn_MEM_Reg, memReadEn_MEM_Reg, resultALU_MEM_Reg, memResult_MEM_Reg, dest_MEM_Reg);
    WB_Stage        WB(clk, rst, dest_MEM_Reg, memResult_MEM_Reg, resultALU_MEM_Reg, memReadEn_MEM_Reg, writeBackEn_MEM_Reg, writeBackDest_WB, writeBackValue_WB, writeBackEn_WB);
endmodule

