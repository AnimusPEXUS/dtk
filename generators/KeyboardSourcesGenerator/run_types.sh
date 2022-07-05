#!/bin/bash

./generate_types_EnumKeyboardKeyCode.d
./generate_types_EnumKeyboardModCode.d

dfmt EnumKeyboardKeyCode.d > EnumKeyboardKeyCode.d2
mv EnumKeyboardKeyCode.d2 EnumKeyboardKeyCode.d

dfmt EnumKeyboardModCode.d > EnumKeyboardModCode.d2
mv EnumKeyboardModCode.d2 EnumKeyboardModCode.d


