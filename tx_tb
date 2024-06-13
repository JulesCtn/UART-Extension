----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN  
-- 
-- Create Date:     13.05.2024 19:22:24
-- Module Name:     UART_TX_tb - Behavioral
-- Target Devices:  MachXO3LF-9400C
-- Description: 
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TX_tb is
end TX_tb;

architecture Behavioral of TX_tb is
    -- Component UUT
    component TX is 
    generic(
        constant DATA_BITS	: integer := 8;		
        constant STOP_BITS	: integer := 1
        );
    Port(
        baud_clk : in  std_logic;
        reset    : in  std_logic;
        tx_start : in  std_logic;
        data_in  : in  std_logic_vector(DATA_BITS-1 downto 0);
        tx_out   : out std_logic;
        tx_busy  : out std_logic
        );
    end component;
    
    -- Signals
    signal clk : std_logic := '0'; -- Clock signal
    signal reset : std_logic := '0'; -- Reset signal
    signal data_in : std_logic_vector(7 downto 0) := (others => '0'); -- Input data
    signal tx_out, start, busy : std_logic; -- TX output
    
    -- Clock period definitions
    constant CLK_PERIOD : time := 20 ns;  -- Période de l'horloge (50 MHz)
begin
    -- Instantiate the UART module
    uut: TX
        port map (
            baud_clk => clk,
            reset => reset,
            data_in => data_in,
            tx_out => tx_out,
            tx_busy => busy,
            tx_start => start
        );
        
    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;
    
    -- Stimulus process
    stimulus_process: process
    begin
        start <= '0';
        -- wait for reset
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD;
        -- Send data
        start <= '1';
        data_in <= "00101011"; 
        wait for 10 * CLK_PERIOD;
        
        wait for CLK_PERIOD;
        start <= '1';
        data_in <= "00000000"; 
        wait for CLK_PERIOD;
        start <= '0';
        
        wait until busy = '0';
        wait for CLK_PERIOD;
        start <= '1';
        data_in <= "11111111"; 
        wait for CLK_PERIOD;
        start <= '0';
        
        wait until busy = '0';
        wait for CLK_PERIOD;
        start <= '1';
        data_in <= "01100110"; 
        wait for CLK_PERIOD;
        start <= '0';
        
        wait;
    end process;
end Behavioral;
