//Maximize2-- uses Maximizer

script "maximize2.ash";

import "beefy_tools.ash";
import "gearlist.ash";

///////////////////////
//Records

record maximize2
{
	string name; //name of maximizer
	string [int] exp_array; //array of elements used in maximizer
	string [slot] pref_gear; //preferred gear, via gearlist for each slot
	boolean [slot] my_slots;
	/*new commands for maxer list...
	list: gear lists can be specified with [slot]list commands
		hatlist <name> - specifies hat list
		weaponlist <name> - specifies weapon list
		off-handlist <name> - specifies off-hand list
		pantslist <name> - specifies pants list
		shirtlist <name> - shirt list
		backlist <name> - back list
		acclist <name> - specifies list for all accessories

		Works by identifying highest int entry in specified gearlist
		where you have at least one of the items in your inventory.
		Then for each item at that level you have, adds "equip <item>"
		Replacing the xlist <name> entry with this list of equips.

	TBD
		dodge: uses my_location() to determine minimum moxie (or if using shield, str) to dodge all attacks
		Only works against non-scaling zones
	*/
};

record max2_style
{
	string name;
	boolean [string] maxers;
};

////////////////////////////////
//Global Variables
int beefy_logging() = get_property("beefy_logging").to_int();

gearlist [string, slot] gearlist_array;
string gearlist_file = "gearlist_array.txt";

maximize2 [string] maximize2_array;
string maximize2_file = "maximize2_array.txt";

max2_style [string] max2_style_array;
string max2_style_file = "max2_style_array.txt";

////////////////////////////////
//Record Saving

boolean SaveMaximize2()
{
	print("Saving maximize2_array");
	return map_to_file(maximize2_array,maximize2_file);
}

boolean SaveMax2_Style()
{
	print("Saving max2_style_array");
	return map_to_file(max2_style_array,max2_style_file);
}

////////////////////////////////
//Array Retrieval Functions

maximize2 [string] Maximize2_Array()
{
	if (maximize2_array.count() == 0)
	{
		print("maximize2_array Map is empty, attempting to load from file...");
		if(file_to_map(maximize2_file,maximize2_array))
		{
			if (maximize2_array.count() == 0)
			{
				log_print("file empty, no maximize2 settings found...");
			}
			else
			{
				log_print("loaded maximize2_array settings from file...");
			}
		}
		else
		{
			log_print("Could not load from " + maximize2_file + ", assuming no maximize2_array settings have been made");
		}
	}
	return maximize2_array;
}

max2_style [string] Max2_Style_Array()
{
	if (max2_style_array.count() == 0)
	{
		print("max2_style_array Map is empty, attempting to load from file...");
		if(file_to_map(max2_style_file,max2_style_array))
		{
			if (max2_style_array.count() == 0)
			{
				log_print("file empty, no max2_style settings found...");
			}
			else
			{
				log_print("loaded max2_style_array settings from file...");
			}
		}
		else
		{
			log_print("Could not load from " + max2_style_file + ", assuming no max2_style_array settings have been made");
		}
	}
	return max2_style_array;
}

////////////////////////////////
//Existance
	////////////////////////////////
	//Maximize2

		boolean Maximize2_Exists(string mxname)
		{
			if(Maximize2_Array() contains mxname)
			{
				print_html("Existence Check: Maximize2 Name %s exists.",mxname, beefy_logging());
				return true;
			}
			else
			{
				print_html("Existence Check: Maximize2 Name %s not found.", mxname, beefy_logging());
				return false;
			}
			return false;
		}

	////////////////////////////////
	//Max2_Style

		boolean Max2_Style_Exists(string max2_style_name)
		{
			if(Max2_Style_Array() contains max2_style_name)
			{
				print_html("Existence Check: Max2 Style Name %s exists.",max2_style_name, beefy_logging());
				return true;
			}
			else
			{
				print_html("Existence Check: Max2 Style Name %s not found.", max2_style_name, beefy_logging());
				return false;
			}
			return false;
		}

