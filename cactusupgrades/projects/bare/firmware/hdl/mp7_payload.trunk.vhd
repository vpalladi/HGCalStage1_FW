LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.ipbus.ALL;
USE work.mp7_data_types.ALL;
USE work.top_decl.ALL;
USE work.mp7_brd_decl.ALL;
USE work.mp7_ttc_decl.ALL;

ENTITY mp7_payload IS
  PORT(
    clk         : IN STD_LOGIC ; -- ipbus signals
    rst         : IN STD_LOGIC;
    ipb_in      : IN ipb_wbus;
    ipb_out     : OUT ipb_rbus;
    clk_payload : IN STD_LOGIC_VECTOR( 2 DOWNTO 0 );
    rst_payload : IN STD_LOGIC_VECTOR( 2 DOWNTO 0 );
    clk_p       : IN STD_LOGIC ; -- data clock
    rst_loc     : IN STD_LOGIC_VECTOR( N_REGION - 1 DOWNTO 0 );
    clken_loc   : IN STD_LOGIC_VECTOR( N_REGION - 1 DOWNTO 0 );
    ctrs        : IN ttc_stuff_array;
    bc0         : OUT STD_LOGIC;
    d           : IN ldata( 4 * N_REGION - 1 DOWNTO 0 ) ; -- data in
    q           : OUT ldata( 4 * N_REGION - 1 DOWNTO 0 ) ; -- data out
    gpio        : OUT STD_LOGIC_VECTOR( 29 DOWNTO 0 ) ; -- IO to mezzanine connector
    gpio_en     : OUT STD_LOGIC_VECTOR( 29 DOWNTO 0 ) -- IO to mezzanine connector( three-state enables )
  );
END mp7_payload;


ARCHITECTURE rtl OF mp7_payload IS
BEGIN

-- ---------------------------------------------------------------------------------
  AlgorithmInstance : ENTITY work.MainProcessorTop
  PORT MAP(
    clk       => clk_p ,
    LinksIn   => d ,
    LinksOut  => q ,
--IPbus
    ipbus_clk => clk ,
    ipbus_rst => rst ,
    ipbus_in  => ipb_in ,
    ipbus_out => ipb_out
  );
-- ---------------------------------------------------------------------------------

  gpio    <= ( OTHERS => '0' );
  gpio_en <= ( OTHERS => '0' );

END rtl;
