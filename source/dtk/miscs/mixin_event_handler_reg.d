module dtk.miscs.mixin_event_handler_reg;

import std.format;

string mixin_event_handler_reg(string subject, bool in_interface=false)
{
	string ret;
	
	if (!in_interface) 
	ret ~= q{
		private void delegate(
			Event%1$s *e,
			ulong mouse_widget_local_x,
			ulong mouse_widget_local_y,
			)[string] handlers%1$s;
	};
	
	ret ~= q{
		void set%1$sHandler(
			string name,
			void delegate(
				Event%1$s *e,
				ulong mouse_widget_local_x,
				ulong mouse_widget_local_y,
				) handler
			)
	};
	
	if (in_interface) 
		{ ret ~= ';';}
	else
	{
		ret ~= q{
			{
				handlers%1$s[name] = handler;
			}
		};
	}
	
	ret ~= q{
		void call%1$sHandler(
			string name,
			Event%1$s* e,
			ulong mouse_widget_local_x,
			ulong mouse_widget_local_y,
			)
	};
	
	if (in_interface) 
		{ ret ~= ';';}
	else
	{
		ret ~= q{
			{
				if (name in handlers%1$s)
				{
					auto ev = handlers%1$s[name];
					ev(e,mouse_widget_local_x,mouse_widget_local_y);
				}
			}
		};
	}
	
	ret ~= q{
		void unset%1$sHandler(string name)
	};
	
	if (in_interface) 
		{ ret ~= ';';}
	else
	{
		ret ~= q{
			{
				handlers%1$s.remove(name);
			}
		};
	}

	return ret.format(subject);
}
