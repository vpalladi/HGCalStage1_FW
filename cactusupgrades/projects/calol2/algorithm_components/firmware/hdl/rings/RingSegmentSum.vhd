--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! @brief An entity providing a RingSegmentSum
--! @details Detailed description
ENTITY RingSegmentSum IS
  GENERIC(
    Size : INTEGER := 32
  );
  PORT(
    clk            : IN STD_LOGIC     := '0' ; --! The algorithm clock
    ringSegmentIn1 : IN tRingSegment  := cEmptyRingSegment;
    ringSegmentIn2 : IN tRingSegment  := cEmptyRingSegment;
    ringSegmentOut : OUT tRingSegment := cEmptyRingSegment
  );
END RingSegmentSum;

--! @brief Architecture definition for entity RingSegmentSum
--! @details Detailed description
ARCHITECTURE behavioral OF RingSegmentSum IS
-- SIGNAL E1 , E2 : STD_LOGIC_VECTOR( 19 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL X1 , X2 : STD_LOGIC_VECTOR( 19 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL Y1 , Y2 : STD_LOGIC_VECTOR( 19 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL T1 , T2 : STD_LOGIC_VECTOR( 19 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL ESUM : STD_LOGIC_VECTOR( 21 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL XSUM : STD_LOGIC_VECTOR( 21 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL YSUM : STD_LOGIC_VECTOR( 21 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL TSUM : STD_LOGIC_VECTOR( 21 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL DATA_VALID : BOOLEAN := FALSE;
BEGIN
  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF( NOT ringSegmentIn1.DataValid OR NOT ringSegmentIn2.DataValid ) THEN
        ringSegmentOut <= cEmptyRingSegment;
      ELSE
        ringSegmentOut.xComponent <= TO_SIGNED( TO_INTEGER( ringSegmentIn1.xComponent( Size-1 DOWNTO 0 ) + ringSegmentIn2.xComponent( Size-1 DOWNTO 0 ) ) , 32 );
        ringSegmentOut.yComponent <= TO_SIGNED( TO_INTEGER( ringSegmentIn1.yComponent( Size-1 DOWNTO 0 ) + ringSegmentIn2.yComponent( Size-1 DOWNTO 0 ) ) , 32 );
        ringSegmentOut.Energy     <= ringSegmentIn1.Energy + ringSegmentIn2.Energy;
        ringSegmentOut.Ecal       <= ringSegmentIn1.Ecal + ringSegmentIn2.Ecal;
        ringSegmentOut.towerCount <= ringSegmentIn1.towerCount + ringSegmentIn2.towerCount;
        ringSegmentOut.DataValid  <= TRUE;
      END IF;
    END IF;
  END PROCESS;


-- E1 <= STD_LOGIC_VECTOR( ringSegmentIn1.Energy );
-- E2 <= STD_LOGIC_VECTOR( ringSegmentIn2.Energy );
--
-- X1 <= STD_LOGIC_VECTOR( ringSegmentIn1.xComponent );
-- X2 <= STD_LOGIC_VECTOR( ringSegmentIn2.xComponent );
--
-- Y1 <= STD_LOGIC_VECTOR( ringSegmentIn1.yComponent );
-- Y2 <= STD_LOGIC_VECTOR( ringSegmentIn2.yComponent );
--
-- T1( 11 DOWNTO 0 ) <= STD_LOGIC_VECTOR( ringSegmentIn1.towerCount );
-- T2( 11 DOWNTO 0 ) <= STD_LOGIC_VECTOR( ringSegmentIn2.towerCount );
--
--
-- TwoInputAddEInstance : ENTITY work.TwoInputAdd
-- PORT MAP(
-- clk => clk ,
-- a => E1 ,
-- d => E2 ,
-- p => ESUM
-- );
--
-- TwoInputAddXInstance : ENTITY work.TwoInputAdd
-- PORT MAP(
-- clk => clk ,
-- a => X1 ,
-- d => X2 ,
-- p => XSUM
-- );
--
-- TwoInputAddYInstance : ENTITY work.TwoInputAdd
-- PORT MAP(
-- clk => clk ,
-- a => Y1 ,
-- d => Y2 ,
-- p => YSUM
-- );
--
-- TwoInputAddTInstance : ENTITY work.TwoInputAdd
-- PORT MAP(
-- clk => clk ,
-- a => T1 ,
-- d => T2 ,
-- p => TSUM
-- );
--
-- DATA_VALID <= ( ringSegmentIn1.DataValid AND ringSegmentIn2.DataValid ) WHEN RISING_EDGE( clk );
-- ringSegmentOut.DataValid <= DATA_VALID;
-- ringSegmentOut.Energy <= UNSIGNED( ESUM( 19 DOWNTO 0 ) ) WHEN DATA_VALID ELSE( OTHERS => '0' );
-- ringSegmentOut.xComponent <= SIGNED( XSUM( 19 DOWNTO 0 ) ) WHEN DATA_VALID ELSE( OTHERS => '0' );
-- ringSegmentOut.yComponent <= SIGNED( YSUM( 19 DOWNTO 0 ) ) WHEN DATA_VALID ELSE( OTHERS => '0' );
-- ringSegmentOut.towerCount <= UNSIGNED( TSUM( 11 DOWNTO 0 ) ) WHEN DATA_VALID ELSE( OTHERS => '0' );

END ARCHITECTURE behavioral;

-- -------------------------------------------------------------------------------------------------------------------------------

--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! @brief An entity providing a RingSegment3Sum
--! @details Detailed description
ENTITY RingSegment3Sum IS
  GENERIC(
    Size : INTEGER := 32
  );
  PORT(
    clk            : IN STD_LOGIC     := '0' ; --! The algorithm clock
    ringSegmentIn1 : IN tRingSegment  := cEmptyRingSegment;
    ringSegmentIn2 : IN tRingSegment  := cEmptyRingSegment;
    ringSegmentIn3 : IN tRingSegment  := cEmptyRingSegment;
    ringSegmentOut : OUT tRingSegment := cEmptyRingSegment
  );
END RingSegment3Sum;

--! @brief Architecture definition for entity RingSegment3Sum
--! @details Detailed description
ARCHITECTURE behavioral OF RingSegment3Sum IS
-- SIGNAL E1 , E2 , E3 : STD_LOGIC_VECTOR( 19 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL X1 , X2 , X3 : STD_LOGIC_VECTOR( 19 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL Y1 , Y2 , Y3 : STD_LOGIC_VECTOR( 19 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL T1 , T2 , T3 : STD_LOGIC_VECTOR( 19 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL ESUM : STD_LOGIC_VECTOR( 21 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL XSUM : STD_LOGIC_VECTOR( 21 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL YSUM : STD_LOGIC_VECTOR( 21 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL TSUM : STD_LOGIC_VECTOR( 21 DOWNTO 0 ) := ( OTHERS => '0' );
-- SIGNAL DATA_VALID : BOOLEAN := FALSE;
BEGIN
  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF( NOT ringSegmentIn1.DataValid OR NOT ringSegmentIn2.DataValid OR NOT ringSegmentIn3.DataValid ) THEN
        ringSegmentOut <= cEmptyRingSegment;
      ELSE
        ringSegmentOut.xComponent <= TO_SIGNED( TO_INTEGER( ringSegmentIn1.xComponent( Size-1 DOWNTO 0 ) + ringSegmentIn2.xComponent( Size-1 DOWNTO 0 ) + ringSegmentIn3.xComponent( Size-1 DOWNTO 0 ) ) , 32 );
        ringSegmentOut.yComponent <= TO_SIGNED( TO_INTEGER( ringSegmentIn1.yComponent( Size-1 DOWNTO 0 ) + ringSegmentIn2.yComponent( Size-1 DOWNTO 0 ) + ringSegmentIn3.yComponent( Size-1 DOWNTO 0 ) ) , 32 );
        ringSegmentOut.Energy     <= ringSegmentIn1.Energy + ringSegmentIn2.Energy + ringSegmentIn3.Energy;
        ringSegmentOut.Ecal       <= ringSegmentIn1.Ecal + ringSegmentIn2.Ecal + ringSegmentIn3.Ecal;
        ringSegmentOut.towerCount <= ringSegmentIn1.towerCount + ringSegmentIn2.towerCount + ringSegmentIn3.towerCount;
        ringSegmentOut.DataValid  <= TRUE;
      END IF;
    END IF;
  END PROCESS;

-- E1 <= STD_LOGIC_VECTOR( ringSegmentIn1.Energy );
-- E2 <= STD_LOGIC_VECTOR( ringSegmentIn2.Energy );
-- E3 <= STD_LOGIC_VECTOR( ringSegmentIn3.Energy );
--
-- X1 <= STD_LOGIC_VECTOR( ringSegmentIn1.xComponent );
-- X2 <= STD_LOGIC_VECTOR( ringSegmentIn2.xComponent );
-- X3 <= STD_LOGIC_VECTOR( ringSegmentIn3.xComponent );
--
-- Y1 <= STD_LOGIC_VECTOR( ringSegmentIn1.yComponent );
-- Y2 <= STD_LOGIC_VECTOR( ringSegmentIn2.yComponent );
-- Y3 <= STD_LOGIC_VECTOR( ringSegmentIn3.yComponent );
--
-- T1( 11 DOWNTO 0 ) <= STD_LOGIC_VECTOR( ringSegmentIn1.towerCount );
-- T2( 11 DOWNTO 0 ) <= STD_LOGIC_VECTOR( ringSegmentIn2.towerCount );
-- T3( 11 DOWNTO 0 ) <= STD_LOGIC_VECTOR( ringSegmentIn3.towerCount );
--
-- ThreeInputAddEInstance : ENTITY work.ThreeInputAdd
-- PORT MAP(
-- clk => clk ,
-- a => E1 ,
-- c => E2 ,
-- d => E3 ,
-- p => ESUM
-- );
--
-- ThreeInputAddXInstance : ENTITY work.ThreeInputAdd
-- PORT MAP(
-- clk => clk ,
-- a => X1 ,
-- c => X2 ,
-- d => X3 ,
-- p => XSUM
-- );
--
-- ThreeInputAddYInstance : ENTITY work.ThreeInputAdd
-- PORT MAP(
-- clk => clk ,
-- a => Y1 ,
-- c => Y2 ,
-- d => Y3 ,
-- p => YSUM
-- );
--
-- ThreeInputAddTInstance : ENTITY work.ThreeInputAdd
-- PORT MAP(
-- clk => clk ,
-- a => T1 ,
-- c => T2 ,
-- d => T3 ,
-- p => TSUM
-- );
--
-- DATA_VALID <= ( ringSegmentIn1.DataValid AND ringSegmentIn2.DataValid AND ringSegmentIn3.DataValid ) WHEN RISING_EDGE( clk );
-- ringSegmentOut.DataValid <= DATA_VALID;
-- ringSegmentOut.Energy <= UNSIGNED( ESUM( 19 DOWNTO 0 ) ) WHEN DATA_VALID ELSE( OTHERS => '0' );
-- ringSegmentOut.xComponent <= SIGNED( XSUM( 19 DOWNTO 0 ) ) WHEN DATA_VALID ELSE( OTHERS => '0' );
-- ringSegmentOut.yComponent <= SIGNED( YSUM( 19 DOWNTO 0 ) ) WHEN DATA_VALID ELSE( OTHERS => '0' );
-- ringSegmentOut.towerCount <= UNSIGNED( TSUM( 11 DOWNTO 0 ) ) WHEN DATA_VALID ELSE( OTHERS => '0' );

END ARCHITECTURE behavioral;
