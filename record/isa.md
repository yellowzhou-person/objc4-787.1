
# isa

实例对象 -> 类对象 -> 元类  -> 根元类  -> 根元类

元类是存在继承的，可以通过 superclass 获取

# 通过 接口获取 isa 内容

```
// woman 实例对象 isa -> Woman 类对象
Class cls = object_getClass(woman);

// Woman 类对象 isa -> Woman 元类
Class metaCls = object_getClass(cls);

// Woman 元类 isa -> NSObject 根元类
Class rootMetaCls = object_getClass(metaCls);

//NSObject 根元类 -> 根根元类，顶端
Class superRootMetaCls = object_getClass(rootMetaCls);

```


# 打印信息，验证 isa 指向类型


```
     (lldb) p woman.class
     (Class) $1 = Woman
     (lldb) p/x woman
     (Woman *) $2 = 0x00000001006702b0
     (lldb) x/4gx woman
     0x1006702b0: 0x001d80010000830d 0x0000000000000064
     0x1006702c0: 0x00000000000001c8 0x0000000100004010
     (lldb) p/x 0x001d80010000830d & 0x00007ffffffffff8UL
     (unsigned long) $4 = 0x0000000100008308
     (lldb) po 0x0000000100008308
     Woman

     (lldb) p/x woman.class
     (Class) $6 = 0x0000000100008308 Woman
     (lldb) p/x cls         // $6、$7 地址是一致的
     (Class) $7 = 0x0000000100008308 Woman
     (lldb) p/x metaCls
     (Class) $8 = 0x00000001000082e0
     (lldb) po 0x00000001000082e0
     Woman

     (lldb) po rootMetaCls
     NSObject

     (lldb) p/x rootMetaCls
     (Class) $11 = 0x00000001003500f0
     (lldb) po superRootMetaCls
     NSObject

     (lldb) p/x object_getClass(superRootMetaCls)
     (Class) $14 = 0x00000001003500f0 // $11、$14 是一致的，说明根元类实现一个闭环，自己指向自己的元类
     
     (lldb) p/x NSObject.class
     (Class) $15 = 0x0000000100350140 NSObject
     (lldb) x/4gx 0x0000000100350140
     0x100350140: 0x00000001003500f0 0x0000000000000000
     0x100350150: 0x00000001021147b0 0x0002801000000003
     (lldb) p/x 0x00000001003500f0 & 0x00007ffffffffff8UL  // 通过NSObject 类对象 isa 指向的元类
     (unsigned long) $16 = 0x00000001003500f0   // NSObject 元类 isa 指向的依然是 NSObject 元类
         
```





