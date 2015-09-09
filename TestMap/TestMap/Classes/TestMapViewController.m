//
//  TestMapViewController.m
//  TestMap
//
//  Created by wsliang on 15/8/14.
//  Copyright (c) 2015年 wsliang. All rights reserved.
//

#import "TestMapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyPoint.h"
#import "dView.h"

@interface TestMapViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *tips;
@property (weak, nonatomic) IBOutlet dView *drowView;
@property (weak, nonatomic) IBOutlet UIButton *drowBtn;

-(IBAction)segmentDidSelected:(UISegmentedControl*)theTaget;

@end

@implementation TestMapViewController
{
  MKCoordinateRegion regionNow;
  CLLocationCoordinate2D locMine;
  BOOL isLoadMineLocation;
  MKMapType mapTypeNow;
  int pointIndex;
  
  
  NSMutableArray *annotationPoints;
  NSMutableArray *polLibcomParks;
  
  BOOL candraw;
//  int count;
  NSMutableArray *drawarrla;
//  NSMutableArray *drawarrlo;
  
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  isLoadMineLocation = NO;
  mapTypeNow = MKMapTypeStandard;
  pointIndex = 0;
  
//  [CLLocationManager requestWhenInUseAuthorization]; // 8.0
  
//  [self.mapView setShowsBuildings:YES]; // 7.0
  [self.mapView setShowsUserLocation:YES];
//  [self.mapView setMapType:MKMapTypeStandard];

  candraw = NO;
  polLibcomParks = [NSMutableArray new];
  annotationPoints = [NSMutableArray new];
  drawarrla = [NSMutableArray new];
  [self.drowView setDefaultData];
  self.drowView.hidden = YES;
  
}

-(void)locationManagerSetup
{
  //创建CLLocationManager对象
  CLLocationManager *locationManager = [[CLLocationManager alloc] init];
  
  //设置委托对象为自己
  [locationManager setDelegate:self];
  
  //要求CLLocationManager对象返回全部结果
  [locationManager setDistanceFilter:kCLDistanceFilterNone];
  
  //要求CLLocationManager对象的返回结果尽可能的精准
  [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
  
  //要求CLLocationManager对象开始工作，定位设备位置
  [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (IBAction)actionOperations:(UIButton *)sender {
  switch (sender.tag) {
    case 100: // self
    {
      MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locMine, 250, 250);
      [self.mapView setRegion:region animated:YES];
    } break;
    case 101: // tag,添加标记选择
    {
      [self addAnnotationPoint:CGPointMake(regionNow.center.latitude, regionNow.center.longitude) isLoadRegion:NO];
    } break;
    case 102: // area,添加区域选择,
    {
      BOOL nowStatus = sender.selected;
      [self.mapView setScrollEnabled:nowStatus];
      [self.mapView setZoomEnabled:nowStatus];
      self.drowView.hidden = nowStatus;
      
      candraw = !nowStatus;
      sender.selected = candraw;
      
    } break;
    case 103: // 清除 标记,区域
    {
      [self.mapView removeOverlays:polLibcomParks];
      [self.mapView removeAnnotations:annotationPoints];
      [annotationPoints removeAllObjects];
      [polLibcomParks removeAllObjects];
      pointIndex = 0;
      
    } break;
      
    default:
      break;
  }
}

//      MKMapTypeStandard = 0,
//      MKMapTypeSatellite,
//      MKMapTypeHybrid
-(IBAction)segmentDidSelected:(UISegmentedControl*)theTaget
{
  mapTypeNow = theTaget.selectedSegmentIndex;
  [self.mapView setMapType:mapTypeNow];
}

//放置标注
-(void)addAnnotationPoint:(CGPoint)thePoint isLoadRegion:(BOOL)isLoad
{
  //创建CLLocation 设置经纬度
  CLLocation *loc = [[CLLocation alloc]initWithLatitude:thePoint.x longitude:thePoint.y];
  CLLocationCoordinate2D coord = [loc coordinate];
  //创建标题
  NSString *titile = [NSString stringWithFormat:@"%f,%f",coord.latitude,coord.longitude];
  MyPoint *myPoint = [[MyPoint alloc] initWithCoordinate:coord andTitle:titile andSubtitle:@"这里是描述文字..."];
  myPoint.headimage = @"tag_self";
  myPoint.tag = ++pointIndex;
  //添加标注
  [self.mapView addAnnotation:myPoint];
  [annotationPoints addObject:myPoint];
  //放大到标注的位置
  if (isLoad) {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 250, 250);
    [self.mapView setRegion:region animated:YES];
  }
}


#pragma mark ---- map delegate ----

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
  NSLog(@"--- mapViewWillStartLocatingUser ---");
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
  NSLog(@"--- mapViewDidStopLocatingUser ---");
}

