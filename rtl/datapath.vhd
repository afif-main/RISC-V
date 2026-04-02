library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;

        -- control signals from control unit
        we         : in  std_logic;
        alu_op     : in  std_logic_vector(3 downto 0);
        alu_src    : in  std_logic;
        mem_to_reg : in  std_logic;
        mem_write  : in  std_logic;
        branch     : in  std_logic;
        branch_ne  : in  std_logic;
        jump       : in  std_logic; 
        jalr       : in  std_logic; 
        pc_to_reg  : in  std_logic; 
        lui_to_reg  : in  std_logic;
        auipc_to_reg: in  std_logic;

        -- instruction to control unit
        instr      : out std_logic_vector(31 downto 0)
    );
end entity datapath;

architecture rtl of datapath is

    -- PC
    signal pc         : std_logic_vector(31 downto 0);
    signal pc_next    : std_logic_vector(31 downto 0);
    signal pc_plus_4  : std_logic_vector(31 downto 0); -- NOUVEAU

    -- Instruction
    signal instr_i    : std_logic_vector(31 downto 0);

    -- Register file
    signal rs1_data   : std_logic_vector(31 downto 0);
    signal rs2_data   : std_logic_vector(31 downto 0);

    -- ALU
    signal alu_b      : std_logic_vector(31 downto 0);
    signal alu_res    : std_logic_vector(31 downto 0);

    -- Memory
    signal mem_data_out : std_logic_vector(31 downto 0);
    signal wb_data      : std_logic_vector(31 downto 0);

    -- Immediate
    signal imm : std_logic_vector(31 downto 0);

    -- Branch signals
    signal zero        : std_logic;
    signal take_branch : std_logic;
    signal pc_branch   : std_logic_vector(31 downto 0);

begin

    ------------------------------------------------
    -- PC REGISTER & PC NEXT LOGIC
    ------------------------------------------------
    pc_inst : entity work.pc
        port map (
            clk    => clk,
            rst    => rst,
            pc_in  => pc_next,
            pc_out => pc
        );

    pc_plus_4 <= std_logic_vector(unsigned(pc) + 4);

    -- Décision de branchement (BEQ/BNE)
    take_branch <= (branch and not branch_ne and zero) or 
                   (branch and branch_ne and not zero);

 
    -- Multiplexeur de l'adresse suivante
    pc_next <= (alu_res(31 downto 1) & '0') when (jump = '1' and jalr = '1') else
               pc_branch                    when (jump = '1' and jalr = '0') else
               pc_branch                    when take_branch = '1' else
               pc_plus_4;
    ------------------------------------------------
    -- INSTRUCTION MEMORY
    ------------------------------------------------
    instr_mem_inst : entity work.instr_mem
        port map (
            address  => pc,
            data_out => instr_i
        );

    instr <= instr_i;

    ------------------------------------------------
    -- REGISTER FILE & WRITE BACK LOGIC
    ------------------------------------------------
       -- Multiplexeur de l'adresse suivante (Gère +4, Branches, JAL, JALR,lui, auipc)
    wb_data <= pc_plus_4    when pc_to_reg = '1' else
               mem_data_out when mem_to_reg = '1' else 
               pc_branch    when auipc_to_reg = '1' else -- AUIPC (PC + imm)
               imm          when lui_to_reg = '1' else   -- LUI (imm 32 bits)
               alu_res;

    regfile_inst : entity work.reg_file
        port map (
            clk   => clk,
            we    => we,
            rs1   => instr_i(19 downto 15),
            rs2   => instr_i(24 downto 20),
            rd    => instr_i(11 downto 7),
            wd    => wb_data,
            rd1   => rs1_data,
            rd2   => rs2_data
        );

    ------------------------------------------------
    -- ALU & IMMEDIATES
    ------------------------------------------------
    alu_b <= rs2_data when alu_src = '0' else imm;
    
    zero <= '1' when rs1_data = rs2_data else '0';
    
    pc_branch <= std_logic_vector(unsigned(pc) + unsigned(imm));

    alu_inst : entity work.alu
        port map (
            a      => rs1_data,
            b      => alu_b,
            op     => alu_op,
            result => alu_res
        );

    imm_gen_inst : entity work.imm_gen
        port map (
            instr   => instr_i,
            imm_out => imm
        );

    ------------------------------------------------
    -- DATA MEMORY
    ------------------------------------------------
    data_mem_inst : entity work.data_mem
        port map (
            clk      => clk,
            we       => mem_write,
            address  => alu_res,
            data_in  => rs2_data,
            data_out => mem_data_out
        );

end architecture rtl;