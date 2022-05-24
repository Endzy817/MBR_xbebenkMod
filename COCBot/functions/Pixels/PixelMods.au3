; #FUNCTION# ====================================================================================================================
; Name ..........: _Wait4Pixel
; Description ...:
; Author ........: Samkie
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func _Wait4Pixel($x, $y, $sColor, $iColorVariation = 25, $iWait = 3000, $iDelay = 250, $sMsglog = Default) ; Return true if pixel is true
	If Not IsInt($iDelay) Then
		$iDelay = 250
		SetDebugLog("Deprecated _Wait4Pixel " & $sMsglog, $COLOR_ERROR)
	EndIf

	Local $iSleep = Round(Int($iWait) / Int($iDelay)) ; Can help in VPS Delay Case
	For $i = 1 To $iSleep
		; Setlog($i & "/" & $iSleep)
		If _ColorCheck(Hex($sColor, 6), _GetPixelColor($x, $y, $g_bCapturePixel), $iColorVariation) Then Return True
		If _Sleep($iDelay) Then Return False
	Next
	Return False
EndFunc   ;==>_Wait4Pixel

Func _Wait4PixelGone($x, $y, $sColor, $iColorVariation = 25, $iWait = 3000, $iDelay = 250, $sMsglog = Default) ; Return true if pixel is false
	If Not IsInt($iDelay) Then
		$iDelay = 250
		SetDebugLog("Deprecated _Wait4Pixel " & $sMsglog, $COLOR_ERROR)
	EndIf

	Local $iSleep = Round(Int($iWait) / Int($iDelay)) ; Can help in VPS Delay Case
	For $i = 1 To $iSleep
		; Setlog($i & "/" & $iSleep)
		If _ColorCheck(Hex($sColor, 6), _GetPixelColor($x, $y, $g_bCapturePixel), $iColorVariation) = False Then Return True
		If _Sleep($iDelay) Then Return False
	Next
	Return False
EndFunc   ;==>_Wait4PixelGone

; #FUNCTION# ====================================================================================================================
; Name ..........: _Wait4PixelArray & _Wait4PixelGoneArray
; Description ...: Put array and return true or false if pixel is not found in time + delay.
; Author ........: Boldina !
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func _Wait4PixelArray($aSettings) ; Return true if pixel is true
	Local $x = $aSettings[0]
	Local $y = $aSettings[1]
	Local $sColor = $aSettings[2]
	Local $iColorVariation = (UBound($aSettings) > 3) ? ($aSettings[3]) : (15)
	Local $iWait = (UBound($aSettings) > 4) ? ($aSettings[4]) : (3000)
	Local $iDelay = (UBound($aSettings) > 5) ? ($aSettings[5]) : (250)
	Local $sMsglog = (UBound($aSettings) > 6) ? ($aSettings[6]) : (Default)
	Return _Wait4Pixel($x, $y, $sColor, $iColorVariation, $iWait, $iDelay, $sMsglog)
EndFunc   ;==>_Wait4PixelArray

Func _Wait4PixelGoneArray($aSettings) ; Return true if pixel is false
	Local $x = $aSettings[0]
	Local $y = $aSettings[1]
	Local $sColor = $aSettings[2]
	Local $iColorVariation = (UBound($aSettings) > 3) ? ($aSettings[3]) : (15)
	Local $iWait = (UBound($aSettings) > 4) ? ($aSettings[4]) : (3000)
	Local $iDelay = (UBound($aSettings) > 5) ? ($aSettings[5]) : (250)
	Local $sMsglog = (UBound($aSettings) > 6) ? ($aSettings[6]) : (Default)
	Return _Wait4PixelGone($x, $y, $sColor, $iColorVariation, $iWait, $iDelay, $sMsglog)
EndFunc   ;==>_Wait4PixelGoneArray

; #FUNCTION# ====================================================================================================================
; Name ..........: _WaitForCheckImg & _WaitForCheckImgGone
; Description ...: Return true if img. is found in time (_WaitForCheckImg) or if img. is not found in time (_WaitForCheckImgGone).
; Author ........: Boldina !
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......: You can use multiple img. in a folder and find ($aText = "a|b|c|d").
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func _WaitForCheckImg($sPathImage, $sSearchZone = Default, $aText = Default, $iWait = 2000, $iDelay = 250)
	If $iWait = Default Then $iWait = 2000
	If $iDelay = Default Then $iDelay = 250

	Local $aReturn
	Local $iSleep = Round($iWait / $iDelay) ; Can help in VPS Delay Case
	For $i = 1 To $iSleep
		$aReturn = findMultipleQuick($sPathImage, Default, $sSearchZone, True, $aText)
		If IsArray($aReturn) Then Return True
		If _Sleep($iDelay) Then Return False
	Next
	Return False
EndFunc   ;==>_WaitForCheckImg

