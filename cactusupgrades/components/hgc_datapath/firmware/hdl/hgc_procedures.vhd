-- implements HGC functions
--

library IEEE;

--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;

--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! using the STD.TEXTIO
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;

--! hgc data types
use work.hgc_data_types.all;


-------------------------------------------------------------------------------
-- pkg declaration
-------------------------------------------------------------------------------
package hgc_procedures is

  procedure hgcPrintWord (
    input : in hgcWord
  );

  procedure hgcPrintFlaggedWord (
    input : in hgcFlaggedWord
  );

end package hgc_procedures;
  
-------------------------------------------------------------------------------
-- pkg body
-------------------------------------------------------------------------------
package body hgc_procedures is

  procedure hgcPrintWord (
    input : in hgcWord
  ) is
    variable L               : line;
  begin
    WRITE(L, string' ("valid ")   );   
    WRITE(L, input.valid         );   
    WRITELINE(OUTPUT, L);
    WRITE(L, string' ("addr.wafer ")   );       
    WRITE(L, input.address.wafer );
    WRITELINE(OUTPUT, L);
    WRITE(L, string' ("addr.row ")   );       
    WRITE(L, input.address.row   );
    WRITELINE(OUTPUT, L);
    WRITE(L, string' ("addr.col ")   );       
    WRITE(L, input.address.col   );
    WRITELINE(OUTPUT, L);
    WRITE(L, string' ("energy ")   );       
    WRITE(L, input.energy        );
    WRITELINE(OUTPUT, L);
    WRITE(L, string' ("EOE ")   );       
    WRITE(L, input.EOE           );
    WRITELINE(OUTPUT, L);   
  end hgcPrintWord;

  
  procedure hgcPrintFlaggedWord (
    input : in hgcFlaggedWord
  ) is
    variable L               : line;
  begin

    hgcPrintWord( input.word );
  
    WRITE(L, string' ("seedFlag ")   );     
    WRITE(L, input.seedFlag          );
    WRITELINE(OUTPUT, L);   

  end hgcPrintFlaggedWord;
  
end package body hgc_procedures;
