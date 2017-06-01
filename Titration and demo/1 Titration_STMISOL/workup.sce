
scenario = "workup";

scenario_type = trials;
         
response_logging = log_active;  #log only if response is expected
response_matching = simple_matching;

default_max_responses = 1;
default_all_responses = true;
active_buttons = 3;
button_codes = 1,2,3;

default_output_port = 1;
response_port_output = false;
write_codes = true;
pulse_width = 1; 

default_background_color = 100, 100, 100;  # gray
default_font = "Arial";      

#######################################
begin;
#######################################

picture {} default;

# Pictures saying how intense the shock will be
array{
picture {text {caption = "0 V";  font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "5 V";  font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "10 V"; font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "15 V"; font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "20 V"; font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "25 V"; font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "30 V"; font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "35 V"; font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "40 V"; font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "45 V"; font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "50 V"; font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "55 V"; font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "60 V"; font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "65 V"; font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "70 V"; font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "75 V"; font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
picture {text {caption = "80 V"; font_size=100; font_color = 255,255,255;}; x=0;y=0;} ;
} array_intensity;

trial { # Select shock intensity
	trial_type = first_response;
	stimulus_event{
	nothing{};
	#picture { text {caption = "test"; font_size=100; font_color = 255,255,255;}; x=0;y=0; } pic_selection; 
	time = 0;
	code = "Response";
	duration = target_response;
	}ev_selection;
} tr_selection; 

trial { # Give shock
	all_responses = true;
	trial_duration = 300;

	stimulus_event {
      picture{ bitmap { filename = "shockpic_self_high.jpg"; width = 800; scale_factor = scale_to_width; }; x = 0; y = 0;} pic_shockpic;
   	time = 0;
   	port_code = 0; # Determines shock intensity, will be changed in PCL
	} tr_shock;

	stimulus_event {
      picture{ bitmap { filename = "shockpic_self_high.jpg"; width = 800; scale_factor = scale_to_width; }; x = 0; y = 0;} pic_shockpic2;
   	time = 20; # Determines shock length, will be constant at 2 ms
   	#duration = 280;
   	port_code = 0;
	} tr_shock_after;
	
} main_trial; 

##############################
begin_pcl;
##############################

# Initialise counters
int shock_no = 0;
int right = response_manager.total_response_count(2); 
int left = response_manager.total_response_count(1);
int step = 1; # 5 V increments, starting at 0 V
double code = 0; # Will be fed to port code argument, range 0-4
tr_shock.set_port_code(0); # Failsafe, always start at 0 V

# Run trials
loop
   int i = 1
until
   i > 3 # Not incremented, makes loop run with no end

	begin 
		if response_manager.total_response_count(1) > left then 
			step = step -1;
			left = response_manager.total_response_count(1);
			if step >= 17 then
				step = 17 # 80 V is maximum
			end;
			if step <= 1 then
				step = 1
			end;
			code = (step-1)*0.5; # Port code ranges from 0 to 4
			ev_selection.set_stimulus( array_intensity[step] );

		elseif response_manager.total_response_count(2) > right then 
			step = step + 1;
			right = response_manager.total_response_count(2);	
			if step >= 17 then
				step = 17
			end;
			if step <= 1 then
				step = 1
			end;
			code = (step-1)*0.5; # Port code ranges from 0 to 4
			ev_selection.set_stimulus( array_intensity[step] );
		end;
	
	tr_selection.present(); # Present trial to select intensity
	
	if (code > 4) then # Failsafe to prevent shocks over 80 V
		code = 0; 
	end; 

	tr_shock.set_port_code(code);
	
	if response_manager.total_response_count(3) > shock_no then
		main_trial.present();
		shock_no = shock_no + 1
	end;
	
end;