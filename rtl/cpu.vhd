library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    port (
        clk : in std_logic;
        rst : in std_logic
    );
end entity cpu;

architecture rtl of cpu is

    signal instr      : std_logic_vector(31 downto 0);
    signal we         : std_logic;
    signal alu_op     : std_logic_vector(3 downto 0);
    signal alu_src    : std_logic;
    signal mem_write  : std_logic;
    signal mem_to_reg : std_logic;
    signal branch     : std_logic;
    signal branch_ne  : std_logic;
    
    -- Nouveaux signaux pour les sauts
    signal jump       : std_logic;
    signal jalr       : std_logic;
    signal pc_to_reg  : std_logic;

begin

    ------------------------------------------------
    -- Control Unit
    ------------------------------------------------
    ctrl_inst : entity work.ctrl_unit
        port map (
            instr      => instr,
            we         => we,
            alu_op     => alu_op,
            alu_src    => alu_src,
            mem_write  => mem_write,
            mem_to_reg => mem_to_reg,
            branch     => branch,
            branch_ne  => branch_ne,
            jump       => jump,
            jalr       => jalr,
            pc_to_reg  => pc_to_reg
        );

    ------------------------------------------------
    -- Datapath
    ------------------------------------------------
    datapath_inst : entity work.datapath
        port map (
            clk        => clk,
            rst        => rst,
            we         => we,
            alu_op     => alu_op,
            alu_src    => alu_src,
            instr      => instr,
            mem_write  => mem_write,
            mem_to_reg => mem_to_reg,
            branch     => branch,
            branch_ne  => branch_ne,
            jump       => jump,
            jalr       => jalr,
            pc_to_reg  => pc_to_reg
        );

end architecture rtl;