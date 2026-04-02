library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        a      : in  std_logic_vector(31 downto 0);
        b      : in  std_logic_vector(31 downto 0);
        op     : in  std_logic_vector(3 downto 0);
        result : out std_logic_vector(31 downto 0)
    );
end entity alu;

architecture rtl of alu is
begin
    process(a, b, op)
    begin
        case op is

            -- Arithmetic
            when "0000" => result <= std_logic_vector(signed(a) + signed(b)); -- ADD
            when "0001" => result <= std_logic_vector(signed(a) - signed(b)); -- SUB

            -- Logic
            when "0010" => result <= a and b; -- AND
            when "0011" => result <= a or b;  -- OR
            when "0100" => result <= a xor b; -- XOR

            -- Comparison
            when "0101" =>  -- SLT
                if signed(a) < signed(b) then
                    result <= x"00000001";
                else
                    result <= x"00000000";
                end if;

            -- Shifts
            when "0110" =>  -- SLL
                result <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b(4 downto 0)))));

            when "0111" =>  -- SRL
                result <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0)))));

            when "1000" =>  -- SRA
                result <= std_logic_vector(shift_right(signed(a), to_integer(unsigned(b(4 downto 0)))));

            when others =>
                result <= (others => '0');

        end case;
    end process;
end architecture rtl;