#!/usr/bin/env rdmd

import std.typecons;
import std.stdio;
import std.file;
import std.csv;
import std.format;

import generator_utils;

int main()
{
    string cwd = getcwd();

    string keyinfo_csv;

    auto fout = File(cwd ~ "/EnumKeyboardModCode.d", "wb");
    scope (success)
        fout.close();

    {
        auto f = File(cwd ~ "/KeyInfo.csv");
        /* scope(exit) f.close(); */
        ubyte[] b;
        b.length = f.size;
        keyinfo_csv = cast(string) f.rawRead(b).idup;
    }

    fout.rawWrite("module dtk.types.EnumKeyboardModCode;\n\n");

    fout.rawWrite(HEADER_TEXT);

    fout.rawWrite("\n");

    fout.rawWrite("enum EnumKeyboardModCode : ushort\n{\n");

    auto reader = makecsvreader(keyinfo_csv);
    /* auto reader = makecsvreader(keyinfo_csv); */
    bool skipped = false;
    main_loop: foreach (row; reader)
    {
        if (!skipped)
        {
            skipped = true;
            continue;
        }
        switch (row[TableColumns.COLUMN_BUTTONS])
        {
        default:
            break;
        case "":
            continue main_loop;
        case "++++++ (generation ends here) ++++++":
            break main_loop;
        }
        if (row[TableColumns.COLUMN_MOD_BITS] == "")
        {
            continue;
        }
        fout.rawWrite(format("    %s = %s,\n", row[TableColumns.COLUMN_BUTTONS],
                row[TableColumns.COLUMN_MOD_BITS]));
    }

    fout.rawWrite("};\n");

    fout.rawWrite("\n");

    fout.rawWrite("

    enum EnumKeyboardModCodeNOT : ushort
    {
        None          =  cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.None,
        LeftShift     = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.LeftShift,
        LeftControl   = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.LeftControl,
        LeftMenu      = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.LeftMenu,
        LeftSuper     = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.LeftSuper,
        LeftAlt       = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.LeftAlt,
        LeftMode      = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.LeftMode,
        RightShift    = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.RightShift,
        RightControl  = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.RightControl,
        RightMenu     = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.RightMenu,
        RightSuper    = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.RightSuper,
        RightAlt      = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.RightAlt,
        RightMode     = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.RightMode,
        CapsLock      = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.CapsLock,
        NumLock       = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.NumLock,
        ScrollLock    = cast(EnumKeyboardModCodeNOT)~cast(uint)EnumKeyboardModCode.ScrollLock,
        Locks = ScrollLock & NumLock & CapsLock
    };

    ");

    fout.rawWrite("\n");
    scope (failure)
    {
        return 1;
    }

    return 0;
}
