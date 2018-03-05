//GearList -- list of gears for a particular slot

script "gearlist.ash";

import "beefy_tools.ash";

///////////////////////
//Records

record gearlist
{//list of gear
	string name; //name of choices
	boolean [int, item] list; //list of items with weights
	int [int] sortindex;
	slot myslot; //slot of gear
};

////////////////////////////////
//Global Variables

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
				log_print("file empty, no gearlist settings found...");
			}
			else
			{
				log_print("loaded gearlist_array settings from file...");
			}
		}
		else
		{
			log_print("Could not load from " + gearlist_file + ", assuming no gearlist_array settings have been made");
		}
	}
	return gearlist_array;
}

////////////////////////////////
//Existance
	boolean GearListName_Exists(string grlname)
	{
		if(GearList_Array() contains grlname)
		{
			print_html("Existence Check: GearList Name %s exists.",grlname, beefy_logging());
			return true;
		}
		else
		{
			print_html("Existence Check: GearList Name %s not found.", grlname, beefy_logging());
			return false;
		}
		return false;
	}
	boolean GearListSlot_Exists(string grlname, slot slt)
	{
		if(GearListName_Exists(grlname))
		{
			if(GearList_Array()[grlname] contains slt)
			{
				print_html("Existence Check: GearList Name %s and slot %s exists.",string[int]{grlname,slt},beefy_logging());
				return true;
			}
			else
			{
				print_html("Existence Check: GearList Name %s exists, but not for slot %s", string[int]{grlname,slt},beefy_logging());
				return false;
			}
		}
		return false;
	}
	boolean GearListSlotWeight_Exists(string grlname, slot slt, int weight)
	{
		if(GearListSlot_Exists(grlname,slt))
		{
			if(GearList_Array()[grlname,slt].list contains weight)
			{
				print_html("Existence Check: GearList Name %s for slot %s with weight %s exists.",string[int]{grlname,slt,weight.to_string()},beefy_logging());
				return true;
			}
			else
			{
				print_html("Existence Check: GearList Name %s for slot %s exists, but not for weight %s", string[int]{grlname,slt,weight.to_string()},beefy_logging());
				return false;
			}
		}
		return false;
	}
////////////////////////////////
//Print Records
	void print_gearlist(gearlist gl)
	{
		string [int] output_array;
		output_array[0] = gl.name;
		output_array[1] = gl.myslot.to_string();
		print_html("Gearlist %s for slot %s",output_array);
		foreach weight in gl.list
		{
			print_html_list("Items for Weight %s: %s",weight.to_string(),gl.list[weight].BooleanItemToStringArray());
		}
		//BooleanItemToStringArray
	}
	void print_gearlist(string glname, slot slt)
	{
		if(GearListSlot_Exists(glname,slt))
		{
			print_gearlist(GearList_Array()[glname,slt]);
		}
			else
		{
			string [int] output_array;
			output_array[0] = glname;
			output_array[1] = slt.to_string();
			print_html("Gearlist Printing Error, %s for slot %s not found", output_array);
		}
	}
	void print_gearlist(string glname, string sltname)
	{
		print_gearlist(glname,sltname.to_slot());
	}

	void print_gearlist(string glname)
	{
		if(GearListName_Exists(glname))
		{
			print_html("Gearlist %s entries", glname);
			foreach slt in GearList_Array()[glname]
			{
				print_gearlist(GearList_Array()[glname,slt]);
			}
			
		}
		else
		{
			print_html("Gearlist Printing Error, %s not found", glname);
		}
	}
	void print_gearlist_all()
	{
		foreach name in GearList_Array()
		{
			print_gearlist(name);
			print("");
		}
	}
////////////////////////////////
//Helper Functions
	void Build_GL_Index(gearlist gl)
	{
		int [int] index_array;
		foreach weight in gl.list
		{
			index_array[index_array.count()] = weight;
		}
		sort index_array by -value;
		gl.sortindex = index_array;
	}

