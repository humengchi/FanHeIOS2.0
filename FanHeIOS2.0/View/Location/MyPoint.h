//
//  MyPoint.h
//  ShiChaZu
//
//  Created by zemeng li on 15/5/26.
//  Copyright (c) 2015年 shichazu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface MyPoint : NSObject<MKAnnotation>
//实现MKAnnotation协议必须要定义这个属性
@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
//标题
@property (nonatomic,copy) NSString *title;

@property (nonatomic,copy) NSString *subtitle;

@property (nonatomic,readwrite)MKAnnotationView *mkA;


//初始化方法
-(id)initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString*)t andAdd:(NSString *)subtitle ;

@end
