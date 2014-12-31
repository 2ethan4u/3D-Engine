CONST w = 1280 'start init
halfw = w / 2
CONST h = 720
halfh = h / 2
CONST tH = 63
CONST tW = 63
a$ = "map.pol"
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
DIM texture(0 TO tH, 0 TO tW) AS LONG
tex& = _LOADIMAGE("image.bmp")
_SOURCE tex&
FOR x = 0 TO tH: FOR y = 0 TO tW
    texture(x, y) = POINT(x, y)
    PSET (x, y), texture(x, y)
NEXT y, x
SLEEP
_SOURCE 0
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
    FOR stripeY = 0 TO tH
      scaler1# = (lineBottom1 - lineTop1) / (tH + 1)
      scaler2# = (lineBottom2 - lineTop2) / (tH + 1)
      tex1T = lineTop1 + scaler1# * stripeY
      tex2T = lineTop2 + scaler2# * stripeY
      tex1B = lineTop1 + scaler1# * (stripeY + 1)
      tex2B = lineTop2 + scaler2# * (stripeY + 1)

      LINE (x1, tex1T)-(x2, tex2T), texture(i, stripeY)
      LINE (x1, tex1B)-(x2, tex2B), texture(i, stripeY)
      LINE (x1, tex1T)-(x1, tex1B), texture(i, stripeY)
      LINE (x2, tex2T)-(x2, tex2B), texture(i, stripeY)

    NEXT

    skippoly: 'for future stuff
  NEXT
  _DISPLAY
  _PRINTMODE _KEEPBACKGROUND
  time = 1 / (TIMER(.001) - bt#)
  _TITLE STR$(time)
LOOP

