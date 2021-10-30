#include 'CommMG.au3'
#include <GUIConstants.au3>
#include <GuiComboBox.au3>
#include <Array.au3>
#include <MsgBoxConstants.au3>

;HotKeySet("{ESC}", "alldone")

Const $maintitle = "Конфигуратор ZX Unikeyboard"
Const $settitle = "Настройка COM-порта"
Const $headerfilename = "customkey.h"
Const $nSearchMax = 30

Const $nCoord1 = 0 
Const $nCoord2 = 1
Const $nMark = 2
Const $nName = 3
Const $nExclude = 1


Global $nStartReading = 0	;key reading process flag
Global $aKeyArray		;array of key names to read
Global $nNextKey = 0		;next key number while reading the keyboard

$nKeyCount=0			;scanned keys counter
Dim $LineTable[200][4]		;scanned lines table to analyze and split them to cols and rows (up to 200 possible keys [col;row;excl_mark] each)

; MAIN FORM *******************************************************************************
$Form1 = GUICreate($maintitle, 490, 350, 100, 100, BitOR($WS_MAXIMIZEBOX, $WS_MINIMIZEBOX, $WS_SIZEBOX, $WS_THICKFRAME, $WS_SYSMENU, $WS_CAPTION, $WS_OVERLAPPEDWINDOW, $WS_TILEDWINDOW, $WS_POPUP, $WS_POPUPWINDOW, $WS_GROUP, $WS_TABSTOP, $WS_BORDER, $WS_CLIPSIBLINGS))
$Edit1 = GUICtrlCreateEdit("", 254, 20, 220, 320, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_READONLY, $ES_WANTRETURN, $WS_HSCROLL, $WS_VSCROLL))
$BtnSetPort = GUICtrlCreateButton("COM-port", 16, 312, 105, 30, $BS_FLAT)
GUICtrlSetColor(-1, 0x008000)
$BtnAbout = GUICtrlCreateButton("О программе", 131, 312, 105, 30, $BS_FLAT)
GUICtrlSetColor(-1, 0x008000)
$BtnEditTemplate = GUICtrlCreateButton("Изменить клавиатурный шаблон", 16, 20, 220, 30, $BS_FLAT)
GUICtrlSetColor(-1, 0x008000)
$BtnOpenTemplate = GUICtrlCreateButton("Открыть клавиатурный шаблон", 16, 60, 220, 30, $BS_FLAT)
GUICtrlSetColor(-1, 0x008000)
$BtnStartReading = GUICtrlCreateButton("Начать считывание клавиш", 16, 100, 220, 30, $BS_FLAT)
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetState(-1, $GUI_DISABLE)
$LabelStart = GUICtrlCreateLabel("Нажмите клавишу:", 26, 140, 200, 30)
GUICtrlSetFont(-1, 10, 400, 0, "MS Sans Serif")
GUICtrlSetColor(-1, 0xE00000)
GUICtrlSetState(-1, $GUI_HIDE)
$Key2Find = GUICtrlCreateLabel("", 16, 155, 180, 30)
GUICtrlSetFont(-1, 16, 400, 0, "MS Sans Serif")
GUICtrlSetStyle(-1, $SS_CENTER)
GUICtrlSetState(-1, $GUI_HIDE)
$LabelRead = GUICtrlCreateLabel("Прочитано: ", 26, 200, 60, 30)
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetState(-1, $GUI_HIDE)
$KeysRead = GUICtrlCreateLabel("", 90, 200, 40, 30)
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetState(-1, $GUI_HIDE)
$LabelLeft = GUICtrlCreateLabel("Осталось: ", 130, 200, 60, 30)
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetState(-1, $GUI_HIDE)
$KeysLeft = GUICtrlCreateLabel("", 190, 200, 40, 30)
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetState(-1, $GUI_HIDE)
$BtnAnalyze = GUICtrlCreateButton("Анализировать", 16, 240, 220, 50, $BS_FLAT)
GUICtrlSetColor(-1, 0x008000)
GUICtrlSetState(-1, $GUI_DISABLE)
GUISetState(@SW_SHOW)
; MAIN FORM *******************************************************************************


