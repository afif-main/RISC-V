library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_mem is
    port (
        clk      : in  std_logic;
        we       : in  std_logic;
        address  : in  std_logic_vector(31 downto 0);
        data_in  : in  std_logic_vector(31 downto 0);
        data_out : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of data_mem is
    type memory_array is array (0 to 255) of std_logic_vector(31 downto 0);
    signal ram : memory_array := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                ram(to_integer(unsigned(address(9 downto 2)))) <= data_in; -- Write on word aligned address
            end if;
        end if;

        data_out <= ram(to_integer(unsigned(address(9 downto 2)))); -- Read on every clock cycle (combinational read)
    end process;

end architecture rtl;
