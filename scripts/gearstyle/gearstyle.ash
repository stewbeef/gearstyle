//Gear Style -- Gear Manage

//import "maxer.ash";
script "gearstyle.ash";
import "beefy_tools.ash";

///////////////////////
//Records

record gearlist
{
	string name;
	boolean [item] list;
}

////////////////////////////////
//Global Variables
//gear [it] gear_array;
//string gear_file = "gear_array.txt";
int my_gm_logging = 0;


gearlist [string, slot] gearlist_array;
string gearlist_file = "gearlist_array.txt";

////////////////////////////////
//Record Saving
boolean SaveGearLists()
{
	print("Saving gearlist_array");
	return map_to_file(gearlist_array,gearlist_file);
}

////////////////////////////////
//Array Retrieval Functions
gearlist [string, slot] GearList_Array()
{
	if (gearlist_array.count() == 0)
	{
		print("gearlist_array Map is empty, attempting to load from file...");
		if(file_to_map(gearlist_file,gearlist_array))
		{
			if (gearlist_array.count() == 0)
			{
				print("file empty, no gearlist settings found...",my_gm_logging);
			}
			else
			{
				print("loaded gearlist_array settings from file...",my_gm_logging);
			}
		}
		else
		{
			print("Could not load from " + gearlist_file + ", assuming no gearlist_array settings have been made",my_gm_logging);
		}
	}
	return gearlist_array;
}
////////////////////////////////
//Existance
boolean GearStyle_Exists(string grsname)
{
	if(GearList_Array() contains grsname)
	{
		print_html("Existence Check: GearStyle %s exists.",grsname, my_gm_logging);
		return true;
	}
	else
	{
		print_html("Existence Check: GearStyle %s not found.", grsname, my_gm_logging);
		return false;
	}
	return false;
}
boolean GearList_Exists(string grsname, slot slt)
{
	if(GearStyle_Exists(grsname))
	{
		if(GearList_Array()[grsname] contains slt)
		{
			print_html("Existence Check: GearList Name %s and slot %s exists.",string[int]{grsname,slt},my_gm_logging);
			return true;
		}
		else
		{
			print_html("Existence Check: GearList Name %s exists, but not for slot %s", string[int]{grsname,slt},my_gm_logging);
			return false;
		}
	}
	return false;
}
boolean GearList_Exists(gearlist gs)
{
	return GearList_Exists(gs.name, gs.grslot);
}

boolean valid_item(item it)
{
	if(can_equip(it))
	{
		if(item_amount(it) > 0)
		{
			return true;
		}
		else if(have_equipped(it))
		{
			return true;
		}
	}
	return false;
}

////////////////////////////////
//Delete Record Functions
boolean DeleteGearList(string grsname, slot slt)
{
	if(GearList_Exists(grsname, slt))
	{
		remove gearlist_array[grsname,slt];
		SaveGearLists();
	print_html("GearList Deletion: Name: %s, slot: %s", string [int]{grsname,slt},my_gm_logging);
		return true;
	}
	return false;
}
boolean DeleteGearStyle(string grsname)
{
	if(GearStyle_Exists(grsname))
	{
		foreach slt in GearList_Array()[grsname]
		{
			print_html("GearList Deletion: Name: %s, slot: %s", string [int]{grsname,slt},my_gm_logging);
		}
		remove gearlist_array[grsname];
		SaveGearLists();
		print_html("GearStyle Deleted: Name: %s", grsname, my_gm_logging);
		return true;
	}
	return false;
}
///////////////////////
//Gear Pseudo-Properties

slot mySlot(gear gr)
{
	return gr.it.to_slot();
}
string myName(gear gr)
{
	return to_string(gr.it);
}

float myWeight(gear gr)
{
	float wt = gr.weight;
	if(gr.wt_function != "")
	{
		wt += call float (gr.wt_function)(gr);
	}
	return wt;
}