While setport(0) = -1
    If MsgBox(4, 'Конфигурирование порта не завершено !', 'Выйти из программмы ?') = 6 Then Exit
WEnd

Events()
_CommSetXonXoffProperties(11, 13, 100, 100)
GUICtrlSetState($Edit1, $GUI_FOCUS)

While 1

    if ($nStartReading = 1) and ($nNextKey < UBound($aKeyArray) ) Then
      GUICtrlSetData ($Key2Find, $aKeyArray[$nNextKey])
      GUICtrlSetData ($KeysRead, $nNextKey)
      GUICtrlSetData ($KeysLeft, UBound($aKeyArray)-$nNextKey)
    Else
      $nStartReading = 0
      GUICtrlSetData ($Key2Find, '')
      GUICtrlSetState($LabelStart, $GUI_HIDE)
      GUICtrlSetState($Key2Find, $GUI_HIDE)
      GUICtrlSetState($LabelRead, $GUI_HIDE)
      GUICtrlSetState($labelLeft, $GUI_HIDE)
      GUICtrlSetState($KeysRead, $GUI_HIDE)
      GUICtrlSetState($KeysLeft, $GUI_HIDE)
    EndIf

    if ($nNextKey = UBound($aKeyArray)) and (UBound($aKeyArray) > 0) Then
         GUICtrlSetState($BtnStartReading, $GUI_DISABLE)
         GUICtrlSetState($BtnAnalyze, $GUI_ENABLE)
         $nNextKey = 0
         If MsgBox($MB_SYSTEMMODAL+$MB_OKCANCEL+$MB_ICONQUESTION, "Успешно", UBound ($aKeyArray) & " клавиш было прочитано." & @CRLF _
             & "Начнем анализировать полученные данные ?") = $IDOK then AnalyzeEvent ()  
         $nStartReading = 0
    endIf
                                  
    $instr = _CommGetString()

    If ($instr <> '') and ($nStartReading = 1) Then

         $aSubExp = StringRegExp ($instr, '\D*(\d*)\D*(\d*)', 1);
           if @error=0 then
               GUICtrlSetData ($Edit1, "{ KEY_" & $aKeyArray[$nNextKey] & ", " & $aSubExp[0] & ", " & $aSubExp[1] & " }," & @CRLF, 1)
                $LineTable[$nKeyCount][$nCoord1] = $aSubExp[0]
                $LineTable[$nKeyCount][$nCoord2] = $aSubExp[1]
                $LineTable[$nKeyCount][$nMark] = 0
                $LineTable[$nKeyCount][$nName] = $aKeyArray[$nNextKey]
                $nKeyCount = $nKeyCount + 1
           endif

        $nNextKey = $nNextKey + 1
    Else
        Sleep(20)
    EndIf

WEnd

Alldone()


; MAIN FORM *******************************************************************************
Func Events()
    Opt("GUIOnEventMode", 1)
    GUISetOnEvent($GUI_EVENT_CLOSE, "justgo")
    GUICtrlSetOnEvent($BtnSetPort, "SetPortEvent")
    GUICtrlSetOnEvent($BtnEditTemplate, "EditFileEvent")
    GUICtrlSetOnEvent($BtnOpenTemplate, "OpenFileEvent")
    GUICtrlSetOnEvent($BtnStartReading, "KeyReadEvent")
    GUICtrlSetOnEvent($BtnAnalyze, "AnalyzeEvent")
    GUICtrlSetOnEvent($BtnAbout, "AboutEvent")
EndFunc   ;==>Events

; Set COM Port handler ********************************************************************
Func SetPortEvent()
    setport();needed because a parameter is optional for setport so we can't use "setport" for the event
EndFunc   ;==>SetPortEvent


; About button handler ********************************************************************
Func AboutEvent()
          MsgBox($MB_SYSTEMMODAL + $MB_ICONINFORMATION, "О программе", "ZX UniKeyboard Configuration Utility" & @CRLF & @CRLF & _
          "https://github.com/valerium-labs/zx-unikeyboard" & @CRLF & _
          "valerium@rambler.ru" & @CRLF & _
          "Chelyabinsk, Russia, 2021")
EndFunc   ;==>AboutEvent



