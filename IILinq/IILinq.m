//
//  IILinq.m
//
//  Created by Tom Adriaenssen on 21/05/14.
//  Copyright (c) 2014 Tom Adriaenssen. All rights reserved.
//

#import "IILinq.h"

@interface IILinqEnumerator : NSEnumerator

+ (instancetype)enumeratorFor:(IILinq*)linq reverse:(BOOL)reverse;

@end

@implementation IILinq
{
    @public
    NSArray *_processors;
    NSArray *_source;
}

+ (instancetype)linqWithArray:(NSArray*)array
{
    IILinq *linq = [IILinq new];
    linq->_source = [array copy];
    linq->_processors = [NSArray new];
    return linq;
}

- (instancetype)linqWithPredicate:(id)processor toMany:(BOOL)toMany
{
    IILinq *linq = [IILinq new];
    linq->_source = self->_source;
    linq->_processors = [_processors arrayByAddingObject:@[processor, @(toMany)]];
    return linq;
}

- (id)init
{
    self = [super init];
    if (self) {
        _processors = [NSArray new];
    }
    return self;
}


- (IILinqEnumerator*)enumerator
{
    return [IILinqEnumerator enumeratorFor:self reverse:NO];
}

- (IILinqEnumerator*)reverseEnumerator
{
    return [IILinqEnumerator enumeratorFor:self reverse:YES];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    NSEnumerator *enumerator;
    if (state->extra[0]) {
         enumerator = (__bridge __strong NSEnumerator*)(void*)state->extra[0];
    }
    else {
        enumerator = [self enumerator];
        state->extra[0] = (unsigned long)(__bridge void*)enumerator;
    }
    return [enumerator countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - Stuff

- (IILinq_Select)select
{
    return ^(id(^predicate)(id item)) {
        return [self linqWithPredicate:predicate toMany:NO];
    };
}

- (IILinq_SelectMany)selectMany
{
    return ^(NSArray*(^predicate)(id item)) {
        return [self linqWithPredicate:predicate toMany:YES];
    };
}

- (NSArray*)allObjects
{
    return [[self enumerator] allObjects];
}

- (id)firstObject
{
    return [[self enumerator] nextObject];
}

- (id)singleObject
{
    IILinqEnumerator* enumerator = [self enumerator];
    id result = [enumerator nextObject];
    id next = [enumerator nextObject];

    if (result && next) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"linq enumeration resulted in more than one object" userInfo:nil];
    }
    else if (!result) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"linq enumeration resulted in zero objects" userInfo:nil];
    }

    return result;
}

- (id)lastObject
{
    return [[self reverseEnumerator] nextObject];
}

@end

@implementation IILinq (Methods)

- (IILinq_Where)where
{
    return ^(BOOL(^predicate)(id item)) {
        return self.select(^id(id item) {
            return predicate(item) ? item : nil;
        });
    };
}

- (IILinq_Each)each
{
    return ^(void(^predicate)(id item)) {
        return self.select(^id(id item) {
            predicate(item);
            return nil;
        });
    };
}

- (IILinq_TakeOrSkip)skip
{
    return ^IILinq*(NSUInteger skip) {
        __block NSUInteger count = skip;
        return self.select(^id(id item) {
            if (count > 0) {
                count--;
                return nil;
            }
            else {
                return item;
            }
        });
    };
}

- (IILinq_TakeOrSkip)take
{
    return ^IILinq*(NSUInteger skip) {
        __block NSUInteger count = skip;
        return self.select(^id(id item) {
            if (count > 0) {
                count--;
                return item;
            }
            else {
                return nil;
            }
        });
    };
}

- (IILinq*)reverse
{
    NSArray* all = [[self reverseEnumerator] allObjects];
    return [IILinq linqWithArray:all];
}

@end

@implementation IILinq (Aggregation)

- (IILinq_Inject)inject
{
    return ^id(id start, id(^predicate)(id result, id item)) {
        __block id result = start;
        for (id item in self) {
            result = predicate(result, item);
        }
        return result;
    };
}

- (id)min
{
    __block id result = nil;
    for (id item in self) {
        if (!result || [item compare:result] == NSOrderedAscending) {
            result = item;
        }
    };
    return result;
}

