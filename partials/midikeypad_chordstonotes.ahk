#SingleInstance, Force

#include %A_ScriptDir%/class_midiOut.ahk

; Get the list of available MIDI output devices
deviceList := MidiOut.getDeviceList()

; Display the list of devices and prompt the user to select one
if (deviceList.length() > 0) {
    deviceNames := ""
    for index, device in deviceList {
        deviceNames .= "Device " . index . ": " . device.name . "`n"
    }
    selectedIndex := 0
    while (selectedIndex < 1 || selectedIndex > deviceList.length()) {
        InputBox, selectedIndex, Select MIDI Output Device, % deviceNames . "`nEnter the device number (1-" . deviceList.length() . "):"
        if (ErrorLevel) {
            ExitApp
        }
    }
    selectedDeviceID := deviceList[selectedIndex].id
} else {
    MsgBox, No MIDI output devices found!
    ExitApp
}

; Create a new MIDI output device with the selected device ID
midiOut := new MidiOut(selectedDeviceID)

; Define the MIDI notes for each key and chord
noteMap := {}
noteIndex := 0

; Assign MIDI notes to single keys
Loop, 16
{
    key := A_Index <= 10 ? A_Index - 1 : Chr(A_Index + 55)
    noteMap[key] := noteIndex
    noteIndex++
}

; Assign MIDI notes to two-key chords
Loop, 16
{
    key1 := A_Index <= 10 ? A_Index - 1 : Chr(A_Index + 55)
    Loop, 16
    {
        key2 := A_Index <= 10 ? A_Index - 1 : Chr(A_Index + 55)
        if (key1 != key2)
        {
            noteMap[key1 . "+" . key2] := noteIndex
            noteIndex++
        }
    }
}

; Set the default instrument (optional)
midiOut.selectInstrument(0)

; Hotkeys for single keys
Loop, 16
{
    key := A_Index <= 10 ? A_Index - 1 : Chr(A_Index + 55)
    Hotkey, % key, PlayNote, On
}

; Hotkeys for two-key chords
Loop, 16
{
    key1 := A_Index <= 10 ? A_Index - 1 : Chr(A_Index + 55)
    Loop, 16
    {
        key2 := A_Index <= 10 ? A_Index - 1 : Chr(A_Index + 55)
        if (key1 != key2)
        {
            Hotkey, % key1 . " & " . key2, PlayChord, On
        }
    }
}

PlayNote:
    note := noteMap[SubStr(A_ThisHotkey, 1)]
    midiOut.noteOn(note, 127)
    midiOut.noteOff(note)
return

PlayChord:
    keys := StrSplit(A_ThisHotkey, " & ")
    chord := keys[1] . "+" . keys[2]
    note := noteMap[chord]
    midiOut.noteOn(note, 127)
    midiOut.noteOff(note)
return

^Esc::ExitApp