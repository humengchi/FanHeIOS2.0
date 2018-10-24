//
//  ActivityLocationViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityLocationViewController.h"
#import "MyPoint.h"

@interface ActivityLocationViewController ()<MAMapViewDelegate, AMapLocationManagerDelegate, AMapSearchDelegate>{
    NSString *_hasLocationAddress;
    NSInteger _currentPage;
    BOOL _handMove;
}

//@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) UIImageView *location;

@property (nonatomic, strong) AMapLocationManager *locationManager;

@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) UILabel *addressLabel;

@property (nonatomic, strong) NSMutableArray *resultDataArray;

@property (nonatomic, strong) AMapPOI *selectedModel;

@property (nonatomic, assign) CLLocationCoordinate2D selectedCoord;

@end

@implementation ActivityLocationViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //停止定位
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"活动定位"];
    self.resultDataArray = [NSMutableArray array];
    _currentPage = 1;
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    finishBtn.frame = CGRectMake(WIDTH-64, 20, 64, 44);
    [finishBtn setTitle:@"确定" forState:UIControlStateNormal];
    [finishBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
    finishBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [finishBtn addTarget:self action:@selector(finishButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finishBtn];
    
    [self initSearchBar:CGRectMake(0, 64, WIDTH, 44)];
    self.searchBar.showsCancelButton = NO;
    
    [AMapServices sharedServices].enableHTTPS = YES;
    
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 108, WIDTH, WIDTH*9/16)];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    //如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.zoomLevel = 18;
    
    //imageview
    self.location = [[UIImageView alloc] initWithFrame:CGRectMake((WIDTH-12)/2.0, (WIDTH*9/16-16)/2, 12, 16)];
    self.location.image = kImageWithName(@"icon_map_bz");
    [self.mapView addSubview:self.location];
    [self configLocationManager];
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    [self initTableView:CGRectMake(0, 108+WIDTH*9/16, WIDTH, HEIGHT-(108+WIDTH*9/16))];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = WHITE_COLOR;
    [self.tableView tableViewAddUpLoadRefreshing:^{
        _currentPage += 1;
        [self searchRequest];
    }];
}

- (void)configLocationManager{
    self.locationManager = [[AMapLocationManager alloc] init];
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //   定位超时时间，最低2s，此处设置为10s
    self.locationManager.locationTimeout =10;
    //   逆地理请求超时时间，最低2s，此处设置为10s
    self.locationManager.reGeocodeTimeout = 10;
    //开始定位
    //    [self.locationManager startUpdatingLocation];
    
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        
        NSLog(@"location:%@", location);
        
        if (regeocode)
        {
            NSLog(@"reGeocode:%@", regeocode);
            self.selectedCoord = location.coordinate;
            if(self.searchBar.text.length==0&&_handMove==NO){
                _currentPage = 1;
                [self searchRequest];
            }
        }
    }];
}

//- (void)configLocationManager_back{
//    self.locationManager = [[AMapLocationManager alloc] init];
//    [self.locationManager setDelegate:self];
//    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
//    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
//    // 带逆地理信息的一次定位（返回坐标和地址信息）
//    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
//    //   定位超时时间，最低2s，此处设置为10s
//    self.locationManager.locationTimeout =10;
//    //   逆地理请求超时时间，最低2s，此处设置为10s
//    self.locationManager.reGeocodeTimeout = 10;
//    //开始定位
//    [self.locationManager startUpdatingLocation];
//}
//
//#pragma mark- AMapLocationManagerDelegate
//- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error{
//    //定位错误
//    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
//}
//
//- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location{
//    self.selectedCoord = location.coordinate;
//    if(self.searchBar.text.length==0&&_handMove==NO){
//        _currentPage = 1;
//        [self searchRequest];
//    }
//}

#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [self.view endEditing:YES];
    CLLocationCoordinate2D coord = [self.mapView convertPoint:CGPointMake((WIDTH-12)/2.0, (WIDTH*9/16-16)/2+8) toCoordinateFromView:self.location];
    self.selectedCoord = coord;
    if(self.searchBar.text.length==0){
        _currentPage = 1;
        [self searchRequest];
    }
}

- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction{
    if(wasUserAction){
        _handMove = YES;
    }
}

#pragma mark - 周围搜索
- (void)searchRequest{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:self.selectedCoord.latitude longitude:self.selectedCoord.longitude];
    request.keywords = [CommonMethod paramStringIsNull:self.searchBar.text];
    /* 按照距离排序. */
    if(self.searchBar.text.length){
        request.sortrule = 1;
    }else{
        request.sortrule = 0;
    }
    request.offset = 20;
    request.page = _currentPage;
    request.requireExtension = YES;
    [self.search AMapPOIAroundSearch:request];
}

#pragma mark -  AMapSearchDelegate
/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    if (response.pois.count == 0){
        return;
    }
    if(_currentPage==1){
        [self.resultDataArray removeAllObjects];
    }
    [self.tableView endRefresh];
    [self.resultDataArray addObjectsFromArray:response.pois];
    [self.tableView reloadData];
}

#pragma mark - 按钮方法
- (void)finishButtonClicked:(UIButton*)sender{
    [self.view endEditing:YES];
    if(self.selectedModel){
        self.selectLoaction(self.selectedModel);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.resultDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 80)];
    headerView.backgroundColor = HEX_COLOR(@"1abc9c");
    self.addressLabel = [UILabel createLabel:CGRectMake(16, 0, WIDTH-32, 40) font:FONT_SYSTEM_SIZE(14) bkColor:HEX_COLOR(@"1abc9c") textColor:WHITE_COLOR];
    if([CommonMethod paramStringIsNull:_hasLocationAddress].length==0 || self.searchBar.text.length == 0){
        if(self.resultDataArray.count){
            AMapPOI *model = self.resultDataArray[0];
            _hasLocationAddress = [NSString stringWithFormat:@"【当前】%@ %@",model.address,model.name];
            self.addressLabel.text = _hasLocationAddress;
            self.selectedModel = model;
        }else{
            self.addressLabel.text = @"【当前】定位中...";
        }
    }else{
        self.addressLabel.text = _hasLocationAddress;
    }
    [headerView addSubview:self.addressLabel];
    return headerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
    }
    AMapPOI *model = self.resultDataArray[indexPath.row];
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = model.address;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    AMapPOI *model = self.resultDataArray[indexPath.row];
    _hasLocationAddress = [NSString stringWithFormat:@"【当前】%@ %@",model.address,model.name];
    self.addressLabel.text = _hasLocationAddress;
    self.selectedModel = model;
    if(self.selectedModel){
        self.selectLoaction(self.selectedModel);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearch
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
    _handMove = YES;
    if(self.searchBar.text.length){
        _currentPage = 1;
        [self searchRequest];
        self.tableView.frame = CGRectMake(0, 108, WIDTH, HEIGHT-108);
    }else{
        _currentPage = 1;
        [self searchRequest];
        self.tableView.frame = CGRectMake(0, 108+WIDTH*9/16, WIDTH, HEIGHT-(108+WIDTH*9/16));
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    _handMove = YES;
    if(self.searchBar.text.length==0){
        _currentPage = 1;
        [self searchRequest];
        self.tableView.frame = CGRectMake(0, 108+WIDTH*9/16, WIDTH, HEIGHT-(108+WIDTH*9/16));
    }
}

#pragma mark - UIScrollviewdeleagte
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
    _handMove = YES;
}

@end
