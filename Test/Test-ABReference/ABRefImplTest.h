//
//  TestABRefImpl.h
//  CPSCoreDataAppKit
//
//  Created by Stefan Hochuli Paychère on 26.10.09.
//  Copyright 2009 Pistache Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CPSABReference.h"

@interface ABRefImplTest :  CPSABManagedObject <CPSABReferenceSorting>
{
	CPSABRefNameOrder order;
}
- (void)setSortOrder:(CPSABRefNameOrder)anOrder;
- (CPSABRefNameOrder) sortOrder;

@property (strong) NSString * testAttribute;

@end



