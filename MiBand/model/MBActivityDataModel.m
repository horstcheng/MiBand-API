#import "MBActivityDataModel.h"

@implementation MBActivityDataModel

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, intensity = %tu, steps = %tu, category = %tu>",[self class], self, _intensity, _steps, _category];
}

@end
