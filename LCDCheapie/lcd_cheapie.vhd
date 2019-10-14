-- Interface parallel character LCDs through Xbox Original LPC bus.
-- Copyright (C) 2019  Benjamin Fiset-Deschênes

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.

-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.


-- Interface Xbox LPC to parallel LCD interface
-- Design makes use of pull-ups on all pins
-- Internal pull-ups of LC4032V are sufficient in a normal Xbox environment

--*+ header
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


-- ----------------------------------------
entity lcdcheapie_entity is
-- ----------------------------------------

    port (
        pin_xbox_n_lrst : in std_logic;                         --Xbox-side Reset signal
        pin_xbox_lclk : in std_logic ;                          --Xbox-side CLK
        pinout4_xbox_lad : inout std_logic_vector(3 downto 0);  --Xbox-side LPC IO
        pout_lcd_rs : out std_logic;
        pout_lcd_e : out std_logic;
        --R/W is set to W on board
        p4out_lcd_d4_d7 : out std_logic_vector(3 downto 0);           
        pout_backlight: out std_logic                           --LCD backlight control.
    );

end lcdcheapie_entity;

-- ----------------------------------------
architecture arch_lcdcheapie of lcdcheapie_entity is
-- ----------------------------------------
--**+ constants +***
    constant c_FALSE_STD: std_logic := '0';
    constant c_TRUE_STD: std_logic := '1';
    
    constant c_RST_ASSERTED: std_logic := '0';
    
    constant c_LAD_START_PATTERN: std_Logic_vector := "0000";
    constant c_LAD_INPUT_PATTERN: std_Logic_vector := "ZZZZ";
    constant c_LAD_PATTERN_SYNC: std_Logic_vector := "0000";
    
    constant c_CYC_MEM_PREFIX: std_Logic_vector := "01";
    constant c_CYC_IO_PREFIX: std_Logic_vector := "00";
    
    constant c_FSM_COUNT_RESET: integer := 0;
    constant c_FSM_COUNT_IO_START_OFFSET: integer := 4;
    
    constant c_FSM_ADDR_SEQ_NIBBLE6: integer := 6;
    constant c_FSM_ADDR_SEQ_NIBBLE7: integer := 7;
    constant c_FSM_ADDR_SEQ_MAX_COUNT: integer := c_FSM_ADDR_SEQ_NIBBLE7;
    constant c_FSM_DATA_SEQ_MAX_COUNT: integer := c_FSM_ADDR_SEQ_NIBBLE6;
    
    constant c_FSM_DATA_WRITE_LO_NIBBLE_OFFSET: integer := 0;
    constant c_FSM_DATA_WRITE_HI_NIBBLE_OFFSET: integer := 1;
    
    constant c_IO_REG_ADDR_NIBBLE1: std_Logic_vector := X"F";
    constant c_IO_REG_ADDR_NIBBLE2: std_Logic_vector := X"7";
    constant c_IO_REG_ADDR_NIBBLE3: std_Logic_vector := X"0";
    constant c_IO_REG_ADDR_LCD_DATA: std_Logic_vector := X"0";
    constant c_IO_REG_ADDR_LCD_BACKLIGHT: std_Logic_vector := X"1";
    
    constant c_LCD_REG_DATA_RESET: std_Logic_vector := "000";
    
    constant c_PWM_COUNTER_RESET_VALUE: std_Logic_vector := "00000";
    constant c_PWM_COUNTER_MAX_VALUE: std_Logic_vector := "11111";
    constant c_NULL_DUTY_CYCLE: std_Logic_vector := "00000";

--***+ types
    -- Regroup the necessary 17 cycle for a single byte of data transfer (both in R/W).
    type LPC_FSM is 
    (
        LPC_FSM_WAIT_START, -- 0000 read, occurs with LFRAME output asserted. Active while idle and on START frame (1/17 cycle)
        LPC_FSM_GET_CYC,    -- next nibble is CYCTYPE. Active 1/17 cycle.
        LPC_FSM_GET_ADDR,   -- 8 nibbles of address, most significant nibble first. Active 8/17 cycles for mem CYC ops or 4 for IO CYC ops
        LPC_FSM_DATA        -- TAR,SYNC and DATA transfer sequences. Active 7/17 cycles.
    );                      -- For a total of 17 cycles :)