///////////////////////
//Set/Add Gearslot
boolean SetGearList(string gsname, slot slt, string maxer, boolean maxisfunc, int def, int pref, boolean negok, boolean addweight, boolean weightfirst, boolean overwrite)
{
	boolean makethis = false;
	if(GearList_Exists(gsname,slt) && overwrite)
	{
		makethis = true;
		print_html("GearList Set Overwriting Existing: Name: " + gsname + ", slot: " + slt);
	}
	else if(! GearList_Exists(gsname,slt))
	{
		makethis = true;
		print_html("GearList Add: Name: " + gsname + ", slot: " + slt);
	}
	else
	{
		print_html("GearList Add/Set: Name: " + gsname + ", slot: " + slt + " already exists");
	}

	if(makethis)
	{
		gearlist this;
		this.name = gsname;
		if(slt == $slot[none])
		{
			print_html("New Gearslot Error, invalid slot!");
			return false;
		}
		this.grslot = slt;
		this.maximizer = maxer;
		this.maxisfunc = maxisfunc;
		this.failtoinventory_score = def;
		this.preference = pref;
		this.negok = negok;
		this.addweight = addweight;
		this.weightfirst = weightfirst;
		GearList_Array()[gsname,slt] = this;
		SaveGearLists();
		return true;
	}
	return false;

	
}
boolean SetGearList(string name, slot slt, string maxer, boolean maxisfunc, boolean negok, boolean overwrite)
{
	return SetGearList(name, slt, maxer, maxisfunc, 0, 0, negok, false, false, overwrite);
}
boolean SetGearList(string name, slot slt, boolean overwrite)
{
	return SetGearList(name, slt, "", false, 0, 0, false, false, false, overwrite);
}
///////////////////////
//Gearslot Setting
boolean SetGearListParam(string gsname, slot slt, string param, string value)
{
	string switchparam = param.to_lower_case();
	if(GearList_Exists(gsname,slt))
	{
		switch(switchparam)
		{
			case "failtoinventory_score":
				GearList_Array()[gsname,slt].failtoinventory_score = value.to_int();
				break;
			case "preference":
				GearList_Array()[gsname,slt].preference = value.to_int();
				break;
			case "addweight":
				GearList_Array()[gsname,slt].addweight = value.to_boolean();
				break;
			case "failtoinventory":
				GearList_Array()[gsname,slt].failtoinventory = value.to_boolean();
				break;
			case "negok":
				GearList_Array()[gsname,slt].negok = value.to_boolean();
				break;
			case "weightfirst":
				GearList_Array()[gsname,slt].weightfirst = value.to_boolean();
				break;
			case "maxisfunc":
				GearList_Array()[gsname,slt].maxisfunc = value.to_boolean();
				break;
			case "maximizer":
				GearList_Array()[gsname,slt].maximizer = value;
				break;
			default:
				print("Gearslot Param Setting Error: " + param + " is not valid parameter");			
				return false;
		}
		SaveGearLists();
		return true;
	}
	return false;
}
boolean SetGearListParam(gearlist gs, string param, string value)
{
	return SetGearListParam(gs.name, gs.grslot, param, value);
}

///////////////////////
//Add Gear
boolean AddGear(gearlist gs, gear gr)
{
	if (gs.grslot == $slot[none])
	{
		print("Add Gear to Gearslot Error, Gearslot has no defined slot!");
		return false;
	}
	else if (gr.mySlot() == $slot[none])
	{
		print("Add Gear to Gearslot Error, Gear item is not equipment!");
		return false;
	}
	else if (gs.gears contains gr.it)
	{
		print("Add Gear to Gearslot Error, Gear is already added!");
		return false;
	}
	else if (gs.outfit = true)
	{
		print_html("Add Gear to Gearslot Error, slot %s is used for outfit %s!", string[int]{gs.grslot,gs.outfit_name});
	}
	else
	{
		print("Added Gear " + gr.it +  " to Gearslot");
		gs.gears[gr.it] = gr;
		SaveGearLists();
	}
	return true;
}
boolean AddGear(string gsname, slot slt, gear gr)
{
	if(GearList_Exists(gsname, slt))
	{
		AddGear(GearList_Array()[gsname,slt], gr);
		return true;
	}
	return false;
}
boolean AddGear(string gsname, slot slt, item it)
{
	if(GearList_Exists(gsname, slt))
	{
		AddGear(GearList_Array()[gsname,slt], new gear(it));
		return true;
	}
	return false;
}

