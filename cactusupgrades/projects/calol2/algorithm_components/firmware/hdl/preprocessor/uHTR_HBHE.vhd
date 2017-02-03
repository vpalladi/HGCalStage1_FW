----------------------------------------------------------------------------------
-- uHTR_HBHE packet decoder
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

--! @brief An entity providing a uHTR_HBHE
--! @details Detailed description
ENTITY uHTR_HBHE IS
    PORT( clk         : IN STD_LOGIC    := '0';
           link_in    : IN lword        := LWORD_NULL;
           region_out : OUT tuHTRregion := cEmptyUHTRregion
          );
END uHTR_HBHE;

--! @brief Architecture definition for entity uHTR_HBHE
--! @details Detailed description
ARCHITECTURE behavioral OF uHTR_HBHE IS
  SIGNAL lCounter : INTEGER RANGE 0 TO 3 := 0;
BEGIN

  PROCESS( clk )
    VARIABLE lRegion : tuHTRregion := cEmptyUHTRregion;
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN

-- ----------------------------------------------------------------------------

      IF( link_in.valid = '1' AND link_in.strobe = '1' ) THEN
        lCounter <= lCounter + 1;

        CASE lCounter IS
          WHEN 0 =>
            lRegion := cEmptyUHTRregion;
            IF( link_in.data( 7 DOWNTO 0 ) == x"00" ) THEN
              lRegion.BC0 := TRUE;
            ELSE
              lRegion.BC0 := FALSE;
            END IF;

            lRegion.Tower( 0 ) .ET( 7 DOWNTO 0 ) := link_in.data( 15 DOWNTO 8 ) ; -- a
            lRegion.Tower( 1 ) .ET( 7 DOWNTO 0 ) := link_in.data( 23 DOWNTO 16 ) ; -- b
            lRegion.Tower( 2 ) .ET( 7 DOWNTO 0 ) := link_in.data( 31 DOWNTO 24 ) ; -- c
          WHEN 1 =>
            lRegion.Tower( 3 ) .ET( 7 DOWNTO 0 ) := link_in.data( 7 DOWNTO 0 ) ; -- d
            lRegion.Tower( 4 ) .ET( 7 DOWNTO 0 ) := link_in.data( 15 DOWNTO 8 ) ; -- e
            lRegion.Tower( 5 ) .ET( 7 DOWNTO 0 ) := link_in.data( 23 DOWNTO 16 ) ; -- f
            lRegion.Tower( 6 ) .ET( 7 DOWNTO 0 ) := link_in.data( 31 DOWNTO 24 ) ; -- g
          WHEN 2 =>
            lRegion.Tower( 7 ) .ET( 7 DOWNTO 0 )    := link_in.data( 7 DOWNTO 0 ) ; -- h

            lRegion.Tower( 0 ) .Flags( 5 DOWNTO 0 ) := link_in.data( 13 DOWNTO 8 ) ; -- a
            lRegion.Tower( 1 ) .Flags( 5 DOWNTO 0 ) := link_in.data( 19 DOWNTO 14 ) ; -- b
            lRegion.Tower( 2 ) .Flags( 5 DOWNTO 0 ) := link_in.data( 25 DOWNTO 20 ) ; -- c
            lRegion.Tower( 3 ) .Flags( 5 DOWNTO 0 ) := link_in.data( 31 DOWNTO 26 ) ; -- d
          WHEN 3 =>
            lRegion.Tower( 4 ) .Flags( 5 DOWNTO 0 ) := link_in.data( 5 DOWNTO 0 ) ; -- e
            lRegion.Tower( 5 ) .Flags( 5 DOWNTO 0 ) := link_in.data( 11 DOWNTO 6 ) ; -- f
            lRegion.Tower( 6 ) .Flags( 5 DOWNTO 0 ) := link_in.data( 17 DOWNTO 12 ) ; -- g
            lRegion.Tower( 7 ) .Flags( 5 DOWNTO 0 ) := link_in.data( 23 DOWNTO 18 ) ; -- h

            lRegion.CRC( 7 DOWNTO 0 )               := link_in.data( 31 DOWNTO 24 );


-- lRegion.Tower( 8 ) .ET( 7 ) := link_in.data( 8 );
-- lRegion.Tower( 8 ) .Isolation := link_in.data( 9 );
-- lRegion.Hamming( 4 ) := link_in.data( 14 downto 10 );
-- lRegion.BC0( 4 ) := link_in.data( 15 );

-- lRegion.HammingError( 3 ) := HammingCheck( -- lRegion.BC0( 3 ) & -- lRegion.Tower( 6 ) .Isolation & -- lRegion.Tower( 6 ) .ET & -- lRegion.Tower( 5 ) .Isolation & -- lRegion.Tower( 5 ) .ET , -- lRegion.Hamming( 3 ) );
-- lRegion.HammingError( 4 ) := HammingCheck( -- lRegion.BC0( 4 ) & -- lRegion.Tower( 8 ) .Isolation & -- lRegion.Tower( 8 ) .ET & -- lRegion.Tower( 7 ) .Isolation & -- lRegion.Tower( 7 ) .ET , -- lRegion.Hamming( 4 ) );

            lRegion.DataValid                       := TRUE;
            lCounter <= 0;
        END CASE;

      ELSE
        lCounter <= 0;
        lRegion := cEmptyUHTRregion;
      END IF;
-- ----------------------------------------------------------------------------

      region_out <= lRegion;
    END IF;
  END PROCESS;


END ARCHITECTURE behavioral;
