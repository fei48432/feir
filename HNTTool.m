//
//  HNTTool.m
//  demo
//
//  Created by 东哥 on 2022/4/19.
//

#import "HNTTool.h"
#import "HNHotspotInfoModel.h"
#import "HouseUsageModel.h"


@interface HNTTool ()

@property(nonatomic ,assign) NSInteger         pageNo;

@property(nonatomic ,assign) NSInteger         pageSize;

@property(nonatomic ,copy) NSString             *houseId;

@property(nonatomic ,assign) NSInteger         indexArr;

@property(nonatomic ,assign) NSInteger         indexAccount;

@property(nonatomic ,strong) NSArray            *addressArr;

@property(nonatomic ,strong) NSMutableArray<HNTAccountModel*>     *accountArr;

@property (nonatomic, copy) void(^finishBlock)(NSArray<HNTAccountModel*> *listAccount);

@property (nonatomic, copy) void(^progressBlock)(CGFloat progress);

@end

@implementation HNTTool


-(NSMutableArray<HNTAccountModel *> *)accountArr
{
    if (!_accountArr) {
        _accountArr = [NSMutableArray array];
    }
    
    return _accountArr;
}


+ (void)getAccountsInfoWithAccountArr:(NSArray*)hotspotArr
                             progress:(void (^)(CGFloat progress ))loadProgress
                         FinishedInfo:(void (^)( NSArray*obj))finishInfoBlcok{
    HNTTool *temp = [[HNTTool alloc]init];
    temp.indexArr = temp.indexAccount = 0;
    temp.addressArr = hotspotArr;
    temp.finishBlock = finishInfoBlcok;
    temp.progressBlock = loadProgress;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [temp loadAccountsInfoData];
    });
}


-(void)loadAccountsInfoData{
    
    
    __block HNTTool* weakself = self;
    
    
    if (weakself.indexArr>=self.addressArr.count)  return;
    
    if (weakself.indexArr == 1)  [self loadHotspotInfo];
    
    
    [FSNetworkController getaccountsInfoWithAddress:self.addressArr[weakself.indexArr] FinishedInfo:^(HNTAccountModel * _Nonnull obj) {
        
        if (obj != nil) {
            
            __block BOOL isExist = NO;
            [weakself.accountArr enumerateObjectsUsingBlock:^(HNTAccountModel * _Nonnull tobj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([tobj.address isEqualToString:obj.address])  isExist = *stop = YES;
                
            }];
            if(!isExist)  [weakself.accountArr addObject:obj];
            
            weakself.indexArr += 1;
            
        }
        
        [weakself loadAccountsInfoData];
        
    }];
    
}


-(void)loadHotspotInfo
{
    
    if (self.accountArr.count<1  || self.indexAccount >= self.addressArr.count)  {
        if (self.indexAccount >= self.addressArr.count) {
            [self.accountArr sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"address" ascending:YES]]];
            if(self.finishBlock)  self.finishBlock(self.accountArr);
        }
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (self.indexAccount < self.addressArr.count)  [self  loadHotspotInfo];
        });
        return;
    }
    
    if(self.progressBlock) self.progressBlock(self.indexAccount/(self.addressArr.count*1.0));
    if(self.finishBlock)  self.finishBlock(self.accountArr);
    __block HNTTool* weakself = self;
    
    @synchronized (self) {
        
        if (weakself.indexAccount>=weakself.accountArr.count) weakself.indexAccount =  weakself.accountArr.count - 1;
        
        NSString *temp = weakself.accountArr[weakself.indexAccount].address;
        
        if (temp.length < 12)  return;
        
        [FSNetworkController getHotspotsInfoWithAddress:temp Finished:^(NSArray<HNHotspotInfoModel *> * _Nonnull obj) {
            if (obj != nil ) {
                
                for (HNTAccountModel *tmj in weakself.accountArr) {
                    if ([tmj.address isEqualToString:obj.firstObject.owner]) {
                        tmj.listHotspot = obj;
                    }
                };
                
                weakself.indexAccount += 1;
            }
            [weakself loadHotspotInfo];
        }];
    }
    
}


+(NSDictionary*)getSumAmountWithListAccount:(NSArray<HNTAccountModel*>*)listAccount
{
    NSDecimalNumber *totalAmount = [NSDecimalNumber decimalNumberWithString:@"0.000"];
    NSInteger offNumber = 0;
    
    for (HNTAccountModel *tmj in listAccount) {
        totalAmount = [totalAmount decimalNumberByAdding:tmj.money];
        for (HNHotspotInfoModel *hmodel in tmj.listHotspot) {
            if ([hmodel.model.online isEqualToString:@"offline"])  offNumber += 1;
        }
    };
    return @{@"totalAmount":totalAmount , @"offNumber" : @(offNumber)};
    
}

+ (void)getHouseTotalCountInfoWithHouseId:(NSString*)houseId
                                 progress:(void (^)(CGFloat progress ))loadProgress
                             FinishedInfo:(void (^)( NSArray*obj))finishInfoBlcok
{
    HNTTool *temp = [[HNTTool alloc]init];
    temp.pageNo = temp.pageSize = 1;
    temp.finishBlock = finishInfoBlcok;
    temp.progressBlock = loadProgress;
    temp.houseId = houseId;
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [temp loadHouseTotalCountInfoData];
    //    });
    
    
}

-(void)loadHouseTotalCountInfoData
{
    @synchronized (self) {
        
        NSString *url = [NSString stringWithFormat:@"http://58.19.239.219:81/xyWeb/project/queryHousesGroupByUnit?page=%ld&limit=15&projectId=85c6d4c6-41d7-4760-97e5-a4f11e40b89e&buildingId=%@",(long)_pageNo,_houseId];
        
        if (self.pageNo > self.pageSize)  {
            
            if(self.finishBlock)  self.finishBlock(self.accountArr);
            
            return;
        }
        
        if(self.progressBlock) self.progressBlock(self.pageNo);
        
        __block HNTTool* weakself = self;
        
        
        
        [[FSNetworkController shareNetController] GETURL:url Finished:^(NetState state, id  _Nonnull responseObject) {
            if (state == net_Parser_SUCCES) {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {
                    if ([responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary * obj = responseObject[@"data"];
                        
                        NSArray * tmpModel = [HouseUsageModel mj_objectArrayWithKeyValuesArray:obj[@"data"]];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if (tmpModel.count > 0) [weakself.accountArr addObjectsFromArray:tmpModel];
                            weakself.pageNo += 1;
                            weakself.pageSize = ceil([obj[@"totalCount"] intValue]/15.0);
                            
                        });
         

                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakself loadHouseTotalCountInfoData];
                        });
                        
                    }
                    
                }
            }else{
//                weakself.pageNo = 1;
                [weakself loadHouseTotalCountInfoData];
            }
            
        }];
    }
}


@end
