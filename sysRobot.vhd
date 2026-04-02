LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY sysRobot IS
PORT (
    SW : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- switch
    KEY : IN STD_LOGIC_VECTOR(0 DOWNTO 0); -- reset
    CLOCK_50 : IN STD_LOGIC;
    LED : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- led

    DRAM_CLK, DRAM_CKE : OUT STD_LOGIC;
    DRAM_ADDR : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
    DRAM_BA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    DRAM_CS_N, DRAM_CAS_N, DRAM_RAS_N, DRAM_WE_N : OUT STD_LOGIC;
    DRAM_DQ : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    DRAM_DQM : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

    MTRR_P, MTRR_N, MTRL_P, MTRL_N : OUT STD_LOGIC;

    LTC_ADC_CONVST, LTC_ADC_SCK, LTC_ADC_SDI : OUT STD_LOGIC;
    LTC_ADC_SDO : IN STD_LOGIC;
    VCC3P3_PWRON_n : OUT STD_LOGIC
);
END sysRobot;

ARCHITECTURE Structure OF sysRobot IS

    -- Signaux internes
    SIGNAL INTER_L, INTER_R : STD_LOGIC_VECTOR(13 DOWNTO 0);
	 SIGNAL cmdL_SL_s, cmdR_SL_s : STD_LOGIC_VECTOR(13 DOWNTO 0);
	 SIGNAL cmdL_Rot_s, cmdR_Rot_s : STD_LOGIC_VECTOR(13 DOWNTO 0);
    
	 SIGNAL INTERCLK_40, INTERCLK_2 : STD_LOGIC;

    SIGNAL data0_internal       : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL data_ready_internal  : STD_LOGIC;
    SIGNAL niveau_internal      : STD_LOGIC_VECTOR(7 DOWNTO 0) := "01101000"; -- 104
    SIGNAL vect_capt_internal   : STD_LOGIC_VECTOR(6 DOWNTO 0);

    SIGNAL start_internal       : STD_LOGIC;
    SIGNAL fin_sl_internal      : STD_LOGIC;
    SIGNAL pos_ligne_internal   : STD_LOGIC_VECTOR(3 DOWNTO 0);
	 
	 SIGNAL fin_rot_internal	  : STD_LOGIC;
	 
	 
	 

    COMPONENT nios_system
    PORT (
        clk_clk : IN STD_LOGIC;
        reset_reset_n : IN STD_LOGIC;
        leds_export : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        switches_export : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

        sdram_wire_addr : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
        sdram_wire_ba : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        sdram_wire_cas_n : OUT STD_LOGIC;
        sdram_wire_cke : OUT STD_LOGIC;
        sdram_wire_cs_n : OUT STD_LOGIC;
        sdram_wire_dq : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        sdram_wire_dqm : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        sdram_wire_ras_n : OUT STD_LOGIC;
        sdram_wire_we_n : OUT STD_LOGIC;

        cntrl_left_export  : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
        cntrl_right_export : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);

        data_0r_external_connection_export      : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
        data_ready_r_external_connection_export : IN  STD_LOGIC;
        vect_cap_external_connection_export     : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
        niveau_external_connection_export       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		  start_sl_external_connection_export     : out   std_logic;                                        --     start_sl_external_connection.export
		  pos_ligne_external_connection_export    : in   std_logic_vector(3 downto 0);                      --    pos_ligne_external_connection.export
		  state_crtl_external_connection_export   : in    std_logic_vector(1 downto 0)  := (others => '0');  --   state_crtl_external_connection.export
		  sdram_clk_clk                           : out   std_logic  
	 );
    END COMPONENT;

    COMPONENT PWM_generation
    PORT (
        clk, reset_n : IN STD_LOGIC;
        s_writedataR, s_writedataL : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
        dc_motor_p_R, dc_motor_n_R, dc_motor_p_L, dc_motor_n_L : OUT STD_LOGIC
    );
    END COMPONENT;

    COMPONENT pll_2freqs
    PORT (
        areset : IN STD_LOGIC := '0';
        inclk0 : IN STD_LOGIC := '0';
        c0 : OUT STD_LOGIC;
        c1 : OUT STD_LOGIC
    );
    END COMPONENT;

    COMPONENT capteurs_sol_seuil
    PORT (
        clk : IN STD_LOGIC;
        reset_n : IN STD_LOGIC;

        data_capture : IN STD_LOGIC;
        data_readyr : OUT STD_LOGIC;

        data0r : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        data1r : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        data2r : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        data3r : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        data4r : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        data5r : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        data6r : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

        NIVEAU : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        vect_capt : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);

        ADC_CONVSTr : OUT STD_LOGIC;
        ADC_SCK : OUT STD_LOGIC;
        ADC_SDIr : OUT STD_LOGIC;
        ADC_SDO : IN STD_LOGIC
    );
    END COMPONENT;

    COMPONENT position_ligne
    PORT (
		  clk            : IN  STD_LOGIC;
        reset_n        : IN  STD_LOGIC;
        data_ready     : IN std_logic;
        vect_capt      : IN  STD_LOGIC_VECTOR(6 DOWNTO 0);
        pos_ligne      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
    END COMPONENT;

    COMPONENT suivi_ligne
    PORT (
        clk            : IN  STD_LOGIC;
        reset_n        : IN  STD_LOGIC;
        pos_ligne      : IN  SIGNED(3 DOWNTO 0);
        start_sl       : IN  STD_LOGIC;
        fin_sl         : OUT STD_LOGIC;
        cmdL_SL        : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
        cmdR_SL        : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
    );
    END COMPONENT;
	 
	 COMPONENT rotation_ligne
	 PORT (
		  clk      : IN  STD_LOGIC;
        reset_n  : IN  STD_LOGIC;
        start_rot: IN  STD_LOGIC;
        dir_rot  : IN  STD_LOGIC;
		  vect_capt: IN  STD_LOGIC_VECTOR(6 downto 0);
        fin_rot  : OUT STD_LOGIC;
        cmdL_Rot : OUT STD_LOGIC_VECTOR(13 downto 0);
        cmdR_Rot : OUT STD_LOGIC_VECTOR(13 downto 0)
	 );
	 END COMPONENT;

BEGIN

    VCC3P3_PWRON_n <= '0';

    -- Nios
    NiosII : nios_system
    PORT MAP (
        clk_clk => CLOCK_50,
        reset_reset_n => KEY(0),

		  sdram_clk_clk => DRAM_CLK,
        sdram_wire_addr => DRAM_ADDR,
        sdram_wire_ba => DRAM_BA,
        sdram_wire_cas_n => DRAM_CAS_N,
        sdram_wire_cke => DRAM_CKE,
        sdram_wire_cs_n => DRAM_CS_N,
        sdram_wire_dq => DRAM_DQ,
        sdram_wire_dqm => DRAM_DQM,
        sdram_wire_ras_n => DRAM_RAS_N,
        sdram_wire_we_n => DRAM_WE_N,
		  
		  leds_export => OPEN,
        switches_export => (others => '0'),

        cntrl_left_export => OPEN,
        cntrl_right_export => OPEN,
		  
		  data_0r_external_connection_export => (others => '0'),
		  data_ready_r_external_connection_export => '0',
		  vect_cap_external_connection_export => (others => '0'),
		  
		  niveau_external_connection_export => OPEN,
        
		  start_sl_external_connection_export => OPEN,
		  pos_ligne_external_connection_export => (others => '0'),
		  state_crtl_external_connection_export => (others => '0')
    );

    -- PWM moteurs
    PMW : PWM_generation
    PORT MAP (
        clk => CLOCK_50,
        reset_n => KEY(0),
        s_writedataL => INTER_L,
        s_writedataR => INTER_R,
        dc_motor_p_R => MTRR_P,
        dc_motor_n_R => MTRR_N,
        dc_motor_p_L => MTRL_P,
        dc_motor_n_L => MTRL_N
    );

    -- PLL
    PLL : pll_2freqs
    PORT MAP (
        inclk0 => CLOCK_50,
        areset => NOT KEY(0),
        c0 => INTERCLK_40,
        c1 => INTERCLK_2
    );

    -- Capteurs IR + seuil
    CAPTEUR : capteurs_sol_seuil
    PORT MAP (
        clk => INTERCLK_40,
        reset_n => KEY(0),
        data_capture => INTERCLK_2,

        data_readyr => data_ready_internal,

        data0r => data0_internal,
        data1r => OPEN,
        data2r => OPEN,
        data3r => OPEN,
        data4r => OPEN,
        data5r => OPEN,
        data6r => OPEN,

        NIVEAU => niveau_internal,
        vect_capt => vect_capt_internal,

        ADC_SCK => LTC_ADC_SCK,
        ADC_CONVSTr => LTC_ADC_CONVST,
        ADC_SDIr => LTC_ADC_SDI,
        ADC_SDO => LTC_ADC_SDO
    );

    -- Calcul de position de ligne
    POS_LINE : position_ligne
    PORT MAP (
		  clk => CLOCK_50,
        reset_n => KEY(0),
		  
        data_ready => data_ready_internal,
        vect_capt => vect_capt_internal,
        pos_ligne => pos_ligne_internal
    );

    -- Automate de suivi de ligne
    CTRL_SL : suivi_ligne
    PORT MAP (
        clk => CLOCK_50,
        reset_n => KEY(0),
        pos_ligne => signed(pos_ligne_internal),
		  
        start_sl => SW(1),
        fin_sl => fin_sl_internal,
        
		  cmdL_SL => cmdL_SL_s,
        cmdR_SL => cmdR_SL_s
    );
	 
	 -- Automate gestion de rotation
	 CRTL_Rot : rotation_ligne
	 PORT MAP (
	     clk      => CLOCK_50,
        reset_n  => KEY(0),
        start_rot => fin_sl_internal,
        dir_rot  => SW(0),
		  vect_capt => vect_capt_internal,
        fin_rot  => fin_rot_internal,
        cmdL_Rot => cmdL_Rot_s,
        cmdR_Rot => cmdR_Rot_s
	 
	 );
	 
	 -- MUX de sélection moteur
    process(fin_sl_internal, cmdL_SL_s, cmdR_SL_s, cmdL_Rot_s, cmdR_Rot_s)
    begin
        if fin_sl_internal = '1' then
            INTER_L <= cmdL_Rot_s;
            INTER_R <= cmdR_Rot_s;
        else
            INTER_L <= cmdL_SL_s;
            INTER_R <= cmdR_SL_s;
        end if;
    end process;
	 
	 -- Affichage LED
    LED(6 DOWNTO 0) <= vect_capt_internal;
    LED(7) <= fin_sl_internal;
	 
	 

END Structure;