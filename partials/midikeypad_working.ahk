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

; Define the MIDI notes for each number key
noteMap := {1: 60, 2: 62, 3: 64, 4: 65, 5: 67, 6: 69, 7: 71, 8: 72, 9: 74, 0: 76}

; Set the default instrument (optional)
midiOut.selectInstrument(0)

; Hotkeys for number keys
Loop, 10
{
    Hotkey, % A_Index = 10 ? 0 : A_Index, PlayNote, On
}

PlayNote:
    note := noteMap[SubStr(A_ThisHotkey, 1)]
    midiOut.noteOn(note, 127)
    KeyWait, % SubStr(A_ThisHotkey, 1)
    midiOut.noteOff(note)
return

^Esc::ExitApp