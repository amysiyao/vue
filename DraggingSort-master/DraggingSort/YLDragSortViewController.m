
#import "YLDragSortViewController.h"
#import "YLDragSortTool.h"
#import "YLDargSortCell.h"
#import "UIView+Frame.h"
#import "YLDefine.h"

#define kSpaceBetweenSubscribe  4 * SCREEN_WIDTH_RATIO
#define kVerticalSpaceBetweenSubscribe  2 * SCREEN_WIDTH_RATIO
#define kSubscribeHeight  35 * SCREEN_WIDTH_RATIO
#define kContentLeftAndRightSpace  20 * SCREEN_WIDTH_RATIO
#define kTopViewHeight  80 * SCREEN_WIDTH_RATIO

@interface YLDragSortViewController ()<UICollectionViewDataSource,SKDragSortDelegate>

@property (nonatomic,strong) UIView * topView;
@property (nonatomic,strong) UICollectionView * dragSortView;
@property (nonatomic,strong) UIView * snapshotView; //截屏得到的view
@property (nonatomic,weak) YLDargSortCell * originalCell;
@property (nonatomic,strong) NSIndexPath * indexPath;
@property (nonatomic,strong) NSIndexPath * nextIndexPath;
@property (nonatomic,strong) UIButton * sortDeleteBtn;
@property (nonatomic,strong) UILabel * sortDeleteLab;

@end

@implementation YLDragSortViewController
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view addSubview:self.dragSortView];
    [self.view addSubview:self.topView];
}

- (BOOL)prefersStatusBarHidden {
    //状态栏隐藏
    return YES;
}

//绑定数据
#pragma mark - collectionView dataSouce

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [YLDragSortTool shareInstance].subscribeArray.count;//数组元素个数
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{//参数：
    
    YLDargSortCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YLDargSortCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.subscribe = [YLDragSortTool shareInstance].subscribeArray[indexPath.row];
    return cell;
}
//设置代理
#pragma mark - SKDragSortDelegate

- (void)YLDargSortCellGestureAction:(UIGestureRecognizer *)gestureRecognizer{
    
    //记录上一次手势的位置
    static CGPoint startPoint;
    //触发长按手势的cell
    YLDargSortCell * cell = (YLDargSortCell *)gestureRecognizer.view;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {//识别状态开始
        
        //开始长按，判断状态
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            // 用来判断是否是某个类或其子类的实例
            [YLDragSortTool shareInstance].isEditing = YES;
            [_sortDeleteBtn setTitle:@"完成" forState:UIControlStateNormal];
            _sortDeleteLab.text=@"拖动排序";
            self.dragSortView.scrollEnabled = NO;//显示滚动条
            [UIView animateWithDuration:0.2 animations:^{
                cell.transform=CGAffineTransformMakeScale(1.2, 1.2);
                cell.alpha=1;//透明度
            }];
        }
        if (![YLDragSortTool shareInstance].isEditing) {
            return;
        }
        
        NSArray *cells = [self.dragSortView visibleCells];//获取可用cells
        for (YLDargSortCell *cell in cells) {
            [cell showDeleteBtn];//显示
        }
        
        //获取cell的截图
        _snapshotView  = [cell snapshotViewAfterScreenUpdates:YES];
        _snapshotView.center = cell.center;
        [_dragSortView addSubview:_snapshotView];
        _indexPath = [_dragSortView indexPathForCell:cell];
        _originalCell = cell;
        _originalCell.hidden = YES;
        startPoint = [gestureRecognizer locationInView:_dragSortView];
        
        //移动
    }else if (gestureRecognizer.state == UIGestureRecognizerStateChanged){
        
        
        CGFloat tranX = [gestureRecognizer locationOfTouch:0 inView:_dragSortView].x - startPoint.x;
        CGFloat tranY = [gestureRecognizer locationOfTouch:0 inView:_dragSortView].y - startPoint.y;
        
        //设置截图视图位置
        _snapshotView.center = CGPointApplyAffineTransform(_snapshotView.center, CGAffineTransformMakeTranslation(tranX, tranY));
        startPoint = [gestureRecognizer locationOfTouch:0 inView:_dragSortView];
        //计算截图视图和哪个cell相交
        for (UICollectionViewCell *cell in [_dragSortView visibleCells]) {
            //跳过隐藏的cell
            if ([_dragSortView indexPathForCell:cell] == _indexPath) {
                continue;
            }
            //计算中心距
            CGFloat space = sqrtf(pow(_snapshotView.center.x - cell.center.x, 2) + powf(_snapshotView.center.y - cell.center.y, 2));
            
            //如果相交一半且两个视图Y的绝对值小于高度的一半就移动
            if (space <= _snapshotView.bounds.size.width * 0.5 && (fabs(_snapshotView.center.y - cell.center.y) <= _snapshotView.bounds.size.height * 0.5)) {
                _nextIndexPath = [_dragSortView indexPathForCell:cell];
                if (_nextIndexPath.item > _indexPath.item) {
                    for (NSUInteger i = _indexPath.item; i < _nextIndexPath.item ; i ++) {
                        [[YLDragSortTool shareInstance].subscribeArray exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
                    }
                }else{
                    for (NSUInteger i = _indexPath.item; i > _nextIndexPath.item ; i --) {
                        [[YLDragSortTool shareInstance].subscribeArray exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
                    }
                }
                //移动
                [_dragSortView moveItemAtIndexPath:_indexPath toIndexPath:_nextIndexPath];
                //设置移动后的起始indexPath
                _indexPath = _nextIndexPath;
                break;
            }
        }
        //停止，手势结束
    }else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        [_snapshotView removeFromSuperview];
        _originalCell.hidden = NO;
    }
}

