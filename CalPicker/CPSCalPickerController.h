//
//  CPSCalPickerController.h
//  CPSCoreDataAppKit
//
//  Created by Stefan Hochuli Paychère on 24.09.10.
//  Copyright 2010 Pistache Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CPSCalPickerController : NSObject {
	IBOutlet NSWindow *pickerWindow;
	IBOutlet NSArrayController *calArrayCtrl;
	
	NSWindow *parentWindow;
	id selectedCalendarDelegate;
	BOOL firstLoad;
}
@property(readonly) NSArray *calendars;
- (IBAction)okSelected:(id)sender;
- (IBAction)cancelSelected:(id)sender;
@end

@interface CPSCalPickerController (CPSCalPickerDelegate)
- (void)setParentWindow:(NSWindow*)aWindow;
- (void)showPickerSheet;
- (void)setSelectedCalendarDelegate:(id)delegate;
@end

@protocol CPSCalendarSelected
- (void)didSelectCalendar:(NSString*)selectedUID withName:(NSString*)displayName;
- (NSString*)currentlySelectedCalendarUID;
@end
