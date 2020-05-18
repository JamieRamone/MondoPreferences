/***********************************************************************************************************************************
 *
 *	Fonts.h
 *
 * This file is an part of Mondo Preferences.
 *
 *	Copyright (C) 2020 Mondo Megagames.
 * 	Author: Jamie Ramone <sancombru@gmail.com>
 *	Date: 18-5-20
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>
 *
 **********************************************************************************************************************************/
#ifndef _FONTS_H_
#define _FONTS_H_

#import <Foundation/Foundation.h>

#import "PreferencePaneController.h"
#import "MenuView.h"
#import "TitleBarView.h"

@interface FontsPaneController : PreferencePaneController {
/*
 * Place all the ivars here that match the ones you defined in the NIB, as well as any auxiliary ones, except for pane which is
 * provided by the superclass.
 */
	NSTextField	* selectedFontNameField;
	NSScrollView	* fixedPitchFontView,
			* otherFontsView;
	MenuView	* menuView;
	TitleBarView	* titleBarView;

}
/*
 * Place your own custom methods here. This includes the NIB-related action methods.
 */
@end

#endif /* _FONTS_H_ */
