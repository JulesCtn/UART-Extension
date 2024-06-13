----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN 
-- 
-- Create Date:     07.05.2024 15:00:20
-- Module Name:     recep_SPI_tb - Behavioral
-- Target Devices:  MachXO3LF-9400C
-- Description: 
--      testbench for recep_spi
-------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity recep_SPI_tb is
end recep_SPI_tb;

architecture Behavioral of recep_SPI_tb is
    -- Component UUT
    component recep_SPI is 
    generic(		
	    constant DATA_BITS	: integer := 8 		
        );
    port (
        -- Signals for SPI communication
        clk : in std_logic;
        reset : in std_logic;
        mosi : in std_logic;
        cs : in std_logic;
        -- Signals for data transfer
        addr : out std_logic_vector(DATA_BITS-2 downto 0);
        r_w_en : out std_logic;
        data_out : out std_logic_vector(DATA_BITS-1 downto 0);
        data_ready : out std_logic
    );
    end component;
    
   -- Signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal mosi : std_logic := '0';
    signal cs : std_logic := '1'; 
    signal data_ready : std_logic;
    signal address : std_logic_vector(6 downto 0);
    signal r_w_en : std_logic;
    signal data_out : std_logic_vector(7 downto 0);
    
    -- Clock period definitions
    constant CLK_PERIOD : time := 20 ns;  -- Période de l'horloge (50 MHz)
    
    -- Task to send an SPI frame
    procedure send_spi_frame(
        constant addr_frame : in std_logic_vector(7 downto 0);
        constant data_frame : in std_logic_vector(7 downto 0);
        signal mosi : out std_logic
    ) is
    begin
        for i in 7 downto 0 loop
            mosi <= addr_frame(i);
            wait for clk_period;
        end loop;
        for i in 7 downto 0 loop
            mosi <= data_frame(i);
            wait for clk_period;
        end loop;
    end procedure; 
begin
    -- Instantiate SPI_Slave module
    uut : recep_SPI
        port map (
            clk => clk,
            reset => reset,
            mosi => mosi,
            cs => cs,
            addr => address,
            r_w_en => r_w_en,
            data_out => data_out,
            data_ready => data_ready
        );
    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;
    
    -- Write and read process
    stimulus_process: process
    begin
        -- Reset
        reset <= '1';
        wait for 2 * CLK_PERIOD;
        reset <= '0';
        
        -- Send first frame
        cs <= '0';  
        send_spi_frame ("10101010", "10101010", mosi);
        cs <= '1';
        wait for 2 * CLK_PERIOD;
        
        -- Send second frame
        cs <= '0';  
        send_spi_frame ("01010101", "01010101", mosi);
        cs <= '1';
        wait for 2 * CLK_PERIOD;
        
        -- Send third frame
        cs <= '0';  
        send_spi_frame ("1100110" & '0', "11001100", mosi);
        cs <= '1';
        wait for 2 * CLK_PERIOD;
        
		wait;
    end process;
end Behavioral;