- (void)YLDargSortCellCancelSubscribe:(NSString *)subscribe {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"取消订阅%@",subscribe] message:nil preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertController dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}


- (UIView *)topView {
    
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kTopViewHeight)];
        _topView.backgroundColor = [UIColor whiteColor];
        
        UIButton * closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setImage:[UIImage imageNamed:@"subscribe_close"] forState:UIControlStateNormal];
        CGFloat btnWH = 35 * SCREEN_WIDTH_RATIO;
        CGFloat topMargin = 15 * SCREEN_WIDTH_RATIO;
        CGFloat rightMargin = 15 * SCREEN_WIDTH_RATIO;
        closeBtn.frame = CGRectMake(SCREEN_WIDTH - btnWH - rightMargin, topMargin, btnWH, btnWH);
        [closeBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        //控件范围内触摸抬起事件，调用back函数
        [_topView addSubview:closeBtn];
        
        UILabel * titleLabel = [[UILabel alloc] init];
        titleLabel.font = kFont(16);
        titleLabel.text = @"我的栏目";
        [titleLabel sizeToFit];
        titleLabel.textColor = [UIColor blackColor];
        [_topView addSubview:titleLabel];
        titleLabel.centerY = (kTopViewHeight - closeBtn.bottom) * 0.5 + closeBtn.bottom;
        titleLabel.left = kContentLeftAndRightSpace+5;
        
        UILabel * titleLabel1= [[UILabel alloc] init];
        titleLabel1.font = kFont(14);
        titleLabel1.text = @"点击进入栏目";
        [titleLabel1 sizeToFit];
        titleLabel1.textColor =[UIColor grayColor];
        [_topView addSubview:titleLabel1];
        titleLabel1.centerY = (kTopViewHeight - closeBtn.bottom) * 0.5 + closeBtn.bottom;
        titleLabel1.left = kContentLeftAndRightSpace+titleLabel.width+10;
        _sortDeleteLab=titleLabel1;
       
        
        
        UIButton *  finshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topView addSubview:finshBtn];
        [finshBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [finshBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        finshBtn.titleLabel.font = kFont(16);
        finshBtn.layer.borderColor = [UIColor orangeColor].CGColor;
        finshBtn.layer.borderWidth = kLineHeight;
        finshBtn.layer.cornerRadius = 10 * SCREEN_WIDTH_RATIO;
        finshBtn.layer.masksToBounds = YES;
        [finshBtn sizeToFit];
        finshBtn.height = 21 * SCREEN_WIDTH_RATIO;
        finshBtn.width = finshBtn.width + 8 * SCREEN_WIDTH_RATIO;
        finshBtn.right = SCREEN_WIDTH - kContentLeftAndRightSpace-5;
        finshBtn.centerY = titleLabel.centerY;
        
        [finshBtn addTarget:self action:@selector(finshClick) forControlEvents:UIControlEventTouchUpInside];//完成点击
        _sortDeleteBtn = finshBtn;
        
        UIView * bottomLine = [[UIView alloc] initWithFrame:CGRectMake(20 * SCREEN_WIDTH_RATIO, _topView.height - kLineHeight, SCREEN_WIDTH, kLineHeight)];
        bottomLine.backgroundColor = RGBColorMake(110, 110, 110, 1);
        [_topView addSubview:bottomLine];
    }
    return _topView;
}

- (void)finshClick {
    
    [YLDragSortTool shareInstance].isEditing = ![YLDragSortTool shareInstance].isEditing;
    NSString * title = [YLDragSortTool shareInstance].isEditing ? @"完成":@"编辑";
    NSString * title1 = [YLDragSortTool shareInstance].isEditing ? @"拖动排序":@"点击进入栏目";
    self.dragSortView.scrollEnabled = ![YLDragSortTool shareInstance].isEditing;
    [_sortDeleteBtn setTitle:title forState:UIControlStateNormal];
    _sortDeleteLab.text=title1;
    [self.dragSortView reloadData];
}

- (void)back {
    
    [self dismissViewControllerAnimated:YES completion:nil];//关闭当前视图，返回父视图，参数为空
}

- (UICollectionView *)dragSortView {
    
    if (!_dragSortView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat width = (SCREEN_WIDTH - 3 * kSpaceBetweenSubscribe - 2 * kContentLeftAndRightSpace )/4 ;
        layout.itemSize = CGSizeMake(width, kSubscribeHeight + 10 * SCREEN_WIDTH_RATIO);
        layout.minimumLineSpacing = kSpaceBetweenSubscribe;
        layout.minimumInteritemSpacing = kVerticalSpaceBetweenSubscribe;
        layout.sectionInset = UIEdgeInsetsMake(kContentLeftAndRightSpace, kContentLeftAndRightSpace, kContentLeftAndRightSpace, kContentLeftAndRightSpace);
        _dragSortView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,kTopViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT - kTopViewHeight) collectionViewLayout:layout];
        //注册cell
        [_dragSortView registerClass:[YLDargSortCell class] forCellWithReuseIdentifier:@"YLDargSortCell"];
        _dragSortView.dataSource = self;
        _dragSortView.backgroundColor = [UIColor whiteColor];
    }
    return _dragSortView;
}

@end
