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

@interface Tests : XCTestCase
@end


@implementation Tests

- (void)test_it_works {
  XCTAssertTrue(YES);
}
@end