boolean RemoveGear(gearlist gs, item it)
{
	if (gs.grslot == $slot[none])
	{
		print("Remove Gear from Gearslot Error, Gearslot has no defined slot!");
		return false;
	}
	else if (to_slot(it) == $slot[none])
	{
		print("Remove Gear from Gearslot Error, Gear item is not equipment!");
		return false;
	}
	else if (gs.gears contains it)
	{
		remove gs.gears[it];
		print("Removed Gear from  Gearslot: " + it + " removed from " + "style " + gs.name + " for slot " + gs.grslot);
		SaveGearLists();
		return true;
	}
	else
	{
		print("Remove Gear from Gearslot Error, Gear item: " + it + " is not in " + gs.name);
		return false;
	}
	return false;
}
boolean RemoveGear(gearlist gs, gear gr)
{
	return RemoveGear(gs, gr.it);
}
boolean RemoveGear(string gsname, slot slt, gear gr)
{
	if(GearList_Exists(gsname, slt))
	{
		RemoveGear(GearList_Array()[gsname,slt], gr);
		return true;
	}
	return false;
}
boolean RemoveGear(string gsname, slot slt, item it)
{
	if(GearList_Exists(gsname, slt))
	{
		RemoveGear(GearList_Array()[gsname,slt], it);
		return true;
	}
	return false;
}
///////////////////////
//Set Gear Setting
boolean SetGearParam(string gsname, slot slt, item it, string param, string value)
{
	string switchparam = param.to_lower_case();
	if(GearList_Exists(gsname,slt))
	{
		if(GearList_Array()[gsname,slt].gears contains it)
		{
			switch(switchparam)
			{
				case "weight":
					GearList_Array()[gsname,slt].gears[it].weight = value.to_float();
					break;
				case "pull":
					GearList_Array()[gsname,slt].gears[it].pull = value.to_boolean();
					break;
				case "buy":
					GearList_Array()[gsname,slt].gears[it].buy = value.to_boolean();
					break;
				case "craft":
					GearList_Array()[gsname,slt].gears[it].craft = value.to_boolean();
					break;
				case "wt_function":
					GearList_Array()[gsname,slt].gears[it].wt_function = value;
					break;
				default:
					print("Gear Param Setting Error: " + param + " is not valid parameter");			
					return false;
			}
			SaveGearLists();
			return true;
		}
		else
		{
			print("Gear Param Setting Error: " + it + " is in " + gsname + " for slot " + slt);	
		}
	}
	return false;
}
boolean SetGearParam(gearlist gs, item it, string param, string value)
{
	return SetGearParam(gs.name, gs.grslot, it, param, value);
}
boolean SetGearParam(gearlist gs, string itname, string param, string value)
{
	return SetGearParam(gs.name, gs.grslot, to_item(itname), param, value);
}
boolean SetGearParam(string gsname, slot slt, string itname, string param, string value)
{
	return SetGearParam(gsname, slt, to_item(itname), param, value);
}
boolean SetGearParam(gearlist gs, int itid, string param, string value)
{
	return SetGearParam(gs.name, gs.grslot, to_item(itid), param, value);
}
boolean SetGearParam(string gsname, slot slt, int itid, string param, string value)
{
	return SetGearParam(gsname, slt, to_item(itid), param, value);
}

///////////////////////
//Maximizer functions
string getMaximizerString(string maximizer, string additions)
{
	string maxer;
	if(maximizer == "")
	{
		maxer=additions;
	}
	else
	{
		maxer = maximizer + "," + additions;
	}
	print("getmaxer " + maxer);
	return maxer;
}

gearscore MaximizeSlot(string maxerbase, slot slt)
{
	string maxertest = getMaximizerString(maxerbase,slt.to_string());
	gearscore scored_item;
	scored_item.maximizer = maxertest;
	scored_item.slt = slt;
	print_html("MaximizeSlot evaluation string: ", maxertest, my_gm_logging);
	foreach index,rec in maximize(maxertest,0,0,true,true)
	{
		print_html(rec.display,my_gm_logging);
		
		print_html(rec.item,my_gm_logging);
		if(rec.display.contains_text("equip " + slt))
		{
			print_html(rec.display);	
			scored_item.score =  rec.score;
			scored_item.it = rec.item;
		}
	}

	return scored_item;

}

gearscore MaximizeItem(string maxerbase, item it)
{
	slot myslot = it.to_slot();
	string myname = it.to_string();
	string maxertest = getMaximizerString(maxerbase,"equip " + myname);
	gearscore scored_item =  MaximizeSlot(maxertest, myslot);
	print_html("Item %s has a score of %s", string[int]{it,scored_item.score}, my_gm_logging);
	return scored_item;
}

