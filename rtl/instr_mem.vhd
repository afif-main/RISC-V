library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instr_mem is
    port (
        address  : in  std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of instr_mem is
    type memory_array is array (0 to 255) of std_logic_vector(31 downto 0);
    signal mem : memory_array := (
    0 => x"00A00093", -- addi x1, x0, 10   (x1 = 10)
    1 => x"01400113", -- addi x2, x0, 20   (x2 = 20)
    2 => x"002081B3", -- add  x3, x1, x2   (x3 = 30)
    3 => x"00302023", -- sw   x3, 0(x0)    (store résultat en mémoire)
    4 => x"00310663", -- beq  x2, x3, +12  (saut à instruction 7)
    5 => x"00311863", -- bne  x2, x3, +16  (saut à instruction 9) <-- CORRIGÉ
    6 => x"00000013", -- NOP
    7 => x"00500193", -- addi x3, x0, 5    (instruction cible BEQ)
    8 => x"00000013", -- NOP
    9 => x"00600213", -- addi x4, x0, 6    (instruction cible BNE)
    others => x"00000000"
);

begin
    -- word aligned (PC increments by 4

    data_out <= mem(to_integer(unsigned(address(31 downto 2))));
end rtl;
