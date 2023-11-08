#Requires AutoHotkey v2
#SingleInstance Force

#Include Lib\Gdip_All.ahk
#Include Lib\ImagePut.ahk

If (!pToken := Gdip_Startup()){
    MsgBox("Gdiplus failed to start. Please ensure you have gdiplus on your system")
    ExitApp
}
OnExit((ExitReason, ExitCode) => Gdip_Shutdown(pToken))

; Change the icon
base64_MineS_16 :="Qk2KBAAAAAAAAIoAAAB8AAAAEAAAABAAAAABACAAAwAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAD/AAD/AAD/AAAAAAAA/0JHUnOAwvUoYLgeFSCF6wFAMzMTgGZmJkBmZgagmZkJPArXAyRcjzIAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/wAAAP8AAAD/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/wAAAP8AAAAAAAAAAAAAAP+AgID/AAAA/wAAAAAAAAAAAAAAAAAAAP8AAAAAAAAAAAAAAAAAAAAAwMDA/4CAgP8AAAD/AAAA/wAAAAAAAAD/gICA/wAAAP8AAAAAAAAAAAAAAP+AgID/AAAA/wAAAAAAAAAAAAAAAAAAAADAwMD/gICA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP+AgID/AAAA/wAAAP8AAAAAAAAAAAAAAAAAAAAAAAAAAMDAwP+AgID/gICA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAgID/wMDA/4CAgP+AgID/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAAAAAAAAAAAAAAAAAAAgICA/4CAgP+AgID/gICA/4CAgP/AwMD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAD/AAAAAICAgP///////////8DAwP/AwMD/gICA/8DAwP+AgID/AAAA/wAAAP8AAAD/AAAA/wAAAP+AgID/gICA/wAAAACAgID/gICA/4CAgP//////wMDA/8DAwP//////wMDA/wAAAP+AgID/AAAA/wAAAP8AAAD/AAAA/wAAAP8AAAAAAAAAAAAAAAAAAAAAgICA///////AwMD/wMDA/4CAgP/AwMD/gICA/4CAgP8AAAD/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgICA/8DAwP///////////8DAwP/AwMD/gICA/8DAwP+AgID/AAAA/wAAAP8AAAAAAAAAAAAAAAAAAAAAgICA/8DAwP//////gICA/4CAgP//////wMDA/8DAwP+AgID/gICA/8DAwP8AAAD/AAAA/wAAAAAAAAAAAAAAAAAAAACAgID/gICA/wAAAAAAAAAAgICA//////+AgID/AAAAAAAAAACAgID/wMDA/wAAAP8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAICAgP//////gICA/wAAAAAAAAAAAAAAAICAgP8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAgID//////4CAgP8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAICAgP8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=="
newIcon := ImagePutHIcon(base64_MineS_16)
TraySetIcon("HICON:" . newIcon)

MineS_Gui()

Return

MineS_Gui(){

    MineS_LoadPictures()

    MyGui := Gui(, "MineSweeper AHK")
    MyGui.Opt("-MaximizeBox +LastFound  -DPIScale ") ; +E0x02000000 +E0x00080000 ; WS_EX_COMPOSITED & WS_EX_LAYERED => Double Buffer

    MyGui.Gui2 := Gui("+Parent" MyGui.hwnd " -Caption +E0x80000 +LastFound +ToolWindow +OwnDialogs")

    MyGui.Rows:= MineS_IniRead("Rows",8)
    MyGui.Columns:= MineS_IniRead("Columns",8)
    MyGui.Mines := MineS_IniRead("Mines",10)
    MyGui.MarginX:= 0
    MyGui.MarginY:= 0
    MyGui.Marks := MineS_IniRead("Marks",9999.99)
    MyGui.StartTime := 0
    MyGui.XWin := MineS_IniRead("XWin")
    MyGui.YWin := MineS_IniRead("YWin")
    MyGui.RecordBegTime := MineS_IniRead("RecordBegTime",9999.99)
    MyGui.RecordBegName := MineS_IniRead("RecordBegName","Anonymous")
    MyGui.RecordIntTime := MineS_IniRead("RecordIntTime",9999.99)
    MyGui.RecordIntName := MineS_IniRead("RecordIntName","Anonymous")
    MyGui.RecordExpTime := MineS_IniRead("RecordExpTime",9999.99)
    MyGui.RecordExpName := MineS_IniRead("RecordExpName","Anonymous")
    MyGui.Status := "Start"
    MyGui.BackColor := 0xC0C0C0

	; MenuBar of Gui
	MyMenuBar := MenuBar()
	MyGui.GameMenu := Menu()
	MyGui.GameMenu.Add("&New	F2",(ItemName, ItemPos, MyMenu)=>(MineS_New(MyGui)))
	MyGui.GameMenu.Add()
	MyGui.GameMenu.Add("&Beginner",(ItemName, ItemPos, MyMenu)=>(MineS_New(MyGui,8,8,10)))
	MyGui.GameMenu.Add("&Intermediate",(ItemName, ItemPos, MyMenu)=>(MineS_New(MyGui,16,16,40)))
	MyGui.GameMenu.Add("&Expert",(ItemName, ItemPos, MyMenu)=>(MineS_New(MyGui,16,30,99)))
	MyGui.GameMenu.Add("&Custom...",(ItemName, ItemPos, MyMenu)=>(Gui_CustomField(MyGui)))
	MyGui.GameMenu.Add()
	MyGui.GameMenu.Add("&Marks (?)",(ItemName, ItemPos, MyMenu)=>(MineS_Marks(MyGui)))
    if (MyGui.Marks){
        MyGui.GameMenu.Check("&Marks (?)")
    }
	MyGui.GameMenu.Add("Best &Times...",(ItemName, ItemPos, MyMenu)=>(Gui_BestTimes(MyGui)))
	MyGui.GameMenu.Add()
	MyGui.GameMenu.Add("E&xit",(ItemName, ItemPos, MyMenu)=>(MineS_Save(MyGui), ExitApp()))
	MyMenuBar.Add("&Game",MyGui.GameMenu)
	MyGui.HelpMenu := Menu()
	MyGui.HelpMenu.Add("&Help Topics",(ItemName, ItemPos, MyMenu)=>(Gui_AboutMineSweeper(MyGui)))
	MyGui.HelpMenu.Add()
	MyGui.HelpMenu.Add("&About Minesweeper",(ItemName, ItemPos, MyMenu)=>(Gui_AboutMineSweeper(MyGui)))
	MyMenuBar.Add("&Help",MyGui.HelpMenu)
	MyMenuBar.Add("&Reload",(*)=>(MineS_Save(MyGui),Reload()))
	MyGui.MenuBar := MyMenuBar
	MyGui.Gui2.MenuBar := MyMenuBar ; to be able to respond to the menu hotkeys
    MineS_UpdateMenu(MyGui)
    MyGui.SetFont("s14")

    MyGui.wGui := Max(24 + MyGui.Columns*16,152)
    MyGui.hGui := 67 + MyGui.Rows*16

    MyGui.InvButton := MyGui.Gui2.AddPicture("x0 y0 w" MyGui.wGui " h" MyGui.hGui " +0x0100 +0x4000000", "" )
    MyGui.InvButton.OnEvent("Click", ((GuiObj,*)=>(MineS_Click(GuiObj))).Bind(MyGui))

    MyGui.Gui2.OnEvent("ContextMenu",((GuiObj,*)=>(MineS_ContextMenu(GuiObj))).Bind(MyGui))

    MyGui.BombNumber := Format("{:03}", MyGui.Mines)
    MyGui.TimeNumber := "000"

    MyGui.oSmiley := {Status: "Smiley"}

    ; Initialisation of GDIP
    ; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
    global hbm := CreateDIBSection(A_ScreenWidth+20, A_ScreenHeight+20)

    ; Get a device context compatible with the screen
    global hdc := CreateCompatibleDC()

    ; Select the bitmap into the device context
    global obm := SelectObject(hdc, hbm)

    ; Get a pointer to the graphics of the bitmap, for use with drawing functions
    global G := Gdip_GraphicsFromHDC(hdc)


    ; Set the smoothing mode to antialias = 4 to make shapes appear smother (only used for vector drawing and filling)
    Gdip_SetSmoothingMode(G, 0)

    MineS_ResetBombs(MyGui)
    MineS_Update(MyGui)

    MyGui.OnEvent("Close", (*)=>(MineS_Save(MyGui),ExitApp()))
	MyGui.Show(" " (MyGui.XWin="" ? "" : " x" MyGui.XWin ) (MyGui.YWin="" ? "" : " y" MyGui.YWin ) " w" MyGui.wGui " h" MyGui.hGui)
    MyGui.Gui2.Show("NA")
    MineS_Update(MyGui)
    MyGui.Status := "Start"
	Return

}

