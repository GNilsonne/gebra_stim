# MID demo test

active_buttons = 1;
response_matching = simple_matching;
default_clear_active_stimuli = false;
default_background_color = 100, 100, 100;  # Gray
default_font_size = 20;
default_font = "Arial";

##############
begin;
##############
picture {} default;
text {caption = "hit"; font_size=100; font_color = 255,255,255,;} text_hit; 
text {caption = "miss"; font_size=100; font_color = 255,255,255,;} text_miss;
text {caption = "no response"; font_size=100; font_color = 255,255,255,;} text_noresponse;

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
text { caption = "Kom ihåg att svara! \nTryck på knappen för att fortsätta testet!"; font_size = 30; } text_reminder; # Remember to respond - press button again to continue
text { caption = "Inga svar registrerades.\n Testet avbröts."; } ingasvar; # No responses registered - test aborted

# Picture objects
picture { bitmap bmp0; x = 0; y = 0; } pic0;
#picture { bitmap bmp5; x = 0; y = 0; } pic5;
#picture { bitmap bmp25; x = 0; y = 0; } pic25;
picture { bitmap bmpsquare; x = 0; y = 0; } picsquare;
#picture { bitmap bmpoutcome0; x = 0; y = 0; text text1; x = -30; y = -70; } picoutcome0;
#picture { bitmap bmpoutcome5; x = 0; y = 0; text text1; x = -30; y = -70; } picoutcome5;
#picture { bitmap bmpoutcome25; x = 0; y = 0; text text1; x = -30; y = -70; } picoutcome25;
picture { bitmap bmpfix; x = 0; y = 0; } picfix;
#picture { text kom_ihag_svara; x = 0; y = 0; } svara;
#picture { text ingasvar; x = 0; y = 0; } picture_ingasvar;
#picture { background_color = 100, 100, 100; } pic_black;

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

###############
begin_pcl;
###############

# Make logfile
# When program is run, enter 4-digit subject number to write logfile with RT cutoff value
string id = logfile.subject();
output_file resfile = new output_file;
string fname = "rt_" + id + ".txt";
resfile.open(fname, false);
resfile.print("trial_type");
resfile.print("\t");
resfile.print("rt");
resfile.print("\t");
resfile.print("outcome");
resfile.print("\n");

# Read trial list
string triallist = "triallist_demo.txt";
int ntmax = 14; # Number of trials
array<int> alltrials[ntmax][1]; # Size of trial list
input_file myfile = new input_file;
myfile.open(triallist);
loop int r=1; until r > ntmax begin
	alltrials[r][1] = myfile.get_int();
	r=r+1;
end;
myfile.close();

# Run trials
int total_win = 0;	
loop int i = 0 until i > 13
	begin	
	i = i + 1;
	
	fix_event.set_duration(random(2000, 4000));
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
	resp_trial.present();
	wait_trial.present();

	stimulus_data last = stimulus_manager.last_stimulus_data();

	if response_manager.hits() > 0 then
		if (last.type() == stimulus_hit) then
			if (last.reaction_time() <= 400)
				then
				total_win = total_win + alltrials[i][1];
				text1.set_caption("("+string(total_win)+" kr)");		
				text1.redraw();
				pic_pic.set_part(2, text1);
				feedback_trial.present();
				resfile.print(last.reaction_time());
				resfile.print("\t");
				resfile.print("hit");
				resfile.print("\n");
			else
				text1.set_caption("("+string(total_win)+" kr)");		
				text1.redraw();
				pic_pic.set_part(1, bmpoutcome0);
				pic_pic.set_part(2, text1);
				feedback_trial.present();
				resfile.print(last.reaction_time());
				resfile.print("\t");
				resfile.print("miss");
				resfile.print("\n");
			end;
		elseif (last.type() == stimulus_miss) then
			text1.set_caption("("+string(total_win)+" kr)");		
			text1.redraw();
			pic_pic.set_part(1, bmpoutcome0);
			pic_pic.set_part(2, text1);
			feedback_trial.present();
			resfile.print(last.reaction_time());
			resfile.print("\t");
			resfile.print("miss");
			resfile.print("\n");
		end;
	elseif response_manager.hits() == 0 then
		reminder_trial.present();
		i = i - 1;
		resfile.print("NA");
		resfile.print("\t");
		resfile.print("miss");
		resfile.print("\n");
	end;
end;

resfile.close();