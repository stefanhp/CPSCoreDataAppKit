//
//  CalPickerController.m
//  CPSCoreDataAppKit
//
//  Created by Stefan Hochuli Paychère on 24.09.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import "CPSCalPickerController.h"
#import <CalendarStore/CalendarStore.h>


@implementation CPSCalPickerController
- (NSArray *)calendars {
	return [[CalCalendarStore defaultCalendarStore] calendars];
}

- (void)awakeFromNib{
	firstLoad = YES;
	// Set sort order
	if(calArrayCtrl != nil){
		[calArrayCtrl setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc]initWithKey:@"title"	ascending:YES]]];
	}
}

- (void)didEndCalPickerSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

- (IBAction)okSelected:(id)sender{
	if(selectedCalendarDelegate != nil){
		CalCalendar *cal = [[calArrayCtrl selectedObjects] objectAtIndex:0];
		if(cal != nil){
			[selectedCalendarDelegate didSelectCalendar:[cal uid] withName:[cal title]];
		}
	}	
	[NSApp endSheet:pickerWindow];
}

- (IBAction)cancelSelected:(id)sender{
	[NSApp endSheet:pickerWindow];
}

@end

@implementation CPSCalPickerController (CPSCalPickerDelegate)
- (void)setParentWindow:(NSWindow*)aWindow{
	parentWindow = aWindow;
}

- (void)showPickerSheet{
	if(parentWindow != nil && pickerWindow != nil){
		// Fix bug with first display of sheet after loading from NIB (sheet not in window).
		if(firstLoad){
			[pickerWindow orderOut:self];
			firstLoad = NO;
		}
		
		// Set current selection
		[calArrayCtrl setSelectedObjects:nil]; // defaults to none
		if(selectedCalendarDelegate != nil){
			NSString *uid = [selectedCalendarDelegate currentlySelectedCalendarUID];
			if(uid != nil){
				CalCalendar *cal = [[CalCalendarStore defaultCalendarStore] calendarWithUID:uid];
				if(cal != nil){
					[calArrayCtrl setSelectedObjects:[NSArray arrayWithObject:cal]];
				}
			}
		}
		
		[NSApp beginSheet:pickerWindow 
		   modalForWindow:parentWindow 
			modalDelegate:self 
		   didEndSelector: @selector(didEndCalPickerSheet:returnCode:contextInfo:)
			  contextInfo:nil];
	}
}

- (void)setSelectedCalendarDelegate:(id)delegate{
	if([delegate conformsToProtocol:@protocol(CPSCalendarSelected)]){
		selectedCalendarDelegate = delegate;
	}
}
@end
