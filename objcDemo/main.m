//
//  main.m
//  objcDemo
//
//  Created by Twisted Fate on 2021/1/8.
//

#import <Foundation/Foundation.h>

#import "Person.h"

OBJC_EXTERN void
_objc_autoreleasePoolPrint(void);

OBJC_EXTERN int _objc_rootRetainCount(id);

OBJC_EXPORT size_t
class_getInstanceSize(Class _Nullable cls);
extern size_t malloc_size(const void *ptr);

OBJC_EXPORT Class _Nullable
object_getClass(id _Nullable obj);

OBJC_EXPORT BOOL
class_isMetaClass(Class _Nullable cls);

OBJC_EXPORT Class _Nullable
class_getSuperclass(Class _Nullable cls);


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        /*
         // https://www.jianshu.com/p/00fca1c5d742
         (lldb) x/4gx woman //打印实例对象内存分布
         0x101046e10: 0x001d800100008215 0x0000000000000064
         0x101046e20: 0x00000000000001c8 0x0000000100004010
         
         (lldb) p/x 0x001d800100008215 & 0x00007ffffffffff8UL   //
         (unsigned long) $13 = 0x0000000100008210
         (lldb) po 0x0000000100008210
         Person
         
         (lldb) po 0x001d800100008215
         8303516107964949

         (lldb) po 0x0000000000000064
         100

         (lldb) po 0x00000000000001c8
         456

         (lldb) po 0x0000000100004010
         yellow
         */
        Woman *woman = [[Woman alloc]init];
        woman.name = @"yellow";
        woman->age = 100;
        woman->index = 456;
        
        Student *student = [Student new];
        struct WData d;
        d.infos = @{@"a":@"123",@"b":@456};
        d.height = 120;
        d.money = 78.36;
        d.alise = @"alise ....";
        student->d = d;
        student->note = @"note ....";
        
        object_getClass(student);
        
        size_t size1 = class_getInstanceSize(woman.class);
        size_t size2 = class_getInstanceSize(Person.class);
        size_t size3 = malloc_size((__bridge const void *)(woman));
        NSLog(@"%@: %ld,%ld,%ld",NSStringFromClass(woman.class),size1,size2,size3);
        
        
        

        
        
        for (int i = 0; i < 505; i++) {
            NSObject *p = [[NSObject alloc] autorelease];
        }
    
//        NSObject *p1 = [[NSObject alloc] auto];
//        NSObject *p2 = [[NSObject alloc] init];
        _objc_autoreleasePoolPrint();
        NSLog(@"Hello, World!");
    }
    NSLog(@"Hello, World!");
    return 0;
}