; Template file open handler **************************************************************
Func OpenFileEvent()
    GUICtrlSetState($BtnStartReading, $GUI_DISABLE)             
    $sFile = FileOpenDialog("Выберите файл шаблона клавиатуры...", ".\Template", "(*.txt)")
    if $sFile <> '' Then
	$aKeyArray = FileReadToArray($sFile)
	If UBound ($aKeyArray)>0 Then
            MsgBox($MB_SYSTEMMODAL, "Load OK", UBound ($aKeyArray) & " клавиш считано")
            GUICtrlSetState($BtnStartReading, $GUI_ENABLE)             
            GUICtrlSetState($BtnAnalyze, $GUI_DISABLE)
        EndIf	
    EndIf
EndFunc   ;==>OpenFileEvent

; Template file editor handler ************************************************************
Func EditFileEvent()
    $sFile = FileOpenDialog("Выберите файл шаблона для изменения...", ".\Template", "(*.txt)")
    if $sFile <> '' Then
            run ("notepad.exe " & $sFile)
    EndIf
EndFunc   ;==>EditFileEvent


; Start reading keys handler **************************************************************
Func KeyReadEvent()
    GUICtrlSetState($LabelStart, $GUI_SHOW)
    GUICtrlSetState($Key2Find, $GUI_SHOW)
    GUICtrlSetData($Edit1, "")
    GUICtrlSetState($LabelRead, $GUI_SHOW)
    GUICtrlSetState($LabelLeft, $GUI_SHOW)
    GUICtrlSetState($KeysRead, $GUI_SHOW)
    GUICtrlSetState($KeysLeft, $GUI_SHOW)
    $nNextKey = 0
    $nKeyCount=0
    $nStartReading = 1
    GUICtrlSetState($BtnAnalyze, $GUI_DISABLE)

EndFunc   ;==>KeyReadEvent

                                                               
; Collected data analyzer *****************************************************************
Func AnalyzeEvent()

 local $nCols[$nSearchMax]
 local $nColCount=0
 local $nRows[$nSearchMax]
 local $nRowCount=0

 for $i = 0 to $nKeyCount-1	;очищаем все пометки, установленные в предыдущих запусках анализа
   $LineTable[$i][$nMark] = 0
 next

 if $nKeyCount >0 then
   $nCols[0] = int ($LineTable[0][$nCoord1])
   $nColCount = $nColCount + 1
   $nRows[0] = int ($LineTable[0][$nCoord2])
   $nRowCount = $nRowCount + 1
   $LineTable[0][$nMark] = $nExclude

  for $i = 0 to $nSearchMax ;выполняем $nSearchMax (30) циклов поиска
    for $line = 1 to $nKeyCount    ;в каждом цикле перебираем все строки, кроме первой назначенной
      if $LineTable[$line][$nMark] = 0 then   ;рассматриваем только ранее не отмеченные строки

             ;если первая координата найдена в массиве столбцов и не найдена вторая в столбцах
             if _ArraySearch ($nCols, int ($LineTable[$line][$nCoord1])) <> -1 and _ 
                     _ArraySearch ($nRows, int ($LineTable[$line][$nCoord2])) = -1 then
                $nRows[$nRowCount] = int ($LineTable[$line][$nCoord2])              ;запоминаем вторую координату в массиве строк
                $nRowCount = $nRowCount + 1
                $LineTable[$line][$nMark] = $nExclude                               ;ставим отметку на строке для исключения из поиска далее
             endif

             ;если первая координата найдена в массиве строк и не найдена вторая в строках
             if _ArraySearch ($nRows, int ($LineTable[$line][$nCoord1])) <> -1 and _
                     _ArraySearch ($nCols, int ($LineTable[$line][$nCoord2])) = -1 then
                $nCols[$nColCount] = int ($LineTable[$line][$nCoord2])              ;запоминаем вторую координату в массиве столбцов
                $nColCount = $nColCount + 1
                $LineTable[$line][$nMark] = $nExclude                               ;ставим отметку на строке для исключения из поиска далее
             endif

             ;если вторая координата найдена в массиве столбцов и не найдена первая в строках
             if _ArraySearch ($nCols, int ($LineTable[$line][$nCoord2])) <> -1 and _
                     _ArraySearch ($nRows, int ($LineTable[$line][$nCoord1])) = -1 then
                $nRows[$nRowCount] = int ($LineTable[$line][$nCoord1])              ;запоминаем первую координату в массиве строк
                $nRowCount = $nRowCount + 1
                $LineTable[$line][$nMark] = $nExclude                               ;ставим отметку на строке для исключения из поиска далее
             endif

             ;если вторая координата найдена в массиве строк и не найдена первая в столбцах
             if _ArraySearch ($nRows, int ($LineTable[$line][$nCoord2])) <> -1 and _ 
                     _ArraySearch ($nCols, int ($LineTable[$line][$nCoord1])) = -1 then
                $nCols[$nColCount] = int ($LineTable[$line][$nCoord1])              ;запоминаем первую координату в массиве столбцов
                $nColCount = $nColCount + 1
                $LineTable[$line][$nMark] = $nExclude                               ;ставим отметку на строке для исключения из поиска далее
             endif

            ;если вторая найдена в строках и первая в столбцах
            ;или если первая найдена в строках и вторая в столбцах
            if ((_ArraySearch ($nRows, int ($LineTable[$line][$nCoord2])) <> -1) and (_ArraySearch ($nCols, int ($LineTable[$line][$nCoord1])) <> -1)) or _
               ((_ArraySearch ($nRows, int ($LineTable[$line][$nCoord1])) <> -1) and (_ArraySearch ($nCols, int ($LineTable[$line][$nCoord2])) <> -1)) then
                $LineTable[$line][$nMark] = $nExclude                               ;ставим отметку на строке для исключения из поиска далее
            endif
    
       endif
    next
  next
 endif
 
