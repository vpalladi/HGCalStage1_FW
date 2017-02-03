-- --------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! @brief An entity providing a PackedLinkPipe
--! @details Detailed description
ENTITY PackedLinkPipe IS
  PORT(
    clk            : IN STD_LOGIC               := '0' ; --! The algorithm clock
    PackedLinkIn   : IN tPackedLinkInCandidates := cEmptyPackedLinkInCandidates;
    PackedLinkPipe : OUT tPackedLinkPipe
  );
END PackedLinkPipe;

--! @brief Architecture definition for entity PackedLinkPipe
--! @details Detailed description
ARCHITECTURE behavioral OF PackedLinkPipe IS
    SIGNAL PackedLinkPipeInternal : tPackedLinkPipe( PackedLinkPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyPackedLinkInCandidates );
BEGIN

  PackedLinkPipeInternal( 0 ) <= PackedLinkIn ; -- since the data is clocked out , no need to clock it in as well...

  gTowerPipe : FOR i IN PackedLinkPipe'LENGTH-1 DOWNTO 1 GENERATE
    PackedLinkPipeInternal( i ) <= PackedLinkPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gTowerPipe;

  PackedLinkPipe <= PackedLinkPipeInternal;
END ARCHITECTURE behavioral;
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! @brief An entity providing a PackedLinkFifo
--! @details Detailed description
ENTITY PackedLinkFifo IS
  GENERIC(
    Offsets : tPackedLinkOffsets
  );
  PORT(
    clk               : IN STD_LOGIC := '0' ; --! The algorithm clock
    PackedLinkPipeIn  : IN tPackedLinkPipe ;  --! A pipe of tPackedLink objects bringing in the PackedLink's
    PackedLinkPipeOut : OUT tPackedLinkPipe   --! A pipe of tPackedLink objects passing out the PackedLink's
  );
END PackedLinkFifo;

--! @brief Architecture definition for entity PackedLinkFifo
--! @details Detailed description
ARCHITECTURE behavioral OF PackedLinkFifo IS
  TYPE tData IS ARRAY( Offsets'RANGE ) OF STD_LOGIC_VECTOR( 33 DOWNTO 0 );
  SIGNAL FlatDataIn , FlatDataOut : tData                   := ( OTHERS => ( OTHERS => '0' ) );
  SIGNAL DataOut                  : tPackedLinkInCandidates := cEmptyPackedLinkInCandidates;
  SIGNAL Delay                    : tData                   := ( OTHERS => ( OTHERS => '0' ) );

BEGIN

  candidate : FOR i IN Offsets'RANGE GENERATE
    g0      : IF Offsets( i ) < 3 GENERATE
      DataOut( i ) <= PackedLinkPipeIn( Offsets( i ) )( i );
    END GENERATE g0;

    gOther : IF Offsets( i ) >= 3 GENERATE
      Delay( i )( 5 DOWNTO 0 ) <= STD_LOGIC_VECTOR( TO_UNSIGNED( Offsets( i ) -2 , 6 ) );
      FlatDataIn( i )          <= TO_STD_LOGIC( PackedLinkPipeIn( 0 )( i ) .DataValid ) & TO_STD_LOGIC( PackedLinkPipeIn( 0 )( i ) .AccumulationComplete ) & PackedLinkPipeIn( 0 )( i ) .Data;

      FifoInstance : ENTITY work.OutputFifo
      PORT MAP(
        a   => Delay( i )( 5 DOWNTO 0 ) ,
        d   => FlatDataIn( i ) ,
        clk => clk ,
        q   => FlatDataOut( i )
      );

      DataOut( i ) .DataValid            <= ( FlatDataOut( i )( 33 ) = '1' );
      DataOut( i ) .AccumulationComplete <= ( FlatDataOut( i )( 32 ) = '1' );
      DataOut( i ) .Data                 <= FlatDataOut( i )( 31 DOWNTO 0 );
    END GENERATE gOther;
  END GENERATE candidate;

  PackedLinkPipeInstance : ENTITY work.PackedLinkPipe
  PORT MAP(
    clk            => clk ,
    PackedLinkIn   => DataOut ,
    PackedLinkPipe => PackedLinkPipeOut
  );

END ARCHITECTURE behavioral;
