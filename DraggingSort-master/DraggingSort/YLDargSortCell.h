//

#import <UIKit/UIKit.h>

@protocol SKDragSortDelegate <NSObject>

- (void)YLDargSortCellGestureAction:(UIGestureRecognizer *)gestureRecognizer;

- (void)YLDargSortCellCancelSubscribe:(NSString *)subscribe;

@end

@interface YLDargSortCell : UICollectionViewCell
@property (nonatomic,strong) NSString * subscribe;
@property (nonatomic,weak) id<SKDragSortDelegate> delegate;

- (void)showDeleteBtn;
@end