MineS_AddTime(GuiObj){
    if (GuiObj.Status = "Lost" or GuiObj.Status = "Won" or GuiObj.Status = "Start"){
        SetTimer(, 0)
    }
    GuiObj.TimeNumber := Format("{:03}", Round((A_TickCount - GuiObj.StartTime)/1000))
    MineS_Update(GuiObj)
}

Gui_BestTimes(GuiObj){
    MyGui := Gui("+owner" GuiObj.Hwnd, "Best Times")
    GuiObj.Opt("+Disabled")  ; Disable main window.
    MyGui.Opt("+Toolwindow -MaximizeBox -MinimizeBox")
    MyGui.Opt("+0x94C80000")
    MyGui.Opt("-Toolwindow")

    ThunderRT6Frame1 := MyGui.AddGroupBox("x11 y11 w303 h102 +Tabstop +E0x4 Section", "Fastest Mine Sweepers")
    MyGui.AddText("xs+10 yp+23","Beginner:")
    ogTextBegTime := MyGui.AddText("xp+100 yp w100",Round(GuiObj.RecordBegTime,2) " Seconds" )
    ogTextBegName := MyGui.AddText("xp+100 yp w100",GuiObj.RecordBegName)
    MyGui.AddText("xs+10 yp+23","nIntermediate:")
    ogTextIntTime := MyGui.AddText("xp+100 yp w100",Round(GuiObj.RecordIntTime,2) " Seconds" )
    ogTextIntName := MyGui.AddText("xp+100 yp w100",GuiObj.RecordIntName)
    MyGui.AddText("xs+10 yp+23","Expert:")
    ogTextExpTime := MyGui.AddText("xp+100 yp w100",Round(GuiObj.RecordExpTime,2) " Seconds" )
    ogTextExpName := MyGui.AddText("xp+100 yp w100",GuiObj.RecordExpName)

    ThunderRT6CommandButton1 := MyGui.AddButton("x140 y122 w84 +Wrap +E0x4", "&Reset Scores")
    ThunderRT6CommandButton2 := MyGui.AddButton("x230 y122 w84 +0x3 +0x9 +Default +Wrap +0x7 +E0x4", "OK")
    ThunderRT6CommandButton1.OnEvent("Click", MyGui_ResetScores)
    ThunderRT6CommandButton2.OnEvent("Click", MyGui_Close)
    MyGui.OnEvent("Close", MyGui_Close)
    MyGui.OnEvent("Escape", MyGui_Close)

    ; CurrentMonitorIndex:=GetCurrentMonitorIndex()
    ; MyGui.Show("x" CoordXCenterScreen(320,CurrentMonitorIndex) " y" CoordYCenterScreen(140,CurrentMonitorIndex) )
    Gui_ShowCenter(MyGui, "")

    MyGui_Close(*){
        GuiObj.Opt("-Disabled")  ; Re-enable the main window (must be done prior to the next step).
        MyGui.Destroy()  ; Destroy the about box.
    }

    MyGui_ResetScores(*){
        Result := MsgBox("Are you sure you want to reset all the best times?", "Reset Scores", "OC Icon? 4096")
        if (Result = "OK"){
            ogTextBegTime.text := "9999.99 Seconds"
            ogTextBegName.text := "Anonymous"
            ogTextIntTime.text := "9999.99 Seconds"
            ogTextIntName.text := "Anonymous"
            ogTextExpTime.text := "9999.99 Seconds"
            ogTextExpName.text := "Anonymous"
            GuiObj.RecordBegTime := 9999.99
            GuiObj.RecordBegName := "Anonymous"
            GuiObj.RecordIntTime := 9999.99
            GuiObj.RecordIntName := "Anonymous"
            GuiObj.RecordExpTime := 9999.99
            GuiObj.RecordExpName := "Anonymous"
        }

    }

}

MineS_Check(GuiObj){ ; Checks if game is finished
    if (GuiObj.Status = "Lost"){
        return
    }
    Counter_Flagged_Correct := 0
    Counter_EmptyButtons := 0

    For GuiCtrlObj in GuiObj.aControls
    {
        if (GuiCtrlObj.HasProp("Bomb") and (GuiCtrlObj.Status = "Flagged") and (GuiCtrlObj.Bomb=1)){
            Counter_Flagged_Correct++
        }
        if (GuiCtrlObj.HasProp("Bomb") and (GuiCtrlObj.Status = "Button" or GuiCtrlObj.Status = "Question" or GuiCtrlObj.Status = "Flagged") and (GuiCtrlObj.Bomb=0) ){
            Counter_EmptyButtons++
        }
    }

    if (Counter_Flagged_Correct=GuiObj.Mines or Counter_EmptyButtons=0){
        GuiObj.Status := "Won"
        GuiObj.oSmiley.Status := "Smiley_Won"
        For GuiCtrlObj in GuiObj.aControls
        {
            if (GuiCtrlObj.HasProp("Bomb") and (GuiCtrlObj.Bomb=1 and (GuiCtrlObj.Status = "Button" or GuiCtrlObj.Status = "Question"))){
                GuiCtrlObj.Status := "Flagged"
            }
        }
        MineS_Update(GuiObj)
        Gui_Congratulations(GuiObj)
        Return 1
    }
    Return 0
}

MineS_Click(GuiObj, *){

    MousePos_Prev := ""
    Status_Temp := ""
    loop {
        Sleep(30)
        MousePos := MineS_MouseGetPos(GuiObj)
        if (MousePos_Prev != MousePos){
            if (MousePos.Column = "Smiley"){
                GuiObj.oSmiley.Status := "Smiley_Pressed"
                MineS_Update(GuiObj)
            } else {
                if (GuiObj.Status = "Lost"){
                    GuiObj.oSmiley.Status := "Smiley_Lost"
                } else if (GuiObj.Status = "Won"){
                    GuiObj.oSmiley.Status := "Smiley_Won"
                } else {
                    GuiObj.oSmiley.Status := "Smiley"
                }

                MineS_Update(GuiObj)
            }
            if (Status_Temp != ""){
                GuiObj.aGrid[PosObj_Temp.Column][PosObj_Temp.Row].Status := Status_Temp
                Status_Temp := ""
            }
            if (IsNumber(MousePos.Column) and GuiObj.Status != "Lost" and GuiObj.Status != "Won" and GuiObj.aGrid.Has(MousePos.Column) and GuiObj.aGrid[MousePos.Column].Has(MousePos.Row)) {

                PosObj := GuiObj.aGrid[MousePos.Column][MousePos.Row]
                if (PosObj.Status = "Button" or PosObj.Status = "Question"){
                    Status_Temp := GuiObj.aGrid[MousePos.Column][MousePos.Row].Status
                    PosObj_Temp := PosObj
                    if (PosObj.Status = "Button"){
                        GuiObj.aGrid[MousePos.Column][MousePos.Row].Status := "Empty"
                    } else {
                        GuiObj.aGrid[MousePos.Column][MousePos.Row].Status := "Question_Pressed"
                    }
                }
                MineS_Update(GuiObj)
            }
        }

        if !GetKeyState("LButton"){
            break
        }
        MousePos_Prev := MousePos
    }

    if (MousePos.Column = "Smiley"){
        GuiObj.oSmiley.Status := "Smiley"
        GuiObj.Status := "Start"
        MineS_ResetBombs(GuiObj)
        MineS_Update(GuiObj)

    } else if IsNumber(MousePos.Column){
        MineS_Hit(GuiObj, MousePos.Column, MousePos.Row)
        MineS_Update(GuiObj)
    } else  {

    }
    MineS_Check(GuiObj)
}

