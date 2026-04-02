library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_unit is
    port (
        instr       : in  std_logic_vector(31 downto 0);
        we          : out std_logic;
        alu_op      : out std_logic_vector(3 downto 0);
        alu_src     : out std_logic;
        mem_write   : out std_logic;
        mem_to_reg  : out std_logic;
        branch      : out std_logic;
        branch_ne   : out std_logic;
        jump        : out std_logic; -- NOUVEAU : Saut inconditionnel
        jalr        : out std_logic; -- NOUVEAU : Différencie JAL et JALR
        pc_to_reg   : out std_logic  -- NOUVEAU : Sauvegarde PC+4
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
        -- Valeurs par défaut
        we         <= '0';
        alu_op     <= "0000";
        alu_src    <= '0';
        mem_write  <= '0';
        mem_to_reg <= '0';
        branch     <= '0'; 
        branch_ne  <= '0'; 
        jump       <= '0';
        jalr       <= '0';
        pc_to_reg  <= '0';

        case opcode is

        -- R-TYPE
        when "0110011" =>
            we <= '1';
            alu_src <= '0';
            case funct3 is
                when "000" =>
                    if funct7 = "0000000" then alu_op <= "0000"; -- ADD
                    elsif funct7 = "0100000" then alu_op <= "0001"; -- SUB
                    end if;
                when "111" => alu_op <= "0010"; -- AND
                when "110" => alu_op <= "0011"; -- OR
                when "100" => alu_op <= "0100"; -- XOR
                when "010" => alu_op <= "0101"; -- SLT
                when "001" => alu_op <= "0110"; -- SLL
                when "101" =>
                    if funct7 = "0000000" then alu_op <= "0111"; -- SRL
                    elsif funct7 = "0100000" then alu_op <= "1000"; -- SRA
                    end if;
                when others => alu_op <= "0000";
            end case;

        -- I-TYPE
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
                    if funct7 = "0000000" then alu_op <= "0111"; -- SRLI
                    elsif funct7 = "0100000" then alu_op <= "1000"; -- SRAI
                    end if;
                when others => alu_op <= "0000";
            end case;

        -- LOAD (lw)
        when "0000011" =>
            we         <= '1';
            alu_src    <= '1';
            alu_op     <= "0000";
            mem_write  <= '0';
            mem_to_reg <= '1';

        -- STORE (sw)
        when "0100011" =>
            we         <= '0';
            alu_src    <= '1';
            alu_op     <= "0000";
            mem_write  <= '1';
            mem_to_reg <= '0';
            
        -- BRANCH (beq/bne)
        when "1100011" =>
            we         <= '0';
            alu_src    <= '0';
            alu_op     <= "0001"; -- Soustraction pour comparer
            mem_write  <= '0';
            mem_to_reg <= '0';
            case funct3 is
                when "000" => branch <= '1'; branch_ne <= '0'; -- BEQ
                when "001" => branch <= '1'; branch_ne <= '1'; -- BNE
                when others => branch <= '0'; branch_ne <= '0';
            end case ;

        -- JAL (Jump And Link) - Type J
        when "1101111" =>
            we         <= '1';   -- Sauvegarde de PC+4
            alu_src    <= '0';   
            alu_op     <= "0000";
            jump       <= '1';   -- Activation du saut
            pc_to_reg  <= '1';   -- On écrit PC+4 au lieu du résultat ALU

        -- JALR (Jump And Link Register) - Type I
        when "1100111" =>
            we         <= '1';   -- Sauvegarde de PC+4
            alu_src    <= '1';   -- ALU additionne rs1 + imm
            alu_op     <= "0000";
            jump       <= '1';   -- Activation du saut
            jalr       <= '1';   -- Spécifie que l'adresse vient de l'ALU
            pc_to_reg  <= '1';   -- On écrit PC+4 au lieu du résultat ALU

        when others =>
            null;

        end case;
    end process;
end architecture rtl;