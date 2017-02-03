--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Writing to and from files
USE IEEE.STD_LOGIC_TEXTIO.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;
--! Writing to and from files
USE STD.TEXTIO.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

--! @brief An entity providing a MP7CaptureFileWriter
--! @details Detailed description
ENTITY MP7CaptureFileWriter IS
  GENERIC( FileName      : STRING;
           DebugMessages : IN BOOLEAN := FALSE
           );
  PORT( clk        : IN STD_LOGIC;
        LinkData : IN ldata( 71 DOWNTO 0 ) := ( OTHERS => LWORD_NULL )
        );
END ENTITY MP7CaptureFileWriter;

--! @brief Architecture definition for entity MP7CaptureFileWriter
--! @details Detailed description
ARCHITECTURE behavioral OF MP7CaptureFileWriter IS

  TYPE tCurrentWriteState IS( Uninitialized , Payload );

-- ----------------------------------------------------------
--  FUNCTION hstring( value : STD_LOGIC_VECTOR ) RETURN STRING IS
--    CONSTANT ne           : INTEGER := ( value'LENGTH + 3 ) / 4;
--    VARIABLE result       : STRING( 1 TO ne );
--    CONSTANT LUT          : STRING( 1 TO 16 ) := "0123456789abcdef";
--  BEGIN
--    FOR i IN 0 TO ne-1 LOOP
--      result( ne-i ) := LUT( TO_INTEGER( UNSIGNED( value( 4 * i + 3 DOWNTO 4 * i ) ) ) + 1 );
--    END LOOP;
--    RETURN result;
--  END FUNCTION hstring;
-- ----------------------------------------------------------

-- ----------------------------------------------------------
  PROCEDURE WRITE( L : INOUT LINE ; VALUE : IN lword := LWORD_NULL ) IS
    VARIABLE TEMP    : CHARACTER;
  BEGIN
    WRITE( L , VALUE.valid );
    WRITE( L , STRING' ( "v" ) );
    HWRITE( L , VALUE.data );
    --WRITE( L , hstring( VALUE.data ) );
  END PROCEDURE WRITE;
-- ----------------------------------------------------------


 ----------------------------------------------------------
  FUNCTION PADDED_INT( VAL : INTEGER ; WIDTH : INTEGER ) RETURN STRING IS
    VARIABLE ret           : STRING( WIDTH DOWNTO 1 ) := ( OTHERS => '0' );
  BEGIN
    IF INTEGER'IMAGE( VAL ) 'LENGTH >= WIDTH THEN
      RETURN INTEGER'IMAGE( VAL );
    END IF;
 
    ret( INTEGER'IMAGE( VAL ) 'LENGTH DOWNTO 1 ) := INTEGER'IMAGE( VAL );
    RETURN ret;
  END FUNCTION PADDED_INT;
 ----------------------------------------------------------



-- ----------------------------------------------------------
  PROCEDURE MP7CaptureFileWriterProc( FileName          : IN STRING;
                                      FILE OutFile      : TEXT;
                                      CurrentWriteState : INOUT tCurrentWriteState;
                                      Counter           : INOUT INTEGER;
                                      LinkData          : IN ldata( 71 DOWNTO 0 );
                                      IsHeader          : STD_LOGIC_VECTOR( 71 DOWNTO 0 );
                                      DebugMessages     : IN BOOLEAN := FALSE
                                    ) IS
    VARIABLE L , DEBUG : LINE;
  BEGIN
    IF CurrentWriteState = Uninitialized THEN

      -------------------------------------------------------------------------
      -- debug
      -------------------------------------------------------------------------
      IF DebugMessages THEN
        WRITE( DEBUG , STRING' ( "UNINITIALIZED : " ) );
        WRITE( DEBUG , Counter );
        WRITELINE( OUTPUT , DEBUG );
      END IF;

      -------------------------------------------------------------------------
      -- Open File 
      -------------------------------------------------------------------------
      FILE_OPEN( OutFile , FileName , WRITE_MODE );
      

      -------------------------------------------------------------------------
      -- Write Human Readable Header
      -------------------------------------------------------------------------
      WRITE( L , STRING' ( "Board ALGO_TESTBENCH" ) );
      WRITELINE( OutFile , L );

      WRITE( L , STRING' ( " Quad/Chan :" ) );
      FOR q IN 0 TO 17 LOOP
        FOR c IN 0 TO 3 LOOP
          WRITE( L , STRING' ( "    q" ) );
          WRITE( L , PADDED_INT( q , 2 ) );
          WRITE( L , STRING' ( "c" ) );
          WRITE( L , c );
          WRITE( L , STRING' ( "  " ) );
        END LOOP;
      END LOOP;
      WRITELINE( OutFile , L );

      WRITE( L , STRING' ( "      Link :" ) );
      FOR q IN 0 TO 71 LOOP
        WRITE( L , STRING' ( "     " ) );
        WRITE( L , PADDED_INT( q , 2 ) );
        WRITE( L , STRING' ( "    " ) );
      END LOOP;
      WRITELINE( OutFile , L );

      CurrentWriteState := Payload;
      Counter           := -1;
      RETURN;
    END IF;

    ---------------------------------------------------------------------------
    -- Data from the 72 Links
    ---------------------------------------------------------------------------
    WRITE( L , STRING' ( "Frame " ) );
    WRITE( L , PADDED_INT( Counter , 4 ) );
    WRITE( L , STRING' ( " :" ) );

    FOR i IN 0 TO 71 LOOP
      --IF IsHeader( i ) = '0' THEN
        WRITE( L , STRING' ( " " ) );
        WRITE( L , LinkData( i ) );
      --ELSE
      --  WRITE( L , STRING' ( " 1v00001000" ) );
      --END IF;
    END LOOP;
    WRITELINE( OutFile , L );

  END PROCEDURE MP7CaptureFileWriterProc;
-- ----------------------------------------------------------

BEGIN

  
  PROCESS( clk )
    FILE OutFile               : TEXT;
    VARIABLE CurrentWriteState : tCurrentWriteState              := Uninitialized;
    VARIABLE Counter           : INTEGER                         := -1;
    VARIABLE TempData          : ldata( 71 DOWNTO 0 )            := ( OTHERS => LWORD_NULL );
    VARIABLE IsHeader          : STD_LOGIC_VECTOR( 71 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN

    IF RISING_EDGE( clk ) THEN
      FOR q IN 0 TO 71 LOOP
        IsHeader( q ) := LinkData( q ) .valid AND NOT TempData( q ) .valid;
      END LOOP;
      MP7CaptureFileWriterProc( FileName , OutFile , CurrentWriteState , Counter , TempData , IsHeader , DebugMessages );
      TempData := LinkData;
      Counter  := Counter + 1;
    END IF;
  END PROCESS;


END ARCHITECTURE behavioral;
