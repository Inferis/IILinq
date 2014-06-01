//
//  IILinq.h
//
//  Created by Tom Adriaenssen on 21/05/14.
//  Copyright (c) 2014 Tom Adriaenssen. All rights reserved.
//

@import Foundation;

@class IILinq;

typedef IILinq*(^IILinq_Select)(id(^predicate)(id item));
typedef IILinq*(^IILinq_SelectMany)(NSArray*(^predicate)(id item));
typedef id(^IILinq_ToObject)();

@interface IILinq : NSObject <NSFastEnumeration>

@property (nonatomic, copy, readonly) IILinq_Select select;
@property (nonatomic, copy, readonly) IILinq_SelectMany selectMany;
@property (nonatomic, copy, readonly) NSArray* allObjects;
@property (nonatomic, copy, readonly) id singleObject;
@property (nonatomic, copy, readonly) id firstObject;
@property (nonatomic, copy, readonly) id lastObject;

@end

typedef IILinq*(^IILinq_Where)(BOOL(^predicate)(id item));
typedef IILinq*(^IILinq_Each)(void(^predicate)(id item));
typedef id(^IILinq_Inject)(id start, id(^predicate)(id result, id item));
typedef IILinq*(^IILinq_TakeOrSkip)(NSUInteger count);

@interface IILinq (Methods)

@property (nonatomic, copy, readonly) IILinq_Where where;
@property (nonatomic, copy, readonly) IILinq_Each each;
@property (nonatomic, copy, readonly) IILinq_TakeOrSkip take;
@property (nonatomic, copy, readonly) IILinq_TakeOrSkip skip;
@property (nonatomic, copy, readonly) IILinq *reverse;

@end

@interface IILinq (Aggregation)

@property (nonatomic, copy, readonly) IILinq_Inject inject;
@property (nonatomic, copy, readonly) id max;
@property (nonatomic, copy, readonly) id min;

@end

@interface NSArray (IILinq)

@property (nonatomic, copy, readonly) IILinq* ii_linq;

@property (nonatomic, copy, readonly) IILinq_Select ii_select;
@property (nonatomic, copy, readonly) IILinq_Where ii_where;
@property (nonatomic, copy, readonly) IILinq_Each ii_each;
@property (nonatomic, copy, readonly) IILinq_TakeOrSkip ii_take;
@property (nonatomic, copy, readonly) IILinq_TakeOrSkip ii_skip;
@property (nonatomic, copy, readonly) IILinq_Inject ii_inject;

@end
