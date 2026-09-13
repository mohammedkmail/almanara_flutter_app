package librarysystem

import com.braintreegateway.BraintreeGateway
import com.braintreegateway.Environment
import com.braintreegateway.Result
import com.braintreegateway.Transaction
import com.braintreegateway.TransactionRequest
import java.math.RoundingMode

class BraintreeGatewayService {

    boolean isConfigured() {
        merchantId() && publicKey() && privateKey()
    }

    String clientToken() {
        ensureConfigured()
        gateway().clientToken().generate()
    }

    Map sale(BigDecimal amount, String nonce, String orderId) {
        ensureConfigured()
        if (!nonce) throw new IllegalArgumentException('تعذر استلام رمز الدفع الآمن من Braintree.')

        TransactionRequest request = new TransactionRequest()
            .amount(amount.setScale(2, RoundingMode.HALF_UP))
            .paymentMethodNonce(nonce)
            .orderId(orderId)
            .options()
                .submitForSettlement(true)
                .done()

        Result<Transaction> result = gateway().transaction().sale(request)

        if (!result.isSuccess()) {
            String details = result.errors?.allDeepValidationErrors
                ?.collect { it.message }
                ?.findAll { it }
                ?.join(' • ')
            throw new IllegalStateException(details ?: result.message ?: 'رفضت بوابة الدفع العملية التجريبية.')
        }

        Transaction tx = result.target
        [
            transactionId: tx.id,
            status       : tx.status?.toString(),
            cardBrand    : tx.creditCard?.cardType?.toString(),
            lastFour     : tx.creditCard?.last4,
            cardholderName: tx.creditCard?.cardholderName
        ]
    }

    void voidTransactionQuietly(String transactionId) {
        if (!transactionId || !isConfigured()) return
        try {
            gateway().transaction().voidTransaction(transactionId)
        } catch (Exception ignored) {
            // Best-effort compensation. The original exception remains the primary failure.
        }
    }

    private BraintreeGateway gateway() {
        new BraintreeGateway(Environment.SANDBOX, merchantId(), publicKey(), privateKey())
    }

    private void ensureConfigured() {
        if (!isConfigured()) {
            throw new IllegalStateException(
                'Braintree Sandbox غير مهيأ بعد. أضف BRAINTREE_MERCHANT_ID وBRAINTREE_PUBLIC_KEY وBRAINTREE_PRIVATE_KEY.'
            )
        }
    }

    private String merchantId() { System.getenv('BRAINTREE_MERCHANT_ID')?.trim() }
    private String publicKey() { System.getenv('BRAINTREE_PUBLIC_KEY')?.trim() }
    private String privateKey() { System.getenv('BRAINTREE_PRIVATE_KEY')?.trim() }
}
