CREATE INDEX IF NOT EXISTS idx_loans_customer_id
ON loans(customer_id);

CREATE INDEX IF NOT EXISTS idx_loans_loan_type_id
ON loans(loan_type_id);

CREATE INDEX IF NOT EXISTS idx_payment_transactions_loan_id
ON payment_transactions(loan_id);

CREATE INDEX IF NOT EXISTS idx_customer_addresses_customer_id
ON customer_addresses(customer_id);

CREATE INDEX IF NOT EXISTS idx_payment_transactions_current_status
ON payment_transactions(current_status);

CREATE INDEX IF NOT EXISTS idx_transaction_history_payment_id
ON transaction_history(payment_id)
WHERE payment_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_transaction_history_provider_transaction_id
ON transaction_history(provider_transaction_id);

CREATE INDEX IF NOT EXISTS idx_transaction_history_processing_status
ON transaction_history(processing_status);

CREATE INDEX IF NOT EXISTS idx_repayment_ledger_loan_id
ON repayment_ledger(loan_id);

CREATE INDEX IF NOT EXISTS idx_processing_batches_file_checksum
ON processing_batches(file_checksum)
WHERE file_checksum IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_processing_batches_batch_status
ON processing_batches(batch_status);

CREATE INDEX IF NOT EXISTS idx_dead_letter_records_batch_id
ON dead_letter_records(batch_id);

CREATE INDEX IF NOT EXISTS idx_dead_letter_records_event_id
ON dead_letter_records(event_id)
WHERE event_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_reconciliation_results_batch_id
ON reconciliation_results(batch_id);

CREATE INDEX IF NOT EXISTS idx_transaction_history_batch_id
ON transaction_history(batch_id);

CREATE INDEX IF NOT EXISTS idx_reconciliation_results_provider_transaction_id
ON reconciliation_results(provider_transaction_id)
WHERE provider_transaction_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_reconciliation_results_status
ON reconciliation_results(reconciliation_status);