; _ArrayDisplay ($LineTable) 
 _ArraySort ($nCols, 0, 0, $nColCount-1)
; _ArrayDisplay ($nCols)
 _ArraySort ($nRows, 0, 0, $nRowCount-1)
; _ArrayDisplay ($nRows)


    $unbound = ""
    for $line = 0 to $nKeyCount-1
       if $LineTable[$line][2] = 0 then $unbound = $unbound & $LineTable[$line][$nName] & " (" & $LineTable[$line][$nCoord1] & "," & $LineTable[$line][$nCoord2] & ")" & @CRLF
    next
    if $unbound <> "" then  MsgBox(BitOR ($MB_SYSTEMMODAL, $MB_ICONWARNING), "Предупреждение !", "Остались клавиши, не привязанные к столбцам и строкам: "& @CRLF & $unbound & @CRLF & _
               "Это нормально, если есть строка и стобец " & @CRLF & "которые содержит только одну клавишу в строке и одну в столбце" & _ 
               @CRLF & "или же была ошибка в клавиатурном шаблоне или при считывании клавиш" & @CRLF & @CRLF &"Проверьте и распределите эти линии по строкам/столбцам вручную")


    $sFile = FileSaveDialog("Выберите каталог для сохранения header-файла к рабочей прошивке...", @ScriptDir, "(*.h)", 16, "customkey.h")
    if @error then 
         MsgBox(BitOR ($MB_SYSTEMMODAL, $MB_ICONWARNING), "Внимание !" ,'Файл не был сохранен. Нажмите "Анализировать" заново, чтобы создать и сохранить файл.')
    else
       $hFile = FileOpen($sFile, 2)                                
    
        for $i = 0 To UBound($aKeyArray) - 1
           FileWrite($hFile, "#define KEY_" & $aKeyArray[$i] & " " & $i & @CRLF)
        next
    
       FileWrite ($hFile, @CRLF & "const uint8_t keyaddr[][3] =" & @CRLF & "{" & @CRLF)
       FileWrite($hFile, GUICtrlRead ($Edit1))
       FileWrite ($hFile, "};" & @CRLF & @CRLF)
    
       if $nColCount < $nRowCount then
         FileWrite ($hFile, "#define COLS_MAX " & $nColCount & @CRLF)
         FileWrite ($hFile, "#define ROWS_MAX " & $nRowCount & @CRLF & @CRLF)
         FileWrite ($hFile, "const uint8_t cols[COLS_MAX] = " & @CRLF & "{" & @CRLF)
    
           for $i = 0 to $nColCount-1
             if $i >0 then FileWrite ($hFile, ", ")
             FileWrite ($hFile, $nCols[$i])
           next
         
           FileWrite ($hFile, @CRLF &"};" & @CRLF & @CRLF)
         
           FileWrite ($hFile, "const uint8_t rows[ROWS_MAX] = " & @CRLF & "{" & @CRLF)
         
           for $i = 0 to $nRowCount-1
             if $i >0 then FileWrite ($hFile, ", ")
             FileWrite ($hFile, $nRows[$i])
           next
         
           FileWrite ($hFile, @CRLF & "};" & @CRLF & @CRLF)
        else
         FileWrite ($hFile, "#define COLS_MAX " & $nRowCount & @CRLF)
         FileWrite ($hFile, "#define ROWS_MAX " & $nColCount & @CRLF & @CRLF)
         FileWrite ($hFile, "const uint8_t rows[ROWS_MAX] = " & @CRLF & "{" & @CRLF)
    
           for $i = 0 to $nColCount-1
             if $i >0 then FileWrite ($hFile, ", ")
             FileWrite ($hFile, $nCols[$i])
           next
         
           FileWrite ($hFile, @CRLF &"};" & @CRLF & @CRLF)
         
           FileWrite ($hFile, "const uint8_t cols[COLS_MAX] = " & @CRLF & "{" & @CRLF)
         
           for $i = 0 to $nRowCount-1
             if $i >0 then FileWrite ($hFile, ", ")
             FileWrite ($hFile, $nRows[$i])
           next
         
           FileWrite ($hFile, @CRLF & "};" & @CRLF & @CRLF)
        endif
    
       FileClose($hFile)

    GUICtrlSetState($BtnAnalyze, $GUI_DISABLE)
    MsgBox(BitOR ($MB_SYSTEMMODAL, $MB_ICONINFORMATION), "Поздравляем !", "Успешно сформирован header-файл" )
    endif
