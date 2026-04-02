library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_unit is
    port (
        instr   : in  std_logic_vector(31 downto 0);
        we      : out std_logic;
        alu_op  : out std_logic_vector(3 downto 0);
        alu_src : out std_logic;
        mem_write   : out std_logic; -- Écriture dans RAM (Store)
        mem_to_reg  : out std_logic;  -- Choisir RAM -> RegFile (Load)
        branch   : out std_logic;
        branch_ne: out std_logic -- pour BNE
    );
end entity ctrl_unit;

architecture rtl of ctrl_unit is
    signal opcode : std_logic_vector(6 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);
begin

    opcode <= instr(6 downto 0);
    funct3 <= instr(14 downto 12);
    funct7 <= instr(31 downto 25);

    process(opcode, funct3, funct7)
    begin
        -- defaults
        we      <= '0';
        alu_op  <= "0000";
        alu_src <= '0';
        mem_write  <= '0';
        mem_to_reg <= '0';
        branch    <= '0'; 
        branch_ne <= '0';  

        case opcode is

        ----------------------------------------------------------------
        -- R-TYPE (0110011)
        ----------------------------------------------------------------
        when "0110011" =>
            we <= '1';
            alu_src <= '0';

            case funct3 is
                when "000" =>
                    if funct7 = "0000000" then
                        alu_op <= "0000"; -- ADD
                    elsif funct7 = "0100000" then
                        alu_op <= "0001"; -- SUB
                    end if;

                when "111" => alu_op <= "0010"; -- AND
                when "110" => alu_op <= "0011"; -- OR
                when "100" => alu_op <= "0100"; -- XOR
                when "010" => alu_op <= "0101"; -- SLT
                when "001" => alu_op <= "0110"; -- SLL
                when "101" =>
                    if funct7 = "0000000" then
                        alu_op <= "0111"; -- SRL
                    elsif funct7 = "0100000" then
                        alu_op <= "1000"; -- SRA
                    end if;

                when others => alu_op <= "0000";
            end case;

        ----------------------------------------------------------------
        -- I-TYPE (0010011)
        ----------------------------------------------------------------
        when "0010011" =>
            we <= '1';
            alu_src <= '1';

            case funct3 is
                when "000" => alu_op <= "0000"; -- ADDI
                when "111" => alu_op <= "0010"; -- ANDI
                when "110" => alu_op <= "0011"; -- ORI
                when "100" => alu_op <= "0100"; -- XORI
                when "010" => alu_op <= "0101"; -- SLTI
                when "001" => alu_op <= "0110"; -- SLLI
                when "101" =>
                    if funct7 = "0000000" then
                        alu_op <= "0111"; -- SRLI
                    elsif funct7 = "0100000" then
                        alu_op <= "1000"; -- SRAI
                    end if;

                when others => alu_op <= "0000";
            end case;

        
        ----------------------------------------------------------------
        -- LOAD (lw) - Opcode 0000011
        ----------------------------------------------------------------
        when "0000011" =>
            we         <= '1';   -- On écrit le résultat dans un registre
            alu_src    <= '1';   -- On calcule l'adresse : rs1 + immédiat
            alu_op     <= "0000";-- L'ALU fait une ADDition
            mem_write  <= '0';   -- On ne veut pas écrire dans la RAM
            mem_to_reg <= '1';   -- IMPORTANT : On choisit la donnée venant de la RAM

        ----------------------------------------------------------------
        -- STORE (sw) - Opcode 0100011
        ----------------------------------------------------------------
        when "0100011" =>
            we         <= '0';   -- On n'écrit PAS dans le RegFile
            alu_src    <= '1';   -- On calcule l'adresse : rs1 + immédiat
            alu_op     <= "0000";-- L'ALU fait une ADDition
            mem_write  <= '1';   -- IMPORTANT : On active l'écriture dans la RAM
            mem_to_reg <= '0';   -- (Don't care, on n'écrit pas dans RegFile)
            
        ----------------------------------------------------------------
        -- BRANCH (beq) - Opcode 1100011 and (bne) - Opcode 1100011
        ----------------------------------------------------------------
        when "1100011" =>
            we         <= '0';   -- On n'écrit PAS dans le RegFile
            alu_src    <= '0';   -- On compare rs1 et rs2
            alu_op     <= "0001";-- L'ALU fait une SUBtraction pour comparer
            mem_write  <= '0';   -- On ne touche pas à la RAM
            mem_to_reg <= '0';   -- (Don't care, on n'écrit pas dans RegFile)

            case funct3 is
                when "000" =>  -- BEQ
                    branch <= '1';
                    branch_ne <= '0';

                when "001" =>  -- BNE
                    branch <= '1';
                    branch_ne <= '1';

                when others =>
                    branch <= '0';
                    branch_ne <= '0';
            
            end case ;
        
        

        when others =>
            null;


        end case;
    end process;

end architecture rtl;