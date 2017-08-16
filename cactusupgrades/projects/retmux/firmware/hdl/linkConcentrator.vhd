--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using STD_LOGIC_UNSIGNED
use IEEE.std_logic_unsigned.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! MP7 datatypes
use work.mp7_data_types.all;
--! HGC datatypes
use work.hgc_data_types.all;

entity LinksConcentrator is

  port (
    wclk    : in std_logic;
    rclk    : in std_logic;
    rst     : in std_logic;
    --wena    : in std_logic;
    linkIn0 : in lword;
    linkIn1 : in lword;
    linkIn2 : in lword;
    linkIn3 : in lword;

    rena        : in  std_logic;        -- edge sensitive
    bxAlmostEnd       : out std_logic;  -- active 2 clk cycle before the last word
    bxEnd       : out std_logic;  -- active the same clk cycle of the last word
    readyToSend : out std_logic;
    dataValid   : out std_logic;
    dataOut     : out std_logic_vector(127 downto 0)
    );

end entity LinksConcentrator;

architecture arch_LinksConcentrator of LinksConcentrator is

  -- control signals
  signal rena_received        : std_logic := '0';
  signal bx_end_internal      : std_logic := '0';
  signal bx_end_internal_1    : std_logic := '0';
  signal bx_end_internal_2    : std_logic := '0';
  signal first_event_received : std_logic := '0';

  -- fsm 
  type fsm_status is (fsm_reset, fsm_waiting_first_send, fsm_sending_first_event, fsm_waiting_send, fsm_sending);
  signal state   : fsm_status := fsm_reset;
  signal state_1 : fsm_status ;
  signal state_2 : fsm_status ;

  -- RAM
  signal ram_clka    : std_logic                       := '0';
  signal ram_ena     : std_logic                       := '0';
  signal ram_wea     : std_logic_vector (0 to 0)       := (others => '0');
  signal ram_addra   : std_logic_vector (11 downto 0)  := (others => '0');
  signal ram_dina    : std_logic_vector (127 downto 0) := (others => '0');
  signal ram_dina_1  : std_logic_vector (127 downto 0) := (others => '0');
  signal ram_clkb    : std_logic                       := '0';
  signal ram_enb     : std_logic                       := '0';
  signal ram_addrb   : std_logic_vector (11 downto 0)  := (others => '0');
  signal ram_addrb_1 : std_logic_vector (11 downto 0)  := (others => '0');
  signal ram_doutb   : std_logic_vector (127 downto 0) := (others => '0');

  -- addr FIFO
  signal addr_fifo_clk   : std_logic                      := '0';
  signal addr_fifo_rst   : std_logic                      := '0';
  signal addr_fifo_din   : std_logic_vector (11 downto 0) := (others => '0');
  signal addr_fifo_wr_en : std_logic                      := '0';
  signal addr_fifo_rd_en : std_logic                      := '0';
  signal addr_fifo_dout  : std_logic_vector (11 downto 0) := (others => '0');
  signal addr_fifo_full  : std_logic                      := '0';
  signal addr_fifo_empty : std_logic                      := '0';

begin

  -----------------------------------------------------------------------------
  -- external signals 
  -----------------------------------------------------------------------------
  dataOut <= ram_doutb;
  bxAlmostEnd   <= bx_end_internal;
  bxEnd   <= bx_end_internal_2;
  dataValid <= '1' when state_1 = fsm_sending or state_1 = fsm_sending_first_event or bx_end_internal_2 = '1' else '0';
  
  p_readyToSend : process (rclk) is
    variable words_cnt : integer := 0;
  begin  -- process p_readyToSend
    if rising_edge(rclk) then           -- rising clock edge

      if ram_dina_1 = x"fbfbfbfbfbfbfbfbfbfbfbfbfbfbfbfb" then
        words_cnt := words_cnt + 1;
      elsif bx_end_internal_1 = '1' then
        words_cnt := words_cnt - 1;
      end if;

      if rst = '1' or words_cnt <= 0 then
        readyToSend <= '0';
      elsif words_cnt > 0 then
        readyToSend <= '1';
      end if;

    end if;
  end process p_readyToSend;

  -----------------------------------------------------------------------------
  -- control signals
  -----------------------------------------------------------------------------
  bx_end_internal <= '1' when (state = fsm_sending_first_event or state = fsm_sending) and (to_integer(unsigned(addr_fifo_dout)) - to_integer(unsigned(ram_addrb))) = 1 else '0';
  p_bxEnd : process (rclk) is
  begin  -- process p_bxEnd
    if rising_edge(rclk) then
      bx_end_internal_1 <= bx_end_internal;
      bx_end_internal_2 <= bx_end_internal_1;
    end if;
  end process p_bxEnd;

  p_rena_received : process (wclk) is
  begin  -- process p_rena_received
    if rising_edge(wclk) then           -- rising clock edge

      if rena = '1' and rena_received = '0' then
        rena_received <= '1';
      elsif bx_end_internal = '1' then
        rena_received <= '0';
      end if;

    end if;
  end process p_rena_received;

