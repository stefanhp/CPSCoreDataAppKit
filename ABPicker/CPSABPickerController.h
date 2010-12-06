//
//  CPSABPickerController.h
//  CPSCoreDataAppKit
//
//  Created by Stefan Hochuli Paychère on 28.10.09.
//  Copyright 2009 Pistache Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AddressBook/ABPeoplePickerView.h>


@interface CPSABPickerController : NSObject {
	IBOutlet NSWindow *pickerWindow;
	IBOutlet ABPeoplePickerView	*pickerView;
	IBOutlet NSButton *addButton;
	IBOutlet NSButton *detailsButton;
	IBOutlet NSButton *editButton;
	
	NSWindow *parentWindow;
	id selectedPersonDelegate;
	
	IBOutlet BOOL selectEnabled;
	BOOL selectPerson; // if false = select group
	
	BOOL firstLoad;
	
@private
	// Selected values
	NSString *theUID;
	NSString *displayName;
}
@property (readonly) BOOL selectEnabled;
@property BOOL selectPerson;
@property BOOL selectGroup;
- (IBAction)addInAddressBook:(id)sender;
- (IBAction)detailsInAddressBook:(id)sender;
- (IBAction)editInAddressBook:(id)sender;
- (IBAction)personSelected:(id)sender;
- (IBAction)cancelSelected:(id)sender;
- (IBAction)doubleClickPerformed:(id)sender;
@end

@interface CPSABPickerController ()
- (void)showPickerSheetForBool:(BOOL)isPerson;
@end 

@interface CPSABPickerController (CPSABPickerDelegate)
- (void)setParentWindow:(NSWindow*)aWindow;
- (void)showPickerSheetForPerson;
- (void)showPickerSheetForGroup;
- (void)setSelectedDelegate:(id)delegate;
@end

@protocol CPSABPersonSelected
- (BOOL)didSelectABPerson:(NSString*)selectedUID withName:(NSString*)displayName;
- (BOOL)didSelectABGroup:(NSString*)selectedUID withName:(NSString*)displayName;
- (void)didCompleteABPersonSheet:(NSString*)selectedUID withName:(NSString*)displayName;
- (void)didCompleteABGroupSheet:(NSString*)selectedUID withName:(NSString*)displayName;
- (void)didCancelABSheet;
@end
