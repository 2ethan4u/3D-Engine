3D-Engine
=========

A basic polygonal 3D engine

**Format**

Header: 'TL;DR'

(loop per poly)
```
X1,  Z1

X2,  Z2

TOP, BOTTOM (0 to 1)

TEXTURE
```
(end of loop)

All entries must be seperated by a comma **or** new line.

**Example**: 

```
-1,1,1,1,1,0,0
```

makes a poly from (-1,1) to (1,1) from height 0 to 1 with texture 0 (which would cover the screen).

Note: Don't yet try to make walls above y=1 or below y=0. I'm still ironing out the bugs there.
