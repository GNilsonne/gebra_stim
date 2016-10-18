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

# Pictures saying how long the shock will be
array{
bitmap { filename = "self_low.jpg"; width = 800; scale_factor = scale_to_width;} ;
bitmap { filename = "self_high.jpg"; width = 800; scale_factor = scale_to_width;} ;
} pic_skala;

array{
bitmap { filename = "shockpic_self_low.jpg"; width = 800; scale_factor = scale_to_width;} ;
bitmap { filename = "shockpic_self_high.jpg"; width = 800; scale_factor = scale_to_width;} ;
} pic_shockpics;

trial { # Select shock length
	trial_type = first_response;
	stimulus_event{
	picture {
		} pic_resp; 
		time = 0;
		code = "Response";
		duration = target_response;
	}ev_resp;
} duration_trial; 

trial { # Give shock
	all_responses = true;
	stimulus_event{  
		picture{
			bitmap { filename = "shockpic_self_low.jpg"; width = 800; scale_factor = scale_to_width;}; x = 0; y = 0;
         } pic_shockpic;
         duration = 300;
		port_code = 1;
		code_width = 1; # Will be changed in pcl
	} ev_shock;
				
} main_trial; 

##############################
begin_pcl;
##############################

# Initialise counters
int lo=1;
int shock_length = 1;
int shock_length_counter = 1;
int shock_no = 0;
int right = response_manager.total_response_count(2); 
int left = response_manager.total_response_count(1);
int movement = 0;	
pic_resp.add_part(pic_skala[1],0,0);

# Run trials
loop
   int i = 1
until
   i > 3 # Not incremented, makes loop run with no end

	begin 
		if response_manager.total_response_count(1) > left then 
			movement = movement -1;
			left = response_manager.total_response_count(1);
			if movement >= 1 then
				movement = 1
			end;
			if movement <= 0 then
				movement = 0
			end;
			int sk = 1;
			if movement == 1 then
				sk= 2;
				shock_length_counter = 300;
			elseif movement == 0 then
				sk= 1;
				shock_length_counter = 1;
			end;
			lo = sk;
			shock_length = shock_length_counter;
			pic_resp.clear();
			pic_resp.add_part(pic_skala[lo],0,0);
			pic_shockpic.clear();
			pic_shockpic.add_part(pic_shockpics[lo],0,0);

		elseif response_manager.total_response_count(2) > right then 
			movement = movement + 1;
			right = response_manager.total_response_count(2);	
			if movement >= 1 then
				movement = 1
			end;
			if movement <= 0 then
				movement = 0
			end;
			int sk = 1;
			if movement == 1 then
				sk= 2;
				shock_length_counter = 300;
			elseif movement == 0 then
				sk= 1;
				shock_length_counter = 1;
			end;
			lo = sk;
			shock_length = shock_length_counter;
			pic_resp.clear();
			pic_resp.add_part(pic_skala[lo],0,0);
			pic_shockpic.clear();
			pic_shockpic.add_part(pic_shockpics[lo],0,0);
		end;
	
	duration_trial.present(); 
	ev_shock.set_code_width(shock_length);
	
	if response_manager.total_response_count(3) > shock_no then
		main_trial.present();
		shock_no = shock_no + 1
	end;
	
end;