//Delete Record Functions
	boolean Delete_GearListName(string grlname)
	{
		if(GearListName_Exists(grlname))
		{
			foreach slt in GearList_Array()[grlname]
			{
				print_html("Gear List Deleted");
				print_gearlist(grlname);
			}
			remove gearlist_array[grlname];
			SaveGearLists();
			print_html("Gear Name Deleted: Name: %s", grlname, beefy_logging());
			return true;
		}
		return false;
	}
	boolean Delete_GearListSlot(string grlname, slot slt)
	{
		if(GearListSlot_Exists(grlname, slt))
		{
			remove gearlist_array[grlname,slt];
			SaveGearLists();
			print_html("Gear List Slot deleted:");
			print_gearlist(grlname,slt);
			return true;
		}
		return false;
	}
	boolean Delete_GearListSlot(string grlname, string sltname)
	{
		return Delete_GearListSlot(grlname,sltname.to_slot());
	}

	boolean Delete_GearListSlotWeight(string grlname, slot slt, int weight)
	{
		if(GearListSlot_Exists(grlname, slt))
		{
			if(GearList_Array[grlname,slt].list contains weight)
			{
				print_html("GearList Remove all Items of weight %s from List %s slot %s", string [int]{weight.to_string(),grlname,slt.to_string()});
				remove gearlist_array[grlname,slt].list[weight];
				Build_GL_Index(gearlist_array[grlname,slt]);
				SaveGearLists();
				return true;
			}
			else
			{
				print_html("GearList Remove Error Items of weight %s not in List %s slot %s", string [int]{weight.to_string(),grlname,slt.to_string()});
			}
		}
		return false;
	}
	boolean Delete_GearListSlotWeight(string grlname, string sltname, int weight)
	{
		return Delete_GearListSlotWeight(grlname, sltname.to_slot(), weight);
	}

	boolean Delete_GearListSlotWeightItem(string grlname, slot slt, int weight, item it)
	{
		if(GearListSlotWeight_Exists(grlname, slt, weight))
		{
			if(GearList_Array[grlname,slt].list[weight] contains it)
			{
				print_html("GearList Remove Item %s of weight %s from List %s slot %s", string [int]{it.to_string(),weight.to_string(),grlname,slt.to_string()});
				remove gearlist_array[grlname,slt].list[weight,it];
				Build_GL_Index(gearlist_array[grlname,slt]);
				SaveGearLists();
				return true;
			}
			else
			{
				print_html("GearList Remove Error Item %s not in List %s slot %s with weight %s", string [int]{it.to_string(),grlname,slt.to_string(), weight.to_string()});
			}
				
		}

		return false;
	}
	boolean Delete_GearListSlotWeightItem(string grlname, string sltname, int weight, item it)
	{
		return Delete_GearListSlotWeightItem(grlname, sltname.to_slot(), weight, it);
	}
	boolean Delete_GearListSlotWeightItem(string grlname, string sltname, int weight, string itname)
	{
		return Delete_GearListSlotWeightItem(grlname, sltname.to_slot(), weight, itname.to_item());
	}

	boolean Delete_GearListSlotItem(string grlname, slot slt, item it)
	{
		boolean nodelete = true;
		if(GearListSlot_Exists(grlname, slt))
		{
			foreach weight in GearList_Array()[grlname,slt].list
			{
				if(GearList_Array()[grlname,slt].list[weight] contains it)
				{
					Delete_GearListSlotWeightItem(grlname, slt, weight, it);
					nodelete = false;
				}
			}
			if(nodelete)
			{
				print_html("GearList Remove Error Item %s not in List %s slot %s", string [int]{it.to_string(),grlname,slt.to_string()});
			}

		}
		return false;
	}
	boolean Delete_GearListSlotItem(string grlname, string sltname, string itname)
	{
		return Delete_GearListSlotItem(grlname, sltname.to_slot(), itname.to_item());
	}

///////////////////////
//Functions GearList

	boolean AllowedSlot(slot slt, item it, boolean personal)
	{
		slot this_slot = to_slot(it);
		if(this_slot == slt || it == $item[none])
		{
			return true;
		}
		else
		{
			switch (slt)
			{
				case $slot[off-hand]:
					if(this_slot == $slot[weapon] && weapon_hands(it) == 1)
					{
						if(personal && have_skill(to_skill(1017)))
						{//Double-Fisted Skull Smashing 1017
							return true;
						}
						else if (! personal)
						{
							return true;
						}
					}
					break;
				case $slot[acc1]:
				case $slot[acc2]:
				case $slot[acc3]:
					if(this_slot == $slot[acc1])
					{
						return true;
					}
				break;

			}
		}
		return false;
	}
	boolean AllowedSlot(slot slt, item it)
	{
		return AllowedSlot(slt, it, false);
	}

