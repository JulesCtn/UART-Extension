----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN 
-- 
-- Create Date:     07.05.2024 13:49:00
-- Module Name:     recep_SPI - Behavioral
-- Target Devices:  MachXO3LF-9400C
-- Description: 
--      Receive a SPI mode 0 databus (16 bits long, MSB first)
--      Databus is as follow :
--        Bit 13 to 15: choose UART
--        Bit 9 to 12: choose function
--        Bit 8: Read or write bit
--        Bit 0 to 7: Data register
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity recep_SPI is
    generic(	
	    constant DATA_BITS  : integer := 8
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
end recep_SPI;

architecture Behavioral of recep_SPI is
-- Signaux
--    signal mosi_reg : std_logic_vector(TRAM_BITS-1 downto 0) := (others => '0');
    type state_type is (IDLE, RECEIVE, READY);
    signal state       : state_type := IDLE;
    signal bit_count   : integer := 0;
    signal sig_addr    : STD_LOGIC_VECTOR(DATA_BITS-2 downto 0) := (others => '0');
    signal sig_wr_en   : STD_LOGIC;
    signal sig_data    : STD_LOGIC_VECTOR(DATA_BITS-1 downto 0) := (others => '0');
begin
-- Process reception MOSI & stockage data_in
        --mosi_reg <=  mosi_reg(DATA_BITS+DATA_BITS-1 downto 0) & mosi;
process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            sig_addr <= (others => '0');
            sig_data <= (others => '0');
            data_ready <= '0';
            bit_count <= 0;
            sig_wr_en <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    data_ready <= '0';
                    bit_count <= 0;
                    sig_addr <= (others => '0');
                    sig_wr_en <= '0';
                    sig_data <= (others => '0');
                    if cs = '0' then
                        state <= RECEIVE;
                        sig_addr <= sig_addr(5 downto 0) & mosi;
                    end if;

                when RECEIVE =>
                    if cs = '1' then
                        state <= IDLE;
                    elsif bit_count < 6 then -- Addresse bits
                        sig_addr <= sig_addr(5 downto 0) & mosi;
                        bit_count <= bit_count + 1;
                    elsif bit_count = 6 then -- R/W# bit
                        sig_wr_en <= mosi;
                        bit_count <= bit_count + 1;
                    elsif bit_count < 14 then -- Data bits
                        sig_data <= sig_data(6 downto 0) & mosi;
                        bit_count <= bit_count + 1;
                    else -- Last data bit 
                        sig_data <= sig_data(6 downto 0) & mosi;
                        --bit_count <= bit_count + 1; -- If debugging (more understandable)   
                        state <= READY;
                    end if;
                    
                when READY =>
                    addr <= sig_addr;
                    data_out <= sig_data;
                    r_w_en <= sig_wr_en;
                    data_ready <= '1';
                    state <= IDLE;

                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;          
end Behavioral;
