; #FUNCTION# ====================================================================================================================
; Name ..........: Laboratory
; Description ...:
; Syntax ........: Laboratory()
; Parameters ....:
; Return values .: None
; Author ........: summoner
; Modified ......: KnowJack (06/2015), Sardo (08/2015), Monkeyhunter(04/2016), MMHK(06/2018), Chilly-Chill (12/2019), xbenk (02/2021)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Local $iSlotWidth = 107, $iDistBetweenSlots = 12, $iYMidPoint = 460; use for logic to upgrade troops.. good for generic-ness
Local $iPicsPerPage = 12, $iPages = 4 ; use to know exactly which page the users choice is on
Local $sLabWindow = "99,122,760,616", $sLabTroopsSection = "110,340,740,540"
Local $sLabWindowDiam = GetDiamondFromRect($sLabWindow), $sLabTroopsSectionDiam = GetDiamondFromRect($sLabTroopsSection) ; easy to change search areas
Local $bLabIsOnUpgrade = False

Func TestLaboratory()
	Local $bWasRunState = $g_bRunState
	Local $sWasLabUpgradeTime = $g_sLabUpgradeTime
	Local $sWasLabUpgradeEnable = $g_bAutoLabUpgradeEnable
	$g_bRunState = True
	$g_bAutoLabUpgradeEnable = True
	$g_sLabUpgradeTime = ""
	Local $Result = Laboratory(True)
	$g_bRunState = $bWasRunState
	$g_sLabUpgradeTime = $sWasLabUpgradeTime
	$g_bAutoLabUpgradeEnable = $sWasLabUpgradeEnable
	Return $Result
EndFunc