--***+ signals
    signal s_io_cyc : std_logic;
    signal s_fsm_counter : integer range c_FSM_COUNT_RESET to c_FSM_ADDR_SEQ_MAX_COUNT;    --Used for addresses resolution and TLPC_DAT state counter.
    signal s_lpc_fsm_state : LPC_FSM;              --2 bit state descriptor, unless you add entries to "typeLpc".
    signal s5_duty_cycle : std_Logic_vector(4 downto 0) := c_NULL_DUTY_CYCLE;    --BL is only on 5 bits so 32 combinations possbile.
    signal s5_pwm_counter : std_logic_vector(4 downto 0) := c_PWM_COUNTER_RESET_VALUE;
    signal s4_io_reg_addr : std_logic_vector(3 downto 0);
    signal s3_lcd_data_low : std_logic_vector(2 downto 0) := c_LCD_REG_DATA_RESET;
    signal s3_lcd_data_high : std_logic_vector(2 downto 0) := c_LCD_REG_DATA_RESET;
    signal s_backlight : boolean := false;
    
begin
--***+ component instantiation

--LCD
pout_backlight <= '1' when s_backlight = true else '0';
pout_lcd_rs <= s3_lcd_data_low(0);
pout_lcd_e <= s3_lcd_data_low(1);
p4out_lcd_d4_d7 <= s3_lcd_data_high & s3_lcd_data_low(2);


--***+ processes

--Process that cycle through all the steps of LPC RW operations. 
process_lpc_decode : process(pin_xbox_lclk) --33MHz
begin
    if rising_edge(pin_xbox_lclk) then
        if pin_xbox_n_lrst = c_RST_ASSERTED then --Still too early in boot sequence. We must wait for RST to go high.
            s_lpc_fsm_state <= LPC_FSM_WAIT_START;   
        else --There we go!
            if s_fsm_counter < c_FSM_ADDR_SEQ_MAX_COUNT then
                s_fsm_counter <= s_fsm_counter + 1;
            else
                s_fsm_counter <= c_FSM_COUNT_RESET;
            end if;
            case s_lpc_fsm_state is
                when LPC_FSM_WAIT_START =>  -- 0000 read, occurs with LFRAME output asserted
                    s_io_cyc <= c_FALSE_STD;
                    if pinout4_xbox_lad = c_LAD_START_PATTERN then -- its a start
                        s_lpc_fsm_state <= LPC_FSM_GET_CYC;
                    end if;                         
                when LPC_FSM_GET_CYC => -- next nibble is CYCTYPE
                    if pinout4_xbox_lad(3 downto 2) = c_CYC_MEM_PREFIX then -- memory read or write
                        s_fsm_counter <= 0;    --Reset counter for address decode.
                        s_lpc_fsm_state <= LPC_FSM_GET_ADDR;
                    elsif pinout4_xbox_lad(3 downto 2) = c_CYC_IO_PREFIX then
                        s_io_cyc <= pinout4_xbox_lad(1); -- 1 for write.
                        s_fsm_counter <= c_FSM_COUNT_IO_START_OFFSET;  --Only 4 address nibbles are required in this case. IO write only requires 13 cycles.
                        s_lpc_fsm_state <= LPC_FSM_GET_ADDR;    --LPC cycle goes on like normal.                    
                    else
                        s_lpc_fsm_state <= LPC_FSM_WAIT_START; -- sit out any unsupported cycle until the next start. This section could be expanded to allow other LPC message to go through (LCD :P)
                    end if;                         
                when LPC_FSM_GET_ADDR => -- 8 nibbles of address, most significant nibble first
                    case s_fsm_counter is
                        when 4 =>
                            --I don't care if you try to read from any address base.
                            if pinout4_xbox_lad /= c_IO_REG_ADDR_NIBBLE1  then     --IO cycle: first nibble must be "0xF"
                                s_io_cyc <= c_FALSE_STD;
                            end if;
                        when 5 =>
                            --IO cycle: Second nibble must either be "0x7"
                            if pinout4_xbox_lad /= c_IO_REG_ADDR_NIBBLE2 then      
                                s_io_cyc <= c_FALSE_STD;
                            end if;
                        when 6 =>
                            if pinout4_xbox_lad /= c_IO_REG_ADDR_NIBBLE3  then --IO cycle: third nibble must be "0000". 
                                s_io_cyc <= c_FALSE_STD;
                            end if;
                        when 7 =>
                            s4_io_reg_addr <= pinout4_xbox_lad;    --We want the real deal.
                            s_fsm_counter <= 0;  --Need to reset counter for LPC_FSM_DATA sequence.
                            s_lpc_fsm_state <= LPC_FSM_DATA;  --Next state once all 32 bits of addressing have been transferred (from the Xbox).
                        when others =>
                            null;
                    end case;
                when LPC_FSM_DATA =>
                    if s_fsm_counter >= c_FSM_DATA_SEQ_MAX_COUNT then
                        s_lpc_fsm_state <= LPC_FSM_WAIT_START;   --Will always signals the end of a R/W cycle.
                    end if;
                when others =>
                    null;   --How did you get there?
            end case;                   
        end if; --pin_xbox_n_lrst
    end if; -- clock
