//
//  JKRTextLabel.m
//  JKRCTDemo
//
//  Created by Lucky on 2018/2/7.
//  Copyright © 2018年 Lucky. All rights reserved.
//

#import "JKRTextLabel.h"
#import <CoreText/CoreText.h>

@interface JKRTextLabel ()

@property (nonatomic, assign) CGRect hightlightRect;

@end

@implementation JKRTextLabel

- (void)drawRect:(CGRect)rect {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    NSString *highLightString = @"Joker";

    NSMutableAttributedString *highlightAttrString = [[NSMutableAttributedString alloc] initWithString:highLightString];
    [highlightAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, highLightString.length)];
    [highlightAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, highLightString.length)];
    [attributedString appendAttributedString:highlightAttrString];
    
    NSString *normalString = @" love you";
    NSMutableAttributedString *normalAttrString = [[NSMutableAttributedString alloc] initWithString:normalString];
    [normalAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, normalString.length)];
    [normalAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, normalString.length)];
    [attributedString appendAttributedString:normalAttrString];
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    CGPathRef pathRef = CGPathCreateWithRect(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), &CGAffineTransformIdentity);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, 0), pathRef, nil);
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
    // 坐标系整体向上移到顶部
    CGContextTranslateCTM(contextRef, 0, self.frame.size.height);
    // y轴向下翻转
    CGContextScaleCTM(contextRef, 1, -1);
    // 绘制文字
    CTFrameDraw(frameRef, contextRef);
    
    
    // 获取信息
    CFArrayRef lineArrayRef = CTFrameGetLines(frameRef);
    
    NSArray *lines = (__bridge NSArray *)(lineArrayRef);
    
    CGPoint pointAry[lines.count];
    memset(pointAry, 0, sizeof(pointAry));
    CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), pointAry);
    float heightAddup = 0;
    
    for (unsigned i = 0; i < lines.count; i++) {
        CTLineRef lineRef = (__bridge CTLineRef)(lines[i]);
        CFArrayRef ctrunArrayRef = CTLineGetGlyphRuns(lineRef);
        NSArray *ctrunArray = (__bridge NSArray *)(ctrunArrayRef);
        
        CGFloat ascent = 0;
        CGFloat descent = 0;
        CGFloat lineGap = 0;
        
        CTLineGetTypographicBounds(lineRef, &ascent, &descent, &lineGap);
        
        float startX = 0;
        float runHeight = ascent + descent + lineGap;
        
        for (unsigned j = 0; j < ctrunArray.count; j++) {
            CTRunRef ctrunRef = (__bridge CTRunRef)(ctrunArray[j]);
            CFRange rangeRef = CTRunGetStringRange(ctrunRef);
            
            float runWidth = CTRunGetTypographicBounds(ctrunRef, CFRangeMake(0, 0), 0, 0, 0);

            if (rangeRef.location == 0) {
                NSLog(@"highlight rect : %f %f %f %f", startX, heightAddup, runWidth, runHeight);
                self.hightlightRect = CGRectMake(startX, heightAddup, runWidth, runHeight);
            }
            startX += runWidth;
        }
        
        heightAddup += runHeight;
        
        NSLog(@"%f == %f", pointAry[i].y, heightAddup);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:self];
    if (CGRectContainsPoint(self.hightlightRect, point)) {
        NSLog(@"点击高亮");
    }
}

@end