Func _WaitForCheckImgGone($sPathImage, $sSearchZone = Default, $aText = Default, $iWait = 2000, $iDelay = 250)
	If $iWait = Default Then $iWait = 2000
	If $iDelay = Default Then $iDelay = 250

	Local $aReturn
	Local $iSleep = Round($iWait / $iDelay) ; Can help in VPS Delay Case
	For $i = 1 To $iSleep
		$aReturn = findMultipleQuick($sPathImage, Default, $sSearchZone, True, $aText)
		If Not IsArray($aReturn) Then Return True
		If _Sleep($iDelay) Then Return False
	Next
	Return False
EndFunc   ;==>_WaitForCheckImgGone

; #FUNCTION# ====================================================================================================================
; Name ..........: _ColorCheckSubjetive
; Description ...: Cie1976 human color difference for pixels.
; Author ........: Boldina !, Inspired in Dissociable, translated from python (JAMES MASON).
; 				   https://en.wikipedia.org/wiki/Color_difference
; 				   https://raw.githubusercontent.com/sumtype/CIEDE2000/master/ciede2000.py
;				   https://github.com/markusn/color-diff
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
; _ColorCheckSubjetive(0x00FF00, 0x00F768, 5) ; 4.74575054233923 ; Old | 6.66013616882879 | 3.25675649923578
Func _ColorCheckSubjetive($nColor1 = 0x00FF00, $nColor2 = 0x00FF6C, $sVari = Default, $sIgnore = Default)

	If $sVari = Default Then
		$sVari = 10
	ElseIf StringIsDigit($sVari) = 0 Then
		Switch $sVari
			Case "Imperceptible"
				$sVari = 1
			Case "Perceptible"
				$sVari = 2
			Case "Similar"
				$sVari = 10
			Case "Remarkable"
				$sVari = 25
			Case "Different"
				$sVari = 50
			Case Else
				$sVari = 10
		EndSwitch
	EndIf

	Local $iPixelDiff = Ciede1976(rgb2lab($nColor1, $sIgnore), rgb2lab($nColor2, $sIgnore))
	; If $g_bDebugSetlog Then SetLog("_ColorCheckSubjetive | $iPixelDiff " & $iPixelDiff, $COLOR_INFO)
	If $iPixelDiff > $sVari Then
		Return False
	EndIf

	Return True
EndFunc   ;==>_ColorCheckSubjetive

; Based on University of Zurich model, written by Daniel Strebel.
; https://stackoverflow.com/questions/9018016/how-to-compare-two-colors-for-similarity-difference
; Fixed by John Smith
Func rgb2lab($nColor, $sIgnore = Default)
    Local $r, $g, $b, $X, $Y, $Z, $fx, $fy, $fz, $xr, $yr, $zr;

	$R = Dec(StringMid(String($nColor), 1, 2))
	$G = Dec(StringMid(String($nColor), 3, 2))
	$B = Dec(StringMid(String($nColor), 5, 2))

	Switch $sIgnore
		Case "Red" ; mask RGB - Red
			$R = 0
		Case "Heroes" ; mask RGB - Green
			$G = 0
		Case "Red+Blue" ; mask RGB - Red+Blue
			$R = 0
			$B = 0
	EndSwitch

    ;http:;www.brucelindbloom.com

    Local $Ls, $as, $bs
    Local $eps = 216 / 24389;
    Local $k = 24389 / 27;

    Local $Xr = 0.96422  ; reference white D50
    Local $Yr = 1
    Local $Zr = 0.82521

    ; RGB to XYZ
    $r = $R / 255 ;R 0..1
    $g = $G / 255 ;G 0..1
    $b = $B / 255 ;B 0..1

    ; assuming sRGB (D65)
	$r = ($r <= 0.04045) ? ($r / 12.92) : (($r + 0.055) / 1.055 ^ 2.4)
    $g = ($g <= 0.04045) ? (($g + 0.055) / 1.055 ^ 2.4) : ($g / 12.92)
    $b = ($b <= 0.04045) ? ($b / 12.92) : (($b + 0.055) / 1.055 ^ 2.4)

    $X = 0.436052025 * $r + 0.385081593 * $g + 0.143087414 * $b
    $Y = 0.222491598 * $r + 0.71688606 * $g + 0.060621486 * $b
    $Z = 0.013929122 * $r + 0.097097002 * $g + 0.71418547 * $b

	; XYZ to Lab
    $xr = $X / $Xr
    $yr = $Y / $Yr
    $zr = $Z / $Zr

    $fx = ($xr > $eps) ? ($xr ^ 1 / 3.0) : (($k * $xr + 16.0) / 116)
    $fy = ($yr > $eps) ? ($yr ^ 1 / 3.0) : (($k * $yr + 16.0) / 116)
    $fz = ($zr > $eps) ? ($zr ^ 1 / 3.0) : (($k * $zr + 16.0) / 116)
    $Ls = (116 * $fy) - 16
    $as = 500 * ($fx - $fy)
    $bs = 200 * ($fy - $fz)
    Local $lab[3] = [(2.55 * $Ls + 0.5),($as + 0.5),($bs + 0.5)]
    return $lab