end process process_lpc_decode;


--Process that control both LAD ports
--Logic is determined by "s_lpc_fsm_state" and "s_fsm_counter" within a specific "s_lpc_fsm_state" value.
process_lpc_direction : process(s_lpc_fsm_state, s_fsm_counter, s_io_cyc)
begin
    if s_lpc_fsm_state = LPC_FSM_DATA and s_io_cyc = c_TRUE_STD and s_fsm_counter = 4 then   --Sequences that reverse data flow.
        pinout4_xbox_lad <= c_LAD_PATTERN_SYNC; --SYNC. Must be hard coded for IO write operations
        --The rest of the time, everybody is in high-Z with pull ups so the necessary 0xF nibbles are all there.                        
    else    --If not one of the condition above. Happens on LFRAME start, CYC decode, 8 address nibbles, TARA1, TARB2 and of course when idle.
        pinout4_xbox_lad <= c_LAD_INPUT_PATTERN;
    end if;
end process process_lpc_direction;
    
    
--IO operations decoding process.
process(pin_xbox_lclk)
begin
    if rising_edge(pin_xbox_lclk) then
        --Only IO write is implemented in this design.
        if s_lpc_fsm_state = LPC_FSM_DATA then
            --Low Data nibble
            if s_fsm_counter = c_FSM_DATA_WRITE_LO_NIBBLE_OFFSET and s_io_cyc = c_TRUE_STD then  --IOWrite
                case s4_io_reg_addr is
                    when c_IO_REG_ADDR_LCD_DATA =>    --LCD register
                        s3_lcd_data_low <= pinout4_xbox_lad(3 downto 1);    
                    when c_IO_REG_ADDR_LCD_BACKLIGHT =>        --BL register
                        s5_duty_cycle(1 downto 0) <= pinout4_xbox_lad(3 downto 2); --Skip LSB 
                    when others => null;
                end case;
                
            --High Data nibble  
            elsif s_fsm_counter = c_FSM_DATA_WRITE_HI_NIBBLE_OFFSET and s_io_cyc = c_TRUE_STD then   --still IOWrite
                case s4_io_reg_addr is
                    when c_IO_REG_ADDR_LCD_DATA =>    --LCD register
                        s3_lcd_data_high <= pinout4_xbox_lad(2 downto 0);   
                    when c_IO_REG_ADDR_LCD_BACKLIGHT =>        --BL register
                        s5_duty_cycle(4 downto 2) <= pinout4_xbox_lad(2 downto 0); 
                    when others => null;
                end case;
            end if;
        end if;
    end if;     --clk
end process;

    
--PWM processes. Generates signal of a frequency of around 260KHz.
--Setting the duty cycle of a signal requires a single input command and will carry on the same
--duty cycle until a new duty cycle value is sent from the Xbox.
process(pin_xbox_lclk)
begin
    if rising_edge(pin_xbox_lclk) then
        s5_pwm_counter <= s5_pwm_counter + 1;
    end if;
end process;    


process(pin_xbox_lclk)
begin
    if rising_edge(pin_xbox_lclk) then     
        if s5_pwm_counter = c_PWM_COUNTER_MAX_VALUE and s5_duty_cycle /= c_NULL_DUTY_CYCLE then 
            s_backlight <= true;
        elsif s5_duty_cycle = s5_pwm_counter  then
             s_backlight <= false;
        end if;
    --That's the best I could think of to generate PWM signal with 5 bits resolution and still make it fit.
    --If you're unhappy, you're free to code a better PWM feature that will fit into the LC4032V without breaking anything else.
    end if;
end process;    

end arch_lcdcheapie;
