library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity position_ligne is
    port (
        clk       : IN  STD_LOGIC;
        reset_n   : IN  STD_LOGIC;
        vect_capt : IN  STD_LOGIC_VECTOR(6 downto 0);
        data_ready: IN  STD_LOGIC;
        pos_ligne : OUT SIGNED(3 downto 0)
    );
end position_ligne;

architecture rtl of position_ligne is
begin
    process(clk, reset_n)
        variable ppu        : integer range 0 to 6;
        variable pdu        : integer range 0 to 6;
        variable found_first: boolean;
        variable found_last : boolean;
        variable pos_int    : integer range -6 to 6;
    begin
        if reset_n = '0' then
            pos_ligne <= (others => '0');
        elsif rising_edge(clk) then
            if data_ready = '1' then
                ppu         := 0;
                pdu         := 0;
                found_first := false;
                found_last  := false;
                pos_int     := 0;

                for i in 0 to 6 loop
                    if vect_capt(i) = '1' and not found_first then
                        ppu         := i;
                        found_first := true;
                    end if;
                end loop;

                for i in 6 downto 0 loop
                    if vect_capt(i) = '1' and not found_last then
                        pdu        := i;
                        found_last := true;
                    end if;
                end loop;

                if vect_capt = "0000000" then
						  pos_ligne <= to_signed(7, 4);  -- valeur impossible normalement = code "pas de ligne"
					 else
						  pos_int := ppu + pdu - 6;
						  pos_ligne <= to_signed(pos_int, 4);
					 end if;
            end if;
        end if;
    end process;
end rtl;