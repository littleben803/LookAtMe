import Combine
import Foundation
import StoreKit

enum ProFeature: String, CaseIterable, Identifiable {
    case heartRainEffect
    case rainbowEffect
    case starSparkleEffect
    case bulletFlyEffect
    case premiumTemplates
    case premiumFonts
    case unlimitedFavorites
    case customStyleSave
    case removeWatermark

    var id: String { rawValue }
}

@MainActor
final class PurchaseManager: ObservableObject {
    static let proProductID = "com.chinasofti.look.pro.lifetime"

    @Published private(set) var isProUnlocked: Bool
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var isPurchasing = false
    @Published private(set) var product: Product?
    @Published private(set) var errorMessage: String?
    @Published private(set) var purchaseSuccess = false
    #if DEBUG
    @Published private(set) var debugStorefrontCountryCode: String?
    #endif

    private let userDefaults: UserDefaults
    private let proCacheKey = "look.pro.cachedIsUnlocked.v1"
    private var transactionUpdatesTask: Task<Void, Never>?

    var productDisplayName: String {
        product?.displayName ?? "想恋爱 Pro 永久解锁"
    }

    var productDisplayPrice: String {
        product?.displayPrice ?? ""
    }

    init(userDefaults: UserDefaults = .standard, autoStart: Bool = true) {
        self.userDefaults = userDefaults
        self.isProUnlocked = userDefaults.bool(forKey: proCacheKey)

        guard autoStart else {
            return
        }

        transactionUpdatesTask = listenForTransactions()
        Task {
            #if DEBUG
            await refreshDebugStorefront()
            #endif
            await refreshEntitlements()
            await loadProducts()
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    func loadProducts() async {
        guard !isLoadingProducts else {
            return
        }

        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            #if DEBUG
            await refreshDebugStorefront()
            #endif
            let products = try await Product.products(for: [Self.proProductID])
            guard let product = products.first(where: { $0.id == Self.proProductID }) else {
                self.product = nil
                errorMessage = "商品加载失败，请稍后重试"
                return
            }

            self.product = product
            errorMessage = nil
        } catch {
            self.product = nil
            errorMessage = message(for: error, fallback: "商品加载失败，请检查网络后重试")
        }
    }

    func purchase() async {
        purchaseSuccess = false
        errorMessage = nil

        if product == nil {
            await loadProducts()
        }

        guard let product else {
            errorMessage = "商品加载失败，请稍后重试"
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verificationResult):
                let transaction = try verified(verificationResult)
                guard transaction.productID == Self.proProductID else {
                    await transaction.finish()
                    errorMessage = "购买商品不匹配，请稍后重试"
                    return
                }

                updateProAccess(isUnlocked: transaction.revocationDate == nil)
                purchaseSuccess = transaction.revocationDate == nil
                errorMessage = transaction.revocationDate == nil ? nil : "购买已撤销，请恢复购买后重试"
                await transaction.finish()
                await refreshEntitlements()

            case .userCancelled:
                errorMessage = "已取消购买"

            case .pending:
                errorMessage = "购买正在处理中，请稍后在设置中恢复购买"

            @unknown default:
                errorMessage = "购买失败，请稍后重试"
            }
        } catch {
            errorMessage = message(for: error, fallback: "购买失败，请稍后重试")
        }
    }

    func restorePurchases() async {
        purchaseSuccess = false
        errorMessage = nil
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            if isProUnlocked {
                purchaseSuccess = true
                errorMessage = nil
            } else {
                errorMessage = "没有找到可恢复的 Pro 购买"
            }
        } catch {
            errorMessage = message(for: error, fallback: "恢复购买失败，请检查网络后重试")
        }
    }

    func refreshEntitlements() async {
        var hasValidProEntitlement = false

        for await entitlement in Transaction.currentEntitlements {
            do {
                let transaction = try verified(entitlement)
                guard transaction.productID == Self.proProductID else {
                    continue
                }
                if transaction.revocationDate == nil {
                    hasValidProEntitlement = true
                }
            } catch {
                errorMessage = message(for: error, fallback: "交易验证失败，请稍后重试")
            }
        }

        updateProAccess(isUnlocked: hasValidProEntitlement)
    }

    func canUse(_ feature: ProFeature) -> Bool {
        isProUnlocked
    }

    func canUse(_ style: BannerStyle) -> Bool {
        isProUnlocked || !style.isPro
    }

    func canUse(_ template: BannerTemplate) -> Bool {
        isProUnlocked || !template.isPro
    }

    func canUse(_ fontStyle: BannerFontStyle) -> Bool {
        isProUnlocked || !fontStyle.isPro
    }

    func clearTransientState() {
        errorMessage = nil
        purchaseSuccess = false
    }

    #if DEBUG
    func refreshDebugStorefront() async {
        let storefront = await Storefront.current
        debugStorefrontCountryCode = storefront?.countryCode
    }

    func resetLocalProCacheForDebug() {
        userDefaults.removeObject(forKey: proCacheKey)
        isProUnlocked = false
        purchaseSuccess = false
        errorMessage = nil
    }
    #endif

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else {
                    return
                }

                do {
                    let transaction = try self.verified(update)
                    if transaction.productID == Self.proProductID {
                        self.updateProAccess(isUnlocked: transaction.revocationDate == nil)
                        self.purchaseSuccess = transaction.revocationDate == nil
                    }
                    await transaction.finish()
                    await self.refreshEntitlements()
                } catch {
                    self.errorMessage = self.message(for: error, fallback: "交易验证失败，请稍后重试")
                }
            }
        }
    }

    private func updateProAccess(isUnlocked: Bool) {
        isProUnlocked = isUnlocked
        userDefaults.set(isUnlocked, forKey: proCacheKey)
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw PurchaseManagerError.unverifiedTransaction
        }
    }

    private func message(for error: Error, fallback: String) -> String {
        if let purchaseError = error as? PurchaseManagerError {
            return purchaseError.localizedDescription
        }

        if let storeKitError = error as? StoreKitError {
            switch storeKitError {
            case .userCancelled:
                return "已取消购买"
            case .networkError:
                return "网络连接失败，请稍后重试"
            case .systemError:
                return "购买失败，请稍后重试"
            default:
                return fallback
            }
        }

        return fallback
    }
}

private enum PurchaseManagerError: LocalizedError {
    case unverifiedTransaction

    var errorDescription: String? {
        switch self {
        case .unverifiedTransaction:
            "交易未通过验证，请稍后重试"
        }
    }
}