MineS_ContextMenu(GuiObj, *){

    if (GuiObj.Status = "Lost"){
        return
    }
    MousePos := MineS_MouseGetPos(GuiObj)

    if (MousePos.Column != "" and MousePos.Column != "Smiley"){
        PosObj := GuiObj.aGrid[MousePos.Column][MousePos.Row]

        if (PosObj.Status = "Button"){
            PosObj.Status := "Flagged"
            if InStr(GuiObj.BombNumber,"-"){
                GuiObj.BombNumber := "-" Format("{:02}", StrReplace(GuiObj.BombNumber,"-")+1)
            } else if (GuiObj.BombNumber=0){
                GuiObj.BombNumber := "-01"
            } else {
                GuiObj.BombNumber := Format("{:03}", GuiObj.BombNumber-1)
            }
        } else if (PosObj.Status = "Flagged"){
            PosObj.Status := GuiObj.Marks ? "Question" : "Button"
            GuiObj.BombNumber := Format("{:03}", GuiObj.BombNumber+1)
        } else if (PosObj.Status = "Question"){

            PosObj.Status := "Button"
        }
        MineS_Update(GuiObj)
    }
    MineS_Check(GuiObj)

}

MineS_GetANeighbors(GuiObj, PosObj){
    aResult := Array()
    loop 9 {
        if(A_Index=5){
            continue
        }
        Column1 := PosObj.Column + Mod(A_Index-1, 3)-1
        Row1 := PosObj.Row +Floor((A_Index-1)/3) -1
        if(GuiObj.aGrid.Has(Column1) and GuiObj.aGrid[Column1].Has(Row1)){
            aResult.Push(GuiObj.aGrid[Column1][Row1])
        }
    }
    return aResult
}

MineS_GetLevel(GuiObj){
    if (GuiObj.Rows = 8 and GuiObj.Columns = 8 and GuiObj.Mines = 10){
        Return "Beginner"
    } else if (GuiObj.Rows = 16 and GuiObj.Columns = 16 and GuiObj.Mines = 40){
        Return "Intermediate"
    } else if (GuiObj.Rows = 16 and GuiObj.Columns = 30 and GuiObj.Mines = 99){
        Return "Expert"
    } else {
        Return "Custom"
    }
}

MineS_GetNumberBombs(GuiObj, PosObj){
    NumberBombs := 0
    for CtrlObj in MineS_GetANeighbors(GuiObj, PosObj) {
        if (CtrlObj.Bomb = 1){
            NumberBombs++
        }
    }
    return NumberBombs
}

MineS_Hit(GuiObj, c1, r1){

    if (GuiObj.aGrid[c1][r1].Status = "Flagged" or GuiObj.Status = "Lost" or GuiObj.Status = "Won"){
        return
    }

    if (GuiObj.Status = "Start"){
        GuiObj.StartTime := A_TickCount
        GuiObj.Status := "Run"
        SetTimer(MineS_AddTime.Bind(GuiObj), 1000)

        if (GuiObj.aGrid[c1][r1].Bomb = 1){
            GuiObj.aGrid[c1][r1].Bomb := 0
            ControlLength := GuiObj.aControls.Length
            loop {
                Index := Random(1, ControlLength)
                if (GuiObj.aControls[Index].Bomb = 0 and (GuiObj.aControls[Index].Column !=c1 or GuiObj.aControls[Index].Row !=r1)){
                    GuiObj.aControls[Index].Bomb := 1
                    break
                }
            }
        }
    }

    if (GuiObj.aGrid[c1][r1].Bomb = 1){
        GuiObj.aGrid[c1][r1].Status := "RedBomb"
        MineS_Lost(GuiObj)
    } else  if (GuiObj.aGrid[c1][r1].Bomb = 0){
        Status := MineS_GetNumberBombs(GuiObj, GuiObj.aGrid[c1][r1])
        GuiObj.aGrid[c1][r1].Status := Status=0 ? "Empty" : Status
        if (Status=0){
            for CtrlObj in MineS_GetANeighbors(GuiObj, GuiObj.aGrid[c1][r1]) {
                if (CtrlObj.Status = "Button"){
                    MineS_Hit(GuiObj, CtrlObj.Column, CtrlObj.Row)
                }
            }
        }
    }
}

