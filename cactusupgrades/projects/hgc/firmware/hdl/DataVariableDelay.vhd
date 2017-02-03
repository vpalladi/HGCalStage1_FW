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
    clk     : in  std_logic;
    rst     : in  std_logic;
    flaggedWordIn  : in  hgcFlaggedWord;
    flaggedWordOut : out hgcFlaggedWord;
    we : out std_logic;
    EOE : out std_logic
    );

end entity DataVariableDelay;

architecture behavioural of DataVariableDelay is

  -- storage ram 
  signal data_ram_clka    : std_logic;
  signal data_ram_ena     : std_logic;
  signal data_ram_wea     : std_logic_vector (0 to 0);
  signal data_ram_addr_wr : std_logic_vector (5 downto 0)  := (others => '0');
  signal data_ram_dina    : std_logic_vector (31 downto 0);
  signal data_ram_clkb    : std_logic;
  signal data_ram_enb     : std_logic;
  signal data_ram_addr_rd : std_logic_vector (5 downto 0)  := (others => '0');
  signal data_ram_doutb   : std_logic_vector (31 downto 0) := (others => '0');

  -- read pointers fifo
  signal rp_fifo_clk   : std_logic;
  signal rp_fifo_srst  : std_logic;
  signal rp_fifo_din   : std_logic_vector(31 downto 0);
  signal rp_fifo_wr_en : std_logic := '0';
  signal rp_fifo_rd_en : std_logic;
  signal rp_fifo_dout  : std_logic_vector(31 downto 0);
  signal rp_fifo_full  : std_logic;
  signal rp_fifo_empty : std_logic;

  -- helpers
  signal new_bx_detected : std_logic := '0';
  signal firstEventDetected : std_logic := '0';     

  
begin  -- architecture behavioural


  -----------------------------------------------------------------------------
  -- ports assignemets
  -----------------------------------------------------------------------------
  EOE <= new_bx_detected;
  --we <= '1' when flaggedWordOut.valid = '1' else
  --'0';
  we <= '1' when data_ram_doutb(16) = '1' else
        '0';
  --we <= '1';

  new_bx_detected <= '1' when (flaggedWordIn.address.row & flaggedWordIn.address.col & flaggedWordIn.energy) = x"BCBC"
                     else '0';

  -----------------------------------------------------------------------------
  -- data storage
  -----------------------------------------------------------------------------
  data_ram_clka   <= clk;
  data_ram_ena    <= '1';
  data_ram_wea(0) <= firstEventDetected;
  data_ram_clkb   <= clk;
  data_ram_enb    <= firstEventDetected;

  data_ram_dina <= "0000000000000" & flaggedWordIn.dataFlag & flaggedWordIn.seedFlag & flaggedWordIn.valid & flaggedWordIn.address.row & flaggedWordIn.address.col & flaggedWordIn.energy when rising_edge(clk)
                   else data_ram_dina;

  
  -- handle the wr_ptr
  firstEventDetected <= '1' when rising_edge(clk) and firstEventDetected = '0' and flaggedWordIn.address.row & flaggedWordIn.address.col = x"BC" and flaggedWordIn.energy = x"BC"
                        else firstEventDetected; 

  process_increment_wr_ptr : process (clk) is
  begin
    if rising_edge(clk) then
      
      if firstEventDetected = '1' then
        data_ram_addr_wr <= data_ram_addr_wr + 1;
      end if;
      
    end if;
  end process process_increment_wr_ptr;

  -- handle the rd_ptr
  data_ram_addr_rd <=  data_ram_addr_rd + 1 when rp_fifo_empty = '0' and rising_edge(clk)
                       else data_ram_addr_rd;

  variable_data_delay_1 : entity work.variable_data_delay
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

  flaggedWordOut.dataFlag <= data_ram_doutb(18);
  flaggedWordOut.seedFlag <= data_ram_doutb(17);
  flaggedWordOut.valid    <= data_ram_doutb(16);
  flaggedWordOut.address.row  <= data_ram_doutb(15 downto 12);
  flaggedWordOut.address.col  <= data_ram_doutb(11 downto 8);
  flaggedWordOut.energy   <= data_ram_doutb(7 downto 0);

  -----------------------------------------------------------------------------
  -- store the read pointers
  -----------------------------------------------------------------------------

  rp_fifo_clk   <= clk;
  rp_fifo_srst  <= rst;
  rp_fifo_din   <= "00000000000000000000000000" & data_ram_addr_wr;
  rp_fifo_wr_en <= '1' when new_bx_detected = '1' and firstEventDetected='1'
                   else '0';
  rp_fifo_rd_en <= '1' when new_bx_detected = '1' and rp_fifo_empty = '0'
                   else '0';

  fifofo_read_pointers_delay_ram_1 : entity work.fifo_read_pointers_delay_ram
    port map (
      clk   => rp_fifo_clk,
      srst  => rp_fifo_srst,
      din   => rp_fifo_din,
      wr_en => rp_fifo_wr_en,
      rd_en => rp_fifo_rd_en,
      dout  => rp_fifo_dout,
      full  => rp_fifo_full,
      empty => rp_fifo_empty
      );

end architecture behavioural;
