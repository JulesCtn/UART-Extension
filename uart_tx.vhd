----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN  
-- 
-- Create Date:     30.05.2024 16:15:28
-- Module Name:     UART_TX - Behavioral
-- Target Devices:  MachXO3LF-9400C
-- Description:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TX is
    generic( 
        constant FREQ_CLK_IN : integer := 50E6;
        constant DATA_BITS	: integer := 8
        );
    Port ( 
        clk :   in STD_LOGIC;
        reset : in STD_LOGIC;
        baudrate_choice : in STD_LOGIC_VECTOR (7 downto 0);
        wr_en : in STD_LOGIC;
        rd_en : in STD_LOGIC;
        fifo_data_in : in STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
        tx_out : out STD_LOGIC;
        fifo_fill_level : out STD_LOGIC_VECTOR(7 downto 0);
        fifo_data_written : out std_logic;
        fifo_data_read : out std_logic;
        uart_tx_busy : out STD_LOGIC
    );
end UART_TX;

architecture Behavioral of UART_TX is
-- Components
    -- Component fifo
    component fifo
        Port ( 
          clk : in STD_LOGIC;
          reset : in STD_LOGIC;
          wr_en : in STD_LOGIC;
          rd_en : in STD_LOGIC;
          data_in : in STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
          data_out : out STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
          current_fill_level : out STD_LOGIC_VECTOR(7 downto 0);
          data_written : out std_logic;
          data_read : out std_logic
          );
    end component;
    
    -- Component baudrate_generator
    component baudrate_generator
        generic( 
        constant FREQ_CLK_IN : integer := 50E6
        );
        Port ( 
           reset : in STD_LOGIC;
           clk_in : in STD_LOGIC;
           baudrate_choice : in STD_LOGIC_VECTOR (7 downto 0);
           baud_clk : out STD_LOGIC);
       end component;
       
    -- Component TX
    component TX
        Port(
            baud_clk : in  std_logic;
            reset    : in  std_logic;
            tx_start : in  std_logic;
            data_in  : in  std_logic_vector(DATA_BITS-1 downto 0);
            tx_out   : out std_logic;
            tx_busy  : out std_logic
            );
    end component;
-- Signaux
    signal fifo_data_out : STD_LOGIC_VECTOR(DATA_BITS-1 downto 0);
    signal baud_clk : STD_LOGIC;
    signal data_written, data_read : STD_LOGIC;
    signal tx_start, tx_busy : STD_LOGIC;
    signal state : STD_LOGIC_VECTOR(1 downto 0);
    constant IDLE : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant START_TX : STD_LOGIC_VECTOR(1 downto 0) := "01";
    constant WAIT_TX : STD_LOGIC_VECTOR(1 downto 0) := "10";
        
begin
-- Instantiation 
    baudrate_gen : baudrate_generator
        port map (
            reset => reset,
            clk_in => clk,
            baudrate_choice => baudrate_choice,
            baud_clk => baud_clk
        );
        
    fifo_inst : fifo
        port map (
            clk => clk,
            reset => reset,
            wr_en => wr_en,
            rd_en => rd_en,
            data_in => fifo_data_in,
            data_out => fifo_data_out,
            current_fill_level => fifo_fill_level,
            data_written => data_written,
            data_read => data_read
        );
        
    tx_inst : TX
        port map (
            baud_clk => baud_clk,
            reset => reset,
            tx_start => tx_start,
            data_in => fifo_data_out,
            tx_out => tx_out,
            tx_busy => tx_busy
        );    
        
-- Process
    uart_proc : process(clk, reset)
    begin
        if reset = '1' then
            tx_start <= '0';
            state <= IDLE;
        elsif rising_edge(clk) then
            if state = IDLE then
                if data_read = '1' then
                    tx_start <= '1';
                    state <= START_TX;
                end if;
            elsif state = START_TX then
                tx_start <= '1';
                if tx_busy = '1' then
                    state <= WAIT_TX;
                end if;
            elsif state = WAIT_TX then
                tx_start <= '0';
                if tx_busy = '0' then
                    state <= IDLE;
                end if;
            else
                state <= IDLE;
            end if;
        end if;
    end process;
    fifo_data_written<= data_written;
    fifo_data_read<= data_read;
    uart_tx_busy <= tx_busy;

end Behavioral;
