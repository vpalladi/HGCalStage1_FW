--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE STD.TEXTIO.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;
--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;
--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! Using the Calo-L2 "helper" helper functions
USE work.helper_functions.ALL;

USE work.LinkType.ALL;
--! Using the Calo-L2 "Link" testbench suite
USE work.LinkReference.ALL;
--! Using the Calo-L2 "Tower" testbench suite
USE work.TowerReference.ALL;
--! Using the Calo-L2 "Jet" testbench suite
USE work.JetReference.ALL;

--! Using the Calo-L2 "Cluster" testbench suite
USE work.ClusterReference.ALL;
--! Using the Calo-L2 "Egamma" testbench suite
USE work.EgammaReference.ALL;
--! Using the Calo-L2 "Tau" testbench suite
USE work.TauReference.ALL;

--! Using the Calo-L2 "Ringsum" testbench suite
USE work.RingsumReference.ALL;


--! @brief An entity providing a TestBench
--! @details Detailed description
ENTITY TestBenchDemux IS
GENERIC(
  sourcefile : STRING
);
END TestBenchDemux;

--! @brief Architecture definition for entity TestBench
--! @details Detailed description
ARCHITECTURE behavioral OF TestBenchDemux IS


  TYPE link_array IS ARRAY( 0 TO 5 ) OF ldata( cNumberOfLinksIn-1 DOWNTO 0 );
  TYPE link_pipe  IS ARRAY( 0 TO 35 ) OF link_array;



  SIGNAL clk , ipbus_clk : STD_LOGIC                            := '1';
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- LINK SIGNALS
  SIGNAL links_in        : ldata( cNumberOfLinksIn-1 DOWNTO 0 ) := ( OTHERS => LWORD_NULL );
  SIGNAL links_pipe      : link_pipe                            := ( OTHERS => ( OTHERS => ( OTHERS => LWORD_NULL ) ) );
  SIGNAL links_demux     : ldata( cNumberOfLinksIn-1 DOWNTO 0 ) := ( OTHERS => LWORD_NULL );
  SIGNAL links_out       : ldata( cNumberOfLinksIn-1 DOWNTO 0 ) := ( OTHERS => LWORD_NULL );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

BEGIN

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    clk       <= NOT clk AFTER 2083 ps;
    ipbus_clk <= NOT ipbus_clk AFTER 30 ns;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- =========================================================================================================================================================================================
  references                 : PROCESS( clk )
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CLOCK COUNTER
    VARIABLE clk_count       : INTEGER                   := -1;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- LINK VARIABLES
-- INPUT
    VARIABLE reference_Links : tLinkPipe( 200 DOWNTO 0 ) := ( OTHERS => cEmptyLinks );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    VARIABLE L               : LINE;

  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      WRITE( L , clk_count );
      WRITELINE( OUTPUT , L );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      IF( clk_count = -1 ) THEN
--SourceLinkData( reference_Links );
--SourceLinkDataFile( sourcefile , 12 , 14 , 0 , 40 , FALSE , reference_Links ) ; --For direct capture
    SourceLinkDataFile( sourcefile , 1 , 14 , 0 , 40 , FALSE , reference_Links ) ; --For aggregated captures
      END IF;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      LinkStimulus
      (
        clk_count ,
        reference_Links ,
        links_in
      );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      clk_count := clk_count + 1;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  END IF;
  END PROCESS;
-- =========================================================================================================================================================================================


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  g1                      : FOR i IN 0 TO 5 GENERATE

    MainProcessorInstance : ENTITY work.MainProcessorTop
    PORT MAP(
      clk      => clk ,
      LinksIn  => links_in ,
      LinksOut => links_pipe( 0 )( i )
    );

    g2 : FOR j IN 1 TO 35 GENERATE
      links_pipe( j ) <= links_pipe( j-1 ) WHEN RISING_EDGE( clk );
    END GENERATE g2;

    links_demux( i + 0 )  <= links_pipe( 6 * i )( i )( 61 );
    links_demux( i + 6 )  <= links_pipe( 6 * i )( i )( 60 );
    links_demux( i + 12 ) <= links_pipe( 6 * i )( i )( 63 );
    links_demux( i + 18 ) <= links_pipe( 6 * i )( i )( 62 );
    links_demux( i + 24 ) <= links_pipe( 6 * i )( i )( 65 );
    links_demux( i + 30 ) <= links_pipe( 6 * i )( i )( 64 );
  END GENERATE g1;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  DemuxInstance : ENTITY work.DemuxTop
  PORT MAP(
    clk      => clk ,
    LinksIn  => links_demux ,
    LinksOut => links_out
  );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- =========================================================================================================================================================================================

END ARCHITECTURE behavioral;
