--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using STD_LOGIC_UNSIGNED
--use IEEE.std_logic_unsigned.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! Using the Calo-L2 "mp7_data" data-types
use work.mp7_data_types.all;

--! hgc data types
use work.hgc_data_types.all;


entity cluster_data is

  generic (
    nRows    : integer := 5;
    nColumns : integer := 5
    );
  port (
    clk : in std_logic;
    rst : in std_logic;

    we            : in std_logic;
    row           : in std_logic_vector(2 downto 0);  -- this is relative to the seed
    col           : in std_logic_vector(2 downto 0);  -- this is relative to the seed
    flaggedWordIn : in hgcFlaggedWord;
    send          : in std_logic;
    occupancy     : in std_logic_matrix(0 to nRows-1, 0 to nColumns-1) := (others => (others => '0'));

    sent           : out std_logic := '0';
    flaggedWordOut : out hgcFlaggedWord;
    dataValid      : out std_logic := '0'
    );

end entity cluster_data;


architecture arch_cluster_data of cluster_data is

  signal addrA             : std_logic_vector(5 downto 0);
  signal dataA_in          : std_logic_vector(31 downto 0);
  signal addrB             : std_logic_vector(5 downto 0);
  --signal a_rd_1  : std_logic_vector(3 downto 0); 
  signal weA               : std_logic;
  signal dataA_out         : std_logic_vector(31 downto 0);
  signal dataB_out         : std_logic_vector(31 downto 0);
  signal ramFlaggedWordOut : hgcFlaggedWord;
  signal ramFlaggedWordOut_1 : hgcFlaggedWord;

  signal erase : std_logic;

  signal valid   : std_logic := '0';
  signal valid_1 : std_logic := '0';

begin  -- architecture arch_cluster_data

  -----------------------------------------------------------------------------
  -- input to ram
  -----------------------------------------------------------------------------

  -- port A
  weA       <= we or erase;
  addrA     <= row & col;
  dataValid <= valid or valid_1;

  e_hgcFlagged2ram : entity work.hgcFlagged2ram
    port map (
      hgcFlaggedWord => flaggedWordIn,
      ram            => dataA_in
      );

  -- port B
  p_addrB : process (clk) is
    --variable r : std_logic_vector(2 downto 0) := (others => '0');
    --variable c : std_logic_vector(2 downto 0) := (others => '0');
    variable r : integer := 0;
    variable c : integer := 0;
  begin
    if rising_edge(clk) then

      if rst = '0' then
        r     := 0;
        c     := 0;
        sent  <= '0';
        valid <= '0';
      elsif send = '1' then
        if c = (nColumns-1) and r = (nRows-1) then
          r     := r;
          c     := c;
          sent  <= '1';
          valid <= '0';
        elsif c = (nColumns-1) then
          r     := r+1;
          c     := 0;
          sent  <= '0';
          valid <= '1';
        else
          r     := r;
          c     := c+1;
          sent  <= '0';
          valid <= '1';
        end if;
      end if;

      valid_1 <= valid;

      addrB <= std_logic_vector(to_unsigned(r, row'length)) & std_logic_vector(to_unsigned(c, col'length));
      --if occupancy(r,c) = '1' then
        --ramFlaggedWordOut_1 <= ramFlaggedWordOut;
      flaggedWordOut <= ramFlaggedWordOut;
      --else
      --  flaggedWordOut <= HGCFLAGGEDWORD_NULL;
      --end if;

    end if;
  end process p_addrB;

  -----------------------------------------------------------------------------
  -- DRAM
  -----------------------------------------------------------------------------
  e_clu_data_ram : entity work.clu_data_ram
    port map (
      a    => addrA,                    -- address
      d    => dataA_in,                 -- data in
      dpra => addrB,                    -- dual port address
      clk  => clk,
      we   => we,                       -- wr enable
      spo  => dataA_out,                -- output of port a
      dpo  => dataB_out                 -- otput of port dpra
      );

  -----------------------------------------------------------------------------
  -- output from ram
  -----------------------------------------------------------------------------
  ram2hgcFlaggedWord_1 : entity work.ram2hgcFlaggedWord
    port map (
      ram            => dataB_out,
      hgcFlaggedWord => ramFlaggedWordOut
      );

--  flaggedWordOut <= ramFlaggedWordOut when occupancy( to_integer(unsigned(addrB( (addrB'length-1) downto (addrB'length-row'length) ) ) ), to_integer( unsigned( addrB( (addrB'length-row'length) downto 0 ) ) ) ) = '1' else
--                    HGCFLAGGEDWORD_NULL;
-- flaggedWordOut <= ramFlaggedWordOut;

end architecture arch_cluster_data;
