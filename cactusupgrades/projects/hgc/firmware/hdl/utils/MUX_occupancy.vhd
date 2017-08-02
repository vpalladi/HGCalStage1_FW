--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using STD_LOGIC_UNSIGNED
--use IEEE.std_logic_unsigned.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! Using the Calo-L2 "mp7_data" data-types
use work.mp7_data_types.all;

--! hgc data types
use work.hgc_data_types.all;

--! I/O
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;

--! hgc constants
use work.hgc_constants.all;

entity MUX_occupancy is
  
  generic (
    nInputs : natural);

  port (
    inputs   : in is array(nInputs-1 downto 0 ) of std_logic_matrix(0 to nRows-1, 0 to nColumns-1);
    selector : in  natural;
    output   : out std_logic_matrix(0 to nRows-1, 0 to nColumns-1)
    );

end entity MUX_occupancy;


architecture arch_MUX of MUX_occupancy is
  
begin  -- architecture arch_MUX

  assert selector >= nInputs
    report "MUX: selector out of range."
    severity error;
  
  output <= inputs(selector) ;

end architecture arch_MUX;