MineS_LoadPictures(){
    global mhBitmap := Map()
    global mpBitmap := Map()

    base64_Button :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAySURBVDhPY/hPAThw4MB/sg0AaW5oaEAYABIgBYM0jxowasBwMwBZgFTMQInmhoaG/wDBzz6MMVuGowAAAABJRU5ErkJggg=="
    base64_Empty :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAjSURBVDhPY2hoaPhPCQYbcODAAbLxqAGjBoDwqAEDb8CB/wD4zyfuKR0PqwAAAABJRU5ErkJggg=="
    base64_Bomb :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABmSURBVDhPtY4BCsAwCAN9uk/zZx0tRNSGFTpXOAqaHIqqji8sgZldcxSICJ2DfgEK86/EvefZBbUY2bLsggleLIOUbxOw4IkkcCMJVlK+XbCGpAS2LLsAfyXuPc8uiNRC5X/BOzYebwt9k4CREIgAAAAASUVORK5CYII="
    base64_RedBomb :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABmSURBVDhPtY6BCoBACEP9dP/cTNI8WR6UHbwJ3hwjZpYvWIAQvWYbQGCXmQ/wg3NWVGI6sEE9zKisXtTAjNfLx/GXmAtAxh0qzw06VG7/eIAtG1RWL2rgs6IS04ENMvWg8n9AD8kBIRHI9Atg8ugAAAAASUVORK5CYII="
    base64_BombCrossed :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAACGSURBVDhPrZALDoAgDEN3dI62m+FYAulK/UQ1KSC8vojWWutfkgJ3f51bgZnJ/ZklCDKzAWIP2fIF5SBmDjPJ8RUmoAQxlPLIJkBwPFwe68IrARdwfSqYh5gYtjKmCJYRgBikoPC/XQHDBZQwuwkmiOUrSRFIgN6ZWQJVTkDsISv/wfN4PwDj5Hnuc8EHRAAAAABJRU5ErkJggg=="
    base64_Flagged :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABZSURBVDhPxYxbCsAwCAQ9+h7Nm9nsR2gizcNIiTA/LjNiiVNVOw5QBvAG+IhAeRkwKXPha5sGqngU8HI4QNKBSjpA5FqAYovfhwEvev4P7NIF2kcUycgA7AFud/esBidV0gAAAABJRU5ErkJggg=="
    base64_Question :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABSSURBVDhPvY9BCsAwCAT36fs0f2bZU1JJJYlUYS6GGQy8MGbm1wHJJEdAixMkpwEAL+J7GojSKvJvIFIKrGSxFfiSRU8go+eCvi/Mi1NQkUn6A0sLCIyx2ZvLAAAAAElFTkSuQmCC"
    base64_Question_Pressed :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABLSURBVDhPY2hoaPhPCQYbcODAAbLxIDeAgYEBBWNVg8sAdE24DKGdAeiYIgNwaQbLETIAn2YQpr0BhDBFLhASlqeDAfgwFQyQ/w8A8sTp78RudUsAAAAASUVORK5CYII="
    base64_Smiley :="iVBORw0KGgoAAAANSUhEUgAAABoAAAAaCAYAAACpSkzOAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAACmSURBVEhL7c1RDsQgCEVRls7S3BmT1+Q1BrEFo5P5mCb3o4ocUVU7XWvNLujkBwTGUYjIAOFiZ0R+FxKRoWiOlSEuNRt7AkvQDPBFWBrKIsxjKaiKsB5bgvCfPUtD/jEXREtns8tQpT909wZH8ymogs2QZYhLfNFMCULRoqd6BKUhlMU8gkoQwpIZyLvoXRliXNoXzbFlqFoI+YvdXdBpBMk3EFW1D4A4lcS5HgVlAAAAAElFTkSuQmCC"
    base64_Smiley_Lost :="iVBORw0KGgoAAAANSUhEUgAAABoAAAAaCAYAAACpSkzOAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAACpSURBVEhL7c1RCsQgDEXRLD1Lc2cOr/BAYuIkUks/WrjQRpsjqtpP11rrF3TyAQLjKERkgnBwZ0TeC4nIlHePlSEu7X1uBZagCLB5WBrKIsxiKWhE+G5hb473bcguW81LUIRU5ltQtQ+awtwW3UtBHrZaar+5owxFCLN3SxD6B9hGBKUhlMUsgkoQwpII5Jn3XxliXDrm3WPbUDUXsgd3d0GnESRPIKrafwHnkchW2NCFAAAAAElFTkSuQmCC"
    base64_Smiley_O :="iVBORw0KGgoAAAANSUhEUgAAABoAAAAaCAYAAACpSkzOAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAC9SURBVEhL1dGBCsMgDIRhHz2P5pulXMuBxHMkXR3d4KeiXT6kzcx8d713P6GdPyAwtkJEJggHT0bkvVBrbUq9x8oQh7rPfQJL0AqIKSwNZREWsRQ0ImbXEDzHwWp/xMoQ1ox7q32s01AcWLkRIlaGqv0XhDOmztHXEL8J1njGb8PS0AqLe6t3OOM2lLlRGUIKwx5TZ+P/0xBSA1URQSUIrW5AQCGoDDEOHVPvsdtQNQnFg6c7od0Iar9AzMwPS39/5qAcv0AAAAAASUVORK5CYII="
    base64_Smiley_Won :="iVBORw0KGgoAAAANSUhEUgAAABoAAAAaCAYAAACpSkzOAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAC0SURBVEhLzc0BCsQgDERRj56jebOUKQxkY3QTqaULny1R85qI6Ol673pDJ39AYByFiAwQDp6MyHeh1tpQdI+VIS5VHVuBJWgG+CIsDWUR5rEUVEWYxcoQvv+1BfmHvtXcYmnI/ttWszLER0jkdyHjDOd+lobswmrfgyJshkf3uGML4hJfdKcEoWjRKougNISymEdQCUJYMgN5Fr0rQ4xLbdE9tg1VCyF/8HQ3dBpB7Q1ERPQCnPph+jm1Ix4AAAAASUVORK5CYII="
    base64_Smiley_Pressed :="iVBORw0KGgoAAAANSUhEUgAAABoAAAAaCAYAAACpSkzOAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsQAAA7EAZUrDhsAAADJSURBVEhL7ZYBCsMgDEV1J/NoHs2b2f5uGSEkJlYcY+xBoNOax1+ELddae9pMKSU9Xs9baa2ldyJYdwHRRxKBv+iapawIYRE17efVkRURhkRcoMGFFq6IJBFGsqFoRkJYsqnLkPOzONqahim6k4bQUk0lQgMp19Y0pkQrfJ/IG7i3b4qu3xB2GHOwmmGdzwmfcZ4zfRnQRNbyZZCpAJrK4uB9mQa4iTSZhSUBoa+OZJaQ9iwJCM8ITbiQF+2N+L0/J/m0dS/2Oikdy6R17aTJEswAAAAASUVORK5CYII="
    base64_1 :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABFSURBVDhPY2hoaPhPCQYbcODAAbIx7Q1gYPgPxtjkQBivATDNZBmArJlkA9A1k2wADI9kA5A1omMMtTQxgBQ80AYc+A8A9hb1t7eSQUcAAAAASUVORK5CYII="
    base64_2 :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABXSURBVDhPxZBBCgAgCAR9uk/zZwWJIKImVnSYkztzEBBxnLACRNTmfgAQUvSW9yrgCR6lgB5lt/IP2gEtWpnvQcCKnsw7E6iKQvjEnSikgYh3gQ6/AzQmBEK2H2eAELsAAAAASUVORK5CYII="
    base64_3 :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABLSURBVDhPxc87DgAgCERBjs7RuBkGq40J+AG1mI59CcTMmtEDInKsNqBEUzg22wHjBiLvAzhA4929wMiL1AbwKJIK4Ngsv+D5HRBt/kPaIUytQXMAAAAASUVORK5CYII="
    base64_4 :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABESURBVDhPY2hoaPhPCQYbcODAAbIxbQxgYAA6DYqx8VHUUt0AbIqxicHlqGoAskJ8mHYG4MK4NIPlRogB+PBAG3DgPwCMRcXfxmukqQAAAABJRU5ErkJggg=="
    base64_5 :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABGSURBVDhPxdCxDQAgCERRRr/R2AyD1TUQIorF6+AnIACsYwdU9djdAERKZgI8lHkXiPCyu/uDzEyAhzKtAC+78gmR3wG1BfXarV9rjF+rAAAAAElFTkSuQmCC"
    base64_6 :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABZSURBVDhPxYxBDoAgDAR9ep/Wn0E1m7BR2IjScJgDy3QOMyt/uALu/pn1gRgk7MJv413uwce46QdYUuQFRvAxbuYCJ68CLKm/eCcFFMMABgm78J/jDLsDXipLYc3f66u03gAAAABJRU5ErkJggg=="
    base64_7 :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAA/SURBVDhPY2hoaPhPCQYbcODAAbIxdQ1gYGAgCtPOAHx4YA3ApRksR3MD8GkGy9PUAEKaQZi2BhCDB9qAA/8BU8bE37c44zIAAAAASUVORK5CYII="
    base64_8 :="iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABWSURBVDhPxdBBCsAgDETRHj1Hy82UKQhj2oRWE1y8VYaPeIlI23EHVHVZfmA8zcNbmAJ27PkU4FF0yw0AD9/wFuo+kUfRrS4QcQNgxxZv4RH463RAWwcNku7frw2mdgAAAABJRU5ErkJggg=="

    base64_Dig_M :="iVBORw0KGgoAAAANSUhEUgAAAA0AAAAXCAYAAADQpsWBAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAB5SURBVDhPnY4BDoAgDMR4uj9HJBK2XccSTKp43U3buPoF++UpngYfngrmnMuk8MFDFvASIMHjJgd4CZDgcZMDvARI8DsYtxQ7N0tVYbFmZ+n6S+GfheB3kBXBS4AEj5sc4CVAgsdNDvAS4BJ7HpwLSVHDU/FHgoLWXwEFYc5OMGylAAAAAElFTkSuQmCC"
    base64_Dig_0 :="iVBORw0KGgoAAAANSUhEUgAAAA0AAAAXCAYAAADQpsWBAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAACKSURBVDhPnY2BDkAwFAN9uj+nQ+e1OhOSq7museDZfnAeEFNkRNHeI+q9PqLgueJ3ZFSkgPA+SgHhfZQCwvsoBYT3UQoI798HBPEcsVwH7waC51uOBnV48fNP7aOICCKPihQQ3kcpILyPUkB4H6WA8D5KAeG9Cp4rfqePRgNS7x2j2YDwbh99Z9l2Fp6sZ6api48AAAAASUVORK5CYII="
    base64_Dig_1 :="iVBORw0KGgoAAAANSUhEUgAAAA0AAAAXCAYAAADQpsWBAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAB0SURBVDhP1Y9RCsAwCEN79N28i2DRkmihfx28LLN7kw1c84J4+A73xD7sBMTqfFgJhj/rlzIIloxKMBAsPb7JQOhNuavtiNVjWAlZdPZhJyBW50MFQv9TJSJYMrpNCJYe26Q+gtCbcq9E7zGshCw6NDgw5g+D8m27RH3VHQAAAABJRU5ErkJggg=="
    base64_Dig_2 :="iVBORw0KGgoAAAANSUhEUgAAAA0AAAAXCAYAAADQpsWBAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAB5SURBVDhP1Y9bDoAgDAQ5ujfHrrBQ+hDjHyZTkO3QUOSrP2gbKVsW6eo/CDKYDwm8ifq890+Bq0WKl0AmACleOnwSkBJPYhDBfEg7gbD3kXiANQO5esIaZJg3+xstFMJJoB86Tp2k9xojgBlgzUC+TNoJhL1D+k6pN55EoHpR21cXAAAAAElFTkSuQmCC"
    base64_Dig_3 :="iVBORw0KGgoAAAANSUhEUgAAAA0AAAAXCAYAAADQpsWBAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAABxSURBVDhP1Y9RDoAgDEM5ujfHVuhExsDwh8krSveymPDkDcoLYslHuuoHiwj1JpGZ2N7X+VfQ2YPwEokEgvDS4ZsIYrxJxQj1Jq0EodlH2t60/U+RiPASmW1CeOmgTSx62vs6PxeEepNWgtCsSf9J+Qao5qB6W6gj3AAAAABJRU5ErkJggg=="
    base64_Dig_4 :="iVBORw0KGgoAAAANSUhEUgAAAA0AAAAXCAYAAADQpsWBAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAACMSURBVDhP1ZJRDoAgDEM5ujfHogy6rUDinyavQkvdBxY89QNzcx3eRKnQYewKEFu/GzKWhUbfT4NMByTm0nRAYi5NByTm0nRAYi5NByTm+4IBySUOFHzuKZ0Khp19SnaJLVhh+Sg1+PYVEF9Svw0DyaXGbhIkl342SX0EoifxelXs62muClzsJONAqTdPYo6PWl001QAAAABJRU5ErkJggg=="
    base64_Dig_5 :="iVBORw0KGgoAAAANSUhEUgAAAA0AAAAXCAYAAADQpsWBAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAB6SURBVDhP1Y5bDsAgCAQ9em9u2ZYlykOb/tlk0LCMtMnXf/BepGyZJDZwViC/9DSJAe8jTgBxwEMh3QS0GTh1kzZS0k08K5BPm3YC4ewj8QUEFcxNAu6fA1JmiUIlSokSWG2SEqWDNiHwjH2dXwuEuUk7gXDWpO+0fgOeRKB6WHthLAAAAABJRU5ErkJggg=="
    base64_Dig_6 :="iVBORw0KGgoAAAANSUhEUgAAAA0AAAAXCAYAAADQpsWBAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAACFSURBVDhP1Y1RDsAgCEM9+m7uwFkDtcRlfzN5xbQ0NHv9A8/H5EgqwfBZ4fk15yohwD9CBWdfYFCQl5xpbvz10jQk8hJmhefp0qkAsDtKMHxWxL1VCobERJeCmTDhXJoJE86lmTDhXJoJE86lmTDhPBv4R3hnlaoCiHujdCoA7K7Se1q/AcO9r2Xk939JAAAAAElFTkSuQmCC"
    base64_Dig_7 :="iVBORw0KGgoAAAANSUhEUgAAAA0AAAAXCAYAAADQpsWBAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAB4SURBVDhP1Y9RDoAwCEN3dG8+SwRhQlni30xercwnceCaP3gKYssiXfogBww7fyWhE+Nc33fB7l8QWRKYICCydPgmAVFvir3ajrDuQyZEUVmHnYCwng8rEPU/MRGRJaHbhMjSYZuqjyDqTbEzUbsPmRBFJQ02jHkD7Ph+JvtsauEAAAAASUVORK5CYII="
    base64_Dig_8 :="iVBORw0KGgoAAAANSUhEUgAAAA0AAAAXCAYAAADQpsWBAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAACKSURBVDhPnYsBDoQwEAL9/6cVa2gA6fWiyWAzLAe+8wPPA7HFRhT3f4XezREF30re2Eikgci+SgORfZUGIvsqDUT2VRqI7H8PCOI90qKhd2O0GxDejhHF/V+hd3MkooLoI5EGIvsqDUT2VRqI7Ks0ENlXaSCyd8G3kjdztBoQvRuj3YDwdo7+5zgv2C++UAgp/RwAAAAASUVORK5CYII="
    base64_Dig_9 :="iVBORw0KGgoAAAANSUhEUgAAAA0AAAAXCAYAAADQpsWBAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAACHSURBVDhP1Y3RDoUwCEP36f75LHMlwGAzvnmTU70tJzb8+geeF8QRJ7GQZ4W9U4kF3y3xxkmmdCDinpYORNzT0oGIe1o6EHFPSwci7nuBIFbJDhn2bkgngfB2SNf8I0MFd5UEihUIL1GoRMQqCbsvIVbpR1+SIWL7eb8XCHeVTgLhrUrvaf0GsravZTHF51cAAAAASUVORK5CYII="

    ; mhBitmap["Button"] := Gdip_CreateHBITMAPFromBitmap(Gdip_BitmapFromBase64(&base64_Button))

    mpBitmap["Button"] := Gdip_BitmapFromBase64(&base64_Button)
    mpBitmap["Empty"] := Gdip_BitmapFromBase64(&base64_Empty)
    mpBitmap["Bomb"] := Gdip_BitmapFromBase64(&base64_Bomb)

    mpBitmap["RedBomb"] := Gdip_BitmapFromBase64(&base64_RedBomb)
    mpBitmap["BombCrossed"] := Gdip_BitmapFromBase64(&base64_BombCrossed)
    mpBitmap["Flagged"] := Gdip_BitmapFromBase64(&base64_Flagged)
    mpBitmap["Question"] := Gdip_BitmapFromBase64(&base64_Question)
    mpBitmap["Question_Pressed"] := Gdip_BitmapFromBase64(&base64_Question_Pressed)
    mpBitmap["Smiley"] := Gdip_BitmapFromBase64(&base64_Smiley)
    mpBitmap["Smiley_Lost"] := Gdip_BitmapFromBase64(&base64_Smiley_Lost)
    mpBitmap["Smiley_O"] := Gdip_BitmapFromBase64(&base64_Smiley_O)
    mpBitmap["Smiley_Won"] := Gdip_BitmapFromBase64(&base64_Smiley_Won)
    mpBitmap["Smiley_Pressed"] := Gdip_BitmapFromBase64(&base64_Smiley_Pressed)
    mpBitmap[1] := Gdip_BitmapFromBase64(&base64_1)
    mpBitmap[2] := Gdip_BitmapFromBase64(&base64_2)
    mpBitmap[3] := Gdip_BitmapFromBase64(&base64_3)
    mpBitmap[4] := Gdip_BitmapFromBase64(&base64_4)
    mpBitmap[5] := Gdip_BitmapFromBase64(&base64_5)
    mpBitmap[6] := Gdip_BitmapFromBase64(&base64_6)
    mpBitmap[7] := Gdip_BitmapFromBase64(&base64_7)
    mpBitmap[8] := Gdip_BitmapFromBase64(&base64_8)

    mpBitmap["Dig_-"] := Gdip_BitmapFromBase64(&base64_Dig_M)
    mpBitmap["Dig_0"] := Gdip_BitmapFromBase64(&base64_Dig_0)
    mpBitmap["Dig_1"] := Gdip_BitmapFromBase64(&base64_Dig_1)
    mpBitmap["Dig_2"] := Gdip_BitmapFromBase64(&base64_Dig_2)
    mpBitmap["Dig_3"] := Gdip_BitmapFromBase64(&base64_Dig_3)
    mpBitmap["Dig_4"] := Gdip_BitmapFromBase64(&base64_Dig_4)
    mpBitmap["Dig_5"] := Gdip_BitmapFromBase64(&base64_Dig_5)
    mpBitmap["Dig_6"] := Gdip_BitmapFromBase64(&base64_Dig_6)
    mpBitmap["Dig_7"] := Gdip_BitmapFromBase64(&base64_Dig_7)
    mpBitmap["Dig_8"] := Gdip_BitmapFromBase64(&base64_Dig_8)
    mpBitmap["Dig_9"] := Gdip_BitmapFromBase64(&base64_Dig_9)

}