// 更新 当前用户的位置
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
  userLocation.title = @"我的位置";
  NSLog(@"--- didUpdateUserLocation :%@ ---",userLocation);

  CLLocationCoordinate2D loc = [userLocation coordinate];
  locMine = loc;
  
  //显示到label上
  self.tips.text = [NSString stringWithFormat:@"我的位置:\n经度:%f 纬度:%f",loc.longitude,loc.latitude]; // 经度

  
  if (!isLoadMineLocation) {
    //放大地图到自身的经纬度位置。
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
    [self.mapView setRegion:region animated:YES];
    isLoadMineLocation = YES;
  }
  
  // 获取详细的街道信息
  CLLocation * newLocation = userLocation.location;
  CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init];
  CLGeocodeCompletionHandler handle = ^(NSArray *placemarks,NSError *error)
  {
    for (CLPlacemark * placeMark in placemarks)
    {
      NSDictionary *addressDic=placeMark.addressDictionary;
      
      NSString *state=[addressDic objectForKey:@"State"];
      NSString *city=[addressDic objectForKey:@"City"];
      NSString *subLocality=[addressDic objectForKey:@"SubLocality"];
      NSString *street=[addressDic objectForKey:@"Street"];
      
      // ---- state:上海市 , city:上海市市辖区 , subLocality:长宁区 , street :芙蓉江路  ----
      NSLog(@"---- 我的位置: state:%@ , city:%@ , subLocality:%@ , street :%@  ----",state,city,subLocality,street);
    }

  };
  [clGeoCoder reverseGeocodeLocation:newLocation completionHandler:handle];

}

// 用户位置更新错误
-(void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
  NSLog(@"--- didFailToLocateUserWithError:%@ ---",error);
  self.tips.text = @"定位当前位置失败";
}




- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
  NSLog(@"--- regionWillChangeAnimated:%@ ---",animated?@"YES":@"NO");
  self.tips.text = @"移动位置...";
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
  regionNow = mapView.region;
  MKCoordinateRegion region = mapView.region;
  NSString *regionStr = [NSString stringWithFormat:@" center:%f,%f span:%f,%f ",region.center.longitude,region.center.latitude,region.span.longitudeDelta,region.span.latitudeDelta];
  NSLog(@"--- regionDidChangeAnimated:%@ ---",regionStr);
  self.tips.text = [NSString stringWithFormat:@"当前位置:\n经度:%4.4f 纬度:%4.4f",region.center.longitude,region.center.latitude];
}


- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
  NSLog(@"--- mapViewWillStartLoadingMap ---");
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
  NSLog(@"--- mapViewDidFinishLoadingMap ---");
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
  NSLog(@"--- mapViewDidFailLoadingMap:%@ ---",error);
}


- (void)mapViewWillStartRenderingMap:(MKMapView *)mapView
{
  NSLog(@"--- mapViewWillStartRenderingMap ---");
}

- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered
{
  NSLog(@"--- mapViewDidFinishRenderingMap:%d ---",fullyRendered);
}





// 自定义 标签 图标
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
  NSLog(@"--- viewForAnnotation ---");
  
  //方法二：using the image as a PlaceMarker to display on map
  if ([annotation isKindOfClass:[MyPoint class]])
  {
    MKAnnotationView *newAnnotation=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"tag_custom"];
    newAnnotation.image = [UIImage imageNamed:@"tag_custom"];
    MyPoint *travellerAnnotation = (MyPoint *)annotation;
    UIImageView *imageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:travellerAnnotation.headimage]];
    [imageview setFrame:CGRectMake(0, 0, 20, 20)];
    newAnnotation.leftCalloutAccessoryView = imageview;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [btn addTarget:self action:@selector(actionGotoDetailPoint:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = travellerAnnotation.tag;//在按钮事件里可获取某个tag标示，以拿到点击来源的btn
    newAnnotation.rightCalloutAccessoryView = btn;
    newAnnotation.canShowCallout=YES;
    newAnnotation.annotation = annotation;
    return newAnnotation;
  }
  // 自己当前位置的 标记
//  if ([annotation isKindOfClass:[selfmark class]]) {
//    MKAnnotationView *newAnnotation = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"tag_self"];
//    newAnnotation.canShowCallout=YES;
//    newAnnotation.image = [UIImage imageNamed:@"tag_self"];
//    newAnnotation.annotation=annotation;
//    return newAnnotation;
//  }
  return Nil;
  
}