////////////////////////////////
//Delete Record Functions
	////////////////////////////////
	//Maximize2 Delete
		boolean Delete_Maximize2(string mxname)
		{
			if(Maximize2_Exists(mxname))
			{
				remove maximize2_array[mxname];
				SaveMaximize2();
				print_html("Maximize2 Deleted: Name: %s", mxname, beefy_logging());
				return true;
			}
			return false;
		}
	////////////////////////////////
	//Max2_Style Delete
		boolean Delete_Max2_Style(string max2_style_name)
		{
			if(Max2_Style_Exists(max2_style_name))
			{
				remove Max2_Style_Array[max2_style_name];
				SaveMax2_Style();
				print_html("Max2 Style Deleted: Name: %s", max2_style_name, beefy_logging());
				return true;
			}
			return false;
		}


///////////////////////
//Set maximize2

	///////////////////////
	//Set maximize2 helpers
		maximize2 _Maximize2_Parse_Exp(string [int] exp_array)
		{
			maximize2 my_max2;
			boolean [slot] my_pos_slots;
			boolean [slot] my_neg_slots;
			string [int] new_array;
			foreach num in exp_array
			{
				switch(exp_array[num])
				{
					case "+hat":
					case "hat":
						my_pos_slots[$slot[hat]] = true;
						break;
					case "-hat":
						my_neg_slots[$slot[hat]] = true;
						break;
					case "+back":
					case "back":
						my_pos_slots[$slot[back]] = true;
						break;
					case "-back":
						my_neg_slots[$slot[back]] = true;
						break;
					case "+weapon":
					case "weapon":
						my_pos_slots[$slot[weapon]] = true;
						break;
					case "-weapon":
						my_neg_slots[$slot[weapon]] = true;
						break;
					case "+off-hand":
					case "off-hand":
						my_pos_slots[$slot[off-hand]] = true;
						break;
					case "-off-hand":
						my_neg_slots[$slot[off-hand]] = true;
						break;
					case "+shirt":
					case "shirt":
						my_pos_slots[$slot[shirt]] = true;
						break;
					case "-shirt":
						my_neg_slots[$slot[shirt]] = true;
						break;
					case "+pants":
					case "pants":
						my_pos_slots[$slot[pants]] = true;
						break;
					case "-pants":
						my_neg_slots[$slot[pants]] = true;
						break;
					case "+acc1":
					case "acc1":
						my_pos_slots[$slot[acc1]] = true;
						break;
					case "-acc1":
						my_neg_slots[$slot[acc1]] = true;
						break;
					case "+acc2":
					case "acc2":
						my_pos_slots[$slot[acc2]] = true;
						break;
					case "-acc2":
						my_neg_slots[$slot[acc2]] = true;
						break;
					case "+acc3":
					case "acc3":
						my_pos_slots[$slot[acc3]] = true;
						break;
					case "-acc3":
						my_neg_slots[$slot[acc3]] = true;
						break;
					case "+familiar":
					case "familiar":
						my_pos_slots[$slot[familiar]] = true;
						break;
					case "-familiar":
						my_neg_slots[$slot[familiar]] = true;
						break;
					default:
						new_array[new_array.count()] = exp_array[num];
				}
			}
			if(my_pos_slots.count() > 0 && my_neg_slots.count() > 0)
			{
				print_html("Invalid maximize string, positive and negative item weights mixed");
			}
			else if(my_pos_slots.count() > 0)
			{
				my_max2.my_slots = my_pos_slots;
			}
			else if(my_neg_slots.count() > 0)
			{
				foreach slt in norm_slots()
				{
					if (! (my_neg_slots contains slt))
					{
						my_max2.my_slots[slt] = true;
					}
				}
			}
			my_max2.exp_array = new_array;
			return my_max2;
		}

	///////////////////////
	//Main Set Maximize2
		void SetMaximize2(string name, string [int] exp_array, boolean change_exp, boolean change_slots)
		{
			maximize2 my_max2 = _Maximize2_Parse_Exp(exp_array);
			if(Maximize2_Exists(name) && (change_exp || change_slots))
			{
				if(change_exp)
				{
					print_html("Setting Maximize2 %s expression to %s", string [int] {name, my_max2.exp_array.concat(",")});
					Maximize2_Array()[name].exp_array = my_max2.exp_array;
				}
				if(change_slots)
				{
					print_html("Setting Maximize2 %s slots to %s", string [int] {name, my_max2.my_slots.concat(",")});
					Maximize2_Array()[name].my_slots = my_max2.my_slots;
				}
				SaveMaximize2();
			}
			else if (!Maximize2_Exists(name))
			{
				print_html("Creating New Maximize2 %s expression to %s", string [int] {name, my_max2.exp_array.concat(",")});
				print_html("With slots: %s", my_max2.my_slots.concat(","));
				Maximize2_Array()[name] = my_max2;
				SaveMaximize2();
			}
			else
			{
				print_html("Maximize2 %s already exists and not set to overide.  No change made", name);
			}
		}
		void SetMaximize2(string name, string exp, boolean change_exp, boolean change_slots)
		{
			SetMaximize2(name, exp.split_string(","), change_exp, change_slots);
		}
		void SetMaximize2(string name, string exp)
		{
			SetMaximize2(name, exp.split_string(","), true, true);
		}
		void SetMaximize2(string name, string [int] exp_array)
		{
			SetMaximize2(name, exp_array, true, true);
		}

		void SetMaximize2Slots(string name, string [int] exp_array)
		{
			SetMaximize2(name, exp_array, false, true);
		}
		void SetMaximize2Slots(string name, string exp)
		{
			SetMaximize2(name, exp.split_string(","), false, true);
		}

		void SetMaximize2Exp(string name, string [int] exp_array)
		{
			SetMaximize2(name, exp_array, true, false);
		}
		void SetMaximize2Exp(string name, string exp)
		{
			SetMaximize2(name, exp.split_string(","), true, false);
		}

		void SetMaximize2GearList(string name, string gl_name, slot slt)
		{
			if(Maximize2_Exists(name) && GearListSlot_Exists(gl_name, slt))
			{
				print_html("Setting Maximize2 %s gearlist for slot %s to %s", string [int] {name, slt.to_string(), gl_name});
				Maximize2_Array()[name].pref_gear[slt] = gl_name;
				SaveMaximize2();
			}
			else if (!Maximize2_Exists(name))
			{
				print_html("Can't set Maximize2 gearlist, Maximize2 value does not exist");
			}
			else
			{
				print_html("Can't set Maximize2 gearlist, gearlist value does not exist");
			}
		}

	///////////////////////
	//Set Max2_Style
		void SetMax2_Style(string name, boolean [string] maxers, boolean override)
		{
			if(Max2_Style_Exists(name) && override)
			{
				print_html_list("Setting Max2 Style %s maximize2 list to %s", name, maxers.BooleanStringToStringArray());
				string [slot] slottests;
				foreach max2 in maxers
				{
					if(Maximize2_Exists(max2))
					{
						foreach slt in Maximize2_Array()[max2].my_slots
						{
							if(slottests[slt] != "")
							{
								print_html("SetMax2_Style failed for style %s, maximize2 %s and %s share at least one slot", string[int]{name,max2,slottests[slt]});
								abort("Error, see above");
							}
							else
							{
								slottests[slt] = max2;
							}
						}
					}
					else
					{
						print_html("Failed to create/modify Max2_Style %s, because maximize2 %s does not exist", string[int]{name,max2});
					}
				}
				Max2_Style_Array()[name].maxers = maxers;
				SaveMax2_Style();
			}
			else if (!Max2_Style_Exists(name))
			{
				print_html("Creating New Max2 Style %s maximize2 list to %s", name, maxers.BooleanStringToStringArray());
				Max2_Style_Array()[name] = new max2_style();
				Max2_Style_Array()[name].maxers = maxers;
				SaveMax2_Style();
			}
			else
			{
				print_html("Max2 Style %s already exists and not set to overide.  No change made", name);
			}
		}
		void SetMax2_Style(string name, boolean [string] maxers)
		{
			SetMax2_Style(name, maxers, true);
		}
		void SetMax2_Style(string name, string [int] maxers, boolean override)
		{
			SetMax2_Style(name, maxers.StringInt2BooleanString(), override);
		}
		void SetMax2_Style(string name, string [int] maxers)
		{
			SetMax2_Style(name, maxers.StringInt2BooleanString(), true);
		}
		///////////////////////
		//Helper Functions 

			///////////////////////
			//maximize2
		string to_exp(maximize2 max2)
		{
			buffer exp_buffer;
			exp_buffer.append(max2.exp_array.concat(","));
			exp_buffer.append(",");
			exp_buffer.append(max2.my_slots.concat(","));
			return exp_buffer.to_string();
		}

		boolean [slot] my_acc_slots(maximize2 max2)
		{
			boolean [slot] accslots;

			foreach slt in max2.my_slots
			{
				if(slt == $slot[acc1] || slt == $slot[acc2] || slt == $slot[acc3])
				{
					accslots[slt] = true;
				}
			}
			return accslots;
		}

		maximize2 copy(maximize2 max2)
		{
			maximize2 copy;
			foreach slt in max2.my_slots
			{
				copy.my_slots[slt] = true;
			}
			
			for num from 0 to max2.exp_array.count() -1 by 1
			{
				copy.exp_array[num] = max2.exp_array[num];
			}

			foreach slt in max2.pref_gear
			{
				copy.pref_gear[slt] = max2.pref_gear[slt];
			}

			return copy;
		}