float [int] myscore(item it, gearlist gs)
{
	float [3] scores;
		//[0] : preference
		//[1] : maximizer score or weight or weight+max score depending on addweight & weightfirst
		//[2] : weight or maximizer score or 0, depending on addweight & weightfirst
	scores[0] = gs.preference;
	gearscore scored_item = MaximizeItem(gs.maximizer,it);
	if(gs.addweight)
	{
		scores[1] = scored_item.score + gs.gears[it].weight;
	}
	else if(gs.weightfirst)
	{
		scores[1] = gs.gears[it].weight;
		scores[2] = scored_item.score;
	}
	else
	{
		scores[1] = scored_item.score;
		scores[2] = gs.gears[it].weight;
	}
	return scores;
}

float [int] myscore(gear gr, gearlist gs)
{
	return myscore(gr.it, gs);
}

///////////////////////
//SelectedGear pseudo-properties and functs

slot myslot(selectedgear sgear)
{
	return sgear.mygslot.grslot;
}
item myitem(selectedgear sgear)
{
	return sgear.mygear.it;
}
int mypref(selectedgear sgear)
{
	return sgear.mygslot.preference;
}

selectedgear EmptySelectedGear(float score)
{
	selectedgear nothing;
	gear nogear;
	nogear.it = $item[none];
	nothing.mygear = nogear;
	nothing.scores = {score,score,score};

	return nothing;
}
selectedgear EmptySelectedGear()
{
	return EmptySelectedGear(0);
}

selectedgear ToSelectedGear(item it, gearlist gs)
{
	selectedgear sgr;
	sgr.mygear = gs.gears[it];
	sgr.mygslot = gs;
	sgr.scores = myscore(it, gs);
	
	return sgr;
}
selectedgear ToSelectedGear(gearscore scored_item, gearlist gs)
{
	selectedgear sgr;
	gear thisgear;
	thisgear.it = scored_item.it;
	sgr.mygear = thisgear;
	sgr.mygslot = gs;
	sgr.scores = {gs.preference,scored_item.score};

	return sgr;
}

///////////////////////
//Compare functions

int CompareGearScore(selectedgear a, selectedgear b, int index)
{
	if(a.scores[index] > b.scores[index])
	{
		return 1;
	}
	else if (a.scores[index] < b.scores[index])
	{
		return -1;
	}
	else
	{
		return 0;
	}
}

selectedgear CompareGear(selectedgear a, selectedgear b)
{
	for index from 0 to 2 by 1
	{
		int compare = CompareGearScore(a,b,index);
		if(compare > 1)
		{
			return a;
		}
		else if(compare < 1)
		{
			return b;
		}
		//if compare == 0, we continue
	}
	//Default to gear a if all equal
	return a;
}

///////////////////////
//SelectedGear functions



///////////////////////
//Gear functions
 





///////////////////////
//Gear Picking
selectedgear ChooseGear(gearlist gs)
{
	selectedgear gearchoice = EmptySelectedGear();
	foreach it in gs.gears
	{
		//print("choosegear for gearlist " + gs.name);
		selectedgear gearoption = ToSelectedGear(it, gs);
		if(gs.negok && gearchoice.mygear.it == $item[none] && valid_item(it))
		{//if negative is ok, then any item is better than the empty one
			gearchoice = gearoption;
		}
		else
		{
			print("choosegear comparing gear");
			gearchoice = CompareGear(gearchoice, gearoption);
		}
	}
	print("Gearchoice score[1]: " + gearchoice.scores[1]);
	if (gearchoice.scores[1] < gs.failtoinventory_score && gs.failtoinventory )
	{
		print("choosegear test failtoinv");
		gearscore chosenitem = MaximizeSlot(gs.maximizer, gs.grslot);
		print_html("Chosen item: %s, for slot: %s", string[int]{chosenitem.it, chosenitem.slt});
		gearchoice = ToSelectedGear(chosenitem, gs);
		print_html("Chosen item: %s, for slot: %s", string[int]{gearchoice.myitem(), chosenitem.slt});
	}

	return gearchoice;
}


