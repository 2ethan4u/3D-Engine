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
DIM poly(1023, 6) AS DOUBLE
DIM polyR(1023, 6) AS DOUBLE
DIM pi AS DOUBLE
pi = 4 * ATN(1#)
x = 0
DO WHILE NOT EOF(1) OR x = 1024
  FOR i = 0 TO 6
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
NEXT y, x
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
    polyR(i, 4) = poly(i, 4)
    polyR(i, 5) = poly(i, 5)
    polyR(i, 6) = poly(i, 6)
  NEXT
  bt# = TIMER(.001)
  LINE (0, 0)-(w, h), _RGB(0, 0, 0), BF
  FOR i = 0 TO polygonCount
    z1 = polyR(i, 1)
    z2 = polyR(i, 3)
    IF z1 - player.z < 0.1 OR z2 - player.z < 0.1 THEN GOTO skippoly
    x1 = halfw * (polyR(i, 0) - player.x) / (z1 - player.z) + halfw
    x2 = halfw * (polyR(i, 2) - player.x) / (z2 - player.z) + halfw
    IF z1 > 0 THEN h1 = h / (z1 - player.z): ELSE h1 = h
    IF z2 > 0 THEN h2 = h / (z2 - player.z): ELSE h2 = h
    IF x1 < 0 AND x2 < 0 THEN GOTO skippoly
    IF x1 > w AND x2 > w THEN GOTO skippoly
    lineTop1 = halfh - h1 * (0.5 - (1 - polyR(i, 4)))
    lineTop2 = halfh - h2 * (0.5 - (1 - polyR(i, 4)))
    lineBottom1 = halfh + h1 * (0.5 - polyR(i, 5))
    lineBottom2 = halfh + h2 * (0.5 - polyR(i, 5))
    FOR stripeY = 0 TO tH
      scaler1# = (lineBottom1 - lineTop1) / (tH + 1)
      scaler2# = (lineBottom2 - lineTop2) / (tH + 1)
      tex1T = lineTop1 + scaler1# * stripeY
      tex2T = lineTop2 + scaler2# * stripeY
      tex1B = lineTop1 + scaler1# * (stripeY + 1)
      tex2B = lineTop2 + scaler2# * (stripeY + 1)

      lastL = 928
      FOR l = 0 TO 1 STEP 0.1
        L1 = tex1T * l + tex1B * (1 - l)
        L2 = tex2T * l + tex2B * (1 - l)
        IF lastL <> L1 THEN LINE (x1, L1)-(x2, L2), texture(polyR(i, 6), stripeY)
        lastL = L1
      NEXT
    NEXT

    skippoly: 'for future stuff
  NEXT
  _DISPLAY
  _PRINTMODE _KEEPBACKGROUND
  time = (TIMER(.001) - bt#)
  _TITLE STR$(1 / time)
  player.z = player.z + time / 10
  player.x = SIN(TIMER(.001)) / 2
LOOP

