#!/bin/bash

./generate_EnumKeyboardKeyCode.d
./generate_EnumKeyboardModCode.d
./generate_sdlkeyconversion.d
dfmt -i ./*.d
