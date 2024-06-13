----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN 
--
-- Create Date:     02.05.2024 13:11:32
-- Module Name:     main_tb - Behavioral
-- Target Devices:  MachXO3LF-9400C
-- Description: 
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_tb is
end main_tb;

architecture behavior of main_tb is
	-- Component Declaration of Unit Under Test (UUT)
	component main is
		generic(
			DATA_BITS	: integer := 8 		-- Nombre de bits de données (8-9)
			);	
		Port (
		    reset       : in    std_logic;
			-- IN SPI
			SPI_CLK		: in 	std_logic;
			SPI_MOSI 	: in 	std_logic;
			SPI_MISO 	: out 	std_logic;
			SPI_CS 		: in 	std_logic;
			SPI_ALERT	: out 	std_logic;	-- Indique que le buffer RX est non vide
			-- UART0
			TX0		: out 	std_logic;
			RX0 	: in 	std_logic;
			-- UART0 Contrôle de flux
			RTS0	: out 	std_logic; 	-- Ready To Send
			CTS0	: in 	std_logic; 	-- Clear To Send
			DTR0	: out 	std_logic 	-- Data Terminal Ready
		);
	end component;

	-- Sig in
	signal reset:   std_logic := '0';
	signal clk	:	std_logic := '0';
	signal mosi	:	std_logic := '0';
	signal cs	:	std_logic := '1';
	signal rx	:	std_logic;
	signal cts	:	std_logic;

	-- Sig out
	signal miso	:	std_logic;
	signal alert:	std_logic;
	signal tx	:	std_logic;
	signal rts	:	std_logic;
	signal dtr	:	std_logic;
	
	-- Clock period definition
	constant CLK_PERIOD : time := 20 ns;  -- Période de l'horloge (50 MHz)
begin

	uut: main
		Port map (
		    reset       =>reset,
			SPI_CLK		=>clk,
			SPI_MOSI	=>mosi,
			SPI_MISO	=>miso,
			SPI_CS		=>cs,
			SPI_ALERT	=>alert,
			TX0			=>tx,
			RX0			=>rx,
			RTS0		=>rts,
			CTS0		=>cts,
			DTR0		=>dtr);
	-- Clock process 
	clk_process	:process
	begin
		clk <= '0';
		wait for CLK_PERIOD/2;
		clk <= '1';
		wait for CLK_PERIOD/2;
	end process;

	-- Stimulus process
	stim_proc 	:process
	begin
		-- Wait for reset
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for 2 * CLK_PERIOD; 
        
        -- Trame config baurate (Addr: 0x02 / R/W#:0 / data: 0x03) 9600 Baudrate
        cs <= '0';  -- Start of frame
        wait for CLK_PERIOD/2;
        mosi <= '0'; -- Address MSB (bit 15 to 11)
        wait for 5*CLK_PERIOD;
        mosi <= '1'; -- Address  (bit 10)
        wait for CLK_PERIOD;
        mosi <= '0'; -- Address LSB (bit 9)
        wait for CLK_PERIOD;
        mosi <= '0'; -- R/W# command (bit 8)
        wait for CLK_PERIOD;
        mosi <= '0'; -- Data (bit 7 to 3)
        wait for 5 * CLK_PERIOD;
        mosi <= '0'; -- Data bit 2
        wait for CLK_PERIOD;
        mosi <= '1'; -- Data bit 1
        wait for CLK_PERIOD;
        mosi <= '1'; -- Data bit 0
        wait for CLK_PERIOD; -- End of frame
        
        cs <= '1';
        wait for 2 * CLK_PERIOD;
        
        -- Trame write dans FIFO TX0 (Addr: 0x00 / R/W#:0 / data: 0xaa)
        cs <= '0';
        mosi <= '0'; -- Address MSB (bit 15 to 10)
        wait for 6 * CLK_PERIOD;
        mosi <= '0'; -- Address LSB (bit 9)
        wait for CLK_PERIOD;
        mosi <= '0'; -- R/W# command (bit 8)
        wait for CLK_PERIOD;
        mosi <= '1'; -- Data bit 7
        wait for CLK_PERIOD;
        mosi <= '0'; -- Data bit 6
        wait for CLK_PERIOD;
        mosi <= '1'; -- Data bit 5
        wait for CLK_PERIOD;
        mosi <= '0'; -- Data bit 4
        wait for CLK_PERIOD;
        mosi <= '1'; -- Data bit 3
        wait for CLK_PERIOD;
        mosi <= '0'; -- Data bit 2
        wait for CLK_PERIOD;
        mosi <= '1'; -- Data bit 1
        wait for CLK_PERIOD;
        mosi <= '0'; -- Data bit 0
        wait for CLK_PERIOD; -- End of frame
        
        cs <= '1';
        wait for 2 * CLK_PERIOD;
        
        -- Trame read FIFO TX (Addr: 0x00 / R/W#:1 / data: 0xff)
        cs <= '0';
        mosi <= '0'; -- Address MSB (bit 15 to 10)
        wait for 6 * CLK_PERIOD;
        mosi <= '0'; -- Address LSB (bit 9)
        wait for CLK_PERIOD;
        mosi <= '1'; -- R/W# command (bit 8)
        wait for CLK_PERIOD;
        mosi <= '0'; -- Data bit 7
        wait for CLK_PERIOD;
        mosi <= '0'; -- Data bit 6
        wait for CLK_PERIOD;
        mosi <= '0'; -- Data bit 5
        wait for CLK_PERIOD;
        mosi <= '0'; -- Data bit 4
        wait for CLK_PERIOD;
        mosi <= '0'; -- Data bit 3
        wait for CLK_PERIOD;
        mosi <= '0'; -- Data bit 2
        wait for CLK_PERIOD;
        mosi <= '0'; -- Data bit 1
        wait for CLK_PERIOD;
        mosi <= '0'; -- Data bit 0
        wait for CLK_PERIOD; -- End of frame
        
        cs <= '1';
		wait;
	end process;
end behavior;
