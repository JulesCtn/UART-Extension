----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN 
-- 
-- Create Date:     02.05.2024 14:26:00
-- Module Name:     baudrate_generator_tb - Behavioral
-- Target Devices:  MachXO3LF-9400C
-- Description: 
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity baudrate_generator_tb is
end baudrate_generator_tb;

architecture Behavioral of baudrate_generator_tb is
    -- Component UUT
    component baudrate_generator is 
        generic(
            FREQ_CLK_IN : integer := 50E6);
        Port ( 
           reset : in STD_LOGIC;
           clk_in : in STD_LOGIC;
           baudrate_choice : in STD_LOGIC_VECTOR (7 downto 0);
           baud_clk : out STD_LOGIC);
    end component;
    
    -- Inputs
    signal clk, reset : STD_LOGIC := '0';        -- Horloge d'entrée
    signal baud_rate_select : STD_LOGIC_VECTOR(7 downto 0) := "00000011"; -- 11 => 9600 bauds
    -- Outputs
    signal baud_out : STD_LOGIC;          -- Sortie du signal de débit de données
    -- Clock period definitions
    constant CLK_PERIOD : time := 20 ns;  -- Période de l'horloge (50 MHz)

begin
    -- Instanciation du générateur de débit de données
    uut : baudrate_generator
        port map (
            clk_in => clk,
            reset => reset,
            baudrate_choice => baud_rate_select,
            baud_clk => baud_out);

    -- Processus pour générer une horloge
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Processus de simulation pour afficher le débit de données
    simulation_process : process
    begin
        -- Reset
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait;
    end process;

end Behavioral;
