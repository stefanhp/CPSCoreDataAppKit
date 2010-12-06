//
//  CPSABReferenceTest.m
//  CPSCoreDataAppKit
//
//  Created by Stefan Hochuli Paychère on 26.10.09.
//  Copyright 2009 Pistache Software. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "CPSABReferenceTest.h"
#import "ABRefImplTest.h"
#import "CPSABReference.h"

@implementation CPSABReferenceTest
- (void)setUp{
	// Path
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportFolder = [NSTemporaryDirectory() stringByAppendingPathComponent:@"TestCPSABReference"];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
	
	// Managed Object Model
	NSString* urlPath = [[NSBundle bundleForClass:[CPSABReferenceTest class]] pathForResource:@"TestCPSABRefModel" ofType:@"mom"];
	NSLog(@"Path: %@", urlPath);
	NSURL *url = [NSURL fileURLWithPath:urlPath];
	managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
	
	// Store coordinator
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
	testStorePath = [applicationSupportFolder stringByAppendingPathComponent: @"TestCPSABRefModel.sqlite"];
    url = [NSURL fileURLWithPath:testStorePath];
	NSError *error;
	NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }
	
	// context
	managedObjectContext = [[NSManagedObjectContext alloc] init];
	[managedObjectContext setPersistentStoreCoordinator: persistentStoreCoordinator];
	
	// Verify Setup
	STAssertNotNil(testStorePath, @"Store coordinator path cannot be nil");
	STAssertNotNil(persistentStoreCoordinator, @"persistentStoreCoordinator cannot be nil");
	STAssertNotNil(managedObjectContext, @"managedObjectContext cannot be nil");
	STAssertNotNil(managedObjectModel, @"managedObjectModel cannot be nil");
	
	STAssertTrue([[managedObjectModel entities]count] > 0, @"There should be at least one object in the model");
}

- (void)tearDown{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(testStorePath != nil && [fileManager fileExistsAtPath:testStorePath]){
		[fileManager removeItemAtPath:testStorePath error:nil];
	}
	[fileManager removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"TestCPSABReference"] error:nil];
}

