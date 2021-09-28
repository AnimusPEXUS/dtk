module dtk.interfaces.FontMgrI;

import std.typecons;

import dtk.interfaces.FontI;

import dtk.types.FontInfo;

interface FontMgrI
{
    FontInfo*[] getFontInfoList();
    FontI loadFont(FontInfo* font_info);
    final FontI loadFont(string filename)
    {
        auto x = new FontInfo;
        x.on_fs = true;
        x.on_fs_filename = filename;
        return loadFont(x);
    }
}