EndFunc   ;==>Analyze


; CloseWindow handler *********************************************************************
Func justgo()
    Exit
EndFunc   ;==>justgo


; Exit on ESCAPE button press *************************************************************
Func AllDone()
    _Commcloseport(true)
    Exit               
EndFunc   ;==>AllDone


;Function SetPort($mode=1)   **************************************************************
;Creates a form for the port settings
;Parameter $mode sets the return value depending on whether the port was set
;Returns  0 if $mode <> 1
;          -1 If` the port not set and $mode is 1
Func SetPort($mode = 1);if $mode = 1 then returns -1 if settings not made

    Dim $FlowType[3] = ["Hardware (RTS, CTS)", "XOn/XOff", "NONE"]
    Dim $ParityType[5] = ["NONE", "ODD", "EVEN", "MARK", "SPACE"]

    Local $sportSetError
    Opt("GUIOnEventMode", 0);keep events for $Form1, use GuiGetMsg for $Form2

    $Form2 = GUICreate("COM port setting", 422, 279, 329, 268, BitOR($WS_MINIMIZEBOX, $WS_CAPTION, $WS_POPUP, $WS_GROUP, $WS_BORDER, $WS_CLIPSIBLINGS, $DS_MODALFRAME), BitOR($WS_EX_TOPMOST, $WS_EX_WINDOWEDGE))
    $Group1 = GUICtrlCreateGroup("Параметры порта", 18, 8, 288, 252)
    $CmboPortsAvailable = GUICtrlCreateCombo("", 127, 28, 145, 25, BitOR($GUI_SS_DEFAULT_COMBO, $CBS_SORT))
    $CmBoBaud = GUICtrlCreateCombo("115200", 127, 66, 145, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL, $CBS_SORT, $WS_VSCROLL))
    GUICtrlSetData(-1, "  9600| 19200| 38400| 57600")
    $CmBoStop = GUICtrlCreateCombo("1", 127, 141, 145, 25)
    GUICtrlSetData(-1, "2|1.5")
    $CmBoParity = GUICtrlCreateCombo("", 127, 178, 145, 25)
    GUICtrlSetData(-1, "NONE|ODD|EVEN|MARK|SPACE")
    GUICtrlSetData(-1, "none")
    $Label2 = GUICtrlCreateLabel("Port", 94, 32, 23, 17)
    $Label3 = GUICtrlCreateLabel("Baud", 89, 70, 28, 17)
    $Label4 = GUICtrlCreateLabel("Stop bits", 75, 145, 50, 17)
    $Label5 = GUICtrlCreateLabel("Parity", 88, 182, 29, 17)
    $CmboDataBits = GUICtrlCreateCombo("8", 127, 103, 145, 25)
    GUICtrlSetData(-1, "7")
    $Label7 = GUICtrlCreateLabel("No. of Data Bits", 41, 107, 79, 17)
    $ComboFlow = GUICtrlCreateCombo("NONE", 127, 216, 145, 25)
    GUICtrlSetData(-1, "Hardware (RTS, CTS)|XOn/XOff")
    $Label1 = GUICtrlCreateLabel("Flow control", 59, 220, 58, 17)
    GUICtrlCreateGroup("", -99, -99, 1, 1)
    $BtnApply = GUICtrlCreateButton("OK", 315, 95, 75, 35, $BS_FLAT)
    GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")
    $BtnCancel = GUICtrlCreateButton("Отмена", 316, 147, 76, 35, $BS_FLAT)
    GUICtrlSetFont(-1, 12, 400, 0, "MS Sans Serif")
    GUISetState(@SW_SHOW)

    WinSetTitle($Form2, "", $settitle);ensure a change to Koda design doesn't stop script working
    $mainxy = WinGetPos($Form1)
    WinMove($Form2, "", $mainxy[0] + 20, $mainxy[1] + 20)

    $portlist = _CommListPorts(0);find the available COM ports and write them into the ports combo
    If @error = 1 Then
        MsgBox(0, 'Не удаест полчить список портов', 'Программа будет завершена')
        Exit
    EndIf

    For $pl = 1 To $portlist[0]
        $portnum = StringReplace($portlist[$pl], "COM", '')
        if StringLen($portnum) = 1 then $portnum = $portnum & ' '
        $portlist[$pl] = 'COM' & $portnum
        GUICtrlSetData($CmboPortsAvailable, $portlist[$pl]);_CommListPorts())
    Next
    GUICtrlSetData($CmboPortsAvailable, $portlist[1]);show the first port found

    _GUICtrlComboBox_SetMinVisible($CmBoBaud, 10);restrict the length of the drop-down list


    $retval = 0

    While 1
        $msg = GUIGetMsg()
        If $msg = $BtnCancel Then
            If Not $mode Then $retval = -1
            ExitLoop
        EndIf


        If $msg = $BtnApply Then

            $comboflowsel = GUICtrlRead($ComboFlow)
            For $n = 0 To 2
                If $comboflowsel = $FlowType[$n] Then
                    $setflow = $n
                    ConsoleWrite("flow = " & $setflow & @CRLF)
                    ExitLoop
                EndIf

            Next
            $setport = StringReplace(GUICtrlRead($CmboPortsAvailable), 'COM', '')


            $ParitySel = GUICtrlRead($CmBoParity)
            For $n = 0 To 4
                If $ParitySel = $ParityType[$n] Then
                    $SetParity = $n
                    ExitLoop
                EndIf
            Next

            $setStop = StringReplace(GUICtrlRead($CmBoStop), '.', '');replace 1.5 with 15 if needed

            $resOpen = _CommSetPort($setport, $sportSetError, GUICtrlRead(StringReplace($CmBoBaud, ' ','')), GUICtrlRead($CmboDataBits), $SetParity, $setStop, $setflow)

            if $resOpen = 0 then
                Exit
            EndIf

            Sleep(1000)
            ;next
            $mode = 1;
            ExitLoop
        EndIf

        ;stop user switching back to $Form1
        If WinActive($maintitle) Then
            If WinActivate($settitle) = 0 Then MsgBox(0, 'not found', $settitle)
        EndIf

    WEnd
    GUIDelete($Form2)
    WinActivate($maintitle)
    Events()
    Return $retval
 
EndFunc   ;==>SetPort