Func Laboratory($bDebug = False)
	If Not $g_bAutoLabUpgradeEnable Then Return ; Lab upgrade not enabled.
	If ChkUpgradeInProgress() Then Return
	If $g_aiLaboratoryPos[0] = 0 Or $g_aiLaboratoryPos[1] = 0 Then
		SetLog("Laboratory Location unknown!", $COLOR_WARNING)
		LocateLab() ; Lab location unknown, so find it.
		If $g_aiLaboratoryPos[0] = 0 Or $g_aiLaboratoryPos[1] = 0 Then
			SetLog("Problem locating Laboratory, re-locate laboratory position before proceeding", $COLOR_ERROR)
			Return False
		EndIf
	EndIf

 	; Get updated village elixir and dark elixir values
	VillageReport(True, True)

	If Not FindResearchButton() Then Return False ; cant start becuase we cannot find the research button
	If _Sleep(1500) Then Return
	If ChkLabUpgradeInProgress($bDebug) Then Return False ; Lab currently running skip going further
	If $bLabIsOnUpgrade And Not $bDebug Then Return False ; detected cancel button when try to open lab

	; Lab upgrade is not in progress and not upgrading, so we need to start an upgrade.
	Local $iCurPage = 1
	Local $sCostResult, $bUpgradeFound = False

		If $g_iCmbLaboratory <> 0 Then
			Local $iPage = Ceiling($g_iCmbLaboratory / $iPicsPerPage) ; page # of user choice
			While($iCurPage < $iPage) ; go directly to the needed page
				LabNextPage() ; go to next page of upgrades
				$iCurPage += 1 ; Next page
				If _Sleep(1000) Then Return
			WEnd

			; Get coords of upgrade the user wants
			SetDebugLog("FindImage: " & $g_avLabTroops[$g_iCmbLaboratory][2])
			Local $aCoords = decodeSingleCoord(findImage($g_avLabTroops[$g_iCmbLaboratory][2], $g_sImgLabResearch & $g_avLabTroops[$g_iCmbLaboratory][2] & "*", $sLabTroopsSectionDiam, 1, True))
			If IsArray($aCoords) And UBound($aCoords) = 2 Then
				If QuickMIS("BC1", $g_sImgResIcon, $aCoords[0], $aCoords[1], $aCoords[0] + 60, $aCoords[1] + 70) Then 
					Local $sCostResult = getLabCost($g_iQuickMISX - 75, $g_iQuickMISY - 10)
					Local $level = getTroopsSpellsLevel($g_iQuickMISX - 75, $g_iQuickMISY - 30)
					If $level = "" Then $level = 1
					If Not IsLabUpgradeResourceEnough($g_avLabTroops[$g_iCmbLaboratory][2], $sCostResult) Then
						SetLog($g_avLabTroops[$g_iCmbLaboratory][0] & " Level[" & $level & "] Cost:" & $sCostResult & " " & $g_iQuickMISName & ", Not Enough Resource", $COLOR_INFO)
					Else
						SetLog($g_avLabTroops[$g_iCmbLaboratory][0] & " Level[" & $level & "] Cost:" & $sCostResult & " " & $g_iQuickMISName, $COLOR_INFO)
						$bUpgradeFound = True
					EndIf
				EndIf
			Else
				SetDebugLog("Image " & $g_avLabTroops[$g_iCmbLaboratory][2] & " not found")
			EndIf

			If Not $bUpgradeFound Then
				SetLog("Lab Upgrade " & $g_avLabTroops[$g_iCmbLaboratory][0] & " - Not available.", $COLOR_INFO)
				Return False
			EndIf

			If $bUpgradeFound Then
				Return LaboratoryUpgrade($g_avLabTroops[$g_iCmbLaboratory][0], $aCoords, $sCostResult, $bDebug) ; return whether or not we successfully upgraded
			EndIf
		Else ; users choice is any upgrade
			If $g_bLabUpgradeOrderEnable Then
				For $z = 0 To UBound($g_aCmbLabUpgradeOrder) - 1 ; list of lab upgrade order
					If $g_aCmbLabUpgradeOrder[$z] + 1 > 0 Then
						SetLog("Priority order " & $z + 1 & " : " & $g_avLabTroops[$g_aCmbLabUpgradeOrder[$z] + 1][0], $COLOR_SUCCESS)
					Endif
				Next
				For $z = 0 To UBound($g_aCmbLabUpgradeOrder) - 1 ;try labupgrade based on order
					Local $iTmpCmbLaboratory = $g_aCmbLabUpgradeOrder[$z] + 1
					If $iTmpCmbLaboratory > 0 Then
						SetLog("Try Lab Upgrade: " & $g_avLabTroops[$iTmpCmbLaboratory][0], $COLOR_INFO)
						Local $iPage = Ceiling($iTmpCmbLaboratory / $iPicsPerPage) ; page # of user choice
						SetDebugLog("Go to Page: " & $iPage, $COLOR_INFO)
						While ($iCurPage > $iPage)
							LabPrevPage()
							$iCurPage -= 1 ;Prev Page
							If _Sleep(1000) Then Return
							If $iCurPage = 1 Then _Sleep(2000)
						Wend

						While ($iCurPage < $iPage)
							LabNextPage() ; go to next page of upgrades
							$iCurPage += 1 ; Next page
							If _Sleep(1000) Then Return
							If $iPage = 4 Then _Sleep(2000)
						WEnd

						; Get coords of upgrade the user wants
						SetDebugLog("FindImage: " & $g_avLabTroops[$iTmpCmbLaboratory][2])
						Local $aCoords = decodeSingleCoord(findImage($g_avLabTroops[$iTmpCmbLaboratory][2], $g_sImgLabResearch & $g_avLabTroops[$iTmpCmbLaboratory][2] & "*", $sLabTroopsSectionDiam, 1, True))
						Local $aSiege = ["WallW", "BattleB", "StoneS", "SiegeB", "LogL", "FlameF"]
						If IsArray($aCoords) And UBound($aCoords) = 2 Then
							If QuickMIS("BC1", $g_sImgResIcon, $aCoords[0], $aCoords[1], $aCoords[0] + 60, $aCoords[1] + 70) Then 
								Local $sCostResult = getLabCost($g_iQuickMISX - 75, $g_iQuickMISY - 10)
								Local $level = getTroopsSpellsLevel($g_iQuickMISX - 75, $g_iQuickMISY - 30)
								If $level = "" Then $level = 1
								If $g_bUpgradeSiegeToLvl2 And $level >= 2 Then
									For $x In $aSiege
										If $g_avLabTroops[$iTmpCmbLaboratory][2] = $x Then
											SetLog("Skip " & $g_avLabTroops[$iTmpCmbLaboratory][0] & ", already Level " & $level)
											ContinueLoop 2									
										EndIf
									Next
								EndIf
								If Not IsLabUpgradeResourceEnough($g_avLabTroops[$iTmpCmbLaboratory][2], $sCostResult) Then
									SetLog($g_avLabTroops[$iTmpCmbLaboratory][0] & " Level[" & $level & "] Cost:" & $sCostResult & " " & $g_iQuickMISName & ", Not Enough Resource", $COLOR_INFO)
								Else
									SetLog($g_avLabTroops[$iTmpCmbLaboratory][0] & " Level[" & $level & "] Cost:" & $sCostResult & " " & $g_iQuickMISName, $COLOR_INFO)
									$bUpgradeFound = True
									ExitLoop
								EndIf
							EndIf
						Else
							SetDebugLog("Image " & $g_avLabTroops[$iTmpCmbLaboratory][2] & " not found")
						EndIf
					EndIf
				Next
				If $bUpgradeFound Then
					Return LaboratoryUpgrade($g_avLabTroops[$iTmpCmbLaboratory][0], $aCoords, $sCostResult, $bDebug) ; return whether or not we successfully upgraded
				Else
					SetLog("Lab Upgrade " & $g_avLabTroops[$iTmpCmbLaboratory][0] & " - Not available.", $COLOR_INFO)
				EndIf
			Else ; no LabUpgradeOrder
				While($iCurPage <= $iPages)
					Local $Upgrades = FindLabUpgrade()
					Local $aUpgradeCoord[2], $sUpgrade
					If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
						For $i = 0 To UBound($Upgrades) - 1
							If $Upgrades[$i][0] = "SKIP" Then ContinueLoop
							SetDebugLog("LabUpgrade:" & $Upgrades[$i][4] & " Cost:" & $Upgrades[$i][3], $COLOR_INFO)	
							If Not IsLabUpgradeResourceEnough($Upgrades[$i][4], $Upgrades[$i][3]) Then
								SetDebugLog($Upgrades[$i][4] & " Skip, Not Enough Resource", $COLOR_INFO)
							Else
								SetDebugLog("LabUpgrade:" & $Upgrades[$i][4] & " Cost:" & $Upgrades[$i][3], $COLOR_SUCCESS)
								$bUpgradeFound = True
								$sUpgrade = $Upgrades[$i][4]
								$aUpgradeCoord[0] = $Upgrades[$i][1]
								$aUpgradeCoord[1] = $Upgrades[$i][2]
								$sCostResult = $Upgrades[$i][3]
								ExitLoop
							EndIf
						Next
					Else
						SetLog("Not found Any Upgrade here, looking next", $COLOR_INFO)
					EndIf

					If $bUpgradeFound Then
						Return LaboratoryUpgrade($sUpgrade, $aUpgradeCoord, $sCostResult, $bDebug) ; return whether or not we successfully upgraded
					EndIf

					LabNextPage() ; go to next page of upgrades
					$iCurPage += 1 ; Next page
					If $iCurPage = 4 Then _Sleep(2000)
					If _Sleep($DELAYLABORATORY2) Then Return
				WEnd
			EndIf
			; If We got to here without returning, then nothing available for upgrade
			SetLog("Nothing available for upgrade at the moment, try again later.")
			If $g_bLabUpgradeOrderEnable And $g_bUpgradeAnyTroops Then 
				Return UpgradeLabAny($bDebug)
			EndIf
			ClickAway()
		EndIf
	ClickAway()
	Return False ; No upgrade started