- (void)testCPSABReferenceObject{
	// Create new John Doe entry
	ABAddressBook* abook = [ABAddressBook sharedAddressBook];
	ABPerson* aPerson = [[ABPerson alloc]initWithAddressBook:abook];
	[aPerson setValue:@"John" forProperty:kABFirstNameProperty];
	[aPerson setValue:@"Doe" forProperty:kABLastNameProperty];
	STAssertTrue([abook addRecord:aPerson], @"Could not add entry to address book");
	STAssertTrue([abook save], @"Could not save address book");
	STAssertNotNil([aPerson uniqueId], @"Must have a valid UID");

	// Create new ABRef entry
	ABRefImplTest* mo = [NSEntityDescription insertNewObjectForEntityForName:@"ABRefImplTest" inManagedObjectContext:managedObjectContext];
	STAssertNotNil(mo, @"Created object should not be nil");
	
	// Assign John Doe
	[mo setContactUID:[aPerson	uniqueId]];
	STAssertNotNil([mo contactUID], @"Entry should now have a unique ID");
	//STAssertNotNil([mo abEntry], @"Should find John Doe in AddressBook (1)");
	STAssertNotNil([CPSABManagedObject abEntryFor:mo], @"Should find John Doe in AddressBook");
	STAssertTrue([[[CPSABManagedObject abEntryFor:mo] uniqueId] isEqualToString:[aPerson uniqueId]], @"Not the same entry");
	[mo setSortOrder:CPSABRefOrderFirstLast];
	STAssertTrue([[mo displayName] isEqualToString:@"John Doe"], @"Assignement failed (%@)", [mo displayName]);

	// Read-only values
	STAssertTrue([[mo firstName] isEqualToString:@"John"], @"Wrong first name (%@)", [mo firstName]);
	STAssertTrue([[mo lastName] isEqualToString:@"Doe"], @"Wrong last name (%@)", [mo lastName]);
	
	// *** Set & test all value 
	// Primary label
	[mo setPrimaryLabel:kABAIMHomeLabel];
	STAssertTrue([[mo primaryLabel] isEqualToString:kABAIMHomeLabel], @"Wrong primary label (%@)", [mo primaryLabel]);
	
	// Secondary label
	[mo setSecondaryLabel:kABAIMWorkLabel];
	STAssertTrue([[mo secondaryLabel] isEqualToString:kABAIMWorkLabel], @"Wrong secondary label (%@)", [mo secondaryLabel]);
	
	// birthdate
	NSDate* theDate =[NSDate dateWithString:@"2001-03-24 12:00:00 +0100"]; // Beware: AB ignores time and default it to 12:00:00 +0100
	[mo setBirthdate:theDate];
	STAssertTrue([[mo birthdate] isEqualToDate:theDate], @"Wrong birth date (%@)", [mo birthdate]);
	
	// mobile phone
	NSString* theValue = @"mobile phone";
	[mo setMobilePhone:theValue];
	STAssertTrue([[mo mobilePhone] isEqualToString:theValue], @"Wrong mobile phone (%@)", [mo mobilePhone]);
	
	// primary address
	theValue = @"primary address";
	[mo setPrimaryAddress:theValue];
	STAssertTrue([[mo primaryAddress] isEqualToString:theValue], @"Wrong primary address (%@)", [mo primaryAddress]);
	
	// primary zip
	theValue = @"primary zip";
	[mo setPrimaryZip:theValue];
	STAssertTrue([[mo primaryZip] isEqualToString:theValue], @"Wrong primary zip (%@)", [mo primaryZip]);

	// primary city
	theValue = @"primary city";
	[mo setPrimaryCity:theValue];
	STAssertTrue([[mo primaryCity] isEqualToString:theValue], @"Wrong primary city (%@)", [mo primaryCity]);
	
	// primary phone
	theValue = @"primary phone";
	[mo setPrimaryPhone:theValue];
	STAssertTrue([[mo primaryPhone] isEqualToString:theValue], @"Wrong primary phone (%@)", [mo primaryPhone]);
	
	// primary fax
	theValue = @"primary fax";
	[mo setPrimaryFax:theValue];
	STAssertTrue([[mo primaryFax] isEqualToString:theValue], @"Wrong primary fax (%@)", [mo primaryFax]);
	
	// primary email
	theValue = @"primary email";
	[mo setPrimaryEmail:theValue];
	STAssertTrue([[mo primaryEmail] isEqualToString:theValue], @"Wrong primary email (%@)", [mo primaryEmail]);
	
	// secondary address
	theValue = @"secondary address";
	[mo setSecondaryAddress:theValue];
	STAssertTrue([[mo secondaryAddress] isEqualToString:theValue], @"Wrong secondary address (%@)", [mo secondaryAddress]);
	
	// secondary zip
	theValue = @"secondary zip";
	[mo setSecondaryZip:theValue];
	STAssertTrue([[mo secondaryZip] isEqualToString:theValue], @"Wrong secondary zip (%@)", [mo secondaryZip]);
	
	// secondary city
	theValue = @"secondary city";
	[mo setSecondaryCity:theValue];
	STAssertTrue([[mo secondaryCity] isEqualToString:theValue], @"Wrong secondary city (%@)", [mo secondaryCity]);
	
	// secondary phone
	theValue = @"secondary phone";
	[mo setSecondaryPhone:theValue];
	STAssertTrue([[mo secondaryPhone] isEqualToString:theValue], @"Wrong secondary phone (%@)", [mo secondaryPhone]);
	
	// secondary fax
	theValue = @"secondary fax";
	[mo setSecondaryFax:theValue];
	STAssertTrue([[mo secondaryFax] isEqualToString:theValue], @"Wrong secondary fax (%@)", [mo secondaryFax]);

	// secondary email
	theValue = @"secondary email";
	[mo setSecondaryEmail:theValue];
	STAssertTrue([[mo secondaryEmail] isEqualToString:theValue], @"Wrong secondary email (%@)", [mo secondaryEmail]);
	
	// *** end
	
	
	// Delete John Doe entry
	STAssertTrue([abook removeRecord:aPerson], @"Failed to remove John Doe record from AddressBook");
	[abook save];
}
@end
