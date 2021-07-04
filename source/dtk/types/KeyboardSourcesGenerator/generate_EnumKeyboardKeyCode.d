#!/usr/bin/env rdmd

import std.typecons;
import std.stdio;
import std.file;
import std.csv;
import std.format;

import generate_templates;

int main()
{
    string cwd = getcwd();

    string keyinfo_csv;

    auto fout = File(cwd ~ "/EnumKeyboardKeyCode.d", "wb");
    scope (success)
        fout.close();

    {
        auto f = File(cwd ~ "/KeyInfo.csv");
        /* scope(exit) f.close(); */
        ubyte[] b;
        b.length = f.size;
        keyinfo_csv = cast(string) f.rawRead(b).idup;
    }

    fout.rawWrite("module dtk.types.EnumKeyboardKeyCode;\n\n");

    fout.rawWrite(HEADER_TEXT);

    fout.rawWrite("\n");

    fout.rawWrite("enum EnumKeyboardKeyCode\n{\n");

    auto reader = csvReader!(Tuple!(string, string, string, string))(keyinfo_csv);
    bool skipped = false;
    main_loop: foreach (row; reader)
    {
        if (!skipped)
        {
            skipped = true;
            continue;
        }
        switch (row[0])
        {
        default:
            break;
        case "":
            continue main_loop;
        case ".":
            break main_loop;
        }
        fout.rawWrite(format("    %s,\n", row[0]));
    }

    fout.rawWrite("};\n");
    fout.rawWrite("\n");
    scope (failure)
    {
        return 1;
    }

    return 0;
}
