--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;

-- -------------------------------------------------------------------------
-- This is how it is packed in the C + +
-- -------------------------------------------------------------------------
-- lTemp |= ( ( unsigned ) lTriggerTower.mEgammaCandidate & 0x1 ) <<15;
-- lTemp |= ( ( unsigned ) lTriggerTower.mHcalFeature & 0x1 ) <<14;
-- lTemp |= ( lEoverHflag & 0x1 ) <<13;
-- lTemp |= ( lDenominatorZeroFlag & 0x1 ) <<12;
-- lTemp |= ( lRatio & 0x7 ) <<9;
-- lTemp |= ( lEnergy & 0x01FF );
-- -------------------------------------------------------------------------

--! @brief An entity providing a TowerFormer
--! @details Detailed description
ENTITY TowerFormer IS
  PORT(
    clk       : IN STD_LOGIC                       := '0' ; --! The algorithm clock
    DataValid : IN STD_LOGIC                       := '0';
    linksIn   : IN STD_LOGIC_VECTOR( 15 DOWNTO 0 ) := ( OTHERS => '0' );
    towerOut  : OUT tTower                         := cEmptyTower
  );
END TowerFormer;

--! @brief Architecture definition for entity TowerFormer
--! @details Detailed description
ARCHITECTURE behavioral OF TowerFormer IS

  SIGNAL DenominatorCoefficient             : STD_LOGIC_VECTOR( 7 DOWNTO 0 )  := ( OTHERS => '0' );
  SIGNAL NumeratorCoefficient               : STD_LOGIC_VECTOR( 7 DOWNTO 0 )  := ( OTHERS => '0' );

  SIGNAL DenominatorOut                     : STD_LOGIC_VECTOR( 16 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL NumeratorOut                       : STD_LOGIC_VECTOR( 16 DOWNTO 0 ) := ( OTHERS => '0' );

  SIGNAL EoverHFlagDelay , EoverHFlagDelay2 : STD_LOGIC                       := '0';
  SIGNAL DelayedDataValid                   : BOOLEAN                         := FALSE;

  SIGNAL towerInt                           : tTower                          := cEmptyTower;
  SIGNAL eta                                : INTEGER RANGE 0 TO 15           := 0 ; -- Use zero-indexed coordinates to save a bit on the eta counter
BEGIN



  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN

-- ----------------------------------------------------------------------------

      IF( DataValid = '0' ) THEN
        towerInt               <= cEmptyTower;
        EoverHFlagDelay        <= '0';
        DenominatorCoefficient <= ( OTHERS => '0' );
        NumeratorCoefficient   <= ( OTHERS => '0' );
        eta                    <= 0 ; -- Use zero-indexed coordinates to save a bit on the eta counter
      ELSE

        IF( eta < 15 ) THEN
          eta <= eta + 1;
        END IF;

-- towerInt.EgammaCandidate <= ( linksIn( 15 ) = '1' );
        towerInt.HcalFeature <= ( linksIn( 14 ) = '1' );
        towerInt.HasEM       <= ( linksIn( 12 ) = '0' OR linksIn( 13 ) = '1' );
-- towerInt.lEoverHflag <= linksIn( 13 );
-- towerInt.lDenominatorZeroFlag <= linksIn( 12 );
-- towerInt.lRatio <= linksIn( 11 DOWNTO 9 );
        towerInt.Energy      <= UNSIGNED( linksIn( 8 DOWNTO 0 ) );

        towerInt.DataValid   <= TRUE;
        EoverHFlagDelay      <= linksIn( 13 );

-- ****************************
-- *** Thomas' Instructions ***
-- ****************************
--IF( linksIn( 13 ) = ‘0’ ) THEN
-- ehIDFlag <= FALSE
--ELSE
-- IF( linksIn( 12 ) = ‘1’ ) THEN
-- ehIDFlag <= TRUE
-- ELSE
-- IF( eta < 16 ) -- CMS COORDINATES
-- ehIDFlag <= ( linksIn( 11 DOWNTO 9 ) > 100 ) -- check if > 4
-- ELSE
-- ehIDFlag <= ( linksIn( 11 DOWNTO 9 ) > 011 ) -- check if > 3

-- Replace EcalFG with EcalFG OR not( ehIDFlag )

-- ***********************
-- *** Andy New Scheme ***
-- ***********************
-- Replace EcalFG with EgammaCandidate = not( EcalFG ) AND ehIDFlag
-- Calibration requires EgammaCandidate = TRUE

-- ****************************

        IF( linksIn( 13 ) = '0' ) THEN
-- ehIDFlag <= FALSE;
-- towerInt.EgammaCandidate <= not( linksIn( 15 ) = '1' ) and FALSE;
-- towerInt.EgammaCandidate <= ( linksIn( 15 ) = '0' ) and FALSE;
          towerInt.EgammaCandidate <= FALSE;
        ELSIF( linksIn( 12 ) = '1' ) THEN
-- ehIDFlag <= TRUE
-- towerInt.EgammaCandidate <= not( linksIn( 15 ) = '1' ) and TRUE;
-- towerInt.EgammaCandidate <= ( linksIn( 15 ) = '0' ) and TRUE;
          towerInt.EgammaCandidate <= ( linksIn( 15 ) = '0' );
-- ELSIF( eta < 16 ) THEN -- CMS COORDINATES
        ELSIF( eta < 15 ) THEN -- ZERO-INDEXED COORDINATES
-- ehIDFlag <= ( linksIn( 11 DOWNTO 9 ) > 100 ) -- check if > 4
-- towerInt.EgammaCandidate <= not( linksIn( 15 ) = '1' ) and( linksIn( 11 DOWNTO 9 ) > 100 );
-- towerInt.EgammaCandidate <= ( linksIn( 15 ) = '0' ) and( linksIn( 11 DOWNTO 9 ) > 100 );
          towerInt.EgammaCandidate <= ( linksIn( 15 ) = '0' ) AND( UNSIGNED( linksIn( 11 DOWNTO 9 ) ) > "100" );
        ELSE
-- ehIDFlag <= ( linksIn( 11 DOWNTO 9 ) > 101 ) -- check if > 5
-- towerInt.EgammaCandidate <= not( linksIn( 15 ) = '1' ) and( linksIn( 11 DOWNTO 9 ) > 101 );
-- towerInt.EgammaCandidate <= ( linksIn( 15 ) = '0' ) and( linksIn( 11 DOWNTO 9 ) > 101 );
          towerInt.EgammaCandidate <= ( linksIn( 15 ) = '0' ) AND( UNSIGNED( linksIn( 11 DOWNTO 9 ) ) > "011" );
        END IF;


        IF( linksIn( 12 ) = '0' ) THEN -- DenominatorZero
          CASE linksIn( 11 DOWNTO 9 ) IS
            WHEN "000" =>
              DenominatorCoefficient <= STD_LOGIC_VECTOR( TO_UNSIGNED( 64 , 8 ) );
              NumeratorCoefficient   <= STD_LOGIC_VECTOR( TO_UNSIGNED( 64 , 8 ) );
            WHEN "001" =>
              DenominatorCoefficient <= STD_LOGIC_VECTOR( TO_UNSIGNED( 43 , 8 ) );
              NumeratorCoefficient   <= STD_LOGIC_VECTOR( TO_UNSIGNED( 85 , 8 ) );
            WHEN "010" =>
              DenominatorCoefficient <= STD_LOGIC_VECTOR( TO_UNSIGNED( 26 , 8 ) );
              NumeratorCoefficient   <= STD_LOGIC_VECTOR( TO_UNSIGNED( 102 , 8 ) );
            WHEN "011" =>
              DenominatorCoefficient <= STD_LOGIC_VECTOR( TO_UNSIGNED( 14 , 8 ) );
              NumeratorCoefficient   <= STD_LOGIC_VECTOR( TO_UNSIGNED( 114 , 8 ) );
            WHEN "100" =>
              DenominatorCoefficient <= STD_LOGIC_VECTOR( TO_UNSIGNED( 8 , 8 ) );
              NumeratorCoefficient   <= STD_LOGIC_VECTOR( TO_UNSIGNED( 120 , 8 ) );
            WHEN "101" =>
              DenominatorCoefficient <= STD_LOGIC_VECTOR( TO_UNSIGNED( 4 , 8 ) );
              NumeratorCoefficient   <= STD_LOGIC_VECTOR( TO_UNSIGNED( 124 , 8 ) );
            WHEN "110" =>
              DenominatorCoefficient <= STD_LOGIC_VECTOR( TO_UNSIGNED( 2 , 8 ) );
              NumeratorCoefficient   <= STD_LOGIC_VECTOR( TO_UNSIGNED( 126 , 8 ) );
            WHEN "111" =>
              DenominatorCoefficient <= STD_LOGIC_VECTOR( TO_UNSIGNED( 1 , 8 ) );
              NumeratorCoefficient   <= STD_LOGIC_VECTOR( TO_UNSIGNED( 127 , 8 ) );
            WHEN OTHERS =>
              DenominatorCoefficient <= ( OTHERS => '0' );
              NumeratorCoefficient   <= ( OTHERS => '0' );
          END CASE;
        ELSE
          DenominatorCoefficient <= STD_LOGIC_VECTOR( TO_UNSIGNED( 0 , 8 ) );
          NumeratorCoefficient   <= STD_LOGIC_VECTOR( TO_UNSIGNED( 128 , 8 ) );
        END IF;
      END IF;

-- ----------------------------------------------------------------------------

      towerOut.EgammaCandidate <= towerInt.EgammaCandidate;
      towerOut.HasEM           <= towerInt.HasEM;
      towerOut.HcalFeature     <= towerInt.HcalFeature;
      towerOut.Energy          <= towerInt.Energy;
      towerOut.DataValid       <= towerInt.DataValid;

      DelayedDataValid         <= towerInt.DataValid;
      EoverHFlagDelay2         <= EoverHFlagDelay;

-- ----------------------------------------------------------------------------

    END IF;
  END PROCESS;

-- a = 9bit unsigned
-- b = 7bit unsigned
-- p = 16bit unsigned
  DenominatorMultiplier : ENTITY work.multiplier9Ux8U
  PORT MAP(
    clk => clk ,
    a   => STD_LOGIC_VECTOR( towerInt.Energy ) ,
    b   => DenominatorCoefficient ,
    p   => DenominatorOut
  );

  NumeratorMultiplier : ENTITY work.multiplier9Ux8U
  PORT MAP(
    clk => clk ,
    a   => STD_LOGIC_VECTOR( towerInt.Energy ) ,
    b   => NumeratorCoefficient ,
    p   => NumeratorOut
  );

  towerOut.Ecal <= ( OTHERS => '0' ) WHEN NOT DelayedDataValid ELSE UNSIGNED( NumeratorOut( 15 DOWNTO 7 ) ) WHEN( EoverHFlagDelay2='1' ) ELSE UNSIGNED( DenominatorOut( 15 DOWNTO 7 ) );
  towerOut.Hcal <= ( OTHERS => '0' ) WHEN NOT DelayedDataValid ELSE UNSIGNED( DenominatorOut( 15 DOWNTO 7 ) ) WHEN( EoverHFlagDelay2='1' ) ELSE UNSIGNED( NumeratorOut( 15 DOWNTO 7 ) );

END ARCHITECTURE behavioral;
