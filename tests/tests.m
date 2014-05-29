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
@end
