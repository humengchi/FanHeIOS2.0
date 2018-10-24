//
//  MyPoint.m
//  ShiChaZu
//
//  Created by zemeng li on 15/5/26.
//  Copyright (c) 2015年 shichazu. All rights reserved.
//

#import "MyPoint.h"

@implementation MyPoint 

-(id)initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString*)t andAdd:(NSString *)subtitle{
    self = [super init];
    if(self){
        _coordinate = c;
        _title = t;
        _subtitle = subtitle;
    }
    return self;
}
@end
