--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "preprocessor" data-types
USE work.preprocessor_types.ALL;


PACKAGE preprocessor_functions IS
  FUNCTION Hamming( Data        : STD_LOGIC_VECTOR ) RETURN STD_LOGIC_VECTOR;
  FUNCTION HammingCheck( Data   : STD_LOGIC_VECTOR ; Checksum : STD_LOGIC_VECTOR ) RETURN STD_LOGIC;
  FUNCTION ToEcalTower( Region  : tOSLBregion ; Index : INTEGER ) RETURN tEcalTower;

  FUNCTION CRC8CCITT( Data      : STD_LOGIC_VECTOR ) RETURN STD_LOGIC_VECTOR;
  FUNCTION CRC8CCITTcheck( Data : STD_LOGIC_VECTOR ; CRC : STD_LOGIC_VECTOR ) RETURN BOOLEAN;


END PACKAGE preprocessor_functions;


PACKAGE BODY preprocessor_functions IS

  FUNCTION Hamming( Data : STD_LOGIC_VECTOR ) RETURN STD_LOGIC_VECTOR IS
    VARIABLE lRET        : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
  BEGIN
    lRet( 0 ) := Data( 0 ) XOR Data( 1 ) XOR Data( 3 ) XOR Data( 4 ) XOR Data( 6 ) XOR Data( 8 ) XOR Data( 10 ) XOR Data( 11 ) XOR Data( 13 ) XOR Data( 15 ) XOR Data( 17 );
    lRet( 1 ) := Data( 0 ) XOR Data( 2 ) XOR Data( 3 ) XOR Data( 5 ) XOR Data( 6 ) XOR Data( 9 ) XOR Data( 10 ) XOR Data( 12 ) XOR Data( 13 ) XOR Data( 16 ) XOR Data( 17 );
    lRet( 2 ) := Data( 1 ) XOR Data( 2 ) XOR Data( 3 ) XOR Data( 7 ) XOR Data( 8 ) XOR Data( 9 ) XOR Data( 10 ) XOR Data( 14 ) XOR Data( 15 ) XOR Data( 16 ) XOR Data( 17 );
    lRet( 3 ) := Data( 4 ) XOR Data( 5 ) XOR Data( 6 ) XOR Data( 7 ) XOR Data( 8 ) XOR Data( 9 ) XOR Data( 10 ) XOR Data( 18 );
    lRet( 4 ) := Data( 11 ) XOR Data( 12 ) XOR Data( 13 ) XOR Data( 14 ) XOR Data( 15 ) XOR Data( 16 ) XOR Data( 17 ) XOR Data( 18 );
    RETURN lRet;
  END Hamming;


  FUNCTION HammingCheck( Data : STD_LOGIC_VECTOR ; Checksum : STD_LOGIC_VECTOR ) RETURN STD_LOGIC IS
    VARIABLE lHamming         : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
    VARIABLE lTest            : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
  BEGIN
    lHamming   := Hamming( Data );
    lTest( 0 ) := NOT( Checksum( 0 ) ) XOR lHamming( 0 );
    lTest( 1 ) := NOT( Checksum( 1 ) ) XOR lHamming( 1 );
    lTest( 2 ) := NOT( Checksum( 2 ) ) XOR lHamming( 2 );
    lTest( 3 ) := NOT( Checksum( 3 ) ) XOR lHamming( 3 );
    lTest( 4 ) := NOT( Checksum( 4 ) ) XOR lHamming( 4 );

-- if lTest = "00000" then
-- if lTest = "11111" then
    IF( lHamming = Checksum ) THEN
-- i.e. Check = TRUE
      RETURN '1';
    ELSE
-- i.e. Check = False
      RETURN '0';
    END IF;
  END HammingCheck;


  FUNCTION ToEcalTower( Region : tOSLBregion ; Index : INTEGER ) RETURN tEcalTower IS
    VARIABLE lRet              : tEcalTower;
  BEGIN
    lRet.ET           := Region.Tower( Index + 1 ) .ET;
    lRet.Isolation    := Region.Tower( Index + 1 ) .Isolation;
    lRet.BC0          := ( Region.BC0 /= "0000" );
    lRet.BC0_Error    := NOT( Region.BC0 = "0000" OR Region.BC0 = "1111" );
    lRet.HammingError := ( ( Region.HammingError( 4 ) OR Region.HammingError( 3 ) OR Region.HammingError( 2 ) OR Region.HammingError( 1 ) ) = '1' );
    lRet.DataValid    := TRUE;
    RETURN lRet;
  END ToEcalTower;


  FUNCTION CRC8CCITT( Data : STD_LOGIC_VECTOR ) RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN x"00";
  END CRC8CCITT;

  FUNCTION CRC8CCITTcheck( Data : STD_LOGIC_VECTOR ; CRC : STD_LOGIC_VECTOR ) RETURN BOOLEAN IS
  BEGIN
    RETURN FALSE;
  END CRC8CCITTcheck;


END preprocessor_functions;
