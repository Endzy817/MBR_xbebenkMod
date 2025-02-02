; #FUNCTION# ====================================================================================================================
; Name ..........: DailyChallenges()
; Description ...: Daily Challenges
; Author ........: TripleM (04/2019), Demen (07/2019)
; Modified ......: Endzy (03/04/2022) April 3
; Remarks .......: This file is part of MyBot Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: DailyChallenges()
; ===============================================================================================================================
#include-once

;[11:11:58 AM] Collecting Daily Rewards...
;[11:11:59 AM] Dragging back for more... [11:12:02 AM] Storage full. Cancelling to sell it
;[11:12:03 AM] Storage full. Cancelling to sell it


Func DailyChallenges()
	Local Static $asLastTimeChecked[UBound($g_abAccountNo)]
	If $g_bFirstStart Then $asLastTimeChecked[$g_iCurAccount] = ""
	checkMainScreen(False, $g_bStayOnBuilderBase, "DailyChallenges")

	Local $bGoldPass = _CheckPixel($aPersonalChallengeOpenButton2, $g_bCapturePixel) ; golden badge button at mainscreen
	Local $bCheckDiscount = $bGoldPass And ($g_bUpgradeKingEnable Or $g_bUpgradeQueenEnable Or $g_bUpgradeWardenEnable Or $g_bUpgradeChampionEnable or $g_bAutoUpgradeWallsEnable)

	If Not $g_bChkCollectRewards And Not $bCheckDiscount Then Return
	Local $bRedSignal = _CheckPixel($aPersonalChallengeOpenButton3, $g_bCapturePixel)

	If _DateIsValid($asLastTimeChecked[$g_iCurAccount]) Then
		Local $iLastCheck = _DateDiff('n', $asLastTimeChecked[$g_iCurAccount], _NowCalc()) ; elapse time from last check (minutes)
		SetDebugLog("LastCheck: " & $asLastTimeChecked[$g_iCurAccount] & ", Check DateCalc: " & $iLastCheck & ", $bRedSignal: " & $bRedSignal)
		If ($iLastCheck <= $bRedSignal ? 180 : 360) Then Return ; A check each 3 hours or 6 hours [6*60 = 360]
	EndIf

	If OpenPersonalChallenges() Then
		CollectDailyRewards($bGoldPass)
		If $bCheckDiscount Then CheckDiscountPerks()

		If _Sleep(1000) Then Return
		ClosePersonalChallenges()

		$asLastTimeChecked[$g_iCurAccount] = _NowCalc()
	EndIf
EndFunc   ;==>DailyChallenges

Func OpenPersonalChallenges()
	SetLog("Opening personal challenges", $COLOR_INFO)
	If _CheckPixel($aPersonalChallengeOpenButton1, $g_bCapturePixel) Then
		ClickP($aPersonalChallengeOpenButton1, 1, 0, "#0666")
	ElseIf _CheckPixel($aPersonalChallengeOpenButton2, $g_bCapturePixel) Then
		ClickP($aPersonalChallengeOpenButton2, 1, 0, "#0666")
	Else
		SetLog("Can't find button", $COLOR_ERROR)
		ClickAway()
		Return False
	EndIf

	Local $counter = 0
	While Not IsFullScreenWindow() ; test for Personal Challenge Close Button
		SetDebugLog("Wait for Personal Challenge Close Button to appear #" & $counter)
		If _Sleep(250) Then Return
		$counter += 1
		If $counter > 8 Then Return False
	WEnd
	Return True
EndFunc   ;==>OpenPersonalChallenges

Func SearchHeroBook($bCheckOneTime = False)
	If _Sleep($DELAYSPECIALCLICK1) Then Return False

	Local $bReturn = False

	$bReturn = _WaitForCheckImg($g_sImgHeroBook, "22,419,840,555", Default, ($bCheckOneTime = False) ? (500) : (0))

	If $g_bDebugSetlog Then
		SetDebugLog("SearchHeroBook: Is HeroBook? " & $bReturn, $COLOR_DEBUG)
	EndIf

	Return $bReturn
