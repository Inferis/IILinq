#import "IILinq/IILinq.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu-zero-variadic-macro-arguments"
@import XCTest;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wimplicit-retain-self"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu-zero-variadic-macro-arguments"

int main() {
    @autoreleasepool {
        XCTSelfTestMain();
    }
}

#import "IILinq/IILinq.m"

@interface Tests : XCTestCase
@end

@implementation Tests

- (void)test_readme_select {
  NSArray *bunchOfInts = @[@7, @9, @7, @2, @0, @4];

  NSArray *result = bunchOfInts.ii_linq.select(^id(id item) {
      return [NSString stringWithFormat:@"%@%@", item, item];
    }).allObjects;
  NSArray *expected = @[@"77", @"99", @"77", @"22", @"00", @"44"];
  XCTAssertEqualObjects(result, expected);
}

- (void)test_readme_shorthand {
  NSArray *bunchOfInts = @[@7, @9, @7, @2, @0, @4];

  NSArray *result = bunchOfInts.ii_where(^BOOL(id item) {
      return [item integerValue] > 5;
    }).select(^id(id item) {
        return [NSString stringWithFormat:@"%@%@", item, item];
      }).allObjects;

  NSArray *expected = @[@"77", @"99", @"77"];
  XCTAssertEqualObjects(result, expected);
}

- (void)test_readme_inject {
  id sum = @[@1, @2, @3, @4].ii_inject(@0, ^(NSNumber* result, NSNumber* element) {
      return @([result integerValue] + [element integerValue]);
    });
  NSString *result = [NSString stringWithFormat:@"result = %@", sum];
  XCTAssertEqualObjects(@"result = 10", result);
}

- (void)test_readme_enumerating {
  NSArray *bunchOfInts = @[@7, @9, @7, @2, @0, @4];
  NSMutableArray *result = @[].mutableCopy;
  IILinq *filtered = bunchOfInts.ii_skip(2).select(^id(NSNumber* num) {
      [result addObject:[NSString stringWithFormat:@"processing %@", num]];
      return [NSString stringWithFormat:@"%@%@", num, num];
    });

  for (NSString* item in filtered) {
    [result addObject:[NSString stringWithFormat:@"Got %@", item]];
    if ([item isEqualToString:@"00"]) {
      break;
    }
  }
  NSArray *expected = @[@"processing 7", @"Got 77", @"processing 2", @"Got 22", @"processing 0", @"Got 00"];
  XCTAssertEqualObjects(expected, result);
}
@end
