#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

printf '\n[1/7] Java\n'
java -version

printf '\n[2/7] Grails\n'
if command -v grails >/dev/null 2>&1; then
  grails --version
else
  echo 'تحذير: أمر grails غير موجود في PATH.'
fi

printf '\n[3/7] الملفات الأساسية\n'
required=(
  grails-app/controllers/librarysystem/PaymentController.groovy
  grails-app/services/PaymentService.groovy
  grails-app/services/BraintreeGatewayService.groovy
  grails-app/services/HolidayCalendarService.groovy
  grails-app/domain/librarysystem/Payment.groovy
  grails-app/domain/librarysystem/CheckoutIntent.groovy
  grails-app/views/payment/checkout.gsp
  grails-app/views/holiday/index.gsp
  grails-app/views/discountRule/index.gsp
)
for file in "${required[@]}"; do
  [[ -f "$file" ]] || { echo "ملف ناقص: $file"; exit 1; }
done
echo 'الملفات الأساسية موجودة.'

printf '\n[4/7] إعدادات التكاملات\n'
if [[ -n "${BRAINTREE_MERCHANT_ID:-}" && -n "${BRAINTREE_PUBLIC_KEY:-}" && -n "${BRAINTREE_PRIVATE_KEY:-}" ]]; then
  echo 'Braintree Sandbox: configured'
else
  echo 'Braintree Sandbox: NOT configured (الدفع الأونلاين لن يعمل حتى تضبط المفاتيح)'
fi
if [[ -n "${HOLIDAY_API_KEY:-}" ]]; then
  echo 'Holiday API: configured'
else
  echo 'Holiday API: not configured (سيعمل fallback المحلي)'
fi

printf '\n[5/7] Compile\n'
if command -v grails >/dev/null 2>&1; then
  grails compile
else
  ./gradlew compileGroovy
fi

printf '\n[6/7] Unit tests\n'
./gradlew test

printf '\n[7/7] Integration tests\n'
./gradlew integrationTest

echo '\nتم التحقق بنجاح.'
