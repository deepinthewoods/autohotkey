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
deviceCCMessages := {"1":0, "2":1, "3":2, "4":3, "5":4, "6":5, "7":6, "8":7, "9":8, "0":9, "a":10, "b":11, "c":12, "d":13, "e":14}


; Define the CC values for each key and chord combination
keyCCValues := {"0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "a": 10, "b": 11, "c": 12, "d": 13, "e": 14, "f":15}
chordCCValues := {"1 & 2": 16, "1 & 3": 17, "1 & 4": 18, "2 & 3": 19, "2 & 4": 20, "3 & 4": 21, "5 & 6": 22, "5 & 7": 23, "5 & 8": 24, "6 & 7": 25, "6 & 8": 26, "7 & 8": 27, "9 & 0": 28, "9 & a": 29, "9 & b": 30, "0 & a":31, "0 & b":32, "a & b": 33, "c & d": 34, "c & e": 35, "c & f": 36, "d & e":37, "d & f":38, "e & f": 39}


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
    ;if (key1 != "f")
    {
        Loop, 15
        {
            key2 := A_Index <= 10 ? A_Index - 1 : Chr(A_Index + 54)
            if (key1 != key2)
            {
                ;Hotkey, % "f & " . key1, SelectDevice, On
                Hotkey, % key1 . " & " . key2, SendCC, On
            }
        }
    }
}

chordDeviceValues:= {"1 & 2 & 3":0, "2 & 3 & 4":1, "5 & 6 & 7":2, "6 & 7 & 8":3, "9 & 0 & a":4, "0 & a & b":5, "c & d & e":6, "d & e & f":7}
chordDeviceKeys := ["1 & 2 & 3", "2 & 3 & 4", "5 & 6 & 7", "6 & 7 & 8", "9 & 0 & a", "0 & a & b", "c & d & e", "d & e & f"]

; Hotkeys for SelectDevice triple keys
Loop, 8
{
    keys := chordDeviceKeys[A_Index]
    Hotkey, %keys%, SelectDevice
}

SelectDevice:
	dKey1 := SubStr(A_ThisHotKey, 1)
	dKey2 := SubStr(A_ThisHotKey, 5)
	dKey3 := SubStr(A_ThisHotKey, 9)
	if (dKey1 < dKey2){
		if (dKey1 < dKey3){
			deviceKey := dKey1
			currentDevice := deviceKey
		} else {
			deviceKey := dKey3
			currentDevice := deviceKey
		}
	} else {
		if (dKey2 < dKey3){
			deviceKey := dKey2
			currentDevice := deviceKey
		} else {
			deviceKey := dKey3
			currentDevice := deviceKey
		}
	}
    
return


SendCC:
    key := A_ThisHotkey
	;key := "1 & 2"
    if (StrLen(key) == 1)
    {
        ccValue := keyCCValues[key ""]
        ccMessage := deviceCCMessages[currentDevice]
        MsgBox, Key: %key%`nCurrent device: %currentDevice%`nCC message: %ccMessage%`nCC value: %ccValue%
        midiOut.controlChange(ccMessage, ccValue)
    }
    else
    {
		ampersandPos := InStr(key, "&")
		spacePos1 := 1
		spacePos2 := ampersandPos - 1
		spacePos3 := ampersandPos + 1
		spacePos4 := StrLen(key)

		; Extract the numbers
		num1 := Trim(SubStr(key, spacePos1, spacePos2 - spacePos1 + 1))
		num2 := Trim(SubStr(key, spacePos3, spacePos4 - spacePos3 + 1))

		; Sort the numbers
		if (num1 > num2)
			sortedString := num2 " & " num1
		else
			sortedString := num1 " & " num2
		
        if chordCCValues.HasKey(sortedString)
            ccValue := chordCCValues[sortedString]
        else
            ccValue := 0
        ccMessage := deviceCCMessages[currentDevice]
        ;MsgBox, Chord: %key%`nCurrent device: %currentDevice%`nCC message: %ccMessage%`nCC value: %ccValue%`n
		;MsgBox % "First number: " num1 "`nSecond number: " num2
        midiOut.controlChange(ccMessage, ccValue)
    }
return

^Esc::ExitApp