// 添加判断会员有效期的方法
func isVIPValid() -> Bool {
    guard let currentUser = currentUser,
          let vipExpirationDate = currentUser.vipExpirationDate else {
        return false
    }
    
    // 判断会员是否在有效期内
    return Date() < vipExpirationDate
} 