----------------------------------------------------------------------------------
-- oSLB packet decoder
-- CURRENTLY MAKES NO PROVISION FOR DECODING CONTROL PACKETS ,
----------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;
--! Using the Calo-L2 "preprocessor" data-types
USE work.preprocessor_types.ALL;
--! Using the Calo-L2 "preprocessor" helper functions
USE work.preprocessor_functions.ALL;

-- type lword is record
-- data : std_logic_vector( LWORD_WIDTH - 1 downto 0 );
-- valid : std_logic;
-- start : std_logic;
-- strobe : std_logic;
-- end record;

-- Can be used to

-- ( a ) Insert Hamming code into data stream
-- ( b ) Check Hamming code
-- ( c ) Extract OSLB data

--! @brief An entity providing a oSLB
--! @details Detailed description
ENTITY oSLB IS
    PORT( clk                : IN STD_LOGIC    := '0';
           link_in           : IN lword        := LWORD_NULL;
           link_out          : OUT lword       := LWORD_NULL;
           hamming_error_out : OUT STD_LOGIC   := '0';
           hamming_check_out : OUT STD_LOGIC   := '0';
           region_out        : OUT tOSLBregion := cEmptyOSLBregion
          );
END oSLB;

--! @brief Architecture definition for entity oSLB
--! @details Detailed description
ARCHITECTURE behavioral OF oSLB IS
  SIGNAL lCounter : INTEGER RANGE 0 TO 6 := 0 ; -- Need 1 extra for sim reasons
