
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Writing to and from files
USE STD.TEXTIO.ALL;

PACKAGE constants IS

  CONSTANT for_synthesis             : BOOLEAN := TRUE
-- pragma synthesis_off
  AND FALSE
-- pragma synthesis_on
;


-- To write to a Log File
--  FILE LoggingDestination                   : TEXT OPEN write_mode IS "TestBench.OUT";
-- To write to the Console
-- alias LoggingDestination is output;

END constants;