--  p_first_event_received: process (wclk) is
--  begin  -- process p_first_event_received
--    if rising_edge(wclk) then
--
--      if rst = '1' then
--        first_event_received <= '0';
--      elsif first_event_received = '0' and addr_fifo_empty = '0' then
--        first_event_received <= '1'; 
--      end if;      
--
--    end if;
--  end process p_first_event_received;

  -----------------------------------------------------------------------------
  -- FSM (sending)
  -----------------------------------------------------------------------------
  p_fsm_read : process (rclk) is
  begin  -- process p_fsm_read  
    if rising_edge(rclk) then           -- rising clock edge

      case state is
        when fsm_reset =>                -- reset
          if rst = '1' then
            state <= fsm_reset;
          else
            state <= fsm_waiting_first_send;
          end if;
        when fsm_waiting_first_send =>   -- waiting 1st send
          if rena = '1' then
            state <= fsm_sending_first_event;
          elsif rst = '1' then
            state <= fsm_reset;
          else
            state <= fsm_waiting_first_send;
          end if;
        when fsm_sending_first_event =>  -- sending 1st evt
          if bx_end_internal = '1' then
            state <= fsm_waiting_send;
          elsif rst = '1' then
            state <= fsm_reset;
          else
            state <= fsm_sending_first_event;
          end if;
        when fsm_waiting_send =>         -- waiting send
          if rena = '1' then
            state <= fsm_sending;
          elsif rst = '1' then
            state <= fsm_reset;
          else
            state <= fsm_waiting_send;
          end if;
        when fsm_sending =>              -- sending
          if bx_end_internal = '1' then
            state <= fsm_waiting_send;
          elsif rst = '1' then
            state <= fsm_reset;
          else
            state <= fsm_sending;
          end if;
      end case;

      state_1 <= state;
      state_2 <= state_1;
      
    end if;
  end process p_fsm_read;


  -----------------------------------------------------------------------------
  -- concentrator RAM
  -----------------------------------------------------------------------------

  -- port a
  ram_ena  <= '1';
  ram_clka <= wclk;
  ram_dina <= linkIn3.data & linkIn2.data & linkIn1.data & linkIn0.data;

  p_write_ram : process (wclk) is
  begin
    if rising_edge(wclk) then

      ram_dina_1 <= ram_dina;

      if ram_dina = x"fbfbfbfbfbfbfbfbfbfbfbfbfbfbfbfb" then
        ram_wea(0) <= '1';
      elsif ram_dina_1 = x"bcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbc" then
        ram_wea(0) <= '0';
      end if;

      if ram_wea(0) = '1' then
        ram_addra <= std_logic_vector(to_unsigned((to_integer(unsigned(ram_addra)) + 1), 12));
      end if;

    end if;
  end process p_write_ram;

  -- port b
  ram_enb  <= '1';
  ram_clkb <= rclk;

  p_read_ram : process (rclk) is
  begin
    if rising_edge(rclk) then

      -- !!!needed!!! improve the handling over the end of the memory
      if state_1 = fsm_sending or state = fsm_sending or state_1 = fsm_sending_first_event or state = fsm_sending_first_event then  --
        ram_addrb <= std_logic_vector( to_unsigned( (to_integer(unsigned(ram_addrb)) + 1 ), 12) );
      end if;

    end if;
  end process p_read_ram;

  -- RAM
  e_blk_ram_merge : entity work.blk_ram_merge
    port map (
      clka  => ram_clka,
      ena   => ram_ena,
      wea   => ram_wea,
      addra => ram_addra,
      dina  => ram_dina_1,
      clkb  => ram_clkb,
      enb   => ram_enb,
      addrb => ram_addrb,
      doutb => ram_doutb
      );


  -----------------------------------------------------------------------------
  -- FIFO storing the last address of the BX data-stream
  -----------------------------------------------------------------------------
  -- inputs
  addr_fifo_clk <= wclk;
  addr_fifo_rst <= rst;
  addr_fifo_din <= std_logic_vector(to_unsigned(to_integer(unsigned(ram_addra))+1, 12));

  addr_fifo_wr_en <= '1' when ram_dina = x"bcbcbcbcbcbcbcbcbcbcbcbcbcbcbcbc" else '0';

  -- read fifo
  p_read_addr_fifo : process (rclk) is
    variable fifo_read : std_logic := '0';
  begin  -- process p_read_addr_fifo
    if rising_edge(rclk) then

      if fifo_read = '0' and (state = fsm_sending_first_event or state = fsm_sending) and addr_fifo_empty = '0' then
        fifo_read       := '1';
        addr_fifo_rd_en <= '1';
      elsif (state = fsm_waiting_first_send or state = fsm_waiting_send) and fifo_read = '1' then
        fifo_read       := '0';
        addr_fifo_rd_en <= '0';
      elsif fifo_read = '1' then
        fifo_read       := '1';
        addr_fifo_rd_en <= '0';
      end if;

    end if;
  end process p_read_addr_fifo;

  -- FIFO
  e_fifo_addresses : entity work.fifo_addresses
    port map (
      clk   => addr_fifo_clk,
      rst   => addr_fifo_rst,
      din   => addr_fifo_din,
      wr_en => addr_fifo_wr_en,
      rd_en => addr_fifo_rd_en,
      dout  => addr_fifo_dout,
      full  => addr_fifo_full,
      empty => addr_fifo_empty
      );



end architecture arch_LinksConcentrator;

