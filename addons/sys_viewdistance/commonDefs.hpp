#ifndef _COMMON_DEFS_HPP
#define _COMMON_DEFS_HPP

#define true 1
#define false 0

#define ReadAndWrite 0 //! any modifications enabled#define ReadAndCreate 1 //! only adding new class members is allowed#define ReadOnly 2 //! no modifications enabled#define ReadOnlyVerified 3 //! no modifications enabled, CRC test applied//--- New grid for new A3 displays
#define GUI_GRID_WAbs			((safezoneW / safezoneH) min 1.2)
#define GUI_GRID_HAbs			(GUI_GRID_WAbs / 1.2)
#define GUI_GRID_W			(GUI_GRID_WAbs / 40)
#define GUI_GRID_H			(GUI_GRID_HAbs / 25)
#define GUI_GRID_X			(safezoneX)
#define GUI_GRID_Y			(safezoneY + safezoneH - GUI_GRID_HAbs)

///////////////////////////////////////////////////////////////////////////
/// Text Sizes - A3
///////////////////////////////////////////////////////////////////////////
//MUF - text sizes are using new grid (40/25)
#define GUI_TEXT_SIZE_SMALL		(GUI_GRID_H * 0.8)
#define GUI_TEXT_SIZE_MEDIUM		(GUI_GRID_H * 1)
#define GUI_TEXT_SIZE_LARGE		(GUI_GRID_H * 1.2)
#define IGUI_TEXT_SIZE_MEDIUM		(GUI_GRID_H * 0.8)

///////////////////////////////////////////////////////////////////////////
/// Fonts - A3
///////////////////////////////////////////////////////////////////////////
#define GUI_FONT_NORMAL			PuristaMedium
#define GUI_FONT_BOLD			PuristaSemibold
#define GUI_FONT_MONO			EtelkaMonospaceProBold
#define GUI_FONT_SMALL			PuristaMedium
#define GUI_FONT_THIN			PuristaLight

#define FontMAIN 			PuristaMedium
#define FontDEBUG 			PuristaMedium

#define SizeXSmall ( 16 / 408 )
#define SizeSmall ( 16 / 408 )
#define SizeNormal ( 21 / 408 )
#define SizeMedium ( 29 / 408 )
#define SizeLarge ( 36 / 408 )

#define SizeTitle 0.08
#define SizeBookTitle 0.06
#define SizeBook 0.05
#define SizeHint 0.0468
#define SizeListBig  0.042
#define SizeList  0.0378

#define SizeMapMarker  32

#define Black 0, 0, 0
#define Green 0.0, 0.6, 0.0
#define Red 0.7, 0.1, 0.0
#define Yellow 0.8, 0.6, 0.0
#define White 0.8, 0.8, 0.8
#define ShineGreen 0.07, 0.7, 0.2
#define ShineRed 1, 0.2, 0.2
#define ShineYellow 1, 1, 0
#define ShineWhite 1, 1, 1
#define Blue 0.1, 0.1, 0.9

#define Gray1 0.00, 0.00, 0.00
#define Gray2 0.20, 0.20, 0.20
#define Gray3 0.50, 0.50, 0.50
#define Gray4 0.60, 0.60, 0.60
#define Gray5 0.80, 0.80, 0.80

#endif