-(IBAction)actionGotoDetailPoint:(UIButton*)sender
{
  NSLog(@"----- tag button touched tag:%ld ------",(long)sender.tag);
  [self alertTitle:nil content:[NSString stringWithFormat:@"选择了一个标记%ld",(long)sender.tag]];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
  NSLog(@"--- didAddAnnotationViews:%@ ---",views);
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
  NSLog(@"--- annotationView:%@ calloutAccessoryControlTapped:%@ ---",view,control);
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
  NSLog(@"--- didSelectAnnotationView:%@ ---",view);
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
  NSLog(@"--- didDeselectAnnotationView:%@ ---",view);
}





- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
  NSLog(@"--- annotationView:%@ didChangeDragState:%lu fromOldState:%lu ---",view,newState,oldState);
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
  NSLog(@"--- didChangeUserTrackingMode:%d ---",animated);
}

//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
//{
//  NSLog(@"--- rendererForOverlay ---");
//}

- (void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers
{
  NSLog(@"--- didAddOverlayRenderers:%@ ---",renderers);
}

// 覆盖层 设置
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
  NSLog(@"--- viewForOverlay %@ ---",overlay);
  
  if ([overlay isKindOfClass:[MKPolygon class]])
  {
    MKPolygonView* aView = [[MKPolygonView alloc]initWithPolygon:(MKPolygon*)overlay];
    aView.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.2f];
    aView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.7f];
    aView.lineWidth = 3;
    return aView;
  }
  return nil;
}

- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews
{
  NSLog(@"--- didAddOverlayViews:%@ ---",overlayViews);
}









-(void)alertTitle:(NSString*)theTitle content:(NSString*)theContent
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:theTitle?:@"提 示 :" message:theContent delegate:nil cancelButtonTitle:@"确  定" otherButtonTitles:nil, nil];
  [alert show];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


// 绘制区域
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
  if (candraw) {
    [drawarrla removeAllObjects];
//    [self.mapView removeOverlay:polLibcomPark];
//    [self.mapView removeOverlays:polLibcomParks];
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    //CLLocationCoordinate2D coo = [mapview convertPoint:point toCoordinateFromView:mapview];
    [drawarrla addObject:[NSValue valueWithCGPoint:point]];
    //        libComPark[0] = CLLocationCoordinate2DMake(coo.latitude,coo.longitude);
  }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
  if (candraw) {
    CGPoint point = [[touches anyObject] locationInView:self.view];
    [drawarrla addObject:[NSValue valueWithCGPoint:point]];
//        CLLocationCoordinate2D coo = [mapview convertPoint:point toCoordinateFromView:mapview];
//        libComPark[count] = CLLocationCoordinate2DMake(coo.latitude,coo.longitude);
//        polLibcomPark = [MKPolygon polygonWithCoordinates:libComPark count:count];
//        [mapview addOverlay:polLibcomPark];
  }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
  if (candraw) {
    CLLocationCoordinate2D libComPark[[drawarrla count]];
    for (int di = 0; di < [drawarrla count]; di ++) {
      CGPoint po = [[drawarrla objectAtIndex:di] CGPointValue];
      CLLocationCoordinate2D coo = [self.mapView convertPoint:po toCoordinateFromView:self.mapView];
      libComPark[di] = CLLocationCoordinate2DMake(coo.latitude,coo.longitude);
    }
    MKPolygon *polLibcomPark = [MKPolygon polygonWithCoordinates:libComPark count:[drawarrla count]];
    [polLibcomParks addObject:polLibcomPark];
    [self.mapView addOverlay:polLibcomPark];
    
    [self.mapView setScrollEnabled:YES];
    [self.mapView setZoomEnabled:YES];
    candraw = NO;
    self.drowView.hidden = YES;
    self.drowBtn.selected = NO;
  }
}


@end
