# Monetary incentive delay task
# By Gustav Nilsonne and Daniel Samsami 2016
# Free to use with attribution 

# MID demo test
scenario_type = fMRI;
pulses_per_scan = 1;
pulse_code = 115;
active_buttons = 1;
response_matching = simple_matching;
default_clear_active_stimuli = false;
default_background_color = 100, 100, 100;  # Gray
default_font_size = 30;
default_font = "Arial";

##############
begin;
##############
picture {} default;

# Bitmap images with cues etc
bitmap { filename = "pic0.jpg";} bmp0;
bitmap { filename = "pic5.jpg";} bmp5;
bitmap { filename = "pic25.jpg";} bmp25;
bitmap { filename = "picsquare.jpg";} bmpsquare;
bitmap { filename = "picoutcome0.jpg";} bmpoutcome0;
bitmap { filename = "picoutcome5.jpg";} bmpoutcome5;
bitmap { filename = "picoutcome25.jpg";} bmpoutcome25;
bitmap { filename = "fix.jpg";} bmpfix;

# Texts
text { caption = "(sammanlagd summa)"; } text1; # Total sum
text { caption = "Kom ihåg att svara! \nTryck på knappen för att fortsätta"; } text_reminder; # Remember to respond - press button again to continue
text { caption = "Inga svar registrerades.\n Testet avbröts."; } ingasvar; # No responses registered - test aborted
text { caption = "För tidigt! \nTryck på knappen för att fortsätta"; } text_false_start; # No responses registered - test aborted

# Picture objects
picture { bitmap bmp0; x = 0; y = 0; } pic0;
picture { bitmap bmpsquare; x = 0; y = 0; } picsquare;
picture { bitmap bmpfix; x = 0; y = 0; } picfix;

# Trials
trial {
	stimulus_event {
      picture pic0; # tell participant which kind of trial it is, will be changed in PCL
		duration = 500;
	} present_event;
	stimulus_event {
      picture picfix; # fixation cross
		deltat = 1000;
		duration = 1000; # will be randomised in PCL	
		response_active = true;
		stimulus_time_in = 0;
		stimulus_time_out = 1000;
	} fix_event;
} present_trial;

trial {
	stimulus_event {
		picture picsquare;
		stimulus_time_in = 0;
		stimulus_time_out = 1000;
		target_button = 1;
		code = "mystim";
	} resp_event;
} resp_trial;

trial {
	stimulus_event {
		picture {};
		deltat = 300;
		duration = 2000; # will be randomised in PCL
	} wait_event;
} wait_trial;

trial{
	stimulus_event {
		picture {
			bitmap bmpoutcome0; x = 0; y = 0; 
			text text1; x = -30; y = -70;
      } pic_pic;  
		duration = 1000;
		code = "feedback";
	} feedback_event;
} feedback_trial;

trial{
	trial_type = first_response;
	trial_duration = forever;
	stimulus_event {
		picture {
			text text_reminder; x = 0; y = 0; 
      } pic_reminder;  
		code = "reminder";
		target_button = 1;
	} reminder_event;
} reminder_trial;

trial{
	trial_type = first_response;
	trial_duration = forever;
	stimulus_event {
		picture {
			text text_false_start; x = 0; y = 0; 
      } pic_false_start;  
		code = "false_start";
		target_button = 1;
	} false_start_event;
} false_start_trial;

###############
begin_pcl;
###############
default.present();
parameter_window.remove_all();

# Make logfile
# When program is run, enter 4-digit subject number to write logfile with RT cutoff value
string id = logfile.subject();
output_file resfile = new output_file;
string fname = "rt_" + id + ".txt";
resfile.open(fname, false);
resfile.print("trial_type");
resfile.print("\t");
resfile.print("cutoff");
resfile.print("\t");
resfile.print("rt");
resfile.print("\t");
resfile.print("outcome");
resfile.print("\n");

