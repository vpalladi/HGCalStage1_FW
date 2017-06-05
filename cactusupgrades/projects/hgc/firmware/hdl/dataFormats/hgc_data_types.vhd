-- Defines the fundamental data type for the HGC
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package hgc_data_types is

  -- std types
  type std_logic_matrix is array (natural range <>,natural range <>) of std_logic;
  type std_logic_array is array (natural range<>) of std_logic;
  type natural_array is array (natural range<>) of natural;
  --type std_logic_vector_array is array (natural range<>) of std_logic_vector;
  
  -- specific 
  type hgcAddress is
  record
    wafer : std_logic_vector(2 downto 0);
    row : std_logic_vector(2 downto 0);
    col : std_logic_vector(2 downto 0);
  end record;

  constant HGCADDR_NULL : hgcAddress := ((others => '0'), (others => '0'), (others => '0'));
  --constant HGCADDR_NEWBX : hgcAddress := ( x"B", x"C");

  type hgcWord is
  record
    valid   : std_logic;
    address : hgcAddress;
    energy  : std_logic_vector(7 downto 0);
    SOE     : std_logic;
    EOE     : std_logic;
  end record;

  type hgcData is array(natural range <>) of hgcWord;

  constant HGCWORD_NULL  : hgcWord             := ('0', HGCADDR_NULL, (others => '0'), '0', '0');
  -- must define a new bx word
  constant HGCDATA_NULL  : hgcData(0 downto 0) := (0 => HGCWORD_NULL);


  type hgcFlaggedWord is
  record
    word : hgcWord;
    bxId : std_logic_vector(7 downto 0);
    dataFlag : std_logic;
    seedFlag : std_logic;
  end record;

  type hgcFlaggedData is array(natural range <>) of hgcFlaggedWord;

  constant HGCFLAGGEDWORD_NULL  : hgcFlaggedWord             := ( HGCWORD_NULL, (others => '0'), '0', '0' );
  --constant HGCFLAGGEDWORD_NEWBX : hgcFlaggedWord             := ('0', HGCADDR_FULL, (others => '1'), '1', '1');
  constant HGCFLAGGEDDATA_NULL  : hgcFlaggedData(0 downto 0) := (0 => HGCFLAGGEDWORD_NULL);

  -- lcuster output
  type hgcFlaggedData_cluOut is array (natural range <>) of hgcFlaggedWord;



  
end hgc_data_types;