MineS_Lost(GuiObj){
    GuiObj.Status := "Lost"
    GuiObj.oSmiley.Status := "Smiley_Lost"
    for CtrlObj in GuiObj.aControls
    {
        if (CtrlObj.Bomb=1 and (CtrlObj.Status = "Button" or CtrlObj.Status = "Question")){
            CtrlObj.Status := "Bomb"
        }
        if ((CtrlObj.Bomb=0) and (CtrlObj.Status = "Flagged")){
            CtrlObj.Status := "BombCrossed"
        }
    }
}

MineS_Marks(GuiObj){
    GuiObj.Marks := !GuiObj.Marks
    if (GuiObj.Marks){
        GuiObj.GameMenu.Check("&Marks (?)")
    } else{
        GuiObj.GameMenu.UnCheck("&Marks (?)")
    }
}

MineS_MouseGetPos(GuiObj){
    MouseGetPos(&OutputVarX, &OutputVarY, &OutputVarWin, &OutputVarControl)

    xs := (GuiObj.wGui)/2-13
    if ((OutputVarX >= xs and OutputVarX <= xs+26) and (OutputVarY >= 15 and OutputVarY <= 41)){
        Return {Column:"Smiley",Row:"Smiley"}
    } else if ((OutputVarX >= 12 and OutputVarX <= (GuiObj.Columns+1)*16 - 4) and (OutputVarY >= 55 and OutputVarY <= (GuiObj.Rows+1)*16 + 39)){
        Column1 := floor((OutputVarX+4)/16)
        Row1 := floor((OutputVary-39)/16)
        return {Column:Column1,Row:Row1}
    }
    return {Column:"",Row:""}
}

