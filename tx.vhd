----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN 
--
-- Create Date:     13.05.2024 18:36:29
-- Module Name:     TX - Behavioral
-- Target Devices:  MachXO3LF-9400C
-- Description: 
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TX is
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
end TX;

architecture Behavioral of TX is
-- Signaux
    signal bit_count : integer := 0;   
    signal tx_reg : std_logic_vector(DATA_BITS+STOP_BITS downto 0) := (others => '1'); 
    signal busy : std_logic := '0'; 
begin
-- Process transmision sur TX
    process (baud_clk, reset)
    begin
        if reset = '1' then
            tx_out <= '1';
            tx_reg <= (others => '1'); 
            bit_count <= 0; 
            busy <= '0'; 
        elsif rising_edge(baud_clk) then
            if busy = '0' and tx_start = '1' then
                busy <= '1';
                tx_reg <= '1' & data_in & '0';  -- buffer avec données et bit start & stop
                tx_out <= '0'; -- Start bit
                bit_count <= 1; 
            elsif bit_count < DATA_BITS+2 then
                tx_out <= tx_reg(bit_count); -- Data bits (LSB first) et stop bit
                bit_count <= bit_count + 1;
            elsif bit_count = DATA_BITS+2 then
                busy <= '0'; -- Trame envoyée, donc plus busy
            end if;
        end if;
    end process;
    tx_busy <= busy;
end Behavioral;
