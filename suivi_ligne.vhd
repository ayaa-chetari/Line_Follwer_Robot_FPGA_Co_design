library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity suivi_ligne is
    port (
        clk      : IN  STD_LOGIC;
        reset_n  : IN  STD_LOGIC;
        pos_ligne: IN  SIGNED(3 downto 0);
        start_sl : IN  STD_LOGIC;
        fin_sl   : OUT STD_LOGIC;
        cmdL_SL  : OUT STD_LOGIC_VECTOR(13 downto 0);
        cmdR_SL  : OUT STD_LOGIC_VECTOR(13 downto 0)
    );
end suivi_ligne;

architecture CTRL_SL of suivi_ligne is
    type etat_type is (ATTENTE, RUN);
    signal etat_courant : etat_type;
    constant K          : integer := 100;
    constant VITESSE    : integer := 2200;

begin

    -- Process séquentiel
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            etat_courant <= ATTENTE;
        elsif rising_edge(clk) then
            case etat_courant is
                when ATTENTE =>
                    if start_sl = '1' then
                        etat_courant <= RUN;
                    end if;
                when RUN =>
                    if start_sl = '0' then
                        etat_courant <= ATTENTE;
                    end if;
            end case;
        end if;
    end process;

    -- Process combinatoire
    process(etat_courant, pos_ligne)
        variable cmdL_int : integer range -8192 to 8191;
        variable cmdR_int : integer range -8192 to 8191;
    begin
        fin_sl  <= '0';
        cmdL_SL <= (others => '0');
        cmdR_SL <= (others => '0');

        case etat_courant is
            when ATTENTE =>
                null;

            when RUN =>
                if pos_ligne /= to_signed(7, 4) then
                    cmdL_int := VITESSE - to_integer(pos_ligne) * K;
                    cmdR_int := VITESSE + to_integer(pos_ligne) * K;
                    if cmdL_int < 0    then cmdL_int := 0;    end if;
                    if cmdR_int < 0    then cmdR_int := 0;    end if;
                    if cmdL_int > 4095 then cmdL_int := 4095; end if;
                    if cmdR_int > 4095 then cmdR_int := 4095; end if;
                    cmdL_SL <= '1' & '0' & std_logic_vector(to_unsigned(cmdL_int, 12));
                    cmdR_SL <= '1' & '0' & std_logic_vector(to_unsigned(cmdR_int, 12));
                else
                    cmdL_SL <= (others => '0');
                    cmdR_SL <= (others => '0');
                    fin_sl  <= '1';
                end if;

        end case;
    end process;

end CTRL_SL;