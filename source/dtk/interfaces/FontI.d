module dtk.interfaces.FontI;

import dtk.types.FontInfo;

import dtk.interfaces.DrawingSurfaceI;

interface FontI
{
    FontInfo* getFontInfo();
    void drawChar(char chr, DrawingSurfaceI ds);
}
