----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN
-- 
-- Create Date:     10.04.2024 18:21:01
-- Module Name:     UART_Generic_Package
-- Target Devices:  MachXO3LF-9400C
-- Description :
-- 		use work.UART_Generic_Package.all;
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--library machXO3;
--use machXO3.all;

package UART_Generic_Package is
-- Declare functions

-- Declare constants
	-- SPI_vers_UART
	constant ADDR_BITS  : integer := 7;
    constant R_W_POS    : integer := 8;
	constant TRAM_BITS	: integer := 16;		-- Nombre de bits dans la trame
	constant DATA_BITS	: integer := 8; 		-- Nombre de bits de données (8-9)
	constant STOP_BITS	: integer := 1; 		-- Nombre de bits de stop 		
	constant ENABLE_TX	: boolean := true; 		-- (Non utilisé)
	constant ENABLE_RX	: boolean := true;       -- (Non utilisé)
	-- baudrate_generator
	constant FREQ_CLK_IN : integer := 8E6;
	-- fifo
	constant FIFO_WIDTH : integer := DATA_BITS;	-- Taille des données de ka FIFO
	constant FIFO_DEPTH : integer := 256;	-- Nombre de case de données

-- Declare components

end UART_Generic_Package;

package body UART_Generic_Package is 
-- fonctions
end UART_Generic_Package;