EndFunc

; start a given upgrade
Func LaboratoryUpgrade($name, $aCoords, $sCostResult, $bDebug = False)

	ClickP($aCoords) ; click troop
	If _Sleep(2000) Then Return
	Local $sCostType = QuickMIS("N1", $g_sImgAUpgradeRes, 690, 500, 730, 580) ; get if elixir or dark elixir upgrade
	;$sCostResult = getResourcesBonus(600, 522) ; get cost
	Local $sEnoughResource = False

	Switch $sCostType ;Check if there is enough resource to save after upgrade
		Case "Elixir"
			If $g_aiCurrentLoot[$eLootElixir] - $sCostResult > $g_iTxtSmartMinElixir Then $sEnoughResource = True
		Case "Dark Elixir"
			If $g_aiCurrentLoot[$eLootDarkElixir] - $sCostResult > $g_iTxtSmartMinDark Then $sEnoughResource = True
		Case Else
			SetLog("Cannot find upgrade cost type!", $COLOR_ERROR)
	EndSwitch

	If $sEnoughResource Then
		SetLog("Selected upgrade: " & $name & " Cost: " & $sCostResult, $COLOR_INFO)

		If $bDebug = True Then ; if debugging, do not actually click it
			SetLog("[debug mode] - Start Upgrade, Click (" & 660 & "," & 520 & ")", $COLOR_ACTION)
			ClickAway()
			Return True ; return true as if we really started an upgrade
		Else
			Click(660, 520, 1, 0, "#0202") ; Everything is good - Click the upgrade button
			If isGemOpen(True) = False Then ; check for gem window
				_Sleep(1000)
				ChkLabUpgradeInProgress($bDebug)
				; success
				SetLog("Upgrade " & $name & " in your laboratory started with success...", $COLOR_SUCCESS)
				PushMsg("LabSuccess")
				If _Sleep($DELAYLABUPGRADE2) Then Return
				ClickAway()
				Return True ; upgrade started
			Else
				SetLog("Oops, Gems required for " & $name & " Upgrade, try again.", $COLOR_ERROR)
				Return False
			EndIf
		EndIf

	Else
		SetLog("Failed to upgrade " & $name & ". Not enough " & $sCostType &" to save!", $COLOR_ERROR)
		ClickAway()
		ClickAway()
	EndIf

