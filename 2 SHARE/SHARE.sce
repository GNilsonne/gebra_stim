#define files
scenario = "SHARE";

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
text { caption = "Hur mycket vill du ge?";}; 
} questions; 

# RATING SCALE # 
picture { 
box { height = 10; width = 200; color = 255,255,255; }; 
x = 0; y = -200; 
box { height = 50; width = 5;color = 255,255,255; }; 
x = 0; y = -200; 
text gap; 
x = -200; y = -200; 
text gap; 
x = 200; y = -200; 
text gap; 
x=0; y=-50; 
bitmap {filename = "sedel.jpg"; width = 600; scale_factor = scale_to_width;}; x = 0; y = 200;
}scale; 

# INSTRUCTIONS TRIAL #
trial {
	picture {
   text {caption = "Du får nu ytterligare 100 kr i ersättning, \n som du har möjlighet att dela \n med den andra personen \n som fick stötar"; }; x = 0; y = 0;
   } pic_cue;  
	duration = 8000;
} tr_instr;   

# RATING TRIAL #
trial {
	all_responses = true;
	trial_duration = stimuli_length;
   trial_type = fixed;
} tr_rate;   

############################
begin_pcl;
############################

parameter_window.remove_all();

# Write file with result
output_file resfile = new output_file;
resfile.open("RESULT_SHARE.txt", false);

########################################	
# Main Trial
#######################################

tr_instr.present();
tr_rate.present();

int confirm = response_manager.total_response_count( 3 ); 
int right = response_manager.total_response_count( 2 ); 
int right_up = response_manager.total_response_count( 5 );
int left = response_manager.total_response_count( 1 );
int left_up = response_manager.total_response_count( 4 ); 
int x = 0; 
int x_inc = 4; 
int movement = 0;
scale.set_part(3,number[1]); 
scale.set_part(4,number[2]); 
scale.set_part(5,questions[1]); 
scale.present(); 

loop
until 
	response_manager.total_response_count( 3 ) > confirm 
begin 
	if response_manager.total_response_count( 1 ) > left then 
		movement = -1;
		left = response_manager.total_response_count( 1 );
	elseif response_manager.total_response_count( 4 ) > left_up then 
		movement = 0;
		left_up = response_manager.total_response_count( 4 ); 
	elseif response_manager.total_response_count( 2 ) > right then 
		movement = 1;
		right = response_manager.total_response_count( 2 );
		elseif response_manager.total_response_count( 5 ) > right_up then 
		movement = 0;
		right_up = response_manager.total_response_count( 5 );		
	end; 
	x = x + (movement * x_inc); 
	if x < -100 then x = -100 elseif x > 100 then x = 100 end;

	scale.set_part_x( 2, x ); 
	scale.present(); 
		
	if response_manager.total_response_count( 3 ) > confirm then
		resfile.print (x); 
	end;
end;