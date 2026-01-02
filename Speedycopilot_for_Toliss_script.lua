





--########################################
--# To have a debug help on screen it's  #
--# VERY important to cancel moving any  #
--# script to the Quarantaine within FWL.#
--########################################







-- FCOM amplified procedures
-- for use as copilot emulation
-- By Aerographe Flight Simulation
-- Under Open Licence 2.0 Etalab
-- Created on 2019-08-07 - Revision in 2020 - Revision in 2022-08 2022-10
-- Works for the ToLis Airbus A319/A321
-- Made from revision 4.5 of Speedy Copilot 320.

--########################################
--# COCKPIT PREP PRESET FREQUENCY       #
--########################################
local presetFrequency = 12280 -- hz.
-- This is the frequency the PM tunes on VHF1 and VHF2 active frequency during
-- the cockpit preparation procedure.
-- Default is 12280 for 122.800, so format is "xxxYY" for frequency "xxx.YY0".

--########################################
--# FLAPS retraction schedule on climb   #
--########################################
-- By default the PM uses F and S speeds indicated by the MCDU
-- Set your climb speeds in knots here instead of the MCDU.
local climb_speed_is_manual = 0  	-- default is 0, set to 1 to take over
flaps1_climb_speed = 180	-- initial value : 180
flapsUP_climb_speed = 200	-- initial value : 200 (max value : 189 kts !)
-- During takeoff phase, F and S speeds are the minimum speeds for retracting the
-- surfaces:
-- * At F speed, the aircraft accelerating (positive speed trend): retract to 1.
-- * At S speed, the aircraft accelerating (positive speed trend): retract to 0.

--########################################
--# FLAPS extension schedule on approach #
--########################################
-- By default the PM uses Green dot and S speeds indicated by the MCDU
-- Set your approach speeds in knots here to take over MCDU values
local app_speed_is_manual = 0 	-- default is 0, set to 1 to take over
flaps1_app_speed = 230		-- initial value : 230
flaps2_app_speed = 190		-- initial value : 190
flapsAPP_app_speed = 170	-- initial value : 170 (F3 or full)




-- Below this line, you shouldn't edit anything in regular use ;-)
local gunslingers = 1 -- when you trespass this limit
--------------------------------------------------------------------------------

-- Everything has been carefully crafted and tested. I swear.
-- If it's not broken, don't fix it ! ;-)



if not SUPPORTS_FLOATING_WINDOWS then
    -- to make sure the script doesn't stop old FlyWithLua versions
    logMsg("FlyWithLua Info: Speedy Copilot for ToLiSS imgui not supported by your FlyWithLua version")
    print("FlyWithLua Info: Speedy Copilot for ToLiSS imgui not supported by your FlyWithLua version")
    return
else
    logMsg("FlyWithLua Info: Speedy Copilot for ToLiSS can load imgui functions. Good.")
end

require("graphics")



--########################################
--# LEGACY GUI                           #
--########################################
local TL_LegacyGUI = "deactivate"
-- Write exclusively "activate" or "deactivate"
-- It's intended to be "activate" only if your setup
-- makes it hard to display the new GUI with
-- pictures (low frames typically).

SCT_start_delay = 15
SCT_start_time = os.clock() + SCT_start_delay
SCT_loaded = false
print("FlyWithLua Info: Speedy Copilot for ToLiSS will be loaded after a delay of " .. SCT_start_delay .. " seconds.")
function delay_SCT_loading()
	if os.clock() > SCT_start_time and SCT_loaded == false then
		SCT_script()
		SCT_loaded = true
	end
end

--[[
https://forums.x-plane.org/index.php?/forums/topic/270998-flywithlua-280_b1-for-x-plane-12/&do=findComment&comment=2424345

Hi, I have the probem that in X-Plane 12 the scripts are loaded too early in contrast with X-Plane 11, during the flight session loading.
I have to modify all my scripts to introduce a delay before loading the content of it, otherwise X-Plane 12 crashes to the desktop. Maybe the dataref interface is not ready at the time the scripts are read by the lua enigne in X-Plane 12. In other words, the session is loading (whatever aircraft), FWL loads the scripts and bam, full X-Plane 12 crash to desktop without clear issue in the log. I confirm, log show no interesting output at all. When adding the scripts AFTER the session is loaded, and reloading them, they can be loaded fine and run normally.
--]]




local version_text_troiscentvingt = "6.6"
-- 6.6 : access to livery_path updated for X-Plane 10.0.8
-- 6.5 : updated temperature_ambiant_c to sim/weather/aircraft/temperature_ambient_deg_c for X-Plane 12
-- 6.4 :  A320 TRIM and CG
-- 6   : font color causing a crash on XP11, GUI functions causing a crash for an user, offers a second location for the bottom bar
-- 5.2 : the Toliss A321 1.5 RC1 was causing a FlyWithLua crash
-- 5.1 : Approaching Minimums Callout adjusted to avoid intermixing with the onboard system callout sound. / Progression of some Normal proc in the Menu fixed
-- 5   : the new Speedy Copilot for ToLiSS,
--       implementing the 2021 AIRBUS FLOWs and checklists
--       implementing VR message
-- 4.5 : replaced activation from acfraft acf definition file to author caracterisation
-- 4.4 : transponder and TCAS setting adjusted to the A340-600 commands
-- 4.21 general cycling action on FD removed and limited to the COCKPIT PREP function
-- 4.2 comment the execution the RADIOtweak function, flight director problem during TRKFPA FD off approaches solved, provisions for 4 engines airbus
-- 3.4 avoids deploying emergency slides
-- 3.3 doesn't open service door with P2F

--########################################
--#  CLOCK                               #
--########################################
-- keep track of the current time
function Time()
	current_time = math.floor(os.clock())
end
do_every_frame("Time()") -- mind the constraint : DO NOT MOVE that function
--########################################

do_sometimes("delay_SCT_loading()")

function SCT_script()

	if IsXPlane12 == nil then IsXPlane12 = false  end-- safety

	if XPLMFindDataRef("sim/version/xplane_internal_version") ~= nil then
		if SGES_xplane_internal_version == nil 		then  dataref("SGES_xplane_internal_version", "sim/version/xplane_internal_version","readonly") end
		print("[Speedy Copilot for ToLiSS] sim/version/xplane_internal_version " .. SGES_xplane_internal_version .. ".")
		if string.find(SGES_xplane_internal_version,"12") then
			IsXPlane12 = true
			print("[Speedy Copilot for ToLiSS] IsXPlane12 true ")
		else
			IsXPlane12 = false
			print("[Speedy Copilot for ToLiSS] IsXPlane12 false ")
		end
	end

	if SpeedyCopilot_Author == nil then dataref("SpeedyCopilot_Author","sim/aircraft/view/acf_author","readonly",0) end
	print("FlyWithLua Info: Speedy Copilot for ToLiSS will check which aircraft is loaded.")

		if SpeedyCopilot_Author == "Gliding Kiwi" or SpeedyCopilot_Author == "GlidingKiwi" then  -------------------------------------- IMPORTANT : THE AIRCRAFT CHECK !!
		print("FlyWithLua Info: Speedy Copilot for ToLiSS says it's a ToLiSS Airbus ! Therefore we continue loading stuff.")

		function display_bubble(text)
			message_time=math.floor(os.clock())  -- used by function AutoClear
			function Message()  message_done = 0
			 if normal_messages == 1 then big_bubble( 50, 20, text) end
			end
		end

		--########################################
		--# SUPPLEMENTARY SETTINGS               #
		--########################################
		local debug_message = 1 -- With 1 debug message is active, with 0 it isn't

		--########################################
		--# GO AROUND after approach             #
		--########################################
		-- GO AROUND FMGS phase is monitored. Values below are only a backup trigger.
		-- So, no need to keep them too sensitive.
		-- set the minimum speed at which the copilot detect a 'go around' (in knots)
		local go_around_speed_detection = 140	-- initial value : 140 kts ; (sensitive)
		-- set the minimum vertical speed to detect a 'go around' (in fpm)
		local go_around_verticalspeed_detection = 1500 -- initial value : 1500 fpm ; (!)

		--########################################
		--#  LOAD DELAY INIT                     #
		--########################################
		dataref("altitudeAGL", "sim/flightmodel/position/y_agl","readonly") -- Altitude above ground level in meter ! /!\
		-- We want to wait a few moments.
		-- FlyWithLua is actually faster and stops short of finding the data it
		-- needs. So we must wait and only look for the data when it becomes
		-- available from the simulated aircraft.
		-- The delay value is now deported in the script setup.

		MenuClosingDelay = 240
		-- To avoid degrading performances, we will close automatically the menu this value elapsed in seconds.
		-- Initial value is for 4 minutes = 240 seconds.

		local FlyWithLuaScriptLoadTime = math.floor(os.clock())
		local MenuOpening_time=FlyWithLuaScriptLoadTime+9999

		-- when the API is not ready, we wait and provide temporary values
		Current_title = "Script not ready"

		shutdownproc_trigger = 9
		beforestartproc_trigger = 9
		preliminaryprocedure_trigger = 9
		preflightproc_trigger = 9
		afterstartproc_trigger = 9
		beforetakeoff_trigger=9
		takeoffproc_trigger= 9
		approachproc_trigger = 9
		afterlandingproc_trigger = 9
		flapsretraction_trigger = 9
		PilotCheckedRight = true
		PilotCheckedLeft = true
		RunwayEntryFlag = true
		BrakeReleasedFlag = true
		GoAroundFlag = false
		the_option_window_displayed = false



		--########################################


		--########################################
		--# INITIAL STATE when ready             #
		--########################################

		local slides_addon_installed = false
		function file_exists(name)
			local f=io.open(name,"r")
			if f~=nil then io.close(f) return true else return false end
		end

		AGL_onGround = 2 -- new in January 2023
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		------------------------ START OF GUI -----------------------------------------------------------------------------------------------------------------------------------------
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

		function all_menus_definitions()
			function build_CLIST_float_wnd(CLIST_float_wnd, x, y) --<-- The GUI code goes in this section.
				local user_color="0xFF95DAFF"
				--~ imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/separator_bar.png"), 675, 7)
				imgui.TextUnformatted('     CHECKLISTS [2 DEC 21]')
				imgui.SetWindowFontScale(1.4)
				-- Define the content of the window, that is the checklists item
				if (takeoffproc_trigger == 0 or takeoffproc_trigger == 1) then
					--imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/ChecklistAirbus2021.arrival.jpg"), 366, 662)

					imgui.TextUnformatted("____________________________________________________")
					imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
					imgui.Bullet()imgui.TextUnformatted(' Cockpit preparation ')
					imgui.PopStyleColor()
					imgui.TextUnformatted('* EXTERNALPWR...................ON')
					imgui.TextUnformatted('GEAR PINS & COVERS ........REMOVED')
					imgui.TextUnformatted('FUEL QUANTITY.............___KG/LB')
					imgui.TextUnformatted('SEAT BELTS......................ON')
					imgui.TextUnformatted('ADIRS..........................NAV')
					imgui.TextUnformatted('BARO REF.......................___')
					imgui.TextUnformatted("____________________________________________________")
					imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
					imgui.Bullet() imgui.TextUnformatted(' Before Start ')
					imgui.PopStyleColor()
					imgui.TextUnformatted('* PARKING BRAKE.................ON')
					imgui.TextUnformatted('T..O. SPEEDS & THRUST..........___')
					imgui.TextUnformatted('WINDOWS.....................CLOSED')
					imgui.TextUnformatted('BEACON..........................ON')
					imgui.TextUnformatted("____________________________________________________")
					imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
					imgui.Bullet() imgui.TextUnformatted(' After Start ')
					imgui.PopStyleColor()
					imgui.TextUnformatted('* ENGINE MODE SEL.............NORM')
					imgui.TextUnformatted('ANTI ICE.......................___')
					imgui.TextUnformatted('PITCH TRIM...................___ %')
					imgui.TextUnformatted('RUDDER TRIM................NEUTRAL')
					imgui.TextUnformatted("____________________________________________________")
					imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
					imgui.Bullet() imgui.TextUnformatted(' Taxi ')
					imgui.PopStyleColor()
					imgui.TextUnformatted('* TAXI LIGHTS...................ON')
					imgui.TextUnformatted('* FLIGHT CONTROLS............CHECKED')
					imgui.TextUnformatted('FLAPS SETTING.............CONF ___')
					imgui.TextUnformatted('RADAR & PRED W/S.........ON & AUTO')
					imgui.TextUnformatted('ENG MODE / START SEL...........___')
					imgui.TextUnformatted('ECAM MEMO...............TO NO BLUE')
					imgui.SetWindowFontScale(1.0)
					imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
					imgui.TextUnformatted('	-AUTO BRK MAX')
					imgui.TextUnformatted('	-SIGNS ON')
					imgui.TextUnformatted('	-CABIN READY')
					imgui.TextUnformatted('	-SPLRS ARM')
					imgui.TextUnformatted('	-FLAPS TO')
					imgui.TextUnformatted('	-TO CONFIG NORM')
					imgui.PopStyleColor()
					imgui.SetWindowFontScale(1.4)
					imgui.TextUnformatted("____________________________________________________")
					imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
					imgui.Bullet() imgui.TextUnformatted(' Line-up ')
					imgui.PopStyleColor()
					imgui.TextUnformatted('* LANDING LIGHTS...............-ON')
					imgui.TextUnformatted('* LEFT/RIGHT GLANCE..........CLEAR')
					imgui.TextUnformatted('T.O. RWY.......................___')
					imgui.TextUnformatted('TCAS...........................___')
					imgui.TextUnformatted('PACKS 1 & 2....................___')
					imgui.TextUnformatted("____________________________________________________")
					imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
					imgui.Bullet() imgui.TextUnformatted('		<< Departure Change >>')
					imgui.PopStyleColor()
					imgui.TextUnformatted('RWY & SID......................___')
					imgui.TextUnformatted('FLAP SETTING..............CONF ___')
					imgui.TextUnformatted('T.O. SPEEDS & THRUST...........___')
					imgui.TextUnformatted('FCU ALT........................___')
					imgui.TextUnformatted("____________________________________________________")

				else
					--~ imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/ChecklistAirbus2021.departure.jpg"), 371, 930)
					imgui.TextUnformatted("____________________________________________________")
					imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
					imgui.Bullet() imgui.TextUnformatted(' Approach ')
					imgui.PopStyleColor()
					imgui.TextUnformatted('BARO REF...................___ SET')
					imgui.TextUnformatted('SEAT BELT.......................ON')
					imgui.TextUnformatted('MINIMUM........................___')
					imgui.TextUnformatted('AUTO BRAKE.....................___')
					imgui.TextUnformatted('ENG MODE / START SEL...........___')
					imgui.TextUnformatted("____________________________________________________")
					imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
					imgui.Bullet() imgui.TextUnformatted(' Landing ')
					imgui.PopStyleColor()
					imgui.TextUnformatted('ECAM MEMO..............LDG NO BLUE')
					imgui.SetWindowFontScale(1.0)
					imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
					imgui.TextUnformatted('	-LDG GEAR DN')
					imgui.TextUnformatted('	-SIGNS ON')
					imgui.TextUnformatted('	-CABIN READY')
					imgui.TextUnformatted('	-SPLRS ARM')
					imgui.TextUnformatted('	-FLAPS SET')
					imgui.PopStyleColor()
					imgui.SetWindowFontScale(1.4)
					imgui.TextUnformatted("____________________________________________________")
					imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
					imgui.Bullet() imgui.TextUnformatted(' After Landing ')
					imgui.PopStyleColor()
					imgui.TextUnformatted('* GND SPOILERS..............DISARM')
					imgui.TextUnformatted('* APU START.....................ON')
					imgui.TextUnformatted('RADAR & PRED W/S...............OFF')
					imgui.TextUnformatted("____________________________________________________")
					imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
					imgui.Bullet() imgui.TextUnformatted(' Parking ')
					imgui.PopStyleColor()
					imgui.TextUnformatted('PARK BRK OR CHOCKS.............SET')
					imgui.TextUnformatted('CHRONO.........................SET')
					imgui.TextUnformatted('ENGINES........................OFF')
					imgui.TextUnformatted('WING LIGHTS....................OFF')
					imgui.TextUnformatted('FUEL PUMPS.....................OFF')
					imgui.TextUnformatted("____________________________________________________")
					imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
					imgui.Bullet() imgui.TextUnformatted(' Securing the aircraft ')
					imgui.PopStyleColor()
					imgui.TextUnformatted('OXYGEN.........................OFF')
					imgui.TextUnformatted('EMER EXIT LIGHT................OFF')
					imgui.TextUnformatted('EFBS...........................OFF')
					imgui.TextUnformatted('BATTERIES......................OFF')
					imgui.TextUnformatted("____________________________________________________")
				end
				imgui.SetWindowFontScale(1)
				if imgui.Button("> BACK < ",370,25) then
					checklist_card_requested = false
					float_wnd_set_imgui_builder(OPTION_WINDOW, "OPTION_BUTTON")
					float_wnd_set_geometry(OPTION_WINDOW,bar_X, bar_Y+normal_bar_height,bar_X+bar_width, bar_Y)
				end
			end




			checklist_card_requested = false
			app_is_active = false
			ToLissPNFonDuty = 1 GUI_ToLissPNFonDuty = true -- patch
			FLAPS_wanted = 1 GUI_FLAPS_wanted = true -- patch
			function update_GUI()
				if FLAPS_wanted == 1 		then GUI_FLAPS_wanted = true 	else GUI_FLAPS_wanted = false end
				if DelaysAPU == 1 		then GUI_DelaysAPU = true 	else GUI_DelaysAPU = false end
				if Say_Rotate == 1 		then GUI_Say_Rotate = true else GUI_Say_Rotate = false end
				if Park_is_PNF == 1 		then GUI_Park_is_PNF = true 	else GUI_Park_is_PNF = false end
				if Pre_Conditioned_Air_Unit == 1 then GUI_Pre_Conditioned_Air_Unit = true else GUI_Pre_Conditioned_Air_Unit = false end

				if JAR_Ground_Handling_wanted == 1 		then GUI_JAR_Ground_Handling_wanted = true DatarefJARLoad() 	else GUI_JAR_Ground_Handling_wanted = false end

				if forward_JARstairs_wanted == 1 	then GUI_forward_stairs_Yes = true  GUI_forward_stairs_No = false else GUI_forward_stairs_Yes = false  GUI_forward_stairs_No = true end
				if AfterLandingWithAPU == 1 	then GUI_AfterLandingWithAPU = true else GUI_AfterLandingWithAPU = false end
				if normal_messages == 1 	then GUI_normal_messages = true else GUI_normal_messages = false end
				if Check_yaw == 1 		then GUI_Check_yaw = true 	else GUI_Check_yaw = false end
				if QuickGlance == 1 		then GUI_QuickGlance = true 	else GUI_QuickGlance = false end
				--if TL_Keep_secondary_sounds == "activate" then GUI_SecondarySounds = true else GUI_SecondarySounds = false end -- direct
				if ToLissPNFonDuty == 1 		then GUI_ToLissPNFonDuty = true 	else GUI_ToLissPNFonDuty = false end

			end
			if app_is_active then do_often("update_GUI()") end

			-- **************** THIS PART WAS ADDED FOR NEW WINDOW STYLE ********************** START **
			-- NEW INDEPENDANT WINDOW
			-- main wnd built function
			options = nil
			if TL_LegacyGUI == "deactivate" then
				function options_show_wnd()
					if not options_open then
						options = float_wnd_create(750, 850, 1, true)
						float_wnd_set_title(options, "Speedy Copilot options")
						--float_wnd_set_imgui_builder(options, "options_on_build")
						float_wnd_set_imgui_builder(options, "OPTION_MENU")
						--~ float_wnd_set_imgui_builder(options, "build_CLIST_float_wnd")

						float_wnd_set_onclose(options, "options_on_close")
						options_open = true
					end
				end

				function options_on_close()
					options_open = false
				end
			end
			-- **************** THIS PART WAS ADDED FOR NEW WINDOW STYLE *********************** END **


			-- MAIN
			show_window_bottom_bar = false
			do_tha_mouse = true
			app_is_active = false
			bar_X= 1200
			bar_Y= 0
			bar_width = 420
			normal_bar_height = 90
			CL_bar_height = 1020
			bar_height = normal_bar_height

			function mouse_surveillance()
				if not app_is_active then
					--if (MOUSE_X > SCREEN_WIDTH - 350) and (MOUSE_Y > SCREEN_HIGHT-250) then
					if (MOUSE_X > bar_X - 200) and (MOUSE_X < bar_X + bar_width + 200 ) and (MOUSE_Y > bar_Y - 220) and (MOUSE_Y < bar_Y + normal_bar_height + 200) then
						mouse_in_region = true
					else
						mouse_in_region = false
					end
				end
			end
			do_often("mouse_surveillance()")

			hide_the_bottom_bar = false
			function show_the_bottom_bar()
				if not app_is_active and hide_the_bottom_bar == false then
					if (mouse_in_region and do_tha_mouse) or FF_FWL_MenuCall then
						show_window_bottom_bar = true
						do_tha_mouse = false
						end_show_time = math.floor(os.clock()) + 10
						if checklist_card_requested then
							end_show_time = end_show_time + 40 -- increase available time when the mouse exits the area
						end
						show_the_option_window()
					end
					if not mouse_in_region and show_window_bottom_bar then
						if (os.clock()) > end_show_time then
							show_window_bottom_bar = false
							do_tha_mouse = true
							if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end
						end
					end
				end
			end
			do_every_frame("show_the_bottom_bar()")

			function show_the_option_window()
				if the_option_window_displayed == false then
					local window_type = 2
					-- THE WINDOW
					if GUI_VR_message then window_type = 1 end
					OPTION_WINDOW = float_wnd_create(bar_X, bar_Y, window_type, true)
					imgui.PushStyleColor(imgui.constant.Col.WindowBg, 0xCC714B00) -- Blue like Background
					float_wnd_set_title(OPTION_WINDOW, "Speedy Copilot for ToLiSS")
					float_wnd_set_position(OPTION_WINDOW, bar_X, bar_Y )
					float_wnd_set_onclose(OPTION_WINDOW, "closed_OPTION_WINDOW")
					the_option_window_displayed = true
					if checklist_card_requested then -- CHANGE THE WINDOW CONTENT TO DISPLAY CHECKLISTS
						bar_height = CL_bar_height
						float_wnd_set_imgui_builder(OPTION_WINDOW, "build_CLIST_float_wnd")
						float_wnd_set_geometry(OPTION_WINDOW,bar_X, bar_Y+bar_height,bar_X+bar_width, bar_Y)
						end_show_time = math.floor(os.clock()) + 40 -- increase available time when the mouse exits the area
					--~ elseif GUI_VR_message and Vr_message_current_answer == "?" and Message_wnd_content ~= "" then
						--~ float_wnd_set_imgui_builder(OPTION_WINDOW, "OPTION_BUTTON")
						--~ float_wnd_set_geometry(OPTION_WINDOW,bar_X, 150,1590, 0)
					else
						bar_height = normal_bar_height
						float_wnd_set_imgui_builder(OPTION_WINDOW, "OPTION_BUTTON")
						float_wnd_set_geometry(OPTION_WINDOW,bar_X, bar_Y+bar_height,bar_X+bar_width, bar_Y)
					end
				end
			end

			function OPTION_BUTTON(OPTION_WINDOW, x, y)
			-- THE BUTTON

				imgui.SetWindowFontScale(1)
				imgui.Bullet() imgui.TextUnformatted(Current_title)
				if imgui.Button("ISCS",60,47) then
					command_once("toliss_airbus/iscs_open")
				end
				imgui.SameLine()
				if TL_LegacyGUI == "deactivate" then
					-- **************** THIS PART WAS ADDED FOR NEW WINDOW STYLE ********************** START **
					function RustineLoadFunction()
						if loadOptions == true then options_show_wnd() loadOptions = false end
					end
					do_often("RustineLoadFunction()")
					if imgui.Button("[Options]",128,47) then

						show_window_bottom_bar = false -- try that in January 2023
						do_tha_mouse = true -- try that in January 2023 following user reporting crashes
						if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end  -- try that in January 2023

						loadOptions = true -- new independant window style
						MenuOpening_time=math.floor(os.clock())
					end
					-- **************** THIS PART WAS ADDED FOR NEW WINDOW STYLE *********************** END **
				end
				if TL_LegacyGUI == "activate" then
					--imgui.SameLine()
					if imgui.Button("[Options]",128,47) or FF_FWL_MenuCall then
						MenuOpening_time=math.floor(os.clock())
						FF_FWL_MenuCall = false
						app_is_active = true
						float_wnd_set_geometry(OPTION_WINDOW, SCREEN_WIDTH-720, 920, SCREEN_WIDTH, 0)
						float_wnd_set_imgui_builder(OPTION_WINDOW, "OPTION_MENU")
					end
				end
				imgui.SameLine()
				if GUI_messages_in_circle_and_all_messages then
					if imgui.Button("Hide",60,47) then
						GUI_messages_in_circle_and_all_messages = false
						normal_messages = 0 GUI_normal_messages = false
					end
				else
					if imgui.Button("Show",60,47) then
						GUI_messages_in_circle_and_all_messages = true normal_messages = 1 GUI_normal_messages = true
					end
				end
				imgui.SameLine()
				if imgui.Button("Checklists",90,47) then -- checklists
					if checklist_card_requested then checklist_card_requested = false else checklist_card_requested = true end
					if checklist_card_requested then -- CHANGE THE WINDOW CONTENT TO DISPLAY CHECKLISTS
						bar_height = CL_bar_height
						float_wnd_set_imgui_builder(OPTION_WINDOW, "build_CLIST_float_wnd")
						end_show_time = math.floor(os.clock()) + 40 -- increase available time when the mouse exits the area
					else
						bar_height = normal_bar_height
						float_wnd_set_imgui_builder(OPTION_WINDOW, "OPTION_BUTTON")
					end
					float_wnd_set_geometry(OPTION_WINDOW,bar_X, bar_Y+bar_height,bar_X+bar_width, bar_Y)
				end
				imgui.SameLine()

				if bar_X > 500 then
					if imgui.Button("L.",30,47) then -- checklists
						if 	bar_X == 1200 then
							bar_X = 1
							bar_Y = 300
							float_wnd_set_geometry(OPTION_WINDOW,bar_X, bar_Y+normal_bar_height,bar_X+bar_width, bar_Y)
						end
					end
				else
					if imgui.Button("B.",30,47) then -- checklists
						if 	bar_X == 1 then
							bar_X = 1200
							bar_Y = 0
							float_wnd_set_geometry(OPTION_WINDOW,bar_X, bar_Y+normal_bar_height,bar_X+bar_width, bar_Y)
						end
					end
				end

				------------------------------VR ----------------------------------------
				------------------------------VR ----------------------------------------
				------------------------------VR ----------------------------------------
				if GUI_VR_message and Vr_message_current_answer == "?" and Message_wnd_content ~= "" then
					--~ if checklist_card_requested then
						--~ float_wnd_set_imgui_builder(OPTION_WINDOW, "OPTION_BUTTON")
						--~ checklist_card_requested = false
					--~ end
					if checklist_card_requested then -- CHANGE THE WINDOW CONTENT TO DISPLAY CHECKLISTS
						bar_height = bar_Y + CL_bar_height
					else
						bar_height = bar_Y + 250
					end
					float_wnd_set_geometry(OPTION_WINDOW,bar_X, bar_height,bar_X+bar_width, bar_Y)
					--imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/separator_sc.png"), 675, 18)

					imgui.PushTextWrapPos(imgui.GetFontSize() * 30)
					imgui.TextUnformatted("____________________________________________________")
					imgui.Bullet() imgui.TextUnformatted(Message_wnd_content)
					imgui.PopTextWrapPos()

					imgui.SetWindowFontScale(0.4)
					imgui.TextUnformatted("")
					imgui.SetWindowFontScale(1)
					--if Message_wnd_action == "" then
						if imgui.Button("Yes",80,40) then
							Vr_message_current_answer = "yes"
							Message_wnd_content = ""
							float_wnd_set_geometry(OPTION_WINDOW,bar_X, bar_Y+normal_bar_height,bar_X+bar_width, bar_Y)
						end
						imgui.SameLine()
						if imgui.Button("No",60,40) then
							--display_bubble("Doing nothing.")
							Vr_message_current_answer = "no"
							float_wnd_set_geometry(OPTION_WINDOW,bar_X, bar_Y+normal_bar_height,bar_X+bar_width, bar_Y)
							show_window_bottom_bar = false -- try that in January 2023
							do_tha_mouse = true -- try that in January 2023 following user reporting crashes
							if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end  -- try that in January 2023
						end
					imgui.TextUnformatted("____________________________________________________")
					--~ else
						--~ if imgui.Button("Acknowledge",90,20) then
							--~ Vr_message_current_answer = "yes"
							--~ Message_wnd_content = ""
							--~ float_wnd_set_geometry(OPTION_WINDOW,bar_X, 90,1590, 0)
						--~ end
					--~ end
				end

				------------------------------VR ----------------------------------------
				------------------------------VR ----------------------------------------
				------------------------------VR ----------------------------------------
			end

			--~ function OPTION_MENU(OPTION_WINDOW, x, y)
			function OPTION_MENU(OPTION_WINDOW)
			-- temp
			-- THE OPTIONS WINDOW
				local user_color="0xFF95DAFF"
				imgui.SetWindowFontScale(1.3)
				imgui.TextUnformatted("Speedy Copilot for ToLiSS " .. version_text_troiscentvingt .. "  ")  imgui.SameLine()
				local changed, newVal = imgui.Checkbox("Is active   ", GUI_ToLissPNFonDuty)
				if changed then
					if newVal then
						if ToLissPNFonDuty == 0 then MENU_RESET = 1 end
						ToLissPNFonDuty = 1
						GUI_ToLissPNFonDuty = true
						display_bubble("Speedy Copilot is active.")
					 else ToLissPNFonDuty = 0 GUI_ToLissPNFonDuty = false
						display_bubble("Speedy Copilot is turned off.")
					 end
				end


				imgui.SameLine() imgui.SetWindowFontScale(0.9) if imgui.Button("> AUTOMATIC RESET <",130,20) then MENU_RESET = 1
					app_is_active = false
					if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end  end
				imgui.SetWindowFontScale(0.5)
				imgui.TextUnformatted("")



				imgui.SetWindowFontScale(1.1) imgui.TextUnformatted("   Reset to ")
				if altitudeAGL < AGL_onGround then
					imgui.SameLine() imgui.SetWindowFontScale(1.1)
					if imgui.Button("COCKPIT PREP.",105,22) then
						MENU_RESET = 44
						app_is_active = false
						if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end
					end

				if preliminaryprocedure_trigger == 2 and afterstartproc_trigger == 0 then
					imgui.SameLine() imgui.SetWindowFontScale(1.1)
					if imgui.Button("MCDU input",95,22) then MENU_RESET = 33
						app_is_active = false
						if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end
					end
				end

				if preliminaryprocedure_trigger == 2 and afterstartproc_trigger == 0 then
					imgui.SameLine() imgui.SetWindowFontScale(1.1)
					if imgui.Button("AOC PERF TO",95,22) then
						app_is_active = false
						if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end
						ACARS_PERF_TAKEOFF_step = 0
						ACARS_PERF_TAKEOFF_time = current_time
					end
				end



					imgui.SameLine() imgui.SetWindowFontScale(1.1)
					if imgui.Button("BEFORE T.O.",95,22) then MENU_RESET = 55
						app_is_active = false
						if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end
					end
				end
				if altitudeAGL > 10 then
					imgui.SameLine() imgui.SetWindowFontScale(1.1)
					if imgui.Button("CLIMB",65,22) then MENU_RESET = 77
						app_is_active = false
						if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end
					end
					imgui.SameLine() imgui.SetWindowFontScale(1.1)
					if imgui.Button("APPROACH",75,22) then MENU_RESET = 88
						app_is_active = false
						if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end
					end
				end

				if altitudeAGL < AGL_onGround then
					imgui.SameLine() imgui.SetWindowFontScale(1.1)
					if imgui.Button("AFTER LANDING",115,22) then MENU_RESET = 99
						app_is_active = false
						if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end
					end
					imgui.SameLine() imgui.SetWindowFontScale(1.1)
					if imgui.Button("NEXT LEG",90,22) then MENU_RESET = 101
						display_bubble("Speedy Copilot is active.")
						app_is_active = false
						if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end
					end
				end


				------------------------------------------------------------------------------------------------------------
				imgui.SetWindowFontScale(1.3)
				if preflightproc_trigger < 2 and ExternalPowerEnabled == 0 and speed < 100 then

					imgui.TextUnformatted(" ") imgui.SameLine()

					if imgui.Button("Start an external power unit (offers preliminary preparation)",650,25) then
						app_is_active = false
						if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end
						if PLANE_ICAO == "A346" then ExternalPowerAEnabled = 1 end
						ExternalPowerEnabled = 1
					end
				end

				if preflightproc_trigger < 2 and ExternalPowerEnabled == 1 and ExtPowerConnected == 0 and speed < 100 then

					imgui.TextUnformatted(" ") imgui.SameLine()
					if imgui.Button("Connect the external power (offers cockpit preparation)",650,25) then
						app_is_active = false
						if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end
						if PLANE_ICAO == "A346" then ExtPowerAConnected = 1 end
						ExtPowerConnected = 1
					end
				end

				imgui.SetWindowFontScale(0.4)
				imgui.TextUnformatted("")
				imgui.SetWindowFontScale(1.3)
				imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
				if imgui.TreeNode("Normal procedures list") then
					imgui.TextUnformatted('Procedures that Speedy Copilot for ToLiSS has done :')
					--~ imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/separator_bar.png"), 675, 7)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFFFFFFFF)
					imgui.Checkbox("Safety exterior inspection procedure", SEI_P)
					imgui.Checkbox("Cockpit preliminary preparation procedure", CPP_P)
					imgui.Checkbox("Cockpit preparation procedure", CP_P)
					imgui.Checkbox("Before PB or start : before start clearance proc.", BSC_P)
					imgui.Checkbox("Before PB or start : at start clearance proc.", ASC_P)
					imgui.Checkbox("Pushback procedure", P_P)
					imgui.Checkbox("Engine start procedure", ES_P)
					imgui.Checkbox("After start procedure", AS_P)
					imgui.Checkbox("Taxi procedure", Tx_P)
					if PLANE_ICAO ~= "A346" then imgui.Checkbox("One Engine Taxi procedure (PRO-SUP-93-20)", OET_P) end
					local changed, newVal = imgui.Checkbox("<< Departure change procedure >> (not scripted)", DC_P)
					if changed then
						if newVal then DC_P = true 	else DC_P = false	end
					end
					imgui.Checkbox("Before takeoff procedure for Line-up C/L)", BT_P)
					imgui.Checkbox("Takeoff procedure", T_P)
					imgui.Checkbox("After takeoff procedure", AT_P)
					imgui.Checkbox("Climb procedure", C_P)
					imgui.Checkbox("Cruise procedure", CS_P)
					imgui.Checkbox("Descent preparation procedure", DPP_P)
					imgui.Checkbox("Descent procedure", D_P)
					imgui.Checkbox("Approach procedure", A_P)
					imgui.Checkbox("Landing procedure", L_P)
					imgui.Checkbox("Go-around procedure", GA_P)
					imgui.Checkbox("After landing procedure", AL_P)
					imgui.Checkbox("Parking procedure", P_P)
					local changed, newVal = imgui.Checkbox("Securing the aircraft procedure (not scripted)", STA_P)
					if changed then
						if newVal then STA_P = true 	else STA_P = false	end
					end
					--
					imgui.TreePop()
					imgui.PopStyleColor()
				end
				imgui.PopStyleColor()

				imgui.TextUnformatted("")
				--
				--~ imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/separator_sc.png"), 675, 18) --if TL_LegacyGUI == "deactivate" then imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/separator_sc.png"), 675, 18) end

		----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")


				--



				imgui.PushStyleColor(imgui.constant.Col.WindowBg, 0xCC1E1E1E) -- Blue like Background
				--imgui.TextUnformatted(" ")
				imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
				imgui.Bullet() imgui.TextUnformatted("Pilot Monitoring options")
				imgui.PopStyleColor()
				--imgui.TextUnformatted(" ")
				--
				local changed, newVal = imgui.Checkbox("The PM sets FLAPS and moves the GEAR handle (not persistent).", GUI_FLAPS_wanted)
				if imgui.IsItemActive() then
					-- We can create a tooltip that is shown while the item is being clicked (click & hold):
					imgui.BeginTooltip()
					-- This function configures the wrapping inside the toolbox and thereby its width
					imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
					imgui.TextUnformatted("The Pilot Monitoring will handle gear and flaps retraction and extension on schedule, during take off and later in approach, as if under your command.")
					imgui.TextUnformatted("This option is always defaulted to 'active'.")
					imgui.PopStyleColor()
					-- Reset the wrapping, this must always be done if you used PushTextWrapPos
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end


					if changed then
					if newVal then
						FLAPS_wanted = 1 GUI_FLAPS_wanted = true
						display_bubble("I won't set FLAPS and GEAR as if under your command.")
					else FLAPS_wanted = 0 GUI_FLAPS_wanted = false
						display_bubble("I won't touch FLAPS and GEAR handles.")
					end
				end
				--
				local changed, newVal = imgui.Checkbox("The PM delays the APU on departure (airport regulations).", GUI_DelaysAPU)
				if imgui.IsItemActive() then
					-- We can create a tooltip that is shown while the item is being clicked (click & hold):
					imgui.BeginTooltip()
					-- This function configures the wrapping inside the toolbox and thereby its width
					imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
					imgui.TextUnformatted("The APU start can be postponed to comply with environmental regulations until the before start clearance procedure. Without this option it's done during the Preliminary Cockpit Preparation.")
					imgui.PopStyleColor()
					-- Reset the wrapping, this must always be done if you used PushTextWrapPos
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end


				if changed then
					if newVal then DelaysAPU = 1 GUI_DelaysAPU = true
					display_bubble("I will delay the APU start.")
				else DelaysAPU = 0 GUI_DelaysAPU = false
					display_bubble("I will start the APU as per FCOM.")
				 end
				end
				--
				local changed, newVal = imgui.Checkbox("The PM configures a PACKS-OFF takeoff (not persistent).", GUI_PacksOff1and2)
				if imgui.IsItemActive() then
					-- We can create a tooltip that is shown while the item is being clicked (click & hold):
					imgui.BeginTooltip()
					-- This function configures the wrapping inside the toolbox and thereby its width
					imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
					imgui.TextUnformatted("The PM shuts OFF both packs at line-up unless APU BLEED is available at this point. This option is not saved for a later flight. It must be selected in the options each time you want it.")
					imgui.TextUnformatted("It's part of the Before Takeoff procedure for the PM to put the PACKS 1+2 as required. Consider selecting packs OFF, or APU bleed ON. This will improve performance when using TOGA thrust. In case of a FLEX takeoff, selecting packs OFF or APU bleed ON will reduce takeoff EGT, and thus reduce maintenance costs. Use of APU bleed is not authorized, if wing anti-ice is to be used.")
					imgui.TextUnformatted("This option is always defaulted to 'inactive'.")
					imgui.PopStyleColor()
					-- Reset the wrapping, this must always be done if you used PushTextWrapPos
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
				if changed then
					if newVal then PacksOff1and2 = 1 GUI_PacksOff1and2 = true message_time=math.floor(os.clock()) + 20
						play_sound(Checked_sound)
						function Message() message_done = 0 big_bubble(MOUSE_X, 40, "TAKE OFF WITH PACKS 1 + 2 OFF    " .. PacksOff1and2, "It's part of the Before Takeoff procedure for the PM to put the PACKS 1+2 as required.","","Consider selecting packs OFF, or APU bleed ON. This will improve performance when using TOGA thrust.",
			"In case of a FLEX takeoff, selecting packs OFF or APU bleed ON will reduce takeoff EGT, and thus reduce maintenance costs.",
			"Use of APU bleed is not authorized, if wing anti-ice is to be used.") end
					else PacksOff1and2 = 0 GUI_PacksOff1and2 = false  message_time=math.floor(os.clock()) - 10
						function Message() message_done = 0 big_bubble(MOUSE_X, 40, "TAKE OFF WITH PACKS 1 + 2 OFF    " .. PacksOff1and2, "It's part of the Before Takeoff procedure for the PM to put the PACKS 1+2 as required.") end
					end
				end
				--
				local changed, newVal = imgui.Checkbox("The PM starts the APU after landing.", GUI_AfterLandingWithAPU)
				if imgui.IsItemActive() then
					-- We can create a tooltip that is shown while the item is being clicked (click & hold):
					imgui.BeginTooltip()
					-- This function configures the wrapping inside the toolbox and thereby its width
					imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
					imgui.TextUnformatted("This setting will record that the Pilot Monitoring will start the APU during the After Landing flow.")
					imgui.PopStyleColor()
					-- Reset the wrapping, this must always be done if you used PushTextWrapPos
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
				if changed then
					if newVal then AfterLandingWithAPU = 1 GUI_AfterLandingWithAPU = true
						display_bubble("I will set the APU ON after landing.")
					else AfterLandingWithAPU = 0 GUI_AfterLandingWithAPU = false
						display_bubble("I will NOT set APU after landing.")
					end
				end
				--
				local changed, newVal = imgui.Checkbox("The PM releases PARK BRK if chocks in place.", GUI_Park_is_PNF)
				if imgui.IsItemActive() then
					-- We can create a tooltip that is shown while the item is being clicked (click & hold):
					imgui.BeginTooltip()
					-- This function configures the wrapping inside the toolbox and thereby its width
					imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
					imgui.TextUnformatted("Usually when chocks are in place, parking brake is released (FCOM). However, this is inactive by default because X-Plane plugins like AutoGate jetways will stay attached to the aircraft only if the parking brake is kept set.")
					imgui.PopStyleColor()
					-- Reset the wrapping, this must always be done if you used PushTextWrapPos
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
				if changed then
					if newVal then Park_is_PNF = 1 GUI_Park_is_PNF = true
					message_time=math.floor(os.clock())  -- used by function AutoClear
					function Message() message_done = 0 big_bubble( MOUSE_X, 40, "The FO will release the brakes.","Usually when chocks are in place, parking brake is released (FCOM 3.03.25).","However third-parties jetways will stay attached to the aircraft only if the parking brake is kept set.") end
				else Park_is_PNF = 0 GUI_Park_is_PNF = false
					message_time=math.floor(os.clock())  -- used by function AutoClear
					function Message() message_done = 0 big_bubble( MOUSE_X, 40, "Maintain bra60,64kes and gate equipment","Usually when chocks are in place, parking brake is released (FCOM 3.03.25).","However third-parties jetways will stay attached to the aircraft only if the parking brake is kept set.","DEACTIVATE is default.") end
				 end
				end
				--
				local changed, newVal = imgui.Checkbox("The PM calls 'rotate'.", GUI_Say_Rotate)
				if imgui.IsItemActive() then
					-- We can create a tooltip that is shown while the item is being clicked (click & hold):
					imgui.BeginTooltip()
					-- This function configures the wrapping inside the toolbox and thereby its width
					imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
					imgui.TextUnformatted("The PM calls 'ROTATE' at VR as set in the MCDU.")
					imgui.PopStyleColor()
					-- Reset the wrapping, this must always be done if you used PushTextWrapPos
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
				if changed then
					if newVal then Say_Rotate = 1 GUI_Say_Rotate = true  else Say_Rotate = 0 GUI_Say_Rotate = false end
				end
				--
				imgui.SameLine()
				local changed, newVal = imgui.Checkbox("The PM calls 'minimums'.", GUI_Say_Mins)
				if imgui.IsItemActive() then
					-- We can create a tooltip that is shown while the item is being clicked (click & hold):
					imgui.BeginTooltip()
					-- This function configures the wrapping inside the toolbox and thereby its width
					imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
					imgui.TextUnformatted("The PM calls 'MINIMUMS' at the barometric altitude or at the radio height set on the MCDU for the landing decision.")
					imgui.PopStyleColor()
					-- Reset the wrapping, this must always be done if you used PushTextWrapPos
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
				if changed then
					if newVal then Say_Mins = 1 GUI_Say_Mins = true  else Say_Mins = 0 GUI_Say_Mins = false end
				end


				--

				local changed, newVal = imgui.Checkbox("The PM keeps the first officer FD synchronized.", GUI_TL_synchronizedFD)
				if imgui.IsItemActive() then
					-- We can create a tooltip that is shown while the item is being clicked (click & hold):
					imgui.BeginTooltip()
					-- This function configures the wrapping inside the toolbox and thereby its width
					imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
					imgui.TextUnformatted("The PM keeps the right hand side flight director in sync with the state of the left hand side one. Therefore, when activated you can easily erase all the FMA upon final approach.")
					imgui.PopStyleColor()
					-- Reset the wrapping, this must always be done if you used PushTextWrapPos
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
				if changed then
					if newVal then TL_synchronizedFD = "activate" GUI_TL_synchronizedFD = true  else TL_synchronizedFD = "deactivate" GUI_TL_synchronizedFD = false end
					if TL_synchronizedFD == "deactivate" then
						message_time=math.floor(os.clock())  -- used by function AutoClear
						function Message()
						 message_done = 0 -- used by function AutoClear
						 big_bubble( MOUSE_X+10, MOUSE_Y+20, "WARNING, it's not good !","Keep both flight directors synchronized now.")
						 command_once("AirbusFBW/CheckCabin") -- alerts ! ding !
						end
					else
						message_time=math.floor(os.clock())  -- used by function AutoClear
						function Message()
						 message_done = 0 -- used by function AutoClear
						 big_bubble( MOUSE_X+10, 20, "FD in sync. ","I feel better")
						end
					end
				end
				--
				local changed, newVal = imgui.Checkbox("Low pressure air requested when on stand.", GUI_Pre_Conditioned_Air_Unit)
				if imgui.IsItemActive() then
					-- We can create a tooltip that is shown while the item is being clicked (click & hold):
					imgui.BeginTooltip()
					-- This function configures the wrapping inside the toolbox and thereby its width
					imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
					imgui.TextUnformatted("You can request a pre-conditionned air unit. Normally you coordinate via interphone so as to not have both the Packs and LP air providing the mixer unit simultaneously.")
					imgui.PopStyleColor()
					-- Reset the wrapping, this must always be done if you used PushTextWrapPos
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
				if changed then
					if newVal then Pre_Conditioned_Air_Unit = 1 GUI_Pre_Conditioned_Air_Unit = true
						display_bubble("Low pressure air requested when on stand.")
					else Pre_Conditioned_Air_Unit = 0 GUI_Pre_Conditioned_Air_Unit = false
						display_bubble("No air cart on stand.")
					end
				end
				--
				local changed, newVal = imgui.Checkbox("The PM minimises landing lights usage.", GUI_LandingLights)
				if imgui.IsItemActive() then
					-- We can create a tooltip that is shown while the item is being clicked (click & hold):
					imgui.BeginTooltip()
					-- This function configures the wrapping inside the toolbox and thereby its width
					imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
					imgui.TextUnformatted("If the PM minimises landing lights usage, landing lights will be retracted early in climb after flaps retraction. Otherwise, landing lights will always be ON below FL100.")
					imgui.PopStyleColor()
					-- Reset the wrapping, this must always be done if you used PushTextWrapPos
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
				if changed then
					if newVal then GUI_LandingLights = newVal else GUI_LandingLights = newVal end
				end
				--


				local changed, newVal = imgui.Checkbox("The PM reduces flood lighting for critical phases.", GUI_DeckLights)
				if imgui.IsItemActive() then
					-- We can create a tooltip that is shown while the item is being clicked (click & hold):
					imgui.BeginTooltip()
					-- This function configures the wrapping inside the toolbox and thereby its width
					imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
					imgui.TextUnformatted("The PM reduces the flight deck luminosity during runway line up and final approach.")
					imgui.PopStyleColor()
					-- Reset the wrapping, this must always be done if you used PushTextWrapPos
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
				if changed then
					if newVal then GUI_DeckLights = newVal  else GUI_DeckLights = newVal end
				end
				--
				--[[
				local changed, newVal = imgui.Checkbox("High altitude landing", GUI_HighAlt) imgui.SameLine() imgui.TextUnformatted(" (change not persistent).")
				if changed then
					if newVal then  maximumGearAltitude = 1220 ApproachActiveRadioAltitude = 2400  GUI_HighAlt = true  else maximumGearAltitude = 640 ApproachActiveRadioAltitude = 1830 GUI_HighAlt = false end
				end
				]] -- removed in April 2021
				--
				if PLANE_ICAO ~= "A346" then
					local changed, newVal = imgui.Checkbox(" PRO-SUP-93-20 : One Engine Taxi departure", GUI_OET)
					if imgui.IsItemActive() then
						-- We can create a tooltip that is shown while the item is being clicked (click & hold):
						imgui.BeginTooltip()
						-- This function configures the wrapping inside the toolbox and thereby its width
						imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
						imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
						imgui.TextUnformatted("When active, start one engine as usual. The PM will offer you to start the second engine later, while handling the yellow elec hyd pump and crossbleed air.")
						imgui.PopStyleColor()
						-- Reset the wrapping, this must always be done if you used PushTextWrapPos
						imgui.PopTextWrapPos()
						imgui.EndTooltip()
					end
					imgui.SameLine() imgui.TextUnformatted(" (not persistent).")
					if changed then
						if newVal then  single_engine_taxi = 1  GUI_OET = true  else single_engine_taxi = 0 GUI_OET = false end
					end
				end


				--
				-- Radio Buttons




				if imgui.TreeNode("...") then

					local changed, newVal = imgui.Checkbox("The PM also handles the landing lights on line-up.", transfer_exterior_lights_to_the_PM_on_ground)
					if imgui.IsItemActive() then
						-- We can create a tooltip that is shown while the item is being clicked (click & hold):
						imgui.BeginTooltip()
						-- This function configures the wrapping inside the toolbox and thereby its width
						imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
						imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
						imgui.TextUnformatted("In 2021 Airbus has moved the exterior lights for line-up to a PF item. You can still ask the PM to do it.")
						imgui.PopStyleColor()
						-- Reset the wrapping, this must always be done if you used PushTextWrapPos
						imgui.PopTextWrapPos()
						imgui.EndTooltip()
					end
					if changed then
						if newVal then transfer_exterior_lights_to_the_PM_on_ground = newVal else transfer_exterior_lights_to_the_PM_on_ground = newVal end
					end
					--
					--imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
					local changed, newVal = imgui.Checkbox("The PM resets VHF frequencies during the cockpit preparation.", GUI_FoTunesRadiosInPreparationFlow)
					if imgui.IsItemActive() then
						-- We can create a tooltip that is shown while the item is being clicked (click & hold):
						imgui.BeginTooltip()
						-- This function configures the wrapping inside the toolbox and thereby its width
						imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
						imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
						imgui.TextUnformatted("The PM sets VHF1 and VHF2 active frequencies to " .. presetFrequency .. " hz during the cockpit preparation flow. You can write your favourite frequency in a text editor, line 30 of the script.")
						imgui.PopStyleColor()
						-- Reset the wrapping, this must always be done if you used PushTextWrapPos
						imgui.PopTextWrapPos()
						imgui.EndTooltip()
					end
					if changed then
						if newVal then FoTunesRadiosInPreparationFlow = 1 GUI_FoTunesRadiosInPreparationFlow = true
								message_time=math.floor(os.clock())  -- used by function AutoClear
						function Message() message_done = 0 big_bubble( MOUSE_X, 40, "I'll set VHF1 and VHF2 active frequencies to 122.800" ," (or the preset frequency) during the cockpit preparation flow.") end
						else FoTunesRadiosInPreparationFlow = 0 GUI_FoTunesRadiosInPreparationFlow = false
							display_bubble("I wont touch the active frequency.")
						 end
					end
					--
					--imgui.PopStyleColor()
					if JAR_Ground_Handling_wanted == 1 then
						imgui.Checkbox("",GUI_JAR_Ground_Handling_wanted)
						imgui.SameLine()
						imgui.TextUnformatted("Service at door 1L: ")
						imgui.SameLine()
						if imgui.RadioButton("Stairs", GUI_forward_stairs_Yes) then
							if JAR_Ground_Handling_wanted == 1 and (beforestartproc_trigger == 0 or  afterlandingproc_trigger == 3) then GHDforwardStairs = 1 GHDpassengersBus = 1 end
							forward_JARstairs_wanted = 1 GUI_forward_stairs_Yes = true GUI_forward_stairs_No = false
						end
						if imgui.IsItemActive() then
							-- We can create a tooltip that is shown while the item is being clicked (click & hold):
							imgui.BeginTooltip()
							-- This function configures the wrapping inside the toolbox and thereby its width
							imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
							imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
							imgui.TextUnformatted("If a jetway is attached to the 1L door and you use GHD, GHD stairs can be removed.")
							imgui.PopStyleColor()
							-- Reset the wrapping, this must always be done if you used PushTextWrapPos
							imgui.PopTextWrapPos()
							imgui.EndTooltip()
						end
						imgui.SameLine()
						if imgui.RadioButton("JetwaChecklistAirbus.jpgy", GUI_forward_stairs_No) then
							-- immediate change if applicable (only)
							if JAR_Ground_Handling_wanted == 1 and (beforestartproc_trigger == 0 or  afterlandingproc_trigger == 3) then GHDforwardStairs = 0 GHDpassengersBus = 0 end
							-- anticipated action
							forward_JARstairs_wanted = 0 GUI_forward_stairs_Yes = false GUI_forward_stairs_No = true
						end
						imgui.SetWindowFontScale(1) imgui.SameLine() imgui.TextUnformatted(" ") imgui.SameLine() if  imgui.Button("Hide to reset",120,22)  then command_once("jd/ghd/show_panel") end imgui.SetWindowFontScale(1.5)
					--~ else
						--~ imgui.TextUnformatted("Service at door 1L: please activate GHD option below.")
					end
					imgui.TreePop()
				end


				--imgui.SameLine() imgui.TextUnformatted(".")

						--
				imgui.TextUnformatted(" ")
				imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
				imgui.Bullet() imgui.TextUnformatted("Noise abatement heights - advisory")
				imgui.PopStyleColor()
				if TL_thrust_reduction_altitude == 800 and TL_Accel_Altitude == 3000 then imgui.SameLine() imgui.TextUnformatted(" NADP1")
				end
				if TL_thrust_reduction_altitude == 800 and TL_Accel_Altitude == 800 then imgui.SameLine() imgui.TextUnformatted(" NADP2")
				end
				imgui.TextUnformatted("   Thrust reduction ")

				imgui.SameLine()
				if imgui.Button("<",30,25) then
					if TL_thrust_reduction_altitude == 1000 then
						TL_thrust_reduction_altitude = 800
					elseif TL_thrust_reduction_altitude == 1500 then
						TL_thrust_reduction_altitude = 1000
					end
				end
				imgui.SameLine() if TL_thrust_reduction_altitude < 1000 then  imgui.TextUnformatted("") imgui.SameLine() end imgui.TextUnformatted(TL_thrust_reduction_altitude)

				imgui.SameLine()
				if imgui.Button(">",30,25) then
					if TL_thrust_reduction_altitude == 800 then
						TL_thrust_reduction_altitude = 1000
					elseif TL_thrust_reduction_altitude == 1000 then
						TL_thrust_reduction_altitude = 1500
					end
				end
				imgui.SameLine()
				imgui.TextUnformatted("ft AGL.  Accel")
				imgui.SameLine()
				if imgui.Button(" < ",30,25) then
					if TL_Accel_Altitude == 1000 then
						TL_Accel_Altitude = 800
					elseif TL_Accel_Altitude == 1500 then
						TL_Accel_Altitude = 1000
					elseif TL_Accel_Altitude == 3000 then
						TL_Accel_Altitude = 1500
					end
				end
				imgui.SameLine() imgui.TextUnformatted(TL_Accel_Altitude)
				imgui.SameLine()
				if imgui.Button(" > ",30,25) then
					if TL_Accel_Altitude == 800 then
						TL_Accel_Altitude = 1000
					elseif TL_Accel_Altitude == 1000 then
						TL_Accel_Altitude = 1500
					elseif TL_Accel_Altitude == 1500 then
						TL_Accel_Altitude = 3000
					end
				end
				imgui.SameLine()
				imgui.TextUnformatted("ft AGL.")

				if TL_Accel_Altitude < TL_thrust_reduction_altitude then
					--imgui.SameLine()
					-- imgui.TextUnformatted("   ** Check that THR RED is less than or equal to ACCEL. **")
					imgui.SameLine()
					imgui.TextUnformatted("No!")
					TL_thrust_reduction_altitude = TL_Accel_Altitude
				end
				--
				--imgui.Bullet() imgui.TextUnformatted("Sound options")
				if TL_LegacyGUI == "deactivate" then
					if imgui.TreeNode("Help on NADP") then
						imgui.Columns(3)
						imgui.SetColumnWidth(0, 150)
						imgui.TextUnformatted("....................................")
						imgui.TextUnformatted(" ")
						imgui.TextUnformatted("....................................")
						imgui.TextUnformatted(">= 800 ft AGL")
						imgui.TextUnformatted(" ")
						imgui.TextUnformatted("....................................")
						imgui.TextUnformatted("at 3000 ft AGL")
						imgui.TextUnformatted("....................................")
						imgui.NextColumn()
						imgui.TextUnformatted("....................................")
						imgui.TextUnformatted(" NADP1")
						imgui.TextUnformatted("....................................")
						imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF8080FF) imgui.TextUnformatted("REDUCE to CLIMB thrust") imgui.PopStyleColor()
						imgui.TextUnformatted("Keep V2+10 and T.O. conf.")
						imgui.TextUnformatted("....................................")
						imgui.PushStyleColor(imgui.constant.Col.Text,  0xFFD280FF) imgui.TextUnformatted("ACCELERATE to flaps-up") imgui.PopStyleColor()
						imgui.TextUnformatted("....................................")
						imgui.NextColumn()
						imgui.TextUnformatted("....................................")
						imgui.TextUnformatted(" NADP2")
						imgui.TextUnformatted("....................................")
						imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF8080FF) imgui.TextUnformatted("REDUCE to CLIMB thrust") imgui.PopStyleColor()
						imgui.PushStyleColor(imgui.constant.Col.Text,  0xFFD280FF) imgui.TextUnformatted("ACCELERATE and retract flaps") imgui.PopStyleColor()
						imgui.TextUnformatted("....................................")
						imgui.TextUnformatted("Accelerate to climb speed")
						imgui.TextUnformatted("....................................")
						imgui.NextColumn()
						imgui.Columns(1)
						--imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/NADPs.jpg"), 650, 187)
						-- ####################################################
						-- ADVISORY ALTITUDES RED AND ACC
						-- ####################################################
					   -- if altitudeAGL < AGL_onGround and Red_AltitudeBaro_fromMCDU > 799 and TL_Accel_AltitudeBaro_fromMCDU > 799 then
					   --         imgui.TextUnformatted("Advisory barometric altitudes (assuming correct QNH set).")
					   --                          imgui.TextUnformatted("REDUCE AT ")
					   --         imgui.SameLine() imgui.TextUnformatted(Red_AltitudeBaro)
					   --         imgui.SameLine() imgui.TextUnformatted(" ft, ACCELERATE AT ")
					   --         imgui.SameLine() imgui.TextUnformatted(TL_Accel_AltitudeBaro)
					   --         imgui.SameLine() imgui.TextUnformatted(" ft.")
						-- ####################################################
						-- ACTUAL FMGS ALTITUDES RED AND ACC
						-- ####################################################
							--imgui.TextUnformatted("Current : ")
							--imgui.SameLine() imgui.TextUnformatted(Red_AltitudeBaro_fromMCDU+0)
							--imgui.SameLine() imgui.TextUnformatted(TL_Accel_AltitudeBaro_fromMCDU+0)
					   -- end

						-- "THR RED/ACC : " .. Red_AltitudeBaro .. " / " .. TL_Accel_AltitudeBaro .. " ft"
						imgui.TreePop()
					end
				end

				--
				--~ imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/separator_bar.png"), 675, 7) --if TL_LegacyGUI == "deactivate" then imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/separator_bar.png"), 675, 7) end

				imgui.TextUnformatted(" ")

				imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
				imgui.Bullet() imgui.TextUnformatted("General options")
				imgui.PopStyleColor()
				--imgui.TextUnformatted(" ")

				--
				--imgui.TextUnformatted("    Display ")
				--imgui.SameLine()
				local changed, newVal = imgui.Checkbox("Display normal messages ", GUI_normal_messages)
					if changed then
					if newVal then normal_messages = 1 GUI_normal_messages = true
						display_bubble("Progress messages activated.")
					else normal_messages = 0 GUI_normal_messages = false

						message_time=math.floor(os.clock()) - 5
						function Message() message_done = 0
						end
					end
				end
				--
				imgui.SameLine()
				local changed, newVal = imgui.Checkbox(" important messages ", GUI_messages_in_circle_and_all_messages)
					if changed then
					if newVal then GUI_messages_in_circle_and_all_messages = true
					normal_messages = 1 GUI_normal_messages = true
					else GUI_messages_in_circle_and_all_messages = false normal_messages = 0 GUI_normal_messages = false
					end
				end
				--
				imgui.SameLine()

				local changed, newVal = imgui.Checkbox(" VR popups", GUI_VR_message)
					if imgui.IsItemActive() then
						-- We can create a tooltip that is shown while the item is being clicked (click & hold):
						imgui.BeginTooltip()
						-- This function configures the wrapping inside the toolbox and thereby its width
						imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
						imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
						imgui.TextUnformatted("This will change the behavior of the Speedy Copilot bottom bar for a better Virtual Reality.  A new way to sequence the procedures is offered in the bottom bar, via button, as on-screen action are not visible in VR.")
						imgui.PopStyleColor()
						-- Reset the wrapping, this must always be done if you used PushTextWrapPos
						imgui.PopTextWrapPos()
						imgui.EndTooltip()
					end
					if changed then
					if newVal then GUI_VR_message = true VR_message = 1
					else GUI_VR_message = false VR_message = 0
					end
				end

				--imgui.SameLine()
				--imgui.TextUnformatted(" messages.")
				--
				local changed, newVal = imgui.Checkbox("Check the yaw axis during flight controls check.", GUI_Check_yaw)
					if imgui.IsItemActive() then
						-- We can create a tooltip that is shown while the item is being clicked (click & hold):
						imgui.BeginTooltip()
						-- This function configures the wrapping inside the toolbox and thereby its width
						imgui.PushTextWrapPos(imgui.GetFontSize() * 30)
						imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
						imgui.TextUnformatted("To start the FCTL CHECK sequence, slightly move the stick, then follow the below routine (at a slow pace, but ensuring you reach full deflection each time), with a 1 sec pause between each movement :")
						imgui.TextUnformatted("1-FULL UP (stick full aft), FULL DOWN,NEUTRAL (Stick released)")
						imgui.TextUnformatted("2-FULL LEFT, FULL RIGHT, NEUTRAL")
						imgui.TextUnformatted("3-After depressing and maintaining presses the Rudder Disc Button which is located in the center of the tiller, select FULL LEFT (Rudder pedal Full left), FULL RIGHT, NEUTRAL. Then you may release the Rudder Disc")
						imgui.TextUnformatted("4- The F/O is then supposed to do the same check silently (side stick only)")
						imgui.TextUnformatted("Here, you have an option to disable the rudder FCTL CHECK (only the rudder check) for those not equipped with rudder.")
						imgui.PopStyleColor()
						-- Reset the wrapping, this must always be done if you used PushTextWrapPos
						imgui.PopTextWrapPos()
						imgui.EndTooltip()
					end
					if changed then
					if newVal then Check_yaw = 1 GUI_Check_yaw = true
						display_bubble("Yaw axis is monitored during flight controls check.")
					else Check_yaw = 0 GUI_Check_yaw = false
						display_bubble("Yaw axis is skipped.")
					end
				end
				--
				local changed, newVal = imgui.Checkbox("Activate \"Quick Glance\" as before takeoff trigger.", GUI_QuickGlance)
				if imgui.IsItemActive() then
					-- We can create a tooltip that is shown while the item is being clicked (click & hold):
					imgui.BeginTooltip()
					-- This function configures the wrapping inside the toolbox and thereby its width
					imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
					imgui.TextUnformatted("When active, looking towards the approach path and runway area (or turn a landing light on) signals the PM to begin the line-up flow. Otherwise only the landing light can signal.")
					imgui.PopStyleColor()
					-- Reset the wrapping, this must always be done if you used PushTextWrapPos
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
				if changed then
					if newVal then QuickGlance = 1 GUI_QuickGlance = true
						display_bubble("Please glance at port and starboard for line-up.")
					 else QuickGlance = 0 GUI_QuickGlance = false
						display_bubble("Legacy trigger is Landing lights ON.")
					 end
				end
				--

				local changed, newVal = imgui.Checkbox("Use JARdesign Ground Handling Deluxe 4.", GUI_JAR_Ground_Handling_wanted)
				if imgui.IsItemActive() then
					-- We can create a tooltip that is shown while the item is being clicked (click & hold):
					imgui.BeginTooltip()
					-- This function configures the wrapping inside the toolbox and thereby its width
					imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
					imgui.TextUnformatted("You will be serviced by the GHD airstairs and by service vehicles if you have Ground Handling Deluxe version 4 or above.")
					imgui.PopStyleColor()
					-- Reset the wrapping, this must always be done if you used PushTextWrapPos
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
				if changed then
					if newVal then JAR_Ground_Handling_wanted = 1 GUI_JAR_Ground_Handling_wanted = true
						DatarefJARLoad()
					else JAR_Ground_Handling_wanted = 0
						GUI_JAR_Ground_Handling_wanted = false
						GHDexecute = 0
						GHD_by_DATAREF = 0
					end
				end
				-- l_bratch user suggestion and code, January 2023
				-- https://forums.x-plane.org/index.php?/files/file/54069-speedy-copilot-for-toliss/&do=findComment&comment=375136
				local changed, newVal = imgui.Checkbox("Go to the cabin with action on the cockpit door locking switch.", GUI_Cabin_on_unlock)		-- l_bratch user suggestion and code, January 2023
				if imgui.IsItemActive() then																						-- l_bratch user suggestion and code, January 2023
					-- We can create a tooltip that is shown while the item is being clicked (click & hold):						-- l_bratch user suggestion and code, January 2023
					imgui.BeginTooltip()																							-- l_bratch user suggestion and code, January 2023
					-- This function configures the wrapping inside the toolbox and thereby its width								-- l_bratch user suggestion and code, January 2023
					imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
					imgui.TextUnformatted("Move the camera to the cabin while using the cockpit door locking switch. Cockpit Door Locking System (CDLS) has the toggle switch located in the center pedestal's Cockpit Door panel.")
					imgui.PopStyleColor()
					-- Reset the wrapping, this must always be done if you used PushTextWrapPos
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
				if changed then
					if newVal then Cabin_on_unlock = 1
						GUI_Cabin_on_unlock = true
					else Cabin_on_unlock = 0																						-- l_bratch user suggestion and code, January 2023
						GUI_Cabin_on_unlock = false																					-- l_bratch user suggestion and code, January 2023
					end																												-- l_bratch user suggestion and code, January 2023
				end
				imgui.SameLine() imgui.SetWindowFontScale(1)
				if imgui.Button("Cabin",80,22) then command_once("toliss_airbus/3d_cockpit_commands/engine_observer") app_is_active = false if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end  end
				imgui.SetWindowFontScale(1.3)																										-- l_bratch user suggestion and code, January 2023
				local changed, newVal = imgui.Checkbox("Transponder OFF during taxi (old online network rule).", GUI_OnlineSQK)
				if imgui.IsItemActive() then
					-- We can create a tooltip that is shown while the item is being clicked (click & hold):
					imgui.BeginTooltip()
					-- This function configures the wrapping inside the toolbox and thereby its width
					imgui.PushTextWrapPos(imgui.GetFontSize() * 20)
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFF01CCDD)
					imgui.TextUnformatted("With this option the transponder will be kept OFF at all times when taxiing on the ground as it used to be ruled in the past by IVAO. When this option is not selected, transponder is ON as required in real life on modern airports from push-back until parking procedure..")
					imgui.PopStyleColor()
					-- Reset the wrapping, this must always be done if you used PushTextWrapPos
					imgui.PopTextWrapPos()
					imgui.EndTooltip()
				end
				if changed then
					if newVal then Online_transponder = 1 GUI_OnlineSQK = true
					 else Online_transponder = 0 GUI_OnlineSQK = false
					 end
				end
				imgui.SameLine() imgui.SetWindowFontScale(1)
				--~ if imgui.Button("Stand-by !",100,22) then XPonDr = 0 Online_transponder = 1 GUI_OnlineSQK = true app_is_active = false if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end  end
				if imgui.Button("Stand-by now !",120,22) then XPonDr = 0  app_is_active = false if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end  end
				imgui.SetWindowFontScale(1.3)
				--
				--
				--~ imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/separator_bar.png"), 675, 7) --if TL_LegacyGUI == "deactivate" then imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/separator_sc.png"), 675, 18) end
				imgui.TextUnformatted(" ")
				--imgui.Bullet() imgui.TextUnformatted("Sound options")

				imgui.PushStyleColor(imgui.constant.Col.Text,  user_color)
				if imgui.TreeNode("Sound options") then
					imgui.PushStyleColor(imgui.constant.Col.Text,  0xFFFFFFFF)
					--From MAIN :
					--SoundLevel = 1
					--PassengerLevel = 0.08

					if imgui.Button("Enforce radio vol. to 1.",220,26) and SoundLevel <= 0.9 then set("sim/operation/sound/radio_volume_ratio",1)  end imgui.SameLine()
					if imgui.Button("First Officer (".. SoundLevel .. ") ",210,26) then SoundLevel = 1 end imgui.SameLine()
					if imgui.Button("FO+",50,26) and SoundLevel <= 0.9 then SoundLevel = SoundLevel + 0.1 end imgui.SameLine()
					if imgui.Button("FO-",50,26) and SoundLevel > 0.2 then SoundLevel = SoundLevel - 0.1 end imgui.SameLine()
					if imgui.Button("Test",70,26) then play_sound(Minimums_sound) play_sound(TOmemo_sound) play_sound(seventyknots_sound) play_sound(LOCBlue_sound)  play_sound(CabinReady_sound)  end
					local changed, newVal = imgui.Checkbox("Mute cabin related sounds (not persistent). " .. PALevel, GUI_MuteCabinRelatedSounds)
					if changed then
						if newVal then MuteCabinRelatedSounds = 1 GUI_MuteCabinRelatedSounds = true
						 else MuteCabinRelatedSounds = 0 GUI_MuteCabinRelatedSounds = false
						 end
					end

					local changed, newVal = imgui.Checkbox("Aircraft is an A321 or an A340-600 freighter.", GUI_AircraftIsP2F)


					if changed then
						display_bubble("Automatic at startup","Speedy Copilot for ToLiSS looks for occurences of the string 'P2F' or 'freighter' in this aircraft path inside the simulator folders. It it finds it, then this must be a freighter. You can change that here.")
						if newVal then MuteCabinRelatedSounds = 1 GUI_MuteCabinRelatedSounds = true GUI_AircraftIsP2F = true AircraftIsP2F = 1
						 else MuteCabinRelatedSounds = 0 GUI_MuteCabinRelatedSounds = false GUI_AircraftIsP2F = false AircraftIsP2F = 0
						 end
					end
					imgui.TextUnformatted("Speedy Copilot for ToLiSS looks for the word 'P2F', 'freighter' or 'cargo'")
					imgui.TextUnformatted("in this aircraft name to determine if it is a freighter.")
					imgui.TextUnformatted("")
					imgui.TextUnformatted("The cabin interphone (to hear the cabin ready report for instance) and")
					imgui.TextUnformatted("the service interphone (to speak with the mechanics on the ground) are")
					imgui.TextUnformatted("audible with the CAB and INT reception knobs OUT on the audio control")
					imgui.TextUnformatted("panel (ACP).")
					imgui.PopStyleColor()
					imgui.TreePop()
				end
				imgui.PopStyleColor()
				imgui.PopStyleColor()

				--~ imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/separator_bar.png"), 675, 7) --if TL_LegacyGUI == "deactivate" then imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/separator_sc.png"), 675, 18) end
				--


				--imgui.TextUnformatted(" ")
				--imgui.Bullet() imgui.TextUnformatted("Sound options")


				--imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/separator_bar.png"), 675, 7) --if TL_LegacyGUI == "deactivate" then imgui.Image(float_wnd_load_image(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/Pictures/separator_sc.png"), 675, 18) end
				--

				imgui.TextUnformatted(" ")
				-- start a chrono to autoclose the menu if open since more than 2 minutes to avoid perf degradation

				if imgui.Button("Save and apply",220,32) or current_time >= MenuOpening_time + MenuClosingDelay then
					ToLiss_A319_WriteSaveToDisk() -- write to persistent options
					display_bubble("Options were saved.")
					app_is_active = false
					if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end
				end
				imgui.SameLine()
				if imgui.Button("ISCS",60,32) then
					ToLiss_A319_WriteSaveToDisk() -- write to persistent options
					display_bubble("Options were saved as seen.")
					app_is_active = false
					if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end

					command_once("toliss_airbus/iscs_open")
				end imgui.SameLine()


				imgui.TextUnformatted('[' .. Current_title .. ']')
				if current_time >= MenuOpening_time + MenuClosingDelay - 30 then
					imgui.SameLine()
					imgui.TextUnformatted('[' .. MenuClosingDelay -(current_time - MenuOpening_time)  .. ' A/Save]')
				end
			end -- ends option_menu

			function closed_OPTION_WINDOW()
				the_option_window_displayed = false
			end

			--~ if TL_LegacyGUI == "activate" then
				--~ create_command("Speedy_Copilot/Options/Menu", "Show the option menu", "FF_FWL_MenuCall = true 		        MenuOpening_time=math.floor(os.clock())", "", "")
			--~ else
				--~ create_command("Speedy_Copilot/Options/Menu", "Show the option menu", "loadOptions = true 	        MenuOpening_time=math.floor(os.clock())", "", "")
			--~ end

		end -- ends all_menus_definitions

		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		------------------------ END OF GUI -------------------------------------------------------------------------------------------------------------------------------------------
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




		function reset_VR_message_popup()
			if Message_wnd_content ~= "" and GUI_VR_message then
				if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end
				print("Killed Speedy Copilot for ToLiSS question")
			end
			Message_wnd_content = ""
			Vr_message_current_answer = "?"
			vr_message_sent = false
			end_show_time = 0
		end

		function SupplementaryInit()
			-- if ExtPowerConnected == 0 then ground_stuff = 0 preliminaryprocedure_trigger = 0 end -- carefully crafted trigger (only at first start)
			-- if ExtPowerConnected ~= 0 then ground_stuff = 13 preliminaryprocedure_trigger = 0 end -- carefully crafted trigger
			-- side effect : to have a full Lua reload, remove GPU first (debug)
			DU1 = 0.90
			DU2 = 0.90
			DU3 = 0.90
			DU4 = 0.85
			DU5 = 0.85
			DU6 = 0.85
			DU7 = 0.85
			DU8 = 0.85
		end

		-- test if the mod for slides have been installed by the user
		-- if, yes, we need to handle the emergency exit light
		slides_addon_installed = file_exists(AIRCRAFT_PATH .. "objects/Evac-Slide-NIT.png")

		function SupplementaryInit2()
			slides_addon_installed = file_exists(AIRCRAFT_PATH .. "objects/Evac-Slide-NIT.png")
			Current_title = "The New Speedy Copilot is ready"
			shutdownproc_trigger = 0
			beforestartproc_trigger = 0
			preliminaryprocedure_trigger = 0
			preflightproc_trigger = 0
			afterstartproc_trigger = 0
			beforetakeoff_trigger=0
			takeoffproc_trigger= 0
			approachproc_trigger = 0
			afterlandingproc_trigger = 0
			flapsretraction_trigger = 0
			PilotCheckedRight = false
			PilotCheckedLeft = false
			RunwayEntryFlag = false
			BrakeReleasedFlag = false
			GoAroundFlag = false
			-- ACP (A340) null
			VHF2 = 0
			Marker = 0
			--
			message_time=math.floor(os.clock()) + 30 -- used by function AutoClear
			function Message()
				message_done = 0 -- used by function AutoClear
				big_bubble( 50, 20, "The New Speedy Copilot for ToLiSS.", "Version " .. version_text_troiscentvingt .. ".","2021 Normal procedures and checklists")
			end
		end


		--########################################
		--# DATAREFS                             #
		--########################################
		-- dataref are readonly to read states of systems to trigger procedures
		-- commands are defined and named in custom.cfg in the A319 Connector
		function DatarefJARLoad()
			if XPLMFindDataRef("jd/ghd/execute") ~= nil then
				-- JAR Ground HANDLING Deluxe  GndHandling v.4.230618 T319
				dataref("GHDpowerCable","jd/ghd/select_00","writable")
				dataref("GHDChocks","jd/ghd/select_01","writable")
				dataref("GHDcateringFwd","jd/ghd/select_02","writable")
				dataref("GHDcateringAft","jd/ghd/select_03","writable")
				dataref("GHDfuelTank","jd/ghd/select_04","writable")
				dataref("GHDpassengersBus","jd/ghd/select_05","writable")
				GHDnoseConus =dataref_table("jd/ghd/select_06","writable")
				--dataref("GHDnoseConus","jd/ghd/select_06","writable")
				dataref("GHDloaderAft","jd/ghd/select_07","writable")
				dataref("GHDloaderFwd","jd/ghd/select_08","writable")
				dataref("GHDforwardStairs","jd/ghd/select_10","writable")
				dataref("GHDrearStairs","jd/ghd/select_09","writable")
				dataref("GHDexecute","jd/ghd/execute","writable")
				dataref("GHD_by_DATAREF","jd/ghd/drfcontrol","writable")

				-- dataref("GHDFireService","jd/ghd/select_11","writable")
				-- delocated, must be undenfinable

				-- 0 = GPU
				-- 1 = chocks
				-- 2  = catering avant
				-- 3 = catering arriere
				-- 4 = camion citerne
				-- 5 = bus Neoplan
				-- 6 = Cones (normalement)
				-- 7 = chargeur avant
				-- 8 = chargeur arriere
				-- 9 = escalier arriere
				-- 10 = escalier avant
				GHDexecute = 1
				GHD_by_DATAREF = 1
			else
				message_time=math.floor(os.clock()) - 60  -- used by function AutoClear
				function Message() message_done = 0 big_bubble( MOUSE_X-50, 20, "Ground Handling Deluxe 4 seems not installed.","See http://handling.jardesign.org") end
				JAR_Ground_Handling_wanted = 0
				GUI_JAR_Ground_Handling_wanted = false
				GHDexecute = 0
				GHD_by_DATAREF = 0
			end
		end

		function DatarefLoad()

			dataref("NoseTire","sim/operation/failures/rel_tire1","writable")
			dataref("LeftTire","sim/operation/failures/rel_tire2","writable")
			dataref("RightTire","sim/operation/failures/rel_tire3","writable")
			-- 6 to explode
			-- 0 to repair

			-- Toliss started to implement a chocks dataref in 2021, not all airplanes may have it
			if XPLMFindDataRef("AirbusFBW/Chocks") ~= nil then
				dataref("Toliss_chocks_set","AirbusFBW/Chocks","writable")
			end
			-- if my SGES not installed on the PC :
			if show_Chocks == nil then show_Chocks = true end -- safety for if else statements
			if Chocks_chg == nil then show_Chocks = true end  -- safety for if else statements


			dataref("MinimumsBaroAltitude","toliss_airbus/performance/MDA","readonly")

			dataref("AuralVolumeFO","AirbusFBW/AuralVolumeFO","writable")
			AuralVolumeFO = 1 -- set to 1 initially.
			--dataref("audio_com_selection","sim/cockpit2/radios/actuators/audio_com_selection","writable")
			-- all audio_com_selection items erased from the script on 2022 10 08
			if PaxDoor1L == nil then  dataref("PaxDoor1L","AirbusFBW/PaxDoorModeArray","writable",0) end -- possible confrontation with SGES plugin
			dataref("ServiceDoor1R","AirbusFBW/PaxDoorModeArray","writable",1)
			if (AIRCRAFT_FILENAME == "a321.acf" or AIRCRAFT_FILENAME == "a321_StdDef.acf" or AIRCRAFT_FILENAME == "a321_XP11.acf" or AIRCRAFT_FILENAME == "a321_XP11_StdDef") then
				print("FlyWithLua Info: Speedy Copilot : Rear left passengers door is set for an A321")
				if PaxDoorRearLeft == nil then dataref("PaxDoorRearLeft","AirbusFBW/PaxDoorModeArray","writable",6)
						print("FlyWithLua Info: Speedy Copilot PaxDoorRearLeft dataref is loaded from Speedy Copilot and not SGES !") end -- possible confrontation with SGES plugin
				dataref("ServiceDoor2R","AirbusFBW/PaxDoorModeArray","writable",7)
			elseif PLANE_ICAO == "A346" then
				print("FlyWithLua Info: Speedy Copilot : Rear left passengers door is set  for an A346")
				if PaxDoorRearLeft == nil then dataref("PaxDoorRearLeft","AirbusFBW/PaxDoorModeArray","writable",2)
						print("PaxDoorRearLeft dataref is loaded from Speedy Copilot and not SGES !") end -- possible confrontation with SGES plugin
				dataref("FlyWithLua Info: Speedy Copilot : ServiceDoor2R","AirbusFBW/PaxDoorModeArray","writable",7)
			else -- a319 is the else.
				print("FlyWithLua Info: Speedy CopilotRear left passengers door is set  for an A319")
				if PaxDoorRearLeft == nil then dataref("PaxDoorRearLeft","AirbusFBW/PaxDoorModeArray","writable",2)
						print("FlyWithLua Info: Speedy Copilot : PaxDoorRearLeft dataref is loaded from Speedy Copilot and not SGES !") end -- possible confrontation with SGES plugin
				dataref("ServiceDoor2R","AirbusFBW/PaxDoorModeArray","writable",3)
			end
			dataref("CargoDoor1","AirbusFBW/CargoDoorModeArray","writable",0)
			dataref("CargoDoor2","AirbusFBW/CargoDoorModeArray","writable",1)
			if (AIRCRAFT_FILENAME == "a321.acf" or AIRCRAFT_FILENAME == "a321_StdDef.acf" or AIRCRAFT_FILENAME == "a321_XP11.acf" or AIRCRAFT_FILENAME == "a321_XP11_StdDef" or PLANE_ICAO == "A346") then
				dataref("BulkDoor","AirbusFBW/CargoDoorModeArray","writable",2)
			end

			dataref("YElecPump","AirbusFBW/HydOHPArray","writable",3)
			dataref("XBleed","AirbusFBW/XBleedSwitch","writable")

			dataref("APUAvail","AirbusFBW/APUAvail","readonly")
			dataref("APUMasterSwitch","AirbusFBW/APUMaster","writable")
			dataref("APUFlapOpenRatio","AirbusFBW/APUFlapOpenRatio","readonly")
			dataref("APUStarterSwitch","AirbusFBW/APUStarter","writable")
			dataref("APU_Bleed_ON","AirbusFBW/APUBleedSwitch","writable")


			dataref("BaroUnitCapt","AirbusFBW/BaroUnitCapt","writable")
			dataref("BaroUnitFO","AirbusFBW/BaroUnitFO","writable")
			dataref("ALT100_1000","AirbusFBW/ALT100_1000","writable")
			dataref("ENGModeSwitch","AirbusFBW/ENGModeSwitch","writable")

			dataref("DU1","AirbusFBW/DUBrightness","writable",0)
			dataref("DU2","AirbusFBW/DUBrightness","writable",1)
			dataref("DU3","AirbusFBW/DUBrightness","writable",2)
			dataref("DU4","AirbusFBW/DUBrightness","writable",3)
			dataref("DU5","AirbusFBW/DUBrightness","writable",4)
			dataref("DU6","AirbusFBW/DUBrightness","writable",5)
			dataref("DU7","AirbusFBW/DUBrightness","writable",6)
			dataref("DU8","AirbusFBW/DUBrightness","writable",7)

			dataref("DomeLight","AirbusFBW/OHPLightSwitches","writable",8)
			dataref("FrontPanelFlood","AirbusFBW/PanelFloodBrightnessLevel","writable")
			dataref("PedestalPanelFlood","AirbusFBW/PedestalFloodBrightnessLevel","writable")
			dataref("XPonDr","AirbusFBW/XPDRPower","writable")
			dataref("XPDRTCASMode","AirbusFBW/XPDRTCASMode","writable")
			-- A340 : 0 STBY, 1 TA, 2 TARA



			dataref("FD1","AirbusFBW/FD1Engage","readonly")
			dataref("FD2","AirbusFBW/FD2Engage","readonly")
			dataref("IR1","AirbusFBW/ADIRUSwitchArray","writable",0)
			dataref("IR2","AirbusFBW/ADIRUSwitchArray","writable",1)
			dataref("IR3","AirbusFBW/ADIRUSwitchArray","writable",2)
			dataref("ADIRUTimeToAlign","AirbusFBW/TimeToAlign","readonly")

			dataref("BatOH1","AirbusFBW/ElecOHPArray","writable",5)
			dataref("BatOH2","AirbusFBW/ElecOHPArray","writable",6)

			dataref("pilots_head_x","sim/aircraft/view/acf_peX","readonly") -- negative when in the left seat.
			dataref("pilots_head_y","sim/aircraft/view/acf_peZ","readonly") -- minus 10.9 and below  when in the cabin.

			dataref("ChronoTimeND2","AirbusFBW/ChronoTimeND2","readonly")
			dataref("timerFlightDeck","sim/time/timer_is_running_sec","writable")
			dataref("ClockETSwitch","AirbusFBW/ClockETSwitch","writable")

			dataref("BeaconL","AirbusFBW/OHPLightSwitches","writable",0)
			dataref("WingL","AirbusFBW/OHPLightSwitches","writable",1)
			dataref("NavL","AirbusFBW/OHPLightSwitches","writable",2)
			dataref("TaxiL","AirbusFBW/OHPLightSwitches","writable",3)
			dataref("LandingLeftL","AirbusFBW/OHPLightSwitches","writable",4)
			if PLANE_ICAO == "A346" then
				LandingRightL = 0   -- the A340-600 only has one switch
			else
				dataref("LandingRightL","AirbusFBW/OHPLightSwitches","writable",5)
			end
			dataref("TurnOffL","AirbusFBW/OHPLightSwitches","writable",6)
			dataref("StrobeL","AirbusFBW/OHPLightSwitches","writable",7)

			dataref("SeatBeltSignsOn","AirbusFBW/OHPLightSwitches","writable",11)
			dataref("EmerLight","AirbusFBW/OHPLightSwitches","writable",10)
			dataref("NoSmokingSignsOn","AirbusFBW/OHPLightSwitches","writable",12)

			dataref("speedbrake_ratio","sim/cockpit2/controls/speedbrake_ratio","writable")

			dataref("Pack1Switch","AirbusFBW/Pack1Switch","writable")
			dataref("Pack2Switch","AirbusFBW/Pack2Switch","writable")

			dataref("ProbeHeatSwitch","AirbusFBW/ProbeHeatSwitch","writable")

			dataref("GroundHPAir","AirbusFBW/GroundHPAir","writable")
			dataref("GroundLPAir","AirbusFBW/GroundLPAir","writable")

			dataref("CvrGndCtrl","AirbusFBW/CvrGndCtrl","writable")
			dataref("radar","AirbusFBW/WXPowerSwitch","writable")

			dataref("BrakeFan319","AirbusFBW/BrakeFan","writable")
			dataref("RMP1","AirbusFBW/RMP1Switch","writable")
			dataref("RMP2","AirbusFBW/RMP2Switch","writable")
			dataref("RMP3","AirbusFBW/RMP3Switch","writable")

			dataref("ACP1_PA","AirbusFBW/ACP1KnobPush","readonly",15) -- public address on loudspeaker == 1
			dataref("ACP2_PA","AirbusFBW/ACP2KnobPush","readonly",15)
			dataref("ACP3_PA","AirbusFBW/ACP3KnobPush","readonly",15)

			dataref("ACP1_INT","AirbusFBW/ACP1KnobPush","readonly",5) -- service interphone active == 1
			dataref("ACP2_INT","AirbusFBW/ACP2KnobPush","readonly",5)
			dataref("ACP3_INT","AirbusFBW/ACP3KnobPush","readonly",5)

			dataref("ACP1_CAB","AirbusFBW/ACP1KnobPush","readonly",6) -- Cabin interphone active == 1
			dataref("ACP2_CAB","AirbusFBW/ACP2KnobPush","readonly",6)
			dataref("ACP3_CAB","AirbusFBW/ACP3KnobPush","readonly",6)

			--~ dataref("ACP_CabVolume","AirbusFBW/ACP_CabVolume","readonly") -- not fonctional in january 2023, will do a workaround with FBW_AuralVolume
			--~ dataref("ACP_IntVolume","AirbusFBW/ACP_CabVolume","readonly") -- not fonctional in january 2023, will do a workaround with FBW_AuralVolume
			dataref("FBW_AuralVolume","AirbusFBW/AuralVolume","readonly")
			--set("AirbusFBW/AuralVolume",0.5)

			local ACP_RESET = -99 -- dont' have it on the ToLiss - Placeholder

			--FMA
			-- Table of dataref values for actual mode :

			dataref("FMAthr","AirbusFBW/FMA2w","readonly",0)
			-- AT modes
			--	SPEED	16384
			--	AFLOOR TOGA LOCK 2
			--	MAN TOGA 2
			--	MAN FLEX 8
			--	THR CLB	128
			--	THR IDLE 512
			--	MCT	2112

			dataref("FMAmodes","AirbusFBW/FMA1g","readonly",0)
			-- Vertical modes
			--	ALT*	256
			--	ALT	128
			--	FPA	64
			--	VS	32
			--	GS*	16
			--	GS	8
			--	OPENCLB	512
			---->   EXP CLB	65536 -- new ! but with thrust climb 128
			--	CLB	2048
			--	OPEN DES 1024
			---->   EXP DES	65536 -- new ! but with Idle thrust 512
			--	DES	4096
			--	SRS	2

			-- Lateral modes
			--	NAV	128
			--	HDG	32
			--	TRK	64
			--	LOC*	16
			--	LOC	8
			--  (APP) NAV	128
			-- 	RWY (TRK) 2
			-- ROLLOUT = 2 (vertical) + 2 (vertical)
			-- FINAL APP = 32768 (vertical) + 128 (lateral)

			dataref("BlueModes","AirbusFBW/FMA2b","readonly",0)
			--	LOC Blue	1
			--	NAV BLUE	2
			-- vertical first, lateral with blank audio first
			--	GS Blue		8
			-- 	ALT BLUE	48





			dataref("PressMode", "AirbusFBW/CabPressMode", "writable")
			dataref("LandElev", "AirbusFBW/LandElev", "writable")

			dataref("NDmodeFO", "AirbusFBW/NDmodeFO", "writable")

			payloadKG = 0
			dataref("payloadKG","sim/flightmodel/weight/m_fixed","readonly")
			dataref("aircraft_CG", "AirbusFBW/CGLocationPercent", "readonly")

			--~ dataref("Eng2N2", "sim/flightmodel2/engines/N2_percent","readonly",1)
			--~ dataref("Eng1N2", "sim/flightmodel2/engines/N2_percent","readonly",0)

			dataref("Eng2N1", "sim/flightmodel2/engines/N1_percent","readonly",1) -- 17 idle = 17% N1
			dataref("Eng1N1", "sim/flightmodel2/engines/N1_percent","readonly",0) -- 17 idle = 17% N1

			dataref("Target_N1_right_Eng2", "AirbusFBW/ENGTLASettingN1","readonly",1) --right
			dataref("Target_N1_left_Eng1", "AirbusFBW/ENGTLASettingN1","readonly",0) --left

			--used when PLANE_ICAO == "A346" :
				--~ dataref("Eng4N2", "sim/flightmodel2/engines/N2_percent","readonly",3)
				--~ dataref("Eng3N2", "sim/flightmodel2/engines/N2_percent","readonly",2)

				dataref("Eng4N1", "sim/flightmodel2/engines/N1_percent","readonly",3) -- 17 idle = 17% N1
				dataref("Eng3N1", "sim/flightmodel2/engines/N1_percent","readonly",2) -- 17 idle = 17% N1

				--dataref("Target_N1_right_Eng4", "AirbusFBW/ENGTLASettingN1","readonly",3) --right
				--dataref("Target_N1_left_Eng3", "AirbusFBW/ENGTLASettingN1","readonly",2) --left
			--end

			dataref("acceleration_pilot","sim/cockpit2/gauges/indicators/airspeed_acceleration_kts_sec_pilot","readonly")
			dataref("acceleration_copilot","sim/cockpit2/gauges/indicators/airspeed_acceleration_kts_sec_copilot","readonly")

			dataref("THRRatingN1","AirbusFBW/THRRatingN1","readonly")
			dataref("THRRatingType","AirbusFBW/THRRatingType","readonly")

			dataref("TakeoffDecision", "toliss_airbus/performance/V1", "writable")
			dataref("TakeoffRotate","toliss_airbus/performance/VR", "writable")
			dataref("TakeoffReference", "toliss_airbus/performance/V2", "writable")
			dataref("AirSpeedGreenDot", "toliss_airbus/pfdoutputs/general/VGreenDot_value","readonly")
			dataref("VFENext", "toliss_airbus/pfdoutputs/general/VFENext_value","readonly")
			dataref("AirSpeedFlaps", "toliss_airbus/pfdoutputs/general/VF_value", "readonly")
			dataref("AirSpeedSlats", "toliss_airbus/pfdoutputs/general/VS_value", "readonly")

			--dataref("THRRedAcc", "AirbusFBW/MCDU1scont5b", "readonly",0)

			dataref("SC_DestWindDir","toliss_airbus/performance/DestWindDir","writable")
			dataref("SC_DestWindSpd","toliss_airbus/performance/DestWindSpd","writable")
			dataref("SC_DestTemp","toliss_airbus/performance/DestTemp","writable")
			dataref("SC_DestQNH","toliss_airbus/performance/DestQNH","writable")

			if IsXPlane12 then
				dataref("OAT","sim/weather/aircraft/temperature_ambient_deg_c","readonly") -- °C
				print("Speedy copilot chooses sim/weather/aircraft/temperature_ambient_deg_c")
				dataref("Sim_WindDir", "sim/weather/aircraft/wind_direction_degt","readonly")
				dataref("Sim_WindSpd", "sim/weather/aircraft/wind_speed_kts","readonly",0)
			else
				dataref("OAT","sim/weather/temperature_ambient_c","readonly") -- °C
				dataref("Sim_WindDir", "sim/weather/wind_direction_degt","readonly")
				dataref("Sim_WindSpd", "sim/weather/wind_speed_kt","readonly",0)
				print("Speedy copilot chooses sim/weather/temperature_ambient_c")
			end

			dataref("Sim_QNH_inches","sim/weather/barometer_sealevel_inhg","readonly")

			dataref("costindex","toliss_airbus/init/costindex","writable")
			dataref("InitZFW","toliss_airbus/init/ZFW","writable")
			dataref("InitZFWCG","toliss_airbus/init/ZFWCG","writable")
			dataref("InitBlockFuel","toliss_airbus/init/BlockFuel","writable")
			dataref("m_fuel_total","sim/flightmodel/weight/m_fuel_total","readonly")
			dataref("m_total","sim/flightmodel/weight/m_total","readonly")

			dataref("flaprqst","sim/flightmodel/controls/flaprqst","writable")


			TL_Accel_AltitudeBaro = 0 -- feet (for init)


			if PLANE_ICAO ~= "A346" then
				dataref("GPWS_Flaps3Pressed","AirbusFBW/GPWSSwitchArray","readonly",3)
				dataref("doorLock","ckpt/doorLock","writable")
				doorLock = 1 -- ie NORM to avoid jumping straight to pax cabin v2.3
				dataref("SpoilersPositionL","anim/spoiler/2","readonly")
				dataref("SpoilersPositionR","anim/spoiler/9","readonly")
				dataref("ReverseR", "anim/reverserRight", "readonly")
				dataref("ReverseL", "anim/reverserLeft", "readonly")
				ExternalPowerAEnabled = 0
				ExtPowerAConnected = 0
				dataref("ExternalPowerEnabled","AirbusFBW/EnableExternalPower","writable")
				dataref("ExtPowerConnected","AirbusFBW/ElecOHPArray","writable",3)
				BatOHAPU = 0
				dataref("FuelPumpOH1","AirbusFBW/FuelOHPArray","writable",0)
				dataref("FuelPumpOH2","AirbusFBW/FuelOHPArray","writable",1)
				dataref("FuelPumpOH3","AirbusFBW/FuelOHPArray","writable",2)
				dataref("FuelPumpOH4","AirbusFBW/FuelOHPArray","writable",3)
				dataref("FuelPumpOH5","AirbusFBW/FuelOHPArray","writable",4)
				dataref("FuelPumpOH6","AirbusFBW/FuelOHPArray","writable",5)
				FuelPumpOH7 = 0
				FuelPumpOH8 = 0
				FuelPumpOH9 = 0
				FuelPumpOH10 = 0
				LandscapeCamera = 0
			elseif PLANE_ICAO == "A346" then
				dataref("GPWS_Flaps3Pressed","AirbusFBW/GPWSSwitchArray","readonly",3)
				dataref("doorLock","AirbusFBW/CockpitDoorSwitch","writable")
				doorLock = 1 -- to avoid jumping straight to pax cabin v2.3
				radarPWS = 0
				dataref("SpoilersPositionL","sim/flightmodel2/wing/spoiler2_deg","readonly",0)
				dataref("SpoilersPositionR","sim/flightmodel2/wing/spoiler2_deg","readonly",1)
				dataref("ReverseR", "sim/flightmodel2/engines/thrust_reverser_deploy_ratio", "readonly",0)
				dataref("ReverseL", "sim/flightmodel2/engines/thrust_reverser_deploy_ratio", "readonly",1)
				dataref("ExternalPowerEnabled","AirbusFBW/EnableExternalPowerB","writable")
				dataref("ExtPowerConnected","AirbusFBW/ElecOHPArray","writable",3)
				dataref("ExternalPowerAEnabled","AirbusFBW/EnableExternalPower","writable")
				dataref("ExtPowerAConnected","AirbusFBW/ElecOHPArray","writable",15)
				dataref("BatOHAPU","AirbusFBW/ElecOHPArray","writable",16)
				dataref("FuelPumpOH1","AirbusFBW/FuelOHPArray","writable",0)
				dataref("FuelPumpOH2","AirbusFBW/FuelOHPArray","writable",1)
				dataref("FuelPumpOH3","AirbusFBW/FuelOHPArray","writable",2)
				dataref("FuelPumpOH4","AirbusFBW/FuelOHPArray","writable",3)
				dataref("FuelPumpOH5","AirbusFBW/FuelOHPArray","writable",4)
				dataref("FuelPumpOH6","AirbusFBW/FuelOHPArray","writable",5)
				dataref("FuelPumpOH7","AirbusFBW/FuelOHPArray","writable",8)
				dataref("FuelPumpOH8","AirbusFBW/FuelOHPArray","writable",9)
				dataref("FuelPumpOH9","AirbusFBW/FuelOHPArray","writable",10)
				dataref("FuelPumpOH10","AirbusFBW/FuelOHPArray","writable",11)
				dataref("FuelXFER0","AirbusFBW/FuelOHPArray","writable",6)   -- AUTOSWITCH
				dataref("FuelXFER1","AirbusFBW/FuelOHPArray","writable",18)
				dataref("FuelXFER2","AirbusFBW/FuelOHPArray","writable",17)
				dataref("FuelXFER3","AirbusFBW/FuelOHPArray","writable",20)
				dataref("FuelXFER4","AirbusFBW/FuelOHPArray","writable",21)
				dataref("FuelXFER5","AirbusFBW/FuelOHPArray","writable",16)
				dataref("FuelXFER6","AirbusFBW/FuelOHPArray","writable",15)
				dataref("FuelXFER11","AirbusFBW/FuelOHPArray","writable",19)

				dataref("FuelXFER7","AirbusFBW/FuelOHPArray","writable",14)
				dataref("FuelXFER8","AirbusFBW/FuelOHPArray","writable",13)
				dataref("FuelXFER9","AirbusFBW/FuelOHPArray","writable",12)
				dataref("FuelXFER10","AirbusFBW/FuelOHPArray","writable",7)
				dataref("FuelXFER12","AirbusFBW/FuelOHPArray","writable",23)
				dataref("FuelXFER13","AirbusFBW/FuelOHPArray","writable",22)

				dataref("LandscapeCamera","AirbusFBW/ElecOHPArray","writable",26)


				dataref("VHF2", "AirbusFBW/ACP1KnobPush", "writable",1)
				dataref("Marker", "AirbusFBW/ACP1KnobPush", "writable",8)


			end
			--dataref("fieldElevMSL","sim/cockpit2/autopilot/altitude_readout_preselector","readonly") -- disused

			dataref("MCDU1thrRed","AirbusFBW/MCDU1label5w","readonly",0)
			dataref("MCDU2thrRed","AirbusFBW/MCDU2label5w","readonly",0)
			dataref("MCDU1thrRedValues","AirbusFBW/MCDU1cont5b","readonly",0) -- When user has made an entry
			dataref("MCDU2thrRedValues","AirbusFBW/MCDU2cont5b","readonly",0)
			dataref("MCDU1thrDefValues","AirbusFBW/MCDU1scont5b","readonly",0) -- by FMGS
			dataref("MCDU2thrDefValues","AirbusFBW/MCDU2scont5b","readonly",0)
			GoAroundPageMarker1="<PHASE    PHASE>"
			GoAroundPageMarker2="<PHASE    PHASE>"
			dataref("GoAroundPageMarker1","AirbusFBW/MCDU1cont6w","readonly",0) -- Will be "<PHASE    PHASE>" if G.A. page
			dataref("GoAroundPageMarker2","AirbusFBW/MCDU2cont6w","readonly",0) -- Will be "<PHASE    PHASE>" if G.A. page
			dataref("TerrainLeft", "AirbusFBW/TerrainSelectedND1","readonly")
			dataref("TerrainRight","AirbusFBW/TerrainSelectedND2","writable")
			-- xplane datarefs
			-- search them at https:..www/siminnovations/com/xplane/dataref/index/php !
			dataref("view_is_external", "sim/graphics/view/view_is_external", "readonly")
			dataref("speed", "sim/flightmodel/position/indicated_airspeed2","readonly")
			dataref("Xcode", "sim/cockpit/radios/transponder_code", "readonly")
			dataref("pressurealtitude", "sim/cockpit2/gauges/indicators/altitude_ft_pilot","readonly") -- BARO alt. in foot ! /!\
			dataref("AirbusFBW_ALTFO","AirbusFBW/ALTFO","readonly") -- available only with electricity, to be reserve for crew duty, not speedy copilot structural stuff
			fieldElevMSL = pressurealtitude -- init
			dataref("verticalspeed", "sim/cockpit2/gauges/indicators/vvi_fpm_copilot","readonly")
			dataref("parkbrakeToLiss", "AirbusFBW/ParkBrake", "writable")
			dataref("altitudeAGL", "sim/flightmodel/position/y_agl","readonly") -- Altitude above ground level in meter ! /!\
			dataref("GearPosition", "sim/flightmodel2/gear/deploy_ratio","readonly",0)
			dataref("aircraft_longitude","sim/flightmodel/position/longitude","readonly")
			dataref("yoke_pitch","sim/cockpit2/controls/yoke_pitch_ratio","readonly")
			dataref("yoke_roll","sim/cockpit2/controls/yoke_roll_ratio","readonly")
			dataref("yoke_yaw","sim/cockpit2/controls/yoke_heading_ratio","readonly")
			dataref("LocalTime","sim/time/local_time_sec")
			dataref("FCUaltitude", "sim/cockpit/autopilot/altitude", "readonly") -- dependant of MOKNY config file.


			if gs_gnd_spd == nil then  dataref("gs_gnd_spd", "sim/flightmodel/position/groundspeed", "readonly") end


			local ffi = require ("ffi")

			-- find the right lib to load
			local XPLMlib = ""
			if SYSTEM == "IBM" then
				-- Windows OS (no path and file extension needed)
				XPLMlib = "XPLM_64"  -- 64bit
			elseif SYSTEM == "LIN" then
				-- Linux OS (we need the path "Resources/plugins/" here for some reason)
				XPLMlib = "Resources/plugins/XPLM_64.so"  -- 64bit
			elseif SYSTEM == "APL" then
				-- Mac OS (we need the path "Resources/plugins/" here for some reason)
				XPLMlib = "Resources/plugins/XPLM.framework/XPLM" -- 64bit and 32 bit
			else
				return -- this should not happen
			end

			-- load the lib and store in local variable
			local XPLM = ffi.load(XPLMlib)

			-- create declarations of C types
			local cdefs = [[
			  typedef void *XPLMDataRef;
			  XPLMDataRef XPLMFindDataRef(const char *inDataRefName);
			  int  XPLMGetDatab(XPLMDataRef          inDataRef,
								 void *               outValue,    /* Can be NULL */
								 int                  inOffset,
								 int                  inMaxBytes);
			]]

			-- add these types to the FFI:
			ffi.cdef(cdefs)
			-- telling which aircraft is pax, which is cargo :
			AircraftSimPath = "PlaceHolder"
			-- Access to acf_livery_path

			-- added 19th november 2023 :
			-- dataref("AircraftPath","sim/aircraft/view/acf_livery_path","readonly",0)
			-- https://forums.x-plane.org/index.php?/forums/topic/296938-with-1208-beta-12-mapping-simaircraftviewacf_livery_path-sends-fwl-into-an-internal-loop/&page=2#comment-2633523
			-- If you followed the discussion in the FWL forum you may have noticed that this particular dataref is not the best candidate for retrieval through the "modern"  FWL dataref interface.
			-- With the attached code snippet it can be retrieved when needed through the ffi interface and that may be a more future proof solution.
			local acf_livery_path_dr = ffi.new("XPLMDataRef")
			local acf_livery_path_dr = XPLM.XPLMFindDataRef("sim/aircraft/view/acf_livery_path");
			local buffer  = ffi.new("char[256]")
			local n = XPLM.XPLMGetDatab(acf_livery_path_dr, buffer, 0, 255)
			AircraftSimPath = ffi.string(buffer)
			-- let's try to see if it is a P2F aircraft if the word "P2F" can be found in the simulator path.
			if AircraftSimPath:match("P2F") or AircraftSimPath:match("freighter") or AircraftSimPath:match("Freighter") or AircraftSimPath:match("cargo") then AircraftIsP2F = 1 GUI_AircraftIsP2F = true MuteCabinRelatedSounds = 1 GUI_MuteCabinRelatedSounds = true else AircraftIsP2F = 0 GUI_AircraftIsP2F = false MuteCabinRelatedSounds = 0 GUI_MuteCabinRelatedSounds = false end -- contains cargo if cargo is in the livery

			--dataref("target_alt", "sim/cockpit/autopilot/altitude", "readonly")
			target_alt = FCUaltitude -- init
			-- special init for PilotHead
			PilotHead = 0 -- prevent external view when WRITABLE, let it readonly
			dataref("PilotHead", "sim/graphics/view/pilots_head_psi", "readonly")

			message_time=math.floor(os.clock()) + 60  -- used by function AutoClear
			function Message()
				message_done = 0 -- used by function AutoClear

				if TL_Keep_secondary_sounds == "activate" then
					--big_bubble( 50, 20, "The New Speedy Copilot for ToLiSS","Welcome. Version " .. version_text_troiscentvingt .. ". " .. WaitingString)
				else
					big_bubble( 50, 20, "The New read_the_SGES_startup_options = true. Welcome !", "Secondary sounds deactivated in options.lua.")
				end
			end

		end -- end of DatarefLoad function only activated when the API is ready by chronometer
		--do_often("DatarefLoad()")


		--########################################
		--# INITIAL COMMANDS                     #
		--########################################



		FF_initial_load = true -- this one is used by the GUI
		-- Our own Cold and Dark state :
		function SupplementaryColdDark()
			if slides_addon_installed then
				print("FlyWithLua Info: Speedy Copilot : slides_addon_installed : TRUE")
			else
				print("FlyWithLua Info: Speedy Copilot : slides_addon_installed : FALSE")
			end
			-- nothing
			if altitudeAGL < AGL_onGround and speed < 30 and Eng1N1 < 10  and Eng2N1 < 10 then
				set("AirbusFBW/FD1Engage",0)
				set("AirbusFBW/FD2Engage",0)
				if JAR_Ground_Handling_wanted == 1 then
					GHDpowerCable = 0
					GHDChocks = 1
					GHDcateringFwd = 1
					GHDcateringAft = 1
					GHDfuelTank = 0
					GHDpassengersBus = 0
					GHDnoseConus[0] =1
					GHDloaderAft = 0
					GHDloaderFwd = 0
					if forward_JARstairs_wanted == 1 then GHDforwardStairs = 0 end
					GHDrearStairs = 1
					--GHDFireService = 0
				end
				Toliss_chocks_set = 1
				-- DOORS (2 is open while 0 is closed. 1 is AUTO)
				PaxDoor1L = 0
				PaxDoorRearLeft = 0
				if slides_addon_installed or AircraftIsP2F == 1 then
					PaxDoorRearLeft = 0
				else
					PaxDoorRearLeft = 2
				end
				ServiceDoor1R = 0
				ServiceDoor2R = 0
				--CargoDoor1 = 0
				--CargoDoor2 = 0
				if (AIRCRAFT_FILENAME == "a321.acf" or AIRCRAFT_FILENAME == "a321_StdDef.acf" or AIRCRAFT_FILENAME == "a321_XP11.acf") then
					BulkDoor = 0
				end

				if PLANE_ICAO == "A346" then
					ServiceDoor2R = 2
					BulkDoor = 0
				else
					ServiceDoor2R = 0
				end

				-- FUELS PUMPS should be OFF in cold and dark and Turn around :
				if  PLANE_ICAO ~= "A346" then
					FuelPumpOH6 = 0
					FuelPumpOH5 = 0
					FuelPumpOH4 = 0
					FuelPumpOH3 = 0
					FuelPumpOH2 = 0
					FuelPumpOH1 = 0
					CvrGndCtrl = 1 -- item of the PF in prep procedure.
					-- let's put it as if let like that by the previous crew ;-)
					-- it's my script, I do whatever I want ;-)
				else
					display_bubble("A340-600 overhead fuel panel.")
					FuelPumpOH10 = 0
					FuelPumpOH9 = 0
					FuelPumpOH8 = 0
					FuelPumpOH7 = 0
					FuelPumpOH6 = 0
					FuelPumpOH5 = 0
					FuelPumpOH4 = 0
					FuelPumpOH3 = 0
					FuelPumpOH2 = 0
					FuelPumpOH1 = 0

					FuelXFER0 = 1    -- AUTOSWITCH
					FuelXFER1 = 0
					FuelXFER2 = 0
					FuelXFER3 = 0
					FuelXFER4 = 0
					FuelXFER5 = 0
					FuelXFER6 = 0
					FuelXFER7 = 0
					FuelXFER8 = 0
					FuelXFER9 = 0
					FuelXFER10 = 0
					FuelXFER11 = 0
					FuelXFER12 = 0
					FuelXFER13 = 0 -- TSFR AUTO / FWD
				end
				--
				ClockETSwitch = 1 -- STOP
				NoSmokingSignsOn = 1 -- no smoking Sign will always be ON, forever.
			end
			if altitudeAGL > 30 or speed > 30 or Eng1N1 >= 10 or Eng2N1 >= 10 then
				set("AirbusFBW/FD1Engage",1)
				set("AirbusFBW/FD2Engage",1)
				if JAR_Ground_Handling_wanted == 1 then
					GHDpowerCable = 0
					GHDChocks = 1
					GHDcateringFwd = 1
					GHDcateringAft = 1
					GHDfuelTank = 0
					GHDpassengersBus = 0
					GHDnoseConus[0] =1
					GHDloaderAft = 0
					GHDloaderFwd = 0
					if forward_JARstairs_wanted == 1 then GHDforwardStairs = 0 end
					GHDrearStairs = 1
					--GHDFireService = 0
				end
				Toliss_chocks_set = 0
			end
		end
		--command_once("toliss_airbus/iscs_open")
		-- function iscs_open()
			-- if  then command_once("toliss_airbus/iscs_open") end
		-- end
		-- do_every_frame("iscs_open()")

		math.randomseed(os.time())



		--########################################
		--# GENERAL INIT OF VARIABLES            #
		--########################################
		 -- if it's not broken, don't repair it !

		--initialize triggers
		-- 0: did not happened
		-- 1: is happening
		-- 2: procedure done
		-- (with deviations)
		-- Below the following altitude in METERS AGL, F.O. is allowed to put gear down.
		-- Above this radio-altitude, even with low speed, gear won't be extended.
		local maximumGearAltitude = 760	-- initial value : 2500 ft AGL = 760 m
		local ApproachActiveRadioAltitude = 1830 --initial value : 6000 ft BARO = 1830 m
		maximumGearAltitude = 914 --m (=3000 ft)eased in April 2021 to suppress high altitude landing option

		single_engine_taxi = 0
		GUI_OET = false -- added April 2021
		GUI_HighAlt = false -- default option.
		GUI_PacksOff1and2 = false
		GUI_messages_in_circle_and_all_messages = true
		GUI_MuteCabinRelatedSounds = false
		GUI_VR_message = false
		MuteCabinRelatedSounds = 0
		GUI_AircraftIsP2F = false
		AircraftIsP2F = 0
		--apu_started = 0
		--apu_time = 86400 -- initialisation
		xpder_time = 0
		PacksOff1and2 = 0
		local gearup = 0
		local step = 0
		local sched = 0
		local checklist = 0
		local genactive1_trigger = 0
		local genactive2_trigger = 0
		local genactive3_trigger = 0
		local genactive4_trigger = 0
		local started1 = 0
		local started2 = 0
		local started3 = 0
		local started4 = 0
		local genonline = 0
		local delay_done = 0
		local afterlandingstep = 0
		local savedflapsUP_climb_speed = 200
		SEI_P = false -- those are patched progress flags for the 2022-08 GUI improvement
		CPP_P = false
		CP_P = false
		BSC_P = false
		ASC_P = false
		PB_P = false
		ES_P = false
		AS_P = false
		Tx_P = false
		OET_P = false
		DC_P = false
		BT_P = false
		T_P = false
		AT_P = false
		C_P = false
		CS_P = false
		DPP_P = false
		D_P = false
		A_P = false
		L_P = false
		GA_P = false
		AL_P = false
		P_P = false
		STA_P = false
		local Sc_cruise_alt = 11000 --tempo
		SERVICEMIC = 0

		Message_wnd_content = ""
		Message_wnd_action = "" -- global !
		vr_message_sent = false
		Vr_message_current_answer = "?"

		local Belts_trigger = 0

		local flightcontrols_checked = 0
		local roll_checked = 0
		local pitch_checked = 0
		local rollsup_checked = 0
		local pitchsup_checked = 0
		local rollinf_checked = 0
		local pitchinf_checked = 0

		local VSpeed = 0
		TakeoffDecision = 120 -- when not set in the MCDU
		TakeoffRotate = 140
		TakeoffReference = 150
		--AirSpeedMinSelect = 120
		local RolloutSpeedSave = 110
		local Max_speed_for_next_flaps = 200 -- VFEnext with a little delta
		AirSpeedFlaps = 152  -- in case sthg wrng
		AirSpeedSlats = 195
		AirSpeedGreenDot = 217
		local flaps3Altitude = 1100 --ft BARO
		local flaps3LastAltitude = 0
		local SpeedSave = 110
		local radioalive_flag = 0
		local TOFlapsWanted = 1
		--local top_flapsAPP_app_speed = 120
		local backup_flapsAPP_app_speed = 120
		local aircraft_calculated_ZFWCG = 30
		local TL_Accel_AltitudeBaro_fromMCDU  = 799
		local Red_AltitudeBaro_fromMCDU = 799
		local Red_AltitudeBaro = 799
		local TL_Accel_AltitudeBaro = 799

		local flagRed = ""
		local flagAcc = ""

		ACP_RESET = 0
		MENU_RESET = 0
		ground_stuff = 0

		fmgs_time = 0
		message_time = 0
		Pack1_time = 0
		local Belts_trigger = 2
		local Adress_trigger = 0
		local INT_trigger = 0
		local CAB_trigger = 0
		local boarding_trigger = 0
		local CLEAR_MESSAGE = 0
		local boardingMusic = 0
		local coldAndDarkAtc = 0
		local ExtPowerFlag = 0
		local transfer_exterior_lights_to_the_PM_on_ground = false -- 2022 08 22

		local FMA = ""
		local FMAthr = ""

		flightcontrols_time = 0
		pax_time=math.floor(os.clock())
		max_pax_time = 9999
		localHour = 12
		local Teleportation_trigger = 0
		local spoilers_played = 0
		local reverse_played = 0

		local ToPackStep = -1
		MCDU1thrRedValues = "799 799  450" -- init
		MCDU2thrRedValues = "799 799  450" -- init
		MCDU1thrDefValues = "799 799  450" -- init
		MCDU2thrDefValues = "799 799  450" -- init
		--Actual_THRAcc = 1700 -- init
		-- Actual_THRAcc : updating does not work
		-- spent almost 5 hours to try to have it dynamic, but no luck
		-- I keep a static value for now, I'm exhausted.

		local CG = 0
		local trim = 0


		--########################################
		--# GUI                                  #
		--########################################
		-- initialisation of variables related to options in GUI (do not remove) starts
		-- don't touch that !
		ToLissPNFonDuty = 1 -- important
		SoundLevel = 1 --important
		JZLevel = 0.7 --important
		O2Level = 0.3 --important
		ENG_wanted = 0
		VREF_wanted = 1
		FLAPS_wanted = 1
		planned_flaps = 40
		DelaysAPU = 1
		AfterLandingWithAPU = 0
		MENU_RESET = 0
		Park_is_PNF = 0
		Pre_Conditioned_Air_Unit = 1
		Gate_service = 1
		QuickGlance = 1
		JAR_Ground_Handling_wanted = 1
		forward_JARstairs_wanted = 1
		PassengerLevel = 0.15
		callout_played = 0
		--Say_Rotate = 1
		-- ends

		-- reading data from ToLiss_A319-options.lua
		-- setting user-persistent options for some options with "ToLiss_A319_WriteSaveToDisk()"

		-- preparing GUI
		add_macro("------------------------------------------------","")
		add_macro("--     SPEEDY COPILOT " .. version_text_troiscentvingt .. "     --","")
		--add_macro("--------TOLISS-AIRBUS--------","")
		--add_macro("Clear the message on screen","CLEAR_MESSAGE = 1")
		--add_macro("Show menu","FF_FWL_MenuCall = true")
		add_macro("Show Speedy Copilot menu","FF_FWL_MenuCall = true show_window_bottom_bar = false 	do_tha_mouse = true 		if OPTION_WINDOW ~= nil then float_wnd_destroy(OPTION_WINDOW) end 			loadOptions = true  	MenuOpening_time=math.floor(os.clock())")
		add_macro("Hide the bottom bar","hide_the_bottom_bar = true normal_messages = 0 GUI_normal_messages = false GUI_messages_in_circle_and_all_messages = false","hide_the_bottom_bar = false normal_messages = 1 GUI_normal_messages = true GUI_messages_in_circle_and_all_messages = true")
		add_macro("Hide the bottom bar, disable the F.O.","hide_the_bottom_bar = true normal_messages = 0 GUI_normal_messages = false GUI_messages_in_circle_and_all_messages = false ToLissPNFonDuty = 0 GUI_ToLissPNFonDuty = false","hide_the_bottom_bar = false normal_messages = 1 GUI_normal_messages = true GUI_messages_in_circle_and_all_messages = true  ToLissPNFonDuty = 1 GUI_ToLissPNFonDuty = true")
		add_macro("------------------------------------------------","")
		-- ***********************************************************
		-- initialisation of variables related to options (do not remove)
		-- preparing GUI from persitent options
		The_PNF_moves_GEAR_and_FLAPS_on_your_command = "activate"
		if The_PNF_moves_GEAR_and_FLAPS_on_your_command == "activate"	then
			FLAPS_wanted = 1
		else FLAPS_wanted = 0		end

		if TL_The_PNF_delays_the_APU_on_departure == "activate"		then
			DelaysAPU = 1 GUI_DelaysAPU = true
		else DelaysAPU = 0 GUI_GUI_DelaysAPU = false		end
		if TL_Global_Say_Rotate == "activate" 							then
			Say_Rotate = 1 GUI_Say_Rotate = true
		else Say_Rotate = 0 GUI_Say_Rotate = false 		end
		if TL_Global_Say_Mins == "activate" 							then
			Say_Mins = 1 GUI_Say_Mins = true
		else Say_Mins = 0 GUI_Say_Mins = false 		end
		if TL_The_PNF_releases_PARK_BRK_with_chocks == "activate" 		then
			Park_is_PNF = 1 GUI_Park_is_PNF = true
		else Park_is_PNF = 0 GUI_Park_is_PNF = false		end
		if TL_Low_pressure_air_requested_when_on_stand == "activate" 	then
			Pre_Conditioned_Air_Unit = 1 GUI_Pre_Conditioned_Air_Unit = true
		else Pre_Conditioned_Air_Unit= 0 GUI_Pre_Conditioned_Air_Unit  = false	end
		if TL_The_PNF_starts_the_APU_after_landing == "activate" 		then
			AfterLandingWithAPU = 1 GUI_AfterLandingWithAPU = true
		else AfterLandingWithAPU = 0 GUI_AfterLandingWithAPU = false	end
		if TL_Check_yaw_during_flight_controls_check == "activate" 	then
			Check_yaw = 1 GUI_Check_yaw = true
		else Check_yaw = 0 GUI_Check_yaw = false 		end
		if TL_QuickGlance_option == "activate" 						then
			QuickGlance = 1  GUI_QuickGlance = true
		else QuickGlance = 0 GUI_QuickGlance = false		end


		if TL_online_transponder_option == "activate" then
			Online_transponder = 1
			GUI_OnlineSQK = true
		else
			Online_transponder = 0
			GUI_OnlineSQK = false
		end

		if TL_Cabin_on_unlock == "activate" then
			Cabin_on_unlock = 1
			GUI_Cabin_on_unlock = true
		else
			Cabin_on_unlock = 0
			GUI_Cabin_on_unlock = false
		end

		if TL_FoTunesRadiosInPreparationFlow == "activate" then
			FoTunesRadiosInPreparationFlow = 1 GUI_FoTunesRadiosInPreparationFlow = true
		else
			FoTunesRadiosInPreparationFlow = 0 GUI_FoTunesRadiosInPreparationFlow = false
		end

		if TL_Display_normal_messages == "activate" 					then
			normal_messages = 1 GUI_normal_messages = true
		else normal_messages = 0 GUI_normal_messages = false	end -- Keep this to "activate".

		if TL_Use_GHD_airstairs_at_gate == "activate" 		then
			JAR_Ground_Handling_wanted = 1  GUI_JAR_Ground_Handling_wanted = true DatarefJARLoad()
		else JAR_Ground_Handling_wanted = 0 GUI_JAR_Ground_Handling_wanted = false	end

		if TL_Use_GHD_airstairs_at_left_forw_door == "activate" 	then
			forward_JARstairs_wanted = 1 GUI_forward_stairs_Yes = true  GUI_forward_stairs_No = false
		else forward_JARstairs_wanted = 0 GUI_forward_stairs_Yes  = false  GUI_forward_stairs_No = true	end
		if TL_Keep_secondary_sounds == "activate" 						then
			GUI_SecondarySounds = true
		else GUI_SecondarySounds = false end
		if Reduce_main_panel_lights == "activate" 					then
			GUI_DeckLights = true
		else GUI_DeckLights = false end
		if Minimises_landing_lights == "activate" 					then
			GUI_LandingLights = true
		else GUI_LandingLights = false end
		if TL_synchronizedFD == "activate"                      then
			GUI_TL_synchronizedFD = true
		else GUI_TL_synchronizedFD = false end
		--if FoTunesRadiosInPreparationFlow == 1                  then GUI_FoTunesRadiosInPreparationFlow = true else GUI_FoTunesRadiosInPreparationFlow = false end
		ToLissPNFonDuty = 1
		if TL_VR_message == "activate" then
			GUI_VR_message = true VR_message = 1
		else GUI_VR_message = false VR_message = 0 end

		if TL_transfer_exterior_lights_to_the_PM_on_ground == "activate" then
			transfer_exterior_lights_to_the_PM_on_ground = true
		else transfer_exterior_lights_to_the_PM_on_ground = false end

		-- ***********************************************************
		-- -- After the last macro init this welcome message hides the options messages
		-- message_time=math.floor(os.clock()) + 180  -- used by function AutoClear
		-- function Message()
			-- message_done = 0 -- used by function AutoClear

			-- if TL_Keep_secondary_sounds == "activate" then
				-- big_bubble( 50, 20, "Speedy Copilot T319 " .. version_text_troiscentvingt .. ". Welcome !" )
			-- else
				-- big_bubble( 50, 20, "Speedy Copilot T319 " .. version_text_troiscentvingt .. ". Welcome !", "Secondary sounds deactivated in ToLiss_A319-options.lua.")
			-- end
		-- end

		FileNameES = SCRIPT_DIRECTORY .. "Speedycopilot_for_Toliss_options.lua"
		function ToLiss_A319_WriteSaveToDisk()

			if FF_initial_load == false then --saved only when previous state was fully aknowledged first
				fileES = io.open(FileNameES, "w")
				fileES:write('-- The New Speedy Copilot settings for the ToLiSs A319/A320/A321/A340-600 \n\n')

				if DelaysAPU == 1 then fileES:write('TL_The_PNF_delays_the_APU_on_departure = "activate"\n') else fileES:write('TL_The_PNF_delays_the_APU_on_departure = "deactivate"\n') end
				fileES:write('-- The APU start can be postponed (usually to comply with environmental regulations) until before start flow. ACTIVATE is default.\n\n')

				if AfterLandingWithAPU == 1 then fileES:write('TL_The_PNF_starts_the_APU_after_landing = "activate"\n') else fileES:write('TL_The_PNF_starts_the_APU_after_landing = "deactivate"\n') end
				fileES:write('-- The PM starts the APU in his after landing flow. DEACTIVATE is default.\n\n')

				if Park_is_PNF == 1 then fileES:write('TL_The_PNF_releases_PARK_BRK_with_chocks = "activate"\n') else fileES:write('TL_The_PNF_releases_PARK_BRK_with_chocks = "deactivate"\n') end
				fileES:write('-- Usually when chocks are in place, parking brake is released (FCOM 3.03.25). However, this is inactive by default because third-parties jetways will stay attached to the aircraft only if the parking brake is kept set. DEACTIVATE is default.\n\n')


				if FoTunesRadiosInPreparationFlow == 1 then fileES:write('TL_FoTunesRadiosInPreparationFlow = "activate"\n') else fileES:write('TL_FoTunesRadiosInPreparationFlow = "deactivate"\n') end
				fileES:write('-- PM will set 122.800 on COM1 and COM2, or not.\n\n')

				if TL_synchronizedFD == "activate" then fileES:write('TL_synchronizedFD = "activate"\n') else fileES:write('TL_synchronizedFD = "deactivate"\n') end
				fileES:write('-- The FO will keep his FD synchonized with the FD on Captain side.\n\n')

				if Pre_Conditioned_Air_Unit == 1 then fileES:write('TL_Low_pressure_air_requested_when_on_stand = "activate"\n') else fileES:write('TL_Low_pressure_air_requested_when_on_stand = "deactivate"\n') end
				fileES:write('-- You can request a pre-conditionned air unit. Normally you coordinate via interphone so as to not have both the Packs and LP air providing the mixer  unit simultaneously. ACTIVATE is default.\n\n')

				if GUI_DeckLights then fileES:write('Reduce_main_panel_lights = "activate"\n') else fileES:write('Reduce_main_panel_lights = "deactivate"\n') end
				fileES:write('-- Activating this will keep as set the main panel flood lights in approach and landing phases. DEACTIVATE is default.\n\n')

				if GUI_LandingLights then fileES:write('Minimises_landing_lights = "activate"\n') else fileES:write('Minimises_landing_lights = "deactivate"\n') end
				fileES:write('-- Activating this will make the PM retract early the landing lights instead of waiting for FL100. ACTIVATE is default.\n\n')

				if Say_Rotate == 1 then fileES:write('TL_Global_Say_Rotate = "activate"\n') else fileES:write('TL_Global_Say_Rotate = "deactivate"\n') end
				fileES:write('-- Deactivate this will remove "rotate" PM call. ACTIVATE is default.\n\n')

				if Say_Mins == 1 then fileES:write('TL_Global_Say_Mins = "activate"\n') else fileES:write('TL_Global_Say_Mins = "deactivate"\n') end
				fileES:write('-- Deactivate this will remove "Minimums" PM call for Baro minimums (MDA / DA). DEACTIVATE is default.\n\n')

				if Check_yaw == 1 then fileES:write('TL_Check_yaw_during_flight_controls_check = "activate"\n') else fileES:write('TL_Check_yaw_during_flight_controls_check = "deactivate"\n') end
				fileES:write('-- You can deactivate the yaw check if you do not have a rudder axis or if you want to ease the flight control process in the simulation. We recommand to let it activated here in the persistent option, and maybe deactivate it using the in-flight menu when temporary required. ACTIVATE is default.\n\n')

				if QuickGlance == 1 then fileES:write('TL_QuickGlance_option = "activate"\n') else fileES:write('TL_QuickGlance_option = "deactivate"\n') end
				fileES:write('-- When active, when you look towards approach path and runway area or when you turn a landing light on, the PM starts the runway entry flow. When inactive, only the light will signal the runway entry to the PM. ACTIVATE is default.\n\n')

				if Cabin_on_unlock == 1 then fileES:write('TL_Cabin_on_unlock = "activate"\n') else fileES:write('TL_Cabin_on_unlock = "deactivate"\n') end
				fileES:write('-- When active, the user can use the pedestal cabin lock mecanism to jump instantly to the cabin..\n\n')

				if Online_transponder == 1 then fileES:write('TL_online_transponder_option = "activate"\n') else fileES:write('TL_online_transponder_option = "deactivate"\n') end
				fileES:write('-- When active, transponder is kept OFF (it used to be an IVAO rule) during all taxi operations..\n\n')

				if JAR_Ground_Handling_wanted == 1 then fileES:write('TL_Use_GHD_airstairs_at_gate = "activate"\n') else fileES:write('TL_Use_GHD_airstairs_at_gate = "deactivate"\n') end
				fileES:write('-- You will be serviced by the GHD airstairs when doors on the left are open. Turning that OFF is great for users who do not use third-party airstairs. DEACTIVATE is default.\n\n')

				if forward_JARstairs_wanted == 1 then fileES:write('TL_Use_GHD_airstairs_at_left_forw_door = "activate"\n') else fileES:write('TL_Use_GHD_airstairs_at_left_forw_door = "deactivate"\n') end
				fileES:write('-- If a jetway is attached to the 1L door, native stairs can be removed at that door. ACTIVATE is default.\n\n')


				if normal_messages == 1 then fileES:write('TL_Display_normal_messages = "activate"\n') else fileES:write('TL_Display_normal_messages = "deactivate"\n') end
				fileES:write('-- With "activate" all text messages are displayed. Keeping this is higly recommanded. ACTIVATE is default.\n\n')

				if VR_message == 1 then fileES:write('TL_VR_message = "activate"\n') else fileES:write('TL_VR_message = "deactivate"\n') end
				fileES:write('-- With "activate" text messages are displayed in a virtual reality compatible format in a popup window. DEACTIVATE is default.\n\n')

				if transfer_exterior_lights_to_the_PM_on_ground then fileES:write('TL_transfer_exterior_lights_to_the_PM_on_ground = "activate"\n') else fileES:write('TL_transfer_exterior_lights_to_the_PM_on_ground = "deactivate"\n') end
				fileES:write('-- With "activate" the landing lights and strobe lights will be actuated by the PM on line-up clearance. 2021 Airbus procedures have normally transferred that action to the PF, therefore  DEACTIVATE is default.\n\n')



				fileES:write('-- -- Following option(s) are only edited by hand in this config file -- --\n')
				-- edited manually
				if TL_Keep_secondary_sounds == "activate" then fileES:write('TL_Keep_secondary_sounds = "activate"\n') else fileES:write('TL_Keep_secondary_sounds = "deactivate"\n') end
				fileES:write('-- FlyWithLua has a limit of wave files. Deactivating this removes some flight attendants and passengers sounds. ACTIVATE is default.\n\n')

				fileES:write('\n-- -- -- NOISE ABATEMENT PROCEDURE\n-- NADP 2 (Noise Abatement Departure Procedure 2) is : \n-- On reaching an altitude equivalent to at least 800 feet AGL (TL_thrust_reduction_altitude), decrease aircraft body angle whilst maintaining a positive rate of climb, accelerate towards Flaps Up speed and reduce thrust with the initiation of the first flaps/slats retraction or reduce thrust after flaps/slats retraction.\n-- At 3000 feet AGL (TL_Accel_Altitude), accelerate to normal en-route climb speed.\nTL_thrust_reduction_altitude = ' .. TL_thrust_reduction_altitude .. ' -- AGL\nTL_Accel_Altitude = ' .. TL_Accel_Altitude)

				fileES:write('\n-- This can be edited by hand when X-Plane is not running. It is overwritten when X-Plane is running.\n-- In flight, YOU MUST change options via the X-Plane menu.')
				fileES:write('\n-- Only two values are acceptable : "activate" or "deactivate".')
				fileES:close()
			end
		end
		--########################################
		--# PUB. ADRESS, DECK AND COPILOT SOUNDS #
		--########################################
		-- sounds
		-- (I learnt how to do sounds this thanks to Tom Stian here :
		-- http:..forums.x-pilot.com/files/file/1029-vspeed-callouts-for-ixeg-733/)
		-- if TL_Keep_secondary_sounds == "activate"  is set in the separate options.lua
		print("FlyWithLua Info: Speedy Copilot referencing the sound files - sounds marker 0")
		PacksOff1and2_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_PacksOff1and2.wav")
		BrakeFans_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_BrakeFans.wav")
		TakeoffDecision_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_320_V1.wav")
		TakeoffRotate_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_320_VR.wav")
		--TakeoffReference_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_319_V2.wav")
		Minimums_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Minimums.wav")
		ApproachingMinimums_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_ApproachingMinimums.wav")
		if TL_Keep_secondary_sounds == "activate" then
			BGSound2_Sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_GRD_background2.wav")
			Hi_Sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_GRD_Hi.wav")
			CoughSound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Cough.wav")
			HumSound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Hum.wav")
			CockpitPrepFO_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_PROC_prep_ann.wav")
			CockpitPrepFO2_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_PROC_prep_ann2.wav")
			ZFW_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_DataInsertionZfw.wav")
			IRSAlign_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_IRSAlignement.wav")
		end
		--print("FlyWithLua Info : [Speedy Copilot] Sounds marker 1")
		Preliminary_sound = 	load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_PROC_prelim.wav")
		Preparation_sound = 	load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_PROC_prep.wav")
		Preparation2_sound = 	load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_PROC_prep2.wav")
		Afterstart_sound = 		load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_PROC_afterstart.wav")
		Beforestart_sound = 	load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Before_start_procedure_done.wav")
		Start1_sound = 			load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Starting_One.wav")
		Start2_sound = 			load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Starting_Two.wav")
		Start3_sound = 			load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_16_Starting3.wav")
		Start4_sound = 			load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_15_Starting4.wav")
		FlightControlsCheck_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_FlightControlsCheck.wav")
		Checked_sound = 		load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Checked.wav")
		FlightControlsCheck_complete_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_FCCheckComplete.wav")
		TOmemo_sound = 			load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_TOmemo.wav")
		TOmemo_variant_sound =  load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_TOmemo2.wav")
		Beforetaxi_sound = 		load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_PROC_taxi.wav")
		THRUSTSET_sound = 		load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_THRUSTSET.wav")
		TAKEOFF_sound = 		load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_TO.wav")
		PositiveRate_sound = 	load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Positive_Climb.wav")
		FlapsRunning_sound = 	load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Flapsrunning.wav")
		FlapsUp_sound = 		load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_FlapsUp_running.wav")
		GearUp_sound = 			load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Gear_Up.wav")
		GearUp2_sound = 		load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Gear_Up.wav")
		--print("FlyWithLua Info : [Speedy Copilot] Sounds marker 2")
		RunwayEntry_sound = 	load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Runway_entry_procedure.wav")
		FL100_sound = 			load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_FL100.wav")
		FL100D_sound =			load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_FL100.wav")
		TOflapsQ_sound = 		load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_TOFlapsQ.wav")
		--print("FlyWithLua Info : [Speedy Copilot] Sounds marker 2.1")
		APP_flaps1_sound = 		load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Flaps1.wav")
		APP_flaps2_sound = 		load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Flaps2.wav")
		APP_flaps3_sound = 		load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Flaps3.wav")
		APP_flaps3FC_sound =	load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Flaps3_FinalConfig.wav")
		APP_flapsFull_sound = 	load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_FlapsFull.wav")
		APP_flaps3_expect_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Flaps3_expected.wav")
		--APP_flapsFull_expect = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_FlapsFull_expected.wav")
		--print("FlyWithLua Info : [Speedy Copilot] Sounds marker 2.25")
		GroundSpoilers_sound =	 load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_SpoilerDeployed.wav")
		ReverseGreen_sound =	 load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_ReverseGreen.wav")
		seventyknots_sound =	 load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_70kts.wav") -- 1
		OneHundredknots_sound =	 load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_100kts.wav") -- 2
		Deceleration_sound = 	 load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Decel_s.wav")
		RADIOALIVE_sound = 		 load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_RadioAltAlive.wav") -- 4
		AfterLanding3_sound = 	 load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_After_landing_procedure_done.wav")
		--print("FlyWithLua Info : [Speedy Copilot] Sounds marker 2.5")
		if TL_Keep_secondary_sounds == "activate" then Lights_and_doors_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Lights_and_doors.wav") end
		Arrived_sound = 		load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_AtGate.wav")
		Typing_sound = 			load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Typing.wav")
		O2MaskTest_sound = 		load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_O2_test.wav")
		CabinNotReady_sound = 	load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_CabinNotReady.wav")
		Boarding_Music = 		load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Annoucements/Boarding_muzac.wav")
		if TL_Keep_secondary_sounds == "activate" then Boarding_Music_alternative = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Annoucements/DarrenCurtis-JourneysReflection.wav") end
		--------------- Added sounds JZ begins ---
		Fulldown_s = 			load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FCTL/stereo_fulldown.wav") -- 9
		Fullleft_s = 			load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FCTL/stereo_fullleft.wav") -- 5
		Fullright_s = 			load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FCTL/stereo_fullright.wav") -- 6
		Neutral_s = 			load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FCTL/stereo_neutral.wav") -- 7
		Fullup_s = 				load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FCTL/stereo_fullup.wav") -- 8
		Onetogo_s = 			load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_1000togo.wav")
		--------------- Added sounds JZ stops ---
		--GC v1.3
		--print("FlyWithLua Info : [Speedy Copilot] Sounds marker 3")
		ChocksGPU_removed_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/GroundCrew/stereo_ChocksGPU_removed.wav")
		LP_air_unit_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/GroundCrew/stereo_LP_air_unit.wav")
		LP_air_unit_removed_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/GroundCrew/stereo_LP_air_unit_removed.wav")
		-- FA
		CabinReady_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_CabinReady.wav")
		if TL_Keep_secondary_sounds == "activate" then
			CabinReady2_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_CabinReady2.wav")
			CabinReady3_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_CabinReady3.wav")
			CabinReady4_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_CabinReady4.wav")
		end
		DoorsClosed_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_DoorsClosed.wav")
		Safety_Ann_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Annoucements/stereo_Safety_Ann.wav")
		Belts_Ann_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Annoucements/stereo_Belts_Ann.wav")
		if TL_Keep_secondary_sounds == "activate" then
			DoorsClosed2_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_DoorsClosed2.wav")
			CabinCold_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/stereo_Coldintheback.wav")
			CabinRelease_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Annoucements/stereo_Climbing_Ann.wav")
			Boarding_Ann_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Annoucements/stereo_Boarding_Ann.wav")
			Arrival_Ann_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Annoucements/stereo_Arrival_Ann.wav")
			Descent_Ann_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Annoucements/stereo_Descent_Ann.wav")
		end
		-- 2023 CABIN INTERPHONE
		Cabin_interphone_1_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Annoucements/stereo_Cabin_interphone_1.wav")
		Cabin_interphone_2_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Annoucements/stereo_Cabin_interphone_2.wav")
		--~ Cabin_interphone_3_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Annoucements/stereo_Belts_Ann.wav")
		--~ Cabin_interphone_4_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Annoucements/stereo_Belts_Ann.wav")
		Cabin_interphone_TO_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Annoucements/stereo_Cabin_interphone_TO.wav")
		Cabin_interphone_ArmDoors_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Annoucements/stereo_Cabin_interphone_ArmDoors.wav")
		Cabin_interphone_DoorsManual_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Annoucements/stereo_Cabin_interphone_DoorsManual.wav")
		let_sound_loop(Cabin_interphone_1_sound, true)
		let_sound_loop(Cabin_interphone_2_sound, true)
		--~ let_sound_loop(Cabin_interphone_3_sound, true)
		--~ let_sound_loop(Cabin_interphone_4_sound, true)
		-- FMA annoucement by F/O
		-- AT
		ALPHA_FLOOR_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/stereo_ALPHA_FLOOR.wav")
		MAN_FLEX_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/stereo_MAN_FLEX.wav")
		MAN_TOGA_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/stereo_MAN_TOGA.wav")
		if TL_Keep_secondary_sounds == "activate" then SPEED_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/stereo_SPEED.wav") end
		if TL_Keep_secondary_sounds == "activate" then TOGA_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/stereo_TOGA.wav") end
		-- Vertical
		--print("FlyWithLua Info : [Speedy Copilot] Sounds marker 4")
		alt_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_alt.wav")
		altstar_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_altstar.wav")
		altblue_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_altBlue.wav")
		climb_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_climb.wav")
		DES_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_DES.wav")
		expediteDescent_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_EXP_DES.wav")
		expediteClimb_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_EXP_CLB.wav")
		FinalApp_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_FinalApp.wav")
		FPA_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_FPA.wav")
		Glideslope_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_Glideslope.wav")
		Glidestar_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_Glidestar.wav")
		Glideblue_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_GlideslopeBlue.wav")
		openclimb_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_openclimb.wav")
		opendescent_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_opendescent.wav")
		VS_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_VS.wav")
		SRS_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/VerticalMode/stereo_SRS.wav")
		-- Lateral
		--print("FlyWithLua Info : [Speedy Copilot] Sounds marker 5")
		HDG_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/LateralMode/stereo_HDG.wav")
		LOC_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/LateralMode/stereo_LOC.wav")
		LOCstar_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/LateralMode/stereo_LOCstar.wav")
		LOCBlue_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/LateralMode/stereo_LOCBlue.wav")
		nav_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/LateralMode/stereo_nav.wav")
		navblue_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/LateralMode/stereo_navBlue.wav")
		RollOut_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/LateralMode/stereo_RollOut.wav")
		RWY_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/LateralMode/stereo_RWY.wav")
		TRK_sound = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/FMA/LateralMode/stereo_TRK.wav")
		-- Pax
		--print("FlyWithLua Info : [Speedy Copilot] Sounds marker 6")
		if TL_Keep_secondary_sounds == "activate" then
			Deb1 = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Passengers/stereo_deboarding1.wav")
			Deb2 = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Passengers/stereo_deboarding2.wav")
			Deb3 = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Passengers/stereo_deboarding3.wav")
			Deb4 = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Passengers/stereo_deboarding4.wav")
			Deb5 = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Passengers/stereo_deboarding5.wav")
			Deb6 = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Passengers/stereo_deboarding6.wav")
			Deb7 = load_WAV_file(SCRIPT_DIRECTORY .. "Speedy_Copilot_for_ToLiSs/sounds/Passengers/stereo_deboarding7.wav")
		end
		--print("FlyWithLua Info : [Speedy Copilot] Sounds marker ends")
		-- Made with "natural reader online"

		-- Sounds level
		-- Main "SoundLevel" variable was set above.
		PALevel = 0.0001
		INTLevel = 0.0001
		CABLevel = 0.0001
		NOISELevel = 0.0001
		MusicLevel = 0.0001
		set_sound_gain(TakeoffDecision_sound, 1) -- this sound is part of the system
		-- some sounds settings are inside a function to allow to mute them
		--PM sounds



		function Generalsounds()
			if TL_Keep_secondary_sounds == "activate" then
				set_sound_gain(Lights_and_doors_sound, SoundLevel)
				set_sound_gain(BGSound2_Sound, SoundLevel)
				set_sound_gain(CoughSound, SoundLevel)
				set_sound_gain(Hi_Sound, SoundLevel)
				set_sound_gain(HumSound, SoundLevel)
				set_sound_gain(CockpitPrepFO_sound, SoundLevel)
				set_sound_gain(CockpitPrepFO2_sound, SoundLevel)
				set_sound_gain(ZFW_sound, SoundLevel)
				set_sound_gain(IRSAlign_sound, JZLevel)
			end
			set_sound_gain(ApproachingMinimums_sound, SoundLevel)
			set_sound_gain(Minimums_sound, SoundLevel)
			set_sound_gain(PacksOff1and2_sound, SoundLevel)
			set_sound_gain(BrakeFans_sound, SoundLevel)
			set_sound_gain(Typing_sound, SoundLevel)
			set_sound_gain(Beforestart_sound, SoundLevel)
			set_sound_gain(Start1_sound, JZLevel) -- JZ
			set_sound_gain(Start2_sound, JZLevel) -- JZ
			set_sound_gain(Start3_sound, JZLevel) -- JZ
			set_sound_gain(Start4_sound, JZLevel) -- JZ
			set_sound_gain(Beforetaxi_sound, SoundLevel)
			set_sound_gain(TAKEOFF_sound, SoundLevel) -- 11
			set_sound_gain(PositiveRate_sound, SoundLevel)
			set_sound_gain(FlapsRunning_sound, SoundLevel)
			set_sound_gain(FlapsUp_sound, SoundLevel)
			set_sound_gain(GearUp_sound, SoundLevel)
			set_sound_gain(GearUp2_sound, SoundLevel)
			set_sound_gain(RunwayEntry_sound, SoundLevel)
			set_sound_gain(FL100_sound, JZLevel) -- JZ
			set_sound_gain(FL100D_sound, JZLevel) -- JZ
			set_sound_gain(TOflapsQ_sound, SoundLevel)
			set_sound_gain(APP_flaps1_sound, JZLevel)
			set_sound_gain(APP_flaps2_sound, JZLevel)
			set_sound_gain(APP_flaps3_sound, JZLevel)
			set_sound_gain(APP_flaps3FC_sound, JZLevel) -- 10
			set_sound_gain(APP_flapsFull_sound, SoundLevel)
			set_sound_gain(AfterLanding3_sound, SoundLevel)
			set_sound_gain(Arrived_sound, SoundLevel)
			set_sound_gain(O2MaskTest_sound, O2Level)
			set_sound_gain(CabinNotReady_sound, SoundLevel)
			--set_sound_gain(APP_flapsFull_expect, SoundLevel)
			set_sound_gain(APP_flaps3_expect_sound, SoundLevel)
			set_sound_gain(FlightControlsCheck_sound, SoundLevel)
			set_sound_gain(Checked_sound, 0.5)
			set_sound_gain(FlightControlsCheck_complete_sound, SoundLevel)
			set_sound_gain(TOmemo_sound, SoundLevel)
			set_sound_gain(TOmemo_variant_sound, SoundLevel)
			set_sound_gain(Preliminary_sound, SoundLevel)
			set_sound_gain(Preparation_sound, SoundLevel)
			set_sound_gain(Preparation2_sound, SoundLevel)
			set_sound_gain(Afterstart_sound, SoundLevel)
			set_sound_gain(Beforestart_sound, SoundLevel)
			--set_sound_gain(TakeoffDecision_sound, SoundLevel) -- set above
			set_sound_gain(TakeoffRotate_sound, 0.75)
			--set_sound_gain(TakeoffReference_sound, 0.0001) -- muted, never said in the real aircraft
			set_sound_gain(GroundSpoilers_sound, SoundLevel)
			set_sound_gain(ReverseGreen_sound, SoundLevel)
			set_sound_gain(THRUSTSET_sound, SoundLevel) -- 0
			set_sound_gain(seventyknots_sound, SoundLevel) -- 1
			set_sound_gain(OneHundredknots_sound, SoundLevel) -- 2
			set_sound_gain(Deceleration_sound, SoundLevel) --  3
			set_sound_gain(RADIOALIVE_sound, SoundLevel) -- 4
			set_sound_gain(Fullleft_s, JZLevel) -- 5
			set_sound_gain(Fullright_s, JZLevel) --6
			set_sound_gain(Fullup_s, JZLevel) -- 7
			set_sound_gain(Fulldown_s, JZLevel) -- 8
			set_sound_gain(Neutral_s, JZLevel) -- 9
			--Ajout JZ
			set_sound_gain(Onetogo_s, SoundLevel)
			--Fin Ajout JZ
			if TL_Keep_secondary_sounds == "activate" then
				set_sound_gain(Deb1, PassengerLevel)
				set_sound_gain(Deb2, PassengerLevel)
				set_sound_gain(Deb3, PassengerLevel)
				set_sound_gain(Deb4, PassengerLevel)
				set_sound_gain(Deb5, PassengerLevel)
				set_sound_gain(Deb6, PassengerLevel)
				set_sound_gain(Deb7, PassengerLevel)
			end
		end
		do_often("Generalsounds()") --do_every_frame enforced


		function Fmasounds()
			set_sound_gain(HDG_sound, SoundLevel)
			set_sound_gain(LOC_sound, SoundLevel)
			set_sound_gain(LOCstar_sound, SoundLevel)
			set_sound_gain(LOCBlue_sound, SoundLevel)
			set_sound_gain(nav_sound, SoundLevel)
			set_sound_gain(navblue_sound, SoundLevel)
			set_sound_gain(RollOut_sound, SoundLevel)
			set_sound_gain(RWY_sound, SoundLevel)
			set_sound_gain(TRK_sound, SoundLevel)
			set_sound_gain(alt_sound, SoundLevel)
			set_sound_gain(altstar_sound, SoundLevel)
			set_sound_gain(altblue_sound, SoundLevel)
			set_sound_gain(climb_sound, SoundLevel)
			set_sound_gain(DES_sound, SoundLevel)
			set_sound_gain(expediteDescent_sound, JZLevel)
			set_sound_gain(expediteClimb_sound, JZLevel)
			set_sound_gain(FinalApp_sound, SoundLevel)
			set_sound_gain(FPA_sound, SoundLevel)
			set_sound_gain(Glideslope_sound, SoundLevel)
			set_sound_gain(Glidestar_sound, SoundLevel)
			set_sound_gain(Glideblue_sound, SoundLevel)
			set_sound_gain(openclimb_sound, SoundLevel)
			set_sound_gain(opendescent_sound, SoundLevel)
			set_sound_gain(SRS_sound, SoundLevel)
			set_sound_gain(VS_sound, SoundLevel)
			set_sound_gain(ALPHA_FLOOR_sound, SoundLevel)
			set_sound_gain(MAN_FLEX_sound, SoundLevel)
			set_sound_gain(MAN_TOGA_sound, SoundLevel)
			if TL_Keep_secondary_sounds == "activate" then set_sound_gain(SPEED_sound, SoundLevel) end
			if TL_Keep_secondary_sounds == "activate" then set_sound_gain(TOGA_sound, SoundLevel) end
		end
		do_often("Fmasounds()")
		-- some sounds settings are inside a function to allow to mute PA annoucements			set_sound_gain(Safety_Ann_sound, PALevel)

		set_sound_gain(Belts_Ann_sound, PALevel)
		if TL_Keep_secondary_sounds == "activate" then
			set_sound_gain(Boarding_Ann_sound,PALevel)
			set_sound_gain(CabinRelease_sound, PALevel)
			set_sound_gain(Arrival_Ann_sound, PALevel)
			set_sound_gain(Descent_Ann_sound, PALevel)
		end
		function PAsounds()
			set_sound_gain(Safety_Ann_sound, PALevel)
			set_sound_gain(Belts_Ann_sound, PALevel)
			if TL_Keep_secondary_sounds == "activate" then
				set_sound_gain(Boarding_Ann_sound,PALevel)
				set_sound_gain(CabinRelease_sound, PALevel)
				set_sound_gain(Arrival_Ann_sound, PALevel)
				set_sound_gain(Descent_Ann_sound, PALevel)
			end
		end
		do_often("PAsounds()") -- do_every_frame it must be

		function IFEsounds()
			set_sound_gain(Boarding_Music, MusicLevel)
			if TL_Keep_secondary_sounds == "activate" then
				set_sound_gain(Boarding_Music_alternative, MusicLevel)
			end
		end
		do_often("IFEsounds()") -- do_every_frame it must be


		set_sound_gain(ChocksGPU_removed_sound, INTLevel)
		set_sound_gain(LP_air_unit_sound,INTLevel)
		set_sound_gain(LP_air_unit_removed_sound,INTLevel)
		function INTsounds()
			set_sound_gain(ChocksGPU_removed_sound, INTLevel)
			set_sound_gain(LP_air_unit_sound,INTLevel)
			set_sound_gain(LP_air_unit_removed_sound,INTLevel)
		end
		do_often("INTsounds()")

		set_sound_gain(CabinReady_sound, CABLevel)
		set_sound_gain(DoorsClosed_sound, CABLevel)
		if TL_Keep_secondary_sounds == "activate" then
			set_sound_gain(DoorsClosed2_sound, CABLevel)
			set_sound_gain(CabinReady2_sound, CABLevel)
			set_sound_gain(CabinReady3_sound, CABLevel)
			set_sound_gain(CabinReady4_sound, CABLevel)
			set_sound_gain(CabinCold_sound, CABLevel)
		end
		set_sound_gain(Cabin_interphone_1_sound, CABLevel)
		set_sound_gain(Cabin_interphone_2_sound, CABLevel)
		set_sound_gain(Cabin_interphone_TO_sound, CABLevel)
		set_sound_gain(Cabin_interphone_TO_sound, CABLevel)
		set_sound_gain(Cabin_interphone_ArmDoors_sound, CABLevel)
		set_sound_gain(Cabin_interphone_DoorsManual_sound, CABLevel)
		function CABsounds()
			set_sound_gain(CabinReady_sound, CABLevel)
			set_sound_gain(DoorsClosed_sound, CABLevel)
			if TL_Keep_secondary_sounds == "activate" then
				set_sound_gain(DoorsClosed2_sound, CABLevel)
				set_sound_gain(CabinReady2_sound, CABLevel)
				set_sound_gain(CabinReady3_sound, CABLevel)
				set_sound_gain(CabinReady4_sound, CABLevel)
				set_sound_gain(CabinCold_sound, CABLevel)
			end
			set_sound_gain(Cabin_interphone_1_sound, CABLevel)
			set_sound_gain(Cabin_interphone_2_sound, CABLevel)
			set_sound_gain(Cabin_interphone_TO_sound, CABLevel)
			set_sound_gain(Cabin_interphone_ArmDoors_sound, CABLevel)
			set_sound_gain(Cabin_interphone_DoorsManual_sound, CABLevel)
			--~ set_sound_gain(Cabin_interphone_3_sound, CABLevel)
			--~ set_sound_gain(Cabin_interphone_4_sound, CABLevel)
		end
		do_often("CABsounds()")
		-- init
		PA_trigger = 2
		--Muz_trigger = -13
		Muz_trigger = 0 -- SC 4.4
		--########################################
		--# Announcements and Boarding music      #
		--########################################

		function AnnouncementTriggers()
			if not SpeedyCopilot_first_load then

				-- ok, we don't have a full ACP in the ToLiss 319 so far
				-- we'll do simple stuff in contrast with other editions of Speedy Copilot
				-- when the pilot head y axis is in the rear cabin, that triggers the PA, IFE, and so on.
				-- instead of having those functions linked with the Capt ACP.

				-- edited January 2023, now the ACP are more complete, and the PA receiver exists

				-- ToLiss A319 PA (if inside cabin) and IFE
				if pilots_head_y > -10.9 and view_is_external == 0 then
					if MuteCabinRelatedSounds == 0 then
						PALevel = 0.6
						MusicLevel = 0.15
					else
						PALevel = 0.0001
						MusicLevel = 0.0001
					end
				elseif ACP1_PA == 1 or ACP2_PA == 1 or ACP3_PA == 1 then
					if MuteCabinRelatedSounds == 0 then
						if FBW_AuralVolume >  0.3 then	PALevel = FBW_AuralVolume else PALevel = 0.3 end
						MusicLevel = 0.0001
					else
						PALevel = 0.0001
						MusicLevel = 0.0001
					end
				else
					if MuteCabinRelatedSounds == 0 then
						PALevel = 0.02
						MusicLevel = 0.005
					else
						PALevel = 0.0001
						MusicLevel = 0.0001
					end
				end

				-- LISTEN TO SERVICE INTERPHONE and CABIN INTERPHONE
				if view_is_external == 1 then
						if CABLevel > 0.0000000000000001 then stop_sound(Cabin_interphone_1_sound) end
						if CABLevel > 0.0000000000000001 then stop_sound(Cabin_interphone_2_sound) end
						CABLevel = 0.0000000000000001
				-- because if we seat outside the aircraft, we can listen to what external people say (but not the FA on the CAB INT)
				elseif ACP1_CAB == 1 or ACP2_CAB == 1 or ACP3_CAB == 1 then
					if MuteCabinRelatedSounds == 0 then
						if CABLevel == 0.0000000000000001 then play_sound(Cabin_interphone_1_sound) end
						if CABLevel == 0.0000000000000001 then play_sound(Cabin_interphone_2_sound) end
						if FBW_AuralVolume >  0.2 then	CABLevel = FBW_AuralVolume else CABLevel = 0.2 end
					else
						if CABLevel > 0.0000000000000001 then stop_sound(Cabin_interphone_1_sound) end
						if CABLevel > 0.0000000000000001 then stop_sound(Cabin_interphone_2_sound) end
						CABLevel = 0.0000000000000001
					end
				else
					if CABLevel > 0.0000000000000001 then stop_sound(Cabin_interphone_1_sound) end
					if CABLevel > 0.0000000000000001 then stop_sound(Cabin_interphone_2_sound) end
					CABLevel = 0.0000000000000001
				end


				if view_is_external == 1 then
						INTLevel = 1
				-- because if we seat outside the aircraft, we can listen to what external people say (but not the FA on the CAB INT)
				elseif ACP1_INT == 1 or ACP2_INT == 1 or ACP3_INT == 1 then
					if MuteCabinRelatedSounds == 0 then
						if FBW_AuralVolume >  0.4 then	INTLevel = FBW_AuralVolume else INTLevel = 0.4 end
					else
						INTLevel = 0.0000000000000001
					end
				else
					INTLevel = 0.0000000000000001
				end


				-- FASTEN YOUR SEAT BELT ANNOUCEMENT (in flight)
				if SeatBeltSignsOn == 1 and Belts_trigger == 0 and AirbusFBW_ALTFO >= 11001 then
					play_sound(Belts_Ann_sound)
					Belts_trigger = 2
				end

				-- SHORTCUT TO GO IN THE CABIN (ie UNLOCK THE FLT DECK DOOR)
				-- -- -- function wing_observer()
					if Cabin_on_unlock == 1 and doorLock == 0 then
						randomView = math.random()
						if randomView > 0.3 then
						command_once("toliss_airbus/3d_cockpit_commands/wing_observer")
						else
						command_once("toliss_airbus/3d_cockpit_commands/engine_observer")
						end
						doorLock = 1
					end
				-- -- -- end
				-- -- -- do_often("wing_observer()")
			end
		end
		do_often("AnnouncementTriggers()") -- less heavy than other editions !

		--play_sound(Boarding_Music) --debug only
		--play_sound(Safety_Ann_sound)

		-- Announcements and Boarding music ends
		--########################################
		--# F/O FMA Monitoring sound	         # -- added in revision 3.1
		--########################################
		srs_played = 0 altstar_played = 0 alt_played = 0 climb_played = 0 od_played = 0 oc_played = 0 fpa_played = 0 vs_played = 0 glide_played = 0 glidestar_played = 0 des_played = 0
		hdg_played = 0 trk_played = 0 loc_played = 0 locstar_played = 0 runway_played = 0 nav_played = 0 final_played = 0 rollout_played = 0
		at_played = 0 speed_played = 0 man_played = 0 afloor_played = 0
		verticalblue_played = 0 vertical_played = 0 lateralblue_played = 0


		function FmaMonitoring()
			if not SpeedyCopilot_first_load then
				if altitudeAGL > 400 then
					-- "%" fonctionne comme un caractère d'échappement pour les caractères magiques.
					if string.match(FMAmodes, "ALT%*") and altstar_played == 0 then play_sound(altstar_sound) altstar_played = 1 srs_played = 0 alt_played = 0 climb_played = 0 od_played = 0 oc_played = 0 fpa_played = 0 vs_played = 0
					elseif string.match(FMAmodes, "CST%*") and altstar_played == 0 then play_sound(altstar_sound) altstar_played = 1 srs_played = 0 alt_played = 0 climb_played = 0 od_played = 0 oc_played = 0 fpa_played = 0 vs_played = 0
					elseif string.match(FMAmodes, "ALT ") and alt_played == 0 then play_sound(alt_sound) alt_played = 1 climb_played = 0 des_played = 0 od_played = 0 oc_played = 0 altstar_played = 0 fpa_played = 0 vs_played = 0 vertical_played = 0
					elseif string.match(FMAmodes, "CST") and alt_played == 0 then play_sound(alt_sound) alt_played = 1 climb_played = 0 des_played = 0 od_played = 0 oc_played = 0 altstar_played = 0 fpa_played = 0 vs_played = 0 vertical_played = 0
					elseif string.match(FMAmodes, "FPA") and fpa_played == 0 then play_sound(FPA_sound) fpa_played = 1 srs_played = 0 altstar_played = 0
					elseif string.match(FMAmodes, "VS") and vs_played == 0 then play_sound(VS_sound) vs_played = 1 srs_played = 0 altstar_played = 0
					elseif string.match(FMAmodes, "DES") and not string.match(FMAmodes, "OP")  and not string.match(FMAmodes, "EXP")  and des_played == 0 then play_sound(DES_sound) des_played = 1 altstar_played = 0
					elseif string.match(FMAmodes, "G/S%*") and glidestar_played == 0 then play_sound(Glidestar_sound) glidestar_played = 1 glide_played = 0
					elseif string.match(FMAmodes, "G/S ") and glide_played == 0 then play_sound(Glideslope_sound) glide_played = 1 rollout_played = 0 LoadApprPerfPage()
					elseif string.match(FMAmodes, "OP CLB") and oc_played == 0 then play_sound(openclimb_sound) oc_played = 1 srs_played = 0 od_played = 0 climb_played = 0 altstar_played = 0 fpa_played = 0 vs_played = 0
					elseif string.match(FMAmodes, "CLB") and not string.match(FMAmodes, "OP")  and not string.match(FMAmodes, "EXP") and climb_played == 0 then play_sound(climb_sound) climb_played = 1 srs_played = 0 des_played = 0 od_played = 0 oc_played = 0 altstar_played = 0 fpa_played = 0 vs_played = 0
					elseif string.match(FMAmodes, "OP DES") and od_played == 0 then play_sound(opendescent_sound) od_played = 1 des_played = 0 climb_played = 0 oc_played = 0 altstar_played = 0 fpa_played = 0 vs_played = 0
					end
					-- else
						-- srs_played = 0 altstar_played = 0 alt_played = 0 climb_played = 0 od_played = 0 oc_played = 0 fpa_played = 0 vs_played = 0 glide_played = 0 glidestar_played = 0 des_played = 0
					-- end

					-- EXPED
					if string.match(FMAmodes, "EXP CLB")  and vertical_played ~= 7 and verticalspeed > 100 then 	play_sound(expediteClimb_sound) vertical_played = 7 end
					if string.match(FMAmodes, "EXP DES") and vertical_played ~= 6 and verticalspeed < -100 then 	play_sound(expediteDescent_sound) vertical_played = 6 end

					-- Blue
					if string.match(BlueModes, "GS") and verticalblue_played ~= 9 and VerticalMode ~= 16 and VerticalMode ~= 8 then  play_sound(Glideblue_sound) verticalblue_played = 9 end
					--if string.match(BlueModes, "ALT") and verticalblue_played ~= 8 then  play_sound(altblue_sound) verticalblue_played = 8 end
					if not string.match(BlueModes, "G/S") and not string.match(BlueModes, "ALT") and VerticalModeBlue ~= 56 then verticalblue_played = 0 end

				end
				--if string.match(FMAmodes, "SRS") and srs_played == 0 and man_played == 1 then play_sound(SRS_sound) srs_played = 1 des_played = 0 od_played = 0 oc_played = 0 altstar_played = 0 fpa_played = 0 vs_played = 0 end

				if altitudeAGL > 400 then
					if string.match(FMAmodes, "NAV") and nav_played == 0 then play_sound(nav_sound) nav_played = 1 loc_played = 0 hdg_played = 0 trk_played = 0 locstar_played = 0 runway_played = 0 final_played = 0 rollout_played = 0 end
					if string.match(FMAmodes, "HDG") and hdg_played == 0 then play_sound(HDG_sound) hdg_played = 1 loc_played = 0 trk_played = 0 locstar_played = 0 runway_played = 0 nav_played = 0 final_played = 0 rollout_played = 0 end
					if string.match(FMAmodes, "TRACK") and trk_played == 0 then play_sound(TRK_sound) trk_played = 1 loc_played = 0 hdg_played = 0 locstar_played = 0 runway_played = 0 nav_played = 0 final_played = 0 rollout_played = 0 end
					if string.match(FMAmodes, "LOC%*") and locstar_played == 0 then play_sound(LOCstar_sound) locstar_played = 1 loc_played = 0 hdg_played = 0 trk_played = 0 runway_played = 0 nav_played = 0 final_played = 0 rollout_played = 0 end
					if string.match(FMAmodes, "LOC ") and loc_played == 0 then play_sound(LOC_sound) loc_played = 1 locstar_played = 0  hdg_played = 0 trk_played = 0 locstar_played = 0 runway_played = 0 nav_played = 0 final_played = 0 rollout_played = 0 end
					-- BLUE MODES
					if string.match(BlueModes, "LOC") and lateralblue_played ~= 9 then  play_sound(LOCBlue_sound) lateralblue_played = 9 end
					if string.match(BlueModes, "NAV") and lateralblue_played ~= 8 then  play_sound(navblue_sound) lateralblue_played = 8 end
					if not string.match(BlueModes, "LOC") and not string.match(BlueModes, "NAV") then lateralblue_played = 0 end
				end
				--if string.match(FMAmodes, "RWY") and runway_played == 0 and srs_played == 1 then play_sound(RWY_sound) runway_played = 1 loc_played = 0 hdg_played = 0 trk_played = 0 locstar_played = 0 nav_played = 0 final_played = 0 rollout_played = 0 end

				if string.match(FMAmodes, "FINAL APP") and final_played == 0 then play_sound(FinalApp_sound) final_played = 1 end

				--if string.match(FMAmodes, "ROLLOUT") and rollout_played == 0 then play_sound(RollOut) rollout_played = 1 speed_played = 0 end

				if string.match(FMAmodes, "IDLE") and at_played == 0 then  at_played = 1  speed_played = 0 man_played = 0 afloor_played = 0 end
				if (string.match(FMAmodes, "FLOOR") or string.match(FMAmodes, "TOGA LK")) and afloor_played == 0 then play_sound(ALPHA_FLOOR_sound) afloor_played = 1 speed_played = 0 end
				if string.match(FMAmodes, "SPEED") and not string.match(FMAmodes, "ALT%*") and speed_played == 0 then
						if TL_Keep_secondary_sounds == "activate" then play_sound(SPEED_sound) end
						speed_played = 1 man_played = 0
				end
				if string.match(FMAmodes, "MACH") and speed_played == 1 then
						speed_played = 0
				end

				--if string.match(FMAthr, "FLX") and man_played == 0 then play_sound(MAN_FLEX_sound) man_played = 1 speed_played = 0 end
				--if string.match(FMAthr, "TOGA") and man_played == 0 then play_sound(MAN_TOGA_sound) man_played = 1 speed_played = 0 end

			end
		end
		do_often("FmaMonitoring()")

		------------------------------------------
		-- One thousand to go (by JackZ at X-Plane.org)
		onetogo_trigger = 0
		function ONETOGO()
			if not SpeedyCopilot_first_load then
				-- after takeoff level 1
				if ToLissPNFonDuty == 1 and pressurealtitude >= 1000 then
					-- make the call of
					-- ((descending to a lower target altitude between 800 and 1000 ft lower) or (climb to a higher target altitude)) and call armed and ((not on GLIDESLOPE) or (not in FINAL APP))
					if ((AirbusFBW_ALTFO - target_alt <= 1000 and AirbusFBW_ALTFO - target_alt > 700 and verticalspeed < -200) or  (AirbusFBW_ALTFO - target_alt > -1000 and AirbusFBW_ALTFO - target_alt < -700 and verticalspeed > 200)) and onetogo_trigger == 0 and (VerticalMode ~= 8 or (VerticalMode ~= 32768 and LateralMode ~= 128)) then
					--if math.abs(target_alt - AirbusFBW_ALTFO) <= 1000 and math.abs(target_alt - AirbusFBW_ALTFO) > 500 and (verticalspeed > 200 or verticalspeed < -200) and onetogo_trigger == 0  then
						play_sound(Onetogo_s)
						onetogo_trigger = 2
					end
					-- arm the "on 1000 to go" call before reaching 1000 ft to go.
					if (math.abs(target_alt - AirbusFBW_ALTFO) > 1001 and math.abs(target_alt - AirbusFBW_ALTFO) <= 2000) or math.abs(target_alt - AirbusFBW_ALTFO) < 500 then 			onetogo_trigger = 0
					end
				end
			-- function close
			end
		end
		do_often("ONETOGO()")

		--------------------------------------------------------------------------------

		--########################################
		--# FLIGHT PROGRESS FUNCTIONS            #
		--########################################

		-- Execute PRELIMINARY COCKPIT PREP and COCKPIT PREPARATION Procedure
		-- Supplementary init
		proc_time = 0
		prep_time=0
		step = 0
		ground_stuff = 0
		FD_flag = 0
		QAnswered = 0
		local randomView = 0
		Toliss_chocks_set = 0


		function show_the_option_window() -- tempo, avoid undefined user crash reported on the forums
			-- FlyWithLua/Scripts/Speedycopilot_for_Toliss_script_5.lua:1829: attempt to call global 'show_the_option_window' (a nil value)
			-- since the code references a function defined at the end of the code. I reckon it was dangerous, but normally the function is not called from the early beginnings
			-- I don't know with the code would trigger the function so early, but this patch should cover that local user situation
		end

		function test_possible_failure(x) -- ie test if == 1
			if XPLMFindDataRef(x) ~= nil then
				temporary = dataref_table(x,"readonly")
				if temporary == 1 then -- a failure is detected by the CM2 on the checked system !
					display_bubble("Aircraft problem detected ! " .. x)
					if TL_Keep_secondary_sounds == "activate" then  play_sound(CoughSound) end
					-- DISPLAY VR message
					if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
						show_window_bottom_bar = true
						end_show_time = math.floor(os.clock()) + 20
						Message_wnd_content = ""    Message_wnd_content = "Problem detected ! " .. x
						Message_wnd_action = "vr_message_sent = false vr_message_sent = false "
						Message_wnd_duration = 20
						show_the_option_window()
					end
					-- End of VR Message
				end
				temporary = nil -- unload dataref
			end
		end

		function test_if_is_equal_to_value(x,y) -- ie test if == 0 (zero by default)
			if y == nil then y = 0 end
			if XPLMFindDataRef(x) ~= nil then
				temporary = dataref_table(x,"readonly")
				if temporary == 0 then -- value is detected zero
					display_bubble("Check " .. x)
					--if TL_Keep_secondary_sounds == "activate" then  play_sound(CoughSound) end
					-- DISPLAY VR message
					if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
						show_window_bottom_bar = true
						end_show_time = math.floor(os.clock()) + 20
						Message_wnd_content = ""    Message_wnd_content = "Check " .. x
						Message_wnd_action = "vr_message_sent = false "
						Message_wnd_duration = 20
						show_the_option_window()
					end
					-- End of VR Message
				end
				temporary = nil -- unload dataref
			end
		end


		-- Execute PRELIMINARY COCKPIT PREP
		function PRELIMINARY()
			if not SpeedyCopilot_first_load then
			-- set the trigger


				-- Start of Chocks monitoring
				-- it's outside of the preliminary prep procedure, because we want it to cycle whenever you've done the flow or not
				-- With the chocks in place we will toggle OFF the parking brake as if done by the PM
				if SC_reset_flag == 0 and ToLissPNFonDuty == 1 and Park_is_PNF == 1 and parkbrakeToLiss > 0 and (Toliss_chocks_set == 1 or show_Chocks) and BrakeReleasedFlag == false and ground_stuff < 2 then command_once("sim/flight_controls/brakes_toggle_max") BrakeReleasedFlag = true	end -- (stopped & on ground plus safety checks)
				-- End of Chocks monitoring

			-- trigger BATTERY 1 to ON --> changed for chocks installed. --> changed for flag in ToLiss

			 --	if ToLissPNFonDuty == 1 and Toliss_chocks_set == 1 and preliminaryprocedure_trigger == 0 and preflightproc_trigger == 0 and beforestartproc_trigger == 0 and takeoffproc_trigger ~= 1 and afterlandingproc_trigger ~= 3 and altitudeAGL < AGL_onGround then
				if ToLissPNFonDuty == 1 and preliminaryprocedure_trigger == 0 and preflightproc_trigger == 0 and beforestartproc_trigger == 0 and afterstartproc_trigger == 0 and takeoffproc_trigger ~= 1 and afterlandingproc_trigger ~= 3 and altitudeAGL < AGL_onGround and speed < 30 then



				--if ground_stuff == 0 and Toliss_chocks_set ~= 0 and ExtPowerConnected == 0 then
				if ground_stuff == 0 and (ExternalPowerEnabled == 1 or ExternalPowerAEnabled == 1) and ExtPowerConnected == 0 and ExtPowerAConnected == 0 then
					Current_title = "Safety exterior inspection"
					--[[
					CM2 :
					* WHEEL CHOCKS ..................................		CHECK
					*L/G DOORS ............................................ CHECK POSITION
					* APU AREA ............................................		CHECK
					--]]
					--ground_stuff = 1
					prep_time=math.floor(os.clock()) + 100
					-- commenting the lines above and uncommenting the lines below make a button appear to start Prelim Proc. Or inverse
					display_bubble("Click to start the PRELIMINARY COCKPIT PREP.")

					function ClickForProcTrigger()
						--if GUI_messages_in_circle_and_all_messages == true then
							draw_string(585, 80, "Click", "white") draw_string(570, 60, "for PRELIM", "white") draw_string(585, 40, "PREP", "white")
							graphics.draw_circle( 600, 60, 45, 2)
							if MOUSE_X <= 650 and MOUSE_X >=550 and MOUSE_Y <= 110  and MOUSE_Y >= 10 and MOUSE_STATUS == "down" then
								graphics.draw_filled_circle( 600, 60, 40, 2)
								draw_string(585, 80, "Click", "black") draw_string(570, 60, "for PRELIM", "black") draw_string(585, 40, "PREP", "black")
								play_sound(Checked_sound)

								-- ToLiSs Chocks:
								Toliss_chocks_set = 1
								test_possible_failure("sim/operation/failures/rel_gear_act")
								-- SGES Chocks :
								Chocks_chg = true
								show_Chocks = true
								SEI_P = true
								if DelaysAPU == 1 then Current_title = "Prelim. cockpit preparation without APU" end
								-- REPAIRING ANY BLOWN TIRE !
								NoseTire = 0
								LeftTire = 0
								RightTire= 0
								FD_flag = 0
								ExternalPowerBEnabled = 1
								set("AirbusFBW/FD1Engage",0)
								set("AirbusFBW/FD2Engage",0)

								prep_time=math.floor(os.clock())  -- used only at third step + when this line triggered.
								ground_stuff = 1
								reset_VR_message_popup()
							else MOUSE_STATUS = "up" end
						--end
					end
					-- DISPLAY VR message
					if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
						show_window_bottom_bar = true
						end_show_time = math.floor(os.clock()) + 50
						Message_wnd_content = "Proceed with the PRELIMINARY COCKPIT PREP ?"
						Message_wnd_action = "vr_message_sent = false ground_stuff = 1"
						Message_wnd_duration = 50
						show_the_option_window()
						--if TL_Keep_secondary_sounds == "activate" then  play_sound(HumSound) end
					end
					if Vr_message_current_answer == "yes" then reset_VR_message_popup() ground_stuff = 1 prep_time=math.floor(os.clock())  end
					-- End of VR Message
				elseif ground_stuff == 0 and (ExternalPowerEnabled == 1 or ExternalPowerAEnabled == 1) and (ExtPowerConnected == 1 or ExtPowerAConnected == 1) then
					Current_title = "Skipping to cockpit preparation"
					FD_flag = 0
					set("AirbusFBW/FD1Engage",0)
					set("AirbusFBW/FD2Engage",0)
					DU1 = 1
					DU2 = 1
					DU3 = 0.90
					DU4 = 0.90
					DU5 = 0.90
					DU6 = 0.90
					DU7 = 0.90
					DU8 = 0.90
					--Toliss_chocks_set = 0
					preliminaryprocedure_trigger = 0
					prep_time=math.floor(os.clock()) - 5
					-- commenting the lines above and uncommenting the lines below make a button appear to start Prelim Proc. Or inverse
					message_time=math.floor(os.clock()) - 10  -- used by function AutoClear
					function Message()
						message_done = 0 -- used by function AutoClear
						if normal_messages ==1 then big_bubble( 50, 20, "Skip to COCKPIT PREP ?","Disconnect electrical source to cancel.",PLANE_ICAO) end
					end
					function ClickForProcTrigger()
						--if GUI_messages_in_circle_and_all_messages == true then
							draw_string(385, 80, "Skip", "green") draw_string(370, 60, "to COCKPIT", "green") draw_string(385, 40, "PREP", "green")
							graphics.draw_circle( 400, 60, 45, 2)
							if MOUSE_X <= 450 and MOUSE_X >=350 and MOUSE_Y <= 110  and MOUSE_Y >= 10 and MOUSE_STATUS == "down" then
								graphics.draw_filled_circle( 400, 60, 40, 2)
								reset_VR_message_popup()
								--if TL_Keep_secondary_sounds == "activate" then play_sound(HumSound) end
								prep_time=math.floor(os.clock()) - 2  -- used only at third step + when this line triggered.
								xpder_time = math.floor(os.clock())
								proc_time=math.floor(os.clock())
								fmgs_time=math.floor(os.clock()) + 999
								--if slides_addon_installed then EmerLight = 0 end
								ground_stuff = 14
								preliminaryprocedure_trigger = 2
								step = 0
								QAnswered = 0
							else MOUSE_STATUS = "up" end
						--end

					end
					-- DISPLAY VR message
					if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
						show_window_bottom_bar = true
						end_show_time = math.floor(os.clock()) + 20
						Message_wnd_content = "Advance to the COCKPIT PREPARATION procedure ?"
						Message_wnd_action = "vr_message_sent = false ground_stuff = 14 preliminaryprocedure_trigger = 2    step = 0    QAnswered = 0 vr_message_sent = false"
						Message_wnd_duration = 50
						show_the_option_window()
					end
					-- End of VR Message
					if Vr_message_current_answer == "yes" then
						reset_VR_message_popup()
						prep_time = math.floor(os.clock()) - 2  -- used only at third step + when this line triggered.
						xpder_time = math.floor(os.clock())
						proc_time = math.floor(os.clock())
						fmgs_time = math.floor(os.clock()) + 999
						--if slides_addon_installed then EmerLight = 0 end
						ground_stuff = 14
						preliminaryprocedure_trigger = 2
						step = 0
						QAnswered = 0
					end

				elseif Eng1N1 >= 17 and SC_reset_flag == 0 then
					function ClickForProcTrigger()

						--if GUI_messages_in_circle_and_all_messages == true then
							draw_string(415, 80, "Skip to", "yellow") draw_string(400, 60, "  the Taxi", "yellow") draw_string(415, 40, "Proc", "yellow")
							graphics.draw_circle( 430, 60, 45, 2)
							if MOUSE_X <= 480 and MOUSE_X >=370 and MOUSE_Y <= 140  and MOUSE_Y >= 40 and MOUSE_STATUS == "down" then
								graphics.draw_filled_circle( 430, 60, 40, 2)
								step = 11
								started1 = 2
								started2 = 2
								preliminaryprocedure_trigger = 2
								beforestartproc_trigger = 2
								afterstartproc_trigger = 0
								genactive1_trigger =1
								genactive2_trigger =1
								genactive3_trigger =1
								genactive4_trigger =1
								cabinready = 0
								DU1 = 0.90
								DU2 = 0.90
								DU3 = 0.90
								DU4 = 0.90
								DU5 = 0.90
								DU6 = 0.90
								DU7 = 0.90
								DU8 = 0.90
								Vr_message_current_answer = "?" vr_message_sent = false end_show_time = 0
							else MOUSE_STATUS = "up" end

						--end
					end
					-- DISPLAY VR message
					if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
						Message_wnd_content = "Engines are running : go to the Taxi procedure ?"
						Message_wnd_action = "vr_message_sent = false step = 11     started1 = 2					started2 = 2					preliminaryprocedure_trigger = 2					beforestartproc_trigger = 2					afterstartproc_trigger = 0					genactive1_trigger =1					genactive2_trigger =1					genactive3_trigger =1					genactive4_trigger =1					cabinready = 0					DU1 = 0.90					DU2 = 0.90					DU3 = 0.90					DU4 = 0.90					DU5 = 0.90					DU6 = 0.90					DU7 = 0.90					DU8 = 0.90"
						Message_wnd_duration = 50
						show_window_bottom_bar = true
						end_show_time = math.floor(os.clock()) + 40
						show_the_option_window()
					end
					-- End of VR Message
					if Vr_message_current_answer == "yes" then
						reset_VR_message_popup()
						step = 11
						started1 = 2
						started2 = 2
						preliminaryprocedure_trigger = 2
						beforestartproc_trigger = 2
						afterstartproc_trigger = 0
						genactive1_trigger =1
						genactive2_trigger =1
						genactive3_trigger =1
						genactive4_trigger =1
						cabinready = 0
						DU1 = 0.90
						DU2 = 0.90
						DU3 = 0.90
						DU4 = 0.90
						DU5 = 0.90
						DU6 = 0.90
						DU7 = 0.90
						DU8 = 0.90
					end
				elseif SC_reset_flag == 0 then
					function ClickForProcTrigger()
						draw_string(385, 80, "", "white")
					end
					--reset_VR_message_popup()
				end


				--[[
				Preliminary cockpit preparation

				The steps referenced below are done by the Crew Member 2 (CM2). This is what does the New Speedy Copilot for ToLiSS.
				Aircraft setup / batteries / external power and lights :
				ENG 1, 2 MASTER LEVERS ....................................... OFF
				ENG MODE selector ................................................... NORM
				WEATHER RADAR ................................................... OFF
				L/G lever ..................................................................... DOWN
				Both WIPER selectors ................................................ OFF

				BAT ............................................................... CHECK/AUTO
				EXT PWR ......................................................ON

				COCKPITLIGHTS ...............AS RQRD

				EFB INITIALIZATION :
				ALL EFB........................START
				EFB / eQRH Version ..................CHECK
				EFB SYNCHRO AVIONICS...............CLICK
				EFB STATUS page.........INSERT / CHECK

				Aircraft acceptance :
				LOGBOOK................................................ CHECK
				AIRCRAFT CONFIGURATION SUMMARY ......CHECK


				FIRE TEST/APU START :
				RMP ......................................................... SET
				FIRE TEST ................................................PERFORM
				APU ............................................................START
				When the APU is AVAIL:
				AIR COND panel .......................................SET
				EXT PWR ................................................ AS RQRD

				PRELIMINARY PERFORMANCE DETERMINATION:
				AIRFIELD DATA .................................OBTAIN
				PRELIMINARY LOADING ... COMPUTE/CROSSCHECK
				MEL/CDL ITEMS..................CHECK ACTIVATED

				NAV CHARTS CLIP BOARD ............... PREPARE

				PRELIM T.O PERF DATA.................................COMPUTE
				PRELIM T.O PERF DATA........................CROSSCHECK

				BEFORE WALKAROUND :
				ECAM OXY PRESS / HYD QTY / ENG OIL QTY ... CHECK
				FLAPS ......................................................CHECK POSITION
				SPD BRK lever ..................... CHECK RET AND DISARMED
				PARKING BRAKE handle ................................................ ON
				ACCU/BRAKES PRESS .......................................... CHECK
				EMER EQPT ............................................................... CHECK
				RAIN REPELLENT ................................................... CHECK
				C/B PANELS ............................................................... CHECK
				GEAR PINS and COVERS___CHECK ONBOARD / STOWED

				EXTERIOR WALKAROUND ..............................PERFORM
				--]]

					-- GPU request
					if (current_time >= prep_time + 1 and ground_stuff == 1) or ground_stuff == 1  then -- or authorise to automate the procedure once passed 5 minutes on ground with chocks.
						Current_title = "Preliminary cockpit preparation "
						function ClickForProcTrigger() draw_string(385, 80, "", "grey") -- eraze
						end
						reset_VR_message_popup()
						BeaconL = 0 -- to allow disamring the slides
						PaxDoor1L = 0

						ClockETSwitch = 1
						--play_sound(Typing_sound)
						display_bubble("PRELIMINARY COCKPIT PREP")
						ExternalPowerEnabled = 1  -- GPU Available
						ExternalPowerAEnabled = 1 -- GPU Available for the A340-600 (only)
						if forward_JARstairs_wanted == 1 and AircraftIsP2F == 0 then
							PaxDoorRearLeft = 2
						else
							PaxDoorRearLeft = 0 -- Door 2L CLOSED
						end
						--CargoDoor1 = 0 -- Cargo CLOSED
						--CargoDoor2 = 0 -- Cargo CLOSED
						if (AIRCRAFT_FILENAME == "a321.acf" or AIRCRAFT_FILENAME == "a321_StdDef.acf" or AIRCRAFT_FILENAME == "a321_XP11.acf") then
							BulkDoor = 0
						end
						if JAR_Ground_Handling_wanted == 1 then
							DatarefJARLoad() -- reload to anticipate interactions with the user.
							GHDpowerCable = 1
							GHDChocks = 1
							GHDcateringFwd = 1
							GHDcateringAft = 1
							GHDfuelTank = 1
							GHDpassengersBus = 0
							GHDnoseConus[0] =1
							GHDloaderAft = 0
							GHDloaderFwd = 0
							if forward_JARstairs_wanted == 1 then GHDforwardStairs = 1 end
							GHDrearStairs = 0
							if forward_JARstairs_wanted == 1 then GHDrearStairs = 1 end

						else
							show_GPU = true
							GPU_chg = true
							show_FUEL = true
							FUEL_chg = true
							show_Cleaning = true
							Cleaning_chg = true
							show_Cones = true
							Cones_chg = true
							show_People1 = true
							People1_chg = true
							show_People2 = true
							People2_chg = true
						end
						Toliss_chocks_set = 1
						ground_stuff = 2
						-- Our own Cold and Dark state :    --
						-- if we are not inside american longitudes, turn to hPa
						if aircraft_longitude < -170  or aircraft_longitude  > -60 then
							BaroUnitCapt = 1 -- 1 is HPA
							BaroUnitFO = 1 -- 1 is HPA
						else
							BaroUnitCapt = 0 -- 1 is HPA
							BaroUnitFO = 0 -- 1 is HPA
						end
						ALT100_1000 = 1 -- to step 1000
						-- end of our own cold and dark state --
					end



					-- Connection of the Battery by FO
					if current_time >= prep_time + 2 and ground_stuff == 2 then
						ENGModeSwitch = 1 -- 1 is NORM, 2 for IGNITION
						--if GearPosition ~= 1 then command_once("sim/flight_controls/landing_gear_toggle") end
						command_once("sim/flight_controls/landing_gear_down")
						--BATTERY (and light!)
						--display_bubble("BATTERY (and light!)")
						BatOH1 = 1
						if localHour >= 17 or localHour <= 8 then DomeLight = 1 else DomeLight = 2 end
						-- the Dome Light at night in BRIGHT position is TOO bright, so we limit it.
						ground_stuff = 2.1
					end

					-- Connection of the Battery by FO
					if current_time >= prep_time + 6 and ground_stuff == 2.1 then
						BatOH2 = 1
						ground_stuff = 2.2
					end

					if current_time >= prep_time + 8 and ground_stuff == 2.2 then
						BatOHAPU = 1 -- A340-600
						set_array("AirbusFBW/ACP2KnobPush",5,1) -- INT RECEPTION KNOB OUT if is 1
						--~ set_array("AirbusFBW/ACP2KnobPush",6,1) -- CAB RECEPTION KNOB OUT if is 1
						ground_stuff = 3
					end

					-- Connection of the GPU
					if current_time >= prep_time + 12 and ground_stuff == 3 then
						ExtPowerConnected = 1 -- overhead button
						ground_stuff = 3.1
						DU7 = 0.90
					end

					if current_time >= prep_time + 16 and ground_stuff == 3.1 then
						ExtPowerAConnected = 1 -- overhead button A340-600
						ground_stuff = 4
						DU8 = 0.90
					end

					-- APU Fire test (added v2.2)
					if current_time >= prep_time + 24 and ground_stuff == 4 then
						message_time=math.floor(os.clock())  -- used by function AutoClear
						function Message()
							message_done = 0 -- used by function AutoClear
							if normal_messages == 1 then draw_string( 50, 20, "The CM2 is performing his EFB INITIALIZATION.", "green" ) end
						end
						FrontPanelFlood = 0.7
						DU4 = 0.90
						DU5 = 0.90
						DU6 = 0.90
						ground_stuff = 4.05
						prep_time=prep_time + 7 -- give it some more clearance (added v4.3 2021) mod 08-2022
						-- maintains it pressed 2 sec.
					end

					if current_time >= prep_time + 32 and ground_stuff == 4.05 then -- mod 08-2022
						message_time=math.floor(os.clock())  -- used by function AutoClear
						function Message()
							message_done = 0 -- used by function AutoClear
							if normal_messages == 1 then draw_string( 50, 20, "The CM2 is performing AIRCRAFT ACCEPTANCE items (LOGBOOK/MEL/CDL and AIRCRAFT CONFIGURATION SUMMARY check).", "green" ) end
						end
						PedestalPanelFlood = 0.75
						DU1 = 0.90
						DU2 = 0.90
						DU3 = 0.90
						ground_stuff = 4.1
						prep_time=prep_time + 7 -- give it some more clearance (added v4.3 2021) mod 08-2022
						-- maintains it pressed 2 sec.
					end

					if current_time >= prep_time + 60 and ground_stuff == 4.1 then
						command_once("AirbusFBW/ECAMRecall") --RCL considered XPJavelin SOP, normally the CM1 does that 3 seconds, not the CM2
						if  PLANE_ICAO == "A346" then
							CvrGndCtrl = 1 -- item of the PF in prep procedure.
						end
						display_bubble("The CM2 will perform the FIRE TEST/APU START items.")
						ground_stuff = 6
						-- MOD NOVEMBER 2021
						CargoDoor1 = 2 -- Cargo OPEN
						-- END
						prep_time = prep_time + 20 -- give more time for the DU SELF TEST to finish
					end

					-- we have sufficiently waited for the system to be ready for APU fire test, we can proceed from now on :

					if current_time >= prep_time + 64 and ground_stuff == 6 then
						command_begin("AirbusFBW/FireTestAPU") -- overhead button
						ground_stuff = 7
						-- maintains it pressed
					end
					if current_time >= prep_time + 66 and ground_stuff == 7 then
						command_once("sim/annunciator/clear_master_warning")
						ground_stuff = 7.1
					end
					if current_time >= prep_time + 70 and ground_stuff == 7.1 then
						command_end("AirbusFBW/FireTestAPU") -- overhead button
						test_possible_failure("sim/operation/failures/rel_apu_fire")
						test_possible_failure("sim/operation/failures/rel_apu")
						test_possible_failure("sim/operation/failures/rel_APU_press")
						ground_stuff = 7.11
						reset_VR_message_popup()
						-- stops to press
					end
					-- APU Fire test (added v2.2)

					-- APU start (new 2021 procedure) mod 2022 08 20
					if current_time >= prep_time + 72 and ground_stuff == 7.11 then
						-- APU Master
						if DelaysAPU == 0 and APUMasterSwitch == 0 then
							 -- apu_started = 0
							APUMasterSwitch = 1
						else
							display_bubble("Start the APU despite our policy to delay it ?")
							-- DISPLAY VR message
							if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
								show_window_bottom_bar = true
								end_show_time = math.floor(os.clock()) + 40
								Message_wnd_content = "Decide to start the APU now ?"
								Message_wnd_action = "vr_message_sent = false APUMasterSwitch = 1"
								Message_wnd_duration = 30
								show_the_option_window()
							end
							-- End of VR Message
							if Vr_message_current_answer == "yes" then
								if APUMasterSwitch == 0 then
									APUMasterSwitch = 1
								end
							end
						end
						if current_time >= prep_time + 95 then ground_stuff = 7.12 reset_VR_message_popup() end
					end

					if current_time >= prep_time + 102 and (APUFlapOpenRatio == 1 or APUMasterSwitch == 0) and ground_stuff == 7.12 then
						if DelaysAPU == 0 then
							APUStarterSwitch = 1
						elseif APUMasterSwitch == 1 then
							--~ -- DISPLAY VR message
							--~ if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
								--~ show_window_bottom_bar = true
								--~ end_show_time = math.floor(os.clock()) + 20
								--~ Message_wnd_content = "Confirm to start the APU now, despite our environnmental policy ?"
								--~ Message_wnd_action = "vr_message_sent = false APUStarterSwitch = 1"
								--~ Message_wnd_duration = 5
								--~ show_the_option_window()
								--~ --if TL_Keep_secondary_sounds == "activate" then  play_sound(HumSound) end
							--~ end
							--~ -- End of VR Message
							--~ if Vr_message_current_answer == "yes" then
								--~ APUStarterSwitch = 1
								--~ reset_VR_message_popup()
							--~ end
							APUStarterSwitch = 1
						end
						--> during APU wait, we do in parallel NON FCOM stuff with XPDER, see below.
						coldAndDarkAtc = 1
						xpder_time = math.floor(os.clock())
						prep_time=math.floor(os.clock())
						ground_stuff = 7.13
					end
							------------------------------------------------------------------------
							-- ATC is COCKPIT PREPARATION/PF DUTY but the default 0000 code in the ToLiss Airbus is not cool
							-- doing additional stuff (non FCOM) with the transponder :

							if ground_stuff >= 7.13 and current_time >= xpder_time + 6 and coldAndDarkAtc == 1 then
								coldAndDarkAtc = 2
								command_once("AirbusFBW/ATCCodeKeyCLR") -- as it should be in real life

							end

							if current_time >= xpder_time + 8 and coldAndDarkAtc == 2 then
								coldAndDarkAtc = 3
								message_time=math.floor(os.clock())
								function Message()
									message_done = 0 -- used by function AutoClear
									draw_string( 50, 20, "Clearing ATC code", "white" ) -- debug
								end
							end

							if current_time >= xpder_time + 10 and coldAndDarkAtc == 3 then
								coldAndDarkAtc = 4
								command_once("AirbusFBW/ATCCodeKey1")
							end

							if current_time >= xpder_time + 12 and coldAndDarkAtc == 4 then
								coldAndDarkAtc = 5
								command_once("AirbusFBW/ATCCodeKey0")
							end

							if current_time >= xpder_time + 14 and coldAndDarkAtc == 5 then
								coldAndDarkAtc = 6
								command_once("AirbusFBW/ATCCodeKey0")
							end

							if current_time >= xpder_time + 16 and coldAndDarkAtc == 6 then
								coldAndDarkAtc = 7
								command_once("AirbusFBW/ATCCodeKey0")
							end
							------------------------------------------------------------------------

					-- APU Bleed after sometime to clean the not so fresh air from start
					if current_time >= prep_time + 30 and ground_stuff == 7.13 then
						if DelaysAPU == 0 then
							APU_Bleed_ON = 1
							prep_time = math.floor(os.clock())
						end
						ground_stuff = 7.2
						GroundHPAir = 0
					end




					-- PRELIMINARY PERFORMANCE DETERMINATION
					if current_time >= prep_time + 32 and ground_stuff == 7.2 then
						if  PLANE_ICAO == "A346" then
							CvrGndCtrl = 1 -- item of the PF in prep procedure.
						end
						display_bubble("PRELIMINARY PERFORMANCE DETERMINATION items.")

						ground_stuff = 7.3
					end

					-- only the human user can really compute perfs on the ISCS, let only theatrically mimic that on the CM2 side
					if current_time >= prep_time + 40 and ground_stuff == 7.3 then
						command_once("AirbusFBW/MCDU2Perf")
						ground_stuff = 7.4
					end

					if current_time >= prep_time + 45 and ground_stuff == 7.4 then
						ground_stuff = 7.5
						--command_once("AirbusFBW/MCDU1Data") --> offer Engine & Aircraft type check to the captain
						InitZFW = (m_total - m_fuel_total)-- symbolic, to mimic the 2021 preliminary performance determination
						-- we let the fuel blank to show blantantly it's not finished, and anyway everything will be overwritten in the cockpit prep flow
					end

					if current_time >= prep_time + 50 and ground_stuff == 7.5 then
						ground_stuff = 7.6
						--command_once("AirbusFBW/MCDU1LSK4L") --> offer Engine & Aircraft type check to the captain
						InitZFWCG = aircraft_calculated_ZFWCG -- symbolic, to mimic the 2021 preliminary performance determination
						-- we let the fuel form blank to show blantantly it's not finished, and anyway everything will be overwritten in the cockpit prep flow
						display_bubble("Before walkaround")
					end

					--[[
					BEFORE WALKAROUND :

					ECAM OXY PRESS / HYD QTY / ENG OIL QTY ... CHECK
					FLAPS ......................................................CHECK POSITION
					SPD BRK lever ..................... CHECK RET AND DISARMED
					PARKING BRAKE handle ................................................ ON
					ACCU/BRAKES PRESS .......................................... CHECK
					EMER EQPT ............................................................... CHECK
					RAIN REPELLENT ................................................... CHECK
					C/B PANELS ............................................................... CHECK
					GEAR PINS and COVERS___CHECK ONBOARD / STOWED

					EXTERIOR WALKAROUND ..............................PERFORM
					--]]

					if current_time >= prep_time + 54 and ground_stuff == 7.60 then
						Current_title = "Before walkaround"
						-- ECAM OXY PRESS
						message_time=math.floor(os.clock())  -- used by function AutoClear
						function Message()
							message_done = 0 -- used by function AutoClear
							if normal_messages == 1 then draw_string( 50, 20, "CM2 checks that OXY pressure on ECAM SD DOOR page is above 486 psi.", "green" ) end
						end
						-- specific link to dataref, (magic table) to be able to unlink the dataref
						-- those specific ECAM button cause problems when not unlinked.
						-- https://docs.flybywiresim.com/pilots-corner/a32nx-briefing/ecam/sd/door/
						ECAMpage = dataref_table("AirbusFBW/SDDOOR","writable")
						ECAMpage[0] = 1
						ECAMpage = nil -- unload dataref
						test_possible_failure("AirbusFBW/PaxOxySwitch")
						test_possible_failure("AirbusFBW/CrewOxyMask")
						ground_stuff = 7.61
					end

					if current_time >= prep_time + 67 and ground_stuff == 7.61 then
						-- HYD QTY
						message_time=math.floor(os.clock())  -- used by function AutoClear
						function Message()
							message_done = 0 -- used by function AutoClear
							if normal_messages == 1 then draw_string( 50, 20, "CM2 checks that HYD reservoir fluid level is within normal (green) range on HYD SD page.", "green" ) end
						end
						-- https://docs.flybywiresim.com/pilots-corner/a32nx-briefing/ecam/sd/hyd/
						ECAMpage = dataref_table("AirbusFBW/SDHYD","writable")
						ECAMpage[0] = 1
						ECAMpage = nil -- unload dataref
						test_possible_failure("sim/operation/failures/rel_hydleak")
						test_possible_failure("sim/operation/failures/rel_hydleak2")
						ground_stuff = 7.62
					end

					if current_time >= prep_time + 76 and ground_stuff == 7.62 then
						-- ENG OIL QTY
						message_time=math.floor(os.clock()) - 5 -- used by function AutoClear
						function Message()
							message_done = 0 -- used by function AutoClear
							if normal_messages == 1 then draw_string( 50, 20, "CM2 checks that the oil quantity is at or above 9.5 qt   + estimated consumption (~ 0.5 qt/h) on ENG SD page.", "green" ) end
						end
						-- https://docs.flybywiresim.com/pilots-corner/a32nx-briefing/ecam/sd/eng/
						ECAMpage = dataref_table("AirbusFBW/SDENG","writable")
						ECAMpage[0] = 1
						ECAMpage = nil -- unload dataref
						test_possible_failure("sim/operation/failures/rel_oilp_ind_0")
						test_possible_failure("sim/operation/failures/rel_oilp_ind_1")
						ground_stuff = 7.63
					end

					if current_time >= prep_time + 85 and ground_stuff == 7.62 then
						test_possible_failure("sim/operation/failures/rel_engfai0")
						test_possible_failure("sim/operation/failures/rel_engfai1")
						if PLANE_ICAO == "A346" then
							test_possible_failure("sim/operation/failures/rel_engfai2")
							test_possible_failure("sim/operation/failures/rel_engfai3")
						end
						-- FLAPS
						--if FLAPS_wanted == 1 then
							flaprqst = 0 -- FLAPS ZERO
						--end
						ground_stuff = 7.625
					end

					if current_time >= prep_time + 86 and ground_stuff == 7.625 then
						ECAMpage = dataref_table("AirbusFBW/SDENG","writable")
						ECAMpage[0] = 0 -- unselect the ECAM SD page
						ECAMpage = nil -- unload dataref
						ground_stuff = 7.63
					end

					if current_time >= prep_time + 88 and ground_stuff == 7.63 then
						test_possible_failure("sim/operation/failures/rel_flap_act")
						test_possible_failure("sim/cockpit2/controls/flap_ratio")
						ground_stuff = 7.64
					end


					if current_time >= prep_time + 90 and ground_stuff == 7.64 then
						-- SPD BRK lever
						speedbrake_ratio = 0
						test_possible_failure("sim/cockpit2/controls/speedbrake_ratio")
						ground_stuff = 7.65
						vr_message_sent = false
					end

					if current_time >= prep_time + 92 and ground_stuff == 7.65 then
						message_time=math.floor(os.clock()) + 30  -- used by function AutoClear
						function Message()
							message_done = 0 -- used by function AutoClear
							if (Park_is_PNF == 1 or parkbrakeToLiss == 0) and normal_messages == 1 then draw_string( 50, 20, "To continue please set parking brake.", "white" ) end
						end  -- I do the message on second item to avoid conflit with the RESET DISPLAY
						-- DISPLAY VR message
						--~ if Vr_message_current_answer == "yes" and parkbrakeToLiss == 0 then
							--~ Message_wnd_content = "To continue, please set the parking brake."
							--~ Message_wnd_action = "vr_message_sent = false"
							--~ Message_wnd_duration = 10
							--~ show_the_option_window()
							--~ Vr_message_current_answer = "?"
						--~ end
						-- End of VR Message

						-- DISPLAY VR message
						if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
							show_window_bottom_bar = true
							end_show_time = math.floor(os.clock()) + 30
							Message_wnd_content = "To continue, please set the parking brake."
							Message_wnd_action = ""
							Message_wnd_duration = 50
							show_the_option_window()
						end
						-- End of VR Message

						-- apu_started = 0 -- allow apu_time initialization (mandatory for GPU removal later)
						if parkbrakeToLiss == 0 then BrakeReleasedFlag = true end
						ground_stuff = 8
						-- MOD NOVEMBER 2021
						CargoDoor2 = 2 -- Cargo OPEN
						PaxDoorRearLeft = 2
						-- END
					end

					----------- PARKBRAKE TRANSITION -----------

					if parkbrakeToLiss > 0 and ground_stuff == 8 then
						reset_VR_message_popup()
						message_time=math.floor(os.clock()) - 10 -- clears previous message
						function Message()
							message_done = 0 -- used by function AutoClear
							if Park_is_PNF == 1 and normal_messages == 1 then draw_string( 50, 20, "To continue please set parking brake.", "green" ) end -- message because the user can deactivate the influence of the FO on the parking brake, and that would be up to the user to take it ON now.
						end
						--ACCU/BRAKES PRESS .......................................... CHECK
						test_possible_failure("sim/operation/failures/rel_lbrakes")
						test_possible_failure("sim/operation/failures/rel_rbrakes")
						ground_stuff = 9
						doorLock = 1
						-- set parking brake by PM as in FCOM -- revision 3.4
						if ToLissPNFonDuty == 1 and Park_is_PNF == 1 and parkbrakeToLiss == 0 and BrakeReleasedFlag == true then parkbrakeToLiss = 1 BrakeReleasedFlag = false	end
					end


					--EMER EQPT ............................................................... CHECK
					--RAIN REPELLENT ................................................... CHECK
					--C/B PANELS ............................................................... CHECK
					--GEAR PINS and COVERS___CHECK ONBOARD / STOWED


					if parkbrakeToLiss > 0 and ground_stuff == 9 and current_time >= prep_time + 30 then
						prep_time=math.floor(os.clock()) -- reset prep_time if park brake is delayed, allows correct sequencing of following actions.

						------ Resets UTC CLOCK CHRONOS and ELAPSED TIME
						--#Elapsed Time clock RST --#CHRONO clock CHR RST
						timerFlightDeck = 0 -- stop
						command_once("sim/instruments/timer_reset") -- reset

						ClockETSwitch = 1
						ground_stuff = 10
					end

					-- APU Start : was here but displaced for 2021 NEW AIRBUS procedures
					if current_time >= prep_time + 33 and (APUFlapOpenRatio == 1 or DelaysAPU == 1) and ground_stuff == 10 then
						ground_stuff = 11
						prep_time=math.floor(os.clock())
					end


				--														///////////////////////////////////////////////////
					if ground_stuff == 11 and current_time >= prep_time + 2 then
						Current_title = "Before walkaround complete, Prelim. cockpit prep. complete"
						CPP_P = true
						play_sound(Preliminary_sound)
						message_time=math.floor(os.clock()) + 180 -- used by function AutoClear -- several minutes to allow loading time
						function Message()
							message_done = 0 -- used by function AutoClear
							if TL_Keep_secondary_sounds == "activate" then
								--big_bubble( 50, 20, "PRELIMINARY COCKPIT PREP done.","Click for the next procedure. Speedy Copilot T319 " .. version_text_troiscentvingt .. ".")
								big_bubble( 50, 20, "PRELIMINARY COCKPIT PREP done.","Click for the next procedure.")
							else
								big_bubble( 50, 20, "PRELIMINARY COCKPIT PREP done.","Click for the next procedure.","Secondary sounds deactivated.")
							end
						end
						ground_stuff = 13
					end



					if ground_stuff == 13 and current_time >= prep_time + 4 then
						function ClickForProcTrigger()
							--if GUI_messages_in_circle_and_all_messages == true then
								draw_string(415, 80, "Click", "white") draw_string(400, 60, "for COCKPIT", "white") draw_string(415, 40, "PREP", "white")
								graphics.draw_circle( 430, 60, 45, 2)
								if MOUSE_X <= 480 and MOUSE_X >=370 and MOUSE_Y <= 140  and MOUSE_Y >= 40 and MOUSE_STATUS == "down" then
									graphics.draw_filled_circle( 430, 60, 40, 2)
									draw_string(415, 80, "Click", "black") draw_string(400, 60, "for COCKPIT", "black") draw_string(415, 40, "PREP", "black")
									ground_stuff 					= 14
									preliminaryprocedure_trigger 	= 2
									preflightproc_trigger 			= 0
									beforestartproc_trigger 		= 0
									proc_time = math.floor(os.clock())	 + 20
									fmgs_time = math.floor(os.clock()) 	 + 999
									reset_VR_message_popup()
								else MOUSE_STATUS = "up" end
							--end
						end
						-- DISPLAY VR message
						if GUI_VR_message and vr_message_sent == false then
							vr_message_sent 	= true
							show_window_bottom_bar 		= true
							end_show_time 		= math.floor(os.clock()) + 50
							Message_wnd_content = "Before walk-around flow complete. Proceed to the cockpit preparation procedure ?"
							Message_wnd_action 	= "vr_message_sent = false ground_stuff = 14     preliminaryprocedure_trigger = 2 preflightproc_trigger = 0 beforestartproc_trigger = 0"
							Message_wnd_duration = 30
							show_the_option_window()
						end
						-- End of VR Message
						if Vr_message_current_answer == "yes" then
							ground_stuff = 14
							preliminaryprocedure_trigger = 2
							preflightproc_trigger = 0
							beforestartproc_trigger = 0
							proc_time = math.floor(os.clock())	 + 20
							fmgs_time = math.floor(os.clock()) 	 + 9999
							ACARS_PERF_TAKEOFF_time = math.floor(os.clock()) 	 + 9999
							reset_VR_message_popup()
						end
					end

				end
			end
		end
		do_often("PRELIMINARY()")

		ACARS_PERF_TAKEOFF_step = 0
		ACARS_PERF_TAKEOFF_time = math.floor(os.clock()) 	 + 9999
		function ACARS_PERF_TAKEOFF()
			if not SpeedyCopilot_first_load then
					if ACARS_PERF_TAKEOFF_step == 0 and current_time >= ACARS_PERF_TAKEOFF_time + 4 then
						command_once("AirbusFBW/MCDU2Prog")
						ACARS_PERF_TAKEOFF_step = 0.5
					end
					if ACARS_PERF_TAKEOFF_step == 0.5 and current_time >= ACARS_PERF_TAKEOFF_time + 8 then
						print("ACARS : AOC FLEX takeoff performance requested by the first officer in Speedy Copilot.")
						command_once("AirbusFBW/MCDU2Perf")
						ACARS_PERF_TAKEOFF_step = 1
					end
					if ACARS_PERF_TAKEOFF_step == 1 and current_time >= ACARS_PERF_TAKEOFF_time + 12 then
						command_once("AirbusFBW/MCDU2LSK6L") -- UPLINK TO DATA
						ACARS_PERF_TAKEOFF_step = 2
					end
					if ACARS_PERF_TAKEOFF_step == 2 and current_time >= ACARS_PERF_TAKEOFF_time + 16 then
						command_once("AirbusFBW/MCDU2LSK6R") -- To DATA REQUEST
						ACARS_PERF_TAKEOFF_step = 3
					end
					if ACARS_PERF_TAKEOFF_step == 3 and current_time >= ACARS_PERF_TAKEOFF_time + 24 then
						command_once("AirbusFBW/MCDU2LSK6L") -- received TO data
						ACARS_PERF_TAKEOFF_step = 4
					end
					if ACARS_PERF_TAKEOFF_step == 4 and current_time >= ACARS_PERF_TAKEOFF_time + 28 then
						if string.find(get("AirbusFBW/MCDU2label2w"),"TEMP") then command_once("AirbusFBW/MCDU2LSK4R") end -- switch to Flex TO data as required
						ACARS_PERF_TAKEOFF_step = 5
					end
					if ACARS_PERF_TAKEOFF_step == 5 and current_time >= ACARS_PERF_TAKEOFF_time + 32 then
						command_once("AirbusFBW/MCDU2LSK6R") -- Insert Flex uplink
						ACARS_PERF_TAKEOFF_step = 6
					end
					if ACARS_PERF_TAKEOFF_step == 6 and current_time >= ACARS_PERF_TAKEOFF_time + 52 then
						command_once("AirbusFBW/MCDU2Fpln") -- Back to FPL
						ACARS_PERF_TAKEOFF_step = 7
						print("ACARS : AOC FLEX takeoff performance inserted by the first officer.")
					end
			end
		end

		do_often("ACARS_PERF_TAKEOFF()")

			------------------------------											///////////////////////////////////////////////////
		function COCKPITPREP()
			if not SpeedyCopilot_first_load then
				if ToLissPNFonDuty == 1 and preflightproc_trigger == 0 and preliminaryprocedure_trigger == 2 and beforestartproc_trigger == 0 and takeoffproc_trigger ~= 1 and afterlandingproc_trigger ~= 3 and altitudeAGL < AGL_onGround then

					-- ADIRU

					if ADIRUTimeToAlign > 590 and IR1 == 1 and IR2 == 1 and IR3 == 1 and FD1 == 1 and FD2 == 1 and altitudeAGL < AGL_onGround then
						set("AirbusFBW/FD1Engage",0)
						set("AirbusFBW/FD2Engage",0)
					end

					-- Execute COCKPIT PREPARATION Procedure

					-- Note : we are going to use the steps below to also prepare some interesting data in the MCDUs : IRS align REF and ZFW on the captain side to help the captain.

					if ground_stuff == 14 and current_time >= prep_time + 3 and step ~= 1 then
						Current_title = "Cockpit preparation"
						function ClickForProcTrigger() -- erase circle
							draw_string( 0, 0, "")
						end
						reset_VR_message_popup()
						--~ -- DISPLAY VR message
						--~ if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
							--~ show_window_bottom_bar = true
							--~ end_show_time = math.floor(os.clock()) + 20
							--~ Message_wnd_content = ""    Message_wnd_content = Current_title
							--~ Message_wnd_action = "vr_message_sent = false"
							--~ Message_wnd_duration = 1
						--~ end
						--~ -- End of VR Message

						-- reset some sensitive stuff :
						PM_does_the_cockpit_preparation_instead_of_the_PF = true
						--if slides_addon_installed then EmerLight = 0 end
						TL_Accel_AltitudeBaro_fromMCDU  = 799
						Red_AltitudeBaro_fromMCDU = 799
						ACARS_PERF_TAKEOFF_time = math.floor(os.clock()) 	 + 999
						-- then begin
						message_time=math.floor(os.clock()) + 30
						function Message()
							message_done = 0 -- used by function AutoClear
							draw_string( 50, 20, ground_stuff .. ";" .. step, "grey" ) -- debug message
						end
						if TL_Keep_secondary_sounds == "activate" then
							random = math.random()
							if random > 0.3 then play_sound(CockpitPrepFO_sound)
							else play_sound(CockpitPrepFO2_sound) end
						end
						BeaconL			= 0 -- 0 is OFF, 1 is red ON -- to allow quickly disarming slides
						if JAR_Ground_Handling_wanted == 1 then
							DatarefJARLoad() -- reload to anticipate interactions with the user.
							GHDpowerCable = 1
							GHDChocks = 1
							GHDcateringFwd = 0
							GHDcateringAft = 0
							GHDfuelTank = 0
							if forward_JARstairs_wanted == 0 then GHDpassengersBus = 0 else GHDpassengersBus = 1 end
							GHDnoseConus[0] =1
							GHDloaderAft = 1
							GHDloaderFwd = 1
							if forward_JARstairs_wanted == 1 then GHDforwardStairs = 1 end
							if forward_JARstairs_wanted == 0 then GHDrearStairs = 0 else GHDrearStairs = 1 end
						else
							show_GPU = true
							GPU_chg = true
							show_FUEL = true
							FUEL_chg = true
							show_Cleaning = true
							Cleaning_chg = true
							show_Light = false
							Light_chg = true
							show_Cones = true
							Cones_chg = true
							show_People1 = true
							People1_chg = true
							show_People2 = true
							People2_chg = true
							show_People3 = true
							People3_chg = true
							show_People4 = true
							People4_chg = true
						end
						Toliss_chocks_set = 1
						set_array("AirbusFBW/ACP2KnobPush",5,1) -- INT RECEPTION KNOB OUT if is 1
						--~ set_array("AirbusFBW/ACP2KnobPush",6,1) -- CAB RECEPTION KNOB OUT if is 1
						step = 1
						QAnswered = 0
						proc_time = math.floor(os.clock()) -- 2ND CHRONO INIT MANDATORY
						if localHour >= 17 or localHour <= 8 then DomeLight = 1 else DomeLight = 2 end
						message_time=math.floor(os.clock()) + 15  -- used by function AutoClear
						function Message()
							message_done = 0 -- used by function AutoClear
							if normal_messages == 1 then big_bubble( 50, 20, "COCKPIT PREPARATION.","The cockpit preparation is conducted by the PF BUT we","are delegating it to the PM, and you do the walkaround.","You have to initialize the FMGS anyway.") end
						end -- I do the message on second item to avoid conflit with the RESET DISPLAY
						reset_VR_message_popup()
						ground_stuff = 15
					end

					------FLAPS SELECTION FOR TAKE OFF---------------------------------------------------
					-------------------------------------------------------------------------------------
					if QAnswered < 2 and current_time >= proc_time + 30 then
						-- print an on-screen button for user choice for TO flaps
						if QAnswered == 0 then play_sound(TOflapsQ_sound) QAnswered = 1 end
						-- the question is displayed regardless of the state of the procedure progress by the FO
						-- The question is erazed later, when reaching the pint where the FO needs to input the data, if no response, flaps 1 will be elected.
						function ClickForProcTrigger()
							--if GUI_messages_in_circle_and_all_messages == true then
									draw_string(328, 60, "FLAPS 1", "white")
									draw_string(337, 48, "(def)", "white")
									graphics.draw_circle( 350, 61, 25, 1)
									draw_string(378, 60, "FLAPS 2", "green")
									graphics.draw_circle( 400, 61, 25, 1)
									draw_string(428, 60, "FLAPS 3", "green")
									graphics.draw_circle( 450, 61, 25, 1)
									if MOUSE_X <= 370 and MOUSE_X >=330 and MOUSE_Y <= 80  and MOUSE_Y >= 40 and MOUSE_STATUS == "down" then
										graphics.draw_filled_circle( 350, 61, 20, 2)
										TOFlapsWanted = 1
										QAnswered = 2
										reset_VR_message_popup()
									elseif MOUSE_X <= 420 and MOUSE_X >=380 and MOUSE_Y <= 80  and MOUSE_Y >= 40 and MOUSE_STATUS == "down" then
										graphics.draw_filled_circle( 400, 61, 20, 2)
										TOFlapsWanted = 2
										QAnswered = 2
										reset_VR_message_popup()
									elseif MOUSE_X <= 470 and MOUSE_X >=430 and MOUSE_Y <= 80  and MOUSE_Y >= 40 and MOUSE_STATUS == "down" then
										graphics.draw_filled_circle( 450, 61, 20, 2)
										TOFlapsWanted = 3
										QAnswered = 2
										reset_VR_message_popup()
									else MOUSE_STATUS = "up" end
							--end
						end


						-- DISPLAY VR message
						if GUI_VR_message and vr_message_sent == false and QAnswered < 2 then vr_message_sent = true
							show_window_bottom_bar = true
							end_show_time = math.floor(os.clock()) + 20
							Message_wnd_content = "Preselect flaps 2 for takeoff ? (otherwise Flaps 1)"
							Message_wnd_action = "vr_message_sent = false TOFlapsWanted = 2     QAnswered = 2"
							Message_wnd_duration = 30
							show_the_option_window()
						end
						-- End of VR Message
						if Vr_message_current_answer == "yes" then reset_VR_message_popup()
							TOFlapsWanted = 2     QAnswered = 2
						end

					elseif QAnswered == 2 then
						function ClickForProcTrigger()
							draw_string( 0, 0, "")
						end
						reset_VR_message_popup()
					end
					-------------------------------------------------------------------------------------

					--[[
					Cockpit preparation

					The procedure runs from the end of the walkaround to the start clearance.
					In the Airbus documentation, the cockpit preparation is conducted by the PF, while the PM is doing the walkaround. Barometric references, flight directors, ND, oxygen, briefing and final performance items will be made in cooperation.
					In Speedy Copilot for ToLiSS, we can switch roles and ask the PM to complete all items assigned by Airbus to the PF in the tasksharing. This can possibly be done on the real aircraft, depending on the conditions, agreement between the two pilots, airline...
					--]]

					if step == 1 and current_time >= proc_time + 3 then
						function ClickForProcTrigger()
							--if GUI_messages_in_circle_and_all_messages == true then
								if MOUSE_X <= 480 and MOUSE_X >=370 and MOUSE_Y <= 140  and MOUSE_Y >= 40 and MOUSE_STATUS == "down" then
									draw_string( 0, 0, "")
									reset_VR_message_popup()
									step = 13.1
									PM_does_the_cockpit_preparation_instead_of_the_PF = false
									proc_time = math.floor(os.clock()) + 40 -- gives time
									display_bubble("You have choosen not to delegate the cockpit preparation.")
								else MOUSE_STATUS = "up"
									if step <= 2 then
										draw_string(411, 80, "I prefer", "white") draw_string(409, 60, "to do it", "white") draw_string(412, 40, "myself", "white")
										graphics.draw_circle( 430, 60, 45, 2)
									end
								end
							--end
						end
						-- DISPLAY VR message
						if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
							show_window_bottom_bar = true
							end_show_time = math.floor(os.clock()) + 20
							Message_wnd_content = "Do you want to do all the cockpit preparation items yourself ? (Otherwise you agree to delegate it to the PM)."
							Message_wnd_action = "vr_message_sent = false step = 13.1     proc_time = math.floor(os.clock()) + 40	PM_does_the_cockpit_preparation_instead_of_the_PF = false"
							Message_wnd_duration = 7
							show_the_option_window()
						end
						--~ -- End of VR Message
						if Vr_message_current_answer == "yes" then
							step = 13.1     proc_time = math.floor(os.clock()) + 40	PM_does_the_cockpit_preparation_instead_of_the_PF = false
							reset_VR_message_popup()
						end
					end


					-------------------------------------------------------------------------------------

					--[[
					Cockpit preparation :

					The PF (can be the PM in Speedy Copilot), on the overhead will scan for white lights OFF, execute the CVR and ground control switch items, put the ADIRS to NAV, the external lights and signs, the probe and window heat, the pack flow, test the engine fire loops, electrical and maintenance panel. On the center instrument panel, he should check the ISIS, click, A/SKID and nose whell steering switches. On the pedestal, the ACP and RMP are then set, and all engine & thurst related levers and selectors are checked for idle, OFF or normal. The ATC is set to standby. The PF continues with the FMS preparation. Later, when both pilots are seated, the PF will set the instruments panel for navigation (set barometric reference and crosscheck, FD/LS, ND, VOR/ADF, and finally the FCU). The PF then tests the oxygen masks, the ECAM (landing elevation is AUTO, ECAM STATUS).
					The  PF concludes by checking the FOB. The conversational departure briefing follows with the PM.

					After the walkaround, the PM sets his navigation instrument in accordance with the PF, tests his oxygen masks, IRS alignement, and FOB which he crosschecks with the other crew member. When ready, the PM completes the conversational departure briefing in cooperation.
					--]]



					--OVERHEAD PANEL:
					--* ALL WHITE LIGHTS...........................................EXTINGUISH (--the fuel pumps)


					if step == 1 and current_time >= proc_time + 20 then
						-- REPAIRING ANY BLOWN TIRE !
						NoseTire = 0
						LeftTire = 0
						RightTire= 0

						--~ message_time=math.floor(os.clock()) + 30
						--~ function Message()
							--~ message_done = 0 -- used by function AutoClear
							--~ draw_string( 50, 20, ground_stuff .. ";" .. step, "grey" ) -- debug message
						--~ end
						FuelPumpOH1 = 1
						if Pack1Switch == 0 then Pack1Switch = 1 end
						if Pack2Switch == 0 then Pack2Switch = 1 end
						--command_once("AirbusFBW/MCDU1Data") --> offer Engine & Aircraft type check to the captain when he's back
						step = 1.1
						proc_time = proc_time - 12
					end

					if step == 1.1 and current_time >= proc_time + 12 then
						show_window_bottom_bar = false
						end_show_time = math.floor(os.clock()) - 20
						--
						FuelPumpOH2 = 1
						--command_once("AirbusFBW/MCDU1LSK4L") --> offer Engine & Aircraft type check to the captain when he's back
						step = 1.2
					end
					if step == 1.2 and current_time >= proc_time + 13 then
						FuelPumpOH3 = 1
						step = 1.3
					end
					if step == 1.3 and current_time >= proc_time + 14 then
						FuelPumpOH4 = 1
						step = 1.4
					end
					if step == 1.4 and current_time >= proc_time + 15 then
						FuelPumpOH5 = 1
						if PLANE_ICAO == "A346" then
							FuelPumpOH7 = 1
							FuelPumpOH8 = 1
							FuelPumpOH10 = 1
						end
						step = 1.5
					end
					if step == 1.5 and current_time >= proc_time + 16 then
						FuelPumpOH6 = 1
						if PLANE_ICAO == "A346" then
							FuelPumpOH9 = 1
							FuelXFER0 = 1    -- AUTOSWITCH
							FuelXFER7 = 0  -- XFEED ENG
							FuelXFER8 = 0  -- XFEED ENG
							FuelXFER9 = 0  -- XFEED ENG
							FuelXFER10 = 0 -- XFEED ENG
							FuelXFER11 = 1
							FuelXFER12 = 1
							FuelXFER13 = 0 -- TSFR AUTO / FWD
						end
						step = 1.8
					end


					if step == 1.8 and current_time >= proc_time + 18 then
						if PLANE_ICAO == "A346" then
							FuelXFER1 = 1
							FuelXFER2 = 1
							FuelXFER3 = 1
						end
						step = 1.9
					end

					if step == 1.9 and current_time >= proc_time + 20 then
						if PLANE_ICAO == "A346" then
							FuelXFER4 = 1
							FuelXFER5 = 1
							FuelXFER6 = 1
						end
						step = 2
						reset_VR_message_popup()
					end


					-- * ALL IR MODE selector.......................................NAV
					-- IR 1
					if step == 2 and current_time >= proc_time + 24 then
						IR1 = 1 -- to NAV
						step = 2.1
					end
					-- IR 2
					if step == 2.1 and current_time >= proc_time + 26 then
						IR2 = 1
						step = 2.2
					end
					-- IR 3
					if step == 2.2 and current_time >= proc_time + 28 then
						IR3 = 1
						step = 2.3
						display_bubble("ADIRS... NAV")
					end
					-- EXTERIOR LIGHTS..............................................SET
					if step == 2.3 and current_time >= proc_time + 32 then
						--message_time=math.floor(os.clock()) + 30
						--function Message()
						--	message_done = 0 -- used by function AutoClear
						--	draw_string( 50, 20, ground_stuff .. ";" .. step, "grey" ) -- debug message
						--end
						if localHour >= 17 or localHour <= 8 then DomeLight = 2 end -- finally put the light to the max at night to see something on the overhead
						-- // -- LIGHTS -- //
						BeaconL			= 0 -- 0 is OFF, 1 is red ON
						WingL			= 0 --
						StrobeL 		= 1 -- 0 is OFF, 1 is AUTO, 2 is ON
						-- // -- LIGHTS -- // end of section //
						step = 2.4
					end

					if step == 2.4 and current_time >= proc_time + 34 then
						play_sound(Typing_sound)
						-- // -- LIGHTS -- //
						NavL 			= 1 -- 0 is OFF, 1 is set #1, 2 is set #2
						TaxiL 			= 0 -- 0 is OFF while 1 is TAXI and 2 is TAKEOFF L.
						LandingLeftL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
						LandingRightL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
						TurnOffL 		= 0 -- 0 is OFF, 1 is ON
						-- // -- LIGHTS -- // end of section //
						step = 2.5
					end

					-- * SIGNS......................................................SET
					if step == 2.5 and current_time >= proc_time + 35 then
						SeatBeltSignsOn = 1
						--play_sound(Typing_sound)
						Belts_trigger = 0
						step = 3
					end
					if step == 3 and current_time >= proc_time + 37 then
						NoSmokingSignsOn = 1
						step = 3.1
					end
					if step == 3.1 and current_time >= proc_time + 39 then
						if not slides_addon_installed then EmerLight = 1 end
						LandscapeCamera = 0
						-- new in 4.5 : flight attendant do also their job on the FAP for CIDS
						cabinready = 0
						-- PROB/WINDOW HEAT .................................................... AUTO

						-- ...
						-- ProbeHeatSwitch =
						step = 3.2
					end

					-- LDG ELEV.....................................................AUTO
					if step == 3.2 and current_time >= proc_time + 41 then
						LandElev = -3 -- -3 means "AUTO"
						PressMode = 0 -- 0 is AUTO and 1 is MANUAL. We want AUTO.
						step = 3.3
					end


					-- * PACK FLOW..................................................AS RQRD
					-- ELEC panel...................................................CHECK
					if step == 3.3 and current_time >= proc_time + 43 then
						-- specific link to dataref, (magic table) to be able to unlink the dataref
						-- those specific ECAM button cause problems when not unlinked.
						ECAMelec = dataref_table("AirbusFBW/SDELEC","writable")
						ECAMelec[0] = 1
						ECAMelec = nil -- unload dataref
						step = 3.5
					end
					-- BAT..........................................................CHECK
						--off then on
					if step == 3.5 and current_time >= proc_time + 45 then
						BatOH1 = 0
						step = 3.6
					end
					if step == 3.6 and current_time >= proc_time + 50 then
						BatOH1 = 1
						step = 3.7
					end

						--off then on
					if step == 3.7 and current_time >= proc_time + 53 then
						BatOH2 = 0
						step = 3.8
					end
					if step == 3.8 and current_time >= proc_time + 58 then
						BatOH2 = 1
						step = 3.9
					end

					if current_time >= proc_time + 63 and step == 3.9 then
						ECAMelec = dataref_table("AirbusFBW/SDELEC","writable")
						ECAMelec[0] = 0
						ECAMelec = nil -- unload dataref
						step = 3.95
					end
					-- ENG FIRE.....................................................CHECK / TEST
					-- ENG 1 Fire test
					if current_time >= proc_time + 65 and step == 3.95 then
						command_begin("AirbusFBW/FireTestENG1")
						if current_time >= proc_time + 69 then step = 4 end
						--step = 4
						-- maintains it pressed 2 sec.
						display_bubble("Engines fire tests.")
					end


					if current_time >= proc_time + 70 and step == 4 then
						command_end("AirbusFBW/FireTestENG1")
						step = 4.1
					end

					-- ENG 2 Fire test
					if current_time >= proc_time + 72 and step == 4.1 then
						command_begin("AirbusFBW/FireTestENG2")
						if current_time >= proc_time + 76 then step = 4.2 end
						--step = 4.2
						-- maintains it pressed 2 sec.
					end

					if current_time >= proc_time + 77 and  step == 4.2 then
						command_end("AirbusFBW/FireTestENG2")
						if PLANE_ICAO == "A346" then
							step = 4.31
						else
							step = 4.3
						end
					end

					if PLANE_ICAO == "A346" then
						-- ENG 3 Fire test
						if current_time >= proc_time + 79 and step == 4.31 then
							command_begin("AirbusFBW/FireTestENG3")
							if current_time >= proc_time + 83 then step = 4.32 end
							-- maintains it pressed 2 sec.
						end

						if current_time >= proc_time + 84 and  step == 4.32 then
							command_end("AirbusFBW/FireTestENG3")
							step = 4.33
						end

						-- ENG 4 Fire test
						if current_time >= proc_time + 86 and step == 4.33 then
							command_begin("AirbusFBW/FireTestENG4")
							if current_time >= proc_time + 90 then step = 4.34 end
							--step = 4.2
							-- maintains it pressed 2 sec.
						end

						if current_time >= proc_time + 91 and  step == 4.34 then
							command_end("AirbusFBW/FireTestENG4")
							step = 4.3
							proc_time=math.floor(os.clock()) - 77
							vr_message_sent = false
						end
					end

					--AUDIO SWITCH............................................................... NORM
					--PA (3rd occupant) ......................................................... RECEPT
					--MAINT panel ................................................................ CHECK

					-- Center instrument panel
					--* ISIS ....................................................................... CHECK
					--* CLOCK ....................................................... CHECK / SET
					--* A/SKID & N/W STRG sw .................................... ON



					-- RMP..........................................................SET
					if current_time >= proc_time + 80 and step == 4.3 then


					if XPLMFindDataRef("AirbusFBW/NWSnAntiSkid") ~= nil then
						temporary = dataref_table("AirbusFBW/NWSnAntiSkid","readonly")
						if temporary == 0 then -- a failure is detected by the CM2 on the checked system !
							display_bubble("Check A/SKID & N/W STRG sw ON")
							if TL_Keep_secondary_sounds == "activate" then  play_sound(CoughSound) end
							-- DISPLAY VR message
							if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
								show_window_bottom_bar = true
								end_show_time = math.floor(os.clock()) + 20
								Message_wnd_content = "Check A/SKID & N/W STRG sw ON"
								Message_wnd_action = "vr_message_sent = false"
								Message_wnd_duration = 5
							end
							-- End of VR Message
						end
						temporary = nil -- unload dataref
					end


						-- DOORS (2 is open while 0 is closed. 1 is AUTO) --delayed for compatibility with disarming slides if required
						if forward_JARstairs_wanted == 1 and AircraftIsP2F == 0 and not slides_addon_installed then PaxDoorRearLeft = 2 else PaxDoorRearLeft = 0 end
						ServiceDoor1R = 0
						ServiceDoor2R = 0
						CargoDoor1 = 2
						CargoDoor2 = 2
						if (AIRCRAFT_FILENAME == "a321.acf" or AIRCRAFT_FILENAME == "a321_StdDef.acf" or AIRCRAFT_FILENAME == "a321_XP11.acf" or PLANE_ICAO == "A346" ) then
							BulkDoor = 2
						end
						--message_time=math.floor(os.clock())  -- used by function AutoClear
						--function Message()
						--	message_done = 0 -- used by function AutoClear
						--	if normal_messages == 1 then big_bubble( 50, 20, "ECAM STATUS") end
						--end
						--ECAMstatus = dataref_table("AirbusFBW/SDSTATUS","writable")
						--ECAMstatus[0] = 1
						--ECAMstatus = nil -- unload dataref
						-- if TL_Keep_secondary_sounds == "activate" then play_sound(CoughSound) end
						--play_sound(Checked_sound)
						---- ref : https://forums.x-plane.org/index.php?/forums/topic/143493-undefine-a-dataref/
						step = 4.4
					end
					--[[
					PEDESTAL PF :

					ACP ..................................................... CHECK ON/SET
					SWITCHING PANEL.......................NORM
					* THRUST LEVERS ............................IDLE (ok)
					* ENG MASTER LEVERS .................. OFF  (ok)
					* ENG MODE selector ........................ NORM  (ok)
					* CKPT DOOR sw ............................... NORM
					*PARK BRK handle ............................ ON
					GRAVITY GEAR EXTN................... CHECK STOWED  (ok)
					* ATC...................................................STBY
					RMP ................................................... CHECK ON/SET
					* FMS.......................................... PREPARE
					--]]

					if current_time >= proc_time + 82 and step == 4.4 then
						--ACP ..................................................... CHECK ON/SET
						-- room for future improvement
						-- SWITCHING PANEL.......................NORM
						-- room for future improvement
						test_possible_failure("ckpt/gravityGearOn/anim") --<-- I have space here so I put it here
						step = 5
					end

					if current_time >= proc_time + 84 and step == 5 then
						--* CKPT DOOR sw ............................... NORM
						doorLock = 1
						--ATC...................................................STBY
						XPonDr = 0
						step = 6
					end

					if current_time >= proc_time + 86 and step == 6 then
						--RMP ................................................... CHECK ON/SET
						RMP1 = 1
						step = 7
					end


					if current_time >= proc_time + 88 and step == 7 then
						RMP3 = 1
						RMP2 = 1
						--~ message_time=math.floor(os.clock())
						--~ function Message()
							--~ message_done = 0 -- used by function AutoClear
							--~ draw_string( 50, 20, ground_stuff .. ";" .. step, "grey" ) -- debug message
						--~ end
						--ECAMstatus = dataref_table("AirbusFBW/SDSTATUS","writable")
						--ECAMstatus[0] = 0
						--ECAMstatus = nil -- unload dataref
						---- ref : https://forums.x-plane.org/index.php?/forums/topic/143493-undefine-a-dataref/
						fmgs_time=math.floor(os.clock())
						step = 8
					end



					-- FMGS (part of)-----------------------------------------------

					if  current_time >= fmgs_time + 2 and step == 8  then
						--if step == 4.5 then
						NDmodeFO = 4 -- PLAN
						PaxDoor1L = 2 -- delayed for compatibility with slides addon
						message_time=math.floor(os.clock())  -- used by function AutoClear
						function Message()
							message_done = 0 -- used by function AutoClear
							if normal_messages == 1 then big_bubble( 50, 20, "FMGS") end
						end
						step = 8.1
					end
					if step == 8.1 and current_time >= fmgs_time + 4 then
						message_time=math.floor(os.clock()) + 30
						function Message()
							message_done = 0 -- used by function AutoClear
							draw_string( 50, 20, ground_stuff .. ";" .. step, "grey" ) -- debug message
						end
						command_once("AirbusFBW/MCDU2Init") --> IRS ALIGN
						step = 8.2
					end
					if step == 8.2 and current_time >= fmgs_time + 6 then
						command_once("AirbusFBW/MCDU2LSK3R") --> IRS ALIGN
						-- if able, otherwise it just go through without detrimental effect
						step = 8.3
					end

					if step == 8.3 and current_time >= fmgs_time + 10 then
						-- command_once  --> IRS ALIGN ON REF
						-- can fail but it doesn't matter, the user will do that at some point as well.
						step = 8.4
					end

					if step == 8.4 and current_time >= fmgs_time + 10.5 then
						-- command_once  --> IRS ALIGN ON REF
						-- can fail but it doesn't matter, the user will do that at some point as well.
						step = 8.45
					end

					if step == 8.45 and current_time >= fmgs_time + 11 then
						if costindex == -1 then costindex = 0 end --> set cost index to zero (if possible)
						command_once("AirbusFBW/MCDU2Init") --> ZFW Insertion
						step = 8.5
					end
					if step == 8.5 and current_time >= fmgs_time + 12 then
						command_once("AirbusFBW/MCDU2SlewRight") --> ZFW Insertion
						if TL_Keep_secondary_sounds == "activate" then play_sound(ZFW_sound) end
						step = 8.6
					end
					if step == 8.6 and current_time >= fmgs_time + 14 then
						InitZFW = (m_total - m_fuel_total)
						InitZFWCG = aircraft_calculated_ZFWCG
						-- we will expect user to crosscheck data with the ISCS.
						InitBlockFuel = m_fuel_total  -- to be set in kg, the plane rounds up
						message_time=math.floor(os.clock()) - 5
						function Message()
							message_done = 0 -- used by function AutoClear
							draw_string( 50, 20, "Don't forget to crosscheck ZFWCG/ZFW on INITB.", "orange" ) -- debug message
						end
						step = 8.7
					end

					if step == 8.7 and current_time >= fmgs_time + 15 then
						command_once("AirbusFBW/MCDU2Perf") --> TO FLAPS Insertion
						step = 8.8
					end

					-- default escape : flaps 1 for takeoff (if no user response to takeoff flaps quesition)
					if step == 8.8 and QAnswered == 2 and current_time >= fmgs_time + 17 then step = 9 end
					if step == 8.8 and current_time >= fmgs_time + 30 then
						TOFlapsWanted = 1
						QAnswered = 2 -- auto
					end

					if step == 9 then
						fmgs_time=math.floor(os.clock()) -- reset proc_time after having waited for user
						if TOFlapsWanted == 1 then command_once("AirbusFBW/MCDU2Key1") step = 9.1 end --> TO FLAPS 1 Insertion
						if TOFlapsWanted == 2 then command_once("AirbusFBW/MCDU2Key2") step = 9.1 end --> TO FLAPS 2 Insertion
						--TOFlapsWanted == 3 added on 1st october 2022
						if TOFlapsWanted == 3 then command_once("AirbusFBW/MCDU2Key3") step = 9.1 end --> TO FLAPS 3 Insertion
					end

					if step == 9.1  and current_time >= fmgs_time + 2 then
						command_once("AirbusFBW/MCDU2KeySlash")
						step = 9.2
					end

					-- FMGS (TRIM POS format)---------------------------------------

					-- for trim we are reading the full CG
					-- We expect the user to cross-check the CG and THS anyway.

						-- AIRBUS 319

					if step == 9.2  and current_time >= fmgs_time + 5 and (AIRCRAFT_FILENAME == "a319_StdDef.acf" or AIRCRAFT_FILENAME == "a319.acf" or AIRCRAFT_FILENAME == "a319_XP11.acf") then
						-- Trim car #1
						if aircraft_CG < 30.6 then command_once("AirbusFBW/MCDU2KeyU")
						elseif aircraft_CG >= 30.6 then command_once("AirbusFBW/MCDU2KeyD")
						end
						step = 9.3
					end

					if step == 9.3  and current_time >= fmgs_time + 6 and (AIRCRAFT_FILENAME == "a319_StdDef.acf" or AIRCRAFT_FILENAME == "a319.acf" or AIRCRAFT_FILENAME == "a319_XP11.acf") then
						-- Trim car #2
						if aircraft_CG < 30.6 then command_once("AirbusFBW/MCDU2KeyP")
						elseif aircraft_CG >= 30.6 then command_once("AirbusFBW/MCDU2KeyN")
						end
						step = 9.4
					end


					if step == 9.4  and current_time >= fmgs_time + 7 and (AIRCRAFT_FILENAME == "a319_StdDef.acf" or AIRCRAFT_FILENAME == "a319.acf" or AIRCRAFT_FILENAME == "a319_XP11.acf") then
						-- Trim car #3
						if aircraft_CG < 20 then command_once("AirbusFBW/MCDU2Key3")
						elseif (aircraft_CG < 23.7 and aircraft_CG >= 20)  or aircraft_CG >= 37.5 then command_once("AirbusFBW/MCDU2Key2")
						elseif  (aircraft_CG >= 23.7 and aircraft_CG < 27.4) or (aircraft_CG >= 33.8 and aircraft_CG < 37.5) then command_once("AirbusFBW/MCDU2Key1")
						else command_once("AirbusFBW/MCDU2Key0")
						end
						step = 9.5
					end


						-- AIRBUS 320

					if step == 9.2  and current_time >= fmgs_time + 5 and (AIRCRAFT_FILENAME == "a320_StdDef.acf" or AIRCRAFT_FILENAME == "a320.acf" or AIRCRAFT_FILENAME == "a320_XP11.acf") then
						-- Trim car #1
						if aircraft_CG < 29 then command_once("AirbusFBW/MCDU2KeyU")
						elseif aircraft_CG >= 29 then command_once("AirbusFBW/MCDU2KeyD")
						end
						step = 9.3
					end

					if step == 9.3  and current_time >= fmgs_time + 6 and (AIRCRAFT_FILENAME == "a320_StdDef.acf" or AIRCRAFT_FILENAME == "a320.acf" or AIRCRAFT_FILENAME == "a320_XP11.acf") then
						-- Trim car #2
						if aircraft_CG < 29 then command_once("AirbusFBW/MCDU2KeyP")
						elseif aircraft_CG >= 29 then command_once("AirbusFBW/MCDU2KeyN")
						end
						step = 9.4
					end


					if step == 9.4  and current_time >= fmgs_time + 7 and (AIRCRAFT_FILENAME == "a320_StdDef.acf" or AIRCRAFT_FILENAME == "a320.acf" or AIRCRAFT_FILENAME == "a320_XP11.acf") then
						-- Trim car #3
						if aircraft_CG < 20 or aircraft_CG >= 37 then command_once("AirbusFBW/MCDU2Key2")
						elseif  (aircraft_CG >= 20 and aircraft_CG < 24) or (aircraft_CG >= 34.0 and aircraft_CG < 37) then command_once("AirbusFBW/MCDU2Key1")
						else command_once("AirbusFBW/MCDU2Key0")
						end
						step = 9.5
					end


						-- AIRBUS 321

					if step == 9.2  and current_time >= fmgs_time + 5 and (AIRCRAFT_FILENAME == "a321.acf" or AIRCRAFT_FILENAME == "a321_StdDef.acf" or AIRCRAFT_FILENAME == "a321_XP11.acf") then
						-- Trim car #1
						if aircraft_CG < 29 then command_once("AirbusFBW/MCDU2KeyU")
						elseif aircraft_CG >= 29 then command_once("AirbusFBW/MCDU2KeyD")
						end
						step = 9.3
					end

					if step == 9.3  and current_time >= fmgs_time + 6 and (AIRCRAFT_FILENAME == "a321.acf" or AIRCRAFT_FILENAME == "a321_StdDef.acf" or AIRCRAFT_FILENAME == "a321_XP11.acf") then
						-- Trim car #2
						if aircraft_CG < 29 then command_once("AirbusFBW/MCDU2KeyP")
						elseif aircraft_CG >= 29 then command_once("AirbusFBW/MCDU2KeyN")
						end
						step = 9.4
					end


					if step == 9.4  and current_time >= fmgs_time + 7 and (AIRCRAFT_FILENAME == "a321.acf" or AIRCRAFT_FILENAME == "a321_StdDef.acf" or AIRCRAFT_FILENAME == "a321_XP11.acf") then
						-- Trim car #3
						if aircraft_CG < 14 then command_once("AirbusFBW/MCDU2Key4")
						elseif (aircraft_CG < 18 and aircraft_CG >= 16)  or aircraft_CG >= 39 then command_once("AirbusFBW/MCDU2Key3")
						elseif (aircraft_CG < 22 and aircraft_CG >= 18)  or (aircraft_CG < 39 and aircraft_CG >= 35) then command_once("AirbusFBW/MCDU2Key2")
						elseif  (aircraft_CG >= 22 and aircraft_CG < 24) or (aircraft_CG >= 32 and aircraft_CG < 35) then command_once("AirbusFBW/MCDU2Key1")
						else command_once("AirbusFBW/MCDU2Key0")
						end
						step = 9.5
					end

					if step == 9.5 and current_time >= fmgs_time + 8 then
						-- Trim car #4
						command_once("AirbusFBW/MCDU2KeyDecimal")
						step = 9.6
					end



						-- AIRBUS 340-600

					if step == 9.2  and current_time >= fmgs_time + 5 and (PLANE_ICAO == "A346") then
						-- Trim car #1
						if aircraft_CG < 37 then command_once("AirbusFBW/MCDU2KeyU")
						elseif aircraft_CG >= 37 then command_once("AirbusFBW/MCDU2KeyD")
						end
						step = 9.3
					end

					if step == 9.3  and current_time >= fmgs_time + 6 and (PLANE_ICAO == "A346") then
						-- Trim car #2
						if aircraft_CG < 37 then command_once("AirbusFBW/MCDU2KeyP")
						elseif aircraft_CG >= 37 then command_once("AirbusFBW/MCDU2KeyN")
						end
						step = 9.4
					end


					if step == 9.4  and current_time >= fmgs_time + 7 and (PLANE_ICAO == "A346") then
						-- Trim car #3
						if aircraft_CG < 24.4 then command_once("AirbusFBW/MCDU2Key4")
						elseif (aircraft_CG < 27.4 and aircraft_CG >= 24.4)  then command_once("AirbusFBW/MCDU2Key3")
						elseif (aircraft_CG < 30.6 and aircraft_CG >= 27.4)  then command_once("AirbusFBW/MCDU2Key2")
						elseif  (aircraft_CG >= 30.6 and aircraft_CG < 34) or (aircraft_CG >= 39.9) then command_once("AirbusFBW/MCDU2Key1")
						else command_once("AirbusFBW/MCDU2Key0")
						end
						step = 9.5
					end

					if step == 9.5 and current_time >= fmgs_time + 8 then
						-- Trim car #4
						command_once("AirbusFBW/MCDU2KeyDecimal")
						step = 9.6
					end


						-- AIRBUS 319

					if step == 9.6 and current_time >= fmgs_time + 9 and (AIRCRAFT_FILENAME == "a319_StdDef.acf" or AIRCRAFT_FILENAME == "a319.acf" or AIRCRAFT_FILENAME == "a319_XP11.acf") then
						-- Trim car #5
						if aircraft_CG < 17.8 then trim = 'UP 2.5' command_once("AirbusFBW/MCDU2Key5")
						elseif aircraft_CG >= 17.8 and aircraft_CG < 18.2 then trim = 'UP 3.5' command_once("AirbusFBW/MCDU2Key5")
						elseif aircraft_CG >= 18.2 and aircraft_CG < 18.7 then trim = 'UP 3.5'  command_once("AirbusFBW/MCDU2Key5")
						elseif aircraft_CG >= 18.7 and aircraft_CG < 19.1 then trim = 'UP 3.4' command_once("AirbusFBW/MCDU2Key4")
						elseif aircraft_CG >= 19.1 and aircraft_CG < 19.6 then trim = 'UP 3.3'  command_once("AirbusFBW/MCDU2Key3")
						elseif aircraft_CG >= 19.6 and aircraft_CG < 20 then trim = 'UP 3.2' command_once("AirbusFBW/MCDU2Key2")
						elseif aircraft_CG >= 20 and aircraft_CG < 20.5 then trim = 'UP 2.8' command_once("AirbusFBW/MCDU2Key8")
						elseif aircraft_CG >= 20.5 and aircraft_CG < 21 then trim = 'UP 2.7' command_once("AirbusFBW/MCDU2Key7")
						elseif aircraft_CG >= 21 and aircraft_CG < 21.4 then trim = 'UP 2.6'command_once("AirbusFBW/MCDU2Key6")
						elseif aircraft_CG >= 21.4 and aircraft_CG < 21.9 then trim = 'UP 2.5' command_once("AirbusFBW/MCDU2Key5")
						elseif aircraft_CG >= 21.9 and aircraft_CG < 22.3 then trim = 'UP 2.4'command_once("AirbusFBW/MCDU2Key4")
						elseif aircraft_CG >= 22.3 and aircraft_CG < 22.8 then trim = 'UP 2.2' command_once("AirbusFBW/MCDU2Key2")
						elseif aircraft_CG >= 22.8 and aircraft_CG < 23.3 then trim = 'UP 2.1' command_once("AirbusFBW/MCDU2Key2")
						elseif aircraft_CG >= 23.3 and aircraft_CG < 23.7 then trim = 'UP 2.0' command_once("AirbusFBW/MCDU2Key0")
						elseif aircraft_CG >= 23.7 and aircraft_CG < 24.2 then trim = 'UP 1.8' command_once("AirbusFBW/MCDU2Key8")
						elseif aircraft_CG >= 24.2 and aircraft_CG < 24.6 then trim = 'UP 1.7' command_once("AirbusFBW/MCDU2Key7")
						elseif aircraft_CG >= 24.6 and aircraft_CG < 25.1 then trim = 'UP 1.5' command_once("AirbusFBW/MCDU2Key5")
						elseif aircraft_CG >= 25.1 and aircraft_CG < 25.6 then trim = 'UP 1.4'command_once("AirbusFBW/MCDU2Key4")
						elseif aircraft_CG >= 25.6 and aircraft_CG < 26 then trim = 'UP 1.3' command_once("AirbusFBW/MCDU2Key3")
						elseif aircraft_CG >= 26 and aircraft_CG < 26.5 then trim = 'UP 1.1' command_once("AirbusFBW/MCDU2Key1")
						elseif aircraft_CG >= 26.5 and aircraft_CG < 26.9 then trim = 'UP 1.0' command_once("AirbusFBW/MCDU2Key0")
						elseif aircraft_CG >= 26.9 and aircraft_CG < 27.4 then trim = 'UP 1.0' command_once("AirbusFBW/MCDU2Key0")
						elseif aircraft_CG >= 27.4 and aircraft_CG < 27.9 then trim = 'UP 0.9' command_once("AirbusFBW/MCDU2Key9")
						elseif aircraft_CG >= 27.9 and aircraft_CG < 28.3 then trim = 'UP 0.7' command_once("AirbusFBW/MCDU2Key7")
						elseif aircraft_CG >= 28.3 and aircraft_CG < 28.8 then trim = 'UP 0.5' command_once("AirbusFBW/MCDU2Key5")
						elseif aircraft_CG >= 28.8 and aircraft_CG < 29.2 then trim = 'UP 0.4' command_once("AirbusFBW/MCDU2Key4")
						elseif aircraft_CG >= 29.2 and aircraft_CG < 29.7 then trim = 'UP 0.3' command_once("AirbusFBW/MCDU2Key3")
						elseif aircraft_CG >= 29.7 and aircraft_CG < 30.2 then trim = 'UP 0.1' command_once("AirbusFBW/MCDU2Key1")
						elseif aircraft_CG >= 30.2 and aircraft_CG < 30.6 then trim = 'UP 0.0' command_once("AirbusFBW/MCDU2Key0")


						elseif aircraft_CG >= 30.6 and aircraft_CG < 31.1 then trim = 'DN 0.1' command_once("AirbusFBW/MCDU2Key1")
						elseif aircraft_CG >= 31.1 and aircraft_CG < 31.5 then trim = 'DN 0.3' command_once("AirbusFBW/MCDU2Key3")
						elseif aircraft_CG >= 31.5 and aircraft_CG < 32 then trim = 'DN 0.4' command_once("AirbusFBW/MCDU2Key4")
						elseif aircraft_CG >= 32 and aircraft_CG < 32.5 then trim = 'DN 0.5' command_once("AirbusFBW/MCDU2Key5")
						elseif aircraft_CG >= 32.5 and aircraft_CG < 32.9 then trim = 'DN 0.7' command_once("AirbusFBW/MCDU2Key7")
						elseif aircraft_CG >= 32.9 and aircraft_CG < 33.4 then trim = 'DN 0.8' command_once("AirbusFBW/MCDU2Key8")
						elseif aircraft_CG >= 33.4 and aircraft_CG < 33.8 then trim = 'DN 0.9' command_once("AirbusFBW/MCDU2Key9")

						elseif aircraft_CG >= 33.8 and aircraft_CG < 34.3 then trim = 'DN 1.0' command_once("AirbusFBW/MCDU2Key0")
						elseif aircraft_CG >= 34.3 and aircraft_CG < 34.8 then trim = 'DN 1.2' command_once("AirbusFBW/MCDU2Key2")
						elseif aircraft_CG >= 34.8 and aircraft_CG < 35.2 then trim = 'DN 1.4' command_once("AirbusFBW/MCDU2Key4")
						elseif aircraft_CG >= 35.2 and aircraft_CG < 35.7 then trim = 'DN 1.5' command_once("AirbusFBW/MCDU2Key5")
						elseif aircraft_CG >= 35.7 and aircraft_CG < 36.1 then trim = 'DN 1.6' command_once("AirbusFBW/MCDU2Key6")
						elseif aircraft_CG >= 36.1 and aircraft_CG < 36.6 then trim = 'DN 1.7' command_once("AirbusFBW/MCDU2Key7")
						elseif aircraft_CG >= 36.6 and aircraft_CG < 37.1 then trim = 'DN 1.8' command_once("AirbusFBW/MCDU2Key8")
						elseif aircraft_CG >= 37.1 and aircraft_CG < 37.5 then trim = 'DN 1.9' command_once("AirbusFBW/MCDU2Key9")

						elseif aircraft_CG >= 37.5 and aircraft_CG < 38 then trim = 'DN 2.0' command_once("AirbusFBW/MCDU2Key0")
						elseif aircraft_CG >= 38 and aircraft_CG < 38.4 then trim = 'DN 2.1' command_once("AirbusFBW/MCDU2Key1")
						elseif aircraft_CG >= 38.4 and aircraft_CG < 38.9 then trim = 'DN 2.2' command_once("AirbusFBW/MCDU2Key2")
						elseif aircraft_CG >= 38.9 and aircraft_CG < 39.4 then trim = 'DN 2.4' command_once("AirbusFBW/MCDU2Key4")
						elseif aircraft_CG >= 39.4 and aircraft_CG < 39.8 then trim = 'DN 2.6' command_once("AirbusFBW/MCDU2Key6")
						elseif aircraft_CG >= 39.8 then trim = 'DN 2.7' command_once("AirbusFBW/MCDU2Key7")
						end
						display_bubble("A319 FLAPS/THS : " .. TOFlapsWanted .. " / " .. trim , "Crosscheck CG and TRIM.")
						fmgs_time=math.floor(os.clock()) -- reset proc_time after having waited for user -- alows to execture the function every 10 seconds only to save performance and at the same time, to not negativaly impact script sequence.
						step = 9.7
					end

					-- AIRBUS A320

					if step == 9.6 and current_time >= fmgs_time + 9 and (AIRCRAFT_FILENAME == "a320_StdDef.acf" or AIRCRAFT_FILENAME == "a320.acf" or AIRCRAFT_FILENAME == "a320_XP11.acf") then
						-- Trim car #5
						if aircraft_CG < 17.8 then trim = 'UP 2.5' command_once("AirbusFBW/MCDU2Key5")
						elseif aircraft_CG < 18 then trim = 'UP 2.3' command_once("AirbusFBW/MCDU2Key3")
						elseif aircraft_CG < 19 then trim = 'UP 2.2'  command_once("AirbusFBW/MCDU2Key2")
						elseif aircraft_CG < 20 then trim = 'UP 2.0' command_once("AirbusFBW/MCDU2Key0")
						elseif aircraft_CG < 21 then trim = 'UP 1.8'  command_once("AirbusFBW/MCDU2Key8")
						elseif aircraft_CG < 22 then trim = 'UP 1.6' command_once("AirbusFBW/MCDU2Key6")
						elseif aircraft_CG < 23 then trim = 'UP 1.3' command_once("AirbusFBW/MCDU2Key3")
						elseif aircraft_CG < 24 then trim = 'UP 1.0' command_once("AirbusFBW/MCDU2Key0")
						elseif aircraft_CG < 25 then trim = 'UP 0.8'command_once("AirbusFBW/MCDU2Key8")
						elseif aircraft_CG < 26 then trim = 'UP 0.6' command_once("AirbusFBW/MCDU2Key6")
						elseif aircraft_CG < 27 then trim = 'UP 0.4'command_once("AirbusFBW/MCDU2Key4")
						elseif aircraft_CG < 28 then trim = 'UP 0.2' command_once("AirbusFBW/MCDU2Key2")
						elseif aircraft_CG < 29 then trim = 'UP 0.0' command_once("AirbusFBW/MCDU2Key0")
						elseif aircraft_CG < 30 then trim = 'DN 0.2' command_once("AirbusFBW/MCDU2Key2")
						elseif aircraft_CG < 31 then trim = 'DN 0.5' command_once("AirbusFBW/MCDU2Key5")
						elseif aircraft_CG < 32 then trim = 'DN 0.7' command_once("AirbusFBW/MCDU2Key7")
						elseif aircraft_CG < 33 then trim = 'DN 0.9' command_once("AirbusFBW/MCDU2Key9")
						elseif aircraft_CG < 34 then trim = 'DN 1.1'command_once("AirbusFBW/MCDU2Key1")
						elseif aircraft_CG < 35 then trim = 'DN 1.4' command_once("AirbusFBW/MCDU2Key4")
						elseif aircraft_CG < 36 then trim = 'DN 1.5' command_once("AirbusFBW/MCDU2Key5")
						elseif aircraft_CG < 37 then trim = 'DN 1.9' command_once("AirbusFBW/MCDU2Key9")
						elseif aircraft_CG < 38 then trim = 'DN 2.0' command_once("AirbusFBW/MCDU2Key0")
						elseif aircraft_CG < 39 then trim = 'DN 2.3' command_once("AirbusFBW/MCDU2Key3")
						elseif aircraft_CG < 40 then trim = 'DN 2.4' command_once("AirbusFBW/MCDU2Key4")
						else trim = 'DN 2.5' command_once("AirbusFBW/MCDU2Key5")
						end
						display_bubble("A320 FLAPS & TRIM : " .. TOFlapsWanted .. " / " .. trim , "Crosscheck CG and TRIM.")
						fmgs_time=math.floor(os.clock()) -- reset proc_time after having waited for user -- alows to execture the function every 10 seconds only to save performance and at the same time, to not negativaly impact script sequence.
						step = 9.7
					end
						-- AIRBUS 321

					if step == 9.6 and current_time >= fmgs_time + 9 and ( AIRCRAFT_FILENAME == "a321.acf" or AIRCRAFT_FILENAME == "a321_StdDef.acf" or AIRCRAFT_FILENAME == "a321_XP11.acf" ) then
						-- Trim car #5
						if aircraft_CG < 12 then trim = 'UP 4.5' command_once("AirbusFBW/MCDU2Key5")
						elseif aircraft_CG >= 12 and aircraft_CG < 14 then trim = 'UP 4.0' command_once("AirbusFBW/MCDU2Key0")
						elseif aircraft_CG >= 14 and aircraft_CG < 16 then trim = 'UP 3.5' command_once("AirbusFBW/MCDU2Key5")
						elseif aircraft_CG >= 16 and aircraft_CG < 17 then trim = 'UP 3.2' command_once("AirbusFBW/MCDU2Key2")
						elseif aircraft_CG >= 17 and aircraft_CG < 18 then trim = 'UP 3.0'  command_once("AirbusFBW/MCDU2Key0")
						elseif aircraft_CG >= 18 and aircraft_CG < 20 then trim = 'UP 2.5' command_once("AirbusFBW/MCDU2Key5")
						elseif aircraft_CG >= 20 and aircraft_CG < 22 then trim = 'UP 2.0'  command_once("AirbusFBW/MCDU2Key0")
						elseif aircraft_CG >= 22 and aircraft_CG < 23 then trim = 'UP 1.6' command_once("AirbusFBW/MCDU2Key6")
						elseif aircraft_CG >= 23 and aircraft_CG < 24 then trim = 'UP 1.3' command_once("AirbusFBW/MCDU2Key3")
						elseif aircraft_CG >= 24 and aircraft_CG < 25 then trim = 'UP 0.9' command_once("AirbusFBW/MCDU2Key9")
						elseif aircraft_CG >= 25 and aircraft_CG < 26 then trim = 'UP 0.7'command_once("AirbusFBW/MCDU2Key7")
						elseif aircraft_CG >= 26 and aircraft_CG < 27 then trim = 'UP 0.4' command_once("AirbusFBW/MCDU2Key4")
						elseif aircraft_CG >= 27 and aircraft_CG < 28 then trim = 'UP 0.2'command_once("AirbusFBW/MCDU2Key2")
						elseif aircraft_CG >= 28 and aircraft_CG < 29 then trim = 'UP 0.0' command_once("AirbusFBW/MCDU2Key0")

						elseif aircraft_CG >= 29 and aircraft_CG < 30 then trim = 'DN 0.4' command_once("AirbusFBW/MCDU2Key4")
						elseif aircraft_CG >= 30 and aircraft_CG < 31 then trim = 'DN 0.5' command_once("AirbusFBW/MCDU2Key5")

						elseif aircraft_CG >= 31 and aircraft_CG < 32 then trim = 'DN 0.8' command_once("AirbusFBW/MCDU2Key8")
						elseif aircraft_CG >= 32 and aircraft_CG < 33 then trim = 'DN 1.2' command_once("AirbusFBW/MCDU2Key2")
						elseif aircraft_CG >= 33 and aircraft_CG < 34 then trim = 'DN 1.4' command_once("AirbusFBW/MCDU2Key4")
						elseif aircraft_CG >= 34 and aircraft_CG < 35 then trim = 'DN 1.8'command_once("AirbusFBW/MCDU2Key8")
						elseif aircraft_CG >= 35 and aircraft_CG < 36 then trim = 'DN 2.1' command_once("AirbusFBW/MCDU2Key1")
						elseif aircraft_CG >= 36 and aircraft_CG < 37 then trim = 'DN 2.4' command_once("AirbusFBW/MCDU2Key4")
						elseif aircraft_CG >= 37 and aircraft_CG < 38 then trim = 'DN 2.6' command_once("AirbusFBW/MCDU2Key6")
						elseif aircraft_CG >= 38 and aircraft_CG < 39 then trim = 'DN 2.9' command_once("AirbusFBW/MCDU2Key9")

						elseif aircraft_CG >= 39 and aircraft_CG < 40 then trim = 'DN 3.1' command_once("AirbusFBW/MCDU2Key1")
						elseif aircraft_CG >= 40 and aircraft_CG < 41 then trim = 'DN 3.4' command_once("AirbusFBW/MCDU2Key4")
						elseif aircraft_CG >= 41 then trim = 'DN 3.5' command_once("AirbusFBW/MCDU2Key7")
						end
						display_bubble("A321 FLAPS/THS : " .. TOFlapsWanted .. " / " .. trim , "Crosscheck CG and TRIM.")
						fmgs_time=math.floor(os.clock()) -- reset proc_time after having waited for user -- alows to execture the function every 10 seconds only to save performance and at the same time, to not negativaly impact script sequence.
						step = 9.7
					end


						-- AIRBUS 340-600

					if step == 9.6 and current_time >= fmgs_time + 9 and ( PLANE_ICAO == "A346"  ) then
						-- Trim car #5
						if aircraft_CG < 24.4 then command_once("AirbusFBW/MCDU2Key5")
						elseif (aircraft_CG < 26 and aircraft_CG >= 24.4)  then command_once("AirbusFBW/MCDU2Key5")
						elseif (aircraft_CG < 27.4 and aircraft_CG >= 26)  then command_once("AirbusFBW/MCDU2Key1")
						elseif (aircraft_CG < 29 and aircraft_CG >= 27.4)  then command_once("AirbusFBW/MCDU2Key5")
						elseif (aircraft_CG < 30.6 and aircraft_CG >= 29)  then command_once("AirbusFBW/MCDU2Key1")
						elseif (aircraft_CG < 33 and aircraft_CG >= 30.6)  then command_once("AirbusFBW/MCDU2Key2")
						elseif (aircraft_CG < 35 and aircraft_CG >= 33)  then command_once("AirbusFBW/MCDU2Key5")
						elseif (aircraft_CG >= 35) then command_once("AirbusFBW/MCDU2Key8")
						-- to be refined at a later date
						end
						--display_bubble("A346 FLAPS/THS : " .. TOFlapsWanted .. " / " .. trim , "Crosscheck CG and TRIM.")
						fmgs_time=math.floor(os.clock()) -- reset proc_time after having waited for user -- alows to execture the function every 10 seconds only to save performance and at the same time, to not negativaly impact script sequence.
						step = 9.7
					end

					-- FMGS (formatting TRIM ends)----------------------------------

					if step == 9.7 and current_time >= fmgs_time + 11 then
						command_once("AirbusFBW/MCDU2LSK3R") --> TO FLAPS Insertion
						step = 9.8
					end


					if step == 9.8 and current_time >= fmgs_time + 13 then
						command_once("AirbusFBW/MCDU2Init") -- back to IRS ALIGN for user convenience
						step = 9.9
					end
					if step == 9.9 and current_time >= fmgs_time + 14 then
						command_once("AirbusFBW/MCDU2LSK3R") -- back to IRS ALIGN for user convenience
						proc_time=math.floor(os.clock()) -- reset proc_time after having waited for user
						step = 10
					end

					-- tune the radio frequencies------------
					if current_time >= proc_time + 2 and step == 10 then -- step number 10 is enforced in a code above

					-------------------------------------------
					-- direct skip to that step is available --
					-------------------------------------------
						Current_title = "Cockpit preparation (continued)"


						-- specific link to dataref, (magic table) to be able to unlink the dataref
						-- those specific ECAM button cause problems when not unlinked.
						com2_stdby_freq_hz = dataref_table("sim/cockpit/radios/com2_stdby_freq_hz","writable")
						com2_stdby_freq_hz[0] = 12150
						com2_stdby_freq_hz = nil -- unload dataref
						if FoTunesRadiosInPreparationFlow == 1 then
							com2_freq_hz = dataref_table("sim/cockpit/radios/com2_freq_hz","writable")
							com2_freq_hz[0] = presetFrequency
							com2_freq_hz = nil -- unload dataref
							com1_freq_hz = dataref_table("sim/cockpit/radios/com1_freq_hz","writable")
							com1_freq_hz[0] = presetFrequency
							com1_freq_hz = nil -- unload dataref
						end
						step = 10.5
					end

					-- GLARESHIELD--------------------------------------------------

					--[[ Glareshield PM :
					BAROMETRIC REFERENCE ...........SET/CROSSCHECK
					FD..............................CHECK ON
					LS/ILS .........................AS RQRD
					ND mode and range ..............AS RQRD
					VOR / ADF selector .............AS RQRD
					--]]

					if current_time >= proc_time + 3 and step == 10.5 then
						-- COCKPIT PREPARATION Procedure
						NDmodeFO = 3 -- ARC
						step = 11


					end

					--[[ LATERAL CONSOLE AND PF/PM INSTRUMENT PANELS: PM : ----------------
					OXYGEN MASK..................TEST
					PFD-ND brightness............AS RQRD
					LOUDSPEAKER knob ............SET
					PFD-ND ......................CHECK
					IRS ALIGN....................CHECK
					FOB .........................CHECK
					DEPARTURE BRIEFING...........PERFORM
					--]]

					if current_time >= proc_time + 4 and step == 11 then
						step = 12
						Current_title = "Cockpit preparation (waiting for IRS alignment)"
						display_bubble("Cockpit preparation (waiting for IRS alignment).")
						-- OXY Mask test
						play_sound(O2MaskTest_sound)
						if JAR_Ground_Handling_wanted == 1 then
							--nothing
						else
							l_newval = true
							show_Bus = l_newval
							Bus_chg = true
							show_GPU = l_newval
							GPU_chg = true
							show_FUEL = false
							FUEL_chg = true
							show_Cleaning = false
							Cleaning_chg = true
							show_BeltLoader = l_newval
							BeltLoader_chg = true
							show_Cart = l_newval
							Cart_chg = true
							show_Catering = false
							Catering_chg = true
							show_Cones = l_newval
							Cones_chg = true
							show_People1 = l_newval
							People1_chg = true
							show_People2 = l_newval
							People2_chg = true
							show_People3 = l_newval
							People3_chg = true
							show_People4 = l_newval
							People4_chg = true
							show_Light = false
							Light_chg = true
						end
						-- when the captain will be back from the visual inspection, he will find the MCDU in the original data page.
						-- we help the captain by setting the ZFW, and then restore to this page.
						-- This doesn't preclude the user to check and redo the entries as necessary.
						-- By no means we pretend do to a full FMGS Init in those lines of code.
						-- It's more about a crew ambiance, a shared responsability ambiance here, expecially for the cockpit preparation procedure.
					end

					----------- FINISH when IRS CHECKED ALIGNED -----------

					if step >= 8 and ADIRUTimeToAlign > 0 and IR1 == 1 and IR2 == 1 and IR3 == 1 then
						FD_flag = 2
						-- if IRS not aligned at the start of the cockpit prep procedure, we call IRS alignment once aligned.
					end

					-- ALIGNED ! :

					if current_time >= proc_time + 15 and ADIRUTimeToAlign == 0 and IR1 == 1 and IR2 == 1 and IR3 == 1 and step == 12 then
						Current_title = "Cockpit preparation (continued)"
						display_bubble("Cockpit preparation (continued).")
						set("AirbusFBW/FD1Engage",1)
						set("AirbusFBW/FD2Engage",1)
						command_once("AirbusFBW/MCDU2Fpln")

						if TL_Keep_secondary_sounds == "activate" and  FD_flag == 2 then play_sound(IRSAlign_sound) end
						--only if IRS not aligned at the start of the cockpit prep procedure, we call IRS alignement once aligned. That's why FD_flag == 2.
						step = 13
						proc_time=math.floor(os.clock())
					end

					--* ECAM STATUS.................................................CHECK (PF)
					-- displaced here in official Airbus flows in 2016
					-- is labeled as PF item in the 2021 new patterns, but I believe it's ok to make it do also by Speedy Copilot
					if current_time >= proc_time + 5 and step == 13 then
						-- display_bubble("ECAM Status") -- do not insist on the PM doing it instead of the PF
						ECAMstatus = dataref_table("AirbusFBW/SDSTATUS","writable")
						ECAMstatus[0] = 1
						ECAMstatus = nil -- unload dataref
						play_sound(Checked_sound)
						-- ref : https://forums.x-plane.org/index.php?/forums/topic/143493-undefine-a-dataref/
						step = 13.1
						function ClickForProcTrigger()
							draw_string( 0, 0, "")
						end
						reset_VR_message_popup()
					end

					if current_time >= proc_time + 10 and step == 13.1 then
						--message_time=math.floor(os.clock()) + 30
						--function Message()
						--	message_done = 0 -- used by function AutoClear
						--	draw_string( 50, 20, ground_stuff .. ";" .. step, "grey" ) -- debug message
						--end
						ECAMstatus = dataref_table("AirbusFBW/SDSTATUS","writable")
						ECAMstatus[0] = 0
						ECAMstatus = nil -- unload dataref
						fmgs_time=math.floor(os.clock())
						step = 13.2
					end

					if current_time >= proc_time + 15 and step == 13.2 then
						command_once("AirbusFBW/MCDU2Fpln") -- again.
						message_time=math.floor(os.clock()) + 40  -- used by function AutoClear
						function Message()
							 message_done = 0 -- used by function AutoClear
							 if normal_messages == 1 and APUAvail == 0 then
								big_bubble( 50, 20, "Suspended to the briefing..."," -> Info : APU start was delayed.", "After the conversational departure briefing", "execute the cockpit preparation checklist","then the before start clearance procedure." )
							 elseif normal_messages == 1 then
								big_bubble( 50, 20, "Suspended to the briefing...", "The conversational departure briefing follows.", "After the conversational departure briefing", "execute the cockpit preparation checklist","then the before start clearance procedure." )
							end
						end

						-- sound events -- START
						random = math.random()
						if random > 0.5  then
							play_sound(Preparation_sound)
						else
							play_sound(Preparation2_sound)
						end
						CP_P = true
						random = math.random()
						if random > 0.80 then boardingMusic = 1 end
						if boardingMusic == 1 and TL_Keep_secondary_sounds == "activate" then play_sound(Boarding_Music_alternative) else 	play_sound(Boarding_Music) end
						-- sound events -- END
						step = 0.5
						--SERVICEMIC = 0
						Current_title = "Cockpit preparation (completed)"
						preflightproc_trigger = 2
						preliminaryprocedure_trigger = 2
						beforestartproc_trigger = 0
						Message_wnd_content = "" Vr_message_current_answer = "?" vr_message_sent = false
					end
				end

			end
		end
		do_often("COCKPITPREP()")


		--------------------------------------------------------------------------------
		-- Execute Before start Procedure
		--   When Ext Power is disconnected following a non delayed APU start in preliminary prep.
		--   or ('or' is used to confer more liberty to the user instead of 'and')
		--   when SERVICE MIC is pushed = 0

		local maxdifference = 500 -- kg -- for fuel check
		function BEFORESTART()
			if not SpeedyCopilot_first_load then

			-- set the trigger
				if ToLissPNFonDuty == 1 and preflightproc_trigger == 2 and preliminaryprocedure_trigger == 2 and beforestartproc_trigger < 2 and BatOH1 > 0 then


					-- REDONE THE TRIGGER FOR 2021 EDITION, 2023 edition mod.
					if step == 0.5 and beforestartproc_trigger == 0 then
						function ClickForProcTrigger()

							--if GUI_messages_in_circle_and_all_messages == true then
								graphics.draw_circle( 415, 72, 50, 1)
								if Red_AltitudeBaro == Red_AltitudeBaro_fromMCDU and TL_Accel_AltitudeBaro == TL_Accel_AltitudeBaro_fromMCDU then
									graphics.draw_circle( 415, 72, 54, 2)
									draw_string(395, 90, "Before", "green") draw_string(372, 70, "start clearance", "green") draw_string(388, 50, "procedure", "green")
								else
									draw_string(395, 90, "Before", "white") draw_string(372, 70, "start clearance", "white") draw_string(388, 50, "procedure", "white")
								end
								if MOUSE_X <= 450 and MOUSE_X >=350 and MOUSE_Y <= 110  and MOUSE_Y >= 10 and MOUSE_STATUS == "down" then
									graphics.draw_filled_circle( 415, 72, 47, 2)
									reset_VR_message_popup()
									draw_string(395, 90, "Before", "black") draw_string(372, 70, "start clearance", "black") draw_string(388, 50, "procedure", "black")
									step = 1
									beforestartproc_trigger = 1
									Current_title = "Beginning next procedure"

								-- January 2023 : offer AOC PERF TO by the First officer
								elseif ACARS_PERF_TAKEOFF_step == 0 or ACARS_PERF_TAKEOFF_step == 7 then
									graphics.draw_circle( 715, 72, 50, 1)
									draw_string(695, 90, " AOC", "grey") draw_string(672, 70, "PERF T.O. REQ", "grey") draw_string(688, 50, "via ACARS", "grey")
									if MOUSE_X <= 750 and MOUSE_X >650 and MOUSE_Y <= 110  and MOUSE_Y >= 10 and MOUSE_STATUS == "down" then
										graphics.draw_filled_circle( 715, 72, 47, 2)
										ACARS_PERF_TAKEOFF_step = 0
										ACARS_PERF_TAKEOFF_time = current_time
									else MOUSE_STATUS = "up" end
								end
							--end
						end


						-- DISPLAY VR message
						if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
							show_window_bottom_bar = true
							end_show_time = math.floor(os.clock()) + 20
							Message_wnd_content = ""    Message_wnd_content = "Suspended to the departure briefing and the cockpit preparation checklist. Can we proceed further to the before start clearance flow ?"
							Message_wnd_action = "vr_message_sent = false vr_message_sent = false step = 1 beforestartproc_trigger = 1"
							Message_wnd_duration = 60
							show_the_option_window()
						end
						-- End of VR Message
						if Vr_message_current_answer == "yes" then reset_VR_message_popup()
							step = 1 beforestartproc_trigger = 1
							Vr_message_current_answer = "?"
						end
					end


					-- actions
					-----------------------	Delayed APU start

					-- we check if APU is OFF, instead of checking if the user said in the option to do a delayed start
					-- because, if the user requested in the options a delayed start but started manually the APU in the mean time,
					-- pressing the APU button now would result in shuting down the APU, and we don't want that to happen !

					if step == 1 then
						proc_time = math.floor(os.clock()) -- 2ND CHRONO INIT MANDATORY
						function ClickForProcTrigger()
							draw_string(0, 0, "","grey")
						end
						reset_VR_message_popup()
						Current_title = "Before start clearance procedure"
						step = 2
						display_bubble("Before start clearance procedure")
						if APUAvail == 0 and flag_ExtPower == false then
						---------------	Intercept false GPU disconnection when delayed APU start is in force
							ExtPowerConnected = 1 -- REWIND
							ExtPowerAConnected = 1 -- REWIND A340-600

						end
						if APUAvail == 0 then
							-- apu_started = 0  -- allows the APU chronometer to be triggered when APU reaches idle speed. (mandat. for GPU)
							APUMasterSwitch = 1
							display_bubble("Before start clearance procedure - Start of the APU")
						end
					end

					if current_time >= proc_time + 6 and APUFlapOpenRatio == 1 and step == 2 and beforestartproc_trigger == 1 then
						APUStarterSwitch = 1
						proc_time = math.floor(os.clock()) - 6
						step = 3
					end

					if current_time >= proc_time + 8 and step == 3 and beforestartproc_trigger == 1 then
						APU_Bleed_ON = 1
						-- Now, the bulk is only present in the A321. We want it to to be closed either at the beginning of the process
						-- or at the end of the process because this will appear more random to the final user to get a varied behaviour
						-- of the ground crew
						random = math.random()
						if random > 0.7 then
							if AIRCRAFT_FILENAME == "a321.acf" or AIRCRAFT_FILENAME == "a321_StdDef.acf" or AIRCRAFT_FILENAME == "a321_XP11.acf" then
								BulkDoor = 0
							end
						end
						step = 4
					end

					-- Note : if we did a late APU start then we need to be sure that the APU is running and online
					-- before removing the GPU ! Otherwise, we'll have a (dark) surprise !

					-----------------------	Delayed APU start finished


					--[[
					BEFORE START CLEARANCE PM ITEMS :
					FINAL LOADSHEET .................................CHECK
					CHECK FUEL ON BOARD .............................CHECK
					FINAL T.O PERF DATA ...........................RECOMPUTE
					FINAL T.O PERF DATA ................................ CROSSCHECK
					EFB/MCU GREEN DOT............................COMPARE
					SEATING POSITION ................................ADJUST
					HUD ........................................................ DEPLOY/ADJUST
					FMS F-PLN page.................SELECT
					AIR CONDITIONING UNITS ........ CHECK DISCONNECTED
					EXT PWR .................................CHECK AVAIL
					EXT PWR DISCONNECTION ..................REQUEST
					--]]

					if step == 4  and current_time >= proc_time + 10 and beforestartproc_trigger == 1 then -- ('or' is used to confer more liberty to the user instead of 'and')
						proc_time = math.floor(os.clock()) -- 2ND CHRONO INIT MANDATORY
						-- DOORS (2 is open while 0 is closed. 1 is AUTO)
						ServiceDoor1R = 0
						ServiceDoor2R = 0
						CargoDoor1 = 0
						CargoDoor2 = 0
						if JAR_Ground_Handling_wanted == 1 then
							GHDpowerCable = 1
							GHDChocks = 1
							GHDcateringFwd = 0
							GHDcateringAft = 0
							GHDfuelTank = 0
							GHDpassengersBus = 0
							GHDnoseConus[0] =0
							GHDloaderAft = 0
							GHDloaderFwd = 0
							GHDforwardStairs = 0
							GHDrearStairs = 0
						else
							l_newval = false			-- SGES equipment list up to date with SGES version 54 (2022-08)
							show_Bus = l_newval
							Bus_chg = true
							show_FireVehicle = l_newval
							FireVehicle_chg = true
							show_GPU = l_newval
							GPU_chg = true
							show_RearBeltLoader = l_newval
							RearBeltLoader_chg = true
							show_FUEL = l_newval
							FUEL_chg = true
							show_Cleaning = l_newval
							Cleaning_chg = true
							show_PRM = l_newval
							PRM_chg = true
							show_BeltLoader = l_newval
							BeltLoader_chg = true
							show_Cart = l_newval
							Cart_chg = true
							show_ULDLoader = l_newval
							ULDLoader_chg = true
							show_Stairs = l_newval
							Stairs_chg = true
							show_StairsH = l_newval
							StairsH_chg = true
							show_Catering = l_newval
							Catering_chg = true
							show_Cones = l_newval
							Cones_chg = true
							show_People1 = l_newval
							People1_chg = true
							show_People2 = l_newval
							People2_chg = true
							show_People3 = l_newval
							People3_chg = true
							show_People4 = l_newval
							People4_chg = true
							show_Pax = l_newval
							Pax_chg = true
							if show_Pax then 		initial_pax_start = true end
							show_Deice = l_newval
							Deice_chg = true
							show_Light = l_newval
							Light_chg = true
							show_StairsXPJ = l_newval
							StairsXPJ_chg = true
							show_StairsXPJ2 = l_newval
							StairsXPJ2_chg = true
							show_TargetMarker = l_newval
							TargetMarker_chg = true
							show_StopSign = l_newval
							StopSign_chg = true
							show_ArrestorSystem = l_newval
							ArrestorSystem_chg = true
							show_ASU = l_newval
							show_ACU = l_newval
							ASU_chg = true
						end
						--Toliss_chocks_set = 1
						GroundHPAir = 0
						-- TO DATA
						command_once("AirbusFBW/MCDU2Perf")
						step = 5
					end


					--[[
					FINAL LOADSHEET .................................CHECK
					CHECK FUEL ON BOARD .............................CHECK
					FINAL T.O PERF DATA ...........................RECOMPUTE
					FINAL T.O PERF DATA ................................ CROSSCHECK --]]
					if step == 5 and current_time >= proc_time + 14 and beforestartproc_trigger == 1 then
						Current_title = "Before start clearance procedure : final TO PERF data"
						command_once("AirbusFBW/MCDU2Init") --> go again to the page allowing the ZFW Insertion
						step = 6
					end
					if step == 6 and current_time >= proc_time + 16 and beforestartproc_trigger == 1 then
						command_once("AirbusFBW/MCDU2SlewRight") --> go again to the page allowing the ZFW Insertion
						--if TL_Keep_secondary_sounds == "activate" then play_sound(ZFW_sound) end --confusing
						vr_message_sent = false
						step = 7
					end
					if step == 7 and current_time >= proc_time + 18 and beforestartproc_trigger == 1 then
						if (InitZFW > (m_total - m_fuel_total) + maxdifference or InitZFW < (m_total - m_fuel_total) - maxdifference)
						or (InitBlockFuel > m_fuel_total + maxdifference or InitBlockFuel < m_fuel_total - maxdifference)
						then
							display_bubble("Please check FINAL T.O PERF DATA : ZFW and block fuel !")
							-- DISPLAY VR message
							if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
								show_window_bottom_bar = true
								end_show_time = math.floor(os.clock()) + 20
								Message_wnd_content = "Please recompute and crosscheck final TO PERF data with final loadsheet and FOB !"
								Message_wnd_action = "vr_message_sent = false "
								Message_wnd_duration = 5
							end
							-- End of VR Message
						end
						step = 8
						proc_time=math.floor(os.clock())  -- used by function AutoClear
					end


					-- FMGS accuracy checkpoint ---------------

					if step == 8 and current_time >= proc_time + 5 and beforestartproc_trigger == 1
					then
						if (InitZFW < (m_total - m_fuel_total) + maxdifference and InitZFW > (m_total - m_fuel_total) - maxdifference)
					or (InitBlockFuel < m_fuel_total + maxdifference and InitBlockFuel > m_fuel_total - maxdifference) then
							--proc_time=math.floor(os.clock())
							Current_title = "Before start clearance procedure (continued)"
							display_bubble("Passed FINAL T.O PERF DATA checkpoint.")
							--FMS F-PLN page.................SELECT
							GroundLPAir = 0
							--AIR CONDITIONING UNITS ........ CHECK DISCONNECTED (external low pressure air they mean !)
							test_possible_failure("AirbusFBW/GroundLPAir")
							ECAMpage = dataref_table("AirbusFBW/SDCOND","writable") -- the PM checks the COND on the ECAM SD
							ECAMpage[0] = 1
							ECAMpage = nil -- unload dataref
						end
						step = 8.5
					end

					if step == 8.5 and current_time >= proc_time + 10 		then
						ECAMpage = dataref_table("AirbusFBW/SDCOND","writable")
						ECAMpage[0] = 0
						ECAMpage = nil -- unload dataref
						step = 9
					end



					if step == 9 and current_time >= proc_time + 15 and beforestartproc_trigger == 1 then
						--EXT PWR ................................CHECK AVAIL
						--EXT PWR DISCONNECTION ..................REQUEST

						-- if the user did not disconnet the GPU and instead triggered the Pushback flow with the INTERPHONE MIC, the PM will disconnect
						-- REMOVED if ExtPowerButton == 0 then ExtPowerConnected = 0 end -- overhead button
						--ExtPowerConnected = 0 -- is trigger : cannot be used alone like that !
						command_once("AirbusFBW/MCDU2Fpln")
						if TL_Keep_secondary_sounds == "activate" then 	play_sound(Boarding_Ann_sound) end
						if JAR_Ground_Handling_wanted == 1 then
							GHDpowerCable = 1
							GHDChocks = 0
						end
						Toliss_chocks_set = 0 -- CHOCKS SUPPOSED TO BE REMOVED
						show_Chocks = false -- SGES
						Chocks_chg = true -- SGES
						step = 9.1
					end

					-- if we did a late APU start then we need to be sure that the APU is running and online
					-- before removing the GPU. We wait the APU speed has reached 99% (and 115 V)
					-- apu_time works both for regular and delayed APU start (if was well initializated)
					if step == 9.1 and APUAvail == 1 and current_time >= proc_time + 20 and beforestartproc_trigger == 1 then
						if ExtPowerConnected == 1 then ExtPowerConnected = 0 end
						if ExtPowerAConnected == 1 then ExtPowerAConnected = 0 end -- A340-600
						-- if GPU still present and the user did not disconnect the GPU from the airbus electrical wiring, the PM will disconnect it before the ground crew removes it.
						proc_time = math.floor(os.clock())
						step = 9.2
						message_time=math.floor(os.clock()) - 30 -- clear message
					end

					if step == 9.2 and current_time >= proc_time + 5  and beforestartproc_trigger == 1 then
						-- the ground crew removes the physical GPU.
						ExternalPowerEnabled = 0
						ExternalPowerAEnabled = 0 -- A340-600
						if JAR_Ground_Handling_wanted == 1 then
							GHDpowerCable = 0
							GHDChocks = 0
						end
						BSC_P = true
						step = 9.3
						vr_message_sent = false
						display_bubble("Before start clearance complete.")
						play_sound(Beforestart_sound) -- play sound "before start clearance procedure done"
						--play_sound(Typing_sound)
					end




						-- hold here -

					if step == 9.3  and SERVICEMIC == 0 and beforestartproc_trigger == 1 then
						function ClickForProcTrigger()

							--if GUI_messages_in_circle_and_all_messages == true then
									graphics.draw_circle( 400, 60, 46, 1)
								if Red_AltitudeBaro == Red_AltitudeBaro_fromMCDU and TL_Accel_AltitudeBaro == TL_Accel_AltitudeBaro_fromMCDU then
									graphics.draw_circle( 400, 60, 49, 2)
									draw_string(385, 80, "Start", "green") draw_string(371, 60, "clearance", "green") draw_string(376, 40, "received", "green")
								else
									draw_string(385, 80, "Start", "white") draw_string(371, 60, "clearance", "white") draw_string(376, 40, "received", "white")
								end
								if MOUSE_X <= 450 and MOUSE_X >=350 and MOUSE_Y <= 110  and MOUSE_Y >= 10 and MOUSE_STATUS == "down" then
									graphics.draw_filled_circle( 400, 60, 41, 2)
									reset_VR_message_popup()
									draw_string(385, 80, "Start", "black") draw_string(371, 60, "clearance", "black") draw_string(376, 40, "received", "black")
									SERVICEMIC = 1 -- we don't have the servic MIC in the ToLiss to we use that variable as a Flag here, as a workaround
									else MOUSE_STATUS = "up" end
							--end
						end

						-- DISPLAY VR message
						if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
							show_window_bottom_bar = true
							end_show_time = math.floor(os.clock()) + 20
							Message_wnd_content = ""    Message_wnd_content = "Start clearance has been received ?"
							Message_wnd_action = "vr_message_sent = false SERVICEMIC = 1"
							Message_wnd_duration = 30
						end
						-- End of VR Message
						if Vr_message_current_answer == "yes" then reset_VR_message_popup()
							SERVICEMIC = 1
							Vr_message_current_answer = "?"
						end
					end


					-- the flow previsously existing at this place was splitted in two flows with the Airbus 2021 procedures revision

					----------------------------------------------------------------------------------------------------------
					-- AT START CLEARANCE PROCEDURE --------------
					----------------------------------------------

					if step == 9.3 and SERVICEMIC == 1 and beforestartproc_trigger == 1 then
						Current_title = "At start clearance flow."
						function ClickForProcTrigger()
							draw_string(0, 0, "","grey")
						end
						reset_VR_message_popup()
						display_bubble("At start clearance flow.")
						SERVICEMIC = 0
						--ATC...............................SET FOR OPERATION (CM2)
						-- ATC is set in accordance with airport requirements.
						-- For online networks, airport requirements used to be XPDR OFF until runway !
						-- For other situations (not adapted to IVAO), XPDR on for "ground radar"
						if Online_transponder ~= 1 then
							XPonDr = 2 -- transponder only
						else
							XPonDr = 0 -- OFF is confirmed for IVAO
						end
						doorLock = 2
						play_sound(Cabin_interphone_ArmDoors_sound)
						proc_time=math.floor(os.clock())
						step = 10
					end

					if step == 10 and current_time >= proc_time + 2 and beforestartproc_trigger == 1  then
						ECAMpage = dataref_table("AirbusFBW/SDDOOR","writable") -- the PM checks the doors on the ECAM SD
						ECAMpage[0] = 1
						ECAMpage = nil -- unload dataref
						-- DOORS (2 is open while 0 is closed. 1 is AUTO)
						if (AIRCRAFT_FILENAME == "a321.acf" or AIRCRAFT_FILENAME == "a321_StdDef.acf" or AIRCRAFT_FILENAME == "a321_XP11.acf" or PLANE_ICAO == "A346") then
							BulkDoor = 0
						end
						PaxDoor1L = 0 -- a confirmation if late opening of the door by dispatch ;-)
						PaxDoorRearLeft = 0
						ServiceDoor1R = 0
						ServiceDoor2R = 0
						CargoDoor1 = 0
						CargoDoor2 = 0
						--WINDOWS CLOSED
						--
						--~ -- // -- LIGHTS -- //
						--~ if transfer_exterior_lights_to_the_PM_on_ground then
							--~ BeaconL			= 1 -- 0 is OFF, 1 is red ON
							--~ NavL 			= 1 -- 0 is OFF, 1 is set #1, 2 is set #2
						--~ end
						--~ -- // -- LIGHTS -- // end of section //
						doorLock = 1
						step = 11.5
					end

					if step == 11.5 and current_time >= proc_time + 10  and beforestartproc_trigger == 1 then
						PaxDoorRearLeft = 0 -- needs enforcement
						step = 12
					end


					if step == 11 and current_time >= proc_time + 20  and beforestartproc_trigger == 1 then
						if slides_addon_installed then EmerLight = 1 end
						PaxDoorRearLeft = 0 -- needs enforcement
						if OAT <= 20 then play_sound(DoorsClosed_sound)
						elseif TL_Keep_secondary_sounds == "activate" then play_sound(DoorsClosed2_sound)
						else play_sound(DoorsClosed_sound)
						end
						step = 12
					end

					if step == 12 and current_time >= proc_time + 25  and beforestartproc_trigger == 1 then
						ECAMpage = dataref_table("AirbusFBW/SDDOOR","writable")
						ECAMpage[0] = 0
						ECAMpage = nil -- unload dataref
						step = 13
					end

					-- the late APU Start sequence was removed from here follwoing to the Airbus 2021 changes and put before start clearance


					if step == 13 and current_time >= proc_time + 30  and beforestartproc_trigger == 1 then
						Toliss_chocks_set = 0
						show_Chocks = false -- SGES
						Chocks_chg = true -- SGES
						---  Ajout JZ ---------
						-- Start Elapsed Time when chocks are OFF
						-- #Elapsed time clock RUN
						ClockETSwitch = 0
						---- Fin ajout JZ

						ground_stuff = 0 -- reset this trigger to allow start over at gate
						step = 14
						OET_step = 0
						beforestart_time = math.floor(os.clock())
						delay_done = 0
						play_sound(ChocksGPU_removed_sound)
						display_bubble("At start clearance flow complete.")
						ASC_P = true
					end

					if step == 14 and current_time >= proc_time + 33  and beforestartproc_trigger == 1 then
						Current_title = "At start clearance flow complete"
						ACS_P = true
						SeatBeltSignsOn = 1 -- if seatbelts where forgotten by the PF, the PM will correct that now
						--NoSmokingSignsOn = 1 -- if Smoking was forgotten by the PF, the PM will correct that now -- commented out for freedom
						BrakeReleasedFlag = false
						play_sound(Beforestart_sound) -- "At start clearance flow complete"
						--play_sound(Typing_sound)
						beforestartproc_trigger = 2 -- enforce
						step = 11 -- yes eleven, in cunjonction with beforestartproc_trigger to 2
						function ClickForProcTrigger()
							draw_string(0, 0, "","grey")
						end
						reset_VR_message_popup()
					end
					-- and beforestartproc_trigger == 1  protection was required seeing mixed steps with previous procedure being triggered.
				end
		end
		end
		do_often("BEFORESTART()")


		--------------------------------------------------------------------------------
		-- Monitor Start

		function START()
			if not SpeedyCopilot_first_load then
				if ToLissPNFonDuty == 1 and beforestartproc_trigger == 2 and afterstartproc_trigger == 0 and step == 11 then
					if Eng1N1 > 0.8 and started1 == 0 then
						play_sound(Start1_sound) started1 = 2 play_sound(Safety_Ann_sound) stop_sound(Boarding_Music)
						if TL_Keep_secondary_sounds == "activate" then stop_sound(Boarding_Ann_sound) stop_sound(Boarding_Music_alternative) end
						Current_title = "Engine start"
					end
					if Eng2N1 > 0.8 and started2 == 0 then
						play_sound(Start2_sound) stop_sound(Boarding_Music)
						if TL_Keep_secondary_sounds == "activate" then stop_sound(Boarding_Music_alternative) end
						started2 = 2
						Current_title = "Engine start"
						-- // -- LIGHTS -- // -- the copilot wakes up and sees the pilot has forgotten the beacon :
						if BeaconL == 0 then
							BeaconL	= 1 -- 0 is OFF, 1 is red ON
							display_bubble("You forgot the red beacon, turned that ON for you.")
						end
						-- // -- LIGHTS -- // end of section //
					end



					if PLANE_ICAO == "A346" then
						if Eng3N1 > 0.8 and started3 == 0 then
							play_sound(Start3_sound)
							started3 = 2
							Current_title = "Engine 3 start"
						end
						if Eng4N1 > 0.8 and started4 == 0 then
							play_sound(Start4_sound)
							started4 = 2
							Current_title = "Engine 4 start"
						end
					else
						started3 = 2
						started4 = 2
					end
				end
			end
		end
		do_often("START()")

		local QDAnswered = 0
		local OET_step = 0


		--------------------------------------------------------------------------------
		-- single_engine_taxi
		--[[
		PRO – PROCEDURES
		A319
		FLIGHT CREW OPERATING MANUAL
		PRO-SUP – SUPPLEMENTARY PROCEDURES
		PRO-SUP-93 – Green Operating Procedures
		PRO-SUP-93-20 – One Engine Taxi
		]]



		function OneEngineTaxiDeparture()

			if ToLissPNFonDuty == 1 and beforestartproc_trigger == 2 and afterstartproc_trigger == 0 and ((genactive1_trigger == 1 or genactive2_trigger == 1) and single_engine_taxi == 1) then
				--[[
				BRAKE ACCU PRESS...CHECK
				]]
				if OET_step == 0  then
					Current_title = "One Engine Taxi"
					message_time=math.floor(os.clock())   -- used by function AutoClear
					function Message()
						 message_done = 0 -- used by function AutoClear
						 if normal_messages == 1 then big_bubble( 50, 20, "BRAKE ACCU PRESS..................CHECK") end
					end
					proc_time=math.floor(os.clock())
					OET_step = OET_step + 1
				end
				--[[
				ENGINE 1...........START
				Use Engine 1 for taxiing because it pressurizes the green hydraulic system (normal braking).
				X BLEED	........OPEN
				]]
				if OET_step == 1 and current_time >= proc_time + 3  then
					message_time=math.floor(os.clock())   -- used by function AutoClear
					function Message()
						 message_done = 0 -- used by function AutoClear
						 if normal_messages == 1 then big_bubble( 50, 20, "X BLEED..................OPEN") end
					end
					set("ckpt/startMode",1) -- reput the packs on to allow cabin cooling during the single engine taxi out.
					XBleed = 2
					OET_step = OET_step + 1
				end
				--[[
				This supplies both packs from Engine 1.
				Apply the normal “AFTER START” procedures, but:
				- Keep the APU running
				Switch off the APU BLEED, to prevent the ingestion of engine exhaust gases]]
				if OET_step == 2 and current_time >= proc_time + 5  then
					message_time=math.floor(os.clock())   -- used by function AutoClear
					function Message()
						 message_done = 0 -- used by function AutoClear
						 if normal_messages == 1 then big_bubble( 50, 20, "APU BLEED OFF to prevent the ingestion of engine exhaust gases") end
					end
					APU_Bleed_ON = 0
					OET_step = OET_step + 1
				end
				--[[
				BEFORE RELEASING THE PARKING BRAKE
				Y ELEC PUMP.............ON
				This pressurizes the yellow hydraulic system (nosewheel steering) without using the PTU.]]
				if OET_step == 3 and current_time >= proc_time + 8  then
					message_time=math.floor(os.clock())   -- used by function AutoClear
					function Message()
						 message_done = 0 -- used by function AutoClear
						 if normal_messages == 1 then big_bubble( 50, 20, "Y ELEC PUMP.... ON","Now you can release the parking brake.") end
					end
					YElecPump = 1
					single_engine_cabin_prep_start = 2
					OET_step = OET_step + 1
				end
				--[[
				Apply the normal “TAXI” procedures, but:
				- Perform the Flight Controls checks after both engines have been started.
				- Do not arm the Auto Brake system before the Flight Controls checks have been completed.
				]]

				if OET_step == 4 and current_time >= proc_time + 11  then
					print("OET_step " .. OET_step)
					if FLAPS_wanted == 1 then
						if TOFlapsWanted == 1 then flaprqst = 0.25  end -- TO FLAPS 1
						if TOFlapsWanted == 2 then flaprqst = 0.50  end -- TO FLAPS 2
						if TOFlapsWanted == 3 then flaprqst = 0.75  end -- TO FLAPS 3
					end
					OET_step = OET_step + 1
				end

				if OET_step == 5 and current_time >= proc_time + 15  then
					print("OET_step " .. OET_step)
					set("AirbusFBW/FD1Engage",1)
					set("AirbusFBW/FD2Engage",1)
					radar = 2 -- 1 is OFF
					OET_step = OET_step + 1
				end

				if OET_step == 6 and current_time >= proc_time + 17  then
					print("OET_step " .. OET_step)
					radarPWS = 2
					--ND Terrain on FO side if no Terrain was drawn at that time
					if TerrainLeft == 0 and TerrainRight == 0 then TerrainRight = 1 end
					OET_step = OET_step + 1
					vr_message_sent = false
				end

				--[[

				BEFORE ENG 2 START
				● No less than 3 min before takeoff and during taxi in a straight line:
				-- Our PM will do that
				]]
				if OET_step == 7 and current_time >= proc_time + 60 then
					function ClickForProcTrigger()
						--if GUI_messages_in_circle_and_all_messages == true then
							draw_string(385, 80, "Start", "green") draw_string(370, 60, "the second", "green") draw_string(385, 40, "engine", "green")
							graphics.draw_circle( 400, 60, 45, 2)
							if MOUSE_X <= 450 and MOUSE_X >=350 and MOUSE_Y <= 110  and MOUSE_Y >= 10 and MOUSE_STATUS == "down" then
								graphics.draw_filled_circle( 400, 60, 40, 2)
								OET_step = 8
								reset_VR_message_popup()
							else MOUSE_STATUS = "up" end
						--end
					end
					-- DISPLAY VR message
					if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
						show_window_bottom_bar = true
						end_show_time = math.floor(os.clock()) + 20
						Message_wnd_content = "Start the second engine ?"
						Message_wnd_action = "vr_message_sent = false OET_step = 8"
						Message_wnd_duration = 30
					end
					-- End of VR Message
					if Vr_message_current_answer == "yes" then reset_VR_message_popup()
						OET_step = 8
						Vr_message_current_answer = "?"
					end
				end
				--[[
				Y ELEC PUMP...OFF
				The Y ELEC PUMP must be set to OFF to enable the automatic test of the PTU during engine 2 start.
				APU BLEED....ON
				ENGINE 2...START
				]]


				if OET_step == 8 then
					function ClickForProcTrigger()
							draw_string(385, 80, "")
					end
					reset_VR_message_popup()
					YElecPump = 0
					OET_step = OET_step + 1
				end

				if OET_step == 9 and current_time >= proc_time + 3  then
					APU_Bleed_ON = 0 -- we start from the APU, but the airbus will shut down the packs.
					set("ckpt/startMode",2)
					OET_step = OET_step + 1
				end

				-- start the other engine
				if OET_step == 10 and current_time >= proc_time + 5 and genactive1_trigger == 1  then
					--start engine 2
					set("AirbusFBW/ENG2MasterSwitch",1)
					OET_step = OET_step + 1
				end

				-- start the other engine
				if OET_step == 10 and current_time >= proc_time + 5 and genactive2_trigger == 1  then
					--start engine 1
					set("AirbusFBW/ENG1MasterSwitch",1)
					OET_step = OET_step + 1
					OET_P = true
				end

				--[[
				APU....AS RQRD
				X BLEED...AUTO
				Continue with the “AFTER START” procedures
				]]
			end

		end

		do_often("OneEngineTaxiDeparture()") -- otherwise click to trigger doesn't work

		--------------------------------------------------------------------------------
		-- Execute After Start and Taxi Procedure
		function AFTERSTART_AND_TAXI()
		if not SpeedyCopilot_first_load then
			-- set the trigger
			-- whatever the ENG 1 or the ENG 2 is booted first, and the other the second, it will trigger after start
			-- but, both ENGINES must be on !
			if beforestartproc_trigger ==2 and afterstartproc_trigger == 0 and Eng1N1 >= 17 then
				genactive1_trigger =1
			end
			if beforestartproc_trigger ==2 and afterstartproc_trigger == 0 and Eng2N1 >= 17 then
				genactive2_trigger =1
			end
			if PLANE_ICAO == "A346" then
				if beforestartproc_trigger ==2 and afterstartproc_trigger == 0 and Eng3N1 >= 17 then
					genactive3_trigger =1
				end
				if beforestartproc_trigger ==2 and afterstartproc_trigger == 0 and Eng4N1 >= 17 then
					genactive4_trigger =1
				end
			elseif genactive2_trigger == 1 and genactive2_trigger == 1 then genactive3_trigger = 1 genactive4_trigger = 1  -- when it's a dual engine aircraft, we can safely flag engine 3 and 4 (non existent) as "ok to go"
			end



			if ToLissPNFonDuty == 1 and preliminaryprocedure_trigger == 2 and beforestartproc_trigger == 2 and afterstartproc_trigger == 0 and genactive1_trigger ==1 and genactive2_trigger ==1 and genactive3_trigger ==1 and genactive4_trigger ==1 then
			--afterstartproc_trigger = 1
			-- actions
			----------- After start procedure -----------
				if step == 11 and ENGModeSwitch == 1 then
					function ClickForProcTrigger()
							draw_string(385, 80, "")
					end
					reset_VR_message_popup()
					--
					ES_P = true
					cabinready = 0
					Current_title = "After start"
					display_bubble(Current_title)
					GroundLPAir = 0
					GroundHPAir = 0
					--
					proc_time = math.floor(os.clock())
					QDAnswered = 0
					step = 11.5
				end
				if step == 11.5 and current_time >= proc_time + 3  then
					speedbrake_ratio = -0.5
					TOFlapsDelayed = 0
					XBleed = 1 -- benefit to all conditions
					if single_engine_taxi == 1 then
						display_bubble("X BLEED..................AUTO")
						--XBleed = 1 -- placed one level higher
					end
					step = 11.75
					Vr_message_current_answer = "?" vr_message_sent = false
				end

				------FLAPS DELAY ? FOR TAKE OFF---------------------------------------------------
				-------------------------------------------------------------------------------------

			-- Hi XPJavelin
			--
			-- The plugin Speedy Copilot A319 Toliss is just awesome. Thanks for sharing it.
			--
			-- How can I prevent the Speedy Copilot from automatically triggering the TO flaps position? Can I change something in the lua file and if so what?
			-- Why do I want this?
			-- I have a problem with Speedy Copilot in connection with the plugin PassengersFX
			-- (PFX2020). Speedy Copilot provides the TO flaps before taxiing and unfortunately not
			-- before the LineUp. As soon as the flaps are activated, PFX2020 makes the
			-- announcements for just before the takeoff. So we're still on the Tarmac and
			-- PFX2020 reports "enjoy the takeoff", "cabincrew reaydy for takeoff" etc.
				-------------------------------------------------------------------------------------

				if step == 11.75 and current_time >= proc_time + 3  then
					-- print an on-screen button for user choice for TO flaps
					-- do we skip flaps extension ?
					function ClickForProcTrigger()
						if single_engine_taxi == 0 then
								draw_string(334, 65, "Delay", "white")
								draw_string(338, 48, "flaps", "white")
								graphics.draw_circle( 350, 60, 28, 2)
								if MOUSE_X <= 370 and MOUSE_X >=330 and MOUSE_Y <= 80  and MOUSE_Y >= 40 and MOUSE_STATUS == "down" then
									graphics.draw_filled_circle( 350, 60, 20, 2)
									TOFlapsDelayed = 1
									step = 12
									reset_VR_message_popup()
								else MOUSE_STATUS = "up" end
						end
					end
				end


				if step == 11.75 and current_time >= proc_time + 14  then
					step = 12
				end
				-------------------------------------------------------------------------------------


				if step == 12 and current_time >= proc_time + 15  then
					function ClickForProcTrigger()
						draw_string( 0, 0, "")

					end
					reset_VR_message_popup()
					-- modified in revision 3.4
					if FLAPS_wanted == 1 and TOFlapsDelayed == 0 then
						if TOFlapsWanted == 1 then flaprqst = 0.25  end -- TO FLAPS 1
						if TOFlapsWanted == 2 then flaprqst = 0.50  end -- TO FLAPS 2
						if TOFlapsWanted == 3 then flaprqst = 0.75  end -- TO FLAPS 3
					end
					step = 13
				end
				if step == 13 and current_time >= proc_time + 20  then
					-- ECAM DOOR PAGE
					-- specific link to dataref, (magic table) to be able to undefine the dataref
					-- those specific ECAM button cause problems when not unlinked.
					ECAMdoor = dataref_table("AirbusFBW/SDDOOR","writable")
					ECAMdoor[0] = 1
					ECAMdoor = nil -- unload dataref
					-- close doors if users tried to open them to test this code ;-)
					-- DOORS (2 is open while 0 is closed. 1 is AUTO)
					PaxDoor1L = 0
					PaxDoorRearLeft = 0
					ServiceDoor1R = 0
					ServiceDoor2R = 0
					CargoDoor1 = 0
					CargoDoor2 = 0
					if (AIRCRAFT_FILENAME == "a321.acf" or AIRCRAFT_FILENAME == "a321_StdDef.acf" or AIRCRAFT_FILENAME == "a321_XP11.acf") then
						BulkDoor = 0
					end
					step = 14
				end
				if step == 14 and current_time >= proc_time + 25  then
					AS_P = true
					-- ECAM DOOR PAGE CLOSE
					-- specific link to dataref, (magic table) to be able to unlink the dataref
					-- those specific ECAM button cause problems when not unlinked.
					ECAMdoor = dataref_table("AirbusFBW/SDDOOR","writable")
					ECAMdoor[0] = 0
					ECAMdoor = nil -- unload dataref
					play_sound(Afterstart_sound)
					message_time=math.floor(os.clock()) - 5  -- used by function AutoClear
					function Message()
						message_done = 0 -- used by function AutoClear
						big_bubble( 50, 20, "After start procedure complete","Ready for the TAXI procedure.","Waiting for you to execute your PF actions.")
					end
					-- FLIGHT CONTROLS CHECK preparation
					flightcontrols_checked = 0

					if DomeLight > 1 then DomeLight = 1 end
					rollsup_checked = 0
					pitchsup_checked = 0
					rollinf_checked = 0
					pitchinf_checked = 0
					-- Mod JZ BEGIN----- https://forums.x-plane.org/index.php?/forums/topic/155486-speedy-copilot-319/&page=8&tab=comments#comment-1537579
					yawsup_checked = 0
					yawinf_checked = 0
					pitch_checked = 0
					roll_checked = 0
					yaw_checked = 0
					-- Mod JZ END -----
					step = 14.9
					proc_time=math.floor(os.clock())
				end

			------------------------------------
			----------- Taxi procedure --------- -- trigger : taxi light -----------------------------
			------------------------------------
			--[[

			TAXI FLOW PM :

			TAXI CLEARANCE...........................................OBTAIN
			F/CTL ...................................................CHECK
			ATC CLEARANCE ...........................................CONFIRM
			FMS F-PLN/SPD ...........................................CHECK
			FCU ALT/HDG .............................................SET
			BOTH FD .................................................CHECK ON
			PFD/ND ..................................................CHECK
			DEPARTURE BRIEFING (WITH PF) ............................CONFIRM
			A/BRK pb ................................................Max
			TERR ON ND...............................................AS RQRD
			SQUAWK ..................................................CONFIRM/SET
			RADAR ...................................................ON
			PREDICTIVE WINDSHEAR SYSTEM..............................AUTO
			T.O CONFIG pb............................................TEST
			T.O MEMO ................................................CHECK NO BLUE
			CABIN REPORT.............................................RECEIVE
			TAXI C/L ................................................COMPLETE
			--]]

					----------- FLIGHTCONTROLS CHECK TRANSITION -----------
				if step == 14.9 and TaxiL > 0 and current_time >= proc_time + 4 then
					Current_title = "Taxi procedure"
					--  EXECUTE FLIGHT CONTROL CHECK
					if yoke_roll > 0.05 or yoke_pitch > 0.05 or yoke_roll < -0.05 or yoke_pitch < -0.05 then
						if flightcontrols_checked == 0 then play_sound(FlightControlsCheck_sound) step = 15 end
						flightcontrols_checked = 1 -- current
						flightcontrols_time=math.floor(os.clock())
					end

				end

				if step == 15 and TaxiL > 0 and current_time >= flightcontrols_time + 0.5  then
					--  EXECUTE FLIGHT CONTROL CHECK
					-- let's do it simple. Roll and Pitch
					-- cycling it must be
					local butee_sup_de_controle = 0.80
					local butee_inf_de_controle = -0.80
					if yoke_roll > butee_sup_de_controle and rollsup_checked == 0 then rollsup_checked = 2 play_sound(Fullright_s) end -- 1
					if yoke_pitch > butee_sup_de_controle and pitchsup_checked == 0 then pitchsup_checked = 2  play_sound(Fullup_s) end -- 2
					if yoke_roll < butee_inf_de_controle and rollinf_checked == 0 then rollinf_checked = 2  play_sound(Fullleft_s) end -- 3
					if yoke_pitch < butee_inf_de_controle and pitchinf_checked == 0 then pitchinf_checked = 2  play_sound(Fulldown_s) end -- 4
					-- Mod JZ BEGIN----- https://forums.x-plane.org/index.php?/forums/topic/155486-speedy-copilot-319/&page=8&tab=comments#comment-1537579
					if pitchsup_checked == 2 and pitchinf_checked == 2 and yoke_pitch <= 0.05 and yoke_pitch >= -0.05 and pitch_checked ~= 2 then pitch_checked = 2 play_sound(Neutral_s) end -- 5
					if rollsup_checked == 2 and rollinf_checked == 2 and yoke_roll <= 0.05 and yoke_roll >= -0.05 and roll_checked ~= 2 then roll_checked = 2 play_sound(Neutral_s) end -- 5

					-- Yaw.

					if Check_yaw == 1 then
						if yoke_yaw > butee_sup_de_controle - 0.15 and yawsup_checked == 0 then yawsup_checked = 2 play_sound(Fullright_s) end -- 6
						if yoke_yaw < butee_inf_de_controle + 0.15 and yawinf_checked == 0 then yawinf_checked = 2 play_sound(Fullleft_s) end -- 7
						if yawsup_checked == 2 and yawinf_checked == 2 and yoke_yaw <= 0.05 and yoke_yaw >= -0.05 and yaw_checked~=2 then yaw_checked = 2 play_sound(Neutral_s) end -- 5
						-- cycling it must be
					end
				end
				if step == 15 and roll_checked == 2 and pitch_checked == 2 and ((yaw_checked == 2 and Check_yaw == 1) or (yaw_checked == 0 and Check_yaw == 0)) then
					-- Mod JZ END -----
					flightcontrols_time    = math.floor(os.clock())
					flightcontrols_checked = 2 -- for cabin simulation
					step = 16
				end

					----------- FLIGHTCONTROLS CHECK TRANSITION -----------

				if step == 16 and current_time >= flightcontrols_time + 2  then
					play_sound(FlightControlsCheck_complete_sound)
					set("AirbusFBW/FD1Engage",1)
					set("AirbusFBW/FD2Engage",1)
					radar = 2 -- 1 is OFF
					radarPWS = 2
					step = 16.5
					vr_message_sent = false
				end



				-- 2021
				if step == 16.5 and current_time >= flightcontrols_time + 4  then -- added 2022 08 21
					display_bubble("Confirm departure briefing.")
					-- DISPLAY VR message
					if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
						show_window_bottom_bar = true
						end_show_time = math.floor(os.clock()) + 20
						Message_wnd_content = "Please confirm departure briefing."
						Message_wnd_action = "vr_message_sent = false "
						Message_wnd_duration = 20
						show_the_option_window()
					end
					-- End of VR Message
					if Vr_message_current_answer == "yes" then reset_VR_message_popup() end_show_time = 0 end
					step = 16.6
				end

				if step == 16.6 and current_time >= flightcontrols_time + 6  then
					--AUTOBRAKE
					command_once("AirbusFBW/AbrkMax")
					step = 17
				end

				if step == 17 and current_time >= flightcontrols_time + 8  then
					--ND Terrain on FO side if no Terrain was drawn at that time
					if TerrainLeft == 0 and TerrainRight == 0 then TerrainRight = 1 end
					step = 18
				end

				if step == 18 and current_time >= flightcontrols_time + 11  then
					-- SQUAWK .......................... CONFIRM/SET
					-- room for improvement
					display_bubble("PM : SQUAWK .......... CONFIRM/SET ?")
					step = 18.5
				end

				if step == 18.5 and current_time >= flightcontrols_time + 15  then
					-- RADAR ..........................................ON
					radar = 2 -- 1 is OFF
					-- PREDICTIVE WINDSHEAR SYSTEM.....................AUTO
					radarPWS = 2 -- <---- room for improvement
					step = 19
					Vr_message_current_answer = "?" vr_message_sent = false
					play_sound(Cabin_interphone_TO_sound)
				end

				-- CABIN REPORT....................................................... RECEIVE

				if step == 19 and current_time >= flightcontrols_time + 19  then
					--command_end("AirbusFBW/TOConfigPress") -- TO CONFIG !
					if boardingMusic == 1 and TL_Keep_secondary_sounds == "activate" then play_sound(Boarding_Music_alternative) else 	play_sound(Boarding_Music) end
					--actions finished
					message_time=math.floor(os.clock())  -- used by function AutoClear
					function Message()
					 message_done = 0 -- used by function AutoClear
					 if normal_messages == 1 and cabinready ~= 2 and AircraftIsP2F == 0 then big_bubble( 50, 20, "AFTER START procedure done. Cabin not ready.","You cannot takeoff while the cabin is not secured.") end
					 if normal_messages == 1 and cabinready == 2 and AircraftIsP2F == 0 then big_bubble( 50, 20, "AFTER START procedure done.","Cabin is already secured.") end
					 if normal_messages == 1 and cabinready == 2 and AircraftIsP2F == 1 then big_bubble( 50, 20, "AFTER START procedure done.") end
					end
					play_sound(Beforetaxi_sound) -- "TO CONFIG pb pressed and cabin report received"
					step = 20
				end


				if step == 20 and current_time >= flightcontrols_time + 22  then
					DomeLight = 0
					PilotCheckedRight = false
					PilotCheckedLeft = false
					RunwayEntryFlag = false
					step = 20.1 -- used later
				end

				-- Delayed flaps extension backup
				if step == 20.1 and current_time >= flightcontrols_time + DelayReadiness + 1  then
					if FLAPS_wanted == 1 and TOFlapsDelayed == 1 then
						if TOFlapsWanted == 1 then flaprqst = 0.25  end -- TO FLAPS 1
						if TOFlapsWanted == 2 then flaprqst = 0.50  end -- TO FLAPS 2
						if TOFlapsWanted == 3 then flaprqst = 0.75  end -- TO FLAPS 3
						play_sound(TOflapsQ_sound)
					end
					step = 20.15
					set_array("AirbusFBW/ACP2KnobPush",5,0) -- INT

				end

				-- new in TOLISS : we redo the TO config once cabin is ready !

				if step == 20.15 and current_time >= flightcontrols_time + DelayReadiness + 7  then
					--TO CONFIG

					command_begin("AirbusFBW/TOConfigPress") -- TO CONFIG !
					random = math.random()
					if random >= 0.75 then -- sort of "random"
						play_sound(TOmemo_sound)
					else
						play_sound(TOmemo_variant_sound)
					end
					step = 20.2
				end

				if step == 20.2 and current_time >= flightcontrols_time + DelayReadiness + 9  then
					command_end("AirbusFBW/TOConfigPress") -- TO CONFIG !
					--actions finished
					Tx_P = true
					message_time=math.floor(os.clock())  -- used by function AutoClear
					function Message()
					 message_done = 0 -- used by function AutoClear
					 if normal_messages == 1 and cabinready ~= 2 and AircraftIsP2F == 0 then big_bubble( 50, 20, "Cabin still not ready !") end
					 if normal_messages == 1 and cabinready == 2 and AircraftIsP2F == 0 then big_bubble( 50, 20, "TAXI procedure done.","Cabin is secured.") end
					 if normal_messages == 1 and cabinready == 2 and AircraftIsP2F == 1 then big_bubble( 50, 20, "TAXI procedure done.") end
					end
					-- // -- LIGHTS -- // Non FCOM, just a hand from the FO
					if localHour >= 18 or localHour <= 8 then TurnOffL = 1 end
					-- // -- LIGHTS -- // end of section //
					afterstartproc_trigger = 2
					step = 105 -- used later
				end

			end

		end
		end

		--do_every_frame("AFTERSTART_AND_TAXI()") -- <- there is the flight controls check, so high monitoring was done
		do_often("AFTERSTART_AND_TAXI()") -- <-- I try to reduce the impact on FPS and see if doesn't prevent the F.C. check
		-- 22 08 22

		--------------------------------------------------------------------------------

		-- The Cabin should be ready before take off
		-- It is not going to be ready if you don't do the flight controls check
		cabinready = 0
		disembark_time = 90
		DelayReadiness = 240 -- increased from 180 to 240 sec on 2022 08 21 for the New Speedy Copilot
		single_engine_cabin_prep_start = 0
		function CABINREADY()
		if not SpeedyCopilot_first_load then
			if ToLissPNFonDuty == 1 and flightcontrols_checked == 2 and cabinready == 0 and altitudeAGL <= 2 then
				if AircraftIsP2F == 1 then -- when it's a freighter aircraft, there are no human passengers
					DelayReadiness = 5
					if current_time >= flightcontrols_time + DelayReadiness then
						-- be silent also
						disembark_time = DelayReadiness
						cabinready = 2
					end
				elseif payloadKG < 3500 or single_engine_cabin_prep_start == 2 then -- a few passengers or we already had time du to EOT out
					DelayReadiness = 60
					if current_time >= flightcontrols_time + DelayReadiness then
						-- be silent also
						disembark_time = DelayReadiness
						command_once("AirbusFBW/CheckCabin")
						play_sound(CabinReady_sound)
						LandscapeCamera = 1
						cabinready = 2
					end
				-- Outside Air Temperature in Celsius
				elseif localHour >= 23 or localHour <= 6 then -- during the night, passengers will quickly relax and sleep, allowing the F/A to increase cabin preparation efficiency.
					DelayReadiness = 180
					if current_time >= flightcontrols_time + DelayReadiness then
						if TL_Keep_secondary_sounds == "activate" then play_sound(CabinReady3_sound) else play_sound(CabinReady_sound) end
						disembark_time = 160
						command_once("AirbusFBW/CheckCabin")
						LandscapeCamera = 1
						cabinready = 2
					end
				elseif OAT <= 10 and OAT > 2 then -- Winter season : when in winter, passengers are packed in a lot of big (texan) clothes and wear their big (texan) boots.
					DelayReadiness = 300
					if current_time >= flightcontrols_time + DelayReadiness then
						if TL_Keep_secondary_sounds == "activate" then play_sound(CabinReady3_sound) else play_sound(CabinReady_sound) end
						disembark_time = 160
						command_once("AirbusFBW/CheckCabin")
						LandscapeCamera = 1
						cabinready = 2
					end
				elseif OAT <= 2 or payloadKG > 19000 then -- The Siberian overload : Everybody is freezed. Or + than 2/3 pax with each a 25 KG bag of Vodka in the cargo hold.
					DelayReadiness = 420
					if current_time >= flightcontrols_time + DelayReadiness then
						if TL_Keep_secondary_sounds == "activate" then play_sound(CabinReady4_sound) else play_sound(CabinReady_sound) end
						disembark_time = 220
						command_once("AirbusFBW/CheckCabin")
						LandscapeCamera = 1
						cabinready = 2
					end
				elseif OAT > 26 or payloadKG > 22000 then -- Summer time : F/A have to deal with the average tourist child who has lost his sandals while boarding. Or 2/3 Pax.
					DelayReadiness = 240
					if current_time >= flightcontrols_time + DelayReadiness then
						if TL_Keep_secondary_sounds == "activate" then play_sound(CabinReady4_sound) else play_sound(CabinReady_sound) end
						play_sound(CabinReady_sound)
						disembark_time = 140
						command_once("AirbusFBW/CheckCabin")
						LandscapeCamera = 1
						cabinready = 2
					end
				elseif OAT > 10 and OAT <= 26 then -- Regular smart : That's the daily efficient boarding with smart passengers and Arnold Schwarzenegger as chief flight attendant.
					DelayReadiness = 160
					if current_time >= flightcontrols_time + DelayReadiness then
						if TL_Keep_secondary_sounds == "activate" then play_sound(CabinReady2_sound) else play_sound(CabinReady_sound) end
						disembark_time = 110
						command_once("AirbusFBW/CheckCabin")
						LandscapeCamera = 1
						cabinready = 2
					end
				end
				-- :D
			end
		end
		end
		do_sometimes("CABINREADY()")
		--------------------------------------------------------------------------------

		CheckRight_time = math.floor(os.clock())
		CheckLeft_time = math.floor(os.clock())
		-- Execute LINE-UP Procedure
		function LINEUP()
		if not SpeedyCopilot_first_load then

			--[[
			Once the PM has obtained line-up clearance, the PF (the human user) will confirm the takeoff runway and intersection, collaboratively check the approach path clear of traffic, set the exterior lights for takeoff*, stow all unmounted equipment and sliding table, set the thurst bump as required

			The PM (Speedy Copilot) checks brake temperature (and turn off the fans). He obtains the line-up clearance, and set accordingly the Packs (« ON », « ON supplied by APU » or « OFF »), the TCAS, the ENG MODE selector. After stowing the table and everything not mounted, he advises the cabin crew in the back.

			*Note : in the new (2021) Airbus operating procedures, setting the exterior lights for takeoff has been moved to a PF item.
			--]]

			if afterstartproc_trigger == 2 and takeoffproc_trigger == 0 and view_is_external == 0 and cabinready == 2 and BrakeFan319 == 1 and current_time >= flightcontrols_time + 2 * DelayReadiness and gs_gnd_spd < 5 then
				-- 2021 changes : brake fans item was moved upward in the documented procedure
				Current_title = "Before TO (Line-up) proc (only brk temp/fans for now)"
				BrakeFan319 = 0 play_sound(BrakeFans_sound) -- BRAKE FAN OFF
				-- gs_gnd_spd < 5 is expected to run the flow when approaching the hold short, but in case of rolling takeoff I acknowledge it could be not triggered. I have a safety later in the code.
			end

			if afterstartproc_trigger == 2 and takeoffproc_trigger == 0 and view_is_external == 0 and cabinready == 2 and GUI_DeckLights and (FrontPanelFlood > 0.2 or PedestalPanelFlood > 0.2) and current_time >= flightcontrols_time + 2.1 * DelayReadiness then
				FrontPanelFlood = 0.05 PedestalPanelFlood = 0.1 -- I'll dim the ligths too :-)
			end

				-- Before takeoff 2021 flow (PM part) :

				-- BRAKE TEMP (if brake fan running).....................CHECK
				-- BRAKE FAN pb (if brake fan running) .............................. OFF
				-- LINE-UP CLEARANCE.............................................. OBTAIN
				-- TAKEOFF RUNWAY .............................................. CONFIRM
				-- APPROACH PATH .......................... CLEAR OF TRAFFIC
				-- PACK 1 and 2 ......................................................... AS RQRD
				-- TCAS mode selector ................................TA ONLY or TA/RA
				-- ENG MODE selector.....................................AS RQRD
				-- SLIDING TABLE ........................................................... STOW
				-- ALL EFB TRANSMITTING MODE ......................... AS RQRD
				-- ALL EFB (with no mounted equipment) ....................... STOW
				-- CABIN CREW ............................................................. ADVISE
				-- LINE UP C/L..............................................COMPLETE


			-- so your triggers since v2.3b are approach clear of traffic (the pilot head heading is tracked to see if the pilot checks the approach clear of traffic
			-- and a regular backward compatible landing light trigger.
			-- Airbus 2021 changes : I needed to add brake fans items before hand, since it was moved upward in the documented procedure


			-- APPROACH CLEAR OF TRAFFIC trigger
			if QuickGlance == 1 and PilotHead > 240 and PilotHead < 280 and afterstartproc_trigger == 2 and takeoffproc_trigger == 0 and view_is_external == 0 and cabinready == 2 then
				-- we don't want the chek to be triggered during taxi, while we are not a threshold so we scan for a runway and approach behaviour
				-- this behavior is a brief glance at right, then a glance at left.
				if  (current_time < CheckRight_time + 5 and PilotCheckedRight == true) or PilotCheckedLeft == false then
					PilotCheckedLeft = true
					play_sound(Checked_sound)
					CheckLeft_time = math.floor(os.clock())
				end
			end
			if QuickGlance == 1 and PilotHead < 100 and PilotHead > 60 and afterstartproc_trigger == 2 and takeoffproc_trigger == 0 and view_is_external == 0 then
				if  (current_time < CheckLeft_time + 5 and PilotCheckedLeft == true) or PilotCheckedRight == false then
					PilotCheckedRight = true
					play_sound(Checked_sound)
					CheckRight_time = math.floor(os.clock())
				end
			end

			-- we don't want the chek to be triggered during taxi, while we are not a threshold so we scan for a runway and approach behaviour
			-- this behavior is a brief glance at right, then a glance at left.
			if PilotCheckedLeft == true and PilotCheckedRight == false and current_time > CheckLeft_time + 5 then
				PilotCheckedRight = false
				PilotCheckedLeft = false
				RunwayEntryFlag = false
			end
			if PilotCheckedLeft == false and PilotCheckedRight == true and current_time > CheckRight_time + 5 then
				PilotCheckedRight = false
				PilotCheckedLeft = false
				RunwayEntryFlag = false
			end

			if PilotCheckedLeft and PilotCheckedRight then RunwayEntryFlag = true end

			-- LANDING LIGHT legacy trigger
			if (LandingLeftL == 2 or LandingRightL == 2) and afterstartproc_trigger == 2 and takeoffproc_trigger == 0 then
				RunwayEntryFlag = true
				cabinready = 2
			end
			if (LandingLeftL == 1 and PLANE_ICAO == "A346") and afterstartproc_trigger == 2 and takeoffproc_trigger == 0 then -- added 2023
				RunwayEntryFlag = true
				cabinready = 2
			end
			-- anyway, a safety trigger is made below :
			-- considering the aircraft is rolling for take off, if the runway flow has not been done, do it now :
			if TakeoffDecision > 100 and speed >= TakeoffDecision - 30 and afterstartproc_trigger == 2 and takeoffproc_trigger == 0 then RunwayEntryFlag = true end


			if ToLissPNFonDuty == 1 and afterstartproc_trigger == 2 and takeoffproc_trigger == 0 and RunwayEntryFlag and step == 105 then

				if BrakeFan319 == 1 then	BrakeFan319 = 0 end -- BRAKE FAN OFF
				-- safety (without sound, supposed to be already done)

				Current_title = "Before TO (Line-up) proc"
				proc_time = math.floor(os.clock())
				-- actions
				-- TCAS ----------------------------- START
				-- (TCAS TA, XPDR ON) before TO
				-- TRANSPONDER
				if PLANE_ICAO == "A346" then XPDRTCASMode = 2 else XPDRTCASMode = 1 end
				-- TCAS MODE
				if PLANE_ICAO == "A346" then XPonDr = 2 else XPonDr = 3 end

			-- A340 : 0 STBY, 1 TA, 2 TARA
				-- TCAS ----------------------------- END

				-- PACKS()
				--LIGHTS

				-- Note : in the new (2021) Airbus operating procedures, setting the exterior lights for takeoff has been moved to a PF item.
				if transfer_exterior_lights_to_the_PM_on_ground then
					-- // -- LIGHTS -- //
					TaxiL 			= 2 -- 0 is OFF while 1 is TAXI and 2 is TAKEOFF L.
					TurnOffL 		= 1 -- 0 is OFF, 1 is ON
					StrobeL 		= 1 -- 0 is OFF, 1 is AUTO, 2 is ON
					-- we keep it soft, the American way.
					-- // -- LIGHTS -- // end of section //
				end
				step = 106
				if cabinready == 0 then
					play_sound(CabinNotReady_sound)
				else
					if PacksOff1and2 == 0 or APU_Bleed_ON == 1 then play_sound(RunwayEntry_sound) end -- don't erase PACK CALL on Packs-OFF TOs
					stop_sound(Boarding_Music)
					if TL_Keep_secondary_sounds == "activate" then stop_sound(Boarding_Music_alternative) end end
			end

			if step == 106 and current_time >= proc_time + 1 and afterstartproc_trigger == 2 and takeoffproc_trigger == 0  then
				-- // -- LIGHTS -- //
				if transfer_exterior_lights_to_the_PM_on_ground then
					if GUI_LandingLights then -- the american way, soft usage of LL
						LandingLeftL 	= 1	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
						LandingRightL 	= 1	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
					else
						LandingLeftL 	= 2	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
						LandingRightL 	= 2	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
						-- the usual european SOP
					end
				end
				if transfer_exterior_lights_to_the_PM_on_ground and (localHour <= 17 or localHour >= 8) then StrobeL = 2 end
				-- during the night, we don't put the strobe to avoid blinding the other guys
				-- see https://www.pprune.org/tech-log/552985-a320-lights-takeoff-sequence.html
				-- // -- LIGHTS -- // end of section //
				-- SGES : remove the follow-me
				show_FM =  false
				FM_chg = true
				step = 107
			end

			if step == 107 and current_time >= proc_time + 4 and afterstartproc_trigger == 2 and takeoffproc_trigger == 0  then
				if PacksOff1and2 == 1 and APU_Bleed_ON == 0 then
					display_bubble("PACKS OFF !")
					--Pack1Switch -- 1 is PACK ON, 0 for PACK OFF
					play_sound(PacksOff1and2_sound)
					Pack1Switch = 0
					Pack2Switch = 0
				else
					display_bubble("CABIN CREW .... ADVISE" ) -- room for improvement ?
				end
				-- added in december 2020, PACK OFF Take OFF
				-- Only if APU BLEED IS NO MORE AVAIL, Otherwise, still it's cool to have PACK from the APU.

				step = 108
			end

			if step == 108 and current_time >= proc_time + 7 and afterstartproc_trigger == 2 and takeoffproc_trigger == 0  then -- 2 seconds spacing
				-- then
				if PLANE_ICAO == "A346" then command_once("AirbusFBW/CopilotTableIn") end
				step = 109
				takeoffproc_trigger = 1
				beforetakeoff_trigger = 1
				Vspeed = 0
				OneHundred_played = 0
				Thrset_played = 0
				ToPackStep = 0
				Perf_updated = 0
				-- CABIN CREW ............................................................. ADVISE
				--command_once("AirbusFBW/CheckCabin")	-- no ! commented out
				--command_once("AirbusFBW/CheckCabin") -- 2022 08 22 -- no ! defeats the purpose to have to wait for the cabin
				display_bubble("READY ! Before TO procedure complete for line-up." )
				BT_P = true
				SC_reset_flag = 0
				if cabinready == 0 then
					if PacksOff1and2 == 0 or APU_Bleed_ON == 1 then play_sound(RunwayEntry_sound) end -- don't erase PACK CALL on Packs-OFF TOs
					display_bubble("Before TO complete except that the cabin is not ready." )
					Current_title = "Before TO complete (waiting for the cabin)."
				else	Current_title = "Before TO (Line-up) proc complete."
				end
			end
		end
		end


		do_often("LINEUP()")
		------------------------------------------------------------------------
		Thrset_played = 0
		OneHundred_played = 0
		SpoolUp_time = 0
		SpooledUp_time = 0
		function TAKEOFF_AND_AFTER_TAKEOFF() -- takeoff schedule
		if not SpeedyCopilot_first_load then
			if ToLissPNFonDuty == 1 and takeoffproc_trigger == 1 and BatOH1 > 0 then

				-- V-speeds monitoring (with a lot of safety triggers)

				if TakeoffDecision >= 50 and speed >= TakeoffDecision - 2 and speed <= TakeoffDecision and altitudeAGL <= 10 and Vspeed == 0 then
					if PLANE_ICAO ~= "A346" then play_sound(TakeoffDecision_sound) end --A340-600 already has the call
					Vspeed = 1
					reverse_played = 0
				end -- - 1 because sound latency

				if speed >= TakeoffRotate - 2 and speed <= TakeoffRotate and Say_Rotate == 1 and Vspeed == 1 then	play_sound(TakeoffRotate_sound) Vspeed = 2 end

				if speed >= TakeoffReference -2 and speed <= TakeoffReference and Vspeed == 2 then
					--play_sound(TakeoffReference_sound) -- V2 is never said.
					Vspeed = -1
				end

				-- if Eng1N1 >= 25 and Perf_updated == 0 then
					-- -- also update actual RED and Acc altitudes (again !)
					-- -- by reading the MCDU values in the ToLiss A319
					-- command_once("AirbusFBW/MCDU2Perf")
					-- -- ACTUAL THR RED and ACC from MCDU
					-- -- every time we have a chance to retrieve actual values from the PERF PAGE in the MCDU, we do it.
					-- Perf_updated = 1
					-- -- " 1660 1660           560"
				-- end
				-- if Eng1N1 >= 30 and Perf_updated == 1 then

					-- message_time=math.floor(os.clock())  -- used by function AutoClear
					-- function Message()
						-- message_done = 0 -- used by function AutoClear
						-- big_bubble( 50, 20, "THRAcc " .. Actual_THRAcc,"Acceleration altitude to retract flaps.")
					-- end
					-- -- its updated
					-- command_once("AirbusFBW/MCDU2Fpln")
					-- Current_title = "Takeoff procedure"
					-- Perf_updated = 2
				-- end

				-- takeoff call outs THRUST SET 80 kts (PM sounds only) -- added in rev 3.4
				if Eng1N1 >= 38 and Eng2N1 >= 38 and Thrset_played == 0 then
					Current_title = "Takeoff procedure"
					-- if the take off PERF page was never displayed, the actual RED and ACC altitudes have not been updated from the default 799
					-- Therefore it's better than nothing to take what is in the advisory RED/ACC calculator in the option menu and supposed it as selected by the pilot.
					if TL_Accel_AltitudeBaro_fromMCDU == 799 then TL_Accel_AltitudeBaro_fromMCDU = TL_Accel_Altitude end
					if Red_AltitudeBaro_fromMCDU == 799 then Red_AltitudeBaro_fromMCDU = Red_AltitudeBaro end
					-- then continue
					reverse_played = 0
					SpoolUp_time=math.floor(os.clock())
					SpooledUp_time = 0
					Thrset_played = 1
					-- // -- LIGHTS -- //
					if transfer_exterior_lights_to_the_PM_on_ground then
						LandingLeftL 	= 2	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
						LandingRightL 	= 2	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
						StrobeL 		= 2 -- 0 is OFF, 1 is AUTO, 2 is ON
					end
					-- // -- LIGHTS -- // end of section //
					if ChronoTimeND2 == 0 then command_once("AirbusFBW/CoChronoButton") end

					-- Ajout JZ -----------
					--#CHRONO clock RST
					timerFlightDeck = 0
					command_once("sim/instruments/timer_reset")
					--#CHRONO clock START/STOP
					timerFlightDeck = 1
					----Fin Ajout JZ -------------
					message_time=math.floor(os.clock())  -- used by function AutoClear
					function Message()  message_done = 0
						if normal_messages == 1 then  draw_string( 50, 20, " [Acc " ..  TL_Accel_AltitudeBaro_fromMCDU .. "]", "grey" ) end
					end
				end -- arm trigger

			-- annouce FMA modes

				-- Before 80kts (per FCOM and FCTM) was traducted in "if forward acceleration felt"
				if ((acceleration_pilot > 2 or acceleration_copilot > 2) or current_time >= SpoolUp_time + 10) and Eng1N1 >= THRRatingN1 - 1 and Eng2N1 >= THRRatingN1 - 1 and Thrset_played == 1 and current_time >= SpoolUp_time + 3 then
					if Eng1N1 >= Target_N1_left_Eng1 - 1 and Eng1N1 <= Target_N1_left_Eng1 + 3 and Eng2N1 >= Target_N1_right_Eng2 - 1 and Eng2N1 <= Target_N1_right_Eng2 + 3 and SpooledUp_time == 0 then -- added in december 2020 -- we check the thrust has effectively reached the carret
						-- and then again we wait 1 second to check if it is stabilised
						SpooledUp_time=math.floor(os.clock())
						print("[Speedy Copilot] Reached the thrust target " .. SpooledUp_time)
					end
					if current_time >= SpooledUp_time + 2.5 and Eng1N1 >= Target_N1_left_Eng1 - 0.5 and Eng1N1 <= Target_N1_left_Eng1 + 2 and Eng2N1 >= Target_N1_right_Eng2 - 0.5 and Eng2N1 <= Target_N1_right_Eng2 + 2 then
						print("[Speedy Copilot] Reached the thrust target... ...and confirmed set and stable")
						play_sound(THRUSTSET_sound) Thrset_played = 2
					end
				end -- smart, isn't it ;-) ?
				-- updated december 2020, really checking if thrust is set as requested --dataref("Target_N1_left_Eng1", "AirbusFBW/ENGTLASettingN1","readonly",0) --left --dataref("Target_N1_right_Eng2", "AirbusFBW/ENGTLASettingN1","readonly",1) --right

				-- added december 2020, FLEX / TOGA
				if THRRatingType == 4 and current_time >= SpooledUp_time + 5 and Eng1N1 >= THRRatingN1 - 0.5 and Eng1N1 <= THRRatingN1 + 2 and Eng2N1 >= THRRatingN1 - 0.5 and Eng2N1 <= THRRatingN1 + 2 and Thrset_played == 2  then
					play_sound(MAN_FLEX_sound)
					Thrset_played = 3
				elseif THRRatingType == 3 and current_time >= SpooledUp_time + 5 and Eng1N1 >= THRRatingN1 - 0.5 and Eng1N1 <= THRRatingN1 + 2 and Eng2N1 >= THRRatingN1 - 0.5 and Eng2N1 <= THRRatingN1 + 2 and (Thrset_played == 2 or Thrset_played == 3)  then
					play_sound(MAN_TOGA_sound)
					Thrset_played = 4
				end

				if string.match(FMAmodes, "SRS") and (Thrset_played == 4 or Thrset_played == 3) and current_time >= SpooledUp_time + 7 and current_time <= SpooledUp_time + 7.1 then
					play_sound(SRS_sound)
				end

				if string.match(FMAmodes, "RWY") and (Thrset_played == 4 or Thrset_played == 3) and current_time >= SpooledUp_time + 8 and current_time <= SpooledUp_time + 8.1 then
					play_sound(RWY_sound)
				end

				if speed >= 97 and OneHundred_played == 0 then play_sound(OneHundredknots_sound) OneHundred_played = 2 end

				-- Aborted TO
				if ReverseL > 0.4  and ReverseL > 0.4 and reverse_played == 0 then
					play_sound(ReverseGreen_sound)
					reverse_played = 1
					step = 109
					gearup = 0
					Current_title="TO aborted ?"
				end

				if Vspeed > 0 and reverse_played == 1 then
					Vspeed = 0
					OneHundred_played = 0
					Thrset_played = 0
					Perf_updated = 0
					Current_title = "Takeoff"
				end -- reset to inital takeoff roll conditions

				-- Lift off
				if (GoAroundFlag == true and verticalspeed >= 0 and gearup == 0) or (verticalspeed >= 400 and altitudeAGL >= 30 and gearup == 0) then -- vertical speed to check  -- Altitude above ground level in meters !
					Current_title = "Takeoff"
					-- actions
					--if FLAPS_wanted == 1 and GearPosition == 1 then command_once("sim/flight_controls/landing_gear_toggle") end
					command_once("sim/flight_controls/landing_gear_up")
					climb_trigger = 0
					gearup = 1
					step = 1
					--~ message_time=math.floor(os.clock())  -- used by function AutoClear
					--~ function Message()  message_done = 0
						--~ if normal_messages == 1 then  draw_string( 50, 20, "[Acceleration altitude " ..  TL_Accel_AltitudeBaro_fromMCDU .. " ft]", "grey" ) end
					--~ end
					display_bubble( "Positive climb. [Acceleration altitude " ..  TL_Accel_AltitudeBaro_fromMCDU .. " ft]")
					play_sound(PositiveRate_sound)
					proc_time = math.floor(os.clock())
					-- tested OK
				end

				-- Flaps retraction schedule -- tout se joue à la ligne 4213 modulo modification
				-- AirSpeedFlaps not defined (= 0) when we TO in F-1 !
				--if AirSpeedFlaps == 0 and step == 1 then
				--    proc_time = math.floor(os.clock())
				 --   step = 3
				--end

				if (speed >= flaps1_climb_speed or speed >= 200) and AirbusFBW_ALTFO > TL_Accel_AltitudeBaro_fromMCDU and step == 1 then  -- FCOM says it's done after acceleration altitude
					-- remember that GO AROUND is later triggered with : pressurealtitude < FCUaltitude and altitudeAGL >= 122 m
					-- actions
					if FLAPS_wanted == 1 then
						if flaprqst > 0.25 then flaprqst = 0.25 end
						-- FLAPS 1
						-- in most cases we are already at flaps 1 so we don't see this
						message_time=math.floor(os.clock())  -- used by function AutoClear
						function Message()  message_done = 0
							if normal_messages == 1 then
								draw_string( 50, 20, "Flaps 1... S-speed : " .. flapsUP_climb_speed .. " kts", "white" )
							end
						end
						proc_time = math.floor(os.clock()) -- we want to decompose slowly (be visible by the user) the sequence F2 -> F1 -> F0
					end
					step = 2

				end

				if step == 2  and current_time >= proc_time + 5 then
					savedflapsUP_climb_speed = flapsUP_climb_speed -- flapsUP_climb_speed will be lost after F0, still we need it.

					-- I'll put that here too because it's convenient and we will require it later :
					if XPLMFindDataRef("toliss_airbus/init/cruise_alt") ~= nil then
						temporary = dataref_table("toliss_airbus/init/cruise_alt","readonly") -- I need to verify the unit
						Sc_cruise_alt = temporary[0]
						temporary = nil -- unload dataref
						print("[Speedy Copilot] Cruise alt set at this time : " .. Sc_cruise_alt .. " feet (FMGS).")
					end
					step = 3
				end



				if (speed >= flapsUP_climb_speed or speed > 230) and AirbusFBW_ALTFO > TL_Accel_AltitudeBaro_fromMCDU and step == 3 and current_time >= proc_time + 5 then

					-- actions

					if FLAPS_wanted == 1 then flaprqst = 0  play_sound(FlapsUp_sound) end --flaps UP
					-- tested OK
					step = 4

					flapsretraction_trigger = 1
					message_time=math.floor(os.clock())  -- used by function AutoClear
					function Message()  message_done = 0
						if normal_messages == 1 then
							draw_string( 50, 20, "Flaps UP running... ", "white" )
						end
					end
					proc_time = math.floor(os.clock())

				end

				-- after flaps retraction is complete
				--[[ PM :
				FLAPS ZERO .................................................SELECT
				GND SPLRS ...................................................DISARM
				L/G....................................CHECK UP
				EXTERIOR LIGHTS...........................SET
				--]]

				-- added 2022 08 22 ;
				if step == 4 and speed >= savedflapsUP_climb_speed + 10 and flapsretraction_trigger == 1 and current_time >= proc_time + 4 then
					speedbrake_ratio = 0 -- disarm the ground spoilers
					test_possible_failure("sim/flight_controls/landing_gear_down") -- test if == 1, which would be bad
					-- test_if_is_equal_to_value() is also available
					step = 4.5
				end

				-- after flaps retraction is complete
				if step == 4.5 and speed >= savedflapsUP_climb_speed + 15 and flapsretraction_trigger == 1 and current_time >= proc_time + 6 then
					--LIGHTS
					-- // -- LIGHTS -- //
					-- the american way, reract the landing lights early in climb.
					-- but the A321 Neo XLR has now integrated lights in the belly that don't deploy out of the fuselage any more.
					if GUI_LandingLights then
						-- if there are integrated lights without drag, keep that ON no matter the policy is
						if XPLMFindDataRef("AirbusFBW/LandingLightLocation") ~= nil  then
							if get("AirbusFBW/LandingLightLocation") == 0 then -- with regular landing lights (articulated)
								-- retract them :
								LandingLeftL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
								LandingRightL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
								Current_title = "Takeoff flow done (retractable landing lights)."
							end
						else -- for aircraft before version 1.8 where the dataref does not exists :
							LandingLeftL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
							LandingRightL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
						end
					end
					TaxiL = 0
					-- // -- LIGHTS -- // end of section //
					step = 5.5
				end

				if step == 5.5 and current_time >= proc_time + 7.5 then
					--LIGHTS
					-- // -- LIGHTS -- //
					TurnOffL = 0
					-- // -- LIGHTS -- // end of section //
					display_bubble("Takeoff procedure done.")
					Current_title = "Takeoff flow done."
					T_P = true
					step = 5
				end


				--------------------------------
				-- After takeoff 			  --
				--------------------------------

				--[[ PM :
				'If the APU was used to supply the air conditioning
				during takeoff:
				APU BLEED pb-sw ..................................................... OFF
				APU MASTER SW pb-sw.................................................. OFF
				ENG MODE selector.......................... AS RQRD

				'If the takeoff was performed with TA ONLY:
				TCAS Mode selector ..................................................... TA/RA
				ANTI ICE pb-sw ....................................................... AS RQRD
				--]]


				if speed >= savedflapsUP_climb_speed + 20 and step == 5 and current_time >= proc_time + 9 then
					display_bubble("After takeoff procedure")
					Current_title = "After takeoff procedure"
					-- actions
					if APU_Bleed_ON == 1 then APU_Bleed_ON = 0 end
					step = 6
				end

				if step == 6 and current_time >= proc_time + 10 then
					if APUMasterSwitch == 1 then APUMasterSwitch = 0 end
					step = 7
				end



				if step == 7 and current_time >= proc_time + 20 then
					-- actions
					LandscapeCamera = 0
					-- TCAS ----------------------------- START
					-- (TCAS TARA, XPDR ON) after TO
					-- TRANSPONDER
					if PLANE_ICAO == "A346" then XPDRTCASMode = 2 else XPDRTCASMode = 1 end
					-- TCAS MODE
					if PLANE_ICAO == "A346" then XPonDr = 2 else XPonDr = 4 end
					-- TCAS ----------------------------- END

					--~ message_time=math.floor(os.clock())  -- used by function AutoClear
					--~ function Message()  message_done = 0
						--~ if normal_messages == 1 then draw_string( 50, 20, "In Climb " .. savedflapsUP_climb_speed, "grey" ) end
					--~ end
					--actions finished
					-- when no drag LDG lights are on board of the very aircraft, we delayed the lights extinction till now with the American policy
					-- it's time to shut them off now to be compliant with the user option anyway
					-- // -- LIGHTS -- //
					if GUI_LandingLights then
						LandingLeftL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
						LandingRightL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
					end
					-- // -- LIGHTS -- // end of section //
					Current_title = "After takeoff procedure done."
					AT_P = true
					step = 8
					sched = 0
					takeoffproc_trigger = 2 -- exit from takeoff schedule
				end

				-- regardless of user option, we still must allow flight following from triggers
				-- and we still perform actions unrelated to FLAPS and GEAR

			end -- close if


		end -- close function
		end
		do_every_frame("TAKEOFF_AND_AFTER_TAKEOFF()")

		--------------------------------------------------------------------------------

		-- Climbing at FL100
		function CLIMBHUNDRED()
		if not SpeedyCopilot_first_load then

			-- if flight cruize alt is less than FL100,escaping with takeoffproc_trigger == 2 on next step

			-- after takeoff level 1 lightning items
			if ToLissPNFonDuty == 1 and pressurealtitude >= 10000 and climb_trigger == 0 then -- and takeoffproc_trigger == 2 then
				-- add altitude trigger here
				Current_title = "Climb procedure"
				-- actions
				PedestalPanelFlood = 0.5
				Pack1Switch = 1 -- 1 is PACK ON, 0 for PACK OFF
				Pack2Switch = 1 -- 1 is PACK ON, 0 for PACK OFF
				 -- (Now used as backup)
				SeatBeltSignsOn = 0

				-- // -- LIGHTS -- //
				LandingLeftL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
				LandingRightL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed  (now a backup)
				display_bubble("In climb through FL100")
				play_sound(FL100_sound)

				-- just a confirmation : TARA
				-- TCAS ----------------------------- START
				-- (TCAS TARA, XPDR ON) after TO
				-- TRANSPONDER
				if PLANE_ICAO == "A346" then XPDRTCASMode = 2 else XPDRTCASMode = 1 end
				-- TCAS MODE
				if PLANE_ICAO == "A346" then XPonDr = 2 else XPonDr = 4 end
				-- TCAS ----------------------------- END

				climb_trigger = 2
				takeoffproc_trigger = 8
				C_P = true
			end

			if pressurealtitude >= 10500 and takeoffproc_trigger == 8 then
				TerrainRight = 0
				FrontPanelFlood = 0.6
				if GUI_DeckLights and PedestalPanelFlood < 0.75 then PedestalPanelFlood = 0.75 end
				command_once("AirbusFBW/MCDU2Fpln")
				test_if_is_equal_to_value("AirbusFBW/BaroStdCapt",0)
				if TL_Keep_secondary_sounds == "activate" then play_sound(CabinRelease_sound) end
				-- get the cruise altitude set at this time
				if XPLMFindDataRef("toliss_airbus/init/cruise_alt") ~= nil then
					temporary = dataref_table("toliss_airbus/init/cruise_alt","readonly") -- I need to verify the unit
					Sc_cruise_alt = temporary[0]
					temporary = nil -- unload dataref
					display_bubble("Cruise level set at this time : FL" .. math.floor(Sc_cruise_alt/100) .. " (FMGS).")
					print("[Speedy Copilot] Cruise alt set at this time : " .. Sc_cruise_alt .. " feet (FMGS).")
				end
				step = 8
				sched = 0
				takeoffproc_trigger = 3
			end

		-- function close
		end
		end

		do_sometimes("CLIMBHUNDRED()")


		--------------------------------------------------------------------------------
		F3_time = 0

		-- Execute Descent and approach Procedure
		function APPROACH()
		if not SpeedyCopilot_first_load then

			-- set the trigger
			if ToLissPNFonDuty == 1 and approachproc_trigger == 0 and (takeoffproc_trigger == 3 or takeoffproc_trigger == 2) then -- this action must cycle until landing
				-- takeoffproc_trigger == 3 are flights which did climb above FL100
				-- takeoffproc_trigger == 2 allows flight which does not climb above FL100
				if Current_title ~= "Cruise" and pressurealtitude >= Sc_cruise_alt - 1 and Sc_cruise_alt > 10000 then
					Current_title = "Cruise"
				end
				---------------------------------------------------------------------------------------------------
				--                       -------------------
				-- 2021 Airbus procedure DESCENT PREPARATION (added 2022 08 23)
				--                       -------------------

				-- (when flight alt was > FL100 in my code)

				if pressurealtitude <= Sc_cruise_alt - 1100 and sched == 0 and step == 8 and takeoffproc_trigger == 3 and verticalspeed <= -800 then
					Current_title = "Descent preparation (STATUS PAGE CHECK)"
					display_bubble("Descent")
					CS_P = true
					-- STATUS PAGE ........... CHECK (PM)
					ECAMpage = dataref_table("AirbusFBW/SDSTATUS","writable")
					ECAMpage[0] = 1
					ECAMpage = nil -- unload dataref
					step = 9
				end

				-- I need to verify the unit of Sc_cruise_alt (note for myself)

				if pressurealtitude <= Sc_cruise_alt - 1500 and sched == 0 and step == 9 and takeoffproc_trigger == 3 then
					ECAMpage = dataref_table("AirbusFBW/SDSTATUS","writable")
					ECAMpage[0] = 0
					ECAMpage = nil -- unload dataref
					if GPWS_Flaps3Pressed == 0 then display_bubble("GPWS LDG FLAP3 ?") end
					-- DISPLAY VR message
					if Vr_message_current_answer == "yes" and GPWS_Flaps3Pressed == 0 then
						Message_wnd_content = "GPWS LDG FLAP3 ?"
						Message_wnd_action = "vr_message_sent = false "
						Message_wnd_duration = 5
						Vr_message_current_answer = "?"
					end
					-- End of VR Message
					step = 10
				end


				if pressurealtitude <= Sc_cruise_alt - 1800 and sched == 0 and step == 10 and takeoffproc_trigger == 3 and verticalspeed <= -500 then
					command_once("AirbusFBW/MCDU2Perf") -- mimics CM2 arrival preparation
					if XPLMFindDataRef("toliss_airbus/flightplan/destination_icao") ~= nil then
						Destination = dataref_table("toliss_airbus/flightplan/destination_icao","readonly")
						SC_destination_icao = Destination[0]
						Destination = nil -- unload dataref
						display_bubble("FMGS destination " .. SC_destination_icao)
						--LoadApprPerfPage(SC_destination_icao) 	--if SC_DestWindDir == 0 and SC_DestWindSpd == -1 included
						-- cannot be used as we can only sense weather around the aircraft, not the airport ! caution !
					end
					step = 11
				end

				if pressurealtitude <= Sc_cruise_alt - 2200 and sched == 0 and step == 11 and takeoffproc_trigger == 3 then
					command_once("AirbusFBW/MCDU2Fpln") -- mimics CM2 arrival preparation
					DPP_P = true
					Current_title = "Descent."
					step = 12
				end


				-- it's possible that the steps above are never played by Speedy Copilot but we can live with it
				-- there might be room for improvement if it is possible to get the TOD time informationn by dataref
				-- and anticipate and code the true descent preparation procedure, before the descent.
				-- anyway, it's acceptable like that.

				---------------------------------------------------------------------------------------------------

				-------------
				-- DESCENT --
				-------------

				-- actions
				-- A) when flight alt was > FL100
				if pressurealtitude <= 10000 and sched == 0 and takeoffproc_trigger == 3 then -- BELOW F100/IAS250
					CS_P = true
					Current_title = "Descent procedure"
					display_bubble(Current_title)
					--LoadApprPerfPage(SC_destination_icao)  --if SC_DestWindDir == 0 and SC_DestWindSpd == -1 included
					-- cannot be used as we can only sense weather around the aircraft, not the airport ! caution !
					-- actions

					-- AUTOBRAKE ON DESCENT IS PF ACTION

					-- // -- LIGHTS -- //
					if not GUI_LandingLights then
						LandingLeftL 	= 2	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
						LandingRightL 	= 2	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
						-- // -- LIGHTS -- // end of section //
						TaxiL = 2 -- 0 is OFF while 1 is TAXI and 2 is TAKEOFF lighting
					end
					SeatBeltSignsOn = 1
					sched = 97 -- sets the trigger for annoucements then flaps extension
					message_time=math.floor(os.clock())  -- used by function AutoClear
					function Message()  message_done = 0
						if normal_messages == 1 then big_bubble(50, 20, "FL100 in descent passed") end
					end
					play_sound(FL100D_sound)
					--play_sound(Typing_sound)

					-- Reset S-speed and F-speed initialization.
					-- even if the content of the variables should be taken in charge by the dataref every 10 seconds,
					-- this ensure no ancient and high value is kept during the end of a previous 10 second cycle.
					flaps1_app_speed = 180
					flaps2_app_speed = 160
					flapsAPP_app_speed = 150
					Max_speed_for_next_flaps = 220
				end

				-- Annoucements schedule
				if pressurealtitude <= 9400 and sched == 97 then
					if TL_Keep_secondary_sounds == "activate" then  play_sound(Descent_Ann_sound) end
					if TerrainLeft == 0 and TerrainRight == 0 then TerrainRight = 1 end
					sched = 97.5
				end

				if pressurealtitude <= 8100 and sched == 97.5 then -- added 2022 08 24
					test_if_is_equal_to_value("AirbusFBW/BaroStdCapt",1)
					set("AirbusFBW/NDShowCSTRFO",1) -- is below FL 100 in the procedure, but I feel to display it earlier
					sched = 98
				end

				if pressurealtitude <= 7000 and sched == 98 then
					if TL_Keep_secondary_sounds == "activate" then stop_sound(Descent_Ann_sound)	end
					play_sound(Belts_Ann_sound)
					if GUI_LandingLights then
						LandingLeftL 	= 2	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
						LandingRightL 	= 2	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
						-- // -- LIGHTS -- // end of section //
						TaxiL = 2 -- 0 is OFF while 1 is TAXI and 2 is TAKEOFF lighting
					end
					D_P = true
					sched = 1
					if GUI_DeckLights and PedestalPanelFlood >= 0.4 then FrontPanelFlood = 0.1 PedestalPanelFlood = 0.2 end
				end

				-- B) when flight alt was < FL100 (or High Airports, because now we use altitude AGL)
				if sched == 0 and takeoffproc_trigger == 2 and verticalspeed <= -600 and speed <= flaps1_app_speed + 30 and altitudeAGL <= 1830 then -- BELOW CRUIZE LEVEL -- 6000ft
					Current_title = "In approach"
					CS_P = true
					D_P = true
					-- // -- LIGHTS -- //
					LandingLeftL 	= 2	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
					LandingRightL 	= 2	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
					TaxiL = 2 -- 0 is OFF while 1 is TAXI and 2 is TAKEOFF lighting
					SeatBeltSignsOn = 1
					-- // -- LIGHTS -- // end of section //
					-- let's say you begin approach mode when a good witness says so
					sched = 1 -- sets the trigger for flaps extension

					-- Reset S-speed and F-speed initialization.
					--
					-- In this code, there is a risk that my code consider
					-- the S-Speed artificially high, therefore, deploying flaps 2 early.

					-- Reset S-speed and F-speed initialization.
					-- even if should be taken in charge by the dataref every 10 seconds,
					-- this ensure no ancient and high value is kept during the end of a previous 10 second cycle.
					flaps1_app_speed = 180
					flaps2_app_speed = 160
					flapsAPP_app_speed = 150
					Max_speed_for_next_flaps = 220
				end



				-- C) Flaps extension schedule
				if altitudeAGL <= 760 and verticalspeed <= 0 and radioalive_flag == 0 then -- RA 2500 ft
					D_P = true
					play_sound(RADIOALIVE_sound) -- change actual sound -- new in rev 3.4
					radioalive_flag = 2
					if TerrainLeft == 0 and TerrainRight == 0 then TerrainRight = 1 end
					set("AirbusFBW/NDShowCSTRFO",1)
					print("radioalive_flag = 2 sched = " .. sched .. " Flaps1_app_speed : " .. flaps1_app_speed)

					-- At that point, if PERF APPR page was not completed by the human user, we need to have to completed.
					-- We suggest to fill the fields whith the weather at nearest airport, or airport from the FP.

					-- FCOM says :
					--PERF APPR page............................................................................ COMPLETE/CHECK ▏
						-- Enter the QNH, temperature, and wind at destination.
						-- Note: Insert the average wind given by the ATC or ATIS. Do not insert the gust value. During
						-- approach, the Ground Speed Mini function (manage speed mode) takes into account the
						-- instantaneous gust.
						-- For more information: Refer to Ground Speed Mini Function.

					--This incorporates a check for DestWindDir == -1 and DestWindSpd == -1 ie winds are empty in PERF APPR page
					LoadApprPerfPage()
					--does nothing ortherwise : cannot erase user input.

				end

				if altitudeAGL <= ApproachActiveRadioAltitude and sched == 1 and speed <= flaps1_app_speed + 15 then  -- Altitude above ground level in meters ! 6000 ft = 1830 m
					GoAroundFlag = false
					radioalive_flag = 0
					flapsretraction_trigger = 1

					if TL_Keep_secondary_sounds == "activate" then  stop_sound(Descent_Ann_sound) end -- for restarts
					stop_sound(Belts_Ann_sound) -- for restarts
					play_sound(Belts_Ann_sound)
					DomeLight = 0
					message_time=math.floor(os.clock()) + 10  -- used by function AutoClear
					function Message()  message_done = 0
						if debug_message == 1 then  draw_string( 50, 20, "[" .. radioaltitude .. "]", "grey" ) end -- for debug
					end
					if GPWS_Flaps3Pressed == 1 then play_sound(APP_flaps3_expect_sound)	end

					-- user information
					message_time=math.floor(os.clock())  -- used by function AutoClear
					function Message()  message_done = 0
						if normal_messages == 1 then
							if GPWS_Flaps3Pressed == 1 then
								draw_string( 50, 20, "Expect flaps 3 for landing (per GPWS setting)", "white" )
							else
								draw_string( 50, 20, "Expect flaps full for landing", "grey" )
							end
							--if Max_speed_for_next_flaps > flaps1_app_speed then
								--draw_string( 50, 40, "Expect CONF 1 below a maximum of " .. Max_speed_for_next_flaps .. " kts, while approaching Green Dot-speed at " .. flaps1_app_speed .. " kts", "grey" ) -- below VFEnext - 10
								draw_string( 50, 40, "Expect CONF 1 at " .. flaps1_app_speed .. " kts while approaching Green Dot-speed. We check below VFE next.", "grey" ) -- below VFEnext - 10
							--else
							--	draw_string( 50, 40, "Expect CONF 1 approaching S-speed at " .. flaps1_app_speed .. " kts and " .. flapTwoPressureAltitude .. " ft", "white" ) -- below F-speed + 10
							--end
						end
					end
					sched = 2
					print ("sched = 2")

					if show_Chocks ~= nil and Chocks_chg ~= nil and show_Chocks then show_Chocks = false  Chocks_chg = true end -- safety removal of chocks !
				end


				if sched == 2 and speed <= flaps1_app_speed and speed <= Max_speed_for_next_flaps then
					-- actions
					if FLAPS_wanted == 1 then
						flaprqst = 0.25 -- FLAPS 1
						play_sound(APP_flaps1_sound)
					end
					if GUI_DeckLights then FrontPanelFlood = 0.1 PedestalPanelFlood = 0.2 end
					-- flaps expected

					-- user information
					message_time=math.floor(os.clock())  -- used by function AutoClear
					function Message()  message_done = 0
						if normal_messages == 1 then
							if GPWS_Flaps3Pressed == 1 then
								draw_string( 50, 20, "Expect flaps 3 for landing (per GPWS setting)", "white" )
							else
								draw_string( 50, 20, "Expect flaps full for landing", "grey" )
							end

							draw_string( 50, 40, "Expect CONF 2 at " .. flaps2_app_speed .. " kts and " .. flapTwoPressureAltitude .. " ft when approaching S-speed.", "grey" ) -- below
							--draw_string( 50, 40, "Expect CONF 2 below a maximum of " .. Max_speed_for_next_flaps .. " kts, approaching S-speed at " .. flaps2_app_speed .. " kts and " .. flapTwoPressureAltitude .. " ft", "grey" ) -- below VFEnext - 10
						end
					end
					sched = 3
					print ("sched = 3")
					GearDone = 0
					-- tested OK
				end

				-- ///////////////////////////////////////////////
				-- Altitude AGL in meters, Baro ALtitude in feet
				-- ///////////////////////////////////////////////

				-- THE DECELERATED APPROACH vs THE STABILIZED APPROACH taken into account following FCOM and FCTM guidance (v2.0 optimization)
				-- THE DECELERATED APPROACH
				-- In most cases, this equates to the aircraft being in
				-- CONF 1 and at S speed at the FAF. (ILS)
				-- THE STABILIZED APPROACH
				-- This technique refers to an approach where the aircraft reaches the FAF in the
				-- landing configuration at VAPP. (NPA)
				if sched == 3 and (altitudeAGL <= 518 or (speed <= flaps2_app_speed and altitudeAGL <= maximumGearAltitude) or (speed <= flaps2_app_speed and AirbusFBW_ALTFO < flapTwoPressureAltitude)) and speed <= Max_speed_for_next_flaps  then -- allows both techniques. See schematics in PDF manual.
				-- altitudeAGL <= 580 is a safety trigger (( changed for 518 meters = 1700 ft instead of 1900 ft
					backup_flapsAPP_app_speed = AirSpeedSlats - 30  -- Save the value at that time before AirSpeedSlats vanishes
					--flaps3Altitude = FCUaltitude - 200 --ft -- Save that value at the time of gearD, because the FCU is the FAF value at this time. Will be used for flaps 3.
					flaps3Altitude = FCUaltitude - 000 --ft
					flaps3LastAltitude = FCUaltitude - 1200 --ft
										-- saving that now is mandatory, because the FCU will be reset later to missed app altitude.
					-- actions
					if FLAPS_wanted == 1 then
						flaprqst = 0.50 -- FLAPS 2
						if speed > flapsAPP_app_speed and altitudeAGL > 365 and AirbusFBW_ALTFO > flaps3Altitude then play_sound(APP_flaps2_sound) end
					end
					if FLAPS_wanted == 1 and GearPosition == 0 and GearDone == 0 then command_once("sim/flight_controls/landing_gear_toggle") GearDone = 2 end -- GearPosition added in v2.1 if Gear was used as speed brake, we don't want the PM to retract it.
					if FLAPS_wanted == 1 then command_once("sim/flight_controls/landing_gear_down") end
					-- tested OK
					speedbrake_ratio = -0.5
					TaxiL = 2 -- 0 is OFF while 1 is TAXI and 2 is TAKEOFF lighting
					TurnOffL = 1 -- 0 is OFF
					sched = 4
					print ("sched = 4")
					gearup = 0
					APPlayed = 0
					F3_time = -1

					message_time=math.floor(os.clock()) + 5  -- used by function AutoClear
					function Message()  message_done = 0
						if normal_messages == 1 then
							--big_bubble( 50, 20, "Flaps 2 , Gear down","Expect CONF 3 below a maximum of " .. Max_speed_for_next_flaps .. " kts, at " .. flapsAPP_app_speed .. " kts while approaching F-speed (FMGS) and " .. flaps3Altitude .. " ft (per FCU)")
							big_bubble( 50, 20, "Flaps 2 , Gear down","Expect CONF 3 at " .. flapsAPP_app_speed .. " kts and " .. flaps3Altitude .. " ft while approaching F-speed.")
							--draw_string( 50, 40, "Expect CONF 3 below a maximum of " .. Max_speed_for_next_flaps .. " kts, approaching F-speed at " .. flapsAPP_app_speed .. " kts and " .. flaps3Altitude .. " ft", "grey" ) -- below VFEnext - 10
						end
					end
					-- FLIGHT ATTENDANTS DUTIES
					random = math.random()
					if random >= 0.3 then
						-- Cabin reports ready :
						command_once("AirbusFBW/CheckCabin")
					end
					-- if outside of range then, will be ready at next step.
					-- to add some sense of randomness to the cabin report.
				end



				if ((((speed <= flapsAPP_app_speed or speed < backup_flapsAPP_app_speed) and AirbusFBW_ALTFO <= flaps3Altitude) or altitudeAGL <= 366 or AirbusFBW_ALTFO <= flaps3LastAltitude) and altitudeAGL >= 61) and speed < Max_speed_for_next_flaps  and sched == 4 then  -- Altitude above ground level in meters ! 1200 ft (FCOM decelerated approach)
					-- altitudeAGL >= 58 m is used to avoid unwanted goaround
					-- (speed <= flapsAPP_app_speed or speed < backup_flapsAPP_app_speed) means
					-- below F speed, or below s speed minus 35 as a safety lowest speed possible before slecting F3
					-- we hope hat flapsAPP_app_speed (ie F speed) will be triggered usually
					-- because it will be greater than S minus 35.
					-- actions

					-- FLAPS
					if FLAPS_wanted == 1 then
						flaprqst = 0.75 -- FLAPS 3
					end

					-- then regardless of user option, we still must allow flight following from triggers
					-- and we still perform actions unrelated to FLAPS and GEAR

					-- FLIGHT ATTENDANTS DUTIES
					if random < 0.3 then
						-- Cabin reports ready :
						command_once("AirbusFBW/CheckCabin")
					end

					-- different actions depending on wether F3 is final flaps or not.
					if GPWS_Flaps3Pressed ~= 1 then -- if F3 is not the final flap setting.
						if F3_time == -1 then
							F3_time=math.floor(os.clock()) -- set a timer to delay FLAPS FULL later
						end
						sched = 4.5 -- 4.5 because the sequence is not finished
						print ("sched = 4.5")
					else -- if GPWS FLAPS 3 is selected
						if APPlayed == 0 then
							play_sound(APP_flaps3FC_sound)
							APPlayed = 2 -- limit the sound to one occurence
							message_time=math.floor(os.clock())  -- used by function AutoClear
							function Message()  message_done = 0
								if normal_messages == 1 then big_bubble( 50, 20, "Flaps 3", "Final config.") end
							end
						end
						sched = 5 -- 5 because we go directly to the end of the sequence.
						print ("sched = 5 - FLAPS 3 FINAL CONFIG")
					end
					--RolloutSpeedSave = AirSpeedMinSelect
					RolloutSpeedSave = 110 -- TEMPO -- 110 but also added negative acceleration check 12/2020
					spoilers_played = 0
					reverse_played = 0
					callout_played = 0
				end

				-- for flaps full, general speed and altitude gate already are OK from previous step.
				-- we just let a few seconds of difference, provided we are below VFEnext for flaps full.
				-- (we relax our delta by 5 knots because runway is approaching fast now !)
				-- we can wait for F-Speed, but that would pt at risk full flaps deployement.
				if sched == 4.5 and current_time > F3_time + 5 and speed < Max_speed_for_next_flaps + 5  and altitudeAGL >= 61 then

					A_P = true
					if FLAPS_wanted == 1 then
						flaprqst = 1 -- FLAPS FULL
					end

					if APPlayed == 0 then
						play_sound(APP_flapsFull_sound)
						APPlayed = 2
						message_time=math.floor(os.clock())  -- used by function AutoClear
						function Message()  message_done = 0
							if normal_messages == 1 then big_bubble( 50, 20, "Flaps full") end
						end
					end
					sched = 5
					print ("sched = 5")
				elseif sched == 4.5 and altitudeAGL < AGL_onGround  then -- but if it comes to late, the copilot thinks it risks to destabilize the approach and does nothing, he skips flaps full.
					if TL_Keep_secondary_sounds == "activate" then play_sound(Humsound) end
					sched = 5
				end


				-- tested OK
				--go around management
				-- positive rate trigger cannot be too little because it would too often trigger GO AROUND on so so stabilised approaches.
				if AirbusFBW_ALTFO <= FCUaltitude and altitudeAGL >= 70 and sched >= 2 and speed >= go_around_speed_detection and verticalspeed >= go_around_verticalspeed_detection and GoAroundFlag == false then  -- Altitude above ground level in meters ! 1400 ft and 400ft
					-- altitudeAGL >= xx m is used to avoid unwanted goaround
					-- In case of Go Around below altitudeAGL, when the aircraft reach altitudeAGL, it will trigger this part.
					GA_P = true
					--~ AT_P = false
					--~ C_P = false
					--~ CS_P = false
					--~ A_P = false
					--~ L_P = false
					-- actions
					-- force spoiler down, I tend to forget this in the rush.
					speedbrake_ratio = 0
					Current_title = "Go around"
					flaprqst = 0.50 -- flaps 2
					sched = 0
					GearDone = 0
					flapsretraction_trigger = 0
					approachproc_trigger = 0
					takeoffproc_trigger = 1 -- execute GO AROUND and exit this approach and landing cycling surveillance
					message_time=math.floor(os.clock()) + 40   -- used by function AutoClear
					function Message()  message_done = 0
						big_bubble( 50, 20, "* GO AROUND *" )
					end
					GoAroundFlag = true -- to ease flaps full on circle to land
					gearup = 0
					MENU_RESET = 1 -- the most efficient - line added in v. 3.1 !
				end

				--no go around (landed)
				if radioaltitude <= 2 and sched == 5 and
				(
				(speed <= RolloutSpeedSave and (acceleration_pilot < -2 or acceleration_copilot < -2))
				or
				(acceleration_pilot < -4 or acceleration_copilot < -4)
				)
				then -- we have two entry conditions : regular and frank decelaration where no doubt is permitted (changed december 2020)
					Current_title = "Landing procedure"
					afterstep = 0 -- mandatory - prepares after landing items
					-- approachproc_trigger = 2 -- exit this approach and landing cycling surveillance
					--print("Rollout")
					message_time=math.floor(os.clock())  -- used by function AutoClear
					function Message()  message_done = 0
						draw_string( 50, 20, "Rollout", "green" )
						if NoseTire ~= 0 or LeftTire ~= 0 or RightTire ~= 0 then draw_string( 50, 40, "Check tire pressure !", "red" ) end
					end

					-- // -- LIGHTS -- //
					if transfer_exterior_lights_to_the_PM_on_ground then
						TurnOffL 		= 1 -- 0 is OFF, 1 is ON
					end
					if GUI_DeckLights then PedestalPanelFlood = 0.4 end -- helps locating the various handles
					-- // -- LIGHTS -- // end of section //

					if SpoilersPositionL >= 0.26 and SpoilersPositionR >= 0.26 and spoilers_played == 0 then play_sound(GroundSpoilers_sound) spoilers_played = 1 SpeedSave = speed end
					if ReverseL ~= 0  and ReverseR ~= 0 and reverse_played == 0 then play_sound(ReverseGreen_sound) reverse_played = 1 approachproc_trigger = 2 end
					-- Doesn't stop until reverse selectionned. When reverse green, exits the approach and landing function.
					if speed == SpeedSave - 30 and spoilers_played == 1 then --check no overlap with reverse
						play_sound(Deceleration_sound)
						L_P = true
					end

					-- add here the "70 knots" call (revision 3.4)
					if speed <= 70 and spoilers_played ~= 3 then
						--message_time=math.floor(os.clock())  -- used by function AutoClear
						--function Message()  message_done = 0
						--	if normal_messages == 1 then big_bubble( 50, 20, "70 knots" ) end
						--end
						play_sound(seventyknots_sound)
						L_P = true
						spoilers_played = 3
					end
				end

				if  radioaltitude <= 2 and sched == 5 and speed <= 75 then -- safety exit at 70 knots if no reverser on landing.
					approachproc_trigger = 2 -- exit this approach and landing cycling surveillance
					L_P = true
				end


			--actions finished
			end
		-- function close
		end
		end

		do_every_frame("APPROACH()")

		--------------------------------------------------------------------------------

		function AFTERLANDING()
		if not SpeedyCopilot_first_load then
			-- on ground with speedbrake retracted by the captain
			-- speedbrake should be checked for retracted value
		  if ToLissPNFonDuty == 1 and approachproc_trigger == 2 and afterlandingproc_trigger == 0 and altitudeAGL <= 50 and speed <= 75 and BatOH1 > 0 then


			-- speed brake DISARM must launch the after landing items
			-- and also from a range of position of the handle because it jitters !
			if speedbrake_ratio >= -0.3 and speedbrake_ratio <= 0.1 and afterstep == 0 then
				Current_title = "After landing procedure"
				proc_time = math.floor(os.clock())
				message_time=math.floor(os.clock())  -- used by function AutoClear
				function Message()  message_done = 0
					if normal_messages == 1 then draw_string( 50, 20, "After landing", "green" ) end
				end
				-- actions

				-- Ajout JZ ----
				-- Ona arrête chrono FO et Chrono Clock une fois posé pour figer le FLT TIME
				command_once("AirbusFBW/CoChronoButton")
				--#CHRONO clock START/STOP
				timerFlightDeck = 0
				--- Fin ajout JZ
				-- // -- LIGHTS -- //
				if transfer_exterior_lights_to_the_PM_on_ground then
					BeaconL			= 1 -- 0 is OFF, 1 is red ON
					NavL 			= 1 -- 0 is OFF, 1 is set #1, 2 is set #2
					WingL			= 0 --
					TaxiL 			= 1 -- 0 is OFF while 1 is TAXI and 2 is TAKEOFF L.
					LandingLeftL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
					LandingRightL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
					--TurnOffL 		= 0 -- 0 is OFF, 1 is ON
					StrobeL 		= 1 -- 0 is OFF, 1 is AUTO, 2 is ON
				end
				if GUI_DeckLights then FrontPanelFlood = 0.06 PedestalPanelFlood = 0.4 end
				-- // -- LIGHTS -- // end of section //
				afterstep = 1


			end
			if afterstep == 1 and current_time >= proc_time + 2  then
				afterstep = 2
				-- weather radar is PM action
				radar = 1 -- 1 is OFF
				radarPWS = 0
				TerrainRight = 0 -- also remove eventual Terrain on FO ND
				if boardingMusic == 1 and TL_Keep_secondary_sounds == "activate" then play_sound(Boarding_Music_alternative) else 	play_sound(Boarding_Music) end
			end
			if afterstep == 2 and current_time >= proc_time + 6  then


				flaprqst = 0.25
				-- TCAS ----------------------------- START
				-- (TCAS OFF, XPDR ON) after landing
				--
				XPDRTCASMode = 0 -- 0 is AUTO, 1 is ON -- standby or auto
				--
				XPonDr = 2

				--With our outfit we switch from TA/RA (i.e. TCAS ON, TXPR ON) to XPDR (TCAS OFF, XPDR ON) after landing. This is maintained to the parking position and then as part of the shutdown checks we set 1000 and STBY.
				--Leaving the XPDR ON with assigned squawk means we display our callsign to ATC ground movement radar while taxiing. Setting 1000 apparently sets the transponder to display aircraft registration.
				-- Source https://www.pprune.org/archive/index.php/t-310939.html

				-- For online network, I can make an exception to the IRL procedure and shutdown the transponder after landing :
				if Online_transponder == 1 then
					XPonDr = 0 -- standby. No transmission ie TCAS OFF, XPDR OFF
					Xcode = 1000
				end
				-- TCAS ----------------------------- END
				afterstep = 3
			end




			if afterstep == 3 and current_time >= proc_time + 10  then
				-- actions
				-- APU or NOT APU ---------------------------------------------START
				message_time=math.floor(os.clock())  -- used by function AutoClear
				if AfterLandingWithAPU == 1 then
				APUMasterSwitch = 1
					function Message()  message_done = 0
						if normal_messages == 1 then big_bubble( 50, 20, "AFTER LANDING procedure done","With APU") end
					end
					--play_sound(Typing_sound)
					play_sound(AfterLanding3_sound)
				else
					function Message()  message_done = 0
						if normal_messages == 1 then big_bubble( 50, 20, "AFTER LANDING procedure done","Without APU") end
					end
				end
				-- APU or NOT APU ---------------------------------------------END
				if TL_Keep_secondary_sounds == "activate" then play_sound(Arrival_Ann_sound) end
				flaprqst = 0
				afterstep = 4
			end

			-- APU Start
			if afterstep == 4 and current_time >= proc_time + 25 then
				PedestalPanelFlood = 0.75
				if AfterLandingWithAPU == 1  then
					APUStarterSwitch = 1
				end
				set_array("AirbusFBW/ACP2KnobPush",5,1) -- INT RECEPTION KNOB OUT if is 1
				--~ set_array("AirbusFBW/ACP2KnobPush",6,1) -- CAB RECEPTION KNOB OUT if is 1
				AL_P = true
				afterstep = 5
				afterlandingproc_trigger = 2
				message_time=math.floor(os.clock())  -- used by function AutoClear
				function Message()  message_done = 0
					draw_string( 50, 20, "Next item is gate entry ('Lights and doors').", "grey" ) -- message for gate
				end
				-- prepare next step
				SC_reset_flag = 0
				Vr_message_current_answer = "?" vr_message_sent = false
				step = 0 -- prepares shutdown items
			end
		 end



			-- lights and doors (based on chrono at the moment) //changed
			-- this step can be skipped with parking brake ON
			-- changed in rev 3.4 : Click For Light and Doors

		  if ToLissPNFonDuty == 1 and speed < 40 and approachproc_trigger == 2 and afterlandingproc_trigger == 2 then

			if afterstep == 5 and gs_gnd_spd < 1 and current_time >= proc_time + 240 then
				afterstep = 6 -- auto progress when > 4 min of taxying and ground speed reducing
			end

			if afterstep == 5 and current_time >= proc_time + 60 then
				function ClickForEntry()
					if speed < 30 then
						draw_string(50, 20, "(Maintain clicked in the circle to command).", "grey")
						draw_string(365, 60, "Gate Entry ?", "white")
						graphics.draw_circle( 400, 60, 35, 1)
						if MOUSE_X <= 450 and MOUSE_X >=350 and MOUSE_Y <= 110  and MOUSE_Y >= 10 and MOUSE_STATUS == "down" then
							graphics.draw_filled_circle( 400, 60, 35, 1)


							afterstep = 6  --  <----------------------- here

						else MOUSE_STATUS = "up" end
					elseif speed > 30 and XPonDr ~= 0 and Online_transponder == 0 then
						draw_string(50, 20, "(Maintain clicked in the circle to command).", "grey")
						draw_string(355, 60, "IVAO XPNDR OFF", "grey")
						graphics.draw_circle( 400, 60, 35, 1)
						if MOUSE_X <= 450 and MOUSE_X >=350 and MOUSE_Y <= 110  and MOUSE_Y >= 10 and MOUSE_STATUS == "down" then
							graphics.draw_filled_circle( 400, 60, 35, 1)
							-- // IVAO transponder reporting work around //
							XPonDr = 0 -- STBY -- we shut off the transponder in advance to avoid rage from the IVAO network, where rules are different than real life
						else MOUSE_STATUS = "up" end
					else
						draw_string(365, 60, "", "red")
					end
				end
				if speed > 45 and XPonDr ~= 0 and Online_transponder == 0 then --higher speed than buble to reduce nuisance from the GUI
					-- DISPLAY VR message
					if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
						show_window_bottom_bar = true
						end_show_time = math.floor(os.clock()) + 20
						Message_wnd_content = ""    Message_wnd_content = "XPNDR OFF for IVAO ?"
						Message_wnd_action = "vr_message_sent = false XPonDr = 0"
						Message_wnd_duration = 5
						show_the_option_window()
					end
					-- End of VR Message
					if Vr_message_current_answer == "yes" then reset_VR_message_popup()
						XPonDr = 0
					end
				end
			end
			if afterstep == 6 then
				function ClickForEntry()
					draw_string(365, 60, "", "red")
				end

				if PLANE_ICAO == "A346" then command_once("AirbusFBW/CopilotTableOut") end
					--------------------------------------------------------
				-- // -- LIGHTS -- //
				if transfer_exterior_lights_to_the_PM_on_ground then
					BeaconL			= 1 -- 0 is OFF, 1 is red ON
					WingL			= 0 --
					NavL 			= 1 -- 0 is OFF, 1 is set #1, 2 is set #2
					TaxiL 			= 0 -- 0 is OFF while 1 is TAXI and 2 is TAKEOFF L.
					LandingLeftL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
					LandingRightL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
					TurnOffL 		= 0 -- 0 is OFF, 1 is ON
					StrobeL 		= 0 -- 0 is OFF, 1 is AUTO, 2 is ON
				end
				if Eng1N1 > 20 and Eng2N1 > 20 and BeaconL == 0 then BeaconL  = 1 end -- mimic the CM2 watching CM1 actions :-)
				-- // -- LIGHTS -- // end of section //
				if localHour >= 17 or localHour <= 8 then DomeLight = 1 end
				--------------------------------------------------------
				if afterlandingproc_trigger < 3 then -- if 'Lights and Doors' is skipped, then we don't hear it later (v1.1)
					message_time=math.floor(os.clock())  -- used by function AutoClear
					function Message()  message_done = 0
						big_bubble( 50, 20, "Lights and doors","Next item is parking brake.","Then after, engine shutdown and beacon OFF.")
					end
				end
				--------------------------------------------------------
				afterstep = 7
			end


		  end

				----------- PARKBRAKE TRANSITION -----------


			-- transition "when on stand"
		  if ToLissPNFonDuty == 1 and parkbrakeToLiss > 0 and approachproc_trigger == 2 and afterlandingproc_trigger == 2 then


			if PLANE_ICAO == "A346" then command_once("AirbusFBW/CopilotTableIn") end

			Current_title = "Inbound to the stand. (Beacon Off to progress)."
			--if slides_addon_installed then EmerLight = 0 end
			-- on prépare aussi JAR GHD qu'il nous faut réinitiliser !
			if JAR_Ground_Handling_wanted == 1 then DatarefJARLoad()
				GHDpowerCable = 0   -- and clean it  a little. Very useful to clean that.
				GHDChocks = 0		-- otherwise you may end up with vehicles not supposed to be
				GHDcateringFwd = 0	-- if you do non-std stuff with the flight phases
				GHDcateringAft = 0
				GHDfuelTank = 0
				GHDpassengersBus = 0
				GHDnoseConus[0] =0
				GHDloaderAft = 0
				GHDloaderFwd = 0
				GHDforwardStairs = 0
				GHDrearStairs = 0
			end


			function ClickForEntry()
				draw_string( 0, 0, "") -- init
			end
			FrontPanelFlood = 0.75
			-- lights ceinture et bretelles :
			-- // -- LIGHTS -- //
			if transfer_exterior_lights_to_the_PM_on_ground then
				BeaconL			= 1 -- 0 is OFF, 1 is red ON
				WingL			= 0 --
				NavL 			= 0 -- 0 is OFF, 1 is set #1, 2 is set #2
				TaxiL 			= 0 -- 0 is OFF while 1 is TAXI and 2 is TAKEOFF L.
				LandingLeftL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
				LandingRightL 	= 0	-- 0 is retracted, 1 is OFF, 2 is ON and deployed
				TurnOffL 		= 0 -- 0 is OFF, 1 is ON
				StrobeL 		= 0 -- 0 is OFF, 1 is AUTO, 2 is ON
			end
			-- // -- LIGHTS -- // end of section //
			if TL_Keep_secondary_sounds == "activate" then play_sound(BGSound2_Sound) end
			-- APU BLEED
			if AfterLandingWithAPU == 1 then APU_Bleed_ON = 1 end

			-- // IVAO transponder reporting work around //
			XPonDr = 0 -- STBY -- we shut off the transponder in advance to avoid rage from the IVAO network, where rules are different than real life



			speedbrake_ratio = 0 -- safety for restart preparation - important to restart DO NOT REMOVE
			-- nothing but triggers
			afterlandingproc_trigger = 3
			single_engine_cabin_prep_start = 0
			step = 0 -- prepares shutdown items

			-- if we had a tire failure, call the services

			if NoseTire ~= 0 or LeftTire ~= 0 or RightTire ~= 0 then
				WingL = 1
				message_time=math.floor(os.clock()) - 10  -- used by function AutoClear
				function Message()  message_done = 0
					big_bubble( 50, 20, "Check the tires.","Please coordinate with services before taxiing again.")
				end
				if JAR_Ground_Handling_wanted == 1 then
						message_time=math.floor(os.clock())  -- used by function AutoClear
						function Message()  message_done = 0
							big_bubble( 50, 20, "Fire service on their way.","Please coordinate before taxiing again.")
						end
						GHDnoseConus[0] = 0
						GHDnoseConus = nil -- unload dataref
						GHDFireService = dataref_table("jd/ghd/select_11","writable")
						GHDFireService[0] = 1 -- call once
						GHDFireService = nil -- unload dataref
						GHDnoseConus =dataref_table("jd/ghd/select_06","writable") -- reload conflictuous dataref
				end
			end

		  end

		end
		end

		--do_every_frame("AFTERLANDING()") -- because of click trigger. Let see if I can reduce the rate, and still activate the trigger
		do_often("AFTERLANDING()") -- I have added a legend to maintain clicked in the circle for action


		--------------------------------------------------------------------------------


		-- PARKING PROCEDURE , FO items
		function PARKING()
		if not SpeedyCopilot_first_load then

			if ToLissPNFonDuty == 1 and afterlandingproc_trigger == 3 and BeaconL == 0 and Eng1N1 < 17 and Eng2N1 < 17 and Eng3N1 < 17 and Eng4N1 < 17  and BatOH1 > 0 then
				if step == 0 then
					Current_title = "Beacon OFF"
					show_GPU = true
					GPU_chg = true
					proc_time = math.floor(os.clock())
					if slides_addon_installed then proc_time = math.floor(os.clock()) + 10 end
					-- we need to wait for the SLIDES to be disarmed
					play_sound(Cabin_interphone_DoorsManual_sound)
					step = 0.5
				end
				if step == 0.5 and current_time >= proc_time + 16 then
					Current_title = "Parking procedure"
					display_bubble(Current_title)
					--if slides_addon_installed then EmerLight = 0 end


					-- // -- LIGHTS -- // Non - FCOM. Just a little help from the Fo
					if localHour <= 18 or localHour >= 8 then NavL = 0 end
					-- // -- LIGHTS -- // end of section //
					-- APU BLEEDS
					if AfterLandingWithAPU == 1 then APU_Bleed_ON = 1 end
					if JAR_Ground_Handling_wanted == 1 then
						GHDpowerCable = 1
						GHDChocks = 1
					else
						show_Chocks = true
						Chocks_chg = true
						show_Cones = true
						Cones_chg = true
					end
					Toliss_chocks_set = 1
					-- Ajout JZ

					--#CHRONO ET START/STOP
					-- empty ?
					----Fin Ajout JZ -------------
					-- TCAS ----------------------------- START
					-- TRANSPONDER
					--XPonDr = 0 -- standby
					-- see complementary action below.
					-- To avoid rage from the network virtual controllers, we shut it down now, as per FCOM, and also to avoid fierce retaliation :-)
				-- TCAS ----------------------------- END
					-- FUEL PUMPS
					FuelPumpOH6 = 0
					FuelPumpOH5 = 0
					proc_time = math.floor(os.clock())
					step = 1
				end
				if step == 1 and current_time >= proc_time + 4  then
					ExternalPowerAEnabled = 1 -- for the A340-600
					FuelPumpOH4 = 0
					FuelPumpOH3 = 0
					step = 2
					play_sound(Arrived_sound)
					PedestalPanelFlood = 0.75
				end
				if step == 2 and current_time >= proc_time + 6  then
					ExtPowerFlag = 0
					ExternalPowerEnabled = 1
					if JAR_Ground_Handling_wanted == 1 then
						DatarefJARLoad() -- reload to anticipate interactions with the user.
						GHDpowerCable = 1
						GHDChocks = 1
						GHDcateringFwd = 0
						GHDcateringAft = 0
						GHDfuelTank = 0
						GHDpassengersBus = 0
						GHDloaderAft = 1
						GHDloaderFwd = 1
						GHDforwardStairs = 0
						GHDrearStairs = 0
						GHDnoseConus[0] = 0
						GHDnoseConus = nil -- unload dataref
						GHDFireService = dataref_table("jd/ghd/select_11","writable")
						GHDFireService[0] = 0 -- call once
						GHDFireService = nil -- unload dataref
						GHDnoseConus =dataref_table("jd/ghd/select_06","writable") -- reload conflictuous dataref
					else
						l_newval = true
						show_BeltLoader = l_newval
						BeltLoader_chg = true
						show_Cart = l_newval
						Cart_chg = true
						show_Cones = l_newval
						Cones_chg = true
						show_People1 = true
						People1_chg = true
					end
					-- FUEL PUMPS
					FuelPumpOH2 = 0
					FuelPumpOH1 = 0

					FuelPumpOH10 = 0 --A340-600
					FuelPumpOH9 = 0
					FuelPumpOH8 = 0
					FuelPumpOH7 = 0



					-- TCAS
					XPonDr = 0 -- standby
					Xcode = 1000
					step = 2.5
				end


				if step == 2.5 and current_time >= proc_time + 8  then	 -- A340-600
					FuelXFER1 = 0
					FuelXFER2 = 0
					FuelXFER3 = 0
					FuelXFER4 = 0
					FuelXFER5 = 0
					step = 2.6
				end

				if step == 2.6 and current_time >= proc_time + 10  then	 -- A340-600
					FuelXFER0 = 1    -- AUTOSWITCH
					FuelXFER6 = 0
					FuelXFER7 = 0
					FuelXFER8 = 0
					FuelXFER9 = 0
					FuelXFER10 = 0
					FuelXFER11 = 0
					FuelXFER12 = 0
					FuelXFER13 = 0 -- TSFR AUTO / FWD
					step = 2.7
					display_bubble("Ready for the parking checklist")
					Vr_message_current_answer = "?" vr_message_sent = false
				end



				-----------------------------------------------------------------------------------------------------------
				if step == 2.7 and current_time >= proc_time + 10  then	 -- added 2022 08 24
					Current_title = "Parking procedure (parking checklist)"


					function ClickForProcTrigger()
						--if GUI_messages_in_circle_and_all_messages == true then
							draw_string(381, 80, "Parking", "yellow") draw_string(376, 60, "checklist", "yellow") draw_string(375, 40, "complete", "green")
							graphics.draw_circle( 400, 60, 45, 2)
							--draw_string(70, 20, "(Maintain clicked in the circle to validate).", "grey")
							if MOUSE_X <= 450 and MOUSE_X >=350 and MOUSE_Y <= 110  and MOUSE_Y >= 10 and MOUSE_STATUS == "down" then
								graphics.draw_filled_circle( 400, 60, 40, 2)
								reset_VR_message_popup()
								draw_string(381, 80, "Parking", "black") draw_string(376, 60, "checklist", "black") draw_string(375, 40, "complete", "red")
								step = 2.9
							else MOUSE_STATUS = "up" end
						--end
					end
					-- DISPLAY VR message
					if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
						show_window_bottom_bar = true
						end_show_time = math.floor(os.clock()) + 20
						Message_wnd_content = "Complete the parking checklist."
						Message_wnd_action = "vr_message_sent = false step = 2.9"
						Message_wnd_duration = 5
						show_the_option_window()
					end
					-- End of VR Message
					if Vr_message_current_answer == "yes" then reset_VR_message_popup()
						step = 2.9
					end
					-- pause for some time to let do the checklist
					-- Indeed the way the 2021 procedures are written, the checklist sits in the middle of the parking flow !

				end
				-----------------------------------------------------------------------------------------------------------

				if step == 2.9  then
					Current_title = "Parking procedure (continued)"
					display_bubble("Parking procedure (continued after checklist)")
					function ClickForProcTrigger()
						draw_string(0, 0, "","grey")
					end
					reset_VR_message_popup()
					-- DISPLAY VR message
					--~ if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
						--~ show_window_bottom_bar = true
						--~ end_show_time = math.floor(os.clock()) + 20
						--~ Message_wnd_content = ""    Message_wnd_content = Current_title
						--~ Message_wnd_action = "vr_message_sent = false "
						--~ Message_wnd_duration = 3
					--~ end
					-- End of VR Message
					step = 3
					proc_time=math.floor(os.clock())
				end

				if step == 3 and current_time >= proc_time + 15  then
					--step = 0
					shutdownproc_trigger = 2
					flightcontrols_checked = 0
					Toliss_chocks_set = 1 -- Chocks then release PRK BRK
					-- the previous "if" about "PARK BRK PM" is set in the options and also the parking brake have been externalised to first cycling function of the code
					-- only if ground set < 2 so :
					ground_stuff = 2 -- to allow parkbrake interactions
					BrakeReleasedFlag = false -- to allow parkbrake interactions
					if JAR_Ground_Handling_wanted == 1 then
						GHDpowerCable = 1
						GHDChocks = 1
						GHDcateringFwd = 0
						GHDcateringAft = 0
						GHDfuelTank = 0
						if forward_JARstairs_wanted == 0 then GHDpassengersBus = 0 else GHDpassengersBus = 1 end
						GHDnoseConus[0] =1
						GHDloaderAft = 1
						GHDloaderFwd = 1
						if forward_JARstairs_wanted == 1 then GHDforwardStairs = 1 end
						if forward_JARstairs_wanted == 1 then GHDrearStairs = 1 else GHDrearStairs = 0 end
					else
						show_Bus = true
						Bus_chg = true
						show_RearBeltLoader = true
						RearBeltLoader_chg = true
					end
					-- DOORS (2 is open while 0 is closed. 1 is AUTO)
					PaxDoor1L = 2
					if forward_JARstairs_wanted == 1 and AircraftIsP2F == 0 and not slides_addon_installed then PaxDoorRearLeft = 2 end
					ServiceDoor1R = 0
					ServiceDoor2R = 0
					CargoDoor1 = 2
					CargoDoor2 = 2
					if (AIRCRAFT_FILENAME == "a321.acf" or AIRCRAFT_FILENAME == "a321_StdDef.acf" or AIRCRAFT_FILENAME == "a321_XP11.acf" or PLANE_ICAO == "A346" ) then
						BulkDoor = 2
					end
					if localHour >= 17 or localHour <= 8 then DomeLight = 2 end
					if ExternalPowerEnabled == 1 then ExtPowerConnected = 1 end -- overhead button
					if ExternalPowerAEnabled == 1 then ExtPowerAConnected = 1 end -- overhead button A340-600

					--if TL_Keep_secondary_sounds == "activate" then  play_sound(HumSound) end
					xpder_time=math.floor(os.clock())
					coldAndDarkAtc = 1
					pax_time=math.floor(os.clock()) + 22
					max_pax_time=math.floor(os.clock()) + disembark_time

					-- new in 4.5 : flight attendants do also their job on the FAP for CIDS
					cabinready = 0
					doorLock = 1


					------------------------------											///////////////////////////////////////////////////
					-- doing additionnal stuff with the transponder :
					if ground_stuff >= 5 and current_time == xpder_time + 6 and coldAndDarkAtc == 1 then
						coldAndDarkAtc = 2
						command_once("AirbusFBW/ATCCodeKeyCLR") -- as it should be in real life
					end
					if current_time == xpder_time + 7 and coldAndDarkAtc == 2 then
						coldAndDarkAtc = 3
						message_time=math.floor(os.clock())
						function Message()
							message_done = 0 -- used by function AutoClear
							draw_string( 50, 20, "Clearing ATC code " .. coldAndDarkAtc, "grey" ) -- debug
						end
					end
					if current_time == xpder_time + 8 and coldAndDarkAtc == 3 then
						coldAndDarkAtc = 4
						command_once("AirbusFBW/ATCCodeKey1")
					end
					if current_time == xpder_time + 9 and coldAndDarkAtc == 4 then
						coldAndDarkAtc = 5
						command_once("AirbusFBW/ATCCodeKey0")
					end
					if current_time == xpder_time + 10 and coldAndDarkAtc == 5 then
						coldAndDarkAtc = 6
						command_once("AirbusFBW/ATCCodeKey0")
					end
					if current_time == xpder_time + 11 and coldAndDarkAtc == 6 then
						coldAndDarkAtc = 7
						command_once("AirbusFBW/ATCCodeKey0")
						XPDRTCASMode = 0 -- auto
						XPonDr = 0 -- stby
						-- TCAS ----------------------------- START
						-- (TCAS OFF, XPDR OFF) after shutdown
						--With our outfit we switch from TA/RA (i.e. TCAS ON, TXPR ON) to XPDR (TCAS OFF, XPDR ON) after landing. This is maintained to the parking position and then as part of the shutdown checks we set 1000 and STBY.
						-- FD (non-FCOM, Speedy Copilot T319 SOP)
						-- must be off to avoid being treated as trigger later
						set("AirbusFBW/FD2Engage",0)
						set("AirbusFBW/FD1Engage",0)
					end
					------------------------------
					Current_title = "Parking procedure done."
					step = 4
				end



				-- new in ToLiss :
				if step == 4 and current_time >= max_pax_time + -2  then
					if BrakeFan319 ~= 0 then	play_sound(BrakeFans_sound) end -- 1 second sound
					DU7 = 0.10
					DU8 = 0.10
					step = 4.1
				end
				if step == 4.1 and current_time >= max_pax_time + 0  then
					DU5 = 0.20
					DU6 = 0.20
					step = 4.2
				end
				if step == 4.2 and current_time >= max_pax_time + 2  then
					DU4 = 0.25
					step = 4.3
					message_time=math.floor(os.clock())+10  -- used by function AutoClear
					function Message()  message_done = 0
						big_bubble( 50, 20, "PARKING procedure done (PM items).","Press 'NEXT LEG' to start the next leg.","Info : SECURING THE AIRCRAFT procedure not scripted." )
					end
				end
				if step == 4.3 and current_time >= max_pax_time + 4  then
					DU1 = 0.40
					DU2 = 0.40
					DU3 = 0.20
					vr_message_sent = false
					if StrobeL == 1 then
						display_bubble("Check the exterior lights Captain !")
					end -- mimics the CM2 watching the tired CM1 !
					step = 4.4
					if (AIRCRAFT_FILENAME == "a321.acf" or AIRCRAFT_FILENAME == "a321_StdDef.acf" or AIRCRAFT_FILENAME == "a321_XP11.acf" or PLANE_ICAO == "A346") then
						BulkDoor = 0
					end
					if PLANE_ICAO == "A346" then command_once("AirbusFBW/CopilotTableOut") end
				end
				if step == 4.4 and current_time >= max_pax_time + 8  then
					step = 4.5
					P_P = true
					message_time=math.floor(os.clock())+60  -- used by function AutoClear
					function Message()  message_done = 0
						big_bubble( 50, 20, "PARKING procedure done (PM items).","Press NEXT LEG to start the next leg.","Info : SECURING THE AIRCRAFT procedure not scripted." )
					end
					reset_VR_message_popup()
				end
				if step == 4.5 and current_time >= max_pax_time + 10  then
					-- DISPLAY VR message
					if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
						show_window_bottom_bar = true
						end_show_time = math.floor(os.clock()) + 40
						Message_wnd_content = "PM items of the PARKING procedure done. Start now the next leg ?"
						Message_wnd_action = "vr_message_sent = false MENU_RESET = 101"
						Message_wnd_duration = 30
						show_the_option_window()
						step = 4.6 -- end
					end
				end
				if step == 4.6 and current_time >= max_pax_time + 10  then

					-- End of VR Message
					if Vr_message_current_answer == "yes" then
						step = 4.7 --deadend
						MENU_RESET = 101
						reset_VR_message_popup()
						Current_title = "Open the menu to press NEXT LEG"
					end
				end

			end

		end
		end
		do_often("PARKING()")


		function deboarding()
		if not SpeedyCopilot_first_load then
			if TL_Keep_secondary_sounds == "activate" and shutdownproc_trigger == 2 and step >= 4 and current_time > pax_time + 8 and current_time < max_pax_time then
				random = math.random()
				if random > 0.7 then play_sound(Deb6) pax_time=math.floor(os.clock())
				elseif random > 0.6 and random <= 0.7 then play_sound(Deb7) pax_time=math.floor(os.clock())
				elseif random > 0.5 and random <= 0.6 then play_sound(Deb5) pax_time=math.floor(os.clock())
				elseif random > 0.4 and random <= 0.5 then play_sound(Deb4) pax_time=math.floor(os.clock())
				elseif random > 0.3 and random <= 0.4 then play_sound(Deb3) pax_time=math.floor(os.clock())
				elseif random > 0.5 and random <= 0.3 then play_sound(Deb2) pax_time=math.floor(os.clock())
				elseif random <= 0.2 then play_sound(Deb1) pax_time=math.floor(os.clock()) end
			end
			if TL_Keep_secondary_sounds == "activate" and shutdownproc_trigger == 2 and step >= 4 and current_time > pax_time + 8 and current_time < max_pax_time then
				if JAR_Ground_Handling_wanted == 1 then
					GHDpowerCable = 1
					GHDChocks = 1
					GHDcateringFwd = 1
					GHDcateringAft = 1
					GHDfuelTank = 1
					GHDpassengersBus = 0
					GHDnoseConus[0] =1
					GHDloaderAft = 0
					GHDloaderFwd = 0
				else
					show_Bus = false
					Bus_chg = true
					show_Pax = false
					Pax_chg = true
					show_Catering = true
					Catering_chg = true
					show_Cleaning = true
					Cleaning_chg = true
				end
			end
		end
		end
		do_often("deboarding()")

		--------------------------------------------------------------------------------


		--########################################
		--# MESSAGE DISPLAY FUNCTIONS            #
		--########################################
		function AutoClear()
			-- Clear any message after some elpased time
			--	requires at message location : "message_time=math.floor(os.clock())"
			if message_done == 0 and current_time >= message_time + 10 then
				function Message()
					draw_string( 0, 0, "") -- erase any message
					--if debug_message == 1 then draw_string( 50, 20, "[" .. radioaltitude .. "]", "grey" ) end -- debug
				end
			message_done = 2 -- cycles out
			end
		end
		do_sometimes("AutoClear()")

		function ClickForProcTrigger()
			draw_string( 0, 0, "") -- init
		end

		function ClickForEntry()
			draw_string( 0, 0, "") -- init
		end

		function Message_switch()
			if GUI_messages_in_circle_and_all_messages == true then
				Message()
				ClickForProcTrigger()
				ClickForEntry()
			else
				function ClickForProcTrigger()
					draw_string( 0, 0, "") -- init
				end
				function ClickForEntry()
					draw_string( 0, 0, "") -- init
				end
				function Message()
					draw_string( 0, 0, "") -- init
				end
			end

		end
		do_every_draw('Message_switch()')

		function Clear()
			-- Clear any message manually with HORNCUTOUT, MENU or (undocumented) RECALL PANEL
			if CLEAR_MESSAGE == 1 then
				CLEAR_MESSAGE = 0
				function Message()
					draw_string( 0, 0, "") -- erase any message
					--draw_clearscreen()
				end
			end
		end
		do_every_frame("Clear()")

		--########################################
		--# LOW PRESSURE CONNECTION EMULATION    #
		--########################################
		-- reference: aviationgse.com/wp-content/uploads/2016/02/AAPTrilectron-DAC-200.pdf
		-- datarefs for triggers

		air_time_trigger = -1
		air_time = 0
		air_step = 0
		windows_opened = 0
		-- Low pressure conditionned Air injected in Mixer then progress towards ducts
		-- FCOM 1.21.10 LP GROUND CONNECTION TO MIXER UNIT
		-- 18°C conditionned air in the mixer and ducts
		-- in the cabin, it will reach 19 °C
		-- but not really here in the ToLiss 1.3.3 !
		disconnect = 0
		function AirConditionned()
			-- pick initial cabin temperature and decrease it slowly until reaching the insufflated air temperature

			if not SpeedyCopilot_first_load then
				--A) CONDITIONS OF EXECUTION
				-- only if High Pressure ASU is not connected
				-- only if APU does not send BLEED
				-- only on ground and stopped and chocks installed

				--B) LOW PRESSURE REFRIGERANT AIR CONNECTION IN MIXER UNIT
				if ToLissPNFonDuty == 1 and Pre_Conditioned_Air_Unit == 1 and (Toliss_chocks_set ~= 0 or show_Chocks) and GroundHPAir == 0 and APU_Bleed_ON == 0 and altitudeAGL < AGL_onGround and Eng1N1 < 10 then
					-- Source : https://www.pprune.org/tech-log/576679-a319-lp-hp-ground-connectors.html#post9325308
					-- There's no indication of LP ground connection to the aircraft. Normally we coordinate with the ground crew via interphone so as to not have both APU bleed and LP air providing the packs simultaneously.
					-- Indication of the air cart actually providing conditioned air can be seen on the COND page. The zone duct temperature indication shows an according value (an actually comfortable temperature)
					-- dataref
					GroundLPAir = 1
					GroundHPAir = 0
				else
					air_time_trigger = 4
					air_time = 0
					-- air_step = 0
					disconnect = 1
					GroundLPAir = 0
				end
			end
		end
		do_sometimes("AirConditionned()")



		function AirConditionned_dependencies()
			if not SpeedyCopilot_first_load then
			-- If it's not broken , don't fix it !
				--C) Associated sounds
				if ToLissPNFonDuty == 1 and air_time_trigger == 0 and air_time == 0 and air_step == 0 then
					air_time = math.floor(os.clock()) -- runs once !
					air_step = 1
				end

				if ToLissPNFonDuty == 1 and current_time > air_time + 5 and air_time ~= 0 and air_step == 1 then
					-- SOUND : "We have refrigerant air. Better not to use the packs !"
					if ground_stuff >= 0.5 then play_sound(LP_air_unit_sound) end -- avoids sound at X-Plane startup
					-- play_sound(LP_air_unit_sound)
					message_time=math.floor(os.clock())  -- used by function AutoClear
					--function Message()  message_done = 0
					--	draw_string( 50, 20, "LP Unit", "grey" ) -- erase any message
					--end
					air_time_trigger = 2
					air_step= 2
				end
				if ToLissPNFonDuty == 1 and current_time > air_time + 120 and air_time ~= 0 and air_step == 2 then

					-- Delayed sound : FA "Sorry guys, passengers say it's a little cold in the cabin"
					random = math.random()
					if random > 0.9 and TL_Keep_secondary_sounds == "activate" then
						play_sound(CabinCold_sound)
					end
					air_time_trigger = 3 -- cycles out
					air_step = 3
				end

				if ToLissPNFonDuty == 1 and air_time_trigger == 4 and air_step >= 1 and disconnect == 1 then
					if ground_stuff >= 0.5 then play_sound(LP_air_unit_removed_sound) end
					stop_sound(LP_air_unit_sound)
					if TL_Keep_secondary_sounds == "activate" then stop_sound(CabinCold_sound) end
					disconnect = 2
					air_step = 0

				end
			end


		end
		do_sometimes("AirConditionned_dependencies()")

		------------------------------------------------------------------------

		local function isempty(s)
		  return s == nil or s == ''
		end


		function LoadApprPerfPage(fmgs_destination) -- renovated 2022 08 24
			if SC_DestWindDir <= 0 and SC_DestWindSpd == -1 then

				if fmgs_destination == nil then
					 ToLiss_next_airport_index = XPLMFindNavAid( nil, nil, LATITUDE, LONGITUDE, nil, xplm_Nav_Airport)
					if debug_message == 1 then print("[Speedy Copilot] Destination supposed from the nearest airport search.") end
					display_bubble("Checking PERF APPR page.")
				else
					ToLiss_next_airport_index = fmgs_destination
					if debug_message == 1 then print("[Speedy Copilot] Destination retrieved from the FMGS.") end
					display_bubble("Checking PERF APPR page.")
				end
				-- let's examine the name of the airport we found, all variables should be local
				-- we do not waste Lua with variables to avoid conflicts with other scripts
				local outID
				local outName

				-- all output we are not interested in can be send to variable _ (a dummy variable)
				_, _, _, _, _, _, outID, outName = XPLMGetNavAidInfo( ToLiss_next_airport_index )

				-- the last step is to create a global variable the function can read out
				if debug_message == 1 then print(string.format("[Speedy Copilot] Your airport: %s (%s)", outName, outID)) end
				NearestAirport = string.format("%s", outID)
				-- transfer to the PERF APPR PAGE :
				if NearestAirport ~= nil then
					--display_bubble(string.format("PERF APPR page for %s (%s) set with backup data. Check time permitting.", outName, outID))
					display_bubble(string.format("PERF APPR page for %s set with neighboring values. Check, time permitting.", outName))
					print("[Speedy Copilot] PERF APPR page set with neighboring values.")
					SC_DestWindDir = Sim_WindDir
					SC_DestWindSpd = Sim_WindSpd
					SC_DestTemp = OAT
					SC_DestQNH = Sim_QNH_inches -- works in the ToLiss whatever InGH or hPA
				end


		   end
		end

		function Cycling_maths()
			if not SpeedyCopilot_first_load then
					-- round radioaltitude in meters
					radioaltitude=math.floor(altitudeAGL)
					-- weights from XPLANE

					-- give me the integer part of the local time (hour)
					localHour = math.floor(LocalTime / 3600)
					--~ if ToLissPNFonDuty == 0 then
						--~ draw_string( 1, 1, "Copilot inactive", "grey" )
					--~ end
					-- head monitoring only on runway entry procedure
					-- if QuickGlance == 1 and afterstartproc_trigger == 2 and takeoffproc_trigger == 0 and step <= 107 then
						-- dataref("PilotHead", "sim/graphics/view/pilots_head_psi", "readonly") -- prevent external view when writable !
					-- else
						-- PilotHead = 0
					-- end
					target_alt = FCUaltitude -- init

					-- FEET altitude BARO to enter in the FMGS PERF-TO page
					if radioaltitude < 1 and afterstartproc_trigger == 0 and preliminaryprocedure_trigger == 2 and takeoffproc_trigger == 0 then
						fieldElevMSL = AirbusFBW_ALTFO
						Red_AltitudeBaro = math.floor((fieldElevMSL +  TL_thrust_reduction_altitude)/10)*10 -- ft
						TL_Accel_AltitudeBaro = math.floor((fieldElevMSL +  TL_Accel_Altitude)/10)*10 -- all in feet

						if afterstartproc_trigger == 0 and Red_AltitudeBaro ~= Red_AltitudeBaro_fromMCDU and TL_Accel_AltitudeBaro ~= TL_Accel_AltitudeBaro_fromMCDU and preliminaryprocedure_trigger == 2 and takeoffproc_trigger == 0 and parkbrakeToLiss > 0 and (Eng1N1 < 0.9 or Eng2N1 < 0.9) and (MCDU1thrRed == "THR RED/ACC  ENG OUT ACC" or MCDU2thrRed == "THR RED/ACC  ENG OUT ACC") then
							message_time=math.floor(os.clock()) - 10
							function Message()  message_done = 0
								if normal_messages == 1 then draw_string( 242, 10, "Assuming correct QNH setting,", "grey" ) end

								if normal_messages == 1 then draw_string( 420, 10, "advisory THR RED/ACC : " .. Red_AltitudeBaro .. " / " .. TL_Accel_AltitudeBaro .. " ft", "grey" ) end
								if normal_messages == 1 and Red_AltitudeBaro_fromMCDU > 799 and Red_AltitudeBaro == Red_AltitudeBaro_fromMCDU and TL_Accel_AltitudeBaro == TL_Accel_AltitudeBaro_fromMCDU then draw_string( 660, 10, "Actual THR RED/ACC : " .. Red_AltitudeBaro_fromMCDU .. " / " .. TL_Accel_AltitudeBaro_fromMCDU .. " ft", "green" )
								elseif normal_messages == 1 and Red_AltitudeBaro_fromMCDU > 799 then draw_string( 660, 10, "Actual THR RED/ACC : " .. Red_AltitudeBaro_fromMCDU .. " / " .. TL_Accel_AltitudeBaro_fromMCDU .. " ft", "red" ) end
							end
							-- when PERF page is displayed during the pre-engine start events, then we display our recommandation of RED and ACC baro altitude.
							-- It's up to the user to enter it, or not, on the MCDU.
						end
					end



					-- ** ZFW CG **
					-- compute and keep current the ZFW CG
					aircraft_calculated_ZFWCG = (aircraft_CG * 1.2377424176) -9.1442898147
					-- ZFWCG as a linear function of the CG.

					-- after the user said "no", rearm the question :
					if Vr_message_current_answer == "no" then Vr_message_current_answer = "?" end


			end
		end
		do_every_draw("Cycling_maths()")


		------------------------------------------------------------------------

		--########################################
		--# FLAPS SCHEDULE MODULE   (v2.0)       #
		--########################################
		-- We take the computed O, F and S speeds computed by the FMGS/FAC1.
		-- The FCTOM tells us to add 10 knots to the target speed, on approach.
		-- Plus, there is a discrepency of 4 to 5 knots between the MCDU and
		-- the FMGS/FAC1 constantly calculated values.
		-- Therefore we will adopt a delta of 14.
		local speedDelta = 9 --  changed to 9 after user stated early extension

		-- (Convert to kts by multiplying with 1.943844547019393)
		-- Those data are only different than zero if it is relevant to the FMGS/FAC1.
		-- i.e.
		-- When approaching the GreenDot, only green dot contains a value different of 0.
		-- then afer passed, only S-speed is displayed different of 0.
		-- then after passed, only F-speed contains a value  different of 0.
		-- What is great is that our triggered flows are well accorded to that mechanism.
		-- It mirrors what is on the PFD.
		-- As a consequence :
		-- We will initialize them with care.
		-- And if it's not broken, don't repair it !

		flapTwoPressureAltitude = 2000 -- ft (initialization)

		function FLAPSparam() -- to be converted in knots
			if not SpeedyCopilot_first_load then
			-- this function updates the speed values for take-off and approach
				if climb_speed_is_manual == 0 then
				-- after acceleration altitude if pressurealtitude > TL_Accel_Altitude
					flaps1_climb_speed = math.floor(AirSpeedFlaps) + speedDelta/2 -- at F speed order Flaps 1
					flapsUP_climb_speed = math.floor(AirSpeedSlats) + speedDelta/2   -- at S speed order Flaps 0
					if flapsUP_climb_speed == speedDelta/2 then flapsUP_climb_speed = 215 end -- VFE
					-- this line above is required, otherwise there is a transiant at zero and we,
					-- as bad effect, skip flaps 1+F step. We don't want that so we secure
					-- the value temporary with a value near the VFE and when "S" becomes
					-- available, it will be updated.
				end
				--Config 1 = Slats 1 (18 degrees) only. Target speed is S
				--Config 2 = Slats 2 (22 degrees), Flap = 2. Target speed is F. (This is a big change and the acft balloons).
				--Config 3 = Slats 2 Flap = 3. Target speed is still F
				--Config Full = Slats Full (27 degrees) Flap = Full. Target speed reduces to Vapp
				if app_speed_is_manual == 0 then
					Max_speed_for_next_flaps = math.floor(VFENext) - 7 -- five is small margin below VFEnext.
					flaps1_app_speed = math.floor(AirSpeedGreenDot) + speedDelta  	 -- GREEN DOT order Flaps1
					flaps2_app_speed = math.floor(AirSpeedSlats) + speedDelta  -- at 2000 ft AGL ILS , at S speed (NON PRECISION), order Flaps 2,   Check  deceleration  toward F  speed
					flapsAPP_app_speed = math.floor(AirSpeedFlaps) + speedDelta

					-- In case of dataref not populated, emergency backup :
					if AirSpeedGreenDot <= 10 then flaps1_app_speed = 185 end
					if AirSpeedSlats <= 10 then flaps2_app_speed = 170 end
					if AirSpeedFlaps <= 10 then flapsAPP_app_speed = 160 end
					-- I had a situation where the dataref was not populated and that was causing troubles.
				end
				-- we also assume the FCU altitude after Flaps 1 is the FAF altitude and use that to trigger FLAPS 2
				flapTwoPressureAltitude = FCUaltitude + 200 -- ft

				-- METERS ALTITUDE AGL, to trigger pack ON
				if altitudeAGL >= TL_Accel_AltitudeBaro_fromMCDU / 3 and ToPackStep == 0 then
					if Pack1Switch == 0 then
						message_time=math.floor(os.clock()) - 5  -- used by function AutoClear
						function Message()  message_done = 0
							if normal_messages == 1 then draw_string( 50, 20, "Pack 1 ON", "white" ) end
						end
					end
					Pack1Switch = 1
					Pack1_time=math.floor(os.clock())
					ToPackStep = 1
				end
				if current_time > Pack1_time + 4 and ToPackStep == 1 then
					if Pack2Switch == 0 then
						message_time=math.floor(os.clock()) - 5  -- used by function AutoClear
						function Message()  message_done = 0
							if normal_messages == 1 then draw_string( 50, 20, "Pack 2 ON", "white" ) end
						end
					end
					Pack2Switch = 1
					ToPackStep = 2
				end

				--Actual_THRAcc = string.match(THRRedAcc," %d+ (%d+) *%d+")+0


					-- FEET altitude BARO from the FMGS PERF-TO page
					-- when the page is displayed, we will take the values really in force in the MCDU
					-- 1810 1810     710
					-- we want to extract 1810 as RED and 1810 (2nd) as ACC

					--and also, be carefull, we study the TAKEOFF PAGE, not the Go around page
					-- GoAroundPageMarker will be "<PHASE    PHASE>" if G.A. page
					-- GoAroundPageMarker will be "          PHASE>" if T.O. page
					-- we let the Go Around case for simplification. It will use the same
					-- values as for takeoff. A discrepency with user-entered altitudes for
					-- Go around page may be seen in case of Go Around if they are
					-- different than for T.O., but we consider this minor as it will not
					-- affect a successful Go Around. This was tested.
					-- We want to focus on regular take off and climbs because this
					-- is where most users will direct their attention at.
					GAPage1 = string.match(GoAroundPageMarker1,"(<PHASE) *PHASE>")
					GAPage2 = string.match(GoAroundPageMarker2,"(<PHASE) *PHASE>")
					flagRed = ""
					flagAcc = ""
					if MCDU1thrRed == "THR RED/ACC  ENG OUT ACC" and isempty(GAPage1) and altitudeAGL < AGL_onGround then
						if not isempty(MCDU1thrRedValues) then -- will be filed when user has made an entry
							Match = string.match(MCDU1thrRedValues,"(%d+)/.*")
							if not isempty(Match) then
								Red_AltitudeBaro_fromMCDU = Match+0
								--print("RED USER")
								--print(Match)
								flagRed = "user"
							end
							Match = string.match(MCDU1thrRedValues,".*/(%d+)")
							if not isempty(Match) then
								TL_Accel_AltitudeBaro_fromMCDU = Match+0
								--print("ACC USER")
								--print(Match)
								flagAcc="user"
							end
						 end
						 if not isempty(MCDU1thrDefValues) then -- will be filed when user has not made an entry

							if flagRed ~= "user" and flagAcc ~= "user" then
								Match = string.match(MCDU1thrDefValues," (%d+) *%d+ *%d")
								if not isempty(Match) then
									--print("RED DEFAULT1")
									Red_AltitudeBaro_fromMCDU = Match+0
									--print(Match)
									flagRed="def"
								end
								Match = string.match(MCDU1thrDefValues," %d+ *(%d+) *%d")
								if not isempty(Match) then
									--print("ACC DEFAULT1")
									TL_Accel_AltitudeBaro_fromMCDU = Match+0
									--print(Match)
									flagAcc="def"
								end
							elseif flagRed == "user" and flagAcc ~="user" then
								Match = string.match(MCDU1thrDefValues," *(%d+) *%d+")
								if not isempty(Match) then
									--print("ACC DEFAULT2")
									TL_Accel_AltitudeBaro_fromMCDU = Match+0
									--print(Match)
									flagAcc="def"
								end
							elseif flagRed ~= "user" and flagAcc =="user" then --voiture balais
								Match = string.match(MCDU1thrDefValues," (%d+) *")
								if not isempty(Match) then
									Red_AltitudeBaro_fromMCDU = Match+0
									--print("RED DEFAULT3")
									--print(Match)
									flagRed = "def"
								end
								--Match = string.match(MCDU2thrRedValues," */(%d+)")
								--if not isempty(Match) then
								--    TL_Accel_AltitudeBaro_fromMCDU = Match+0
								--    print("ACC USER3")
								--    print(Match)
								--    flagAcc="user"
								--end
							end
						end
					elseif MCDU2thrRed == "THR RED/ACC  ENG OUT ACC" and isempty(GAPage2) and altitudeAGL < AGL_onGround then
						if not isempty(MCDU2thrRedValues) then -- will be filed when user has made an entry
							Match = string.match(MCDU2thrRedValues,"(%d+)/.*")
							if not isempty(Match) then
								Red_AltitudeBaro_fromMCDU = Match+0
								--print("RED USER")
								--print(Match)
								flagRed = "user"
							end
							Match = string.match(MCDU2thrRedValues,".*/(%d+)")
							if not isempty(Match) then
								TL_Accel_AltitudeBaro_fromMCDU = Match+0
								--print("ACC USER")
								--print(Match)
								flagAcc="user"
							end
						 end
						 if not isempty(MCDU2thrDefValues) then -- will be filed when user has not made an entry

							if flagRed ~= "user" and flagAcc ~= "user" then
								Match = string.match(MCDU2thrDefValues," (%d+) *%d+ *%d")
								if not isempty(Match) then
									--print("RED DEFAULT1")
									Red_AltitudeBaro_fromMCDU = Match+0
									--print(Match)
									flagRed="def"
								end
								Match = string.match(MCDU2thrDefValues," %d+ *(%d+) *%d")
								if not isempty(Match) then
									--print("ACC DEFAULT1")
									TL_Accel_AltitudeBaro_fromMCDU = Match+0
									--print(Match)
									flagAcc="def"
								end
							elseif flagRed == "user" and flagAcc ~="user" then
								Match = string.match(MCDU2thrDefValues," *(%d+) *%d+")
								if not isempty(Match) then
									--print("ACC DEFAULT2")
									TL_Accel_AltitudeBaro_fromMCDU = Match+0
									--print(Match)
									flagAcc="def"
								end
							elseif flagRed ~= "user" and flagAcc =="user" then --voiture balais
								Match = string.match(MCDU2thrDefValues," (%d+) *")
								if not isempty(Match) then
									Red_AltitudeBaro_fromMCDU = Match+0
									--print("RED DEFAULT3")
									--print(Match)
									flagRed = "def"
								end
								--Match = string.match(MCDU2thrRedValues," */(%d+)")
								--if not isempty(Match) then
								--    TL_Accel_AltitudeBaro_fromMCDU = Match+0
								--    print("ACC USER3")
								--    print(Match)
								--    flagAcc="user"
								--end
							end
						end
					end
				   -- we have now collected actual RED either from default or manual entry
				   -- and actual ACC either from default or manual entry
					-- both either from MCDU 1 or MCDU 2
					-- That will keep the last value displayed when the PERF PAGE was shown.


				-- Flight directors
				-- we will synchronize with the delay FD states from user seat to the other seat FD.
				if TL_synchronizedFD == "activate" then
					if FD1 == 1 and pilots_head_x < 0 and FD2 == 0 then set("AirbusFBW/FD2Engage",1) end
					if FD1 == 0 and pilots_head_x < 0 and FD2 == 1 then set("AirbusFBW/FD2Engage",0) end
					if FD2 == 1 and pilots_head_x > 0 and FD1 == 0 then set("AirbusFBW/FD1Engage",1) end
					if FD2 == 0 and pilots_head_x > 0 and FD1 == 1 then set("AirbusFBW/FD1Engage",0) end
				end

				if Say_Mins == 1 then
					-- We also add the minimum Baro (MDA) callout, which is airline option and not modelled.
					if MinimumsBaroAltitude > 190 and altitudeAGL > 150 and verticalspeed < 10 then -- if MDA or DA exists and if not too late
						if AirbusFBW_ALTFO < MinimumsBaroAltitude + 180 and callout_played == 0 then
							if AirbusFBW_ALTFO > MinimumsBaroAltitude + 130 then play_sound(ApproachingMinimums_sound) print("---> Approaching minimums of " .. AirbusFBW_ALTFO .. " said at " .. AirbusFBW_ALTFO) end  -- AirbusFBW_ALTFO > MinimumsBaroAltitude + 100 was changed for 130 to avoid intermixing with the more recent ToLiss callout "hundred above"
							callout_played = 1
						end
						if AirbusFBW_ALTFO < MinimumsBaroAltitude + 9 and callout_played == 1 and AirbusFBW_ALTFO > MinimumsBaroAltitude - 50 then
							play_sound(Minimums_sound)
							print("---> Minimums (" .. MinimumsBaroAltitude .. "ft) said at " .. AirbusFBW_ALTFO)
							callout_played = 2
						end
					end
				end


				-- A340-600 specific code because it doesn't have a tree position landing light switch (fixed LL)
				if PLANE_ICAO == "A346" and LandingLeftL == 2 then LandingLeftL = 1  LandingLeftR = 1 end
				-- This patch saves from rewriting code everywhere
				-- This patch also spares breaking the legacy landing lights == 2 trigger, not it's broken anyway in 2023 :-)


				--GUI size
				-- reduce the size when ot a checklist and not an active question:
				--~ if app_is_active and  checklist_card_requested == false and vr_message_sent == false then
					--~ float_wnd_set_geometry(OPTION_WINDOW,bar_X, 90,1590, 0)
				--~ end

			end
		end
		do_often("FLAPSparam()")

		------------------------------------------------------------------------

		--########################################
		--# RESET AND RESTART FUNCTIONS          #
		--########################################
		SC_reset_flag = 0
		function RESTART()
			if not SpeedyCopilot_first_load then


				-- restart to cockpit prep manually
				if ToLissPNFonDuty == 1 and altitudeAGL < AGL_onGround and MENU_RESET == 44 then
					function ClickForProcTrigger()
						draw_string(415, 80, "", "grey")
					end
					message_time=math.floor(os.clock())+10  -- used by function AutoClear
					function Message()  message_done = 0
						big_bubble( 50, 20, "Cockpit preparation","Manual skip to cockpit preparation.")
					end
					single_engine_cabin_prep_start = 0
					RunwayEntryFlag = false
					beforestartproc_trigger = 0
					preliminaryprocedure_trigger = 2
					preflightproc_trigger = 0
					afterstartproc_trigger = 0
					beforetakeoff_trigger=0
					takeoffproc_trigger= 0
					approachproc_trigger = 0
					flapsretraction_trigger = 0
					afterlandingproc_trigger = 0
					shutdownproc_trigger = 0
					flightcontrols_checked = 0
					rollsup_checked = 0
					pitchsup_checked = 0
					rollinf_checked = 0
					pitchinf_checked = 0
					roll_checked = 0
					pitch_checked = 0
					gearup = 0
					step = 0
					sched = 0
					ground_stuff = 14
					genactive1_trigger =0
					genactive2_trigger =0
					genactive3_trigger =0
					genactive4_trigger =0
					started1 = 0
					started2 = 0
					started3 = 0
					started4 = 0
					checklist = 0
					eng1_time = 0
					eng2_time = 0
					air_time = 0
					prep_time = 0
					proc_time = 0
					autostart_step = 0
					--top_flapsAPP_app_speed = 0
					backup_flapsAPP_app_speed = 0
					afterlandingstep = 0
					windows_opened = 0
					disconnect = 0
					spoilers_played = 0
					reverse_played = 0
					BrakeReleasedFlag = false
					GoAroundFlag = false
					MENU_RESET = 0
					cabinready = 0
					XPonDr = 0
					Vspeed = 0
					OneHundred_played = 0
					Thrset_played = 0
					ToPackStep = 0
					Perf_updated = 0
					QAnswered = 0
					prep_time=math.floor(os.clock()) - 2  -- used only at third step + when this line triggered.
					xpder_time = math.floor(os.clock())
					proc_time=math.floor(os.clock())
					fmgs_time=math.floor(os.clock()) + 999
					if TL_Keep_secondary_sounds == "activate" then play_sound(Hi_Sound) end
					CP_P = false
					BSC_P = false
					ASC_P = false
					PB_P = false
					ES_P = false
					AS_P = false
					Tx_P = false
					OET_P = false
					DC_P = true
					BT_P = false
					T_P = false
					AT_P = false
					C_P = false
					CS_P = false
					DPP_P = false
					D_P = false
					A_P = false
					L_P = false
					GA_P = false
					AL_P = false
					P_P = false
					STA_P = false
					reset_VR_message_popup()
				end

				-- restart to cockpit prep manually - FMGS PART !
				if ToLissPNFonDuty == 1 and altitudeAGL < AGL_onGround and MENU_RESET == 33 then
					function ClickForProcTrigger()
						draw_string(415, 80, "", "grey")
					end
					message_time=math.floor(os.clock())+10  -- used by function AutoClear
					function Message()  message_done = 0
						big_bubble( 50, 20, "Cockpit preparation","Manual skip to cockpit preparation.")
					end
					single_engine_cabin_prep_start = 0
					RunwayEntryFlag = false
					beforestartproc_trigger = 0
					preliminaryprocedure_trigger = 2
					preflightproc_trigger = 0
					afterstartproc_trigger = 0
					beforetakeoff_trigger=0
					takeoffproc_trigger= 0
					approachproc_trigger = 0
					flapsretraction_trigger = 0
					afterlandingproc_trigger = 0
					shutdownproc_trigger = 0
					step = 8.45
					ground_stuff = 15
					MENU_RESET = 0
					prep_time=math.floor(os.clock()) - 2  -- used only at third step + when this line triggered.
					xpder_time = math.floor(os.clock())
					proc_time=math.floor(os.clock())
					fmgs_time=math.floor(os.clock()) -10
					if TL_Keep_secondary_sounds == "activate" then play_sound(Hi_Sound) end
					CP_P = false
					BSC_P = false
					ASC_P = false
					PB_P = false
					ES_P = false
					AS_P = false
					Tx_P = false
					OET_P = false
					DC_P = true
					BT_P = false
					T_P = false
					AT_P = false
					C_P = false
					CS_P = false
					DPP_P = false
					D_P = false
					A_P = false
					L_P = false
					GA_P = false
					AL_P = false
					P_P = false
					STA_P = false
					reset_VR_message_popup()
				end

				-- restart to before take off
				if ToLissPNFonDuty == 1 and altitudeAGL < AGL_onGround and MENU_RESET == 55 then
					SC_reset_flag = 1
					function ClickForProcTrigger()
						draw_string(415, 80, "", "grey")
					end
					single_engine_cabin_prep_start = 0
					RunwayEntryFlag = true
					beforestartproc_trigger = 2
					preliminaryprocedure_trigger = 2
					preflightproc_trigger = 2
					afterstartproc_trigger = 2
					beforetakeoff_trigger=0
					takeoffproc_trigger= 0
					approachproc_trigger = 0
					flapsretraction_trigger = 0
					afterlandingproc_trigger = 0
					shutdownproc_trigger = 0
					flightcontrols_checked = 2
					rollsup_checked = 2
					pitchsup_checked = 2
					rollinf_checked = 2
					pitchinf_checked = 2
					roll_checked = 2
					pitch_checked = 2
					gearup = 0
					step = 105
					sched = 0
					genactive1_trigger =2
					genactive2_trigger =2
					genactive3_trigger =0
					genactive4_trigger =0
					started1 = 2
					started2 = 2
					started3 = 2
					started4 = 2
					checklist = 0
					eng1_time = 0
					eng2_time = 0
					air_time = 0
					prep_time = 0
					proc_time = 0
					autostart_step = 0
					--top_flapsAPP_app_speed = 0
					backup_flapsAPP_app_speed = 0
					afterlandingstep = 0
					windows_opened = 0
					disconnect = 0
					spoilers_played = 0
					reverse_played = 0
					BrakeReleasedFlag = false
					GoAroundFlag = false
					MENU_RESET = 0
					cabinready = 2
					XPonDr = 4

					Vspeed = 0
					OneHundred_played = 0
					Thrset_played = 0
					ToPackStep = 0
					Perf_updated = 0
					SupplementaryInit()
					SEI_P = true
					CPP_P = true
					CP_P = true
					BSC_P = true
					ASC_P = true
					PB_P = true
					ES_P = true
					AS_P = true
					Tx_P = true
					OET_P = true
					DC_P = true
					BT_P = false
					T_P = false
					AT_P = false
					C_P = false
					CS_P = false
					DPP_P = false
					D_P = false
					A_P = false
					L_P = false
					GA_P = false
					AL_P = false
					P_P = false
					STA_P = false
					reset_VR_message_popup()
				end



				-- rollout restart on ground (only with flaps more than 75%)
				if ToLissPNFonDuty == 1 and altitudeAGL < AGL_onGround and (MENU_RESET == 99 or ( (ACP_RESET == 1 or MENU_RESET == 1) and speed <= 30 and speedbrake_ratio == 0) ) then -- Armed speedBrake
					SC_reset_flag = 1
					single_engine_cabin_prep_start = 0
					function ClickForProcTrigger()
						draw_string(415, 80, "", "grey")
					end
					XPonDr = 0
					MENU_RESET = 0
					QAnswered = 0
					rollout_time = math.floor(os.clock())
					afterstep = 0 -- done with SPEEDBRAKE DISARM MANUAL
					beforestartproc_trigger = 2
					preliminaryprocedure_trigger = 2
					preflightproc_trigger = 2
					afterstartproc_trigger = 2
					beforetakeoff_trigger=2
					takeoffproc_trigger= 2
					approachproc_trigger = 2
					afterlandingproc_trigger = 0
					takeoffproc_trigger= 3
					shutdownproc_trigger = 0
					BrakeReleasedFlag = false
					message_time=math.floor(os.clock()) + 40  -- used by function AutoClear
					function Message()  message_done = 0
						draw_string( 50, 40, "We will restart to the AFTER LANDING procedure when you disarm the spoilers by using the speedbrake handle.", "yellow" ) -- erase any message
						draw_string( 50, 20, "This is a restart to a rollout state. To reset to another state, please disarm the spoilers and RESET again.", "white" ) -- erase any message
					end
					-- DISPLAY VR message
					if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
						show_window_bottom_bar = true call_question = true
						end_show_time = math.floor(os.clock()) + 10
							Message_wnd_content = "Manual skip to the after landing rollout. Now disarm speed brake."
						Message_wnd_action = "vr_message_sent = false "
						Message_wnd_duration = 2
						show_the_option_window()
					end
					-- End of VR Message
					SupplementaryInit()
					reset_VR_message_popup()
				end



				-- restart for next leg after a flight has been completed
				if ToLissPNFonDuty == 1 and altitudeAGL <= 50 and (MENU_RESET == 101 or ( (ACP_RESET == 1 or MENU_RESET == 1) and speed <= 30 and speedbrake_ratio ~= 0) ) then -- disarmed speedbrake
					MENU_RESET = 0
					vr_message_sent = false
					function ClickForProcTrigger()
						draw_string(415, 80, "", "grey")
					end
					if shutdownproc_trigger == 2 then
						Current_title = "Ready for next leg"
						single_engine_cabin_prep_start = 0
						message_time=math.floor(os.clock())+10  -- used by function AutoClear
						function Message()  message_done = 0
							big_bubble( 50, 20, "Ready for the next leg.","TURN AROUND STATE")
						end
						if TL_Keep_secondary_sounds == "activate" then play_sound(BGSound2_Sound) end
					else
						message_time=math.floor(os.clock())  -- used by function AutoClear
						function Message()  message_done = 0
							draw_string( 50, 20, "RESET TO INITIAL POWER UP DONE.", "yellow" )
						end

						stop_sound(Boarding_Music)
						if TL_Keep_secondary_sounds == "activate" then stop_sound(Boarding_Music_alternative) end
						if TL_Keep_secondary_sounds == "activate" then stop_sound(Boarding_Ann_sound) end
						stop_sound(Safety_Ann_sound)
					end
					coldAndDarkAtc = 0
					-- apu_started = 0
					VSpeed = 0
					cabinready = 0
					PA_trigger = 2
					if TL_Keep_secondary_sounds == "activate" then play_sound(CoughSound) end
					if TL_Keep_secondary_sounds == "activate" then play_sound(Hi_Sound) end
					proc_time = 0
					prep_time=0
					air_time_trigger = 0
					air_time = 0
					air_step = 0
					flightcontrols_time = 0
					QAnswered = 0
					cabinready = 0
					XPonDr = 0
					ground_stuff = 0 -- safety first
					callout_played = 0
					if ExtPowerConnected == 0 then ground_stuff = 0 end -- carefully crafted trigger (only at first start)
					if ExtPowerConnected ~= 0 then ground_stuff = 13 end -- carefully crafted trigger
					-- prepare next step
					set("AirbusFBW/FD1Engage",0)
					set("AirbusFBW/FD2Engage",0)

					-- Ajout JZ reset CLOCK (CHR and ET)
					--#Elapsed clock RST --#CHRONO clock RST
					command_once("sim/instruments/timer_reset")

					ClockETSwitch = 2
					if ChronoTimeND2 > 0 then command_once("AirbusFBW/CoChronoButton") end

					----Fin Ajout JZ -------------

					if speed < 30 then NavL = 0 end -- anti trigger on ground : forbids COCKPIT PREP flow to be launched!
					vr_message_sent = false
					beforestartproc_trigger = 0
					preliminaryprocedure_trigger = 0
					preflightproc_trigger = 0
					afterstartproc_trigger = 0
					beforetakeoff_trigger=0
					takeoffproc_trigger= 0
					approachproc_trigger = 0
					flapsretraction_trigger = 0
					afterlandingproc_trigger = 0
					shutdownproc_trigger = 0
					flightcontrols_checked = 0
					rollsup_checked = 0
					pitchsup_checked = 0
					rollinf_checked = 0
					pitchinf_checked = 0
					roll_checked = 0
					pitch_checked = 0
					gearup = 0
					step = 0
					sched = 0
					genactive1_trigger =0
					genactive2_trigger =0
					genactive3_trigger =0
					genactive4_trigger =0
					started1 = 0
					started2 = 0
					started3 = 0
					started4 = 0
					checklist = 0
					eng1_time = 0
					eng2_time = 0
					current_time = 0
					air_time = 0
					prep_time = 0
					proc_time = 0
					autostart_step = 0
					--top_flapsAPP_app_speed = 0
					backup_flapsAPP_app_speed = 0
					afterlandingstep = 0
					windows_opened = 0
					disconnect = 0
					spoilers_played = 0
					reverse_played = 0
					BrakeReleasedFlag = false
					GoAroundFlag = false
					RunwayEntryFlag = false
					PilotCheckedRight = false
					PilotCheckedLeft = false
					XPonDr = 0
					Vspeed = -1
					SEI_P = true
					CPP_P = false
					CP_P = false
					BSC_P = false
					ASC_P = false
					PB_P = false
					ES_P = false
					AS_P = false
					Tx_P = false
					OET_P = false
					DC_P = false
					BT_P = false
					T_P = false
					AT_P = false
					C_P = false
					CS_P = false
					DPP_P = false
					D_P = false
					A_P = false
					L_P = false
					GA_P = false
					AL_P = false
					P_P = false
					STA_P = false
					reset_VR_message_popup()
				end

				-- inflight restart below FL100
				if ToLissPNFonDuty == 1 and (MENU_RESET == 77 or ( (pressurealtitude >= 101 and pressurealtitude <= 10000 and verticalspeed >= 300) and (ACP_RESET == 1 or MENU_RESET == 1) )) then
					function ClickForProcTrigger()
						draw_string(415, 80, "", "grey")
					end
					vr_message_sent = false
					MENU_RESET = 0
					beforestartproc_trigger = 2
					preliminaryprocedure_trigger = 2
					preflightproc_trigger = 2
					afterstartproc_trigger = 2
					takeoffproc_trigger = 1
					beforetakeoff_trigger = 1
					-- with above 2 triggers, we run the takeoff events automatically again then the restart will be complete/
					approachproc_trigger = 0
					afterlandingproc_trigger = 0
					shutdownproc_trigger = 0
					sched = 0
					genactive_trigger =0
					checklist = 0
					current_time = 0
					proc_time = 0
					prep_time=0
					air_time_trigger = 0
					air_time = 0
					air_step = 0
					flightcontrols_time = 0
					windows_opened = 0
					disconnect = 0
					ToPackStep = 0 -- important
					BrakeReleasedFlag = false
					if PLANE_ICAO == "A346" then XPonDr = 2 else XPonDr = 4 end
					Vspeed = -1
					message_time=math.floor(os.clock())  -- used by function AutoClear
					function Message()  message_done = 0
						draw_string( 50, 20, "RESTARTED TO CLIMB STATE", "yellow" ) -- erase any message
					end
					if TL_Keep_secondary_sounds == "activate" then play_sound(CoughSound) end
					C_P = false
					CS_P = false
					DPP_P = false
					D_P = false
					A_P = false
					L_P = false
					GA_P = false
					AL_P = false
					P_P = false
					STA_P = false
					reset_VR_message_popup()
				end

				-- inflight restart below FL100 and descending
				if ToLissPNFonDuty == 1 and (MENU_RESET == 88 or ( (pressurealtitude >= 101 and pressurealtitude <= 10000 and verticalspeed <= 299  and speed > 110) and (ACP_RESET == 1 or MENU_RESET == 1) )) then
					function ClickForProcTrigger()
						draw_string(415, 80, "", "grey")
					end
					vr_message_sent = false
					MENU_RESET = 0
					message_time=math.floor(os.clock())  -- used by function AutoClear
					beforestartproc_trigger = 2
					preliminaryprocedure_trigger = 2
					preflightproc_trigger = 2
					afterstartproc_trigger = 2
					takeoffproc_trigger= 3
					approachproc_trigger = 0
					afterlandingproc_trigger = 0
					shutdownproc_trigger = 0
					sched = 1
					genactive_trigger =0
					checklist = 0
					current_time = 0
					windows_opened = 0
					disconnect = 0
					spoilers_played = 0
					reverse_played = 0
					if PLANE_ICAO == "A346" then XPonDr = 2 else XPonDr = 4 end
					Vspeed = -1
					callout_played = 0
					function Message()  message_done = 0
						draw_string( 50, 20, "RESTARTED TO DESCENT STATE", "yellow" ) -- erase any message
					end
					-- DISPLAY VR message
					if GUI_VR_message and vr_message_sent == false then vr_message_sent = true
						show_window_bottom_bar = true call_question = true
						end_show_time = math.floor(os.clock()) + 10
							Message_wnd_content = "RESTARTED TO DESCENT STATE."
						Message_wnd_action = "vr_message_sent = false "
						Message_wnd_duration = 2
						show_the_option_window()
					end
					-- End of VR Message
					if TL_Keep_secondary_sounds == "activate" then  play_sound(CoughSound) end
					A_P = false
					L_P = false
					GA_P = false
					AL_P = false
					P_P = false
					STA_P = false
					reset_VR_message_popup()
				end


				-- inflight restart above FL100
				if ToLissPNFonDuty == 1 and pressurealtitude >= 10001 and (ACP_RESET == 1 or MENU_RESET == 1) then
					function ClickForProcTrigger()
						draw_string(415, 80, "", "grey")
					end
					vr_message_sent = false
					MENU_RESET = 0
					message_time=math.floor(os.clock())  -- used by function AutoClear
					beforestartproc_trigger = 2
					preflightproc_trigger = 2
					afterstartproc_trigger = 2
					takeoffproc_trigger = 3
					preliminaryprocedure_trigger = 2
					approachproc_trigger = 0
					afterlandingproc_trigger = 0
					shutdownproc_trigger = 0
					sched = 0
					genactive_trigger =0
					current_time = 0
					proc_time = 0
					prep_time=0
					air_time_trigger = 0
					air_time = 0
					air_step = 0
					flightcontrols_time = 0
					windows_opened = 0
					disconnect = 0
					BrakeReleasedFlag = false
					if PLANE_ICAO == "A346" then XPonDr = 2 else XPonDr = 4 end
					Vspeed = -1
					function Message()  message_done = 0
						draw_string( 50, 20, "RESTARTED TO CRUIZE STATE", "yellow" ) -- erase any message
					end
					if TL_Keep_secondary_sounds == "activate" then  play_sound(CoughSound) end
					CS_P = false
					DPP_P = false
					D_P = false
					A_P = false
					L_P = false
					GA_P = false
					AL_P = false
					P_P = false
					STA_P = false
					reset_VR_message_popup()
				end
			end -- not SpeedyCopilot_first_load
		end
		do_often("RESTART()")
		--------------------------------------------------------------------------------

		-- initial script loading functions :
		if SpeedyCopilot_Author == "Gliding Kiwi" or SpeedyCopilot_Author == "GlidingKiwi" then
			print("FlyWithLua Info: Speedy Copilot for ToLiSS will load GUI functions.")
			all_menus_definitions()
			print("FlyWithLua Info: Speedy Copilot for ToLiSS has loaded GUI functions.")
			DatarefLoad()
			SupplementaryInit()
			SupplementaryInit2()
			SupplementaryColdDark()
			FF_initial_load = false
		end
	else -- ends aircraft ToLiSS Airbus check
		print("FlyWithLua Info: Speedy Copilot for ToLiSS says it is not a ToLiSS Airbus ! Do nothing then.")
	end -- ends aircraft ToLiSS Airbus check
end -- function SCT_script() for XP12