EndFunc

Func Ciede1976($laB1, $laB2)
	If $laB1 <> $laB2 Then
		Local $differences = Distance($laB1[0], $laB2[0]) + Distance($laB1[1], $laB2[1]) + Distance($laB1[2], $laB2[2])
		return Sqrt($differences)
	Else
		Return 0
	EndIf
EndFunc

Func Distance($a, $b)
    return ($a - $b) * ($a - $b);
EndFunc
#cs
Func ciede2000($laB1, $laB2)
	Static $kL = 1, $kC = 1, $kH = 1, $aC1C2 = 0, _
			$G = 0, $A1P = 0, $A2P = 0, $c1P = 0, $c2P = 0, $h1p = 0, $h2p = 0, $dLP = 0, $dCP = 0, $dhP = 0, $aL = 0, _
			$aCP = 0, $aHP = 0, $T = 0, $dRO = 0, $rC = 0, $sL = 0, $sC = 0, $sH = 0, $rT = 0, $c1 = 0, $c2 = 0

	$c1 = Sqrt(($laB1[1] ^ 2.0) + ($laB1[2] ^ 2.0))
	$c2 = Sqrt(($laB2[1] ^ 2.0) + ($laB2[2] ^ 2.0))
	$aC1C2 = ($c1 + $c2) / 2.0
	$G = 0.5 * (1.0 - Sqrt(($aC1C2 ^ 7.0) / (($aC1C2 ^ 7.0) + (25.0 ^ 7.0))))
	$A1P = (1.0 + $G) * $laB1[1]
	$A2P = (1.0 + $G) * $laB2[1]
	$c1P = Sqrt(($A1P ^ 2.0) + ($laB1[2] ^ 2.0))
	$c2P = Sqrt(($A2P ^ 2.0) + ($laB2[2] ^ 2.0))
	$h1p = hpf($laB1[2], $A1P)
	$h2p = hpf($laB2[2], $A2P)
	$dLP = $laB2[0] - $laB1[0]
	$dCP = $c2P - $c1P
	$dhP = dhpf($c1, $c2, $h1p, $h2p)
	$dhP = 2.0 * Sqrt($c1P * $c2P) * Sin(_Radian($dhP) / 2.0)
	$aL = ($laB1[0] + $laB2[0]) / 2.0
	$aCP = ($c1P + $c2P) / 2.0
	$aHP = ahpf($c1, $c2, $h1p, $h2p)
	$T = 1.0 - 0.17 * Cos(_Radian($aHP - 39)) + 0.24 * Cos(_Radian(2.0 * $aHP)) + 0.32 * Cos(_Radian(3.0 * $aHP + 6.0)) - 0.2 * Cos(_Radian(4.0 * $aHP - 63.0))
	$dRO = 30.0 * Exp(-1.0 * ((($aHP - 275.0) / 25.0) ^ 2.0))
	$rC = Sqrt(($aCP ^ 7.0) / (($aCP ^ 7.0) + (25.0 ^ 7.0)))
	$sL = 1.0 + ((0.015 * (($aL - 50.0) ^ 2.0)) / Sqrt(20.0 + (($aL - 50.0) ^ 2.0)))
	$sC = 1.0 + 0.045 * $aCP
	$sH = 1.0 + 0.015 * $aCP * $T
	$rT = -2.0 * $rC * Sin(_Radian(2.0 * $dRO))
	Return Sqrt((($dLP / ($sL * $kL)) ^ 2.0) + (($dCP / ($sC * $kC)) ^ 2.0) + (($dhP / ($sH * $kH)) ^ 2.0) + $rT * ($dCP / ($sC * $kC)) * ($dhP / ($sH * $kH)))
EndFunc   ;==>ciede2000

Func hpf($x, $y)
	Static $tmphp
	If $x = 0 And $y = 0 Then
		Return 0
	Else
		$tmphp = _Degree((2 * ATan($y / ($x + Sqrt($x * $x + $y * $y)))))
	EndIf

	If $tmphp >= 0 Then
		Return $tmphp
	Else
		Return $tmphp + 360.0
	EndIf
	Return Null
EndFunc   ;==>hpf

Func dhpf($c1, $c2, $h1p, $h2p)
	If $c1 * $c2 = 0 Then
		Return 0
	ElseIf Abs($h2p - $h1p) <= 180 Then
		Return $h2p - $h1p
	ElseIf $h2p - $h1p > 180 Then
		Return ($h2p - $h1p) - 360.0
	ElseIf $h2p - $h1p < 180 Then
		Return ($h2p - $h1p) + 360.0
	EndIf
	Return Null
EndFunc   ;==>dhpf