///////////////////////
//Style Picking
selectedstyle UpdateStyle(selectedstyle mystyle, string newstyle)
{
	print("Updating Items to equip for style: " + newstyle);
	if(GearStyle_Exists(newstyle))
	{
		foreach slt in $slots[]
		{
			print("Checking for suggestions for slot " + slt + "...", my_gm_logging);
			if(GearList_Array()[newstyle] contains slt)
			{
				print("looking at gear for slot " + slt);
				selectedgear gearoption = ChooseGear(GearList_Array()[newstyle, slt]);
				print_html("Picked gear %s for slot %s", string[int]{gearoption.myitem(),slt});
				if(gearoption.mygear.it == $item[none])
				{
					print("No gear in style selected. No changes made.");
					//do nothing
				}
				else if (mystyle.equipment contains slt)
				{
					print("Comparing options....");
					print("Existing choice: " + mystyle.equipment[slt] + " verses " + gearoption.myitem());
					mystyle.equipment[slt] = CompareGear(mystyle.equipment[slt], gearoption);
				}
				else
				{
					print("Choosing " + gearoption.myitem() + " by default");
					mystyle.equipment[slt] = gearoption;
				}
			}
		}
	}
	return mystyle;
}
boolean EquipGear(selectedgear sgr)
{
	if(equipped_item(sgr.myslot()) != sgr.myitem())
	{
		equip(sgr.myslot(),sgr.myitem());
		print("Equipping item: " + sgr.myitem() + " in slot " + sgr.myslot());
		return true;
	}
	return false;
}

void EquipStyle(selectedstyle mystyle)
{
	foreach slt in mystyle.equipment
	{
		string [int] vars;
		vars[0] = mystyle.equipment[slt].myitem();
		vars[1] = slt;
		EquipGear(mystyle.equipment[slt]);
	}
}
void VoidEquip()
{
	selectedstyle mystyle;
	foreach s in $slots[]
	{
		equip(s,$item[none]);
	}
}
void EquipStyles(boolean [string] styles)
{
	selectedstyle mystyle;
	foreach s in styles
	{
		UpdateStyle(mystyle, s);
	}
	EquipStyle(mystyle);
}
void EquipStyles(string [int] styles)
{
	selectedstyle mystyle;
	for i from 0 to styles.count() - 1 by 1
	{
		print("Working on style " + styles[i] + "....", my_gm_logging);
		UpdateStyle(mystyle, styles[i]);
	}
	EquipStyle(mystyle);
}



////////////////////////////////
//Print Records
void Print_Gear(gear gr)
{
	print("\t********************");
	print("\tGear: " + gr.it);
	if(gr.weight != 0)
	{
		print("\tWeight: " +  gr.weight);
	}
	if(gr.wt_function != "")
	{
		print("\tWeight Function: " + gr.wt_function);
	}
	if(gr.pull == true)
	{
		print("\tPull if Possible");
	}
	if(gr.buy == true)
	{
		print("\tBuy if Possible");
	}
	if(gr.craft == true)
	{
		print("\tCraft if Possible");
	}
	print("\t********************");
}
void Print_GearList(gearlist gs)
{
	if(GearList_Exists(gs.name, gs.grslot))
	{
		print("=============================");
		print_html("Gearslot Name: %s, for slot: %s", string [int] {gs.name.to_string(),gs.grslot.to_string()});
		//boolean [string] testy = $strings[gs.name.to_string(),gs.grslot.to_string()];
		print_html("Preference: %s", gs.preference);
		if(gs.failtoinventory)
		{
			print_html("Fail to Inventory Score: %s", to_string(gs.failtoinventory_score));
		}
		print("Add Weight to Maximizer Score: " + gs.addweight);
		if(! gs.addweight)
		{
			print_html("Consider Weight before Maximizer Score: %s", gs.weightfirst);
		}
		print_html("Equip Negative Maximizer Score Items if Highest: %s", gs.negok);
		foreach it in gs.gears
		{
			Print_Gear(gs.gears[it]);
		}
		if(gs.maximizer != "" && gs.maxisfunc)
		{
			print_html("Maximizer is a Function: %s", gs.maximizer);
		}
		else if(gs.maximizer != "")
		{
			print_html("Maximizer String: %s", gs.maximizer);
		}
		print("=============================");
	}
}
void Print_GearList(string gsname, slot slt)
{
	if(GearList_Exists(gsname,slt))
	{
		Print_GearList(GearList_Array()[gsname,slt]);
	}
}