///////////////////////
//Set/Add Gearslot
	void AddGearToList(string grlname, slot slt, int weight, item it)
	{
		if(GearListSlot_Exists(grlname,slt))
		{
			if(GearList_Array()[grlname,slt].list contains weight)
			{
				if(GearList_Array()[grlname,slt].list[weight] contains it)
				{
					print_html("GearList %s, slot %s, adding %s with weight %s", string[int]{grlname, slt.to_string(), it.to_string(), weight.to_string()});
					GearList_Array()[grlname,slt].list[weight,it] = true;
					SaveGearLists();
				}
				else
				{
					print_html("GearList %s, slot %s, weight %s, already has %s", string[int]{grlname, slt.to_string(), weight.to_string(),it.to_string()});
				}
			}
			else
			{
				print_html("GearList %s, slot %s, adding %s with new weight %s", string[int]{grlname, slt.to_string(), it.to_string(), weight.to_string()});
				GearList_Array()[grlname,slt].list[weight,it] = true;
				Build_GL_Index(gearlist_array[grlname,slt]);
				SaveGearLists();
			}
		}
		else
		{
			print_html("Gear List Add Error %s for slot %s does not exist", string[int]{grlname, slt.to_string()});
		}
	}
	void AddGearToList(string grlname, string sltname, string itname, string weight)
	{
		AddGearToList(grlname, sltname.to_slot(), itname.to_item(), weight.to_int());
	}

	void SetGearList(string grlname, slot slt, int weight, boolean [item] its, boolean overwrite)
	{
		if(GearListSlotWeight_Exists(grlname,slt,weight) && overwrite)
		{
			print_html("Setting Gear List, replacing existing list %s for slot %s", string[int]{grlname, slt.to_string()});
			print("Old List...");
			print_gearlist(grlname,slt);
			GearList_Array()[grlname,slt].list[weight] = its;
			print("New List...");
			print_gearlist(grlname,slt);
			Build_GL_Index(gearlist_array[grlname,slt]);
			SaveGearLists();
		}
		else if(GearListSlot_Exists(grlname,slt) && !GearListSlotWeight_Exists(grlname,slt,weight))
		{
			GearList_Array()[grlname,slt].list[weight] = its;
			Build_GL_Index(gearlist_array[grlname,slt]);
			SaveGearLists();
			print_html("Setting new Gear List %s for slot %s with weight %s", string[int]{grlname, slt.to_string(), weight.to_string()});
			print_gearlist(grlname,slt);
		}
		else if(!GearListSlot_Exists(grlname,slt))
		{
			GearList_Array()[grlname,slt] = new gearlist();
			GearList_Array()[grlname,slt].name = grlname;
			GearList_Array()[grlname,slt].list[weight] = its;
			GearList_Array()[grlname,slt].myslot = slt;
			Build_GL_Index(gearlist_array[grlname,slt]);
			SaveGearLists();
			print_html("Setting new Gear List %s for slot %s", string[int]{grlname, slt.to_string()});
			print_gearlist(grlname,slt);
		}
		else
		{
			print_html("Failure: Gear List %s for slot %s with weight %s already exists, not overwriting", string[int]{grlname, slt.to_string(), weight.to_string()});
		}
	}
	void SetGearList(string grlname, slot slt, int weight, boolean [string] itnames, boolean overwrite)
	{
		boolean [item] it_array;
		foreach name in itnames
		{
			item this_it = to_item(name);
			if(AllowedSlot(slt, this_it))
			{
				it_array[this_it] = true;
			}
			else
			{
				print_html("SetGearList item %s not valid for slot %s", string [int]{name, slt.to_string()});
			}
		}
		SetGearList(grlname,slt,weight,it_array,overwrite);
	}
	void SetGearList(string grlname, slot slt, int weight, boolean [item] it_array)
	{
		SetGearList(grlname, slt, weight, it_array, true);
	}
	void SetGearList(string grlname, slot slt, int weight, boolean [string] itnames)
	{
		SetGearList(grlname, slt, weight, itnames, true);
	}
	void SetGearList(string grlname, string sltname, int weight, boolean [string] itnames, boolean overwrite)
	{
		SetGearList(grlname, sltname.to_slot(), weight, itnames, overwrite);
	}
	void SetGearList(string grlname, string sltname, int weight, boolean [string] itnames)
	{
		SetGearList(grlname, sltname.to_slot(), weight, itnames, true);
	}

////////////////////////////////
//Command Parsing
void Parse_Gear_Command(string command)
{
	string [int] command_array = split_string(command,",");
	slot gslot;
	item it;
	int paramnum = command_array.count();
	string [int] subarray;
	switch(command_array[0])
	{
	//Gear List Commands
		case "+":
		case "new":
		case "create":
			subarray = command_array.FromX(4);
			SetGearList(command_array[1],command_array[2],command_array[3].to_int(),subarray.StringInt2BooleanString(),false);
		break;
		case "rewrite gearlist":
		case "rw gearlist":
		case "rw gl":
			subarray = command_array.FromX(4);
			SetGearList(command_array[1],command_array[2],command_array[3].to_int(),subarray.StringInt2BooleanString());
		break;
		case "+gear to list":
		case "add to gearlist":
		case "+gear2list":
		case "+g2l":
			subarray = command_array.FromX(4);
			AddGearToList(command_array[1], command_array[2],command_array[3].to_int(), subarray.StringInt2BooleanString());
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
					
					
									
					
				break;
				case 5:
					Delete_GearListSlotWeightItem(command_array[1],command_array[2],command_array[3].to_int(), command_array[4]);
				break;
			}
		break;
		case "remove gearlist weight":
		case "rm gearlist weight":
		case "rm glwt":
			Delete_GearListSlotWeight(command_array[1],command_array[2], command_array[3].to_int());
		break;
		case "remove gearlist item":
		case "rm gearlist item":
		case "rm gli":
			switch(paramnum)
			{
				case 4:
					Delete_GearListSlotItem(command_array[1],command_array[2],command_array[3]);
				break;
				case 5:
					Delete_GearListSlotWeightItem(command_array[1],command_array[2],command_array[3].to_int(), command_array[4]);
				break;
			}
		break;
		case "list":
		case "print":
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