EndFunc

; get the time for the selected upgrade
Func SetLabUpgradeTime($sTrooopName)
	Local $Result = getLabUpgradeTime(581, 495) ; Try to read white text showing time for upgrade
	Local $iLabFinishTime = ConvertOCRTime("Lab Time", $Result, False)
	SetLog($sTrooopName & " Upgrade OCR Time = " & $Result & ", $iLabFinishTime = " & $iLabFinishTime & " m", $COLOR_INFO)
	Local $StartTime = _NowCalc() ; what is date:time now
	SetDebugLog($sTrooopName & " Upgrade Started @ " & $StartTime, $COLOR_SUCCESS)
	If $iLabFinishTime > 0 Then
		$g_sLabUpgradeTime = _DateAdd('n', Ceiling($iLabFinishTime), $StartTime)
		SetLog($sTrooopName & " Upgrade Finishes @ " & $Result & " (" & $g_sLabUpgradeTime & ")", $COLOR_SUCCESS)
	Else
		SetLog("Error processing upgrade time required, try again!", $COLOR_WARNING)
		Return False
	EndIf
	Return True ; success
EndFunc

; get the cost of an upgrade based on its coords
; find image slot that we found so that we can read the cost to see if we can upgrade it... slots read 1-12 top to bottom so barb = 1, arch = 2, giant = 3, etc...
Func GetLabCostResult($XCoords, $YCoords, $UpgradeName = "")
	Local $xColumn =  $XCoords - 40, $yRow, $sCostResult = 0
	If $YCoords + 10 < $iYMidPoint Then
		$yRow = 410
	Else
		$yRow = 520
	EndIf
	$sCostResult = getLabUpgrdResourceWht($xColumn, $yRow)
	If $sCostResult = "" Then
		SetLog($UpgradeName & " Cost read failed", $COLOR_ERROR)
	EndIf
	Return $sCostResult
EndFunc

; if we are on last page, smaller clickdrag... for future dev: this is whatever is enough distance to move 6 off to the left and have the next page similarily aligned
Func LabNextPage()
	Local $MidPoint = 500
	ClickDrag(720, $MidPoint, 85, $MidPoint, 500)
EndFunc

Func LabPrevPage()
	Local $MidPoint = 500
	ClickDrag(130, $MidPoint, 760, $MidPoint, 500) ;600
EndFunc

