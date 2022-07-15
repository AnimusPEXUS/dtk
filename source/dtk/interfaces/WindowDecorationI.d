module dtk.interfaces.WindowDecorationI;

import dtk.interfaces.FormI;

import dtk.types.WindowBorderSizes;

interface WindowDecorationI : FormI
{
    WindowBorderSizes getBorderSizes();
}
