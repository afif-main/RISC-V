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
        -- === TESTS ARITHMÉTIQUES & LOGIQUES (I-Type & R-Type) ===
        0  => x"00A00093", -- PC=0x00: addi x1, x0, 10  | x1 = 10 (0xA)
        1  => x"01400113", -- PC=0x04: addi x2, x0, 20  | x2 = 20 (0x14)
        2  => x"002081B3", -- PC=0x08: add  x3, x1, x2  | x3 = 30 (0x1E)
        3  => x"40110233", -- PC=0x0C: sub  x4, x2, x1  | x4 = 10 (0xA)
        4  => x"0020F2B3", -- PC=0x10: and  x5, x1, x2  | x5 = 0  (0x0)
        5  => x"0020E333", -- PC=0x14: or   x6, x1, x2  | x6 = 30 (0x1E)
        6  => x"00209413", -- PC=0x18: slli x8, x1, 2   | x8 = 40 (0x28) (10 décalé de 2)

        -- === TESTS MÉMOIRE (S-Type & I-Type) ===
        7  => x"00802023", -- PC=0x1C: sw   x8, 0(x0)   | RAM[0] = 40
        8  => x"00002483", -- PC=0x20: lw   x9, 0(x0)   | x9 = 40 (0x28)

        -- === TESTS BRANCHEMENTS (B-Type) ===
        9  => x"00849463", -- PC=0x24: bne  x9, x8, +8  | x9 et x8 valent 40. Le saut ÉCHOUE.
        10 => x"00848663", -- PC=0x28: beq  x9, x8, +12 | x9 et x8 valent 40. Le saut RÉUSSIT (vers PC=0x34).
        11 => x"00100513", -- PC=0x2C: addi x10, x0, 1  | PIÈGE : Ne doit pas s'exécuter !
        12 => x"00100513", -- PC=0x30: addi x10, x0, 1  | PIÈGE : Ne doit pas s'exécuter !

        -- === TESTS SAUTS INCONDITIONNELS (J-Type) ===
        13 => x"010005EF", -- PC=0x34: jal  x11, +16    | x11 = PC+4 (0x38). Saut vers PC=0x44.
        
        -- (Cible du JALR ci-dessous)
        14 => x"06300613", -- PC=0x38: addi x12, x0, 99 | x12 = 99 (0x63).
        15 => x"00000063", -- PC=0x3C: beq  x0, x0, 0   | FIN DU PROGRAMME : Boucle infinie sur 0x3C.
        16 => x"00000013", -- PC=0x40: nop              | 
        
        -- (Cible du JAL ci-dessus)
        17 => x"00700693", -- PC=0x44: addi x13, x0, 7  | x13 = 7. Preuve que le JAL a fonctionné.
        18 => x"00058067", -- PC=0x48: jalr x0, x11, 0  | Saut absolu vers x11 (0x38) ! (Retour en arrière)

        
    others => x"00000000"
);

begin
    -- word aligned (PC increments by 4

    data_out <= mem(to_integer(unsigned(address(31 downto 2))));
end rtl;
