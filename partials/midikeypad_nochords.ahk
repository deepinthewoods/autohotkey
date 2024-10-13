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

; Define the CC messages for each device
deviceCCMessages := {}
deviceCCMessages["device1"] := 1
deviceCCMessages["device2"] := 2
; Add more devices and their CC messages as needed

; Define the CC values for each key and chord combination
keyCCValues := {"0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "a": 10, "b": 11, "c": 12, "d": 13, "e": 14}
chordCCValues := {"1&2": 15, "1&3": 16, "1&4": 17, "1&5": 18, "1&6": 19, "1&7": 20, "1&8": 21, "1&9": 22, "1&0": 23, "1&a": 24, "1&b": 25, "1&c": 26, "1&d": 27, "1&e": 28, "2&3": 29, "2&4": 30, "2&5": 31, "2&6": 32, "2&7": 33, "2&8": 34, "2&9": 35, "2&0": 36, "2&a": 37, "2&b": 38, "2&c": 39, "2&d": 40, "2&e": 41}

; Set the default device
currentDevice := "device1"

; Hotkeys for single keys
Loop, 15
{
    key := A_Index <= 10 ? A_Index - 1 : Chr(A_Index + 54)
    if (key != "f")
    {
        Hotkey, % key, SendCC, On
    }
}

; Hotkeys for chords
Loop, 15
{
    key1 := A_Index <= 10 ? A_Index - 1 : Chr(A_Index + 54)
    if (key1 != "f")
    {
        Loop, 15
        {
            key2 := A_Index <= 10 ? A_Index - 1 : Chr(A_Index + 54)
            if (key2 != "f" && key1 != key2)
            {
                Hotkey, % "f & " . key1, SelectDevice, On
                Hotkey, % key1 . " & " . key2, SendCC, On
            }
        }
    }
}

SelectDevice:
    deviceKey := SubStr(A_ThisHotkey, 5)
    switch deviceKey
    {
        case "1":
            currentDevice := "device1"
            MsgBox, Device switched to %currentDevice%
        case "2":
            currentDevice := "device2"
            MsgBox, Device switched to %currentDevice%
        ; Add more cases for additional devices
        default:
            MsgBox, Invalid device selection: %deviceKey%
    }
return

SendCC:
    key := A_ThisHotkey
    if (StrLen(key) == 1)
    {
        ccValue := keyCCValues[key ""]
        ccMessage := deviceCCMessages[currentDevice]
        MsgBox, Key: %key%`nCurrent device: %currentDevice%`nCC message: %ccMessage%`nCC value: %ccValue%
        midiOut.controlChange(ccMessage, ccValue)
    }
    else
    {
        chord := StrReplace(key, " & ", "&")
        ccValue := chordCCValues[chord]
		
        ccMessage := deviceCCMessages[currentDevice]
        MsgBox, Chord: %chord%`nCurrent device: %currentDevice%`nCC message: %ccMessage%`nCC value: %ccValue%
        midiOut.controlChange(ccMessage, ccValue)
    }
return

^Esc::ExitApp