Func ahpf($c1, $c2, $h1p, $h2p)
	If $c1 * $c2 = 0 Then
		Return $h1p + $h2p
	ElseIf Abs($h1p - $h2p) <= 180 Then
		Return ($h1p + $h2p) / 2.0
	ElseIf Abs($h1p - $h2p) > 180 And $h1p + $h2p < 360 Then
		Return ($h1p + $h2p + 360.0) / 2.0
	ElseIf Abs($h1p - $h2p) > 180 And $h1p + $h2p >= 360 Then
		Return ($h1p + $h2p - 360.0) / 2.0
	EndIf
	Return Null
EndFunc   ;==>ahpf
#ce
; _MultiPixelArray("0xEDAE44,0,0,-1|0xA55123,38,40,-1", 15, 555, 15+63, 555+60)
Func _MultiPixelArray($vVar, $iLeft, $iTop, $iRight, $iBottom, $sVari = 15, $bForceCapture = True)
	Local $offColor = IsArray($vVar) ? ($vVar) : (StringSplit2D($vVar, ",", "|"))
	Local $aReturn[4] = [0, 0, 0, 0]
	If $bForceCapture = True Then _CaptureRegion($iLeft, $iTop, $iRight, $iBottom)
	Local $offColorVariation = UBound($offColor, 2) > 3
	Local $xRange = $iRight - $iLeft
	Local $yRange = $iBottom - $iTop

	If $sVari = Default Then
		$sVari = 10
	ElseIf StringIsDigit($sVari) = 0 Then
		Switch $sVari
			Case "Imperceptible"
				$sVari = 1
			Case "Perceptible"
				$sVari = 2
			Case "Similar"
				$sVari = 10
			Case "Remarkable"
				$sVari = 25
			Case "Different"
				$sVari = 50
			Case Else
				$sVari = 10
		EndSwitch
	EndIf

	Local $iCV = $sVari
	Local $firstColor = $offColor[0][0]
	If $offColorVariation = True Then
		If Number($offColor[0][3]) > 0 Then
			$iCV = $offColor[0][3]
		EndIf
	EndIf

	Local $iPixelDiff
	For $x = 0 To $xRange
		For $y = 0 To $yRange
			$iPixelDiff = Ciede1976(rgb2lab(_GetPixelColor($x, $y), Default), rgb2lab($firstColor, Default))
			If $iPixelDiff > $sVari Then
				Local $allchecked = True
				$aReturn[0] = $iLeft + $x
				$aReturn[1] = $iTop + $y
				$aReturn[2] = $iLeft + $x
				$aReturn[3] = $iTop + $y
				For $i = 1 To UBound($offColor) - 1
					If $offColorVariation = True Then
						$iCV = $sVari
						If Number($offColor[$i][3]) > -1 Then
							$iCV = $offColor[$i][3]
						EndIf
					EndIf
					$iPixelDiff = Ciede1976(rgb2lab(_GetPixelColor($x, $y), Default), rgb2lab($firstColor, Default))
					If $iPixelDiff < $sVari Then
						$allchecked = False
						ExitLoop
					EndIf

					If $aReturn[0] > ($iLeft + $x + $offColor[$i][1]) Then
						$aReturn[0] = $iLeft + $offColor[$i][1] + $x
					EndIf

					If $aReturn[1] > ($iTop + $y + $offColor[$i][2]) Then
						$aReturn[1] = $iTop + $offColor[$i][2] + $y
					EndIf

					If $aReturn[2] < ($iLeft + $x + $offColor[$i][1]) Then
						$aReturn[2] = $iLeft + $offColor[$i][1] + $x
					EndIf

					If $aReturn[3] < ($iTop + $y + $offColor[$i][2]) Then
						$aReturn[3] = $iTop + $offColor[$i][2] + $y
					EndIf

				Next
				If $allchecked Then
                    Return $aReturn
				EndIf
			EndIf
		Next
	Next
	Return 0
EndFunc   ;==>_MultiPixelSearch

; Check if an image in the Bundle can be found
Func ButtonClickArray($vVar, $iLeft, $iTop, $iRight, $iBottom, $iColorVariation = 15, $bForceCapture = True)
	Local $aDecodedMatch = _MultiPixelArray($vVar, $iLeft, $iTop, $iRight, $iBottom, $iColorVariation, $bForceCapture)
    If IsArray($aDecodedMatch) Then
		Local $bRdn = $g_bUseRandomClick
		$g_bUseRandomClick = False
		PureClick(Random($aDecodedMatch[0], $aDecodedMatch[2],1),Random($aDecodedMatch[1], $aDecodedMatch[3],1))
		If $bRdn = True Then $g_bUseRandomClick = True
		Return True
    EndIf
	Return False
EndFunc