; check the lab to see if something is upgrading in the lab already
Func ChkLabUpgradeInProgress($bDebug = False)
	; check for upgrade in process - look for green in finish upgrade with gems button
	If _Sleep(500) Then Return
	If _ColorCheck(_GetPixelColor(125, 160, True), Hex(0xBDE36B, 6), 20) Or _ColorCheck(_GetPixelColor(722, 278, True), Hex(0xA2CB6C, 6), 20) Then ; Look for light green in upper right corner of lab window.
		SetLog("Laboratory is Running", $COLOR_INFO)
		;==========Hide Red  Show Green Hide Gray===
		GUICtrlSetState($g_hPicLabGray, $GUI_HIDE)
		GUICtrlSetState($g_hPicLabRed, $GUI_HIDE)
		GUICtrlSetState($g_hPicLabGreen, $GUI_SHOW)
		;===========================================
		If _Sleep($DELAYLABORATORY2) Then Return
		Local $sLabTimeOCR = getRemainTLaboratory(270, 227)
		Local $iLabFinishTime = ConvertOCRTime("Lab Time", $sLabTimeOCR, False)
		SetDebugLog("$sLabTimeOCR: " & $sLabTimeOCR & ", $iLabFinishTime = " & $iLabFinishTime & " m")
		If $iLabFinishTime > 0 Then
			$g_sLabUpgradeTime = _DateAdd('n', Ceiling($iLabFinishTime), _NowCalc())
			SetLog("Research will finish in " & $sLabTimeOCR & " (" & $g_sLabUpgradeTime & ")")
		EndIf
		If $bDebug Then Return False
		If _Sleep(50) Then Return
		ClickAway()
		If ProfileSwitchAccountEnabled() Then SwitchAccountVariablesReload("Save") ; saving $asLabUpgradeTime[$g_iCurAccount] = $g_sLabUpgradeTime for instantly displaying in multi-stats
		If $g_bUseLabPotion And $iLabFinishTime > 1440 Then ; only use potion if lab upgrade time is more than 1 day
			_Sleep(1000)
			Local $LabPotion = FindButton("LabPotion")
			If IsArray($LabPotion) And UBound($LabPotion) = 2 Then
				SetLog("Use Laboratory Potion", $COLOR_INFO)
				Local $LabBoosted = FindButton("LabBoosted")
				If IsArray($LabBoosted) And UBound($LabBoosted) = 2 Then ; Lab already boosted skip using potion
					SetLog("Detected Laboratory already boosted", $COLOR_INFO)
					Return True
				EndIf
				Click($LabPotion[0], $LabPotion[1])
				_Sleep(1000)
				If QuickMis("BC1", $g_sImgGeneralCloseButton, 560, 225, 610, 275) Then 
					Click(430, 400)
				EndIf
				ClickAway("Right")
			Else
				SetLog("No Laboratory Potion Found", $COLOR_DEBUG)
				ClickAway("Right")
			EndIf
		EndIf
		Return True
	EndIf
	Return False
EndFunc

; checks our global variable to see if we know of something already upgrading
Func ChkUpgradeInProgress()
	Local $TimeDiff ; time remaining on lab upgrade
	If $g_sLabUpgradeTime <> "" Then $TimeDiff = _DateDiff("n", _NowCalc(), $g_sLabUpgradeTime) ; what is difference between end time and now in minutes?
	If @error Then _logErrorDateDiff(@error)
	SetDebugLog("Lab Endtime: " & $g_sLabUpgradeTime, $COLOR_DEBUG)

	If Not $g_bRunState Then Return
	If $TimeDiff <= 0 Then
		SetLog("Checking Troop Upgrade in Laboratory ...", $COLOR_INFO)
	Else
		SetLog("Laboratory Upgrade in progress, waiting for completion", $COLOR_INFO)
		Return True
	EndIf
	Return False ; we currently do not know of any upgrades in progress
EndFunc

Func FindLabUpgrade()
	Local $aResult[0][6]
	Local $TmpResult = QuickMIS("CNX", $g_sImgResIcon, 110, 330, 740, 540)
	Local $aSiege = ["WallW", "BattleB", "StoneS", "SiegeB", "LogL", "FlameF"]
	If IsArray($TmpResult) And UBound($TmpResult) > 0 Then
		For $i = 0 To UBound($TmpResult) - 1
			_ArrayAdd($aResult, $TmpResult[$i][0] & "|" & $TmpResult[$i][1] & "|" & $TmpResult[$i][2])
		Next
		For $i = 0 To UBound($aResult) - 1
			If QuickMIS("BC1", $g_sImgLabResearch, $aResult[$i][1] - 75, $aResult[$i][2] - 80, $aResult[$i][1], $aResult[$i][2]) Then
				Local $cost = getLabCost($aResult[$i][1] - 75, $aResult[$i][2] - 10)
				Local $level = getTroopsSpellsLevel($aResult[$i][1] - 75, $aResult[$i][2] - 30)
				If $level = "" Then $level = 1
				$aResult[$i][3] = Number($cost)
				$aResult[$i][4] = $g_iQuickMISName
				$aResult[$i][5] = Number($level)
			EndIf
			If $g_bUpgradeSiegeToLvl2 And $aResult[$i][5] >= 2 Then
				For $x In $aSiege
					If $aResult[$i][4] = $x Then
						SetLog("Skip " & $aResult[$i][4] & ", already Level " & $aResult[$i][5])
						$aResult[$i][0] = "SKIP"
					EndIf
				Next
			EndIf
		Next
	Else
		SetLog("Result Not Array", $COLOR_ERROR)
	EndIf
	_ArraySort($aResult, 0, 0, 0, 3)
	Return $aResult
