
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


# 查找 实例对象 到 类对象

```

objc_object::initInstanceIsa(Class cls, bool hasCxxDtor)
{
    ASSERT(!cls->instancesRequireRawIsa());
    ASSERT(hasCxxDtor == cls->hasCxxDtor());

    initIsa(cls, true, hasCxxDtor);
}

objc_object::initIsa(Class cls, bool nonpointer, bool hasCxxDtor) 
{ 
    ASSERT(!isTaggedPointer()); 
    
    if (!nonpointer) {
        isa = isa_t((uintptr_t)cls);
    } else {
        ASSERT(!DisableNonpointerIsa);
        ASSERT(!cls->instancesRequireRawIsa());

        isa_t newisa(0);

#if SUPPORT_INDEXED_ISA
        ASSERT(cls->classArrayIndex() > 0);
        newisa.bits = ISA_INDEX_MAGIC_VALUE;
        // isa.magic is part of ISA_MAGIC_VALUE
        // isa.nonpointer is part of ISA_MAGIC_VALUE
        newisa.has_cxx_dtor = hasCxxDtor;
        newisa.indexcls = (uintptr_t)cls->classArrayIndex();
#else
        newisa.bits = ISA_MAGIC_VALUE;
        // isa.magic is part of ISA_MAGIC_VALUE
        // isa.nonpointer is part of ISA_MAGIC_VALUE
        newisa.has_cxx_dtor = hasCxxDtor;
        newisa.shiftcls = (uintptr_t)cls >> 3;
#endif

        // This write must be performed in a single store in some cases
        // (for example when realizing a class because other threads
        // may simultaneously try to use the class).
        // fixme use atomics here to guarantee single-store and to
        // guarantee memory order w.r.t. the class index table
        // ...but not too atomic because we don't want to hurt instantiation
        isa = newisa;
    }
}

```

？ 为什么要 右移 3 位呢 & 需要强转  uintptr_t 类型
```
newisa.shiftcls = (uintptr_t)cls >> 3;
```
因为 右移 3位是 保存 nonpointer、has_assoc、has_cxx_dtor 类信息，
shiftcls 存储 类信息cls 指针的值，转换类型是让类信息能被机器码识别
```

#   define ISA_BITFIELD                                                        \
      uintptr_t nonpointer        : 1;                                         \
      uintptr_t has_assoc         : 1;                                         \
      uintptr_t has_cxx_dtor      : 1;                                         \
      uintptr_t shiftcls          : 44; /*MACH_VM_MAX_ADDRESS 0x7fffffe00000*/ \
      uintptr_t magic             : 6;                                         \
      uintptr_t weakly_referenced : 1;                                         \
      uintptr_t deallocating      : 1;                                         \
      uintptr_t has_sidetable_rc  : 1;                                         \
      uintptr_t extra_rc          : 8

(lldb) p newisa
(isa_t) $10 = {
  cls = Student
  bits = 8303516107965933
   = {
    nonpointer = 1
    has_assoc = 0
    has_cxx_dtor = 1
    shiftcls = 536875197
    magic = 59
    weakly_referenced = 0
    deallocating = 0
    has_sidetable_rc = 0
    extra_rc = 0
  }
}
```

这也是为什么在取 isa 时需要与 ISA_MASK 掩码 做与操作

```
#   define ISA_MASK        0x00007ffffffffff8ULL

inline Class 
objc_object::ISA() 
{
    ASSERT(!isTaggedPointer()); 
#if SUPPORT_INDEXED_ISA
    if (isa.nonpointer) {
        uintptr_t slot = isa.indexcls;
        return classForIndex((unsigned)slot);
    }
    return (Class)isa.bits;
#else
    return (Class)(isa.bits & ISA_MASK);
#endif
}
```
将 ISA_MASK 转化成 二级进制 刚好是可以取出 bits.shiftcls
```
11111111111111111111111111111111111111111111000
```
[结构体的成员ISA_BITFIELD排列情况](./img/ISA_BITFIELD.png)