MineS_New(GuiObj, NewRows?, NewColumns?, NewMines?){
    GuiObj.Status := "Lost" ; Prevent user input during generation

    SetTimer(MineS_AddTime.Bind(GuiObj),0)
    if IsSet(NewMines){
        GuiObj.Mines := NewMines
    }

    if IsSet(NewRows){
        GuiObj.Rows := NewRows
    }
    if IsSet(NewColumns){
        GuiObj.Columns := NewColumns
    }

    GuiObj.wGui := Max(24 + GuiObj.Columns*16,152)
    GuiObj.hGui := 67 + GuiObj.Rows*16
    WinGetClientPos(, , &cWidth, &cHeight, GuiObj)
    WinGetPos(, , &Width, &Height, GuiObj)
    GuiObj.Move(,,GuiObj.wGui+Width-cWidth,GuiObj.hGui+Height-cHeight)
    GuiObj.InvButton.Move(0,0,GuiObj.wGui,GuiObj.hGui)

    GuiObj.StartTime := 0
    MineS_Save(GuiObj)

    MineS_ResetBombs(GuiObj)

    MineS_Update(GuiObj)
    MineS_UpdateMenu(GuiObj)

    GuiObj.Status := "Start"
}

MineS_ResetBombs(GuiObj){

    GuiObj.aGrid := Array()
    GuiObj.aControls := Array()

    loop GuiObj.Columns {
        Column:= A_Index
        GuiObj.aGrid.Push(Array())
        loop GuiObj.Rows {
            Row := A_Index
            GuiObj.aGrid[Column].Push({Status:"Button"})
        }
    }
    loop GuiObj.Columns {
        Column := A_Index
        loop GuiObj.Rows {
            Row := A_Index
            GuiObj.aGrid[Column][Row].Bomb := 0
            GuiObj.aGrid[Column][Row].Status := "Button"
            GuiObj.aGrid[Column][Row].Row := Row
            GuiObj.aGrid[Column][Row].Column := Column
            GuiObj.aGrid[Column][Row].x := Column*16 - 4
            GuiObj.aGrid[Column][Row].y := Row*16 + 39
            GuiObj.aControls.Push(GuiObj.aGrid[Column][Row])
        }

    }

    MinesCount := 0
    ControlLength := GuiObj.aControls.Length
    loop {
        Index := Random(1, ControlLength)
        if (GuiObj.aControls[Index].Bomb = 0){
            GuiObj.aControls[Index].Bomb := 1
            MinesCount++
            if(MinesCount=GuiObj.Mines){
                break
            }
        }
    }

    GuiObj.BombNumber := Format("{:03}", GuiObj.Mines)
    GuiObj.TimeNumber := "000"
}

MineS_Save(GuiObj){
    WinGetPos(&XWin, &YWin, , , GuiObj)
    MineS_IniWrite("XWin",XWin)
    MineS_IniWrite("YWin",YWin)
    MineS_IniWrite("Rows",GuiObj.Rows)
    MineS_IniWrite("Columns",GuiObj.Columns)
    MineS_IniWrite("Mines",GuiObj.Mines)
    MineS_IniWrite("Marks",GuiObj.Marks)
    MineS_IniWrite("RecordBegTime",GuiObj.RecordBegTime)
    MineS_IniWrite("RecordBegName",GuiObj.RecordBegName)
    MineS_IniWrite("RecordIntTime",GuiObj.RecordIntTime)
    MineS_IniWrite("RecordIntName",GuiObj.RecordIntName)
    MineS_IniWrite("RecordExpTime",GuiObj.RecordExpTime)
    MineS_IniWrite("RecordExpName",GuiObj.RecordExpName)
}

