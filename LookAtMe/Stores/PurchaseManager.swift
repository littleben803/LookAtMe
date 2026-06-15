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
        product?.displayName ?? L10n.Purchase.productFallbackName
    }

    func productDisplayName(locale: Locale) -> String {
        product?.displayName ?? L10n.string(L10n.Purchase.productFallbackName, locale: locale)
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
                errorMessage = L10n.Purchase.Error.productLoadFailed
                return
            }

            self.product = product
            errorMessage = nil
        } catch {
            self.product = nil
            errorMessage = message(for: error, fallbackKey: L10n.Purchase.Error.productLoadFailedNetwork)
        }
    }

    func purchase() async {
        purchaseSuccess = false
        errorMessage = nil

        if product == nil {
            await loadProducts()
        }

        guard let product else {
            errorMessage = L10n.Purchase.Error.productLoadFailed
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
                    errorMessage = L10n.Purchase.Error.productMismatch
                    return
                }

                updateProAccess(isUnlocked: transaction.revocationDate == nil)
                purchaseSuccess = transaction.revocationDate == nil
                errorMessage = transaction.revocationDate == nil ? nil : L10n.Purchase.Error.purchaseRevoked
                await transaction.finish()
                await refreshEntitlements()

            case .userCancelled:
                errorMessage = L10n.Purchase.Error.userCancelled

            case .pending:
                errorMessage = L10n.Purchase.Error.purchasePending

            @unknown default:
                errorMessage = L10n.Purchase.Error.purchaseFailed
            }
        } catch {
            errorMessage = message(for: error, fallbackKey: L10n.Purchase.Error.purchaseFailed)
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
                errorMessage = L10n.Purchase.Error.restoreNotFound
            }
        } catch {
            errorMessage = message(for: error, fallbackKey: L10n.Purchase.Error.restoreFailedNetwork)
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
                errorMessage = message(for: error, fallbackKey: L10n.Purchase.Error.verificationFailed)
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
                    self.errorMessage = self.message(for: error, fallbackKey: L10n.Purchase.Error.verificationFailed)
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

    private func message(for error: Error, fallbackKey: String) -> String {
        if let purchaseError = error as? PurchaseManagerError {
            return purchaseError.errorDescription ?? fallbackKey
        }

        if let storeKitError = error as? StoreKitError {
            switch storeKitError {
            case .userCancelled:
                return L10n.Purchase.Error.userCancelled
            case .networkError:
                return L10n.Purchase.Error.networkFailed
            case .systemError:
                return L10n.Purchase.Error.purchaseFailed
            default:
                return fallbackKey
            }
        }

        return fallbackKey
    }
}

private enum PurchaseManagerError: LocalizedError {
    case unverifiedTransaction

    var errorDescription: String? {
        switch self {
        case .unverifiedTransaction:
            L10n.Purchase.Error.unverifiedTransaction
        }
    }
}
