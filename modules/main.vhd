----------------------------------------------------------------------------------
-- Author:          Jules CONTADIN
-- 
-- Create Date:     10.04.2024 18:18:33
-- Module Name:     main - Behavioral
-- Target Devices:  MachXO3LF-9400C
-- Description:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use work.UART_Generic_Package.all;

entity main is
	generic (DATA_BITS: integer := 8); 		-- Nombre de bits de données (8-9)	
	Port (
    reset       : in std_logic;
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
		-- Registre de choix de la PIN
		--PIN_SELECT : in std_logic_vector (1 downto 0) 
	);
end main;
	
architecture Behavioral of main is
-- Component recep_SPI
    component recep_SPI
        Port(
          clk       : in std_logic;
          reset     : in std_logic;
          mosi      : in std_logic;
          cs        : in std_logic;
          addr      : out std_logic_vector(6 downto 0);--(DATA_BITS-2 downto 0);
          r_w_en    : out std_logic;
          data_out  : out std_logic_vector(7 downto 0);--(DATA_BITS-1 downto 0);
          data_ready: out std_logic
          );
    end component;

-- Compo UART_TX
    component UART_TX
        Port ( 
        clk :   in STD_LOGIC;
        reset : in STD_LOGIC;
        baudrate_choice : in STD_LOGIC_VECTOR (7 downto 0);
        wr_en : in STD_LOGIC;
        rd_en : in STD_LOGIC;
        fifo_data_in : in STD_LOGIC_VECTOR(7 downto 0); -- 7 <= DATA_BITS-1
        tx_out : out STD_LOGIC;
        fifo_fill_level : out STD_LOGIC_VECTOR(7 downto 0);
        fifo_data_written : out std_logic;
        fifo_data_read : out std_logic;
        uart_tx_busy : out STD_LOGIC
        );
    end component;
    
-- Signaux
	-- data SPI to Registres
	signal spi_in_addr     : std_logic_vector(6 downto 0); --(DATA_BITS-2 downto 0);
	signal spi_in_r_w      : std_logic;
	signal spi_in_data     : std_logic_vector(7 downto 0); --(DATA_BITS-1 downto 0);
	signal spi_in_bus_ready: std_logic;
	-- UART0_TX
	signal uart0_tx_baudrate_cs : std_logic_vector (7 downto 0);
	signal uart0_tx_data_in     : std_logic_vector (7 downto 0); -- 7 <= DATA_BITS-1
	signal uart0_tx_wr_en       : std_logic;
	signal uart0_tx_rd_en       : std_logic;
	signal uart0_tx_fill_lvl    : std_logic_vector (7 downto 0);
	signal uart0_tx_data_written: std_logic; 
	signal uart0_tx_data_read   : std_logic;
	signal uart0_tx_busy        : std_logic;
 
begin
-- Mapping
    -- Reception du SPI
    SPI_IN : recep_SPI
        Port map(
            clk         =>  SPI_CLK,
            reset       =>  reset,
            mosi        =>  SPI_MOSI,
            cs          =>  SPI_CS,
            addr        =>  spi_in_addr,
            r_w_en      =>  spi_in_r_w,
            data_out    =>  spi_in_data,
            data_ready  =>  spi_in_bus_ready
            );
	
	-- Port map UART
	UART0_TX : UART_TX
      Port map(
        clk             =>  SPI_CLK,
        reset           =>  reset,
        baudrate_choice =>  uart0_tx_baudrate_cs,
        wr_en           =>  uart0_tx_wr_en,
        rd_en           =>  uart0_tx_rd_en,
        fifo_data_in    =>  spi_in_data,
        tx_out          =>  TX0,
        fifo_fill_level =>  uart0_tx_fill_lvl,
        fifo_data_written =>uart0_tx_data_written,
        fifo_data_read  =>  uart0_tx_data_read,
        uart_tx_busy    =>  uart0_tx_busy
        );
	
-- Process interprétation de la trame data_in
	main_proc : Process(SPI_CLK) 
	begin
		if rising_edge(SPI_CLK) then
            if spi_in_bus_ready='1' then
                case spi_in_addr(3 downto 0) is
                     -- Adresse x0: UART_TX (Read or write)
                     when "0000" =>
                        if spi_in_r_w='1' then -- Read the contents of the UART0_TX's FIFO on TX0
                            if uart0_tx_data_read = '0' then
                                uart0_tx_rd_en <= '1';
                                uart0_tx_wr_en <= '0';  
                            else
                                uart0_tx_rd_en <= '0';
                            end if;
                        else    -- Write contents on UART0_TX's FIFO_TX0
                            if uart0_tx_data_written = '0' then 
                                uart0_tx_wr_en <= '1';
                                uart0_tx_rd_en <= '0';
                            else 
                                uart0_tx_wr_en <= '0';
                            end if;
                        end if;
                    -- Adresse x1: UART_RX (Read or write)
                    when "0001" =>
        --				if r_w_in='1' then
        --					rx0_rd_en <= '1';
        --					rx0_wr_en <= '0';
        --				else	
        --					rx0_wr_en <= '1';
        --					rx0_rd_en <= '0';
        --				end if;
                    -- Adresse x2: R/W# du Baudrate0
                    when "0010" =>
                        if spi_in_r_w='1' then 
                            -- sortir <= uart0_baudrate_cs;  
                        else
                            uart0_tx_baudrate_cs <= spi_in_data;
                        end if;
                    -- Adresse x3: Config 
                    when "0011" =>
                        if spi_in_r_w='1' then 
                        -- Lecture de la config (GPIO1 GPIO0 DTR CTS RTS) into MISO
                            -- Data Terminal Ready
                            --if ENABLE_RX then DTR0 <= '1';
                            --else DTR0 <= '0';	
                            --end if;
                            
                             --Ready To Send (état haut='0')
                            --if CTS0='1' and ENABLE_TX then  RTS0 <= '0';
                            --else    RTS0 <= '1';
                            --end if;
                        else
                            -- Ecriture sur config
                        end if;
                    -- Adresse x4: Current fill level TX0 
                    when "0100" =>
                        if spi_in_r_w='1' then 
                            -- <= uart0_fill_lvl;
                        else
                            -- Ecriture ??
                        end if;
                    -- Adresse x5: Current fill level RX0 
                    when "0101" =>
                        if spi_in_r_w='1' then 
                        -- <= rx0_fill_lvl;
                    else
                        -- Ecriture ??
                    end if;
                    -- Le reste u temps
                    when others =>
                        uart0_tx_rd_en <= '0';
                        uart0_tx_wr_en <= '0';
                end case;
            else 
                uart0_tx_rd_en <= '0';
                uart0_tx_wr_en <= '0';
            end if;	
        end if;
	end process;
end Behavioral;
