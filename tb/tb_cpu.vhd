library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_pc is
end entity;

architecture sim of tb_pc is

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

begin

    -- 20 ns clock period
    clk <= not clk after 10 ns;

    cpu_inst: entity work.cpu
        port map(
            clk => clk,
            rst => rst
        );

    process
    begin
        -- Reset active
        rst <= '1';
        wait for 25 ns;
        rst <= '0';

        -- Let CPU execute instructions
        wait for 200 ns;

        assert false report "Simulation finished. Expect x1=5, x2=10, x3=15." severity note;
        wait;
    end process;

end architecture;