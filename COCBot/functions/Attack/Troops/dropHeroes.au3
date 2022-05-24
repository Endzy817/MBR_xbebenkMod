; #FUNCTION# ====================================================================================================================
; Name ..........: dropHeroes
; Description ...: Will drop heroes in a specific coordinates, only if slot is not -1,Only drops when option is clicked.
; Syntax ........: dropHeroes($x, $y, $iKingSlot = -1, $iQueenSlot = -1, $iWardenSlot = -1, $iChampionSlot = -1)
; Parameters ....: $x                   - an unknown value.
;                  $y                   - an unknown value.
;                  $KingSlot            - [optional] an unknown value. Default is -1.
;                  $QueenSlot           - [optional] an unknown value. Default is -1.
;                  $WardenSlot          - [optional] an unknown value. Default is -1.
; Return values .: None
; Author ........:
; Modified ......: Modefied by Endzy (29/03/2022)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func dropHeroes($iX, $iY, $iKingSlotNumber = -1, $iQueenSlotNumber = -1, $iWardenSlotNumber = -1, $iChampionSlotNumber = -1) ;Drops for All Heroes
	SetDebugLog("dropHeroes $iKingSlotNumber " & $iKingSlotNumber & " $iQueenSlotNumber " & $iQueenSlotNumber & " $iWardenSlotNumber " & $iWardenSlotNumber & " $iChampionSlotNumber " & $iChampionSlotNumber & " matchmode " & $g_iMatchMode, $COLOR_DEBUG)
	If _Sleep($DELAYDROPHEROES1) Then Return
	Local $bDropKing = False
	Local $bDropQueen = False
	Local $bDropWarden = False
	Local $bDropChampion = False

	;use hero if  slot (detected ) and ( ($g_iMatchMode <>DB and <>LB  ) or (check user GUI settings) )
	If $iKingSlotNumber <> -1 And (($g_iMatchMode <> $DB And $g_iMatchMode <> $LB) Or BitAND($g_aiAttackUseHeroes[$g_iMatchMode], $eHeroKing) = $eHeroKing) Then $bDropKing = True
	If $iQueenSlotNumber <> -1 And (($g_iMatchMode <> $DB And $g_iMatchMode <> $LB) Or BitAND($g_aiAttackUseHeroes[$g_iMatchMode], $eHeroQueen) = $eHeroQueen) Then $bDropQueen = True
	If $iWardenSlotNumber <> -1 And (($g_iMatchMode <> $DB And $g_iMatchMode <> $LB) Or BitAND($g_aiAttackUseHeroes[$g_iMatchMode], $eHeroWarden) = $eHeroWarden) Then $bDropWarden = True
	If $iChampionSlotNumber <> -1 And (($g_iMatchMode <> $DB And $g_iMatchMode <> $LB) Or BitAND($g_aiAttackUseHeroes[$g_iMatchMode], $eHeroChampion) = $eHeroChampion) Then $bDropChampion = True

	SetDebugLog("drop KING = " & $bDropKing, $COLOR_DEBUG)
	SetDebugLog("drop QUEEN = " & $bDropQueen, $COLOR_DEBUG)
	SetDebugLog("drop WARDEN = " & $bDropWarden, $COLOR_DEBUG)
	SetDebugLog("drop CHAMPION = " & $bDropChampion, $COLOR_DEBUG)

	Local $count = 0
	Local $i = 0

	If ($g_iMatchMode = $DB And $g_aiAttackAlgorithm[$DB] = 1) Or ($g_iMatchMode = $LB And $g_aiAttackAlgorithm[$LB] = 1) Then
		SetLog("Scriptedf Attack Enabled", $COLOR_INFO)
		If $bDropKing Then
			SetLog("Dropping King at " & $iX & ", " & $iY, $COLOR_INFO)
			SelectDropTroop($iKingSlotNumber, 1, Default, False)
			If _Sleep($DELAYDROPHEROES2) Then Return
			AttackClick($iX + Random(0, 20, 1), $iY + Random(0, 20, 1), 1, 0, 0, "#0093")
			If Not $g_bDropKing Then ; check global flag, only begin hero health check on 1st hero drop as flag is reset to false after activation
				$g_bCheckKingPower = True
			Else
				SetDebugLog("King dropped 2nd time, Check Power flag not changed") ; do nothing as hero already dropped
			EndIf
			$g_bDropKing = True ; Set global flag hero dropped
			$g_aHeroesTimerActivation[$eHeroBarbarianKing] = __TimerInit() ; initialize fixed activation timer
			If RandomSleep($DELAYDROPHEROES1 * 2) Then Return
		EndIf

		;If RandomSleep($DELAYDROPHEROES1 * 2) Then Return

		If $bDropQueen Then
			SetLog("Dropping Queen at " & $iX & ", " & $iY, $COLOR_INFO)
			SelectDropTroop($iQueenSlotNumber, 1, Default, False)
			If _Sleep($DELAYDROPHEROES2) Then Return
			AttackClick($iX + Random(10, 30, 1), $iY + Random(10, 30, 1), 1, 0, 0, "#0095")
			If Not $g_bDropQueen Then ; check global flag, only begin hero health check on 1st hero drop as flag is reset to false after activation
				$g_bCheckQueenPower = True
			Else
				SetDebugLog("Queen dropped 2nd time, Check Power flag not changed") ; do nothing as hero already dropped
			EndIf
			$g_bDropQueen = True ; Set global flag hero dropped
			$g_aHeroesTimerActivation[$eHeroArcherQueen] = __TimerInit() ; initialize fixed activation timer
			If RandomSleep($DELAYDROPHEROES1 * 2) Then Return
		EndIf

		;If RandomSleep($DELAYDROPHEROES1 * 2) Then Return

		If $bDropWarden Then
			SetLog("Dropping Grand Warden at " & $iX & ", " & $iY, $COLOR_INFO)
			SelectDropTroop($iWardenSlotNumber, 1, Default, False)
			If _Sleep($DELAYDROPHEROES2) Then Return
			AttackClick($iX + Random(-10, 30, 1), $iY + Random(-10, 30, 1), 1, 0, 0, "#x999")
			If Not $g_bDropWarden Then ; check global flag, only begin hero health check on 1st hero drop as flag is reset to false after activation
				$g_bCheckWardenPower = True
			Else
				SetDebugLog("Warden dropped 2nd time, Check Power flag not changed") ; do nothing as hero already dropped
			EndIf
			$g_bDropWarden = True ; Set global flag hero dropped
			$g_aHeroesTimerActivation[$eHeroGrandWarden] = __TimerInit() ; initialize fixed activation timer
			If RandomSleep($DELAYDROPHEROES1 * 2) Then Return
		EndIf

		;If RandomSleep($DELAYDROPHEROES1 * 2) Then Return

		If $bDropChampion Then
			SetLog("Dropping Royal Champion at " & $iX & ", " & $iY, $COLOR_INFO)
			SelectDropTroop($iChampionSlotNumber, 1, Default, False)
			If _Sleep($DELAYDROPHEROES2) Then Return
			AttackClick($iX + Random(0, 40, 1), $iY + Random(0, 40, 1), 1, 0, 0, "#x999")
			If Not $g_bDropChampion Then ; check global flag, only begin hero health check on 1st hero drop as flag is reset to false after activation
				$g_bCheckChampionPower = True
			Else
				SetDebugLog("Royal Champion dropped 2nd time, Check Power flag not changed") ; do nothing as hero already dropped
			EndIf
			$g_bDropChampion = True ; Set global flag hero dropped
			$g_aHeroesTimerActivation[$eHeroRoyalChampion] = __TimerInit() ; initialize fixed activation timer
			If RandomSleep($DELAYDROPHEROES1 * 2) Then Return
		EndIf
		;If RandomSleep($DELAYDROPHEROES1 * 2) Then Return
	Else
		Do
			SetLog("Loop: " & "[" & $count & "]", $COLOR_INFO)
			If $bDropKing And $g_bDropKing = 0 And Random(0, 5, 1) = 4 Then
				$i += 1
				SetLog("Dropping King at " & $iX & ", " & $iY, $COLOR_INFO)
				SelectDropTroop($iKingSlotNumber, 1, Default, False)
				If _Sleep($DELAYDROPHEROES2) Then Return
				AttackClick($iX + Random(0, 20, 1), $iY + Random(0, 20, 1), 1, 0, 0, "#0093")
				If Not $g_bDropKing Then ; check global flag, only begin hero health check on 1st hero drop as flag is reset to false after activation
					$g_bCheckKingPower = True
				Else
					SetDebugLog("King dropped 2nd time, Check Power flag not changed") ; do nothing as hero already dropped
				EndIf
				$g_bDropKing = True ; Set global flag hero dropped
				$g_aHeroesTimerActivation[$eHeroBarbarianKing] = __TimerInit() ; initialize fixed activation timer
				If RandomSleep($DELAYDROPHEROES1 * 2) Then Return
			EndIf

			;If RandomSleep($DELAYDROPHEROES1 * 2) Then Return

			If $bDropQueen And $g_bDropQueen = 0 And Random(0, 5, 1) = 3 Then
				$i += 1
				SetLog("Dropping Queen at " & $iX & ", " & $iY, $COLOR_INFO)
				SelectDropTroop($iQueenSlotNumber, 1, Default, False)
				If _Sleep($DELAYDROPHEROES2) Then Return
				AttackClick($iX + Random(10, 30, 1), $iY + Random(10, 30, 1), 1, 0, 0, "#0095")
				If Not $g_bDropQueen Then ; check global flag, only begin hero health check on 1st hero drop as flag is reset to false after activation
					$g_bCheckQueenPower = True
				Else
					SetDebugLog("Queen dropped 2nd time, Check Power flag not changed") ; do nothing as hero already dropped
				EndIf
				$g_bDropQueen = True ; Set global flag hero dropped
				$g_aHeroesTimerActivation[$eHeroArcherQueen] = __TimerInit() ; initialize fixed activation timer
				If RandomSleep($DELAYDROPHEROES1 * 2) Then Return
			EndIf

			;If RandomSleep($DELAYDROPHEROES1 * 2) Then Return

			If $bDropWarden And $g_bDropWarden = 0 And Random(0, 5, 1) = 2 Then
				$i += 1
				SetLog("Dropping Grand Warden at " & $iX & ", " & $iY, $COLOR_INFO)
				SelectDropTroop($iWardenSlotNumber, 1, Default, False)
				If _Sleep($DELAYDROPHEROES2) Then Return
				AttackClick($iX + Random(-10, 30, 1), $iY + Random(-10, 30, 1), 1, 0, 0, "#x999")
				If Not $g_bDropWarden Then ; check global flag, only begin hero health check on 1st hero drop as flag is reset to false after activation
					$g_bCheckWardenPower = True
				Else
					SetDebugLog("Warden dropped 2nd time, Check Power flag not changed") ; do nothing as hero already dropped
				EndIf
				$g_bDropWarden = True ; Set global flag hero dropped
				$g_aHeroesTimerActivation[$eHeroGrandWarden] = __TimerInit() ; initialize fixed activation timer
				If RandomSleep($DELAYDROPHEROES1 * 2) Then Return
			EndIf

			;If RandomSleep($DELAYDROPHEROES1 * 2) Then Return

			If $bDropChampion And $g_bDropChampion = 0 And Random(0, 5, 1) = 1 Then
				$i += 1
				SetLog("Dropping Royal Champion at " & $iX & ", " & $iY, $COLOR_INFO)
				SelectDropTroop($iChampionSlotNumber, 1, Default, False)
				If _Sleep($DELAYDROPHEROES2) Then Return
				AttackClick($iX + Random(0, 40, 1), $iY + Random(0, 40, 1), 1, 0, 0, "#x999")
				If Not $g_bDropChampion Then ; check global flag, only begin hero health check on 1st hero drop as flag is reset to false after activation
					$g_bCheckChampionPower = True
				Else
					SetDebugLog("Royal Champion dropped 2nd time, Check Power flag not changed") ; do nothing as hero already dropped
				EndIf
				$g_bDropChampion = True ; Set global flag hero dropped
				$g_aHeroesTimerActivation[$eHeroRoyalChampion] = __TimerInit() ; initialize fixed activation timer
				If RandomSleep($DELAYDROPHEROES1 * 2) Then Return
			EndIf

			;If RandomSleep($DELAYDROPHEROES1 * 2) Then Return
			$count += 1
			If $count > 20 Then
				SetLog("Looped 20 times now...", $COLOR_INFO)
				SetLog("Something maybe wrong, exiting dropHeroes Loop!", $COLOR_INFO)
				ExitLoop
			EndIf
		Until $i = 4
	EndIF

EndFunc   ;==>dropHeroes

