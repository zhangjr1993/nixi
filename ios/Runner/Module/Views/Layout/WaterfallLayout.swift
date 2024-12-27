import UIKit

class WaterfallLayout: UICollectionViewFlowLayout {
    private let columns: Int = 2
    private let spacing: CGFloat = 8
    private var cachedAttributes: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { return }
        
        let columnWidth = (contentWidth - spacing * (CGFloat(columns) - 1)) / CGFloat(columns)
        var columnHeights = Array(repeating: 0.0, count: columns)
        var currentColumn = 0
        
        cachedAttributes.removeAll()
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let height = columnWidth + 8 + 20 + 18 + 16  // 图片高度 + 上下间距 + 姓名高度 + 职业高度
            
            let frame = CGRect(x: (columnWidth + spacing) * CGFloat(currentColumn),
                             y: columnHeights[currentColumn],
                             width: columnWidth,
                             height: height)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cachedAttributes.append(attributes)
            
            columnHeights[currentColumn] = frame.maxY + spacing
            contentHeight = max(contentHeight, frame.maxY + spacing)
            
            currentColumn = columnHeights.firstIndex(of: columnHeights.min() ?? 0) ?? 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cachedAttributes.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
} 