EndFunc   ;==>SearchHeroBook

Func SearchHeroPot($bCheckOneTime = False)
	If _Sleep($DELAYSPECIALCLICK1) Then Return False

	Local $bReturn = False

	$bReturn = _WaitForCheckImg($g_sImgHeroPot, "22,419,840,555", Default, ($bCheckOneTime = False) ? (500) : (0))

	If $g_bDebugSetlog Then
		SetDebugLog("SearchHeroPot: Is HeroPotion? " & $bReturn, $COLOR_DEBUG)
	EndIf

	Return $bReturn
EndFunc   ;==>SearchHeroPot
#cs no image yet, comment for now
Func SearchPowerPot($bCheckOneTime = False)
	If _Sleep($DELAYSPECIALCLICK1) Then Return False

	Local $bReturn = False

	$bReturn = _WaitForCheckImg($g_sImgHeroBook, "22,419,840,555", Default, ($bCheckOneTime = False) ? (500) : (0))

	If $g_bDebugSetlog Then
		SetDebugLog("SearchHeroBook: Is HeroBook? " & $bReturn, $COLOR_DEBUG)
	EndIf

	Return $bReturn
EndFunc   ;==>SearchPowerPot
#ce
Func CollectDailyRewards($bGoldPass = False)

	If Not $g_bChkCollectRewards Or Not _CheckPixel($aPersonalChallengeRewardsAvail, $g_bCapturePixel) Then Return ; no red badge on rewards tab

	SetLog("Collecting Daily Rewards...")

	ClickP($aPersonalChallengeRewardsTab, 1, 0, "Rewards tab") ; Click Rewards tab
	If _Sleep(2000) Then Return

	Local $iClaim = 0
	For $i = 0 To 10
		If Not $g_bRunState Then Return
		Local $SearchArea = $bGoldPass ? GetDiamondFromRect("25,300(810,240)") : GetDiamondFromRect("25,500(810,35)")
		Local $aResult = findMultiple(@ScriptDir & "\imgxml\DailyChallenge\", $SearchArea, $SearchArea, 0, 1000, $bGoldPass ? 5 : 2, "objectname,objectpoints", True)
		If $aResult <> "" And IsArray($aResult) Then
			For $i = 0 To UBound($aResult) - 1
				Local $aResultArray = $aResult[$i] ; ["Button Name", "x1,y1", "x2,y2", ...]
				SetDebugLog("Find Claim buttons, $aResultArray[" & $i & "]: " & _ArrayToString($aResultArray))

				If IsArray($aResultArray) And $aResultArray[0] = "ClaimBtn" Then
					Local $sAllCoordsString = _ArrayToString($aResultArray, "|", 1) ; "x1,y1|x2,y2|..."
					Local $aAllCoords = decodeMultipleCoords($sAllCoordsString, 50, 50) ; [{coords1}, {coords2}, ...]
					;Local $bSkipChkHB = False
					;Local $bSkipChkHP = False
					For $j = 0 To UBound($aAllCoords) - 1
						;_CaptureRegion2()
						;$bSkipChkHB = False ;Reset
						If Not SearchHeroBook() Then ;And Not $bSkipChkHB Then
							ClickP($aAllCoords[$j], 1, 0, "Claim " & $j + 1) ; Click Claim button
						Else
							Setlog("Found Book of Heroes, skip claim.", $COLOR_SUCCESS)
							;$bSkipChkHB = True
							ContinueLoop
						EndIf
						;If Not SearchHeroPot() And Not $bSkipChkHP Then
						;	ClickP($aAllCoords[$j], 1, 0, "Claim " & $j + 1) ; Click Claim button
						;Else
						;	Setlog("Found Hero Potion, skip claim.", $COLOR_SUCCESS)
						;	$bSkipChkHP = True
						;	ContinueLoop
						;EndIf
						If WaitforPixel(350, 380, 351, 381, Hex(0xFDC875, 6), 20, 3) Then; wait for Cancel Button popped up in 1.5 second
						    If $g_bChkSellRewards Then
							    Setlog("Selling extra reward for gems", $COLOR_SUCCESS)
								ClickP($aPersonalChallengeOkBtn, 1, 0, "Okay Btn") ; Click the Okay
								$iClaim += 1
							Else
								SetLog("Sell Extras not enabled.", $COLOR_INFO)
								SetLog("Cancel. Not selling extra rewards.", $COLOR_SUCCESS)
								ClickP($aPersonalChallengeCancelBtn, 1, 0, "Cancel Btn") ; Click Claim button
							Endif
							If _Sleep(1000) Then ExitLoop
						Else
							$iClaim += 1
							If _Sleep(100) Then ExitLoop
						EndIf
					Next
				EndIf
			Next
		EndIf
		If _CheckPixel($aPersonalChallengeRewardsCheckMark, $g_bCapturePixel) And Not _CheckPixel($aPersonalChallengeLeftEdge, $g_bCapturePixel) Then ; far left edge
			If $i = 0 Then
				SetLog("Dragging back for more... ", Default, Default, Default, Default, Default, Default, False) ; no end line
			Else
				SetLog($i & ".. ", Default, Default, Default, Default, Default, 0, $i < 10 ? False : Default) ; no time
			EndIf
			ClickDrag(100, 385, 750, 385, 1000) ;x1 was 50. x2 was 810  Change for Dec '20 update
			If _Sleep(500) Then ExitLoop
		Else
			If $i > 0 Then SetLog($i & ".", Default, Default, Default, Default, Default, False) ; no time + end line
			ExitLoop
		EndIf
	Next
	SetLog($iClaim > 0 ? "Claimed " & $iClaim & " reward(s)!" : "Nothing to claim!", $COLOR_SUCCESS)
	;$bSkipChkHB = False ;Reset
	;$bSkipChkHP = False ;Reset
	If _Sleep(500) Then Return

EndFunc   ;==>CollectDailyRewards

Func CheckDiscountPerks()
	SetLog("Checking for builder boost...")
	If $g_bFirstStart Then $g_iBuilderBoostDiscount = 0

	ClickP($aPersonalChallengePerksTab, 1, 0, "PerksTab")

	If Not WaitforPixel($aPersonalChallengePerksTab[0] - 1, $aPersonalChallengePerksTab[1] - 1, $aPersonalChallengePerksTab[0] + 1, $aPersonalChallengePerksTab[1] + 1, _
					Hex($aPersonalChallengePerksTab[2], 6), $aPersonalChallengePerksTab[3], 2) Then Return; wait for Perks Tab completely loaded in 1 second

	If _Sleep(500) Then Return

	; find builder boost rate %
	;Local $sDiscount = getOcrAndCapture("coc-builderboost", 370, 330, 110, 46)
	;SetDebugLog("Builder boost OCR: " & $sDiscount)
	;If StringInStr($sDiscount, "%") Then
	;	Local $aDiscount = StringSplit($sDiscount, "%", $STR_NOCOUNT)
	;	$g_iBuilderBoostDiscount = Number($aDiscount[0])
	;	SetLog($g_iBuilderBoostDiscount > 0 ? "Current Builder boost: " & $g_iBuilderBoostDiscount & "%" : "Keep working hard on challenges", $COLOR_SUCCESS)
	;Else
	;	SetLog("Cannot read builder boost", $COLOR_ERROR)
	;EndIf
EndFunc   ;==>CheckDiscountPerks

Func ClosePersonalChallenges()
	If $g_bDebugSetlog Then SetLog("Closing personal challenges", $COLOR_INFO)

	If IsFullScreenWindow() Then
		Click(820, 40) ;close window
		Return True
	EndIf
	Return False

EndFunc   ;==>ClosePersonalChallenges
