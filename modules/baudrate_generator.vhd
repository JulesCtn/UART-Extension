----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN 
-- 
-- Create Date:     02.05.2024 17:56:56
-- Module Name:     baudrate_generator - Behavioral
-- Target Devices:  MachXO3LF-9400C
-- Description: 
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity baudrate_generator is
    generic(
           FREQ_CLK_IN : integer := 50E6);    -- Fréquence de la clock du SPI_MASTER
    Port ( 
           reset : in STD_LOGIC;
           clk_in : in STD_LOGIC;
           baudrate_choice : in STD_LOGIC_VECTOR (7 downto 0);
           baud_clk : out STD_LOGIC);
end baudrate_generator;

architecture Behavioral of baudrate_generator is
    type baud_rate_array is array (0 to 11) of INTEGER; -- Tableau des baudrate possibles
    constant baud_rates : baud_rate_array := (1200, 2400, 4800, 9600, 14400, 19200, 
                                              38400, 57600, 115200, 230400, 460800, 921600);
    signal baud_rate_selected : INTEGER;
    signal baud_period : INTEGER;
    signal counter : INTEGER range 0 to FREQ_CLK_IN := 0;
    --signal counter_half_baud : INTEGER range 0 to FREQ_CLK_IN := 0;
    signal out_baud_clk : STD_LOGIC := '0';

begin
-- Selection ud baudrate
process(baudrate_choice)
begin
    baud_rate_selected <= baud_rates(to_integer(unsigned(baudrate_choice)));
end process;

-- Clock generator
process(clk_in)
begin
    if reset = '1' then 
        counter <= 0;
        out_baud_clk <= '0';
        --counter_half_baud <= 0;
    elsif rising_edge(clk_in) then      
        baud_period <= FREQ_CLK_IN / (2 * baud_rate_selected); -- Il y a 2*baudrate bit/s   
        if counter = baud_period - 1 then -- Si la période de bit est atteinte
            out_baud_clk <= not out_baud_clk;
            counter <= 0;
            --counter_half_baud <= counter_half_baud + 1;
        else -- Si le compteur est inférieur à la période de bits                             
            counter <= counter + 1;
        end if;
    end if;
end process;
baud_clk <= out_baud_clk;

end Behavioral;