BEGIN

  PROCESS( clk )
    VARIABLE lRegion : tOSLBregion := cEmptyOSLBregion;
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN

      link_out          <= link_in;
      hamming_error_out <= '0';
      hamming_check_out <= '0';

      IF( link_in.valid = '1' ) THEN
        lCounter <= lCounter + 1;

        CASE lCounter IS
          WHEN 0 =>
            lRegion                              := cEmptyOSLBregion;
            lRegion.Tower( 1 ) .ET( 7 DOWNTO 0 ) := link_in.data( 7 DOWNTO 0 );
            lRegion.Tower( 3 ) .ET( 7 DOWNTO 0 ) := link_in.data( 15 DOWNTO 8 );
          WHEN 1 =>
            lRegion.Tower( 5 ) .ET( 7 DOWNTO 0 ) := link_in.data( 7 DOWNTO 0 );
            lRegion.Tower( 7 ) .ET( 7 DOWNTO 0 ) := link_in.data( 15 DOWNTO 8 );
          WHEN 2 =>
            lRegion.Tower( 1 ) .Isolation        := link_in.data( 0 );
            lRegion.Tower( 2 ) .ET( 6 DOWNTO 0 ) := link_in.data( 7 DOWNTO 1 );
            lRegion.Tower( 3 ) .Isolation        := link_in.data( 8 );
            lRegion.Tower( 4 ) .ET( 6 DOWNTO 0 ) := link_in.data( 15 DOWNTO 9 );
          WHEN 3 =>
            lRegion.Tower( 5 ) .Isolation        := link_in.data( 0 );
            lRegion.Tower( 6 ) .ET( 6 DOWNTO 0 ) := link_in.data( 7 DOWNTO 1 );
            lRegion.Tower( 7 ) .Isolation        := link_in.data( 8 );
            lRegion.Tower( 8 ) .ET( 6 DOWNTO 0 ) := link_in.data( 15 DOWNTO 9 );
          WHEN 4 =>
            lRegion.Tower( 2 ) .ET( 7 )   := link_in.data( 0 );
            lRegion.Tower( 2 ) .Isolation := link_in.data( 1 );
            lRegion.Hamming( 1 )          := link_in.data( 6 DOWNTO 2 );
            lRegion.BC0( 1 )              := link_in.data( 7 );

            lRegion.Tower( 4 ) .ET( 7 )   := link_in.data( 8 );
            lRegion.Tower( 4 ) .Isolation := link_in.data( 9 );
            lRegion.Hamming( 2 )          := link_in.data( 14 DOWNTO 10 );
            lRegion.BC0( 2 )              := link_in.data( 15 );

            lRegion.HammingError( 1 )     := NOT HammingCheck( lRegion.BC0( 1 ) & lRegion.Tower( 2 ) .Isolation & lRegion.Tower( 2 ) .ET & lRegion.Tower( 1 ) .Isolation & lRegion.Tower( 1 ) .ET , lRegion.Hamming( 1 ) );
            lRegion.HammingError( 2 )     := NOT HammingCheck( lRegion.BC0( 2 ) & lRegion.Tower( 4 ) .Isolation & lRegion.Tower( 4 ) .ET & lRegion.Tower( 3 ) .Isolation & lRegion.Tower( 3 ) .ET , lRegion.Hamming( 2 ) );

            link_out.data( 14 DOWNTO 10 ) <= Hamming( lRegion.BC0( 2 ) & lRegion.Tower( 4 ) .Isolation & lRegion.Tower( 4 ) .ET & lRegion.Tower( 3 ) .Isolation & lRegion.Tower( 3 ) .ET );
            link_out.data( 6 DOWNTO 2 )   <= Hamming( lRegion.BC0( 1 ) & lRegion.Tower( 2 ) .Isolation & lRegion.Tower( 2 ) .ET & lRegion.Tower( 1 ) .Isolation & lRegion.Tower( 1 ) .ET );
          WHEN 5 =>
            lRegion.Tower( 6 ) .ET( 7 )   := link_in.data( 0 );
            lRegion.Tower( 6 ) .Isolation := link_in.data( 1 );
            lRegion.Hamming( 3 )          := link_in.data( 6 DOWNTO 2 );
            lRegion.BC0( 3 )              := link_in.data( 7 );

            lRegion.Tower( 8 ) .ET( 7 )   := link_in.data( 8 );
            lRegion.Tower( 8 ) .Isolation := link_in.data( 9 );
            lRegion.Hamming( 4 )          := link_in.data( 14 DOWNTO 10 );
            lRegion.BC0( 4 )              := link_in.data( 15 );

            lRegion.HammingError( 3 )     := NOT HammingCheck( lRegion.BC0( 3 ) & lRegion.Tower( 6 ) .Isolation & lRegion.Tower( 6 ) .ET & lRegion.Tower( 5 ) .Isolation & lRegion.Tower( 5 ) .ET , lRegion.Hamming( 3 ) );
            lRegion.HammingError( 4 )     := NOT HammingCheck( lRegion.BC0( 4 ) & lRegion.Tower( 8 ) .Isolation & lRegion.Tower( 8 ) .ET & lRegion.Tower( 7 ) .Isolation & lRegion.Tower( 7 ) .ET , lRegion.Hamming( 4 ) );

            link_out.data( 14 DOWNTO 10 ) <= Hamming( lRegion.BC0( 4 ) & lRegion.Tower( 8 ) .Isolation & lRegion.Tower( 8 ) .ET & lRegion.Tower( 7 ) .Isolation & lRegion.Tower( 7 ) .ET );
            link_out.data( 6 DOWNTO 2 )   <= Hamming( lRegion.BC0( 3 ) & lRegion.Tower( 6 ) .Isolation & lRegion.Tower( 6 ) .ET & lRegion.Tower( 5 ) .Isolation & lRegion.Tower( 5 ) .ET );

            lRegion.DataValid := TRUE;
            lCounter          <= 0;
            hamming_error_out <= lRegion.HammingError( 4 ) OR lRegion.HammingError( 3 ) OR lRegion.HammingError( 2 ) OR lRegion.HammingError( 1 );
            hamming_check_out <= '1';
          WHEN OTHERS =>
            lCounter <= 0;
        END CASE;

      ELSE
        hamming_error_out <= '0';
        hamming_check_out <= '0';
        lCounter          <= 0;
        lRegion := cEmptyOSLBregion;
      END IF;
-- ----------------------------------------------------------------------------

      region_out <= lRegion;
    END IF;
  END PROCESS;


END ARCHITECTURE behavioral;
