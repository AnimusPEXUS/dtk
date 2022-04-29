module dtk.types.LineStyle;

import std.format;

import dtk.types.Color;

struct LineStyle
{
    Color color;
    bool[] style;
    
    this(Color color, bool[] style = null)
    {
        this.color = color;
        this.style = style;
    }
    
    string toString()
    {
    	return "(color: %s, style: %s)".format(color, style);
    }
}
