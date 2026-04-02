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
        -- === 1. INITIALISATION (U-Type & I-Type) ===
        0  => x"12345137", -- PC=0x00: lui   x2, 0x12345   | x2 = 0x12345000 (Test LUI)
        1  => x"00001197", -- PC=0x04: auipc x3, 0x00001   | x3 = PC(4) + 0x1000 = 0x00001004 (Test AUIPC)
        2  => x"00A00213", -- PC=0x08: addi  x4, x0, 10    | x4 = 10 (0xA)
        3  => x"01400293", -- PC=0x0C: addi  x5, x0, 20    | x5 = 20 (0x14)
        
        -- === 2. APPEL DE FONCTION (J-Type) ===
        4  => x"010000EF", -- PC=0x10: jal   x1, +16       | Saut vers 0x20. Sauvegarde le retour (0x14) dans x1.
        
        -- === 4. RETOUR AU MAIN & MÉMOIRE (S-Type, I-Type, B-Type) ===
        5  => x"00602223", -- PC=0x14: sw    x6, 4(x0)     | RAM[4] = x6 (Le résultat de la fonction)
        6  => x"00402383", -- PC=0x18: lw    x7, 4(x0)     | x7 = RAM[4] (Vérification de la lecture)
        7  => x"00000063", -- PC=0x1C: beq   x0, x0, 0     | FIN : Boucle infinie pour stopper.
        
        -- ========================================================
        -- === 3. LA FONCTION MATHÉMATIQUE (Sous-programme)     ===
        -- ========================================================
        8  => x"00520333", -- PC=0x20: add   x6, x4, x5    | x6 = 10 + 20 = 30 (0x1E) (Test ALU)
        9  => x"00031463", -- PC=0x24: bne   x6, x0, +8    | Si x6 != 0, saute à 0x2C pour esquiver le piège.
        10 => x"06300313", -- PC=0x28: addi  x6, x0, 99    | PIÈGE : Ne doit pas s'exécuter !
        11 => x"00008067", -- PC=0x2C: jalr  x0, 0(x1)     | Fin de fonction : Retour au main (PC = x1 = 0x14)

        others => x"00000000"
    );

begin

    data_out <= mem(to_integer(unsigned(address(31 downto 2))));
end rtl;
