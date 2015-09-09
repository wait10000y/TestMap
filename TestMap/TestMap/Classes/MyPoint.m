//
//  MyPoint.m
//  TestMap
//
//  Created by wsliang on 15/8/24.
//  Copyright (c) 2015年 wsliang. All rights reserved.
//

#import "MyPoint.h"

@implementation MyPoint

-(id)initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString *)t andSubtitle:(NSString*)s{
  self = [super init];
  if(self){
    _coordinate = c;
    _title = t;
    _subtitle = s;
  }
  return self;
}

@end