# Read trial list
string triallist = "triallist_1.txt";
int ntmax = 60; # Number of trials
array<int> alltrials[ntmax][1]; # Size of trial list
input_file myfile = new input_file;
myfile.open(triallist);
loop int r=1; until r > ntmax begin
	alltrials[r][1] = myfile.get_int();
	r=r+1;
end;
myfile.close();

# Read response times from demo
#string rt = "rt_" + id + ".txt";
#int ntmax = 14; # Number of trials
#array<int> alltrials[ntmax][1]; # Size of list
#input_file rtfile = new input_file;
#rtfile.open(rt);
#loop int r=1; until r > ntmax begin
#	rtlist[r][1] = mrtfile.get_int();
#	r=r+1;
#end;
#rtfile.close();

# Get fMRI trigger pulse
int pulses = pulse_manager.main_pulse_count();
loop until (pulse_manager.main_pulse_count() > pulses)
begin
end;

# Run trials
int total_win = 0;	
int cutoff = 262;
loop int i = 0 until i > 59
	begin	
	i = i + 1;
	
	int thisduration = random(2000, 4000);
	fix_event.set_duration(thisduration);
	fix_event.set_stimulus_time_out(thisduration);
	wait_event.set_duration(random(2000, 4000));
	
	if alltrials[i][1] == 0 then
		pic0.set_part(1, bmp0);
		pic_pic.set_part(1, bmpoutcome0);
		resfile.print(0);
		resfile.print("\t");
	elseif alltrials[i][1] == 5 then
		pic0.set_part(1, bmp5);
		pic_pic.set_part(1, bmpoutcome5);
		resfile.print(5);
		resfile.print("\t");
	elseif alltrials[i][1] == 25 then
		pic0.set_part(1, bmp25);
		pic_pic.set_part(1, bmpoutcome25);
		resfile.print(25);
		resfile.print("\t");
	end;

	present_trial.present();
	stimulus_data last = stimulus_manager.last_stimulus_data();
	if last.type() != last.FALSE_ALARM then # No false start
		resp_trial.present();
		wait_event.set_deltat(cutoff);
		wait_trial.present();

		stimulus_data last2 = stimulus_manager.last_stimulus_data();

		if response_manager.hits() > 0 then
			if (last2.type() == stimulus_hit) then
				if (last2.reaction_time() <= cutoff)
					then
					total_win = total_win + alltrials[i][1];
					text1.set_caption("("+string(total_win)+" kr)");		
					text1.redraw();
					pic_pic.set_part(2, text1);
					feedback_trial.present();
					resfile.print(cutoff);
					resfile.print("\t");
					resfile.print(last2.reaction_time());
					resfile.print("\t");
					resfile.print("hit");
					resfile.print("\n");
					cutoff = cutoff - 10;
				else
					text1.set_caption("("+string(total_win)+" kr)");		
					text1.redraw();
					pic_pic.set_part(1, bmpoutcome0);
					pic_pic.set_part(2, text1);
					feedback_trial.present();
					resfile.print(cutoff);
					resfile.print("\t");
					resfile.print(last2.reaction_time());
					resfile.print("\t");
					resfile.print("miss");
					resfile.print("\n");
					cutoff = cutoff + 20;
				end;
			elseif (last2.type() == stimulus_miss) then
				text1.set_caption("("+string(total_win)+" kr)");		
				text1.redraw();
				pic_pic.set_part(1, bmpoutcome0);
				pic_pic.set_part(2, text1);
				feedback_trial.present();
				resfile.print(cutoff);
				resfile.print("\t");
				resfile.print(last2.reaction_time());
				resfile.print("\t");
				resfile.print("miss");
				resfile.print("\n");
				cutoff = cutoff + 20;
			end;
		elseif response_manager.hits() == 0 then
			reminder_trial.present();
			i = i - 1;
			resfile.print(cutoff);
			resfile.print("\t");
			resfile.print("NA");
			resfile.print("\t");
			resfile.print("miss");
			resfile.print("\n");
		end;
	elseif last.type() == last.FALSE_ALARM then
		false_start_trial.present();
	end;
end;
resfile.close();