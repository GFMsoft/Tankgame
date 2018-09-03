# Tankgame
Ein kleines Spiel - Erstellt mit Autoit
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
