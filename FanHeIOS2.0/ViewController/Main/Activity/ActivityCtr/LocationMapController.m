//
//  LocationMapController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "LocationMapController.h"
#import "MyPoint.h"
#import "CoordinateTransformationUtil.h"
#define DefaultLocationTimeout 10
#define DefaultReGeocodeTimeout 5
@interface LocationMapController ()<CLLocationManagerDelegate,MKMapViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic ,strong)MKMapView *mapView;
@end

@implementation LocationMapController
@synthesize latitude,longitude,userLatitude,userLongitude,guserLatitude,guserLongitude;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createCustomNavigationBar:@""];
    ///初始化地图
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT - 64)];
    self.mapView.delegate = self;
    ///把地图添加至view
    [self.view addSubview:self.mapView];
    self.mapView.mapType = MKMapTypeStandard;
       
    //创建CLLocation 设置经纬度
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:self.latitude  longitude:self.longitude];
    CLLocationCoordinate2D coord = [loc coordinate];
    
    MyPoint *myPoint = [[MyPoint alloc] initWithCoordinate:coord andTitle:self.addressStr andAdd:nil];
    //添加标注
    [_mapView addAnnotation:myPoint];
    MKCoordinateSpan span=MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region=MKCoordinateRegionMake(loc.coordinate, span);
    [_mapView setRegion:region animated:YES];
    
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = 5.0f;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(WIDTH-60, 20, 50, 44);
    [editBtn setTitle:@"导航" forState:UIControlStateNormal];
    [editBtn setTitleColor:HEX_COLOR(@"818C9E") forState:UIControlStateNormal];
    editBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [editBtn addTarget:self action:@selector(mapNavigationGaoDe:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:editBtn];
}

- (void)mapNavigationGaoDe:(UIButton*)btn{
    
    CLLocationCoordinate2D cooder = CLLocationCoordinate2DMake(self.guserLatitude, self.guserLongitude);
    
    CLLocationCoordinate2D bdPt = [JZLocationConverter wgs84ToBd09:cooder];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        
    }];
    
    UIAlertAction* baiduMap = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault                                                             handler:^(UIAlertAction * action) {
        
        CLLocationCoordinate2D cooder1 = CLLocationCoordinate2DMake(self.latitude, self.longitude);
        
        CLLocationCoordinate2D bdPt1 = [JZLocationConverter wgs84ToBd09:cooder1];
        NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:终点&mode=driving",bdPt.latitude , bdPt.longitude,bdPt1.latitude , bdPt1.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
        
    }];
    UIAlertAction* gaoDeMap = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault                                                                 handler:^(UIAlertAction * action)  {
        CLLocationCoordinate2D test = CLLocationCoordinate2DMake(self.guserLatitude,self.guserLongitude);
        
        CLLocationCoordinate2D gcjCord  = [CoordinateTransformationUtil transformFromWGSToGCJ:test];
      //  CLLocationCoordinate2D from = CLLocationCoordinate2DMake(gcjCord.latitude,gcjCord.longitude);
        
        
        MKMapItem *fromLocation = [MKMapItem mapItemForCurrentLocation];
        
    //    MKPlacemark * fromMark = [[MKPlacemark alloc] initWithCoordinate:from
                                                       //addressDictionary:nil];
      //  MKMapItem * fromLocation = [[MKMapItem alloc] initWithPlacemark:fromMark];
        fromLocation.name = @"我的位置";
        CLLocationCoordinate2D to = CLLocationCoordinate2DMake(self.latitude,self.longitude);
        MKPlacemark * toMark = [[MKPlacemark alloc] initWithCoordinate:to
                                                     addressDictionary:nil];
        MKMapItem * toLocation = [[MKMapItem alloc] initWithPlacemark:toMark];
        toLocation.name = self.addressStr;
        
        NSArray  * values = [NSArray arrayWithObjects:
                             MKLaunchOptionsDirectionsModeDriving,
                             [NSNumber numberWithBool:YES],
                             [NSNumber numberWithInt:0],
                             nil];
        NSArray * keys = [NSArray arrayWithObjects:
                          MKLaunchOptionsDirectionsModeKey,
                          MKLaunchOptionsShowsTrafficKey,
                          MKLaunchOptionsMapTypeKey,nil];
        
        [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:fromLocation, toLocation, nil]
                       launchOptions:[NSDictionary dictionaryWithObjects:values
                                                                 forKeys:keys]];
        
    }];
    [alertController addAction:cancelAction];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]])
    {
        [alertController addAction:baiduMap];
    }
    
    [alertController addAction:gaoDeMap];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}
#pragma mark-------大头针内容自动显示
-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MKPinAnnotationView * piview = (MKPinAnnotationView *)[views objectAtIndex:0];
    [_mapView selectAnnotation:piview.annotation animated:YES];
}
#pragma mark - 地图控件代理方法
#pragma mark 更新用户位置，只要用户改变则调用此方法（包括第一次定位到用户位置）
//定位成功后执行这个代理
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    
    if (locations.count)
    {
        CLLocation * location = (CLLocation *)[locations objectAtIndex:0];
        
        self.guserLatitude = location.coordinate.latitude;
        self.guserLongitude = location.coordinate.longitude;
        
    }
    
}

//- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id )annotation
//{
//
//
//    MKPinAnnotationView *pinView = nil;
//    if(annotation != _mapView.userLocation)
//    {
//        static NSString *defaultPinID = @"com.invasivecode.pin";
//        pinView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
//        if ( pinView == nil ) pinView = [[MKPinAnnotationView alloc]
//                                         initWithAnnotation:annotation reuseIdentifier:defaultPinID] ;
//        pinView.pinColor = MKPinAnnotationColorRed;
//
//        //        pinView.image = [UIImage imageNamed:@"lucency_image"];
//        //左边的图片
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 77, 38)];
//        imageView.image = [UIImage imageNamed:@"guidance"];
//        UITapGestureRecognizer *mapTapMapView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mapTapMapViewActionClick:)];
//        imageView.userInteractionEnabled = YES;
//        [imageView addGestureRecognizer:mapTapMapView];
//        pinView.rightCalloutAccessoryView = imageView;
//
//
//        pinView.canShowCallout = YES;
//        pinView.animatesDrop = YES;
//    }
//    else {
//        [_mapView.userLocation setTitle:@"欧陆经典"];
//        [_mapView.userLocation setSubtitle:@"vsp"];
//    }
//    return pinView;
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
