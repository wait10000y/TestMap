//
//  dView.m
//  mapdraw
//
//  Created by admin on 12-9-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "dView.h"

@implementation dView
{
  void *data;
  CGContextRef context;
  BOOL candraw;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
      [self setDefaultData];
        //[self clear];
    }
    return self;
}

-(void)setDefaultData
{
  int width = self.bounds.size.width;
  int height = self.bounds.size.height;
  data = malloc(width * height * 4);
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  context = CGBitmapContextCreate(Nil, width, height, 8, 4 * width,
                                  colorSpace, kCGImageAlphaPremultipliedFirst);
  CGColorSpaceRelease(colorSpace);

  candraw = YES;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextDrawImage(currentContext, rect, image);
    CGImageRelease(image);
    //CGContextRelease(currentContext);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)evnet {
    CGPoint p = [[touches anyObject] locationInView:self];
    CGPoint q = [[touches anyObject] previousLocationInView:self];
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 3);
    CGContextMoveToPoint(context, q.x, q.y);
    CGContextAddLineToPoint(context, p.x, p.y);
    //CGFloat bluecolor[4]={1.0f,0.0f,0.0f,1.0f};
    //CGContextSetStrokeColor(context, bluecolor);
    CGContextSetRGBStrokeColor(context,0,0.7,0,1);//要用RGB的
    CGContextStrokePath(context);
    [self setNeedsDisplay];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.0);
//    CGContextFillRect(context, self.bounds);
//    [self setNeedsDisplay];
    
    CGContextClearRect(context, self.frame);
    [self setNeedsDisplay];
}

@end
