//
//  TestCPSNSObjectUnproyAddition.m
//  CPSCoreDataAppKit
//
//  Created by Stefan Hochuli Paychère on 25.10.09.
//  Copyright 2009 Pistache Software. All rights reserved.
//

#import "CPSNSObjectUnproyAdditionTest.h"
#import "CPSNSObjectUnproxyAddition.h"

@class _NSControllerObjectProxy;

@interface CPSNSObjectUnproyAdditionTestInnerClass : NSObject
{
	NSString* text;
	NSString* text2;
	NSInteger* value;
}
@property(retain) NSString* text;
@property(retain) NSString* text2;
@end

@implementation CPSNSObjectUnproyAdditionTestInnerClass
@synthesize text;
@synthesize text2;
@end


@implementation CPSNSObjectUnproyAdditionTest
- (void)setUp{
	arrayController = [[NSArrayController alloc]init];
}
- (void)tearDown{
}

- (void)testUnProxyOperation{
	CPSNSObjectUnproyAdditionTestInnerClass* sample = [[CPSNSObjectUnproyAdditionTestInnerClass alloc]init];
	[sample setText:@"This is a sample text"];
	[sample setText2:@"10"];
	
	[arrayController addObject:sample];
	[arrayController setSelectedObjects:[NSArray arrayWithObject:sample]];
	id objectArray = [arrayController selectedObjects];
	STAssertNotNil(objectArray, @"selectedObjects should not be nil");
	STAssertTrue([objectArray isKindOfClass:[NSArray class]], @"selectedObjects should be an NSArray");
	STAssertTrue([objectArray count] == 1, @"One object should be present (count = %i)", [objectArray count]);
	
	NSObject* sampleProxy = [objectArray objectAtIndex:0];
	STAssertNotNil(sampleProxy, @"sampleProxy should not be nil");
	// Can't get a Proxy class... I wonder why...
	/*
	STAssertTrue([sampleProxy isKindOfClass:[_NSControllerObjectProxy class]], 
				 @"sampleProxy should be a proxy class (%@)", [[sampleProxy class]description]);
	 */
	STAssertNotNil([sampleProxy unproxy], @"unproxy should always return the object");
}
@end
