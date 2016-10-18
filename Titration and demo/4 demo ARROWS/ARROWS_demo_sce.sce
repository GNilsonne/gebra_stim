scenario = "ARROWS_demo_sce";
scenario_type = fMRI;
pulses_per_scan = 1;
pulse_code = 115;
response_logging = log_active;  # Log only if response is expected
response_matching = simple_matching;

default_max_responses = 1;
default_all_responses = false;
active_buttons = 3;
button_codes = 1,2,3;

default_background_color = 100, 100, 100;  # Gray
default_font = "Verdana";      
default_font_size = 30;                                 

#######################################
begin;
#######################################

picture {} default;

# Read in pictures
TEMPLATE "ARROWS_demo_tem.tem";

# DEFINE TRIALS #
# Regulation cue and stimulus picture
trial {     
   trial_duration = stimuli_length;
   trial_type = fixed;
	all_responses = false;
   stimulus_event{ 
      picture {
         text {caption = "Cue"; }; x = 0; y = 0;
         } pic_cue;  
		time = 0;
		duration = 2000; 
      code = "Cue";
      } ev_cue;
   stimulus_event{ 
      picture {
         text {caption = "Pic2";}; x = 0; y = 0;
         } pic_pic;  
         deltat = 2000;
		duration = 1000; 
      code = "Pic";
      port_code = 99;
      } ev_pic;
   stimulus_event {  # Blank screen
      picture {
         } pic_blank;  
		time = 3000;
		duration = 2000;
      code = "Blank";
   } ev_blank;
}tr_instpic;

# Response
trial {
	all_responses = true;	
	stimulus_event{
	picture {
		} pic_resp; 
		time = 0;
		code = "Response";
		}ev_resp;
} tr_resp;

# Fixation cross
trial {     
   trial_duration = stimuli_length;
   trial_type = fixed;
	all_responses = false;
      stimulus_event{
			picture {
				text {caption = "+"; font_size=100; font_color = 255,255,255,;}; x=0;y=0;
			} pic_iti; 
		time = 0;		
		duration = 4000; # Will be randomised in PCL
      code = "ITI"; # Intertrial interval
      } ev_iti;      
}tr_iti;  

###############################
begin_pcl;
###############################

default.present();
parameter_window.remove_all();

# READ TRIAL LIST #
string fname = "triallist_demo.txt";

# LOCATE TRIALS #
int ntmax = 4; # Number of trials
array<int> alltrials[ntmax][5]; # Size of trial list
input_file myfile = new input_file;
myfile.open(fname);
loop int r=1; until r > ntmax begin
	alltrials[r][1] = myfile.get_int();
	alltrials[r][2] = myfile.get_int(); 
	alltrials[r][3] = myfile.get_int(); 
	alltrials[r][4] = myfile.get_int();
	alltrials[r][5] = myfile.get_int();
	r=r+1;
end;
myfile.close();

# RUN TRIALS #

# Loop over stimuli
loop int tr=1; until tr > 4 begin

	int thispic = alltrials[tr][2];
	int thiscond = alltrials[tr][3];
	int thisiti= alltrials[tr][5];
	
	pic_pic.clear();	
	pic_cue.clear();	
	pic_pic.add_part(pic[thispic],0,0);

	if thiscond == 1 then # Maintain neg 
		pic_cue.add_part(cue[1],0,0);
		pic_pic.add_part(pic[thispic],0,0);
	
	elseif thiscond == 3 then # Downregulate
		pic_cue.add_part(cue[2],0,0);
		pic_pic.add_part(pic[thispic],0,0);
		
	elseif thiscond == 4 then # Maintain neutral
		pic_cue.add_part(cue[1],0,0);
		pic_pic.add_part(pic[thispic],0,0);
	end;
	
# Show fixation cross
	ev_iti.set_event_code("ITI");
	ev_iti.set_duration(thisiti); 
	tr_iti.present();
	
# Show cue and stimulus
	ev_blank.set_duration(thisiti); 
	tr_instpic.present();

# Get response
	int resp=0;
	int tnow= 0;
	int ttrial= 0;
	int tzero=0;
	int lo=1;
	int bpress=0;
	
	int confirm = response_manager.total_response_count(2); 
	int right = response_manager.total_response_count(3); 
	int left = response_manager.total_response_count(1);
	int movement = 0;	
	pic_resp.add_part(pic_skala[1],0,0);

loop
  	until 
		response_manager.total_response_count(2) > confirm 
	begin 
		if response_manager.total_response_count(1) > left then 
			movement = movement -1;
			left = response_manager.total_response_count(1);
			if movement >= 3 then
				movement = 3
			end;
			if movement <= -3 then
				movement = -3
			end;
			int sk = 5;
			if movement == 3 then
				sk= 8;
				elseif movement == 2 then
				sk= 7;
				elseif movement == 1 then
				sk= 6;
				elseif movement == 0 then
				sk= 5;
				elseif movement == -1 then
				sk= 4;
				elseif movement == -2 then
				sk= 3;
				elseif movement == -3 then
				sk= 2;
			end;
			lo=sk;
			pic_resp.clear();
			pic_resp.add_part(pic_skala[lo],0,0);

		elseif response_manager.total_response_count(3) > right then 
			movement = movement + 1;
			right = response_manager.total_response_count(3);	
			if movement >= 3 then
				movement = 3
			end;
			if movement <= -3 then
				movement = -3
			end;
			int sk = 5;
			if movement == 3 then
				sk= 8;
				elseif movement == 2 then
				sk= 7;
				elseif movement == 1 then
				sk= 6;
				elseif movement == 0 then
				sk= 5;
				elseif movement == -1 then
				sk= 4;
				elseif movement == -2 then
				sk= 3;
				elseif movement == -3 then
				sk= 2;
			end;
			lo=sk;
			pic_resp.clear();
			pic_resp.add_part(pic_skala[lo],0,0);
		end;
	if response_manager.total_response_count(2) > confirm then
	end;
		
	tr_resp.present();
	resp = lo-1;				
end;

tr=tr+1;
	
end;			