-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;
--! Using the Calo-L2 "demux" data-types
USE work.demux_types.ALL;

--! @brief An entity providing a demux_by_type
--! @details Detailed description
ENTITY demux_by_type IS
  GENERIC(
    NumberOfMPs     : INTEGER := 0;
    TapParameterSet : tTapParametersSet
  );
  PORT(
    clk      : IN STD_LOGIC ; --! The algorithm clock
    LinksIn  : IN ldata( NumberOfMPs-1 DOWNTO 0 )               := ( OTHERS => LWORD_NULL );
    LinksOut : OUT ldata( TapParameterSet'LENGTH - 1 DOWNTO 0 ) := ( OTHERS => LWORD_NULL )
  );
END demux_by_type;


--! @brief Architecture definition for entity demux_by_type
--! @details Detailed description
ARCHITECTURE behavioral OF demux_by_type IS
  SIGNAL lCounters                  : tCounters( NumberOfMPs-1 DOWNTO 0 )        := ( OTHERS => 127 );
  SIGNAL lCounterEnable             : STD_LOGIC_VECTOR( NumberOfMPs-1 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL LinksInt , LinksIntDelayed : ldata( NumberOfMPs-1 DOWNTO 0 )            := ( OTHERS => LWORD_NULL );
  CONSTANT CLKS_TIME_MUX_PERIOD     : NATURAL                                    := NumberOfMPs * 6;
BEGIN

-- TRIVIAL TO ADD A TIMING CHECK HERE!
  PROCESS( clk )
  BEGIN
    IF RISING_EDGE( clk ) THEN
      FOR j IN 0 TO NumberOfMPs-1 LOOP
        IF( LinksIn( j ) .valid = '1' AND LinksInt( j ) .valid = '0' ) THEN
          lCounters( j ) <= 0;
        ELSE
          IF( lCounters( j ) < 127 ) THEN
            lCounters( j ) <= lCounters( j ) + 1;
          END IF;
        END IF;
      END LOOP;
      LinksInt        <= LinksIn;
      LinksIntDelayed <= LinksInt;
    END IF;
  END PROCESS;

  gTaps : FOR i IN 0 TO TapParameterSet'LENGTH - 1 GENERATE
    PROCESS( clk )
      VARIABLE LinksMerge : lword := LWORD_NULL;
    BEGIN
      IF RISING_EDGE( clk ) THEN
        LinksMerge := LWORD_NULL;
        FOR j IN 0 TO NumberOfMPs-1 LOOP
          IF lCounters( j ) = TapParameterSet( i ) .Offset THEN
            LinksMerge.data  := LinksMerge.data OR LinksInt( j ) .data;
            LinksMerge.valid := LinksMerge.valid OR LinksInt( j ) .valid;
          END IF;
          LinksOut( i ) <= LinksMerge;
        END LOOP;
      END IF;
    END PROCESS;
  END GENERATE;

END ARCHITECTURE behavioral;
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------



-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;
--! Using the Calo-L2 "demux" data-types
USE work.demux_types.ALL;

--! @brief An entity providing a demux
--! @details Detailed description
ENTITY demux IS
  GENERIC(
    NumberOfMPs     : INTEGER := 0;
    LinksPerMPs     : INTEGER := 0;
    TapParameterSet : tTapParametersSet
  );
  PORT(
    clk      : IN STD_LOGIC ; --! The algorithm clock
    LinksIn  : IN ldata( cNumberOfLinksIn-1 DOWNTO 0 )                           := ( OTHERS => LWORD_NULL );
    LinksOut : OUT ldata( ( TapParameterSet'LENGTH * LinksPerMPs ) -1 DOWNTO 0 ) := ( OTHERS => LWORD_NULL )
  );
END demux;


--! @brief Architecture definition for entity demux
--! @details Detailed description
ARCHITECTURE behavioral OF demux IS
  TYPE tLinksInByType IS ARRAY( LinksPerMPs-1 DOWNTO 0 ) OF ldata( NumberOfMPs-1 DOWNTO 0 );
  SIGNAL LinksInByType : tLinksInByType := ( OTHERS => ( OTHERS => LWORD_NULL ) );

  TYPE tLinksOutByType IS ARRAY( LinksPerMPs-1 DOWNTO 0 ) OF ldata( TapParameterSet'LENGTH - 1 DOWNTO 0 );
  SIGNAL LinksOutByType    : tLinksOutByType := ( OTHERS => ( OTHERS => LWORD_NULL ) );

  CONSTANT HalfNumberOfMPs : NATURAL         := 6;

BEGIN

-- ------------------------------------------------------------------------------------
-- Map Input Links
  gI1     : FOR i IN 0 TO NumberOfMPs-1 GENERATE
    gJ1   : FOR j IN 0 TO LinksPerMPs-1 GENERATE

      RX1 : IF i < HalfNumberOfMPs GENERATE
        LinksInByType( j )( i ) <= LinksIn( ( HalfNumberOfMPs * j ) + i ) ; -- Groups fibre by data-type
      END GENERATE;
      RX2 : IF i > ( HalfNumberOfMPs - 1 ) GENERATE
        LinksInByType( j )( i ) <= LinksIn( 60 - ( HalfNumberOfMPs * j ) + i ) ; -- Groups fibre by data-type
      END GENERATE;


    END GENERATE;
  END GENERATE;
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  gByLinkType : FOR j IN 0 TO LinksPerMPs-1 GENERATE
    instance  : ENTITY work.demux_by_type
    GENERIC MAP(
      NumberOfMPs     => NumberOfMPs ,
      TapParameterSet => TapParameterSet
    )
    PORT MAP(
      clk      => clk ,
      LinksIn  => LinksInByType( j ) ,
      LinksOut => LinksOutByType( j )
    );
  END GENERATE;
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
-- Map Output Links
  gI2   : FOR i IN 0 TO( TapParameterSet'LENGTH-1 ) GENERATE
    gJ2 : FOR j IN 0 TO LinksPerMPs-1 GENERATE
      LinksOut( ( TapParameterSet'LENGTH * j ) + i ) <= LinksOutByType( j )( i );
    END GENERATE;
  END GENERATE;
-- ------------------------------------------------------------------------------------


END ARCHITECTURE behavioral;
