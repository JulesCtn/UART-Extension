----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN 
-- 
-- Create Date:     06.05.2024 10:28:30
-- Module Name:     fifo_tb - Behavioral
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

entity fifo_tb is
end fifo_tb;

architecture Behavioral of fifo_tb is
    constant CLOCK_PERIOD : time := 10 ns;
    
    -- Signal 
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal wr_en : std_logic := '0';
    signal rd_en : std_logic := '0';
    signal data_in : std_logic_vector(7 downto 0) := (others => '0');
    signal data_out : std_logic_vector(7 downto 0);
    signal current_fill_level : std_logic_vector(7 downto 0);
    signal data_written : std_logic;
    signal data_read : std_logic;
    
    -- Component UTT
    component fifo
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
    end component;

begin
    uut : fifo 
        port map(
            clk,
            reset,
            wr_en,
            rd_en,
            data_in,
            data_out, 
            current_fill_level,
            data_written,
            data_read);
                       
    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for CLOCK_PERIOD / 2;
        clk <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;
    
    -- Write and read process
    stimulus_process: process
    begin
        -- Wait for reset
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        wait for CLOCK_PERIOD; 
        -- Example write until full
--        wr_en <= '1';
--        rd_en <= '1';
--        data_in <= "00000001";
--        wait for CLOCK_PERIOD;
--        data_in <= "00000010";
--        wait for CLOCK_PERIOD;
--        data_in <= "00000011";
--        wait for CLOCK_PERIOD;
--        data_in <= "00000100";
--        wait for CLOCK_PERIOD;
        
--        rd_en <= '0';
--        data_in <= "00000101";
--        wait for CLOCK_PERIOD;
--        wr_en <= '0';
--        rd_en <= '1';
--        data_in <= "00000110";
--        wait for CLOCK_PERIOD;
--        rd_en <= '0';
--        wr_en <= '1';
--        data_in <= "00000111";
--        wait for CLOCK_PERIOD;
--        wr_en <= '0';
--        data_in <= "00001000";
--        wait for CLOCK_PERIOD;
--        data_in <= "00001001";
--        wait for CLOCK_PERIOD;
--        data_in <= "00001010";
--        wait for CLOCK_PERIOD;
--        data_in <= "00001011";
--        wait for CLOCK_PERIOD;

        wr_en <= '1';
        data_in <= "00000001";
        wait for CLOCK_PERIOD;
        while current_fill_level <= x"07" loop -- 0x01 à 0x80
            data_in <= data_in(6 downto 0) & '0';
            wait for CLOCK_PERIOD;
        end loop;
        wait for CLOCK_PERIOD;
        wr_en <= '0'; -- Stop writgin
        
        --Read until empty
        rd_en <= '1';
        while current_fill_level > x"00" loop
            wait for CLOCK_PERIOD;
        end loop;
        
        wait;
    end process;
end Behavioral;
