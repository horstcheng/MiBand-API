#import "MBActivityDataFragmentModel.h"

@implementation MBActivityDataFragmentModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _activityDataList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, type = %tu, timeStamp = %@, duration = %tu min, count = %tu>",[self class], self, _type, _timeStamp, _duration, _count];
}

@end
