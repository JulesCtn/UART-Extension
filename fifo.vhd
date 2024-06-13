----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN 
-- 
-- Create Date:     06.05.2024 10:28:09
-- Module Name:     fifo - Behavioral
-- Target Devices:  MachXO3LF-9400C
-- Description: 
--				+-----+-----+-----+----------------+
--	Output <-	| n°0 | n°1 | ... | n°FIFO_DEPTH-1 | <- Input 
--				+-----+-----+-----+----------------+
-- (2096 bytes pour la FIFOS) => 2048 est plus pratique
-- Donc 256 places de 8 bits = 2048
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fifo is
   generic( 
     FIFO_WIDTH : integer := 8;
     FIFO_DEPTH : integer := 8
     );
    Port ( 
      clk : in STD_LOGIC;
      reset : in STD_LOGIC;
      wr_en : in STD_LOGIC;
      rd_en : in STD_LOGIC;
      data_in : in STD_LOGIC_VECTOR(FIFO_WIDTH-1 downto 0);
      data_out : out STD_LOGIC_VECTOR(FIFO_WIDTH-1 downto 0);
      current_fill_level : out STD_LOGIC_VECTOR(7 downto 0);
      data_written : out std_logic;
      data_read : out std_logic
      );
end fifo;

architecture Behavioral of fifo is
    type memory_array is array (0 to FIFO_DEPTH-1) of STD_LOGIC_VECTOR(7 downto 0);
    signal fifo_mem : memory_array;
    signal fill_level : integer range 0 to FIFO_DEPTH := 0;
    signal sig_full, sig_empty : std_logic;
begin
    fifo_proc : process(clk, reset)
    variable f_level : integer range 0 to FIFO_DEPTH := 0;
    variable rd_ptr, wr_ptr : integer range 0 to FIFO_DEPTH-1 := 0;
    begin
        if reset = '1' then
            wr_ptr := 0;
            rd_ptr := 0;
            f_level := 0;
            fill_level <= 0;
            data_out <= (others => '0');
            data_written <= '0';
            data_read <= '0';
        elsif rising_edge(clk) then
            data_written <= '0';  -- Default to '0'
            data_read <= '0';
            if wr_en = '1' and sig_full = '0' then
                fifo_mem(wr_ptr) <= data_in;
                wr_ptr := (wr_ptr + 1) mod FIFO_DEPTH;
                f_level := f_level + 1;
                data_written <= '1';  -- Acknowledge the write
            end if;
            if rd_en = '1' and sig_empty = '0' then
                data_out <= fifo_mem(rd_ptr);
                rd_ptr := (rd_ptr + 1) mod FIFO_DEPTH;
                f_level := f_level - 1;
                data_read <= '1';   -- Acknowledge the read
            end if;
            fill_level <= f_level;
        end if;
    end process;
    sig_full <= '1' when fill_level = FIFO_DEPTH else '0';
    sig_empty <= '1' when fill_level = 0 else '0'; 
    current_fill_level <= std_logic_vector(to_unsigned(fill_level, current_fill_level'length));
end Behavioral;
