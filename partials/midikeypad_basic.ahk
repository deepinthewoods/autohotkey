#SingleInstance, Force


#include %A_ScriptDir%/class_midiOut.ahk

; Create a new MIDI output device
midiOut := new MidiOut(2)

; Define the MIDI notes for each number key
noteMap := {1: 60, 2: 62, 3: 64, 4: 65, 5: 67, 6: 69, 7: 71, 8: 72, 9: 74, 0: 76}

; Set the default instrument (optional)
midiOut.selectInstrument(20)

; Hotkeys for number keys
Loop, 10
{
    Hotkey, % A_Index = 10 ? 0 : A_Index, NoteOn
    Hotkey, % A_Index = 10 ? 0 : A_Index . " up", NoteOff
}

NoteOn:
    note := noteMap[SubStr(A_ThisHotkey, 1)]
    midiOut.noteOn(note, 127)
return

NoteOff:
    note := noteMap[SubStr(A_ThisHotkey, 1, 1)]
    midiOut.noteOff(note)
return

^Esc::ExitApp