EndFunc

Func GetUpgradeName($shortName)
	For $i = 0 To UBound($g_avLabTroops) -1
		If $shortName = $g_avLabTroops[$i][2] Then Return $g_avLabTroops[$i][0]
	Next
EndFunc

Func IsLabUpgradeResourceEnough($TroopOrSpell, $Cost)
	Local $bRet = False
	If StringInStr($TroopOrSpell, "Spell") Then
		If IsDarkSpell($TroopOrSpell) Then ;DE Spell
			If $g_aiCurrentLoot[$eLootDarkElixir] > ($g_iTxtSmartMinDark + $Cost) Then
				SetDebugLog($g_iTxtSmartMinDark & " + " & $Cost & " = " & $g_iTxtSmartMinDark + $Cost)
				SetDebugLog("DE = " & $g_aiCurrentLoot[$eLootDarkElixir])
				$bRet = True
			EndIf
		Else ;Elixir Spell
			If $g_aiCurrentLoot[$eLootElixir] > ($g_iTxtSmartMinElixir + $Cost) Then
				SetDebugLog($g_iTxtSmartMinElixir & " + " & $Cost & " = " & $g_iTxtSmartMinElixir + $Cost)
				SetDebugLog("Elixir = " & $g_aiCurrentLoot[$eLootElixir])
				$bRet = True
			EndIf
		EndIf
	Else
		If IsDarkTroop($TroopOrSpell) Then ;DE Troop
			If $g_aiCurrentLoot[$eLootDarkElixir] > ($g_iTxtSmartMinDark + $Cost) Then
				SetDebugLog($g_iTxtSmartMinDark & " + " & $Cost & " = " & $g_iTxtSmartMinDark + $Cost)
				SetDebugLog("DE = " & $g_aiCurrentLoot[$eLootDarkElixir])
				$bRet = True
			EndIf
		Else ;Elixir Troop
			If $g_aiCurrentLoot[$eLootElixir] > ($g_iTxtSmartMinElixir + $Cost) Then
				SetDebugLog($g_iTxtSmartMinElixir & " + " & $Cost & " = " & $g_iTxtSmartMinElixir + $Cost)
				SetDebugLog("Elixir = " & $g_aiCurrentLoot[$eLootElixir])
				$bRet = True
			EndIf
		EndIf
	EndIf
	Return $bRet
EndFunc

; Find Research Button
Func FindResearchButton()
	Local $TryLabAutoLocate = False
	Local $LabFound = False
	$bLabIsOnUpgrade = False ;reset value
	ClickAway()
	CheckMainScreen(False, $g_bStayOnBuilderBase, "FindResearchButton")

	;Click Laboratory
	If Int($g_aiLaboratoryPos[0]) < 1 Or Int($g_aiLaboratoryPos[1]) < 1 Then
		$TryLabAutoLocate = True
	Else
		Click($g_aiLaboratoryPos[0], $g_aiLaboratoryPos[1])
		If _Sleep(1000) Then Return
		Local $BuildingInfo = BuildingInfo(260, 494)
		If StringInStr($BuildingInfo[1], "Lab") Then
			$TryLabAutoLocate = False
			$LabFound = True
		Else
			$TryLabAutoLocate = True
		EndIf
	EndIf

	If $TryLabAutoLocate Then
		$LabFound = AutoLocateLab()
		If $LabFound Then
			applyConfig()
			saveConfig()
		Else
			SetLog("TryLabAutoLocate Failed, please locate manually", $COLOR_DEBUG)
			Return
		EndIf
	EndIf

	If $LabFound Then
		Local $aBtnCancel = FindButton("cancel")
		If IsArray($aBtnCancel) And UBound($aBtnCancel) > 0 Then
			SetLog("Laboratory is Upgrading!, Cannot start any upgrade", $COLOR_ERROR)
			$bLabIsOnUpgrade = True
		EndIf
		ClickB("Research")
		If _Sleep(1000) Then Return
		Return True
	EndIf
