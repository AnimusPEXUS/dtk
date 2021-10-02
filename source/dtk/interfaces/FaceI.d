module dtk.interfaces.FaceI;

import dtk.types.fontinfo;
import dtk.types.Image;

import dtk.interfaces.DrawingSurfaceI;

interface FaceI
{
    FaceInfo* getFaceInfo();
    void setPixelSize(uint width, uint height);
    void setCharSize(uint width, uint height);
    void setCharResolution(uint horizontal, uint vertical);
    GlyphRenderResult* renderGlyphByChar(dchar chr);
}