///////////////////////
//Equip maximize2

	///////////////////////
	//Equip Records
		record max2_slot_list
		{
			int size;
			boolean [item] mustequip;
			boolean [item] tomax;
		};

		record max2_equip_list
		{
			item [slot] equip_list;
			string [int] max2_list;
		};

		int count(max2_slot_list mylist)
		{
			return mylist.tomax.count() + mylist.mustequip.count();
		}

	///////////////////////
	//Add Choices

		max2_slot_list addchoices(max2_slot_list slist, boolean [item] candidates)
		{
			boolean [item] owned_candidates;
			foreach it in candidates
			{
				if(item_amount(it) > 0)
				{
					owned_candidates[it] = true;
				}
			}
			if(owned_candidates.count() > 0 && slist.count() < slist.size)
			{
				if ((slist.mustequip.count() + owned_candidates.count() < slist.size) && slist.tomax.count() == 0)
				{
					foreach it in owned_candidates
					{
						slist.mustequip[it] = true;
					}
				}
				else if(slist.tomax.count() + owned_candidates.count() < slist.size)
				{
					foreach it in owned_candidates
					{
						slist.tomax[it] = true;
					}
				}
				//add tertiary
			}
			return slist;
		}

	///////////////////////
	//Equip: Get Equip Lists

		max2_slot_list Get_Max2_Slot_List(gearchoices prefs, maximize2 max2)
		{
			print_html("Generating Max2 Slot list for gearchoice %s", prefs.name);
			max2_slot_list my_slot_list;
			if(prefs.myslot == $slot[acc1])
			{
				my_slot_list.size = max2.my_acc_slots().count();
			}
			else
			{
				my_slot_list.size = 1;
			}
			foreach index in prefs.list
			{
				my_slot_list = my_slot_list.addchoices(GearList_Array()[prefs.list[index],prefs.myslot].list);
			}

			return my_slot_list;
		}

		max2_equip_list get_max2_equip(maximize2 max2, max2_equip_list my_list)
		{
			maximize2 temp = max2.copy();
			boolean [string] equip_strings; //there should be no duplicates
			foreach slt in max2.pref_gear
			{
				string gcs = max2.pref_gear[slt];
				
				if(GearChoiceSlot_Exists(gcs, slt))
				{
					max2_slot_list slt_list = Get_Max2_Slot_List(GearChoices_Array()[gcs,slt],max2);
					int size = slt_list.size;
					slot [int] accslots = max2.my_acc_slots().BooleanSlotToArray();
					
					foreach it in slt_list.mustequip
					{
						switch(size)
						{
							case 1:
								if(slt == $slot[acc1])
								{
									slot this_slot = accslots[0];
									my_list.equip_list[this_slot] = it;
									temp.my_slots[this_slot] = false;
								}
								else
								{
									my_list.equip_list[slt] = it;
									temp.my_slots[slt] = false;
								}
								size--;
							break;
							case 2:
								if(slt == $slot[acc1])
								{
									slot this_slot = accslots[1];
									my_list.equip_list[this_slot] = it;
									temp.my_slots[this_slot] = false;
									size--;
								}
								else
								{
									print_html("Max2 Equip Error, slot %s is not acc1", slt);
								}
							break;
							case 3:
								if(slt == $slot[acc1])
								{
									slot this_slot = accslots[2];
									my_list.equip_list[this_slot] = it;
									temp.my_slots[this_slot] = false;
									size--;
								}
								else
								{
									print_html("Max2 Equip Error, slot %s is not acc1", slt);
								}
							break;
						}
					}
					foreach it in slt_list.tomax
					{
						if(size > 0)
						{
							equip_strings["equip " + it.to_string()] = true;
						}
					}
				}
			}
			buffer maxer_exp;
			maxer_exp.append(temp.to_exp());
			maxer_exp.append(",");
			maxer_exp.append(equip_strings.concat(","));
			my_list.max2_list[my_list.max2_list.count()] = maxer_exp.to_string();

			return my_list;
		}

		max2_equip_list get_max2_equip(string maxername, max2_equip_list my_list)
		{
			max2_equip_list my_equip_list;
			if(Maximize2_Exists(maxername))
			{
				maximize2 max2 = Maximize2_Array()[maxername];
				my_equip_list = get_max2_equip(max2, my_list);

			}
			else
			{
				print_html("Maximize2 Get Equip error, Maximize2 %s does not exist", maxername);
			}
			return my_equip_list;
		}

		max2_equip_list get_max2_equip(string maxername)
		{
			max2_equip_list my_max2_list;
			return get_max2_equip(maxername, my_max2_list);
		}
		max2_equip_list get_max2_equip(maximize2 maxer)
		{
			max2_equip_list my_max2_list;
			return get_max2_equip(maxer, my_max2_list);
		}


	///////////////////////
	//Equip: Equip (including style equip)
		boolean maxer2_equip(boolean [string] maxernames, boolean test)
		{
			max2_equip_list my_list;
			boolean success = true;
			foreach mxr2name in maxernames
			{
				my_list = get_max2_equip(mxr2name, my_list);
			}
			
			foreach slt in my_list.equip_list
			{
				if(test)
				{
					print_html("Equip %s in slot %s", string [int] {my_list.equip_list[slt], slt.to_string()});
					//print_html("Equip %s...", my_list.equip_list[slt]);
					//print_html("...in slot %s", slt.to_string());
				}
				else
				{
					success = success & equip(slt,my_list.equip_list[slt]);
				}
			}
			foreach num in my_list.max2_list
			{
				if(test)
				{
					print("test");
					print("max " + my_list.max2_list[num]);
					foreach index,rec in maximize(my_list.max2_list[num], 0, 0, true, test)
					{
						print(rec.display);
					}
				}
				else
				{
					success = success & maximize(my_list.max2_list[num], test);
				}
				
			}
			return success;
		}
	///////////////////////
	//Equip: Equip Style
		boolean max2_style_equip(max2_style m_style, boolean test)
		{
			print_html("Equipping gear for Maximize2 Style %s", m_style.name);
			return maxer2_equip(m_style.maxers, test);
		}
		boolean max2_style_equip(max2_style m_style)
		{
			return max2_style_equip(m_style, false);
		}

		boolean max2_style_equip(string m_style_name, boolean test)
		{
			if(Max2_Style_Exists(m_style_name))
			{
				print_html("Equipping gear for Maximize2 Style %s", m_style_name);
				return maxer2_equip(Max2_Style_Array()[m_style_name].maxers, test);
			}
			else
			{
				print_html("Max2Style Equip error, Max2Style %s does not exist", m_style_name);
			}
			return false;
		}
		boolean max2_style_equip(string m_style_name)
		{
			return max2_style_equip(m_style_name, false);
		}
	///////////////////////
	//Equip: Equip Max2
		boolean max2_equip(maximize2 maxer, boolean test)
		{
			print_html("Equipping gear for Maximize2 %s", maxer.name);
			boolean [string] maxer_array;
			maxer_array[maxer.name] = true;
			return maxer2_equip(maxer_array, test);
		}
		boolean max2_equip(maximize2 maxer)
		{
			return max2_equip(maxer, false);
		}
		boolean max2_equip(string maxername, boolean test)
		{
			if(Maximize2_Exists(maxername))
			{
				print_html("Equipping gear for Maximize2 %s", maxername);
				boolean [string] maxer_array;
				maxer_array[maxername] = true;
				return maxer2_equip(maxer_array, test);
			}
			else
			{
				print_html("Maximize2 Equip error, Maximize2 %s does not exist", maxername);
			}
			return false;
		}
		boolean max2_equip(string maxername)
		{
			return max2_equip(maxername, false);
		}

