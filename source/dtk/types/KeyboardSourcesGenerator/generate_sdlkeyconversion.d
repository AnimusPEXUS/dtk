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

    auto fout = File(cwd ~ "/sdlkeyconversion.d", "wb");
    scope (success)
        fout.close();

    {
        auto f = File(cwd ~ "/KeyInfo.csv");
        /* scope(exit) f.close(); */
        ubyte[] b;
        b.length = f.size;
        keyinfo_csv = cast(string) f.rawRead(b).idup;
    }

    fout.rawWrite("module dtk.platforms.sdl_desktop.sdlkeyconversion;\n\n");

    fout.rawWrite(HEADER_TEXT);

    fout.rawWrite("
import dtk.types.EnumKeyboardKeyCode;
import bindbc.sdl;
");

    fout.rawWrite("\n");

    {
        fout.rawWrite(
                "EnumKeyboardKeyCode convertSDLKeycodeToEnumKeyboardKeyCode(SDL_Keycode code)\n{\n");

        fout.rawWrite("    switch (code) {\n");
        fout.rawWrite("        default:\n");
        fout.rawWrite("            throw new Exception(\"could not decode supplied keycode\");\n");

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

            if (row[3] == "")
            {
                continue;
            }

            fout.rawWrite("        case SDL_Keycode." ~ row[3] ~ ":\n");
            fout.rawWrite("            return EnumKeyboardKeyCode." ~ row[0] ~ ";\n");
        }

        fout.rawWrite("    }\n");
        fout.rawWrite("}\n");
        fout.rawWrite("\n");
    }

    {
        fout.rawWrite(
                "SDL_Keycode convertEnumKeyboardKeyCodeToSDLKeycode(EnumKeyboardKeyCode code)\n{\n");

        fout.rawWrite("    switch (code) {\n");
        fout.rawWrite("        default:\n");
        fout.rawWrite("            throw new Exception(\"could not decode supplied keycode\");\n");

        auto reader = csvReader!(Tuple!(string, string, string, string))(keyinfo_csv);
        bool skipped = false;
        main_loop2: foreach (row; reader)
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
                continue main_loop2;
            case ".":
                break main_loop2;
            }

            if (row[3] == "")
            {
                continue;
            }

            fout.rawWrite("        case EnumKeyboardKeyCode." ~ row[0] ~ ":\n");
            fout.rawWrite("            return SDL_Keycode." ~ row[3] ~ ";\n");
        }

        fout.rawWrite("    }\n");
        fout.rawWrite("}\n");
        fout.rawWrite("\n");
    }

    scope (failure)
    {
        return 1;
    }

    return 0;
}
