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
import dtk.types.EnumKeyboardModCode;
import bindbc.sdl;
");

    fout.rawWrite("\n");

    // ------------------ Key Codes ------------------

    {
        fout.rawWrite(
                "EnumKeyboardKeyCode convertSDLKeycodeToEnumKeyboardKeyCode(SDL_Keycode code)\n{\n");

        fout.rawWrite("    switch (code) {\n");
        fout.rawWrite("        default:\n");
        fout.rawWrite("            throw new Exception(\"could not decode supplied keycode\");\n");

        mixin makecsvreader;
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
            case ".":
                break main_loop;
            }

            if (row[TableColumns.COLUMN_SDL_KEYCODE] == "")
            {
                continue;
            }

            fout.rawWrite("        case SDL_Keycode." ~ row[TableColumns.COLUMN_SDL_KEYCODE] ~ ":\n");
            fout.rawWrite(
                    "            return EnumKeyboardKeyCode."
                    ~ row[TableColumns.COLUMN_BUTTONS] ~ ";\n");
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

        mixin makecsvreader;
        /* auto reader = makecsvreader(keyinfo_csv); */
        bool skipped = false;
        main_loop2: foreach (row; reader)
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
                continue main_loop2;
            case ".":
                break main_loop2;
            }

            if (row[TableColumns.COLUMN_SDL_KEYCODE] == "")
            {
                continue;
            }

            fout.rawWrite(
                    "        case EnumKeyboardKeyCode." ~ row[TableColumns.COLUMN_BUTTONS] ~ ":\n");
            fout.rawWrite(
                    "            return SDL_Keycode." ~ row[TableColumns.COLUMN_SDL_KEYCODE] ~ ";\n");
        }

        fout.rawWrite("    }\n");
        fout.rawWrite("}\n");
        fout.rawWrite("\n");
    }

    // ------------------ Mod Codes ------------------

    {
        fout.rawWrite(
                "EnumKeyboardModCode convertSDLKeymodToEnumKeyboardModCode(SDL_Keymod code)\n{\n");

        fout.rawWrite("    switch (code) {\n");
        fout.rawWrite("        default:\n");
        fout.rawWrite("            throw new Exception(\"could not decode supplied keymod\");\n");

        mixin makecsvreader;
        /* auto reader = makecsvreader(keyinfo_csv); */
        bool skipped = false;
        main_loop3: foreach (row; reader)
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
                continue main_loop3;
            case ".":
                break main_loop3;
            }

            if (row[TableColumns.COLUMN_SDL_KEYMOD] == "")
            {
                continue;
            }

            fout.rawWrite("        case SDL_Keymod." ~ row[TableColumns.COLUMN_SDL_KEYMOD] ~ ":\n");
            fout.rawWrite(
                    "            return EnumKeyboardModCode."
                    ~ row[TableColumns.COLUMN_BUTTONS] ~ ";\n");
        }

        fout.rawWrite("    }\n");
        fout.rawWrite("}\n");
        fout.rawWrite("\n");
    }

    {
        fout.rawWrite(
                "SDL_Keymod convertEnumKeyboardModCodeToSDLKeymod(EnumKeyboardModCode code)\n{\n");

        fout.rawWrite("    switch (code) {\n");
        fout.rawWrite("        default:\n");
        fout.rawWrite("            throw new Exception(\"could not decode supplied keymod\");\n");

        mixin makecsvreader;
        /* auto reader = makecsvreader(keyinfo_csv); */
        bool skipped = false;
        main_loop4: foreach (row; reader)
        {
            if (!skipped)
            {
                skipped = true;
                continue;
            }
            switch (row[TableColumns.COLUMN_SDL_KEYMOD])
            {
            default:
                break;
            case "":
                continue main_loop4;
            case ".":
                break main_loop4;
            }

            if (row[TableColumns.COLUMN_SDL_KEYCODE] == "")
            {
                continue;
            }

            fout.rawWrite(
                    "        case EnumKeyboardModCode." ~ row[TableColumns.COLUMN_BUTTONS] ~ ":\n");
            fout.rawWrite(
                    "            return SDL_Keymod." ~ row[TableColumns.COLUMN_SDL_KEYMOD] ~ ";\n");
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