///////////////////////
//Print Functions
	///////////////////////
	//Print Maximize 2
void print_max2(maximize2 maxer)
{
	print_html("<font size=\"+1\"><u>Maximize2 %s's Settings</u></font>",maxer.name);
	print_html("Base Expression: %s",maxer.exp_array.concat(","));
	print_html("Slots: %s",maxer.my_slots.concat(","));
	foreach grc in maxer.pref_gear
	{
		print_gearchoices(grc);
	}
}
void print_max2(string maxername)
{
	if(Maximize2_Exists(maxername))
	{
		print_max2(Maximize2_Array()[maxername]);
	}
	else
	{
		print_html("Maximize2 Printing Error, %s not found", maxername);
	}
}
void print_max2_all()
{
	foreach name in Maximize2_Array()
	{
		print_max2(Maximize2_Array()[name]);
	}
}
	///////////////////////
	//Print Max2_Style
void print_max2_style(max2_style mstyle)
{
	print_html("<font size=\"+2\"><u>Maximize2 %s's Settings</u></font>",mstyle.name);
	foreach max2 in mstyle.maxers
	{
		print_max2(max2);
	}
}
void print_max2_style(string mstylename)
{
	if(Max2_Style_Exists(mstylename))
	{
		print_max2(Max2_Style_Array()[mstylename]);
	}
	else
	{
		print_html("Max2 Style Printing Error, %s not found", mstylename);
	}
}
void print_max2_style_all()
{
	foreach name in Max2_Style_Array()
	{
		print_max2(Max2_Style_Array()[name]);
	}
}

