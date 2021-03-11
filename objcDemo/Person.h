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

struct WData {
    NSDictionary * infos;
    NSInteger   height;
    NSString * alise;
    CGFloat     money;
};
@interface Student : NSObject
{
    @public
    struct WData d;
    
    NSString * note;
}

@property (nonatomic , strong) NSString * name;
@property (nonatomic , assign) int age;


@property (nonatomic , copy) void (^modify)(NSString *name, int age);

@end

NS_ASSUME_NONNULL_END
