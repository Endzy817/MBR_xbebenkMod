; #FUNCTION# ====================================================================================================================
; Name ..........: EndzyMod
; Description ...:
; Syntax ........:
; Parameters ....: None
; Return values .: None
; Author ........:
; Modified ......: Endzy (2022)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

#cs
#Region - Search NoLeague for DeadBase - Endzy
Func TestCheckDeadBase()
	Local $dbBase
	;_CaptureRegion2()
	If QuickMIS("BC1", $g_sImgChkLeague, 10, 15, 44, 47, True, $g_bDebugImageSave) Then
		If $g_bChkNoLeague[$DB] Then
			If SearchNoLeague() Then
				SetLog("Dead Base is in No League, match found !", $COLOR_SUCCESS)
				$dbBase = True
			ElseIf $g_iSearchCount > 50 Then
				$dbBase = checkDeadBase()
			Else
				SetLog("Dead Base is in a League, skipping search !", $COLOR_INFO)
				$dbBase = False
			EndIf
		Else
			$dbBase = checkDeadBase()
		EndIf
	EndIf

	Return $dbBase
EndFunc   ;==>TestCheckDeadBase

Func SearchNoLeague($bCheckOneTime = False)
	If _Sleep($DELAYSPECIALCLICK1) Then Return False

	Local $bReturn = False

	$bReturn = _WaitForCheckImg($g_sImgNoLeague, "3,4,47,53", Default, ($bCheckOneTime = False) ? (500) : (0))

	If $g_bDebugSetlog Then
		SetDebugLog("SearchNoLeague: Is no league? " & $bReturn, $COLOR_DEBUG)
	EndIf

	Return $bReturn
EndFunc   ;==>SearchNoLeague
#EndRegion - Search NoLeague for DeadBase - Endzy
#ce
Func TestAttack() ;Endzy
	If _Sleep(300) Then Return
	PureClick(20,350)
	If _Sleep(1000) Then Return
	PureClick(230,580)
	If _Sleep(1000) Then Return
	PureClick(680,430)
	If _Sleep(1000) Then Return
	For $x = 0 To 5
		_Sleep(1000)
		If QuickMIS("BC1", $g_sImgFCsurr, 14, 520, 129, 560, True, $g_bDebugImageSave) Then
			SetLog("Found Surrender Button, PrepareAttack now!", $COLOR_INFO)
			PrepareAttack($g_iMatchMode)
			_Sleep(1000)
			ExitLoop
		EndIf
	Next
	If _Sleep(1000) Then Return
	$g_bAttackActive = True
	SetLog(" ====== Start Attack ====== ", $COLOR_SUCCESS)
	If ($g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 1) Or ($g_iMatchMode = $LB And $g_aiAttackAlgorithm[$LB] = 1) Then
		SetDebugLog("start scripted attack", $COLOR_ERROR)
		Algorithm_AttackCSV()
		If Not $g_bRunState Then Return
		If _Sleep(20000) Then Return
		PureClick(70,540)
		If _Sleep(1200) Then Return
		PureClick(530,400)
		If _Sleep(2000) Then Return
		PureClick(440,480)
		If _Sleep(1000) Then Return
	ElseIf $g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 2 Then
		SetDebugLog("start smart farm attack", $COLOR_ERROR)
		; Variable to return : $Return[3]  [0] = To attack InSide  [1] = Quant. Sides  [2] = Name Sides
		Local $Nside = ChkSmartFarm()
		If Not $g_bRunState Then Return
		AttackSmartFarm($Nside[1], $Nside[2])
	Else
		SetDebugLog("start standard attack", $COLOR_ERROR)
		algorithm_AllTroops()
		If Not $g_bRunState Then Return
		If _Sleep(15000) Then Return
		PureClick(70,540)
		If _Sleep(1200) Then Return
		PureClick(530,400)
		If _Sleep(2000) Then Return
		PureClick(440,480)
		If _Sleep(1000) Then Return
	EndIf
	$g_bAttackActive = False
EndFunc ;==>TestAttack