void Print_GearStyle(string gsname)
{
	if(GearStyle_Exists(gsname))
	{
		foreach slt in GearList_Array()[gsname]
		{
			Print_GearList(GearList_Array()[gsname,slt]);
		}
	}	
}

void Print_GearStyles()
{
	foreach gsname in GearList_Array()
	{
		print("=============================");
		print("=============================");
		print_html("Gear Slot Style: %s",gsname);
		print("=============================");
		Print_GearStyle(gsname);
	}
}
////////////////////////////////
//Command Parsing
void Parse_Gear_Command(string command)
{
	string [int] command_array = split_string(command,",");
	slot gslot;
	item it;
	int paramnum = command_array.count();
		switch(command_array[0])
	{
		case "help":
		case "?":
		case "HELP":
		case "":
			print("Help Text to be here");
			//Page().PageSetTitle("SetVenture.ash Help");
			//PageWrite(__venture_helptext);
			break;
		case "add gearlist":
		case "ags":
			gslot = to_slot(command_array[2]);
			switch(paramnum)
			{
				case 3:
					SetGearList(command_array[1],gslot,false);
					break;
				case 6:
					boolean maxisfunc = to_boolean(command_array[4]);
					boolean negok = to_boolean(command_array[5]);
					SetGearList(command_array[1],gslot,command_array[3],maxisfunc, negok, false);
					break;
			}
			break;
		case "set gearlist":
		case "sgs":
			gslot = to_slot(command_array[2]);
			switch(paramnum)
			{
				case 3:
					SetGearList(command_array[1],gslot,true);
					break;
				case 6:
					boolean maxisfunc = to_boolean(command_array[4]);
					boolean negok = to_boolean(command_array[5]);
					SetGearList(command_array[1],gslot,command_array[3],maxisfunc, negok, true);
					break;
			}
			break;
		case "add outfit":

			break;
		case "remove gearlist":
		case "rgslot":
		case "-gslot":
			gslot = to_slot(command_array[2]);
			DeleteGearList(command_array[1],gslot);
			break;
		case "remove gearstyle":
		case "rgstyle":
		case "-gstyle":
			DeleteGearStyle(command_array[1]);
			break;
		//Parameter Commands
		case "add gear to gearlist":
		case "add gear":
		case "agr":
			gslot = to_slot(command_array[2]);
			it;
			if(command_array[3].is_integer())
			{
				it = to_item(to_int(command_array[3]));
			}
			else
			{
				it = to_item(command_array[3]);
			}
			AddGear(command_array[1], gslot,it);
			Print_GearList(command_array[1],gslot);
			break;
		case "remove gear from gearlist":
		case "remove gear":
		case "rgr":
			gslot = to_slot(command_array[2]);
			it;
			if(command_array[3].is_integer())
			{
				it = to_item(to_int(command_array[3]));
			}
			else
			{
				it = to_item(command_array[3]);
			}
			RemoveGear(command_array[1], gslot,it);
			Print_GearList(command_array[1],gslot);
			break;
		case "set gearlist parameter":
		case "set gsparam":
		case "sgsp":
			gslot = to_slot(command_array[2]);
			SetGearListParam(command_array[1], gslot,command_array[3],command_array[4]);
			Print_GearList(command_array[1],gslot);
			break;
		case "set gear parameter":
		case "set grparam":
		case "sgrp":
			gslot = to_slot(command_array[2]);
			it;
			if(command_array[3].is_integer())
			{
				it = to_item(to_int(command_array[3]));
			}
			else
			{
				it = to_item(command_array[3]);
			}
			SetGearParam(command_array[1], gslot,it,command_array[4],command_array[5]);
			Print_GearList(command_array[1],gslot);
			break;
		case "show":
		case "print":
			Print_GearStyles();
			break;
		case "voidgear":
		case "void gear":
		case "void equip":
		case "voidequip":
		case "void":
			VoidEquip();
			break;
		case "equip":
			string [int] thesestyles = split_string(command_array[1],"/");
			EquipStyles(thesestyles);
			break;
		default:
			print("\"" + command + "\" is an unrecognized command");
			//PageWrite(__venture_helptext);
			break;
	}
}

void main(string command)
{
	Parse_Gear_Command(command);
}