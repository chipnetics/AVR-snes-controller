# SNES controller implementation on the Neo Geo
## A lagless implementation of a SNES controller for use on the Neo Geo, using the ATTINY2313

This firmware source code (work) is released under MIT License.  Do not remove the license or remove the credit.

SNES controllers can be used as a substitute for the original Neo Geo controller. It maintains all the buttons, and probably anybody interested in a consolized Neo Geo is fanatical enough that they are almost certainly going to own a Super Nintendo, so they won’t have to shell out any more dollars.

The beautiful thing about this implementation is that it is LAGLESS. Even though the serial data from the SNES must be converted to parallel, an entire polling loop takes .098875mS, while a 60fps frame draw means a new frame every 16.67mS (so, ~168 polls per frame!).

## You can view the project writeup here https://chipnetics.com/projects/fw/snesparallel/

## Or additionally on hackaday https://hackaday.io/project/168676-snes-controller-implementation-on-the-neo-geo
