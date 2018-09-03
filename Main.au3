

;~ Author: Ferdinand Marx
;~ Projectname: Tankprojekt


;#################################################################################
;~   _____                                        _        _   _
;~  |  __ \                                      | |      | | (_)
;~  | |  | | ___   ___ _   _ _ __ ___   ___ _ __ | |_ __ _| |_ _  ___  _ __
;~  | |  | |/ _ \ / __| | | | '_ ` _ \ / _ \ '_ \| __/ _` | __| |/ _ \| '_ \
;~  | |__| | (_) | (__| |_| | | | | | |  __/ | | | || (_| | |_| | (_) | | | |
;~  |_____/ \___/ \___|\__,_|_| |_| |_|\___|_| |_|\__\__,_|\__|_|\___/|_| |_|
;#################################################################################

;~ Projektstart am 26.08.2013
; Ziel dieses Projekts war ein kleines Spiel, in dem man einen "Panzer" jagen und fangen muss.
; Irgendwann begann ich damit, dem Spiel einige rudimentäre AI-Ansätze hinzuzufügen.

; So entstanden unterschiedliche "Suchfunktionen".
; Search 1: Diese Funktion löst eine Suche über das komplette Spielfeld aus.
;~ 			Der eigene Panzer wird den anderen Jagen und versuchen zu fangen.

; Search 2: Diese Funktion löst eine Suche mit Radarimpulsen aus.
;~ 			Bei dieser Funktion hat der Gegnerpanzer die Möglichkeit zu flüchten.
;~ 			Der Linke Panzer wird auch die Raketen nutzen.
;~ 			Ein Treffer mit einer solchen Rakete macht den getroffenen Panzer manövrierunfähig.

; Search 3: Diese Suchfunktion aktiviert einen Scanner, der nur die Umgebung scannt.
;~ 			Befindet sich der feindliche Panzer innerhalb dieses Bereichs so wird er automatisch gefangen.


; Known BUGS - Bekannte Fehler
; Bei Search2 kann es zu Bugs kommen. Es kann vorkommen, dass der Panzer nicht gefunden wird und ewig im falschen Bereich gesucht wird.
; Es kann auch vorkommen, dass beide Panzer in einer Ecke hängen bleiben und nichts mehr passiert.
; Ich habe diese Fehler nicht mehr behoben, weil ich nicht mehr am Projekt arbeite.


; Ich habe fast alle Soundfiles entfernt, weil ich die Lizenzbedingungen für die Soundfiles nicht kenne.
; Es müssten also folgende Dateien ins Scriptverzeichnis gelegt werden, damit das Spiel auf ein paar Töne hat.

;~ pong.wav
;~ ping.mp3
;~ attack.wav


;###################################################
;~    _____            _             _
;~   / ____|          | |           | |
;~  | |     ___  _ __ | |_ _ __ ___ | |___
;~  | |    / _ \| '_ \| __| '__/ _ \| / __|
;~  | |___| (_) | | | | |_| | | (_) | \__ \
;~   \_____\___/|_| |_|\__|_|  \___/|_|___/
;###################################################

;~ up		-	Moves own Tank up / Bewegt eigenen Panzer nach Oben
;~ down 	-	Moves own Tank down / Bewegt eigenen Panzer nach unten
;~ left 	-	Moves own Tank left / Bewegt eigenen Panzer nach links
;~ right	-	Moves own Tank right / Bewegt eigenen Panzer nach rechts
;~ F1		-	Starts Seachpattern 1 / Startet Suchmuster 1
;~ F2		-	Starts Seachpattern 2 / Startet Suchmuster 2
;~ F3		-	Starts Seachpattern 3 / Startet Suchmuster 3
;~ F4		-	Fire missle /  Rakete abfeuern
;~ F5		-	Reload missle /  Rakete nachladen
;~ SPACE	-	Send radar ping / Radar aktivieren

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>

Global $hGraphic, $x1, $y1, $maxX, $maxY, $schrittweite, $zielx, $ziely, $hBrush, $hPen, $linex, $liney, $linex2, $ping, $entfernung
Global $radarstrahl, $kontakt, $radarshots, $oldx, $oldxwert, $ping2, $durchlaufsearch2
Global $misslex, $missley, $misslemovement, $treffer, $savex, $savey, $savedurchlauf,$version
$radarshots = 0
$misslemovement = 0
$savedurchlauf = 0
$durchlaufsearch2 = 0

$version="0.1.0.0"

HotKeySet("{f1}", "search")
HotKeySet("{f2}", "search2")
HotKeySet("{f3}", "search3")
HotKeySet("{f4}", "missle")
HotKeySet("{f5}", "missleladen")
HotKeySet("{esc}", "ende")
HotKeySet("{up}", "up")
HotKeySet("{down}", "down")
HotKeySet("{left}", "left")
HotKeySet("{right}", "right")
HotKeySet("{space}", "radar")


;~ OPTIONEN
;~ #############################
$schrittweite = 10
$schrittweitemissle = 10
;Zielkoords
$zielx = Random(0, 1450, 1)
$ziely = Random(0, 820, 1)
$kontakt = 0
;~ #############################

;~ Startwerte für Kreis
;~ ######################
$x1 = 50
$y1 = 50
;~ ######################

;~ Hier die maximalen Werte für den Bewegungsradius der Objekte
$maxX = 1450
$maxY = 820




#Region ### START Koda GUI section ### Form=Tankprojekt
$hGUI = GUICreate("Form1 " & "x: " & $x1 & " - y: " & $y1 & "### zielx: " & $zielx & " - ziely: " & $ziely & " - Ping Entfernung: " & $entfernung, 1475, 840, 230, 118)
$label1 = GUICtrlCreateLabel("test++++++++++++++++++++++++++++++++++++", 1, 1, 500, 15)
$label2 = GUICtrlCreateLabel("Status: ", 520, 1, 500, 15)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


_GDIPlus_Startup()
$hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI)


;Zeichne Bot
_GDIPlus_GraphicsDrawArc($hGraphic, $x1, $y1, 20, 20, 180, 360)

;Zeichne Ziel
$hPen = _GDIPlus_PenCreate() ;Erstelle Zeichenstift
_GDIPlus_PenSetColor($hPen, 0xFFEE0000) ;setze Farbe für Zeichenstift
_GDIPlus_GraphicsDrawArc($hGraphic, $zielx, $ziely, 20, 20, 180, 360, $hPen);Zeichne Ziel


While 1

	;Kollisionabfrage für x1 und y1 - FÜR TANK1
	kollision()

	_GDIPlus_GraphicsDrawArc($hGraphic, $zielx, $ziely, 20, 20, 180, 360, $hPen) ;Zeichne Ziel
	GUICtrlSetData($label1, "x: " & $x1 & " - y: " & $y1 & "### zielx: " & $zielx & " - ziely: " & $ziely & " - Ping Entfernung: " & $entfernung)

	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_GDIPlus_GraphicsDispose($hGraphic)
			_GDIPlus_Shutdown()
			Exit
	EndSwitch

WEnd



Func draw()



	_GDIPlus_GraphicsClear($hGraphic, 0xFFF0F0F0)


	If $x1 < $maxX Then
		$x1 = $x1 + $schrittweite
	EndIf

	If $y1 < $maxY Then
		$y1 = $y1 + $schrittweite
	EndIf

	_GDIPlus_GraphicsDrawArc($hGraphic, $x1, $y1, 20, 20, 180, 360)


EndFunc   ;==>draw



Func up()
	_GDIPlus_GraphicsClear($hGraphic, 0xFFF0F0F0)

	If $y1 < $maxY And $y1 > 0 Then
		$y1 = $y1 - $schrittweite
	Else
		If $y1 = $maxY Then
			$y1 = $y1 - $schrittweite
		EndIf
	EndIf
	_GDIPlus_GraphicsDrawArc($hGraphic, $x1, $y1, 20, 20, 180, 360)
	_GDIPlus_GraphicsDrawArc($hGraphic, $zielx, $ziely, 20, 20, 180, 360, $hPen)
	kollision()
EndFunc   ;==>up




Func down()
	_GDIPlus_GraphicsClear($hGraphic, 0xFFF0F0F0)

	If $y1 < $maxY And $y1 > 0 Then
		$y1 = $y1 + $schrittweite
	Else
		If $y1 = 0 Then
			$y1 = $y1 + $schrittweite
		EndIf
	EndIf
	_GDIPlus_GraphicsDrawArc($hGraphic, $x1, $y1, 20, 20, 180, 360)
	_GDIPlus_GraphicsDrawArc($hGraphic, $zielx, $ziely, 20, 20, 180, 360, $hPen)
	kollision()
EndFunc   ;==>down





Func left()
	_GDIPlus_GraphicsClear($hGraphic, 0xFFF0F0F0)

	If $x1 < $maxX And $x1 > 0 Then

		$x1 = $x1 - $schrittweite
	Else
		If $x1 = $maxX Then
			$x1 = $x1 - $schrittweite
		EndIf
	EndIf

	_GDIPlus_GraphicsDrawArc($hGraphic, $x1, $y1, 20, 20, 180, 360)
	_GDIPlus_GraphicsDrawArc($hGraphic, $zielx, $ziely, 20, 20, 180, 360, $hPen)
	kollision()
EndFunc   ;==>left




Func right()
	_GDIPlus_GraphicsClear($hGraphic, 0xFFF0F0F0)

	If $x1 < $maxX And $x1 > 0 Then

		$x1 = $x1 + $schrittweite

	Else
		If $x1 = 0 Then
			$x1 = $x1 + $schrittweite
		EndIf
	EndIf

	_GDIPlus_GraphicsDrawArc($hGraphic, $x1, $y1, 20, 20, 180, 360); Tank malen
	_GDIPlus_GraphicsDrawArc($hGraphic, $zielx, $ziely, 20, 20, 180, 360, $hPen);Ziel malen
	kollision()
EndFunc   ;==>right




Func radar()
	$radarshots = $radarshots + 1
	Local $entfernung2
	$entfernung2 = 0
	$ping = 0
	SoundPlay("ping.mp3", 0)
	$linex = $x1
	$liney = $y1
	$linex2 = $x1

	If $kontakt = 0 Then
		$radarstrahl = $maxX
	EndIf

	While $linex2 < $radarstrahl + 100

		_GDIPlus_GraphicsDrawLine($hGraphic, $linex, $liney, $linex2, $liney)

		If $linex2 = $zielx Then

			If $liney < $ziely And $liney > $ziely - 3 Then
				SoundPlay("pong.wav", 0)
				$ping = 1
				$entfernung = $linex2 - $linex
				GUICtrlSetData($label1, "x: " & $x1 & " - y: " & $y1 & "### zielx: " & $zielx & " - ziely: " & $ziely & " - Ping Entfernung: " & $entfernung)
				SplashTextOn("Radar-Status", "Ping Entfernung: " & $entfernung, 200, 50, ($maxX + 200) / 2, -20 & @CRLF & "Status: Tracking")
				$kontakt = 1
				ExitLoop
			EndIf

			If $liney > $ziely And $liney < $ziely + 25 Then

				SoundPlay("pong.wav", 0)
				$ping = 1
				$entfernung = $linex2 - $linex
				GUICtrlSetData($label1, "x: " & $x1 & " - y: " & $y1 & "### zielx: " & $zielx & " - ziely: " & $ziely & " - Ping Entfernung: " & $entfernung)
				SplashTextOn("Radar-Status", "Ping Entfernung: " & $entfernung, 200, 50, ($maxX + 200) / 2, -20 & @CRLF & "Status: Tracking")
				$kontakt = 1
				ExitLoop

			EndIf

		EndIf

		$linex2 = $linex2 + 1

	WEnd

	Sleep(100)
	_GDIPlus_GraphicsClear($hGraphic, 0xFFF0F0F0)
	_GDIPlus_GraphicsDrawArc($hGraphic, $x1, $y1, 20, 20, 180, 360)

EndFunc   ;==>radar



Func search()

	Local $weitex, $weitey

	$weitex = $maxX / 10
	$weitey = $maxY / 10
	$schrittweite = 20

	While $x1 > 10
		left()
	WEnd

	While $y1 > 10
		up()
		Sleep(5)
	WEnd

	While 1

		While $x1 < $maxX
			right()
			kollision()
			Sleep(10)
		WEnd

		down()
		kollision()

		While $x1 > 10
			left()
			kollision()
			Sleep(10)
		WEnd

		down()
		kollision()
	WEnd

EndFunc   ;==>search



Func search2()
	missleladen()
	Local $enemypos, $isearch, $pingi
	$isearch = 0

	If $durchlaufsearch2 <> 0 Then
		missle()
	EndIf


	;###zurück nur Startposi
	While $x1 > 10
		left()
		Sleep(25)
	WEnd

	While $y1 > 10
		up()
		Sleep(25)
	WEnd


	;Gehe auf die gemessene Entfernung, da nur dort der andere Kreis sein kann
	If $oldx = 1 Then

		While $x1 < $oldxwert / 2
			right()
		WEnd

		radar2()

	EndIf


	If $treffer = 1 And $savedurchlauf <= 3 Then ;Catch taget if hit = true

		While $x1 < $savex

			right()

		WEnd

		While $x1 > $savex
			left()
		WEnd

		While $y1 < $savey
			down()
		WEnd

		While $y1 > $savey
			up()
		WEnd

	EndIf



	While 1
		;Schieße Suchradar
		radar()
		enemymove();Gegner move

		If $treffer = 1 Then
			catch()
		EndIf




		If $ping <> 0 Then ;Prüfe auf Radarecho - wenn Radarecho nicht null dann Aktion

			$ping = 0 ;setze Radarecho zurück
			missle()
			$radarstrahl = $x1 + $entfernung ; Grenze Radarstahl ein wenn einmal gefunden

			If $entfernung <= 100 Then ;Starte Rundumradar wenn Entfernung unter 100m
				search3()
			EndIf


			While 1
				$ping = 0

				right() ;Gehe Schritt nach Rechts
				kollision() ;Prüfe auf Kollision

				Sleep(50)
				radar() ;Schieße Radar

				If $ping = 1 Then
					If $entfernung > 1000 Then
						$schrittweite = 500
					EndIf
				EndIf

				enemymove()

				If $ping = 0 Then ;Wenn Radar nicht getroffen dann

					While $pingi < 8 ;Hüpfe 8 Schritte nach Oben
						$schrittweite = 10
						up()
						radar()

						If $ping <> 0 Then
							$schrittweite = 50
							ExitLoop
						EndIf

						Sleep(25)
						$pingi = $pingi + 1

					WEnd

					$pingi = 0
					If $ping = 0 Then
						ExitLoop ;Verlasse Schleife
					EndIf

				EndIf

				If $entfernung <= 800 Then

					SoundPlay("attack.wav")
					$schrittweite = 10
					$enemypos = $x1 + $entfernung

					While 1
						right()
						kollision()
						enemymove()
						Sleep(25)

						If $x1 >= $enemypos Then

							While 1

								up()
								search3()
								Sleep(50)

								$isearch = $isearch + 1
								If $isearch = 10 Then
									ExitLoop
								EndIf
							WEnd

							$isearch = 0

							While 1

								down()
								search3()

								$isearch = $isearch + 1
								Sleep(50)

								If $isearch = 20 Then
									ExitLoop
								EndIf

							WEnd


							$oldx = 1
							$oldxwert = $x1

							search2()
							missle()

						EndIf

					WEnd

				EndIf

			WEnd

		EndIf

		down()

		If $y1 = $maxY Then
			$durchlaufsearch2 = $durchlaufsearch2 + 1
			$oldx = 1
			$oldxwert = $x1
			search2()
			ExitLoop
		EndIf

	WEnd



EndFunc   ;==>search2




Func search3()


	radar2()

	If $ping2 <> 0 Then

		If $zielx > $x1 Then

			While $zielx > $x1
				Sleep(100)
				right()
			WEnd

		EndIf


		If $ziely > $y1 Then

			While $ziely > $y1
				Sleep(100)
				down()
			WEnd

		EndIf


		If $zielx < $x1 Then

			While $zielx < $x1
				Sleep(100)
				left()
			WEnd

		EndIf


		If $ziely < $y1 Then

			While $ziely < $y1
				Sleep(100)
				up()
			WEnd

		EndIf


	EndIf




EndFunc   ;==>search3






;~ Kollisionsabfrage
Func kollision()

	;Kollision für Tank1
;~ 	########################################################################
	If $x1 < $zielx And $x1 > $zielx - 20 And $y1 < $ziely And $y1 > $ziely - 20 Then
		SoundPlay("win.wav")
		MsgBox(0, "Ende1", "Radarshots: " & $radarshots)
		Exit

	EndIf

	If $x1 > $zielx And $x1 < $zielx + 25 And $y1 > $ziely And $y1 < $ziely + 25 Then
		SoundPlay("win.wav")
		MsgBox(0, "Ende2", "Radarshots: " & $radarshots)
		Exit

	EndIf
;~ 	############################################################################



EndFunc   ;==>kollision


Func misslekollision()

	If $treffer = 1 Then
		Return
	EndIf

	;Kollision für Missle und Ziel
;~ 	########################################################################
	If $misslex < $zielx And $misslex > $zielx - 25 And $missley < $ziely And $missley > $ziely - 25 Then
		MsgBox(0, "", "Treffer1")
		$savex = $misslex
		$savey = $missley
		$treffer = 1
		_GDIPlus_GraphicsClear($hGraphic, 0xFFF0F0F0)
	EndIf

	If $misslex > $zielx And $misslex < $zielx + 25 And $missley > $ziely And $missley < $ziely + 25 Then

		MsgBox(0, "", "Treffer2")
		$savex = $misslex
		$savey = $missley
		$treffer = 1
		_GDIPlus_GraphicsClear($hGraphic, 0xFFF0F0F0)
	EndIf
;~ 	########################################################################




EndFunc   ;==>misslekollision




Func enemymove()

	Local $zufall
	$zufall = Random(1, 10, 1)

	If $zufall < 5 Then
		If $ziely < $maxY Then
			$ziely = $ziely + 30
		EndIf
	EndIf

	If $zufall > 5 Then
		If $ziely > 10 Then
			$ziely = $ziely - 30
		EndIf
	EndIf

	Sleep(5)
	_GDIPlus_GraphicsDrawArc($hGraphic, $zielx, $ziely, 20, 20, 180, 360, $hPen)

EndFunc   ;==>enemymove



;~ Rundumradar
Func radar2()

	If GUICtrlRead($label2) <> "Fieldscan" Then
		GUICtrlSetData($label2, "Fieldscan")
	EndIf

	Local $aPoints[5][2]
	$aPoints[0][0] = 4

	$aPoints[1][0] = $x1 - 100 ;x
	$aPoints[1][1] = $y1 - 90 ;y

	$aPoints[2][0] = $x1 + 110 ;x
	$aPoints[2][1] = $y1 - 90 ;y

	$aPoints[3][0] = $x1 + 110 ;x
	$aPoints[3][1] = $y1 + 100 ;y

	$aPoints[4][0] = $x1 - 100 ;x
	$aPoints[4][1] = $y1 + 100 ;y


	_GDIPlus_GraphicsDrawPolygon($hGraphic, $aPoints)


	If $zielx > $aPoints[1][0] And $zielx < $aPoints[2][0] And $ziely > $aPoints[1][1] And $ziely < $aPoints[4][1] Then

		$ping2 = 1

	Else

		$ping2 = 0

	EndIf


EndFunc   ;==>radar2



Func missle()

	If $misslemovement = 300 Then
		$misslemovement = 0
	EndIf

	$misslex = $x1 + 10
	$missley = $y1 + 10

	_GDIPlus_GraphicsDrawArc($hGraphic, $misslex, $missley, 10, 10, 180, 360)


	;Ab hier Suchmodus für Missle
	While $misslex < $zielx
		rightmissle()
		targetescape()
		If $misslemovement >= 300 Then
			ExitLoop
		EndIf
		Sleep(10)
	WEnd

	While $misslex > $zielx
		leftmissle()
		targetescape()
		If $misslemovement >= 300 Then
			ExitLoop
		EndIf
		Sleep(10)
	WEnd

	While $missley < $ziely
		downmissle()
		targetescape()
		If $misslemovement >= 300 Then
			ExitLoop
		EndIf
		Sleep(10)
	WEnd

	While $missley > $ziely
		upmissle()
		targetescape()
		If $misslemovement >= 300 Then
			ExitLoop
		EndIf
		Sleep(10)
	WEnd


	$circle = 0
	If $misslemovement < 300 Then
		While 1
			$circle = $circle + 1

			If $circle = 25 Then
				Return
			EndIf

			While $misslex < $zielx
				rightmissle()
				targetescape()
				If $misslemovement >= 300 Then
					ExitLoop
				EndIf
				Sleep(10)
			WEnd

			While $misslex > $zielx
				leftmissle()
				targetescape()
				If $misslemovement >= 300 Then
					ExitLoop
				EndIf
				Sleep(10)
			WEnd

			While $missley < $ziely
				downmissle()
				targetescape()
				If $misslemovement >= 300 Then
					ExitLoop
				EndIf
				Sleep(10)
			WEnd

			While $missley > $ziely
				upmissle()
				targetescape()
				If $misslemovement >= 300 Then
					ExitLoop
				EndIf
				Sleep(10)
			WEnd

		WEnd

	Else

		_GDIPlus_GraphicsClear($hGraphic, 0xFFF0F0F0)
		_GDIPlus_GraphicsDrawArc($hGraphic, $x1, $y1, 20, 20, 180, 360)
		Return

	EndIf

	_GDIPlus_GraphicsClear($hGraphic, 0xFFF0F0F0)
	_GDIPlus_GraphicsDrawArc($hGraphic, $x1, $y1, 20, 20, 180, 360)

	If $treffer = 1 Then
		catch()
	EndIf

EndFunc   ;==>missle


Func targetescape()

	If $treffer = 1 Then
		Return
	EndIf

	Local $aPointsmissle[5][2]
	$aPointsmissle[0][0] = 4

	$aPointsmissle[1][0] = $zielx - 100 ;x
	$aPointsmissle[1][1] = $ziely - 90 ;y

	$aPointsmissle[2][0] = $zielx + 110 ;x
	$aPointsmissle[2][1] = $ziely - 90 ;y

	$aPointsmissle[3][0] = $zielx + 110 ;x
	$aPointsmissle[3][1] = $ziely + 100 ;y

	$aPointsmissle[4][0] = $zielx - 100 ;x
	$aPointsmissle[4][1] = $ziely + 100 ;y



	_GDIPlus_GraphicsDrawPolygon($hGraphic, $aPointsmissle)

	;Wenn Missle im Sensorbereich dann Flucht
	If $misslex > $aPointsmissle[1][0] And $misslex < $aPointsmissle[2][0] And $missley > $aPointsmissle[1][1] And $missley < $aPointsmissle[4][1] Then

		;Wenn Missle links vom Ziel dann Flucht
		If $misslex < $zielx And ($zielx - $misslex) <= 100 Then

			;Prüfe auf Feldbegrenzung
			If $zielx < $maxX - 20 Then
				$zielx = $zielx + 10
			Else;Dann Flucht hoch oder links nach Prüfung
				If $ziely < $maxY - 20 Then
					$ziely = $ziely + 10
				Else
					$zielx = $zielx - 100
				EndIf
			EndIf

		EndIf

		;Ist Missle rechts vom Ziel, dann Flucht
		If $misslex > $zielx And ($zielx - $misslex) <= 100 Then

			;Prüfe auf Feldbegrenzung
			If $zielx > 10 Then
				$zielx = $zielx - 10
			Else
				If $ziely <= 0 Then
					$ziely = $ziely + 10
				Else
					$zielx = $zielx + 100
				EndIf
			EndIf

		EndIf

	EndIf

	_GDIPlus_GraphicsDrawArc($hGraphic, $zielx, $ziely, 20, 20, 180, 360, $hPen)

EndFunc   ;==>targetescape



;~ MISSLEMOVEMENT
;~ ##################################################
Func upmissle()
	_GDIPlus_GraphicsClear($hGraphic, 0xFFF0F0F0)
	If $missley < $maxY And $missley > 0 Then
		$missley = $missley - $schrittweitemissle
	Else
		If $missley = $maxY Then
			$missley = $missley - $schrittweitemissle
		EndIf
	EndIf
	_GDIPlus_GraphicsDrawArc($hGraphic, $misslex, $missley, 10, 10, 180, 360)
	_GDIPlus_GraphicsDrawArc($hGraphic, $x1, $y1, 20, 20, 180, 360)
	_GDIPlus_GraphicsDrawArc($hGraphic, $zielx, $ziely, 20, 20, 180, 360, $hPen)
	$misslemovement = $misslemovement + 1
	misslekollision()
EndFunc   ;==>upmissle



Func downmissle()
	_GDIPlus_GraphicsClear($hGraphic, 0xFFF0F0F0)
	If $missley < $maxY And $missley > 0 Then
		$missley = $missley + $schrittweitemissle
	Else
		If $missley = 0 Then
			$missley = $missley + $schrittweitemissle
		EndIf
	EndIf
	_GDIPlus_GraphicsDrawArc($hGraphic, $misslex, $missley, 10, 10, 180, 360)
	_GDIPlus_GraphicsDrawArc($hGraphic, $x1, $y1, 20, 20, 180, 360)
	_GDIPlus_GraphicsDrawArc($hGraphic, $zielx, $ziely, 20, 20, 180, 360, $hPen)
	$misslemovement = $misslemovement + 1
	misslekollision()
EndFunc   ;==>downmissle



Func leftmissle()
	_GDIPlus_GraphicsClear($hGraphic, 0xFFF0F0F0)
	If $misslex < $maxX And $misslex > 0 Then

		$misslex = $misslex - $schrittweitemissle
	Else
		If $misslex = $maxX Then
			$misslex = $misslex - $schrittweitemissle
		EndIf
	EndIf
	_GDIPlus_GraphicsDrawArc($hGraphic, $misslex, $missley, 10, 10, 180, 360)
	_GDIPlus_GraphicsDrawArc($hGraphic, $x1, $y1, 20, 20, 180, 360)
	_GDIPlus_GraphicsDrawArc($hGraphic, $zielx, $ziely, 20, 20, 180, 360, $hPen)
	$misslemovement = $misslemovement + 1
	misslekollision()
EndFunc   ;==>leftmissle



Func rightmissle()
	_GDIPlus_GraphicsClear($hGraphic, 0xFFF0F0F0)
	If $misslex < $maxX And $misslex > 0 Then

		$misslex = $misslex + $schrittweitemissle

	Else
		If $misslex = 0 Then
			$misslex = $misslex + $schrittweitemissle
		EndIf
	EndIf
	_GDIPlus_GraphicsDrawArc($hGraphic, $misslex, $missley, 10, 10, 180, 360);missle malen
	_GDIPlus_GraphicsDrawArc($hGraphic, $x1, $y1, 20, 20, 180, 360); Tank malen
	_GDIPlus_GraphicsDrawArc($hGraphic, $zielx, $ziely, 20, 20, 180, 360, $hPen);Ziel malen
	$misslemovement = $misslemovement + 1
	misslekollision()
EndFunc   ;==>rightmissle
;~ ##################################################


Func missleladen()

	$misslemovement = 500
	$misslemovement = 0

EndFunc   ;==>missleladen


Func catch()

	If $treffer = 1 And $savedurchlauf <= 3 Then

		While $x1 < $savex

			right()

		WEnd

		While $x1 > $savex
			left()
		WEnd

		While $y1 < $savey
			down()
		WEnd

		While $y1 > $savey
			up()
		WEnd

	EndIf


EndFunc   ;==>catch


Func ende()
	Exit
EndFunc   ;==>ende