- (id)max
{
    __block id result = nil;
    for (id item in self) {
        if (!result || [item compare:result] == NSOrderedDescending) {
            result = item;
        }
    }
    return result;
}


@end

@implementation NSArray (IILinq)

- (IILinq *)ii_linq
{
    return [IILinq linqWithArray:self];
}

- (IILinq_Select)ii_select
{
    return ^(id(^select)(id item)) {
        return self.ii_linq.select(select);
    };
}

- (IILinq_Where)ii_where
{
    return ^(BOOL(^where)(id item)) {
        return self.ii_linq.where(where);
    };
}

- (IILinq_Each)ii_each
{
    return ^(void(^each)(id item)) {
        return self.ii_linq.each(each);
    };
}

- (IILinq_TakeOrSkip)ii_skip
{
    return ^(NSUInteger count) {
        return self.ii_linq.skip(count);
    };
}

- (IILinq_TakeOrSkip)ii_take
{
    return ^(NSUInteger count) {
        return self.ii_linq.take(count);
    };
}

- (IILinq_Inject)ii_inject {
    return ^id(id start, id(^predicate)(id result, id item)) {
        return self.ii_linq.inject(start, predicate);
    };
}

@end

@implementation IILinqEnumerator {
    NSArray *_processors;
    NSEnumerator *_source;
    BOOL _reverse;
    NSMutableArray *_buffer;
}

+ (instancetype)enumeratorFor:(IILinq*)linq reverse:(BOOL)reverse
{
    IILinqEnumerator *result = [IILinqEnumerator new];
    result->_processors = linq->_processors;
    result->_source = reverse ? [linq->_source reverseObjectEnumerator] : [linq->_source objectEnumerator];
    result->_reverse = reverse;
    return result;
}

- (NSArray *)allObjects
{
    NSMutableArray *array = [NSMutableArray array];
    for (id item in _source) {
        NSArray* processedItems = [self processItem:item];
        [array addObjectsFromArray:processedItems];
    }

    return [array copy];
}

- (id)nextObject
{
    if (_buffer) {
        id result = [_buffer firstObject];

        if (_buffer.count <= 1) {
            // if this is the last object, clear the buffer
            _buffer = nil;
        }
        else {
            // remove the just picked result object
            [_buffer removeObjectAtIndex:0];
        }
        return result;
    }

    // check source objects now
    id result = nil;
    while (!result) {
        id nextSource = [_source nextObject];
        if (!nextSource) {
            // iteration is over. Reset source and processors so they can be freed even though
            // the enumerator might be kept around.
            _source = nil;
            _processors = nil;
            return nil;
        }

        // process the source object. This can result into multiple result objects (thanks to selectMany).
        // if we get more than one back, store these in a buffer
        NSArray* items = [self processItem:nextSource];
        result = [items firstObject];
        if (items.count > 1) {
            // remember other items so we can return them next
            _buffer = [NSMutableArray arrayWithArray:items];
            [_buffer removeObjectAtIndex:0];
        }
    }

    return result;
}

- (NSArray*)processItem:(id)item
{
    return [self processItem:item withProcessors:_processors];
}

- (NSArray*)processItem:(id)item withProcessors:(NSArray*)processors
{
    NSArray* processor = [processors firstObject];
    if (!processor) {
        return @[item];
    }

    // get predicate and toMany flag from the current processor
    id(^predicate)(id x) = processor[0];
    BOOL toMany = [processor[1] boolValue];
    // reduce processors list (remove current processor)
    processors = [processors subarrayWithRange:NSMakeRange(1, processors.count-1)];

    item = predicate(item);
    if (item) {
        if (toMany && [item conformsToProtocol:@protocol(NSFastEnumeration)]) {
            NSMutableArray *toManyResult = [NSMutableArray array];
            for (id subitem in (id<NSFastEnumeration>)item) {
                NSArray *subresults = [self processItem:subitem withProcessors:processors];
                if (_reverse) {
                    for (id subresult in subresults) {
                        [toManyResult insertObject:subresult atIndex:0];
                    }
                }
                else {
                    [toManyResult addObjectsFromArray:subresults];
                }
            }
            return toManyResult;
        }
        else {
            return [self processItem:item withProcessors:processors];
        }
    }

    return @[];
}

@end
