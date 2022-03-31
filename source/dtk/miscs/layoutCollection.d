module dtk.miscs.layoutCollection;

import std.format;

// Button

string mixin_Button_centerChild01_code()
{
	string ret;
	
	ret = q{
		auto c = getChild();

		if (c is null)
		{
			return;
		}
		
		auto w = getWidth();
		auto h = getHeight();
	
		auto cw = c.getWidth();		 
		auto ch = c.getHeight();
		
		c.setX(w/2 - cw/2);
		c.setY(h/2 - ch/2);		
	};
	
	return ret;
}