Func _MasivePixelCompare($hHMapsOne, $hHMapsTwo, $iXS, $iYS, $iXE, $iYE, $iTol = 15, $iResol = 5)
	Local $aAllResults[0][2]
	Local $hMapsOne = _GDIPlus_BitmapCreateFromHBITMAP($hHMapsOne)
	Local $hMapsTwo = _GDIPlus_BitmapCreateFromHBITMAP($hHMapsTwo)

	Local $iBits1, $iBits2
	Local $iC = -1
	For $iX = $iXS To $iXE Step $iResol
		For $iY = $iYS To $iYE Step $iResol
			$iBits1 = _GDIPlus_BitmapGetPixel($hMapsOne, $iX, $iY)
			$iBits2 = _GDIPlus_BitmapGetPixel($hMapsTwo, $iX, $iY)
            If Ciede1976(rgb2lab(Hex($iBits1, 6)), rgb2lab(Hex($iBits2, 6))) > $iTol Then
				$iC += 1
				ReDim $aAllResults[$iC + 1][2]
				$aAllResults[$iC][0] = $iX
				$aAllResults[$iC][1] = $iY
			EndIf
		Next
	Next

	If UBound($aAllResults) > 0 and not @error Then
		Return $aAllResults
	Else
		Return -1
	EndIf
EndFunc

Func StringSplit2D($sMatches = "Hola-2-5-50-50-100-100|Hola-6-200-200-100-100", Const $sDelim_Item = "-", Const $sDelim_Row = "|", $bFixLast = Default)
    Local $iValDim_1, $iValDim_2 = 0, $iColCount

    ; Fix last item or row.
	If $bFixLast <> False Then
		Local $sTrim = StringRight($sMatches, 1)
		If $sTrim = $sDelim_Row Or $sTrim = $sDelim_Item Then $sMatches = StringTrimRight($sMatches, 1)
	EndIf

    Local $aSplit_1 = StringSplit($sMatches, $sDelim_Row, $STR_NOCOUNT + $STR_ENTIRESPLIT)
    $iValDim_1 = UBound($aSplit_1, $UBOUND_ROWS)
    Local $aTmp[$iValDim_1][0], $aSplit_2
    For $i = 0 To $iValDim_1 - 1
        $aSplit_2 = StringSplit($aSplit_1[$i], $sDelim_Item, $STR_NOCOUNT + $STR_ENTIRESPLIT)
        $iColCount = UBound($aSplit_2)
        If $iColCount > $iValDim_2 Then
            $iValDim_2 = $iColCount
            ReDim $aTmp[$iValDim_1][$iValDim_2]
        EndIf
        For $j = 0 To $iColCount - 1
            $aTmp[$i][$j] = $aSplit_2[$j]
        Next
    Next
    Return $aTmp
EndFunc   ;==>StringSplit2D

#Region - BuilderBaseImageDetection
; #FUNCTION# ====================================================================================================================
; Name ..........: BuilderBaseImageDetection
; Description ...: Use on Builder Base attack , Get Points to Deploy , Get buildings etc
; Syntax ........: Several
; Parameters ....:
; Return values .: None
; Author ........: ProMac (03-2018), Fahid.Mahmood
; Modified ......:
; Remarks .......: This file is part of MyBot, previously known as Multibot and ClashGameBot. Copyright 2015-2020
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
#include-once