EndFunc

Func AutoLocateLab()
	Local $LabFound = False
	SetLog("Try to Auto Locate Laboratory!", $COLOR_INFO)
	ClickAway()
	Local $LabResearch = decodeSingleCoord(findImage("Research", $g_sImgLaboratory & "\Research*", GetDiamondFromRect("77,70(700,510)"), 1, True))
	If IsArray($LabResearch) And UBound($LabResearch) = 2 Then
		Click($LabResearch[0], $LabResearch[1] + 30)
		If _Sleep(1000) Then Return
		Local $BuildingInfo = BuildingInfo(290, 494)
		If StringInStr($BuildingInfo[1], "Lab") Then
			$g_aiLaboratoryPos[0] = $LabResearch[0] + 5
			$g_aiLaboratoryPos[1] = $LabResearch[1] + 30
			SetLog("Found Laboratory Lvl " & $BuildingInfo[2] & ", save as Lab Coords : " & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1], $COLOR_INFO)
			$LabFound = True
		EndIf
	EndIf

	If Not $LabFound Then
		Local $Lab = decodeSingleCoord(findImage("Laboratory", $g_sImgLaboratory & "\Laboratory*", GetDiamondFromRect("50,60,800,600"), 1, True))
		If IsArray($Lab) And UBound($Lab) = 2 Then
			Click($Lab[0], $Lab[1])
			If _Sleep(1000) Then Return
			Local $BuildingInfo = BuildingInfo(290, 494)
			If StringInStr($BuildingInfo[1], "Lab") Then
				$g_aiLaboratoryPos[0] = $Lab[0]
				$g_aiLaboratoryPos[1] = $Lab[1]
				SetLog("Found Laboratory Lvl " & $BuildingInfo[2] & ", save as Lab Coords : " & $g_aiLaboratoryPos[0] & "," & $g_aiLaboratoryPos[1], $COLOR_INFO)
				$LabFound = True
			EndIf
		EndIf
	EndIf
	Return $LabFound
EndFunc

Func UpgradeLabAny($bDebug = False)
	;just start from page 1, close and open again lab window
	ClickAway()
	If _Sleep(1000) Then Return
	If Not ClickB("Research") Then Return
	If _Sleep(1000) Then Return
	Local $iCurPage = 1, $bUpgradeFound = False, $sCostResult = 0
	While(True)
		Local $Upgrades = FindLabUpgrade()
		Local $aUpgradeCoord[2], $sUpgrade
		If IsArray($Upgrades) And UBound($Upgrades) > 0 Then
			For $i = 0 To UBound($Upgrades) - 1
				If $Upgrades[$i][0] = "SKIP" Then ContinueLoop
				SetDebugLog("LabUpgrade:" & $Upgrades[$i][4] & " Cost:" & $Upgrades[$i][3] & " " & $Upgrades[$i][0], $COLOR_INFO)
				If Not IsLabUpgradeResourceEnough($Upgrades[$i][4], $Upgrades[$i][3]) Then
					SetDebugLog("LabUpgrade:" & $Upgrades[$i][4] & " Skip, Not Enough Resource", $COLOR_INFO)
				Else
					SetDebugLog("LabUpgrade:" & $Upgrades[$i][4] & " Cost:" & $Upgrades[$i][3], $COLOR_SUCCESS)
					$bUpgradeFound = True
					$sUpgrade = $Upgrades[$i][4]
					$aUpgradeCoord[0] = $Upgrades[$i][1]
					$aUpgradeCoord[1] = $Upgrades[$i][2]
					$sCostResult = $Upgrades[$i][3]
					ExitLoop
				EndIf
			Next
		Else
			SetLog("Not found Any Upgrade here, looking next", $COLOR_INFO)
		EndIf
		If Number($iCurPage) = 4 Then ExitLoop
		If $bUpgradeFound Then
			Return LaboratoryUpgrade($sUpgrade, $aUpgradeCoord, $sCostResult, $bDebug) ; return whether or not we successfully upgraded
		EndIf
		SetDebugLog("CurrentPage=" & $iCurPage)
		LabNextPage() ; go to next page of upgrades
		$iCurPage += 1 ; Next page
		If Number($iCurPage) = 4 Then _Sleep(2000)
		If _Sleep($DELAYLABORATORY2) Then Return
	WEnd
	ClickAway()
	Return False
EndFunc