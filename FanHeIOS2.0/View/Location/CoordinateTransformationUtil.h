//
//  CoordinateTransformationUtil.h
//  ShiChaZu
//
//  Created by renhao on 15/10/8.
//  Copyright © 2015年 shichazu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoordinateTransformationUtil : NSObject
+(CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc;
@end