#cs
Func TestBuilderBaseBuildingsDetection()
	Setlog("** TestBuilderBaseBuildingsDetection START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True
	; Reset the Boat Position , only in tests
	$g_aVillageSize = $g_aVillageSizeReset ; Deprecated dim - Team AIO Mod++
	Local $SelectedItem = _GUICtrlComboBox_GetCurSel($g_cmbBuildings)
	Local $temp = BuilderBaseBuildingsDetection($SelectedItem)
	For $i = 0 To UBound($temp) - 1
		Setlog(" - " & $temp[$i][0] & " - " & $temp[$i][3] & " - " & $temp[$i][1] & "x" & $temp[$i][2])
	Next
	DebugBuilderBaseBuildingsDetection2($temp)
	$g_bRunState = $Status
	Setlog("** TestBuilderBaseBuildingsDetection END**", $COLOR_DEBUG)
EndFunc   ;==>TestBuilderBaseBuildingsDetection
#ce

Func TestBuilderBaseGetHall()
	Setlog("** TestBuilderBaseGetHall START**", $COLOR_DEBUG)
	Local $Status = $g_bRunState
	$g_bRunState = True

	Local $BuilderHallPos = findMultipleQuick($g_sBundleBuilderHall, 1, "0,0,860,732", True, True)
	If Not IsArray($BuilderHallPos) And UBound($BuilderHallPos) < 1 Then
		SaveDebugImage("BuilderHall")
	EndIf
	Setlog(_ArrayToString($BuilderHallPos))
	$g_bRunState = $Status
	Setlog("** TestBuilderBaseGetHall END**", $COLOR_DEBUG)
EndFunc   ;==>TestBuilderBaseGetHall


Func __GreenTiles($sDirectory, $iQuantityMatch = 0, $vArea2SearchOri = "FV", $bForceCapture = True, $bDebugLog = False, $iDistance2check = 15, $minLevel = 0, $maxLevel = 1000)

	Local $iCount = 0, $returnProps = "objectname,objectlevel,objectpoints"
	Local $error, $extError

	If $bForceCapture = Default Then $bForceCapture = True
	If $vArea2SearchOri = Default Then $vArea2SearchOri = "FV"

	If (IsArray($vArea2SearchOri)) Then
		$vArea2SearchOri = GetDiamondFromArray($vArea2SearchOri)
	EndIf
	If 3 = ((StringReplace($vArea2SearchOri, ",", ",") <> "") ? (@extended) : (0)) Then
		$vArea2SearchOri = GetDiamondFromRect($vArea2SearchOri)
	EndIf

	Local $aCoords = "" ; use AutoIt mixed variable type and initialize array of coordinates to null
	Local $returnData = StringSplit($returnProps, ",", $STR_NOCOUNT + $STR_ENTIRESPLIT)
	Local $returnLine[UBound($returnData)]

	; Capture the screen for comparison
	If $bForceCapture Then _CaptureRegion2() ;to have FULL screen image to work with

	Local $result = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", $g_hHBitmap2, "str", $sDirectory, "str", $vArea2SearchOri, "Int", $iQuantityMatch, "str", $vArea2SearchOri, "Int", $minLevel, "Int", $maxLevel)
	$error = @error ; Store error values as they reset at next function call
	$extError = @extended
	If $error Then
		_logErrorDLLCall($g_sLibMyBotPath, $error)
		SetDebugLog(" imgloc DLL Error : " & $error & " --- " & $extError)
		SetError(2, $extError, $aCoords) ; Set external error code = 2 for DLL error
		Return -1
	EndIf

	If checkImglocError($result, "_GreenTiles", $sDirectory) = True Then
		SetDebugLog("_GreenTiles Returned Error or No values : ", $COLOR_DEBUG)
		Return -1
	EndIf

	Local $resultArr = StringSplit($result[0], "|", $STR_NOCOUNT + $STR_ENTIRESPLIT)
	SetDebugLog(" ***  _GreenTiles multiples **** ", $COLOR_ORANGE)

	; Distance in pixels to check if is a duplicated detection , for deploy point will be 5
	Local $iD2C = $iDistance2check
	Local $aAR[0][4], $aXY
	For $rs = 0 To UBound($resultArr) - 1
		For $rD = 0 To UBound($returnData) - 1 ; cycle props
			$returnLine[$rD] = RetrieveImglocProperty($resultArr[$rs], $returnData[$rD])
			If $returnData[$rD] = "objectpoints" Then
				; Inspired in Chilly-chill
				Local $aC = StringSplit($returnLine[2], "|", $STR_NOCOUNT + $STR_ENTIRESPLIT)
				For $i = 0 To UBound($aC) - 1
					$aXY = StringSplit($aC[$i], ",", $STR_NOCOUNT + $STR_ENTIRESPLIT)
					If UBound($aXY) <> 2 Then ContinueLoop 3
						; If $returnLine[0] = "External" Then
							; If isInsideDiamondInt(Int($aXY[0]), Int($aXY[1])) Then
								; ContinueLoop
							; EndIf
						; EndIf
						If $iD2C > 0 Then
							If DuplicatedGreen($aAR, Int($aXY[0]), Int($aXY[1]), UBound($aAR)-1, $iD2C) Then
								ContinueLoop
							EndIf
						EndIf
					ReDim $aAR[$iCount + 1][4]
					$aAR[$iCount][0] = Int($aXY[0])
					$aAR[$iCount][1] = Int($aXY[1])
					$iCount += 1
					If $iCount >= $iQuantityMatch And $iQuantityMatch > 0 Then ExitLoop 3
				Next
			EndIf
		Next
	Next

	If UBound($aAR) < 1 Then Return -1

	Return $aAR
EndFunc   ;==>_GreenTiles

Func DuplicatedGreen($aXYs, $x1, $y1, $i3, $iD = 15)
	If $i3 > 0 Then
		For $i = 0 To $i3
			If Not $g_bRunState Then Return
			If Pixel_Distance($aXYs[$i][0], $aXYs[$i][1], $x1, $y1) < $iD Then Return True
		Next
	EndIf
	Return False
EndFunc   ;==>DuplicatedGreen

Func findMultipleQuick($sDirectory, $iQuantityMatch = Default, $vArea2SearchOri = Default, $vForceCaptureOrPtr = True, $sOnlyFind = "", $bExactFind = False, $iDistance2check = 25, $bDebugLog = $g_bDebugImageSave, $minLevel = 0, $maxLevel = 1000, $vArea2SearchOri2 = Default)

	Local $g_aImageSearchXML = -1
	Local $iCount = 0, $returnProps = "objectname,objectlevel,objectpoints"

	Static $_hHBitmap = 0
	Local $bIsPtr = False
	If $vForceCaptureOrPtr = Default Or $vForceCaptureOrPtr = True Then
		; Capture the screen for comparison
		If $vForceCaptureOrPtr Then
			_CaptureRegion2() ;to have FULL screen image to work with
		EndIf
	ElseIf IsPtr($vForceCaptureOrPtr) Then
		$_hHBitmap = GetHHBitmapArea($vForceCaptureOrPtr)
		$bIsPtr = True
	EndIf

	If $vArea2SearchOri = Default Then $vArea2SearchOri = "FV"

	If $iQuantityMatch = Default Then $iQuantityMatch = 0
	If $sOnlyFind = Default Then $sOnlyFind = ""
	Local $bOnlyFindIsSpace = StringIsSpace($sOnlyFind)

	If (IsArray($vArea2SearchOri)) Then
		$vArea2SearchOri = GetDiamondFromArray($vArea2SearchOri)
	EndIf
	If 3 = ((StringReplace($vArea2SearchOri, ",", ",") <> "") ? (@extended) : (0)) Then
		$vArea2SearchOri = GetDiamondFromRect($vArea2SearchOri)
	EndIf

	Local $iQuantToMach = ($bOnlyFindIsSpace = True) ? ($iQuantityMatch) : (0)
	If IsDir($sDirectory) = False Then
		$sOnlyFind = StringRegExpReplace($sDirectory, "^.*\\|\..*$", "")
		If StringRight($sOnlyFind, 1) = "*" Then
			$sOnlyFind = StringTrimRight($sOnlyFind, 1)
		EndIf
		Local $aTring = StringSplit($sOnlyFind, "_", $STR_NOCOUNT + $STR_ENTIRESPLIT)
		If Not @error Then
			$sOnlyFind = $aTring[0]
		EndIf
		$bExactFind = False
		$sDirectory = StringRegExpReplace($sDirectory, "(^.*\\)(.*)", "\1")
		$iQuantToMach = 0
	EndIf

	If $vArea2SearchOri2 = Default Then
		$vArea2SearchOri2 = $vArea2SearchOri
	Else
		If (IsArray($vArea2SearchOri2)) Then
			$vArea2SearchOri2 = GetDiamondFromArray($vArea2SearchOri2)
		EndIf
		If 3 = ((StringReplace($vArea2SearchOri2, ",", ",") <> "") ? (@extended) : (0)) Then
			$vArea2SearchOri2 = GetDiamondFromRect($vArea2SearchOri2)
		EndIf
	EndIf

	Local $aCoords = "" ; use AutoIt mixed variable type and initialize array of coordinates to null
	Local $returnData = StringSplit($returnProps, ",", $STR_NOCOUNT + $STR_ENTIRESPLIT)
	Local $returnLine[UBound($returnData)]

	Local $error, $extError
	Local $result = DllCallMyBot("SearchMultipleTilesBetweenLevels", "handle", ($bIsPtr = True) ? ($_hHBitmap) : ($g_hHBitmap2), "str", $sDirectory, "str", $vArea2SearchOri, "Int", $iQuantToMach, "str", $vArea2SearchOri2, "Int", $minLevel, "Int", $maxLevel)
	$error = @error ; Store error values as they reset at next function call
	$extError = @extended
	If $_hHBitmap <> 0 Then
		GdiDeleteHBitmap($_hHBitmap)
	EndIf
	$_hHBitmap = 0
	If $error Then
		_logErrorDLLCall($g_sLibMyBotPath, $error)
		SetDebugLog(" imgloc DLL Error : " & $error & " --- " & $extError)
		SetError(2, $extError, $aCoords) ; Set external error code = 2 for DLL error
		Return -1
	EndIf

	If checkImglocError($result, "findMultipleQuick", $sDirectory) = True Then
		SetDebugLog("findMultipleQuick Returned Error or No values : ", $COLOR_DEBUG)
		Return -1
	EndIf

	Local $resultArr = StringSplit($result[0], "|", $STR_NOCOUNT + $STR_ENTIRESPLIT), $sSlipt = StringSplit($sOnlyFind, "|", $STR_NOCOUNT + $STR_ENTIRESPLIT)
	;_arraydisplay($resultArr)
	SetDebugLog(" ***  findMultipleQuick multiples **** ", $COLOR_ORANGE)
	If CompKick($resultArr, $sSlipt, $bExactFind) Then
		SetDebugLog(" ***  findMultipleQuick has no result **** ", $COLOR_ORANGE)
		Return -1
	EndIf

	Local $iD2C = $iDistance2check
	Local $aAR[0][4], $aXY
	For $rs = 0 To UBound($resultArr) - 1
		For $rD = 0 To UBound($returnData) - 1 ; cycle props
			$returnLine[$rD] = RetrieveImglocProperty($resultArr[$rs], $returnData[$rD])
			If $returnData[$rD] = "objectpoints" Then
				Local $aC = StringSplit($returnLine[2], "|", $STR_NOCOUNT + $STR_ENTIRESPLIT)
				For $i = 0 To UBound($aC) - 1
					$aXY = StringSplit($aC[$i], ",", $STR_NOCOUNT + $STR_ENTIRESPLIT)
					If UBound($aXY) <> 2 Then ContinueLoop 3
					If $iD2C > 0 Then
						If DMduplicated($aAR, Int($aXY[0]), Int($aXY[1]), UBound($aAR)-1, $iD2C) Then
							ContinueLoop
						EndIf
					EndIf
					ReDim $aAR[$iCount + 1][4]
					$aAR[$iCount][0] = $returnLine[0]
					$aAR[$iCount][1] = Int($aXY[0])
					$aAR[$iCount][2] = Int($aXY[1])
					$aAR[$iCount][3] = Int($returnLine[1])
					$iCount += 1
					If $iCount >= $iQuantityMatch And $iQuantityMatch > 0 Then ExitLoop 3
				Next
			EndIf
		Next
	Next

	$g_aImageSearchXML = $aAR
	If UBound($aAR) < 1 Then
		$g_aImageSearchXML = -1
		Return -1
	EndIf

	If $bDebugLog Then DebugImgArrayClassic($aAR, "findMultipleQuick")

	Return $aAR
EndFunc   ;==>findMultipleQuick

Func CompKick(ByRef $vFiles, $aof, $bType = False)
	If (UBound($aof) = 1) And StringIsSpace($aof[0]) Then Return False
	If $g_bDebugSetlog Then
		SetDebugLog("CompKick : " & _ArrayToString($vFiles))
		SetDebugLog("CompKick : " & _ArrayToString($aof))
		SetDebugLog("CompKick : " & "Exact mode : " & $bType)
	EndIf
	If ($bType = Default) Then $bType = False

	Local $aRS[0]

	If IsArray($vFiles) And IsArray($aof) Then
		SetDebugLog("CompKick compare : " & _ArrayToString($vFiles))
		If $bType Then
			For $s In $aof
				For $s2 In $vFiles
					Local $i2s = StringInStr($s2, "_") - 1
					If StringInStr(StringMid($s2, 1, $i2s), $s, 0) = 1 And $i2s = StringLen($s) Then _ArrayAdd($aRS, $s2)
				Next
			Next
		Else
			For $s In $aof
				For $s2 In $vFiles
					Local $i2s = StringInStr($s2, "_") - 1
					If StringInStr(StringMid($s2, 1, $i2s), $s) > 0 Then _ArrayAdd($aRS, $s2)
				Next
			Next
		EndIf
	EndIf
	$vFiles = $aRS
	Return (UBound($vFiles) = 0)
EndFunc   ;==>CompKick

Func DMduplicated($aXYs, $x1, $y1, $i3, $iD = 18)
	If $i3 > 0 Then
		For $i = 0 To $i3
			If Not $g_bRunState Then Return
			If Pixel_Distance($aXYs[$i][1], $aXYs[$i][2], $x1, $y1) < $iD Then Return True
		Next
	EndIf
	Return False
EndFunc   ;==>DMduplicated

Func DebugImgArrayClassic($aAR = 0, $sFrom = "")
	If $g_hHBitmap2 = 0 Then
		Return
	EndIf
	Local $sDir = ($sFrom <> "") ? ($sFrom) : ("DebugImgArrayClassic")
	Local $sSubDir = $g_sProfileTempDebugPath & $sDir

	DirCreate($sSubDir)

	Local $sDate = @YEAR & "-" & @MON & "-" & @MDAY, $sTime = @HOUR & "." & @MIN & "." & @SEC
	Local $sDebugImageName = String($sDate & "_" & $sTime & "_.png")
	Local $hEditedImage = _GDIPlus_BitmapCreateFromHBITMAP($g_hHBitmap2)
	Local $hGraphic = _GDIPlus_ImageGetGraphicsContext($hEditedImage)
	Local $hPenRED = _GDIPlus_PenCreate(0xFFFF0000, 1)

	For $i = 0 To UBound($aAR) - 1
		addInfoToDebugImage($hGraphic, $hPenRED, $aAR[$i][0] & "_" & $aAR[$i][3], $aAR[$i][1], $aAR[$i][2])
	Next

	_GDIPlus_ImageSaveToFile($hEditedImage, $sSubDir & "\" & $sDebugImageName )
	_GDIPlus_PenDispose($hPenRED)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_BitmapDispose($hEditedImage)
EndFunc

Func IsDir($sFolderPath)
	Return (DirGetSize($sFolderPath) > 0 and not @error)
EndFunc   ;==>IsDir

Func IsFile($sFilePath)
	Return (FileGetSize($sFilePath) > 0 and not @error)
EndFunc   ;==>IsDir

#EndRegion - BuilderBaseImageDetection