///////////////////////
//Parsing Command Line
void maximize2_parse(string command)
{
	string [int] command_array = split_string(command,",");
	int paramnum = command_array.count();

	string [int] subarray; //for array additions

	switch(command_array[0].to_lower_case())
	{
	//General Commands
		case "help":
		case "?":
			print("Help Text");
			//Gear List Commands
				print_html("<font size=\"+1\"><b><u>Gearlist Commands</u></b></font>");
				print_html("<b>*</b> Add gearlist: [cmd],[name],[slot],[item1],[item2],...");
				print_html("...[cmd]: %s or %s or %s", string[int]{"+gearlist","new gearlist","new gl","+gl"});
				print_html("...to overwrite [cmd]: %s or %s or %s", string[int]{"rewrite gearlist","rw gearlist","rw gl"});

				print_html("<b>*</b> Add item to gearlist: [cmd],[name],[slot],[item]");
				print_html("...[cmd]: %s or %s or %s or %s", string[int]{"+gear to list","add to gearlist","+gear2list","+g2l"});

				print_html("<b>*</b> Remove gearlist: [cmd],[name](,slot(,item))");
				print_html("...[cmd]: %s or %s or %s", string[int]{"remove gearlist","rm gearlist"});
				print_html("...removes entire gearlist, slot, or just an item");

				print_html("<b>*</b> Print gearlist: [cmd],(name(,slot))");
				print_html("...[cmd]: %s or %s", string[int]{"remove gearlist","rm gearlist"});
				print_html("...print all gearlists, all slots for a gearlist name, for a slot");
			//Maximize2 Commands
				print_html("<font size=+1><b><u>Maximize2 Commands</u></b></font>");
				print_html("<b>*</b> Add Maximize2: [cmd],[name],[gearchoice1],[gearchoice2],...");
				print_html("...[cmd]: %s or %s or %s or %s", string[int]{"+maximize2","new max2","new maximize2","+maximize2"});
				print_html("...to overwrite [cmd]: %s or %s or %s", string[int]{"rewrite maximize2","rw maximize2","rw max2"});

				print_html("<b>*</b> Rewrite Maximize2 Slots: [cmd],[name],[slot1],[slot2]...");
				print_html("...[cmd]: %s or %s or %s or %s or %s", string[int]{"rewrite maximize2 slots","rw maximize2 slots","rw max2 slots","rw m2 slots","rw m2slots"});
				
				print_html("<b>*</b> Rewrite Maximize2 Expression: [cmd],[name],[term1],[term2]...");
				print_html("...[cmd]: %s or %s or %s or %s or %s", string[int]{"rewrite maximize2 expression","rw maximize2 exp","rw max2 exp","rw m2 exp","rw m2exp"});

				print_html("<b>*</b> Remove Maximize2: [cmd],[name]");
				print_html("...[cmd]: %s or %s", string[int]{"remove maximize2","rm max2"});
				print_html("...removes entire Maximize2");

				print_html("<b>*</b> Print Maximize2: [cmd],(name)");
				print_html("...[cmd]: %s or %s", string[int]{"print maximize2","print max2"});
				print_html("...print all Maximize2s or named Maximize2");

			//Max2Style Commands
				print_html("<font size=+1><b><u>Max2 Style Commands</u></b></font>");
				print_html("<b>*</b> Add Max2 Style: [cmd],[name],[gearchoice1],[gearchoice2],...");
				print_html("...[cmd]: %s or %s or %s or %s or %s or %s", string[int]{"+max2 style","+max2style","+m2style","new max2 style","new max2style","new m2style"});
				print_html("...to overwrite [cmd]: %s or %s or %s", string[int]{"rw max2 style","rw max2style","rw m2style"});

				print_html("<b>*</b> Remove Max2 Style: [cmd],[name]");
				print_html("...[cmd]: %s or %s", string[int]{"remove max2style","rm m2style"});
				print_html("...removes entire Max2 Style");

				print_html("<b>*</b> Print Max2 Style: [cmd],(name)");
				print_html("...[cmd]: %s or %s", string[int]{"print max2 style","print max2style","print m2style"});
				print_html("...print all Max2 Styles or named Max2 Style");

			//Equip Commands
				print_html("<font size=+1><b><u>Equip Commands</u></b></font>");
			break;
	//Gear List Commands
		case "+gearlist":
		case "new gearlist":
		case "new gl":
		case "+gl":
			subarray = command_array.FromX(3);
			SetGearList(command_array[1],command_array[2],subarray.StringInt2BooleanString(),false);
			break;
		case "rewrite gearlist":
		case "rw gearlist":
		case "rw gl":
			subarray = command_array.FromX(3);
			SetGearList(command_array[1],command_array[2],subarray.StringInt2BooleanString());
			break;
		case "+gear to list":
		case "add to gearlist":
		case "+gear2list":
		case "+g2l":
			AddGearToList(command_array[1], command_array[2], command_array[3]);
			break;
		case "remove gearlist":
		case "rm gearlist":
			switch(paramnum)
			{
				case 2:
					Delete_GearListName(command_array[1]);
					break;
				case 3:
					Delete_GearListSlot(command_array[1],command_array[2]);
					break;
				case 4:
					Delete_GearListSlotItem(command_array[1],command_array[2],command_array[3]);
					break;
			}
			break;
		case "print gearlist":
		case "print gl":
			switch(paramnum)
			{
				case 1:
					print_gearlist_all();
					break;
				case 2:
					print_gearlist(command_array[1]);
					break;
				case 3:
					print_gearlist(command_array[1],command_array[2]);
					break;
			}
			break;
	//Maximize2 Commands
		case "+maximize2":
		case "new max2":
		case "new maximize2":
		case "+max2":
			subarray = command_array.FromX(2);
			SetMaximize2(command_array[1],subarray,false,false);
			break;
		case "rewrite maximize2":
		case "rw maximize2":
		case "rw max2":
			subarray = command_array.FromX(2);
			SetMaximize2(command_array[1],subarray,true,true);
			break;
		case "rewrite maximize2 slots":
		case "rw maximize2 slots":
		case "rw max2 slots":
		case "rw m2 slots":
		case "rw m2slots":
			subarray = command_array.FromX(2);
			SetMaximize2Slots(command_array[1],subarray);
			break;
		case "rewrite maximize2 expression":
		case "rw maximize2 exp":
		case "rw max2 exp":
		case "rw m2 exp":
		case "rw m2exp":
			subarray = command_array.FromX(2);
			SetMaximize2Exp(command_array[1],subarray);
			break;
		case "remove maximize2":
		case "rm max2":
			Delete_Maximize2(command_array[1]);
			break;
		case "print maximize2":
		case "print max2":
			switch(paramnum)
			{
				case 1:
					print_max2_all();
					break;
				case 2:
					print_max2(command_array[1]);
					break;
			}
			break;
	//Max2Style Commands
		case "+max2 style":
		case "+max2style":
		case "+m2style":
		case "new max2 style":
		case "new max2style":
		case "new m2style":
		case "new style":
		case "+style":
			subarray = command_array.FromX(2);
			SetMax2_Style(command_array[1],subarray,false);
			break;
		case "rw max2 style":
		case "rw max2style":
		case "rw m2style":
		case "rw style":
			subarray = command_array.FromX(2);
			SetMax2_Style(command_array[1],subarray,true);
			break;
		case "remove max2style":
		case "rm m2style":
		case "rm style":
			Delete_Max2_Style(command_array[1]);
			break;
		case "print max2style":
		case "print m2style":
		case "print style":
			switch(paramnum)
			{
				case 1:
					print_max2_style_all();
					break;
				case 2:
					print_max2_style(command_array[1]);
					break;
			}
			break;	
	//Equip Commands
		case "equip":
			max2_equip(command_array[1]);
			break;
		case "equiptest":
		case "equip test":
			max2_equip(command_array[1],true);
			break;
	//Other
		default:
			print("Invalid command.  Try again.");
			break;
	}
}

///////////////////////
//Main

void main(string command)
{
	maximize2_parse(command);
}