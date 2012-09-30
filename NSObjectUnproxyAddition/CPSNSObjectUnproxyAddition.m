//
//  CPSNSObjectUnproxyAddition.m
//  CPSCoreDataAppKit
//
//  Created by Stefan Hochuli Paychère on 05.01.09.
//  Copyright 2009 Pistache Software. All rights reserved.
//

#import "CPSNSObjectUnproxyAddition.h"

//@class _NSControllerObjectProxy;

@implementation NSObject (ObjectUnproxyAddition)
- (id)unproxy{
    /*
	if([self isKindOfClass:[_NSControllerObjectProxy class]]){
		return [self valueForKey:@"unproxy"];
	} else {
		return self;
	}*/
    return self;
}
@end