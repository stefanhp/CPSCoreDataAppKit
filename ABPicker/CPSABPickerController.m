//
//  CPSABPickerController.m
//  CPSCoreDataAppKit
//
//  Created by Stefan Hochuli Paychère on 28.10.09.
//  Copyright 2009 Pistache Software. All rights reserved.
//

#import "CPSABPickerController.h"
#import <AddressBook/ABRecord.h>
#import <AddressBook/ABPerson.h>
#import <AddressBook/ABGroup.h>
#import <AddressBook/ABGlobals.h>


@implementation CPSABPickerController
@dynamic selectEnabled;
- (BOOL)selectEnabled{
	return YES;
	/*
	 if(selectedPersonDelegate != nil){
	 NSArray *selected = [pickerView selectedRecords];
	 if([selected count] == 1){
	 ABRecord *record = [selected objectAtIndex:0];
	 if([record isKindOfClass:[ABPerson class]] && [self selectPerson]){
	 return YES;
	 }
	 if([record isKindOfClass:[ABGroup class]] && [self selectGroup]){
	 return YES;
	 }
	 }
	 }	
	 return NO;
	 */
}

@synthesize selectPerson;
@dynamic selectGroup;
- (BOOL)selectGroup{
	return (![self selectPerson]);
}

- (void)setSelectGroup:(BOOL)aValue{
	[self setSelectPerson: (!aValue)];
}


- (void)awakeFromNib{
	firstLoad = YES;
}

- (IBAction)addInAddressBook:(id)sender{
	[pickerView selectInAddressBook:sender];	
}

- (IBAction)detailsInAddressBook:(id)sender{
	[pickerView selectInAddressBook:sender];
}

- (IBAction)editInAddressBook:(id)sender{
	
}

- (IBAction)personSelected:(id)sender{
	BOOL pickOk = NO;
	if(selectedPersonDelegate != nil){
		NSArray *selected;
		if([self selectPerson]){ // Person selection
			selected = [pickerView selectedRecords];
			if([selected count] == 1){
				ABRecord *record = [selected objectAtIndex:0];
				
				if([record isKindOfClass:[ABGroup class]]){
					// we want a Person and got a Group: exit
					return;
				}
				theUID = [record uniqueId];
				displayName = [record valueForProperty:kABFirstNameProperty];
				displayName = [displayName stringByAppendingString:@" "];
				displayName = [displayName stringByAppendingString:[record valueForProperty:kABLastNameProperty]];
				pickOk = [selectedPersonDelegate didSelectABPerson:theUID withName:displayName];
				
			}
		} else { // Group selection 
			selected = [pickerView selectedGroups];
			if([selected count] == 1){
				ABRecord *record = [selected objectAtIndex:0];
				
				if([record isKindOfClass:[ABPerson class]]){
					// We want a Group and got a Person: exit
					return;
				}
				theUID = [record uniqueId];
				displayName = [record valueForProperty:kABGroupNameProperty];
				pickOk = [selectedPersonDelegate didSelectABGroup:theUID withName:displayName];
			}
		}
	}
	if(pickOk){
		[NSApp endSheet:pickerWindow];
	}
}

- (IBAction)cancelSelected:(id)sender{
	[NSApp endSheet:pickerWindow];
	if(selectedPersonDelegate != nil){
		[selectedPersonDelegate didCancelABSheet];
	}
}

- (IBAction)doubleClickPerformed:(id)sender{
	[self personSelected:sender];
}

- (void)didEndABPickerSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
	if(selectedPersonDelegate != nil && theUID != nil){
		if([self selectPerson]){
			[selectedPersonDelegate didCompleteABPersonSheet:theUID withName:displayName];
		} else {
			[selectedPersonDelegate didCompleteABGroupSheet:theUID withName:displayName];
		}
	}
	// clean up
	theUID = nil;
	displayName = nil;
}

- (void)showPickerSheetForBool:(BOOL)isPerson{
	[self setSelectPerson:isPerson];
	if(pickerView != nil){
		[pickerView setAllowsGroupSelection:!(isPerson)];
		[pickerView setAllowsMultipleSelection:NO];
		
		//double click
		[pickerView setTarget:self];
		[pickerView setNameDoubleAction:@selector(doubleClickPerformed)];
		[pickerView setGroupDoubleAction:@selector(doubleClickPerformed)];
		
		// Selection
		[pickerView deselectAll:self];
	}
	if(parentWindow != nil && pickerWindow != nil){
		// Fix bug with first display of sheet after loading from NIB (sheet not in window).
		if(firstLoad){
			[pickerWindow orderOut:self];
			firstLoad = NO;
		}
		[NSApp beginSheet:pickerWindow 
		   modalForWindow:parentWindow 
			modalDelegate:self 
		   didEndSelector: @selector(didEndABPickerSheet:returnCode:contextInfo:)
			  contextInfo:nil];
	}
}
@end

@implementation CPSABPickerController (CPSABPickerDelegate)
- (void)setParentWindow:(NSWindow*)aWindow{
	parentWindow = aWindow;
}

- (void)showPickerSheetForPerson{
	[self showPickerSheetForBool:YES];
}

- (void)showPickerSheetForGroup{
	[self showPickerSheetForBool:NO];
}

- (void)setSelectedDelegate:(id)delegate{
	if([delegate conformsToProtocol:@protocol(CPSABPersonSelected)]){
		selectedPersonDelegate = delegate;
	}
}
@end