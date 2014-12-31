CONST w = 1280 'start init
halfw = w / 2
CONST h = 720
halfh = h / 2
a$ = "map.pol"
theme& = _SNDOPEN("theme.mp3")
CLS
IF NOT _FILEEXISTS(a$) THEN
  COLOR 12
  PRINT "That isn't a file!"
  COLOR 7
  PRINT "Go away."
END IF
OPEN a$ FOR INPUT AS 1
LINE INPUT #1, check$
COLOR 2
IF NOT check$ = "TL;DR" THEN PRINT "INVALID FILE, MUTHERFUDGER": SYSTEM ' verify with magic TL;DR
DIM poly(1023, 3) AS DOUBLE
DIM polyR(1023, 3) AS DOUBLE
DIM pi AS DOUBLE
pi = 4 * ATN(1#)
x = 0
DO WHILE NOT EOF(1) OR x = 1024
  FOR i = 0 TO 3
    INPUT #1, da#
    poly(x, i) = da#
  NEXT
  x = x + 1
LOOP
CLOSE
polygonCount = x - 1
IF x = 1024 THEN: COLOR 12, 4: PRINT "Scene truncated!": SLEEP
TYPE Entity
  x AS DOUBLE
  y AS DOUBLE
  z AS DOUBLE
  currentHealth AS INTEGER
  maxHealth AS INTEGER
END TYPE

DIM player AS Entity
player.x = 0
player.y = 0
player.z = 0
SCREEN _NEWIMAGE(w, h, 32)
OPEN "image.hfi" FOR INPUT AS 2
INPUT #2, tW
INPUT #2, tH
DIM texture(tH, tW, 2) AS DOUBLE
FOR x = 0 TO tW
  FOR y = 0 TO tH
    FOR e = 0 TO 2
      INPUT #2, a#
      texture(x, y, e) = a#
NEXT e, y, x
DIM aperture AS DOUBLE
aperture = 255
_SOURCE 0
'end of init, start render
r = 0
DO
  FOR i = 0 TO polygonCount
    polyR(i, 0) = poly(i, 0) '* COS(r) - poly(i, 1) * SIN(r)
    polyR(i, 1) = poly(i, 1) '* SIN(r) + poly(i, 0) * COS(r)
    polyR(i, 2) = poly(i, 2) '* COS(r) - poly(i, 3) * SIN(r)
    polyR(i, 3) = poly(i, 3) '* SIN(r) + poly(i, 2) * COS(r)
  NEXT
  bt# = TIMER(.001)
  LINE (0, 0)-(w, h), _RGB(0, 0, 0), BF
  FOR i = 0 TO polygonCount
    z1 = polyR(i, 1)
    z2 = polyR(i, 3)
    IF z1 - player.z < 0.1 OR z2 - player.z < 0.1 THEN GOTO skippoly
    x1 = halfw * polyR(i, 0) / (z1 - player.z) + halfw
    x2 = halfw * polyR(i, 2) / (z2 - player.z) + halfw
    IF z1 > 0 THEN h1 = h / (z1 - player.z): ELSE h1 = h
    IF z2 > 0 THEN h2 = h / (z2 - player.z): ELSE h2 = h
    lineTop1 = halfh - h1 / 2
    lineTop2 = halfh - h2 / 2
    lineBottom1 = halfh + h1 / 2
    lineBottom2 = halfh + h2 / 2

    FOR x = x1 TO x2
      dec# = 1 - ABS(x - x1) / ABS(x2 - x1)
      lineTop = (lineTop1 * dec#) + (lineTop2 * (1 - dec#))
      lineBottom = (lineBottom1 * dec#) + (lineBottom2 * (1 - dec#))
      myZ = (z1 * dec#) + (z2 * (1 - dec#))
      myX = (poly(i, 0) * dec#) + (poly(i, 2) * (1 - dec#))
      texelX% = ((myZ + myX) * (tW + 1)) MOD (tW + 1)
      scaler# = (lineBottom - lineTop) / (tH + 1)
      FOR pixel% = 0 TO tH
        top = lineTop + scaler# * pixel%
        bottom = lineTop + scaler# * (pixel% + 1)
        IF x < 0 OR x > w - 1 THEN GOTO nope
        IF top < 0 THEN top = 0
        IF bottom > h - 1 THEN bottom = h - 1
        LINE (x, top)-(x, bottom), _RGB(texture(texelX%, pixel%, 0) * aperture, texture(texelX%, pixel%, 1) * aperture, texture(texelX%, pixel%, 2) * aperture)
        nope:
      NEXT
    NEXT
    skippoly:
  NEXT
  _DISPLAY
  _PRINTMODE _KEEPBACKGROUND
  time = 1 / (TIMER(.001) - bt#)
  _TITLE STR$(time)
  IF LCASE$(INKEY$) = "w" THEN player.z = player.z + 0.05
  IF LCASE$(INKEY$) = "s" THEN player.z = player.z - 0.05
  player.z = player.z + 0.01
  r = r + 0.001
LOOP
