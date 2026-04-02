library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rotation_ligne is
    port (
        clk      : IN  STD_LOGIC;
        reset_n  : IN  STD_LOGIC;
        start_rot: IN  STD_LOGIC;
        dir_rot  : IN  STD_LOGIC;
		  vect_capt: IN  STD_LOGIC_VECTOR(6 downto 0);
        fin_rot  : OUT STD_LOGIC;
        cmdL_Rot : OUT STD_LOGIC_VECTOR(13 downto 0);
        cmdR_Rot : OUT STD_LOGIC_VECTOR(13 downto 0)
        
    );
end rotation_ligne;

architecture CTRL_Rot of rotation_ligne is
    type etat_type is (ATTENTE, RUN);
    signal etat_courant : etat_type;
    constant VITESSE : STD_LOGIC_VECTOR(11 downto 0) := std_logic_vector(to_unsigned(2000, 12));

begin

    -- Process séquentiel
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            etat_courant <= ATTENTE;
        elsif rising_edge(clk) then
            case etat_courant is
                when ATTENTE =>
                    if start_rot = '1' then
                        etat_courant <= RUN;
                    end if;
                when RUN =>
                    if start_rot = '0' then
                        etat_courant <= ATTENTE;
                    end if;
            end case;
        end if;
    end process;

    -- Process combinatoire
    process(etat_courant, vect_capt, dir_rot)
    begin
        fin_rot  <= '0';
        cmdL_Rot <= (others => '0');
        cmdR_Rot <= (others => '0');

        case etat_courant is
            when ATTENTE =>
                null;

            when RUN =>
                if vect_capt(3) = '0' then
                    -- tourne selon dir_rot
                    cmdL_Rot <= '1' & dir_rot       & VITESSE;
                    cmdR_Rot <= '1' & (not dir_rot) & VITESSE;
                else
                    -- milieu de ligne atteint
                    cmdL_Rot <= (others => '0');
                    cmdR_Rot <= (others => '0');
                    fin_rot  <= '1';
                end if;

        end case;
    end process;

end CTRL_Rot;