MineS_Update(GuiObj){

    pBrushBackGround := Gdip_BrushCreateSolid("0xFFC0C0C0")
    pBrushWhite := Gdip_BrushCreateSolid("0xFFFFFFFF")
    pBrushDarkGrey := Gdip_BrushCreateSolid("0xFF808080")

    Gdip_FillRectangle(G, pBrushBackGround, 0, 0, GuiObj.wGui, GuiObj.hGui)
    x1 :=0
    y1 :=0
    w1 := GuiObj.wGui
    h1 := GuiObj.hGui
    t1 := 3
    Gdip_FillPolygon(G, pBrushWhite, x1 "," y1 "|" x1+w1-1 "," y1 "|" x1+w1-t1-1 "," y1+t1 "|" x1+t1 "," y1+t1 "|" x1+t1 "," y1+h1-t1-1 "|" x1 "," y1+h1-1)
    Gdip_FillPolygon(G, pBrushDarkGrey, x1+w1 "," y1+h1 "|" x1+w1 "," y1 "|" x1+w1-t1 "," y1+t1 "|" x1+w1-t1 "," y1+h1-t1 "|" x1+t1 "," y1+h1-t1 "|" x1 "," y1+h1)

    x1 := 9
    y1 := 9
    w1 := GuiObj.wGui-18
    h1 := 37
    t1 := 2
    Gdip_FillPolygon(G, pBrushDarkGrey, x1 "," y1 "|" x1+w1-1 "," y1 "|" x1+w1-t1-1 "," y1+t1 "|" x1+t1 "," y1+t1 "|" x1+t1 "," y1+h1-t1-1 "|" x1 "," y1+h1-1)
    Gdip_FillPolygon(G, pBrushWhite, x1+w1 "," y1+h1 "|" x1+w1 "," y1 "|" x1+w1-t1 "," y1+t1 "|" x1+w1-t1 "," y1+h1-t1 "|" x1+t1 "," y1+h1-t1 "|" x1 "," y1+h1)

    x1 := 9
    y1 := 52
    w1 := GuiObj.wGui-18
    h1 := GuiObj.hGui-52-9
    t1 := 3
    Gdip_FillPolygon(G, pBrushDarkGrey, x1 "," y1 "|" x1+w1-1 "," y1 "|" x1+w1-t1-1 "," y1+t1 "|" x1+t1 "," y1+t1 "|" x1+t1 "," y1+h1-t1-1 "|" x1 "," y1+h1-1)
    Gdip_FillPolygon(G, pBrushWhite, x1+w1 "," y1+h1 "|" x1+w1 "," y1 "|" x1+w1-t1 "," y1+t1 "|" x1+w1-t1 "," y1+h1-t1 "|" x1+t1 "," y1+h1-t1 "|" x1 "," y1+h1)

    x1 := 17
    y1 := 16
    w1 := 39
    h1 := 23
    Gdip_FillRectangle(G, pBrushDarkGrey, x1-1, y1-1, w1+1, h1+1)
    Gdip_FillRectangle(G, pBrushWhite, x1, y1, w1+1, h1+1)

    aBombs := StrSplit(GuiObj.BombNumber)
    Gdip_DrawImage(G, mpBitmap["Dig_" aBombs[1]], x1, y1, 13, 23)
    Gdip_DrawImage(G, mpBitmap["Dig_" aBombs[2]], x1+13, y1, 13, 23)
    Gdip_DrawImage(G, mpBitmap["Dig_" aBombs[3]], x1+26, y1, 13, 23)

    x1 := GuiObj.wGui-18-39
    y1 := 16
    w1 := 39
    h1 := 23
    Gdip_FillRectangle(G, pBrushDarkGrey, x1-1, y1-1, w1+1, h1+1)
    Gdip_FillRectangle(G, pBrushWhite, x1, y1, w1+1, h1+1)


    aTime := StrSplit(GuiObj.TimeNumber)
    Gdip_DrawImage(G, mpBitmap["Dig_" aTime[1]], x1, y1, 13, 23)
    Gdip_DrawImage(G, mpBitmap["Dig_" aTime[2]], x1+13, y1, 13, 23)
    Gdip_DrawImage(G, mpBitmap["Dig_" aTime[3]], x1+26, y1, 13, 23)

    Gdip_DrawImage(G, mpBitmap[GuiObj.oSmiley.Status],(GuiObj.wGui)/2 -13, 15,26,26)

    for CtrlObj in GuiObj.aControls
    {
        Gdip_DrawImage(G, mpBitmap[CtrlObj.Status], CtrlObj.x, CtrlObj.y,16,16)
    }

    UpdateLayeredWindow(GuiObj.Gui2.hwnd, hdc, 0, 0, GuiObj.wGui, GuiObj.hGui)
}

MineS_UpdateMenu(GuiObj){
    level := MineS_GetLevel(GuiObj)
    GuiObj.GameMenu.UnCheck("&Beginner")
    GuiObj.GameMenu.UnCheck("&Intermediate")
    GuiObj.GameMenu.UnCheck("&Expert")
    GuiObj.GameMenu.UnCheck("&Custom...")

    if (level = "Beginner"){
        GuiObj.GameMenu.Check("&Beginner")
    } else if (level = "Intermediate"){
        GuiObj.GameMenu.Check("&Intermediate")
    } else if (level = "Expert"){
        GuiObj.GameMenu.Check("&Expert")
    } else {
        GuiObj.GameMenu.Check("&Custom...")
    }
}

MineS_IniRead(Key,Default:=""){
    Return IniRead( "MineSweeper.ini", "MineSweeper", Key , Default)
}

MineS_IniWrite(Key,Value){
    IniWrite(Value, "MineSweeper.ini", "MineSweeper", Key)
}


Gui_CustomField(GuiObj){
    MyGui := Gui("+owner" GuiObj.Hwnd, "Custom Field")
    GuiObj.Opt("+Disabled")  ; Disable main window.
    MyGui.Opt("+Toolwindow -MaximizeBox -MinimizeBox")
    MyGui.Opt("+0x94C80000")
    MyGui.Opt("-Toolwindow")
    MyGui.AddText("xm y14 ", "&Height:")
    ogEditHeight := MyGui.AddEdit("x75 y11 w60 h20 +Number", GuiObj.Rows)
    MyGui.AddText("xm y49 ", "&Width:")
    ogEditWidth := MyGui.AddEdit("x75 y46 w60 h20 +Number", GuiObj.Columns)
    MyGui.AddText("xm y83 ", "&Mines:")
    ogEditMines := MyGui.AddEdit("x75 y80 w60 h20 +Number", GuiObj.Mines)
    MyGui.AddButton("x146 y39 w75 +Wrap +E0x4", "Cancel").OnEvent("Click", MyGui_Close)
    MyGui.AddButton("x146 y11 w75 +0x3 +0x9 +Default +Wrap +0x7 +E0x4", "OK").OnEvent("Click", MyGui_OK)

    MyGui.OnEvent("Close", MyGui_Close)
    MyGui.OnEvent("Escape", MyGui_Close)

    Gui_ShowCenter(MyGui, " w231 h111")

    MyGui_Close(*){
        GuiObj.Opt("-Disabled")  ; Re-enable the main window (must be done prior to the next step).
        MyGui.Destroy()  ; Destroy the about box.
    }
    MyGui_OK(*){
        NewRows := ogEditHeight.Value
        NewColumns := ogEditWidth.Value
        NewMines := Max(Min(ogEditMines.Value,NewRows*NewColumns),1)
        GuiObj.Opt("-Disabled")  ; Re-enable the main window (must be done prior to the next step).
        MyGui.Destroy()  ; Destroy the about box.
        MineS_New(GuiObj,NewRows,NewColumns,NewMines)
    }
}

