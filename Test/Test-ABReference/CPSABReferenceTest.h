//
//  CPSABReferenceTest.h
//  CPSCoreDataAppKit
//
//  Created by Stefan Hochuli Paychère on 26.10.09.
//  Copyright 2009 Pistache Software. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@interface CPSABReferenceTest : SenTestCase {
	NSManagedObjectModel *managedObjectModel;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectContext *managedObjectContext;
	NSString *testStorePath;
}

@end
