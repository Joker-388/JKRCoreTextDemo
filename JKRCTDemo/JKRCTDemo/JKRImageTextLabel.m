//
//  JKRImageTextLabel.m
//  JKRCTDemo
//
//  Created by Lucky on 2018/2/7.
//  Copyright © 2018年 Lucky. All rights reserved.
//

#import "JKRImageTextLabel.h"

#define JKRCoreTextWidth @"JKRCoreTextWidth"
#define JKRCoreTextAscent @"JKRCoreTextAscent"
#define JKRCoreTextDescent @"JKRCoreTextDescent"

@interface JKRImageTextLabel ()

@property (nonatomic, assign) CGRect hightlightRect;
@property (nonatomic, assign) CGRect imageRect;

@end

@implementation JKRImageTextLabel
/*
 CoreText对象
 CTFramesetterRef:创建CTFrameRef需要的中间对象,通过NSMutableAttributedString对象创建
 CTRunDelegateRef:用于自定义一段NSAttributedString进行文字绘制时的参数,如文字宽高,用于图文展示
 CTFrameRef:相当于文字绘制的画布
 CTLineRef:相当于每一行
 CTRunRef:每一行的一块文字,连续相同属性的一段文字在一个CTRun里
 
 
 富文本绘制步骤
 1,获取需要绘制的字符串NSString和图片
 2,把NSString转成NSAttributedString
 3,用NSAttributedString创建CTFramesetterRef
 4,用CTFramesetterRef创建CTFrameRef
 5,获取当前上下文CGContextRef
 6,调整CGContextRef坐标
 7,用CTFrameDraw方法绘制CTFrameRef到上下文
 */

