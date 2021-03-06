#define files
scenario = "EP";
pcl_file = "EP.pcl";

#standard settings
scenario_type = fMRI;
pulses_per_scan = 1;
pulse_code = 115;

active_buttons = 5;
button_codes = 1,2,3,4,5;
response_logging = log_active;  # log only if response is expected
response_matching = simple_matching;

default_output_port = 1; # parallel port 
response_port_output = false;
write_codes = true;
pulse_width = 1; # duration of shock, will be changed in pcl

default_background_color = 100, 100, 100; # gray   
default_font_size = 40;
default_text_color = 255,255,255;
default_font = "Arial";      

#####################################################
begin;
#####################################################

#Stimuli
picture {} default;
picture {text {caption = "+"; font_size=100; font_color = 255,255,255,;}; x=0;y=0;} fixation_cross;
TEMPLATE "template.tem";

text { caption = "XXX"; 
font_size =20;
preload = false; 
} gap; 

# RANGE OF RATING SCALE # 
array{ 
text {caption = "0";}; 
text {caption = "100";}; 
} number;

# QUESTION ABOVE RATING SCALE # 
array{ 
text { caption = "Hur ont gjorde det?";}; 
text { caption = "Hur obehagligt var det för dig?";}; 
text { caption = "Hur ont tror du att det gjorde?";}; 
} questions; 

# RATING SCALE # 
picture { 
box { height = 10; width = 200; color = 255,255,255; }; 
x = 0; y = 0; 
box { height = 50; width = 5;color = 255,255,255; }; 
x = 0; y = 0; 
text gap; 
x = -200; y = 0; 
text gap; 
x = 200; y = 0; 
text gap; 
x=0; y=150; 
}scale; 


#######################################################
# Define trials
#######################################################

# FIXATION CROSS #
trial {
	all_responses = false;
	trial_duration = stimuli_length;
   trial_type = fixed;
	stimulus_event{ 
		picture fixation_cross;
		time = 0;
		duration = 2000;
		code="fixation_cross";		
	} ev_fixation_cross;
} tr_fixation_cross;   

# BLANK SCREEN #
trial {
	all_responses = false;
	trial_duration = stimuli_length;
   trial_type = fixed;
	stimulus_event{ 
		picture default;
		time = 0;
		duration = 4000;
		code="blank";		
	} ev_blank;
} tr_blank;   

# CONDITION TRIAL #
trial {     
   trial_duration = stimuli_length;
   trial_type = fixed;
	all_responses = false;
   stimulus_event{  #condition
      picture {
         text {caption = "condition";}; x = 0; y = 0;
         } pic_condition;  
		time=0;
		duration = 	500;
      code = "condition";
      } ev_condition;	
}tr_condition;

# SHOCK #
trial {
   trial_duration = stimuli_length;
   trial_type = fixed;
	all_responses = false;

	stimulus_event {
      picture {text {caption = "condition";}; x = 0; y = 0; } pic_shock; # Will be changed in PCL
      time=0;
   	port_code = 0; # Determines shock intensity, will be changed in PCL
		code = "shock";
	} ev_shock;

	stimulus_event {
      picture {text {caption = "condition";}; x = 0; y = 0; } pic_shock2; # Will be changed in PCL
   	time = 2; # Determines shock length, will be constant at 2 ms
   	duration = 298;
   	port_code = 0;
	} ev_shockpic;
	
} tr_shock; 

# RATING SCALE #
trial {
	all_responses = true;
	trial_duration = stimuli_length;
   trial_type = fixed;
} tr_rate;   

#########################