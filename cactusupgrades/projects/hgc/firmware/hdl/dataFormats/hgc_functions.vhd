-- Defines HGC functions
--

library IEEE;

--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;

--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! hgc data types
use work.hgc_data_types.all;

package hgc_functions is

  function get_row (
    row : natural;
    nCols : natural;
    hgcClusterId_matrix : hgcClusterId_matrix
    )  
  return hgcClusterIds; 

end package hgc_functions;


package body hgc_functions is

  function get_row (
    row : natural;
    nCols : natural;
    hgcClusterId_matrix : hgcClusterId_matrix
    )  
  return hgcClusterIds is
    variable rowOut : hgcClusterIds( nCols-1 downto 0 );
  begin
    
      for icol in nCols-1 downto 0 loop
        rowOut( icol ) := hgcClusterId_matrix( row, icol );
      end loop;  -- icol

      return rowOut;
      
  end get_row;

end package body hgc_functions;