- (void)drawRect:(CGRect)rect {
    
    /**********************************
     1,获取需要绘制的字符串NSString和图片
     **********************************/
    
    // 高亮文字
    NSString *highLightString = @"Joker";
    // 图片尺寸
    CGSize imageSize = CGSizeMake(20, 20);
    // 非高亮文字
    NSString *normalString = @" love you, View Object Controller Code Bug";
    
    /**********************************
     2,把NSString转成NSAttributedString
     **********************************/
    
    // 最终的拼接好的NSMutableAttributedString对象
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    // 高亮文字
    NSMutableAttributedString *highlightAttrString = [[NSMutableAttributedString alloc] initWithString:highLightString];
    [highlightAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, highLightString.length)];
    [highlightAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, highLightString.length)];
    [attributedString appendAttributedString:highlightAttrString];
    
    // 图片占位符定义成一个空格
    NSMutableAttributedString *spaceAttributeString  = [[NSMutableAttributedString alloc] initWithString:@" "];
    
    /*
     因为图片的宽高比文字大得多，为了让一个空格占用的位置足够大
     重定义这段字符的CTRunDelegateRef，让它能够占用到图片尺寸那么大的范围
     */
    
    /*
     CTRunDelegateRef创建需要一个CTRunDelegateCallbacks回调方法结构体
     其中包括四个方法分别返回四个富文本绘制所需的参数
     */
    CTRunDelegateCallbacks callBacks;
    memset(&callBacks, 0, sizeof(CTRunDelegateCallbacks));
    // 字符的宽度,传入一个C语言方法的指针
    callBacks.getWidth = jkr_RunDelegateGetWidthCallback;
    // 字符的上行高度,传入一个C语言方法的指针
    callBacks.getAscent = jkr_RunDelegateGetAscentCallback;
    // 字符的下行高度,传入一个C语言方法的指针
    callBacks.getDescent = jkr_RunDelegateGetDescentCallback;
    callBacks.version = kCTRunDelegateCurrentVersion;
    
    // CTRunDelegateCallbacks结构体中方法返回的参数的集合的字典
    static NSMutableDictionary *refConDictionary;
    refConDictionary = [NSMutableDictionary dictionary];
    refConDictionary[JKRCoreTextAscent] = @(imageSize.height);
    refConDictionary[JKRCoreTextWidth] = @(imageSize.width);
    refConDictionary[JKRCoreTextDescent] = @(0);
    
    // 创建CTRunDelegateRef对象，传入之前创建CTRunDelegateCallbacks结构体和返回结果字典集合refConDictionary
    CTRunDelegateRef runDelegateRef = CTRunDelegateCreate(&callBacks, (__bridge void * _Nullable)(refConDictionary));
    // 将占位字符串spaceAttributeString的CTRunDelegate设置成自定义的CTRunDelegateRef对象
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)spaceAttributeString, CFRangeMake(0, 1), kCTRunDelegateAttributeName, runDelegateRef);
    // 将占位字符拼接到总的用来展示的attributedString中
    [attributedString appendAttributedString:spaceAttributeString];
    
    // 正常显示的文字
    NSMutableAttributedString *normalAttrString = [[NSMutableAttributedString alloc] initWithString:normalString];
    [normalAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, normalString.length)];
    [normalAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, normalString.length)];
    [attributedString appendAttributedString:normalAttrString];
    
    
    /**********************************
     3,用NSAttributedString创建CTFramesetterRef
     **********************************/
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    // CTFrameRef画布的尺寸
    CGPathRef pathRef = CGPathCreateWithRect(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), &CGAffineTransformIdentity);
    
    /**********************************
     4,用CTFramesetterRef创建CTFrameRef
     **********************************/
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), pathRef, nil);

    /**********************************
     5,获取当前上下文CGContextRef
     **********************************/
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    /**********************************
     6,调整CGContextRef坐标
     **********************************/
    
    /* 调整坐标
     CoreText绘制坐标
     y
     ^
     |
     |
     |
     |
     |
     0 -----------------> x
     调整后坐标
     0 -----------------> x
     |
     |
     |
     |
     V
     y
     */
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    // 坐标系整体向上移到顶部
    CGContextTranslateCTM(contextRef, 0, self.frame.size.height);
    // y轴向下翻转
    CGContextScaleCTM(contextRef, 1, -1);
    
    /**********************************
     7,用CTFrameDraw方法绘制CTFrameRef到上下文
     **********************************/
    // 绘制文字
    CTFrameDraw(frameRef, contextRef);
    
    
    /**********************************
     一,获取文本所有的行（CTLine）
     **********************************/
    
    // 获取所有行信息（CTLine数组）
    CFArrayRef lineArrayRef = CTFrameGetLines(frameRef);
    NSArray *lines = (__bridge NSArray *)(lineArrayRef);
    
    CGPoint pointAry[lines.count];
    memset(pointAry, 0, sizeof(pointAry));
    // 每一行的原始坐标起点位置(X轴正确，Y轴是反的)
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), pointAry);
    
    // 累加行高
    float heightAddup = 0;
    
    /**********************************
     二,遍历文本所有的行（CTLine）
     **********************************/
    // 遍历行
    for (unsigned i = 0; i < lines.count; i++) {
        NSLog(@"************* 第 %d 行(CTLine) ***************", i);
        NSLog(@"Line origin: (%f, %f)", pointAry[i].x, pointAry[i].y);
        
        // 行对象
        CTLineRef lineRef = (__bridge CTLineRef)(lines[i]);
        // 获取行内的CTRun数组
        CFArrayRef ctrunArrayRef = CTLineGetGlyphRuns(lineRef);
        NSArray *ctrunArray = (__bridge NSArray *)(ctrunArrayRef);
        
        
        // 上行高度
        CGFloat ascent = 0;
        // 下行高度
        CGFloat descent = 0;
        // 行间距
        CGFloat lineGap = 0;
        // 获取每一个CTRun的尺寸
        CTLineGetTypographicBounds(lineRef, &ascent, &descent, &lineGap);
        // x轴坐标累加
        float startX = 0;
        // 每一行的高度 = 上行高度 + 下行高度 + 行间距
        float runHeight = ascent + descent + lineGap;
        
        /**********************************
         三,遍历文本所有行的内容（CTRun）
         **********************************/
        // 遍历CTRun
        for (unsigned j = 0; j < ctrunArray.count; j++) {
            /**********************************
             四,计算每个CTRun的frame，保存要处理的CTRun的frame
             **********************************/
            NSLog(@"-------- 第 %d 段(CTRun) ----------", j);
            // 获取CTRun对象
            CTRunRef ctrunRef = (__bridge CTRunRef)(ctrunArray[j]);
            CFRange rangeRef = CTRunGetStringRange(ctrunRef);
            NSLog(@"run string : %@", [attributedString.string substringWithRange:NSMakeRange(rangeRef.location, rangeRef.length)]);
            
            // CTRun宽度
            float runWidth = CTRunGetTypographicBounds(ctrunRef, CFRangeMake(0, 0), 0, 0, 0);
            // 第一段高亮
            if (rangeRef.location == 0) {
                NSLog(@"highlight rect : (%0.2f, %0.2f, %0.2f, %0.2f)", startX, heightAddup, runWidth, runHeight);
                // 保存高亮文字的位置，用于高亮点击事件拦截
                self.hightlightRect = CGRectMake(startX, heightAddup, runWidth, runHeight);
            } else if (rangeRef.location == 5) { // 第二段图片
                NSLog(@"image rect : (%0.2f, %0.2f, %0.2f, %0.2f)", startX, heightAddup, runWidth, runHeight);
                // 保存图片的位置，用于添加图片实现图文混排和图片点击事件拦截
                self.imageRect = CGRectMake(startX, heightAddup, runWidth, runHeight);
            } else { // 其余为普通
                NSLog(@"normal rect : (%0.2f, %0.2f, %0.2f, %0.2f)", startX, heightAddup, runWidth, runHeight);
            }
            // x轴坐标累加，每一行第一个CTRun的x轴坐标为0，下一个为startX+上一个CTRun的宽度
            startX += runWidth;
        }
        // y轴坐标累加，第一行的y轴坐标为0，下一行为heightAddup + 上一行高度
        heightAddup += runHeight;
    }
    // 计算完成刷新并在layoutSubviews在图片的位置添加一个UIImageView展示图片实现图文混排
    [self setNeedsLayout];
}

/**********************************
 五,添加图片
 **********************************/
- (void)layoutSubviews {
    UIImageView *imageView = [UIImageView new];
    imageView.image = [UIImage imageNamed:@"baojimoshi"];
    imageView.frame = self.imageRect;
    [self addSubview:imageView];
}

static CGFloat jkr_RunDelegateGetWidthCallback (void * refCon) {
    NSDictionary *runInfo = (__bridge NSDictionary*)refCon;
    if ([runInfo isKindOfClass:[NSDictionary class]]) {
        return [[runInfo objectForKey:JKRCoreTextWidth] floatValue];
    }
    return 0;
}

static CGFloat jkr_RunDelegateGetAscentCallback (void * refCon) {
    NSDictionary *runInfo = (__bridge NSDictionary*)refCon;
    if ([runInfo isKindOfClass:[NSDictionary class]]) {
        return [[runInfo objectForKey:JKRCoreTextAscent] floatValue];
    }
    return 0;
}

static CGFloat jkr_RunDelegateGetDescentCallback (void * refCon) {
    return 0;
}

/**********************************
 六,高亮/图片点击拦截处理
 **********************************/
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:self];
    if (CGRectContainsPoint(self.hightlightRect, point)) {
        NSLog(@"点击高亮");
    }
    if (CGRectContainsPoint(self.imageRect, point)) {
        NSLog(@"点击图片");
    }
}

@end
