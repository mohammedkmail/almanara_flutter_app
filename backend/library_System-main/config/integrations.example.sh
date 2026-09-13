#!/usr/bin/env bash

# انسخ هذا الملف إلى:
# config/integrations.local.sh
#
# عبّئ القيم الحقيقية ثم نفّذ:
# source config/integrations.local.sh
#
# لا ترفع integrations.local.sh إلى GitHub.

# ============================================================
# Braintree Sandbox
# ============================================================

export BRAINTREE_MERCHANT_ID="YOUR_SANDBOX_MERCHANT_ID"
export BRAINTREE_PUBLIC_KEY="YOUR_SANDBOX_PUBLIC_KEY"
export BRAINTREE_PRIVATE_KEY="YOUR_SANDBOX_PRIVATE_KEY"


# ============================================================
# Production database - optional
# ============================================================

# export DB_USERNAME="YOUR_DB_USERNAME"
# export DB_PASSWORD="YOUR_DB_PASSWORD"
# export DB_URL="YOUR_DB_URL"
