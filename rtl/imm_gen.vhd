library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity imm_gen is
    port (
        instr   : in  std_logic_vector(31 downto 0);
        imm_out : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of imm_gen is
begin
    process(instr)
        variable opcode : std_logic_vector(6 downto 0);
    begin
        opcode := instr(6 downto 0);
        
        case opcode is
            -- Type-I (ADDI, ANDI, LW, etc.)
            when "0010011" | "0000011" =>
                imm_out <= std_logic_vector(resize(signed(instr(31 downto 20)), 32));

            -- Type-S (SW)
            when "0100011" =>
                imm_out <= std_logic_vector(resize(signed(instr(31 downto 25) & instr(11 downto 7)), 32));

            -- Type-B (BEQ, BNE)
            when "1100011" =>
                imm_out <= std_logic_vector(
                               resize(
                                   signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'),
                                   32
                               )
                           );

            -- Par défaut
            when others =>
                imm_out <= (others => '0');
        end case;
    end process;
end architecture;