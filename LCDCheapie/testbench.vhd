-- Code your testbench here
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- entity declaration for your testbench.Dont declare any ports here
ENTITY LPCMod_tb IS
END LPCMod_tb;

ARCHITECTURE behavior OF LPCMod_tb IS
   -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT lcdcheapie_entity is  --'test' is the name of the module needed to be tested.
--just copy and paste the input and output ports of your module as such.
    port 
    (
        pin_xbox_n_lrst : in std_logic;                         --Xbox-side Reset signal
        pin_xbox_lclk : in std_logic ;                          --Xbox-side CLK
        pinout4_xbox_lad : inout std_logic_vector(3 downto 0);  --Xbox-side LPC IO
        pout_lcd_rs : out std_logic;
        pout_lcd_e : out std_logic;
        --R/W is set to W on board
        p4out_lcd_d4_d7 : out std_logic_vector(3 downto 0);           
        pout_backlight: out std_logic                           --LCD backlight control.
    );
    END COMPONENT lcdcheapie_entity;

    signal pin_xbox_n_lrst : std_logic := '0';
    signal pin_xbox_lclk : std_logic := '0';
    signal pinout4_xbox_lad : std_logic_vector(3 downto 0) := "1111";
    signal pout_lcd_rs : std_logic := '0';
    signal pout_lcd_e : std_logic := '0';
    signal p4out_lcd_d4_d7 : std_logic_vector(3 downto 0) := "0000";      --Contains R/S, E and D4-D7. R/W is set on W.
    signal pout_backlight: std_logic:= '0'; --LCD backlight control

constant clk_period : time := 30 NS;
    
BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: lcdcheapie_entity PORT MAP (
        pin_xbox_n_lrst,
        pin_xbox_lclk,
        pinout4_xbox_lad,
        pout_lcd_rs,
        pout_lcd_e,
        p4out_lcd_d4_d7,
        pout_backlight
     ); 
        
   -- Clock process definitions( clock with 50% duty cycle is generated here.
   clk_process :process
   begin
        pin_xbox_lclk <= '0';
        wait for clk_period/2;
        pin_xbox_lclk <= '1';
        wait for clk_period/2;
   end process;       
   
   
stim_proc: process
    begin    
        pin_xbox_n_lrst <= '0';
        wait for clk_period;        --30 ns delay
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
        wait for 22 NS;         --Arbitrary delay induced on further data stimulation. In reality, the Xbox sets it's data for the next rising edge around 9 NS after the preceding rising edge of said data.
        pin_xbox_n_lrst <= '1';
        wait for clk_period;

        -- Set backlight to some random value
        wait for clk_period;
        wait for clk_period;
        pinout4_xbox_lad <= "0000"; --Start!
        wait for clk_period;
        pinout4_xbox_lad <= "0010"; --CYC
        wait for clk_period;
        pinout4_xbox_lad <= x"F";   --addr4
        wait for clk_period;
        pinout4_xbox_lad <= x"7";   --addr5
        wait for clk_period;
        pinout4_xbox_lad <= x"0";   --addr6
        wait for clk_period;    
        pinout4_xbox_lad <= x"1";   --addr7     BL
        wait for clk_period;
        pinout4_xbox_lad <= x"F";   --DATA1
        wait for clk_period;
        pinout4_xbox_lad <= x"F";   --DATA2
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARA1
        wait for clk_period;
        pinout4_xbox_lad <= "ZZZZ"; --TARA2
        wait for clk_period;
        --SYNC
        wait for clk_period; 
        --TARB1
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARB2
        wait for clk_period;
        wait for clk_period;


        -- Set LCD value
        wait for clk_period;
        wait for clk_period;
        pinout4_xbox_lad <= "0000"; --Start!
        wait for clk_period;
        pinout4_xbox_lad <= "0010"; --CYC
        wait for clk_period;
        pinout4_xbox_lad <= x"F";   --addr4
        wait for clk_period;
        pinout4_xbox_lad <= x"7";   --addr5
        wait for clk_period;
        pinout4_xbox_lad <= x"0";   --addr6
        wait for clk_period;    
        pinout4_xbox_lad <= x"0";   --addr7     lcd data
        wait for clk_period;
        pinout4_xbox_lad <= x"A";   --DATA1
        wait for clk_period;
        pinout4_xbox_lad <= x"A";   --DATA2
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARA1
        wait for clk_period;
        pinout4_xbox_lad <= "ZZZZ"; --TARA2
        wait for clk_period;
        --SYNC
        wait for clk_period; 
        --TARB1
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARB2
        wait for clk_period;
        wait for clk_period;
        
        
        -- Set LCD value
        wait for clk_period;
        wait for clk_period;
        pinout4_xbox_lad <= "0000"; --Start!
        wait for clk_period;
        pinout4_xbox_lad <= "0010"; --CYC
        wait for clk_period;
        pinout4_xbox_lad <= x"F";   --addr4
        wait for clk_period;
        pinout4_xbox_lad <= x"7";   --addr5
        wait for clk_period;
        pinout4_xbox_lad <= x"0";   --addr6
        wait for clk_period;    
        pinout4_xbox_lad <= x"0";   --addr7     lcd data
        wait for clk_period;
        pinout4_xbox_lad <= x"5";   --DATA1
        wait for clk_period;
        pinout4_xbox_lad <= x"5";   --DATA2
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARA1
        wait for clk_period;
        pinout4_xbox_lad <= "ZZZZ"; --TARA2
        wait for clk_period;
        --SYNC
        wait for clk_period; 
        --TARB1
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARB2
        wait for clk_period;
        wait for clk_period;

        -- non conflicting mem write
        wait for clk_period;
        pinout4_xbox_lad <= "0000";    --Start!
        wait for clk_period;
        pinout4_xbox_lad <= "0110"; --CYC: mem write
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --addr0
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --addr1
        wait for clk_period;
        pinout4_xbox_lad <= "0000"; --addr2
        wait for clk_period;
        pinout4_xbox_lad <= "0000"; --addr3
        wait for clk_period;
        pinout4_xbox_lad <= x"5";   --addr4
        wait for clk_period;
        pinout4_xbox_lad <= x"5";   --addr5
        wait for clk_period;
        pinout4_xbox_lad <= x"5";   --addr6
        wait for clk_period;
        pinout4_xbox_lad <= x"5";   --addr7
        wait for clk_period;
        pinout4_xbox_lad <= x"A";   --DATA1
        wait for clk_period;
        pinout4_xbox_lad <= x"A";   --DATA2
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARA1
        wait for clk_period;
        pinout4_xbox_lad <= "ZZZZ"; --TARA2
        wait for clk_period;
        --SYNC
        wait for clk_period; 
        --TARB1
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARB2
        wait for clk_period;
        wait for clk_period;


        -- conflicting mem write
        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
        pinout4_xbox_lad <= "0000"; --Start!
        wait for clk_period;
        pinout4_xbox_lad <= "0110"; --CYC
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --addr0
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --addr1
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --addr2
        wait for clk_period;
        pinout4_xbox_lad <= "0010"; --addr3
        wait for clk_period;
        pinout4_xbox_lad <= x"F";   --addr4
        wait for clk_period;
        pinout4_xbox_lad <= x"7";   --addr5
        wait for clk_period;
        pinout4_xbox_lad <= x"0";   --addr6
        wait for clk_period;
        pinout4_xbox_lad <= x"1";   --addr7
        wait for clk_period;
        pinout4_xbox_lad <= x"5";   --DATA1
        wait for clk_period;
        pinout4_xbox_lad <= x"5";   --DATA2
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARA1
        wait for clk_period;
        pinout4_xbox_lad <= "ZZZZ"; --TARA2
        wait for clk_period;
        --SYNC
        wait for clk_period; 
        --TARB1
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARB2
        wait for clk_period;
        wait for clk_period;

        -- conflicting backlight not working
        wait for clk_period;
        wait for clk_period;
        pinout4_xbox_lad <= "0000"; --Start!
        wait for clk_period;
        pinout4_xbox_lad <= "0010"; --CYC
        wait for clk_period;
        pinout4_xbox_lad <= x"F";   --addr4
        wait for clk_period;
        pinout4_xbox_lad <= x"7";   --addr5
        wait for clk_period;
        pinout4_xbox_lad <= x"1";   --addr6
        wait for clk_period;    
        pinout4_xbox_lad <= x"1";   --addr7     BL
        wait for clk_period;
        pinout4_xbox_lad <= x"0";   --DATA1
        wait for clk_period;
        pinout4_xbox_lad <= x"0";   --DATA2
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARA1
        wait for clk_period;
        pinout4_xbox_lad <= "ZZZZ"; --TARA2
        wait for clk_period;
        --SYNC
        wait for clk_period; 
        --TARB1
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARB2
        wait for clk_period;
        wait for clk_period;

        -- conflicting lcd not working
        wait for clk_period;
        wait for clk_period;
        pinout4_xbox_lad <= "0000"; --Start!
        wait for clk_period;
        pinout4_xbox_lad <= "0010"; --CYC
        wait for clk_period;
        pinout4_xbox_lad <= x"F";   --addr4
        wait for clk_period;
        pinout4_xbox_lad <= x"7";   --addr5
        wait for clk_period;
        pinout4_xbox_lad <= x"1";   --addr6
        wait for clk_period;    
        pinout4_xbox_lad <= x"0";   --addr7
        wait for clk_period;
        pinout4_xbox_lad <= x"0";   --DATA1
        wait for clk_period;
        pinout4_xbox_lad <= x"0";   --DATA2
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARA1
        wait for clk_period;
        pinout4_xbox_lad <= "ZZZZ"; --TARA2
        wait for clk_period;
        --SYNC
        wait for clk_period; 
        --TARB1
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARB2
        wait for clk_period;
        wait for clk_period;

        -- set backlight to 0
        wait for clk_period;
        wait for clk_period;
        pinout4_xbox_lad <= "0000"; --Start!
        wait for clk_period;
        pinout4_xbox_lad <= "0010"; --CYC
        wait for clk_period;
        pinout4_xbox_lad <= x"F";   --addr4
        wait for clk_period;
        pinout4_xbox_lad <= x"7";   --addr5
        wait for clk_period;
        pinout4_xbox_lad <= x"0";   --addr6
        wait for clk_period;    
        pinout4_xbox_lad <= x"1";   --addr7     BL
        wait for clk_period;
        pinout4_xbox_lad <= x"0";   --DATA1
        wait for clk_period;
        pinout4_xbox_lad <= x"0";   --DATA2
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARA1
        wait for clk_period;
        pinout4_xbox_lad <= "ZZZZ"; --TARA2
        wait for clk_period;
        --SYNC
        wait for clk_period; 
        --TARB1
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARB2
        wait for clk_period;
        wait for clk_period;

        -- IO read on lcd reg
        wait for clk_period;
        wait for clk_period;
        pinout4_xbox_lad <= "0000"; --Start!
        wait for clk_period;
        pinout4_xbox_lad <= "0000"; --CYC
        wait for clk_period;
        pinout4_xbox_lad <= x"F";   --addr4
        wait for clk_period;
        pinout4_xbox_lad <= x"7";   --addr5
        wait for clk_period;
        pinout4_xbox_lad <= x"0";   --addr6
        wait for clk_period;    
        pinout4_xbox_lad <= x"0";   --addr7
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARA1
        wait for clk_period;
        pinout4_xbox_lad <= "ZZZZ"; --TARA2
        wait for clk_period;
        --SYNC
        wait for clk_period;
        --DATA1
        wait for clk_period;
        --DATA2
        wait for clk_period; 
        --TARB1
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARB2
        wait for clk_period;
        wait for clk_period;

        -- set lcd to 0
        wait for clk_period;
        wait for clk_period;
        pinout4_xbox_lad <= "0000"; --Start!
        wait for clk_period;
        pinout4_xbox_lad <= "0010"; --CYC
        wait for clk_period;
        pinout4_xbox_lad <= x"F";   --addr4
        wait for clk_period;
        pinout4_xbox_lad <= x"7";   --addr5
        wait for clk_period;
        pinout4_xbox_lad <= x"0";   --addr6
        wait for clk_period;    
        pinout4_xbox_lad <= x"0";   --addr7
        wait for clk_period;
        pinout4_xbox_lad <= x"0";   --DATA1
        wait for clk_period;
        pinout4_xbox_lad <= x"0";   --DATA2
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARA1
        wait for clk_period;
        pinout4_xbox_lad <= "ZZZZ"; --TARA2
        wait for clk_period;
        --SYNC
        wait for clk_period; 
        --TARB1
        wait for clk_period;
        pinout4_xbox_lad <= "1111"; --TARB2
        wait for clk_period;
        wait for clk_period;

        wait for clk_period;
        wait for clk_period;
        wait for clk_period;
        ASSERT FALSE REPORT "Test done." SEVERITY NOTE;

        wait;
    end process;

END behavior;
