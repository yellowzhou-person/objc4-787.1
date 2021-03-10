//
//  Person.h
//  objcDemo
//
//  Created by Twisted Fate on 2021/1/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject
{
    @public
    NSInteger age;
    int index;
}
@property (nonatomic, strong)   NSString *name;


@end

@interface Woman : Person

@end

NS_ASSUME_NONNULL_END
