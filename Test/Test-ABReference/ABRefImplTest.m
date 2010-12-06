// 
//  TestABRefImpl.m
//  CPSCoreDataAppKit
//
//  Created by Stefan Hochuli Paychère on 26.10.09.
//  Copyright 2009 Pistache Software. All rights reserved.
//

#import "ABRefImplTest.h"


@implementation ABRefImplTest 

@dynamic testAttribute;

- (void)setSortOrder:(CPSABRefNameOrder)anOrder{
	order = anOrder;
}

- (CPSABRefNameOrder) sortOrder{
	return order;
}

@end
