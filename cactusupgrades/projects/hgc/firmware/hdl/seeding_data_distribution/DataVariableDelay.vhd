--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using STD_LOGIC_UNSIGNED
use IEEE.std_logic_unsigned.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! Using the Calo-L2 "mp7_data" data-types
use work.mp7_data_types.all;

--! hgc data types
use work.hgc_data_types.all;


entity DataVariableDelay is

  port (
    clk            : in  std_logic;
    rst            : in  std_logic;
    flaggedWordIn  : in  hgcFlaggedWord;
    flaggedWordOut : out hgcFlaggedWord;
    --we             : out std_logic;
    EOE            : out std_logic := '0'
    );

end entity DataVariableDelay;

architecture behavioural of DataVariableDelay is

  -- storage ram 
  signal data_ram_clka    : std_logic;
  signal data_ram_ena     : std_logic;
  signal data_ram_wea     : std_logic_vector (0 to 0)      := (others => '0');
  signal data_ram_addr_wr : std_logic_vector (5 downto 0)  := (others => '0');
  signal data_ram_dina    : std_logic_vector (31 downto 0) := x"00000000";
  signal data_ram_clkb    : std_logic;
  signal data_ram_enb     : std_logic;
  signal data_ram_addr_rd : std_logic_vector (5 downto 0)  := (others => '0');
  signal data_ram_doutb   : std_logic_vector (31 downto 0) := (others => '0');

  -- read pointers fifo
--  signal rp_fifo_clk   : std_logic;
--  signal rp_fifo_srst  : std_logic;
--  signal rp_fifo_din   : std_logic_vector(31 downto 0);
--  signal rp_fifo_wr_en : std_logic := '0';
--  signal rp_fifo_rd_en : std_logic;
--  signal rp_fifo_dout  : std_logic_vector(31 downto 0);
--  signal rp_fifo_full  : std_logic;
--  signal rp_fifo_empty : std_logic;

  -- helpers
  signal bxCounter : natural := 0;
--  signal new_bx_detected    : std_logic := '0';
  signal firstEventDetected : std_logic := '0';
  signal wordToRam    : std_logic_vector(31 downto 0) := (others => '0');
  signal wordFromRam  : std_logic_vector(31 downto 0) := (others => '0');

begin  -- architecture behavioural

  -----------------------------------------------------------------------------
  -- ports assignemets
  -----------------------------------------------------------------------------
  --we  <= '1' when data_ram_doutb(16) = '1' else '0';
  bxCounter <= bxCounter+1 when rising_edge(clk) and flaggedWordIn.word.SOE = '1' else bxCounter;
  
  -----------------------------------------------------------------------------
  -- helper to define the input and output to/from RAM
  -----------------------------------------------------------------------------
  e_toRAM : entity work.hgcFlagged2ram
    port map(
      hgcFlaggedWord => flaggedWordIn,
      ram            => wordToRam
      );

  e_fromRAM : entity work.ram2hgcFlaggedWord
    port map(
      ram            => wordFromRam,
      hgcFlaggedWord => flaggedWordOut
      );

  -----------------------------------------------------------------------------
  -- data storage
  -----------------------------------------------------------------------------
  data_ram_clka <= clk;
  data_ram_ena <= '1';

  data_ram_clkb <= clk;
  data_ram_enb  <= '1';

  -- wr/rd ram
  p_ram_wr : process (clk) is
     variable into_event : std_logic := '0';
     variable into_extended_event : std_logic := '0';
     variable read_ram : std_logic := '0';
--     variable enable_ram_rd : std_logic := '0';       
  begin
    if rising_edge(clk) then

      -- ram port a input
      data_ram_dina <= wordToRam;
      
      -- into_event and into_extended_event variables
      if flaggedWordIn.word.SOE = '1' then
        into_event := '1';
      elsif flaggedWordIn.word.EOE = '1' then
        into_event := '0';
      end if;

      if into_event = '1' or flaggedWordIn.word.EOE = '1' then
        into_extended_event := '1';
      else
        into_extended_event := '0';
      end if;
      
      -- ram write enable port a
      if rst = '0' then
        data_ram_wea(0) <= '0';
      elsif into_extended_event = '1' then
        data_ram_wea(0) <= '1';
      else
        data_ram_wea(0) <= '0';
      end if;
      
      -- wr pointer
      if into_extended_event = '1' then 
        data_ram_addr_wr <= data_ram_addr_wr + 1;
      end if;

      -- read pointer increment
      if flaggedWordIn.word.EOE = '1' then
        read_ram := '1';
      end if;
      if read_ram = '1' and data_ram_addr_wr /= data_ram_addr_rd then
        data_ram_addr_rd <= data_ram_addr_rd + 1;
      elsif data_ram_addr_wr = data_ram_addr_rd then
        data_ram_addr_rd <= data_ram_addr_rd;
      end if;
            
    end if;
  end process;


  e_ram_variable_data_delay : entity work.variable_data_delay
    port map (
      clka  => data_ram_clka,
      ena   => data_ram_ena,
      wea   => data_ram_wea,
      addra => data_ram_addr_wr,
      dina  => data_ram_dina,
      clkb  => data_ram_clkb,
      enb   => data_ram_enb,
      addrb => data_ram_addr_rd,
      doutb => data_ram_doutb
      );
  
  wordFromRam <= data_ram_doutb;

  
  -----------------------------------------------------------------------------
  -- store the read pointers
  -----------------------------------------------------------------------------

--  rp_fifo_clk   <= clk;
--  rp_fifo_srst  <= '0' when rst ='1' else '1';
--  rp_fifo_din   <= "00000000000000000000000000" & data_ram_addr_wr;
--  rp_fifo_wr_en <= '1' when flaggedWordIn.word.SOE = '1' else '0';
--  rp_fifo_rd_en <= '1' when flaggedWordIn.word.EOE = '1' and rp_fifo_empty = '0' else '0';
--
--  e_fifofo_read_pointers_delay_ram : entity work.fifo_read_pointers_delay_ram
--    port map (
--      clk   => rp_fifo_clk,
--      srst  => rp_fifo_srst,
--      din   => rp_fifo_din,
--      wr_en => rp_fifo_wr_en,
--      rd_en => rp_fifo_rd_en,
--      dout  => rp_fifo_dout,
--      full  => rp_fifo_full,
--      empty => rp_fifo_empty
--      );

end architecture behavioural;