Gui_AboutMineSweeper(GuiObj){

    MyGui := Gui("+owner" GuiObj.Hwnd, "About Minesweeper AHK")
    GuiObj.Opt("+Disabled")  ; Disable main window.
    MyGui.Opt("+Toolwindow -MaximizeBox -MinimizeBox")
    MyGui.Opt("+0x94C80000")
    MyGui.Opt("-Toolwindow")
    base64_MineS_32 :="AAABAAIAEBAQAAEABAAoAQAAJgAAACAgEAABAAQA6AIAAE4BAAAoAAAAEAAAACAAAAABAAQAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAgAAAAICAAIAAAACAAIAAgIAAAMDAwACAgIAAAAD/AAD/AAAA//8A/wAAAP8A/wD//wAA////AAAAAAAAAAAAAAAACAAAAAAHgAAIAACAAAB4AAAACAAAAAeIAAAAAAAACHiAAAAAAIiIhwAAAAAAj/d4eAAACICIj3f3CAAAAAAI93h4gAAAAIf/d4eAAAAIf4j3eIcAAACIAI+ACHAAAAAAj4AAgAAAAACPgAAAAAAAAAgAAAAA/H8AoMx3ugCEY7oAwAMAAOAHAADgDwAAAAEAAAABAAAAAQAA4A8AAMAHAACAAwAAzGMAAPx3AAD8fwAA/v8AACgAAAAgAAAAQAAAAAEABAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAACAAAAAgIAAgAAAAIAAgACAgAAAwMDAAICAgAAAAP8AAP8AAAD//wD/AAAA/wD/AP//AAD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIgAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAHgAAAAAAAAAAACAAAAAAACHgAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAICAgICAAAAAAAAAAAAAAAgICAgICAAAAAAAAAAAAACAgICAgICAAAAAAAAAAAAIiIiICAAACAAAAAAAAAAAiIiIiIAAAACAAAAAAAAIiHh4eHgAAAAACAAAAAAAh3eHh4eAiIgAAICAAACIgI//eHh4ePd4AAgICAAAAAAIiP+Hh4j3eACIgICAAAAAAACH93d4j/gIeIgIAAAAAAAAj393d4iHh4eIgIAAAAAAAIf393d3eHh4eAgAAAAAAAAI/393d3eHh4iAgAAAAAAACH/393d3eHh4CAAAAAAAAIh3/39/d3eHiIAAAAAAAAiHf//39/d3eHiAgAAAAAAHd/93f39/d4eAD4gAAAAAAH/3AHf393hwAAD4AAAAAAAHcAAAd/eHAAAAAAAAAAAAAAAAAAf3gAAAAAAAAAAAAAAAAAAH94AAAAAAAAAAAAAAAAAAB/eAAAAAAAAAAAAAAAAAAAB4gAAAAAAAAAD//j////wf///8H//54B8/8IAGH+AAAA/gAAAP8AAAH/gAAD/wAAA/8AAAH+AAAB/gAAAPgAAAAQAAAAAAAAAAAAAAAIAAAAHwAAAP8AAAH/AAAB/4AAA/+AAAP/AAAB/gAAAP4AAAD/DABh/58B8///g////4P///+D////x//w=="
    HBitmap := Gdip_CreateHBITMAPFromBitmap(Gdip_BitmapFromBase64(&base64_MineS_32))
    MyGui.AddPicture("x10 y10 w32 h32", "HBITMAP:*" HBitmap)
    MyGui.AddText("x+20 y20 w260","Based on Microsoft (R) Minesweeper`n`nThis product is freeware.`n`nThe goal in Minesweeper game is to free all the unmined squares, by clicking on them with the left button.`n`nThe numbered squares show the amount of squares around that contain a mine.`n`nYou can mark with a red flag the squares that contain a mine  you can check (or uncheck) it with a flag  using the right button of the mouse.")
    ThunderRT6CommandButton1 := MyGui.AddButton("x255 y+15 w75 +0x3 +0x9 +Default +Wrap +0x7 +E0x4", "OK")
    ThunderRT6CommandButton1.OnEvent("Click", MyGui_Close)
    MyGui.OnEvent("Close", MyGui_Close)
    MyGui.OnEvent("Escape", MyGui_Close)

    Gui_ShowCenter(MyGui, "")

    MyGui_Close(*){
        GuiObj.Opt("-Disabled")  ; Re-enable the main window (must be done prior to the next step).
        MyGui.Destroy()  ; Destroy the about box.
    }

}

Gui_Congratulations(GuiObj){

    Time := (A_TickCount - GuiObj.StartTime)/1000
    level := MineS_GetLevel(GuiObj)

    if (level = "Beginner"){
        RecordTime := GuiObj.RecordBegTime
        RecordName := GuiObj.RecordBegName
    } else if (level = "Intermediate"){
        RecordTime := GuiObj.RecordIntTime
        RecordName := GuiObj.RecordIntName
    } else if (level = "Expert"){
        RecordTime := GuiObj.RecordExpTime
        RecordName := GuiObj.RecordExpName
    } else {
        return
    }
    if (Time > RecordTime){
        return
    }
    MyGui := Gui("+owner" GuiObj.Hwnd, "Congratulations")
    GuiObj.Opt("+Disabled")  ; Disable main window.
    MyGui.Opt("+Toolwindow -MaximizeBox -MinimizeBox")
    MyGui.Opt("+0x94C80000")
    MyGui.Opt("-Toolwindow")

    MyGui.AddText("","You have the fasted time for " level " `nlevel.Please type your name")
    OgEditName := MyGui.AddEdit("x11 y49 w201 h20 +0x40 +E0x4", RecordName)
    ThunderRT6CommandButton1 := MyGui.AddButton("x137 y80 w75 +Wrap +E0x4", "OK")
    ThunderRT6CommandButton1.OnEvent("Click", MyGui_OK)
    MyGui.OnEvent("Close", MyGui_Close)
    MyGui.OnEvent("Escape", MyGui_Close)

    Gui_ShowCenter(MyGui, " w222 h110")

    MyGui_Close(*){
        GuiObj.Opt("-Disabled")  ; Re-enable the main window (must be done prior to the next step).
        MyGui.Destroy()  ; Destroy the about box.
    }
    MyGui_OK(*){
        if (level = "Beginner"){
            GuiObj.RecordBegTime := Time
            GuiObj.RecordBegName := OgEditName.Value
        } else if (level = "Intermediate"){
            GuiObj.RecordIntTime := Time
            GuiObj.RecordIntName := OgEditName.Value
        } else if (level = "Expert"){
            GuiObj.RecordExpTime := Time
            GuiObj.RecordExpName := OgEditName.Value
        }

        GuiObj.Opt("-Disabled")  ; Re-enable the main window (must be done prior to the next step).
        MyGui.Destroy()  ; Destroy the about box.
    }

}

Gui_ShowCenter(GuiObj, Options){
    ; Centers the Gui in the monitor where the mouse is

    ; If 1 monitor, do a normal show
    MonitorCount := SysGet(80)
    if (MonitorCount=1 or (InStr(" " Options," x") and InStr(" " Options," y"))){
        GuiObj.Show(Options)
        return
    }

    GuiObj.Show(Options (InStr(" " Options " ", " Hide ") ? "" : " Hide"))

    ; Get the monitor of the mouse
    CoordMode("Mouse", "Screen")
	MouseGetPos(&mx, &my)
    CurrentMonitorIndex:= 1
	Loop MonitorCount{
		MonitorGet(A_Index, &monitorLeft, &monitorTop, &monitorRight, &monitorBottom)
		if (monitorLeft <= mx && mx <= monitorRight && monitorTop <= my && my <= monitorBottom){
            break
		}
    }

    ; Get Size of Gui window
    RC := Buffer(16)
    DllCall("GetClientRect", "uint", GuiObj.hwnd, "Ptr", rc)
    w := NumGet(rc, 8, "int")
    h := NumGet(rc, 12, "int")

    GuiObj.Show("x" (( monitorRight-monitorLeft - w ) / 2) + monitorLeft " y" (monitorBottom-monitorTop - 30 - h ) / 2 (InStr(" " Options " ", " Hide ") ? " Hide" : ""))
}
