module dtk.interfaces.FontI;

import dtk.types.FontInfo;
import dtk.types.Image;

import dtk.interfaces.DrawingSurfaceI;

interface FontI
{
    FontInfo* getFontInfo();
    void setPixelSize(uint width, uint height);
    void setCharSize(uint width, uint height);
    void setCharResolution(uint horizontal, uint vertical);
    Image drawChar(dchar chr);
}