#Region - For MainLoop - Endzy
#cs
Func OptimizedUpgrade()

	If $g_iFreeBuilderCount > 0 And _ColorCheck(_GetPixelColor(709, 29, True), Hex(0xF4DD72, 6), 1) Or _ColorCheck(_GetPixelColor(702, 83, True), Hex(0xC027C0, 6), 1) Then
		SetLog("Gold/Elixir storages are 70% full.", $COLOR_SUCCESS)
		SetLog ("Starting AutoUpgrade & UpgradeWall now...", $COLOR_SUCCESS)
		Local $aRndFuncList = ['UpgradeBuilding', 'UpgradeWall']
		For $Index In $aRndFuncList
			If Not $g_bRunState Then Return
			_RunFunction($Index)
			If _Sleep(100) Then Return
			If $g_bRestart Then Return
		Next
		;SetLog("Gold/Elixir storages are 70% full.", $COLOR_SUCCESS)
		;SetLog ("Starting AutoUpgrade & UpgradeWall now...", $COLOR_SUCCESS)
		;AutoUpgrade()
		;_Sleep($DELAYRUNBOT3)
		;If Not $g_bRunState Then Return
		;_RunFunction('UpgradeWall')
	Else
		SetLog("Gold/Elixir is not 70% full, skipping AutoUpgrade & UpgradeWall.", $COLOR_INFO)
	EndIf

EndFunc   ;==>OptimizedUpgrade

Func RoutineBeforeSwitch()

	If $g_iFreeBuilderCount > 0 Then
		Setlog("Your account is on Halt Attack & have FREE BUILDER/S & full Storages!", $COLOR_INFO)
		If Not $g_bRunState Then Return
		_RunFunction('CleanYard')
		_Sleep(8000) ;add wait after clean yard
		If Not $g_bRunState Then Return

		SetLog("Doing AutoUpgrade now!", $COLOR_INFO)
		AutoUpgrade()
		_Sleep(1000)
		VillageReport()
		ZoomOut()
		If Not $g_bRunState Then Return

		SetLog("Doing Upgrade Wall now!", $COLOR_INFO)
		UpgradeWall()
	EndIf

EndFunc  ;==>RoutineBeforeSwitch
#ce
#EndRegion - For MainLoop - Endzy

Func CheckLeague() ;little humanization
; No gui, hardcoded humanization
	If IsMainPage() Then
		If QuickMIS("BC1", $g_sImgChkLeague, 49, 64, 65, 83, True, $g_bDebugImageSave) Then ;QuickMIS("BC1", $g_sImgChkLeague, 19, 68, 64, 110, True, $g_bDebugImageSave) Then
			SetLog("You are in a New League!", $COLOR_INFO)
			SetLog("Checking League now!", $COLOR_INFO)
			;Click Trophy symbol/logo
			Click(Random(20, 55, 1), Random(90, 105, 1), 1, 0, "Endzy is still learning") ;Exact click is Click(36,95)
			; Wait for Okay button
			If _Wait4Pixel(443, 559, 0xDFF885, 25, 3000) Then
				; Click Okay
				Click(Random(400, 500, 1), Random(560, 590, 1), 1, 0, "#0222") ;Exact click is Click(460,570)
				If _Sleep(2000) Then Return
				; Click [X] close
				Click(Random(810, 840, 1), Random(45, 55, 1), 1, 0, "#0223") ;Exact click is Click(810,40)
				If _Sleep(500) Then Return
				; ClickAway just to make sure
				ClickAway()
			Else
				If _Sleep(Random(1500,2500,1)) Then Return
				Click(Random(810, 840, 1), Random(45, 55, 1), 1, 0, "#0223") ;Exact click is Click(810,40)
				If _Sleep(500) Then Return
				ClickAway()
			EndIf
		EndIf
	EndIf

EndFunc  ;==>CheckLeague
; Endzy - randomSleep function
Func randomSleep($iSleepTime, $iRange = Default)
	If Not $g_bRunState Or $g_bRestart Then Return
	If $iRange = Default Then $iRange = $iSleepTime * 0.20
	Local $iSleepTimeF = Abs(Round($iSleepTime + Random( -Abs($iRange), Abs($iRange))))
	If $g_bDebugClick Or $g_bDebugSetlog Then SetLog("Default sleep : " & $iSleepTime & " - Random sleep : " & $iSleepTimeF, $COLOR_ACTION)
	Return _Sleep($iSleepTimeF)
EndFunc   ;==>randomSleep

Func _GUICtrlCreateInput($sText, $iLeft, $iTop, $iWidth, $iHeight, $vStyle = -1, $vExStyle = -1)
	Local $hReturn = GUICtrlCreateInput($sText, $iLeft, $iTop, $iWidth, $iHeight, $vStyle, $vExStyle)
	GUICtrlSetBkColor($hReturn, 0xD1DFE7)
	Return $hReturn
EndFunc   ;==>_GUICtrlCreateInput