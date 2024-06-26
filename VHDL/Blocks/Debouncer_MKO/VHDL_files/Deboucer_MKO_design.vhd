library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debounce is
    Port ( CLK : in STD_LOGIC;
           BTNC : in STD_LOGIC;
           PWM_Per: in STD_LOGIC_vector(3 downto 0);
           En_PWM : out STD_LOGIC);
end debounce;

architecture Behavioral of debounce is
	
    constant debounce_time : integer:= 4; -- change this value
    constant duration_1 : integer:= 100; -- change this value to 1 sec
    constant duration_2 : integer:= 200; -- change this value to 2 sec
	constant duration_3 : integer:= 300; -- change this value to 3 sec
	constant duration_4 : integer:= 400; -- change this value to 4 sec
    type state_type is (RELEASED, PRE_PRESSED, PRESSED, PRE_RELEASED);
    signal clean_temp : std_logic;
    signal clean : std_logic;
    signal debounce_counter : integer range 0 to debounce_time ;
    signal per_counter : integer:= 0;
    signal duration : integer:= 0;
   	signal state : state_type;
    
begin
    process (CLK)
    begin
        if rising_edge(CLK) then
        	case state is

                    when RELEASED =>
                        -- If BTNC button = 1 then clear counter and change to PRE_PRESSED;
                        if BTNC = '1' then
                            debounce_counter <= 0;
                            state <= PRE_PRESSED;
                        end if;

                    when PRE_PRESSED =>
                        -- If BTNC = 1 increment counter
                        if BTNC = '1' then
                            debounce_counter <= debounce_counter + 1;
                            -- if debounce_counter = debounce_time-1 change to PRESSED
                            if debounce_counter = debounce_time -1 then
                                state <= PRESSED;
                            end if;
                        -- else change to RELEASED
                        else
                            state <= RELEASED;
                        end if;

                    when PRESSED =>
                        -- If BTNC = 0 then clear counter and change to PRE_RELEASED;
                        if BTNC = '0' then
                            debounce_counter <= 0;
                            state <= PRE_RELEASED;
                        end if;

                    when PRE_RELEASED =>
                        -- If BTNC = 0 then increment counter
                        if BTNC = '0' then
                            debounce_counter <= debounce_counter + 1;
                            -- if debounce_counter = debounce_coun ter-1 change to RELEASED;
                            if debounce_counter = debounce_time - 1 then
                                state <= RELEASED;
                            else 
                            end if;
                        -- else clear counter and change to PRESSED;
                        else
                            debounce_counter <= 0;
                            state <= PRESSED;
                        end if;

                    -- Prevent unhandled cases
                    when others =>
                        null;
                end case;
        end if;
    end process;

-- Set clean signal value = 1 when states PRESSED or PRE_RELEASED
clean_temp <= '1' when state = PRESSED or state = PRE_RELEASED else '0';

duration_proces: process (CLK, PWM_Per)
begin
	if PWM_Per = "0000" then
    	clean <= clean_temp;
	else
    	if rising_edge(CLK) then
          		if per_counter < duration  then
                	if clean_temp = '1' then
                    per_counter <= per_counter + 1;
                    clean <= '1';
                    else 
                    	if per_counter < duration and clean = '1' then
                    	per_counter <= per_counter + 1;
                        	if per_counter = duration - 1 then
                    			clean <= '0';
                                per_counter <= 0;
                           	end if;
                        end if;
                    end if;
                else 
                 	clean <= '0';
                end if;
        end if;
    end if;
end process;

En_PWM <= clean;

period_decoder: process (PWM_Per)
    begin 
        case PWM_Per is
            when "0001" =>     
                duration <= duration_1;
            when "0010" =>     
                duration <= duration_2;
            when "0011" =>     
                duration <= duration_3;
            when "0100" =>     
                duration <= duration_4;
               
            when others => 
                duration <= 0; 
        end case;
    end process;
    
   
end Behavioral;
