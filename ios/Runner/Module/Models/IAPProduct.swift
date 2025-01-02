import StoreKit

struct IAPProduct {
    let name: String
    let productId: String
    let description: String
    let diamonds: Int?
    let isMembership: Bool
    
    static let allProducts: [IAPProduct] = [
        IAPProduct(name: "60钻石", productId: "com.nixi.zuanshi6", description: "6元可购买60钻石", diamonds: 60, isMembership: false),
        IAPProduct(name: "300钻石", productId: "com.nixi.zuanshi28", description: "28元可购买300钻石", diamonds: 300, isMembership: false),
        IAPProduct(name: "1130钻石", productId: "com.nixi.zuanshi98", description: "98元可购买1130钻石", diamonds: 1130, isMembership: false),
        IAPProduct(name: "2350钻石", productId: "com.nixi.zuanshi198", description: "198元可购买2350钻石", diamonds: 2350, isMembership: false),
        IAPProduct(name: "3070钻石", productId: "com.nixi.zuanshi268", description: "268元可购买3070钻石", diamonds: 3070, isMembership: false),
        IAPProduct(name: "3600钻石", productId: "com.nixi.zuanshi298", description: "298元可购买3600钻石", diamonds: 3600, isMembership: false),
        IAPProduct(name: "首充月会员", productId: "com.nixi.zuanshi88", description: "88元首次购买月会员", diamonds: nil, isMembership: true),
        IAPProduct(name: "月会员", productId: "com.nixi.zuanshi98", description: "98元购买月会员", diamonds: nil, isMembership: true),
        IAPProduct(name: "季会员", productId: "com.nixi.zuanshi268", description: "268元可购买季度会员", diamonds: nil, isMembership: true)
    ]
} 
