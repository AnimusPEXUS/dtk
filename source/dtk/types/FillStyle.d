module dtk.types.FillStyle;

import std.format;

import dtk.types.Color;

struct FillStyle
{
    Color color;
    
    string toString()
    {
    	return "(color: %s)".format(color);
    }
}
