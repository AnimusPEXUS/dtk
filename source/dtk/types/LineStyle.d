module dtk.types.LineStyle;

import dtk.types.Color;

struct LineStyle
{
    Color color;
    bool[] style;

    this(Color color, bool[] style=null)
    {
        this.color=color;
        this.style = style;
    }
}
