LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY sysRobot IS
PORT (
    SW : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    KEY : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    CLOCK_50 : IN STD_LOGIC;
    LED : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    DRAM_CLK, DRAM_CKE : OUT STD_LOGIC;
    DRAM_ADDR : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
    DRAM_BA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    DRAM_CS_N, DRAM_CAS_N, DRAM_RAS_N, DRAM_WE_N : OUT STD_LOGIC;
    DRAM_DQ : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    DRAM_DQM : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    MTRR_P, MTRR_N, MTRL_P, MTRL_N : OUT STD_LOGIC
);
END sysRobot;

ARCHITECTURE Structure OF sysRobot IS

    -- Déclaration des signaux internes
    SIGNAL INTER_L, INTER_R : STD_LOGIC_VECTOR(13 DOWNTO 0);

    COMPONENT nios_system
    PORT (
        SIGNAL clk_clk : IN STD_LOGIC;
        SIGNAL reset_reset_n : IN STD_LOGIC;
        SIGNAL leds_export : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL switches_export : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL sdram_wire_addr : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
        SIGNAL sdram_wire_ba : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        SIGNAL sdram_wire_cas_n : OUT STD_LOGIC;
        SIGNAL sdram_wire_cke : OUT STD_LOGIC;
        SIGNAL sdram_wire_cs_n : OUT STD_LOGIC;
        SIGNAL sdram_wire_dq : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        SIGNAL sdram_wire_dqm : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        SIGNAL sdram_wire_ras_n : OUT STD_LOGIC;
        SIGNAL sdram_wire_we_n : OUT STD_LOGIC;
        SIGNAL cntrl_left_export  : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);                    
        SIGNAL cntrl_right_export : OUT STD_LOGIC_VECTOR(13 DOWNTO 0)
    );                     
    END COMPONENT;

    COMPONENT PWM_generation 
    PORT (
        clk, reset_n : IN STD_LOGIC;
        s_writedataR, s_writedataL : IN STD_LOGIC_VECTOR(13 DOWNTO 0);        
        -- Le bit13 : bit de go(1)/stop(0). 
        -- Le bit12: bit de forward(0)/backward(1). 
        -- Les bits 11 à 0: vitesse = durée état haut
        dc_motor_p_R, dc_motor_n_R, dc_motor_p_L, dc_motor_n_L : OUT STD_LOGIC
    );
    END COMPONENT;

BEGIN

    -- Instanciation du composant nios_system
    NiosII: nios_system
    PORT MAP (
        clk_clk => CLOCK_50,
        reset_reset_n => KEY(0),
        leds_export => LED,
        switches_export => SW,
        sdram_wire_addr => DRAM_ADDR,
        sdram_wire_ba => DRAM_BA,
        sdram_wire_cas_n => DRAM_CAS_N,
        sdram_wire_cke => DRAM_CKE,
        sdram_wire_cs_n => DRAM_CS_N,
        sdram_wire_dq => DRAM_DQ,
        sdram_wire_dqm => DRAM_DQM,
        sdram_wire_ras_n => DRAM_RAS_N,
        sdram_wire_we_n => DRAM_WE_N,
        cntrl_left_export => INTER_L, 
        cntrl_right_export => INTER_R
    );
    
    DRAM_CLK <= CLOCK_50;

    -- Instanciation du composant PWM_generation
    PMW: PWM_generation
    PORT MAP (
        clk => CLOCK_50,
        reset_n => KEY(0),
        s_writedataL => INTER_L,  -- Mapping correct pour INTER_L
        s_writedataR => INTER_R,  -- Mapping correct pour INTER_R
        dc_motor_p_R => MTRR_P,
        dc_motor_n_R => MTRR_N,
        dc_motor_p_L => MTRL_P,
        dc_motor_n_L => MTRL_N
    );    
    
END Structure;
