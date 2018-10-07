

#import <Foundation/Foundation.h>

@interface YLDragSortTool : NSObject
@property (nonatomic,assign) BOOL isEditing;
@property (nonatomic,strong) NSMutableArray * subscribeArray;
+ (instancetype)shareInstance;
//单例模式，只拥有一个全局对象
@end
